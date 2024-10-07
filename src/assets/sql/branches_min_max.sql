SELECT branch FROM (
    SELECT branch
    FROM ghost.repos
    WHERE (status = 'Init' OR status = 'In progress') AND (commits > min_lim) AND (commits <= max_lim)
    GROUP BY branch, commits
    ORDER BY commits LIMIT 1_000_000
) AS unique_branches GROUP BY branch;
