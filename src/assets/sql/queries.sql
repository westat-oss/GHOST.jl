CREATE TABLE IF NOT EXISTS ghost.queries (
    spdx text NOT NULL,
    created tsrange NOT NULL,
    count smallint NOT NULL,
    asof timestamp NOT NULL DEFAULT date_trunc('second', current_timestamp AT TIME ZONE 'UTC')::timestamp,
    done bool NOT NULL DEFAULT false,
    CONSTRAINT nonoverlappingqueries EXCLUDE USING gist (created WITH &&, spdx WITH =)
);
ALTER TABLE ghost.queries OWNER TO postgres;
COMMENT ON TABLE ghost.queries IS 'This table is a tracker for queries';
COMMENT ON COLUMN ghost.queries.spdx IS 'The SPDX license ID';
COMMENT ON COLUMN ghost.queries.created IS 'The time interval for the query';
COMMENT ON COLUMN ghost.queries.count IS 'How many results for the query';
COMMENT ON COLUMN ghost.queries.asof IS 'When was GitHub queried about the information.';
COMMENT ON COLUMN ghost.queries.done IS 'Has the repositories been collected?';
COMMENT ON CONSTRAINT nonoverlappingqueries ON ghost.queries IS 'No duplicate for queries';
