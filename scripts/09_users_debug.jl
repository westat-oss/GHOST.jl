using GHOST
using DataFrames: DataFrames, AbstractDataFrame, DataFrame, order, groupby, select, leftjoin, nrow, rename, subset, sort
using Tables: ByRow
using Diana: Diana, HTTP, Client, GraphQLClient, Result,
             # HTTP
             HTTP.request, HTTP.ExceptionRequest.StatusError
using Distributed: addprocs, @everywhere, fetch, @spawnat, workers, remotecall, remotecall_eval, Future, @sync, @distributed
using JSON3: JSON3
using LibPQ: LibPQ, Connection, execute, load!,
             # Intervals
             Intervals, Interval, superset, Closed, Open,
             # TimeZones
             TimeZones, TimeZone, ZonedDateTime, UTC, TimeZones.utc_tz,
             # Dates
             Dates, DateTime, Dates.CompoundPeriod, Dates.canonicalize, Second, Year, Month, Week, Dates.format, now, unix2datetime, Day, Date, Hour, year, Minute,
             # Tables
             Tables, rowtable
using CSV
import Base: show, summary, isless
setup(pats = [GitHubPersonalAccessToken("simas", "INSERTPATHERE")])
(;conn, schema, pat) = GHOST.PARALLELENABLER

# __typename below is what tells us user / bot / organization
# while not done, set done = true when no groups left
big_users = execute(conn,
            """
            select id as author_id from ghost.test_usr_codegov;
            """) |>
    (obj -> getproperty.(obj, :author_id))

# Creates a vector of user id vectors, where the inner vector is at most 1_000 elements in size.
grouped_users = [big_users[i:min(i + 999, lastindex(big_users))] for i in 1:1_000:length(big_users) ]
grouped_users_count = lastindex(grouped_users)

for i in 1:grouped_users_count
    @info "Querying user group $i of $grouped_users_count)..."
    users = grouped_users[i]
    try
        nodes = [ users[i:min(i + 99, lastindex(users))] for i in 1:100:length(users) ]
        vars = Dict(zip(string.("x", eachindex(nodes)), nodes))
        query = string("fragment a on Node {id __typename",
                       "...on User {login, createdAt, location} ",
                       "...on Organization {login, createdAt, location} ",
                       "...on Bot {login, createdAt, location: resourcePath}",
                       "...on Mannequin {login, createdAt, location: resourcePath}}",
                       "query A(",
                       join(("\$x$i:[ID!]!" for i in eachindex(nodes)), ','),
                       "){",
                       join(("_$i:nodes(ids:\$x$i){...a}" for i in eachindex(nodes)), ' '),
                       "}")
        @info "Sending query for user group."
        result = graphql(query, vars = vars, max_retries = 1)
        @info "Received results for user group."
        json = JSON3.read(result.Data)
    
        if (haskey(json, "errors"))
            println("Errors found....")
            println(length(json.errors))
    
            bad_uuids = String[]
            bad_df = DataFrame([[],[],[],[],[]], ["id", "__typename", "login", "createdAt", "location"])
            for n in [1:1:length(json.errors);]
                push!(bad_uuids, split(json.errors[n].message, "'")[2])    
                push!(bad_df, [split(json.errors[n].message, "'")[2],"None","None","2000-01-01T01:01:01Z","None"])    
            end
    
            for p in [1:1:length(vars);]
                filter!(e->e∉bad_uuids, eval(Meta.parse(string.("vars[\"x", p, "\"]"))))
            end
    
            query = string("fragment a on Node {id __typename",
                        "...on User {login, createdAt, location} ",
                        "...on Organization {login, createdAt, location} ",
                        "...on Bot {login, createdAt, location: resourcePath}",
                        "...on Mannequin {login, createdAt, location: resourcePath}}",
                        "query A(",
                        join(("\$x$i:[ID!]!" for i in eachindex(nodes)), ','),
                        "){",
                        join(("_$i:nodes(ids:\$x$i){...a}" for i in eachindex(nodes)), ' '),
                        "}")
            @info "Sending query for user group."
            result = graphql(query, vars = vars, max_retries = 1)
            @info "Received results for user group."
            json = JSON3.read(result.Data)
            output = reduce(vcat, DataFrame(r for r in values(elem) if ~isnothing(r)) for elem in values(json.data))
            output = vcat(output, bad_df)
    
            @info "Creating data frame and saving to db."
            execute(conn, "BEGIN;")
            GHOST.load!(output, conn, "UPDATE $schema.test_usr_codegov SET login=\$3, acctype=\$2, createdat=\$4, location=\$5 WHERE id = \$1;")
            execute(conn, "COMMIT;")
            @info "Done with user group."
            sleep(15)
            nothing 
        else
            @info "Creating data frame and saving to db."
            output = reduce(vcat, DataFrame(r for r in values(elem) if ~isnothing(r)) for elem in values(json.data))
            execute(conn, "BEGIN;")
            GHOST.load!(output, conn, "UPDATE $schema.test_usr_codegov SET login=\$3, acctype=\$2, createdat=\$4, location=\$5 WHERE id = \$1;")
            execute(conn, "COMMIT;")
            @info "Done with user group."
            sleep(15)
            nothing 
        end
    catch
        continue
    end
end
