using GHOST
setup()
setup_parallel()

function get_branches(conn, schema, min_lim, max_lim)
    branches = execute(conn,
        String(read(joinpath(pkgdir(GHOST), "src", "assets", "sql", "branches_min_max.sql"))) |>
        (obj -> replace(obj, "schema" => schema)) |>
        (obj -> replace(obj, "min_lim" => min_lim)) |>
        (obj -> replace(obj, "max_lim" => max_lim)),
        not_null = true) |>
        (obj -> getproperty.(obj, :branch))
    branches
end

function collect_commits(min_lim, max_lim)
    time_start = now()
    @info "Started collecting commits for repos with more than $min_lim and up to $max_lim commits @ $time_start."
    (;conn, schema) = GHOST.PARALLELENABLER
    branches = get_branches(conn, schema, min_lim, max_lim)
    mini_batch_size = 8
    while length(branches) > 0
        @info "Getting commits for $(length(branches)) repo branches."
        @sync @distributed for idx in 1:mini_batch_size:length(branches)
            query_commits(view(branches, idx:min(idx + (mini_batch_size - 1), lastindex(branches))), 100)
            GC.gc();GC.gc();GC.gc();
            sleep(0.25)
        end
        GC.gc();GC.gc();GC.gc();
        branches = get_branches(conn, schema, min_lim, max_lim)
    end
    time_end = now()
    @info canonicalize(CompoundPeriod(time_end - time_start))
end

collect_commits(0, 100)
