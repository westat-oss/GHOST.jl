using GHOST
setup()
(;conn, schema, pat) = GHOST.PARALLELENABLER

users = execute(conn,
                """
                SELECT author_id
                FROM $schema.users A
                LEFT JOIN $schema.test_usr B
                ON A.author_id = B.id
                WHERE B.id is null
                ;
                """) |>
    (obj -> getproperty.(obj, :author_id))

# Creates a vector of user id vectors, where the inner vector is at most 5_000 elements in size.
grouped_users = [users[i:min(i + 4_999, lastindex(users))] for i in 1:5_000:length(users) ]

function query_users(users::Vector{<:String})
    nodes = [ users[i:min(i + 99, lastindex(users))] for i in 1:100:length(users) ]
    vars = Dict(zip(string.("x", eachindex(nodes)), nodes))
    query = string("fragment a on Node {id __typename",
                   "...on User {login, createdAt, location} ",
                   "...on Organization {login, createdAt, location} ",
                   "...on Bot {login, createdAt, resourcePath}}",
                   "query A(",
                   join(("\$x$i:[ID!]!" for i in eachindex(nodes)), ','),
                   "){",
                   join(("_$i:nodes(ids:\$x$i){...a}" for i in eachindex(nodes)), ' '),
                   "}")
    @info "Sending query for user group."
    result = graphql(query, vars = vars, max_retries = 2)
    @info "Received results for user group."
    json = JSON3.read(result.Data)
    @info "Creating data frame and saving to db."
    output = reduce(vcat, DataFrame(r for r in values(elem) if ~isnothing(r)) for elem in values(json.data))
    execute(conn, "BEGIN;")
    GHOST.load!(output, conn, "INSERT INTO $schema.test_usr VALUES(\$1,\$2,\$3,\$4) ON CONFLICT DO NOTHING;")
    execute(conn, "COMMIT;")
    @info "Done with user group."
    nothing
end

grouped_users_count = lastindex(grouped_users)
for i in 1:grouped_users_count
    @info "Querying user group $i of $grouped_users_count)..."
    query_users(grouped_users[i])
end
