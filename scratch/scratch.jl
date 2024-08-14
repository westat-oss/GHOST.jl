using Revise, GHOST
pats = [ GitHubPersonalAccessToken(split(pat, ':')...) for pat in filter!(!isempty, split(ENV["GH_PAT"], '\n')) ]
setup(pats = pats)
licenses()
setup_parallel(2)
spdxs = execute(GHOST.PARALLELENABLER.conn,
                "SELECT spdx FROM $(GHOST.PARALLELENABLER.schema).licenses where spdx = ANY('{EUPL-1.2,UPL-1.0}'::text[]) ORDER BY spdx;",
                not_null = true) |>
    (obj -> getproperty.(obj, :spdx))
for spdx in spdxs
    queries(spdx)
end
data = execute(GHOST.PARALLELENABLER.conn,
                replace(
                    String(read(joinpath(pkgdir(GHOST), "src",  "assets", "sql", "queries_batches.sql"))),
                    "schema" => GHOST.PARALLELENABLER.schema
                ),
                not_null = true) |>
    DataFrame |>
    (df -> groupby(df, [:queries, :query_group]));

find_repos(data)
sql = String(read(joinpath(pkgdir(GHOST), "src", "assets", "sql", "branches_min_max.sql"))) |>
    (obj -> replace(obj, "schema" => GHOST.PARALLELENABLER.schema)) |>
    (obj -> replace(obj, "min_lim" => 1)) |>
    (obj -> replace(obj, "max_lim" => 2))
data = execute(GHOST.PARALLELENABLER.conn,
                sql,
                not_null = true) |>
    (obj -> getproperty.(obj, :branch))
query_commits(data, 3)