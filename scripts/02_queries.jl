using GHOST
time_start = now()
setup()
setup_parallel(5)
spdxs = execute(GHOST.PARALLELENABLER.conn,
                "SELECT spdx FROM $(GHOST.PARALLELENABLER.schema).licenses ORDER BY spdx;",
                not_null = true) |>
    (obj -> getproperty.(obj, :spdx))
for spdx in spdxs
    queries(spdx)
end
time_end = now()
canonicalize(CompoundPeriod(time_end - time_start))
