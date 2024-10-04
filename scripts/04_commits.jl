using GHOST
setup()
setup_parallel()

function get_branches(conn, schema)
    branches = execute(conn,
        String(read(joinpath(pkgdir(GHOST), "src", "assets", "sql", "branches_min_max.sql"))) |>
        (obj -> replace(obj, "schema" => schema)) |>
        (obj -> replace(obj, "min_lim" => 0)) |>
        (obj -> replace(obj, "max_lim" => 100)),
        not_null = true) |>
        (obj -> getproperty.(obj, :branch))
    branches
end

function collect_commits()
    time_start = now()
    @info time_start
    (;conn, schema) = GHOST.PARALLELENABLER
    branches = get_branches(conn, schema)
    while length(branches) > 0
        @info "Getting commits for $(length(branches)) repo branches."
        @sync @distributed for idx in 1:2:length(branches)
            query_commits(view(branches, idx:min(idx + 7, lastindex(branches))), 25)
            GC.gc();GC.gc();GC.gc();
            sleep(0.25)
        end
        GC.gc();GC.gc();GC.gc();
        branches = get_branches(conn, schema)
    end
    time_end = now()
    canonicalize(CompoundPeriod(time_end - time_start))
end

collect_commits()
