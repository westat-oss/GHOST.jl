WITH A AS (
    SELECT spdx,
        created,
        CEIL(count::real / 2) queries
    FROM ghost.queries
    WHERE NOT done
    ORDER BY queries DESC,
        spdx
),
B AS (
    SELECT spdx,
        created,
        queries::smallint,
        CEIL(
            ROW_NUMBER() OVER (
                PARTITION BY queries
                ORDER BY queries DESC,
                    spdx,
                    created
            )::real / 2
        )::smallint AS query_group
    FROM A
)
SELECT *
FROM B
ORDER BY queries DESC,
    query_group;
