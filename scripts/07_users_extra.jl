using GHOST
setup()
(;conn, schema, pat) = GHOST.PARALLELENABLER

users = execute(conn,
                """
                SELECT author_id
                FROM $schema.tst_users 
                WHERE acctype = 'User' AND updatedat IS NULL;
                """) |>
    (obj -> getproperty.(obj, :author_id))


group_size = 5_000
# Creates a vector of user id vectors, where the inner vector is at most group_size elements in size.
grouped_users = [users[i:min(i + (group_size - 1), lastindex(users))] for i in 1:group_size:length(users) ]

function query_users(users::Vector{<:String})
    nodes = [ users[i:min(i + 99, lastindex(users))] for i in 1:100:length(users) ]
    vars = Dict(zip(string.("x", eachindex(nodes)), nodes))
    query = string("fragment a on Node {id ",
                   "...on User {bio, company, pronouns, updatedAt } ",
                   "query A(",
                   join(("\$x$i:[ID!]!" for i in eachindex(nodes)), ','),
                   "){",
                   join(("_$i:nodes(ids:\$x$i){...a}" for i in eachindex(nodes)), ' '),
                   "}")
    result = graphql(query, vars = vars, max_retries = 2)
    @info "Received results for user group."
    json = JSON3.read(result.Data)
    @info "Creating data frame and saving to db."
    output = reduce(vcat, DataFrame(r for r in values(elem) if ~isnothing(r)) for elem in values(json.data))
    execute(conn, "BEGIN;")
    GHOST.load!(output, conn, "UPDATE schema.test_usr SET bio =\$2, company=\$3, pronouns=\$4, updatedat=\$5) WHERE id = \$1;")
    execute(conn, "COMMIT;")
    @info "Done with user group."
end

grouped_users_count = lastindex(grouped_users)
for i in 1:grouped_users_count
    @info "Querying user group $i of $grouped_users_count)..."
    query_users(grouped_users[i])
end
