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
using CSV


setup(pats = [GitHubPersonalAccessToken("bens", "INSERTPATHERE")])
(;conn, schema, pat) = GHOST.PARALLELENABLER

base_users = CSV.read("user_data_sectors_2025_03_26_codegov_unique.csv", DataFrame; header = true)

## filter the users from rashis instructions here
dr = Date.(2013:2024)

# need to add a column to this call it extra_done which will only query real users and get their extra data (that way we dont waste time on bots/organizations and such)
function user_repos_dev(user::String31, since::String, until::String)

    sincedt = DateTime(since)
    untildt = DateTime(until)
    
    query = String(read(joinpath(pkgdir(GHOST), "src", "assets", "graphql", "08_user_to_repo.graphql"))) |>
            (obj -> replace(obj, r"\s+" => " ")) |>
            (obj -> replace(obj, r"\s+(\{|\}|\:)\s*" => s"\1")) |>
            (obj -> replace(obj, r"(:|,|\.{3})\s*" => s"\1")) |>
            strip |>
            string

    vars = Dict("since" => string(sincedt, "Z"),
                "until" => string(untildt, "Z"),
                "username" => user)

    result = graphql(query, vars = vars, max_retries = 0)

    # needs to be global so the eval(Meta.parse(string. 's can see this variable
    user_repos = JSON3.read(result.Data)
    output = DataFrame()

    ## columns: userid, login, repoid, slug, commit_year
    if (length(user_repos.data.user.contributionsCollection.commitContributionsByRepository) > 0)
        for i in [1:1:length(user_repos.data.user.contributionsCollection.commitContributionsByRepository);]
            user_repos.data.user.contributionsCollection.commitContributionsByRepository[i].repository

            tiny_repo = user_repos.data.user.contributionsCollection.commitContributionsByRepository[i].repository

            new_output = DataFrame(userid = user_repos.data.user.id,
                                login = user,
                                repoid = tiny_repo.id,
                                owner = user_repos.data.user.contributionsCollection.commitContributionsByRepository[i].repository.owner.login,
                                name = tiny_repo.name,
                                commit_year = sincedt)

            output = append!(output, new_output, promote = true)
        end
    else
        println("No data for user login: ")
        println(user)
        println("for the year: ")
        println(sincedt)
    end
    @info "Creating data frame and saving to db."

    execute(conn, "BEGIN;")
    GHOST.load!(output, conn, "INSERT INTO $schema.tst_repo_users VALUES(\$1,\$2,\$3,\$4,\$5,\$6) ON CONFLICT DO NOTHING;")
    execute(conn, "COMMIT;")
    @info "Done with user group."

    print(output)
end

base_users_count = size(base_users, 1)

for j in 1:length(dr)-1
    for i in 1:base_users_count
        @info "Querying user group $i of $base_users_count)..."
        user = base_users[i, "login"]
        print(user)
        try
            user_repos_dev(string(user), string(dr[j]), string(dr[j+1]))
        catch
            continue
        end
    end
end

## save to csv and upload to AWS S3

for j in 1:length(dr)-1
    current_date = dr[j]
    @info "Querying user group $j)...$current_date"
    user_repos_dev("alchemistmatt", string(dr[j]), string(dr[j+1]))
end
