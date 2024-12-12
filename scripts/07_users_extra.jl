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
import Base: show, summary, isless

setup(pats = [GitHubPersonalAccessToken("msimas@gmail.com", "xxx")])
(;conn, schema, pat) = GHOST.PARALLELENABLER

# need to add a column to this call it extra_done which will only query real users and get their extra data (that way we dont waste time on bots/organizations and such)
function query_users(users::Vector{<:String})
    nodes = [ users[i:min(i, lastindex(users))] for i in 1:1:length(users) ]
    vars = Dict(zip(string.("login", eachindex(nodes)), users))

    query = string(String(read(joinpath(pkgdir(GHOST), "src", "assets", "graphql", "06_users_extra.graphql"))),
                    "query A(",
                    join(("\$login$i: String!" for i in eachindex(nodes)), ','),
                    "){",
                    join(("_$i:user(login:\$login$i) {...a}" for i in eachindex(nodes)), ' '),
                    "}")

    result = graphql(query, vars = vars, max_retries = 0)

    # needs to be global so the eval(Meta.parse(string. 's can see this variable
    global user_json = JSON3.read(result.Data)

    if (haskey(user_json, "errors"))
        println("Errors found....")
        println(length(user_json.errors))

        bad_logins = String[]
        bad_logins_df = DataFrame([[],[],[],[],[],[],[],[],[],[],[],[],[]], 
                                ["id",
                                "bio",
                                "company",
                                "pronouns",
                                "isDeveloperProgramMember",
                                "isEmployee",
                                "updatedAt",
                                "twitterUsername",
                                "websiteUrl",
                                "socialAccounts",
                                "organization_ids",
                                "organization_logins",
                                "user_email"])

        for n in [1:1:length(user_json.errors);]
            push!(bad_logins, split(user_json.errors[n].message, "'")[2])    
            push!(bad_logins_df, ["None","None","None","None","false","false","2000-01-01T01:01:01Z","None","None",["None"],["None"],["None"],"None"])
        end

        all_logins = unique(values(vars))
        good_logins = filter!(e->e ∉ bad_logins, all_logins)
        nodes = [ good_logins[i:min(i, lastindex(good_logins))] for i in 1:1:length(good_logins) ]
        vars = Dict(zip(string.("login", eachindex(nodes)), good_logins))

        query = string(String(read(joinpath(pkgdir(GHOST), "src", "assets", "graphql", "06_users_extra.graphql"))),
                        "query A(",
                        join(("\$login$i: String!" for i in eachindex(nodes)), ','),
                        "){",
                        join(("_$i:user(login:\$login$i) {...a}" for i in eachindex(nodes)), ' '),
                        "}")

        result = graphql(query, vars = vars, max_retries = 0)

        # needs to be global so the eval(Meta.parse(string. 's can see this variable
        global user_json = JSON3.read(result.Data)

        # Check if json.data._1.socialAccounts.totalCount is = 0, if not make for loop to iterated over edges totalCount times and do the same for organizations
        output = DataFrame()
        for n in [1:1:length(user_json.data);]
            println(n)
            soc_a = String[]
            if (eval(Meta.parse(string.("user_json.data._", n, ".socialAccounts.totalCount"))) > 0)
                for i in [1:1:eval(Meta.parse(string.("user_json.data._", n, ".socialAccounts.totalCount")));]
                    println(i)
                    push!( soc_a,  eval(Meta.parse(string.("user_json.data._", n, ".socialAccounts.edges[", i, "].node.url"))))
                end
            end

            org_a = String[]
            org_b = String[]
            if (eval(Meta.parse(string.("user_json.data._", n, ".organizations.totalCount"))) > 0)
                for i in [1:1:eval(Meta.parse(string.("user_json.data._", n, ".organizations.totalCount")));]
                    println(i)
                    push!( org_a, eval(Meta.parse(string.("user_json.data._", n, ".organizations.edges[", i, "].node.id"))) )
                    push!( org_b, eval(Meta.parse(string.("user_json.data._", n, ".organizations.edges[", i, "].node.login"))))
                end
            end

            new_output = DataFrame(id = eval(Meta.parse(string.("user_json.data._", n, ".id"))),
                                bio = eval(Meta.parse(string.("user_json.data._", n, ".bio"))),
                                company = eval(Meta.parse(string.("user_json.data._", n, ".company"))),
                                pronouns = eval(Meta.parse(string.("user_json.data._", n, ".pronouns"))),
                                isDeveloperProgramMember = eval(Meta.parse(string.("user_json.data._", n, ".isDeveloperProgramMember"))),
                                isEmployee = eval(Meta.parse(string.("user_json.data._", n, ".isEmployee"))),
                                updatedAt = eval(Meta.parse(string.("user_json.data._", n, ".updatedAt"))),
                                twitterUsername = eval(Meta.parse(string.("user_json.data._", n, ".twitterUsername"))),
                                websiteUrl = eval(Meta.parse(string.("user_json.data._", n, ".websiteUrl"))),
                                socialAccounts = [soc_a],
                                organization_ids = [org_a],
                                organization_logins = [org_b],
                                user_email = eval(Meta.parse(string.("user_json.data._", n, ".email"))))

            output = append!(output, new_output, promote = true)
        end

        output = vcat(output, bad_logins_df)

        @info "Creating data frame and saving to db."

        execute(conn, "BEGIN;")
        GHOST.load!(output, conn, "UPDATE $schema.test_usr SET bio =\$2, company=\$3, pronouns=\$4, isDeveloperProgrammember=\$5, isEmployee=\$6, updatedAt=\$7, twitterUsername=\$8, websiteUrl=\$9, socialAccounts=\$10, organization_ids=\$11, organization_logins=\$12, user_email=\$13 WHERE id = \$1;")
        execute(conn, "COMMIT;")
        @info "Done with user group."
        sleep(.025)
    else
        # Check if json.data._1.socialAccounts.totalCount is = 0, if not make for loop to iterated over edges totalCount times and do the same for organizations
        output = DataFrame()
        for n in [1:1:length(user_json.data);]
            println(n)
            soc_a = String[]
            if (eval(Meta.parse(string.("user_json.data._", n, ".socialAccounts.totalCount"))) > 0)
                for i in [1:1:eval(Meta.parse(string.("user_json.data._", n, ".socialAccounts.totalCount")));]
                    println(i)
                    push!( soc_a,  eval(Meta.parse(string.("user_json.data._", n, ".socialAccounts.edges[", i, "].node.url"))))
                end
            end

            org_a = String[]
            org_b = String[]
            if (eval(Meta.parse(string.("user_json.data._", n, ".organizations.totalCount"))) > 0)
                for i in [1:1:eval(Meta.parse(string.("user_json.data._", n, ".organizations.totalCount")));]
                    println(i)
                    push!( org_a, eval(Meta.parse(string.("user_json.data._", n, ".organizations.edges[", i, "].node.id"))) )
                    push!( org_b, eval(Meta.parse(string.("user_json.data._", n, ".organizations.edges[", i, "].node.login"))))
                end
            end

            new_output = DataFrame(id = eval(Meta.parse(string.("user_json.data._", n, ".id"))),
                                bio = eval(Meta.parse(string.("user_json.data._", n, ".bio"))),
                                company = eval(Meta.parse(string.("user_json.data._", n, ".company"))),
                                pronouns = eval(Meta.parse(string.("user_json.data._", n, ".pronouns"))),
                                isDeveloperProgramMember = eval(Meta.parse(string.("user_json.data._", n, ".isDeveloperProgramMember"))),
                                isEmployee = eval(Meta.parse(string.("user_json.data._", n, ".isEmployee"))),
                                updatedAt = eval(Meta.parse(string.("user_json.data._", n, ".updatedAt"))),
                                twitterUsername = eval(Meta.parse(string.("user_json.data._", n, ".twitterUsername"))),
                                websiteUrl = eval(Meta.parse(string.("user_json.data._", n, ".websiteUrl"))),
                                socialAccounts = [soc_a],
                                organization_ids = [org_a],
                                organization_logins = [org_b],
                                user_email = eval(Meta.parse(string.("user_json.data._", n, ".email"))))

            output = append!(output, new_output, promote = true)
        end

        @info "Creating data frame and saving to db."

        execute(conn, "BEGIN;")
        GHOST.load!(output, conn, "UPDATE $schema.test_usr SET bio =\$2, company=\$3, pronouns=\$4, isDeveloperProgrammember=\$5, isEmployee=\$6, updatedAt=\$7, twitterUsername=\$8, websiteUrl=\$9, socialAccounts=\$10, organization_ids=\$11, organization_logins=\$12, user_email=\$13 WHERE id = \$1;")
        execute(conn, "COMMIT;")
        @info "Done with user group."
        sleep(.025)
    end
    nothing
end



# while not done, set done = true when no groups left
done = false
while !done
    base_users = execute(conn,"""
                SELECT login
                FROM $schema.users A
                LEFT JOIN $schema.test_usr B
                ON A.author_id = B.id
                WHERE NOT B.id is null 
                AND acctype = 'User'
                AND updatedat IS NULL
                """) |>
    (obj -> getproperty.(obj, :login))
    group_size = 250

    # Creates a vector of user id vectors, where the inner vector is at most group_size elements in size.
    grouped_users = [base_users[i:min(i + (group_size - 1), lastindex(base_users))] for i in 1:group_size:length(base_users) ]

    grouped_users_count = lastindex(grouped_users)
    for i in 1:grouped_users_count
        @info "Querying user group $i of $grouped_users_count)..."
        try
            query_users(grouped_users[i])
        catch
            continue
        end
    end
    if length(base_users) == 0
        done = true
    end
end