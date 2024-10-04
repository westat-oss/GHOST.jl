SELECT branch
FROM ghost.repos
WHERE (status = 'Init' OR status = 'In progress') AND (commits > min_lim) AND (commits <= max_lim)
ORDER BY commits LIMIT 10000;
