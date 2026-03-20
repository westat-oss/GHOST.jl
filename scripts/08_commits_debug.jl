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

setup(pats = [GitHubPersonalAccessToken("jeremycorry", "INSERTPATHERE")])
(;conn, schema, pat) = GHOST.PARALLELENABLER

sandia_df = CSV.read("doe_additions_sandia.csv", DataFrame)
codegov_df = CSV.read("codegov_github_slugs.csv", DataFrame)

# need to add a column to this call it extra_done which will only query real users and get their extra data (that way we dont waste time on bots/organizations and such)
function query_repos_by_name(slug::String)

    owner, name = split(slug, "/")

    query = String(read(joinpath(pkgdir(GHOST), "src", "assets", "graphql", "07_repo_slug_to_id.graphql"))) |>
        (obj -> replace(obj, r"\s+" => " ")) |>
        (obj -> replace(obj, r"\s+(\{|\}|\:)\s*" => s"\1")) |>
        (obj -> replace(obj, r"(:|,|\.{3})\s*" => s"\1")) |>
        strip |>
        string

    vars = Dict("reponame" => name,
                "repoowner" => owner)

    result = graphql(query, vars = vars, max_retries = 2)

    # needs to be global so the eval(Meta.parse(string. 's can see this variable
    repo_id = JSON3.read(result.Data)

    # if (haskey(repo_id, "errors"))
    #     @info ("Errors found....")
    #     @info (length(repo_id.errors))
    #     @info (repo_id.errors)
    #     sleep(.025)
    # else
    #     @info "Getting repo data frame and saving to db."
    #     query_commits_debug(repo_id.data.repository.defaultBranchRef.id)
    #     sleep(.025)
    # end
    @info "Done with repo : $slug"
    return repo_id.data.repository.defaultBranchRef.id
    nothing
end


# need to add a column to this call it extra_done which will only query real users and get their extra data (that way we dont waste time on bots/organizations and such)
function query_repos_by_name_test(slug::String)

    owner, name = split(slug, "/")

    query = String(read(joinpath(pkgdir(GHOST), "src", "assets", "graphql", "07_repo_slug_to_id.graphql"))) |>
        (obj -> replace(obj, r"\s+" => " ")) |>
        (obj -> replace(obj, r"\s+(\{|\}|\:)\s*" => s"\1")) |>
        (obj -> replace(obj, r"(:|,|\.{3})\s*" => s"\1")) |>
        strip |>
        string

    vars = Dict("reponame" => name,
                "repoowner" => owner)

    try
        result = graphql(query, vars = vars, max_retries = 1)
        repo_id = JSON3.read(result.Data)
        return repo_id.data.repository.defaultBranchRef.id        
    catch
        return ""
    end
end
"""
    parse_author(node)::NamedTuple

This parses the email, name, and ID of the author node.
"""
parse_author(node) = (email = escape_string(node.email),
                      name = escape_string(node.name),
                      id = isnothing(node.user) ? missing : escape_string(node.user.id))
"""
    parse_commit(branch, node)::NamedTuple

This parses a commit node and adds the branch it queried.
"""
function parse_commit(branch, node)
    # if isnothing(node)
    #     @error(branch)
    #     throw(ErrorException("Weird thing going on"))
    # end
    authors = parse_author.(getproperty.(node.authors.edges, :node))
    emails = getproperty.(authors, :email)
    names = getproperty.(authors, :name)
    users = getproperty.(authors, :id)
    (branch = branch,
     id = node.id,
     sha1 = node.oid,
     committed_ts = replace(node.committedDate, "Z" => ""),
     emails = emails,
     names = names,
     users = users,
     additions = node.additions,
     deletions = node.deletions)
end

function query_commits_debug(branch::AbstractString; batch_size::Integer = 16)::Nothing
    (;conn, schema) = GHOST.PARALLELENABLER
    @info "In query_commits()"
    #since = execute(conn, "SELECT MIN(committedat) AS since FROM $(schema).commits WHERE branch = '$branch';") |>
    #    (obj -> only(getproperty.(obj, :since)))
    #since = coalesce(since, GHOST.GH_FIRST_REPO_TS)
    since = GHOST.GH_FIRST_REPO_TS

    try
        execute(conn, "BEGIN;")

        output = DataFrame(
            branch = String[],
            id = String[],
            sha1 = String[],
            committed_ts = String[],
            emails = Union{Missing, String, Vector{Union{Missing, String}}, Vector{String}, Vector{Missing}}[],
            names = Union{Missing, String, Vector{Union{Missing, String}}, Vector{String}, Vector{Missing}}[],
            users = Union{Missing, String, Vector{Union{Missing, String}}, Vector{String}, Vector{Missing}}[],
            additions = Int[],
            deletions = Int[]
        )
        query = String(read(joinpath(pkgdir(GHOST), "src", "assets", "graphql", "04_commits_single.graphql"))) |>
            (obj -> replace(obj, r"\s+" => " ")) |>
            (obj -> replace(obj, r"\s+(\{|\}|\:)\s*" => s"\1")) |>
            (obj -> replace(obj, r"(:|,|\.{3})\s*" => s"\1")) |>
            strip |>
            string
        vars = Dict("since" => string(since, "Z"),
                    "until" => "2025-01-01T00:00:00Z",
                    "node" => branch,
                    "first" => batch_size
                    )
        success = false


        json = try
            while !success
                @info "Running query in query_commits($branch)."
                result = graphql(query, vars = vars, max_retries = 3)
                json = JSON3.read(result.Data)
                if haskey(json, :errors)
                    if first(json.errors).type == "NOT_FOUND"
                        return
                    end
                end
                try
                    json = json.data.node.target.history
                    success = !isempty(json.edges)
                catch err
                    @warn err
                    vars["first"] == 1 && throw(ErrorException("$branch is not playing nice."))
                    vars["first"] ÷= 2
                end
            end
            json
        catch err
            @error err
            throw(ErrorException("$branch is not playing nice ($first)."))
        end
        for edge in json.edges
            if !isnothing(edge.node)
                push!(output, parse_commit(branch, edge.node))
            end
        end
        @info "Saving commits for branch $branch."
        execute(conn, "BEGIN;")
        load!(output,
            conn,
            string("INSERT INTO $(schema).commit_codegov VALUES (",
                    join(("\$$i" for i in 1:size(output, 2)), ','),
                    ");"))
        execute(conn, "COMMIT;")
        
        batch_count = 0

        while json.pageInfo.hasNextPage & batch_count < 10

            batch_count = batch_count+1

            if (maximum(output[!, "committed_ts"]) == minimum(output[!, "committed_ts"]))
                new_since = string(DateTime(maximum(output[!, "committed_ts"])) + Hour(1), "Z")
                vars["since"] = new_since
            else
                vars["since"] = string(DateTime(maximum(output[!, "committed_ts"])), "Z")
            end

            vars["first"] = batch_size
            success = false
            json = try
                while !success
                    @debug "Running query in query_commits()."
                    result = graphql(query, vars = vars, max_retries = 3)
                    @debug "Parsing JSON in query_commits()."
                    json = JSON3.read(result.Data)
                    if haskey(json, :errors)
                        if first(json.errors).type == "NOT_FOUND"
                            return
                        end
                        if first(json.errors).type == "SERVICE_UNAVAILABLE"
                            @info "SERVICE NOT AVAILABLE"
                        end
                    end
                    try
                        json = json.data.node.target.history
                        success = !isempty(json.edges) || ((isempty(json.edges) && !haskey(json, :errors)))
                    catch err
                        @error err
                        vars["first"] == 1 && throw(ErrorException("$branch is not playing nice."))
                        vars["first"] ÷= 2
                    end
                end
                json
            catch err
                @error err
                execute(conn, "ROLLBACK;")
                throw(ErrorException("$branch is not playing nice ($first)."))
            end
            output = DataFrame(
                branch = String[],
                id = String[],
                sha1 = String[],
                committed_ts = String[],
                emails = Union{Missing, String, Vector{Union{Missing, String}}, Vector{String}, Vector{Missing}}[],
                names = Union{Missing, String, Vector{Union{Missing, String}}, Vector{String}, Vector{Missing}}[],
                users = Union{Missing, String, Vector{Union{Missing, String}}, Vector{String}, Vector{Missing}}[],
                additions = Int[],
                deletions = Int[]
            )

            for edge in json.edges
                if !isnothing(edge.node)
                    push!(output, parse_commit(branch, edge.node))
                end
            end
            @info "Saving commits for $branch"
            # execute(conn, "BEGIN;")
            load!(output,
                conn,
                string("INSERT INTO $schema.commit_codegov VALUES (",
                        join(("\$$i" for i in 1:size(output, 2)), ','),
                        ");"))
        end
        execute(conn, "COMMIT;")
        @info("$branch done at $(now())")
    catch err
        @error err
        execute(conn, "ROLLBACK;")
    end
    nothing
end


codegov_count = nrow(codegov_df)

codegov_df.branchid .= ""
codegov_df.status .= ""

print(codegov_count)

##### for codegov
## write the branch id back to the CSV so we can link it to final dataset
for i in 1:codegov_count
    slug = codegov_df[i, :][53]
    print(i)
    if i == 3500
        setup(pats = [GitHubPersonalAccessToken("bens", "INSERTPATHERE")])
        (;conn, schema, pat) = GHOST.PARALLELENABLER
    end
    try
        codegov_df[i, :][54] = query_repos_by_name(slug)
    catch
        @info "uh oh $slug"
    end
end

CSV.write("codegov_github_slugs_output.csv", codegov_df)

## POST branch id and GET the commit data
for i in 1:codegov_count
    slug = codegov_df[i, :][53]
    print(i)
    if i == 3500
        setup(pats = [GitHubPersonalAccessToken("jeremycorry", "INSERTPATHERE")])
        (;conn, schema, pat) = GHOST.PARALLELENABLER
    end
    try
        query_repos_by_name_test(slug)
    catch
        @info "uh oh"
    end
end



execute(conn, "UPDATE ghost.commit_codegov SET data_source = 'codegov'  WHERE data_source IS NULL;")
execute(conn, "COMMIT;")

## for sandia
sandia_df[!, "slug"] = string.(sandia_df[!, "owner"], "/", sandia_df[!, "repo_name"])

sandia_count = nrow(sandia_df)

sandia_df.branchid .= ""
sandia_df.status .= ""

print(sandia_count)

## for sandia
for i in 1:sandia_count
    slug = sandia_df[i, :][6]
    print(i)
    try
        sandia_df[i, :][7] = query_repos_by_name(slug)
    catch
        @info "uh oh $slug"
    end
end

CSV.write("codegove_github_slugs_output.csv", sandia_df)

for i in 1:repo_count
    slug = repo_df[i, :][6]
    try
        repo_df[i, :][7] = query_repos_by_name(slug)
        repo_df[i, :][8] = "Success"
    catch
        @info "uh oh"
        repo_df[i, :][8] = "Error"
        continue
    end
end


execute(conn, "UPDATE ghost.commit_codegov SET data_source = 'sandia' WHERE data_source IS NULL;")
execute(conn, "COMMIT;")



