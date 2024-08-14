CREATE TABLE IF NOT EXISTS ghost.repos (
    id text PRIMARY KEY,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp NOT NULL DEFAULT date_trunc('second', current_timestamp AT TIME ZONE 'UTC')::timestamp,
    status text NOT NULL DEFAULT 'Init',
    CONSTRAINT repos_branch UNIQUE (branch)
);
ALTER TABLE ghost.repos OWNER TO postgres;
COMMENT ON TABLE ghost.repos IS 'Repository ID and base branch ID';
COMMENT ON COLUMN ghost.repos.id IS 'Repository ID';
COMMENT ON COLUMN ghost.repos.spdx IS 'SPDX license ID';
COMMENT ON COLUMN ghost.repos.slug IS 'Location of the respository';
COMMENT ON COLUMN ghost.repos.createdat IS 'When was the repository created on GitHub?';
COMMENT ON COLUMN ghost.repos.description IS 'Description of the respository';
COMMENT ON COLUMN ghost.repos.primarylanguage IS 'Primary language of the respository';
COMMENT ON COLUMN ghost.repos.branch IS 'Base branch ID';
COMMENT ON COLUMN ghost.repos.commits IS 'Number of commits in the branch until the end of the observation period';
COMMENT ON COLUMN ghost.repos.asof IS 'When was GitHub queried?';
COMMENT ON COLUMN ghost.repos.status IS 'Status of collection effort';
