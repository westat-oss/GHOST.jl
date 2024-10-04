using GHOST
using GHOST: @everywhere, READY, remotecall
setup()
time_start = now()
@info time_start
setup_parallel()

(;conn, schema, pat) = GHOST.PARALLELENABLER
data = execute(conn,
               "SELECT branch FROM $(schema).repos WHERE status = 'Init' ORDER BY commits;",
               not_null = true) |>
    (obj -> getproperty.(obj, :branch))

@everywhere function magic(branch)
    query_commits(branch)
end

for w in eachindex(READY.x)
    branch = popfirst!(data)
    @info "Sending branch $branch to run in worker $w."
    READY.x[w] = remotecall(magic, w + 1, branch)
end

while !isempty(data)
    w = findfirst(isready, READY.x)
    if isnothing(w)
        sleep(30)
    else
        branch = popfirst!(data)
        @info "Sending branch $branch to run in worker $w."
        READY.x[w] = remotecall(magic, w + 1, branch)
    end
end

while any(!isready, READY.x)
    sleep(60)
end
time_end = now()
canonicalize(CompoundPeriod(time_end - time_start))
