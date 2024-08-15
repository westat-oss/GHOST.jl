CREATE TABLE IF NOT EXISTS ghost.repos (
    id text,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp NOT NULL DEFAULT date_trunc('second', current_timestamp AT TIME ZONE 'UTC')::timestamp,
    status text NOT NULL DEFAULT 'Init',
    CONSTRAINT repos_branch UNIQUE (branch, createdat),
    PRIMARY KEY (id, createdat)
) PARTITION BY RANGE (createdat);


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


CREATE TABLE ghost_partitions.repos_2007 PARTITION OF ghost.repos FOR VALUES FROM ('2007-01-01') TO ('2008-01-01');
CREATE TABLE ghost_partitions.repos_2008 PARTITION OF ghost.repos FOR VALUES FROM ('2008-01-01') TO ('2009-01-01');
CREATE TABLE ghost_partitions.repos_2009 PARTITION OF ghost.repos FOR VALUES FROM ('2009-01-01') TO ('2010-01-01');
CREATE TABLE ghost_partitions.repos_2010 PARTITION OF ghost.repos FOR VALUES FROM ('2010-01-01') TO ('2011-01-01');
CREATE TABLE ghost_partitions.repos_2011 PARTITION OF ghost.repos FOR VALUES FROM ('2011-01-01') TO ('2012-01-01');
CREATE TABLE ghost_partitions.repos_2012 PARTITION OF ghost.repos FOR VALUES FROM ('2012-01-01') TO ('2013-01-01');
CREATE TABLE ghost_partitions.repos_2013 PARTITION OF ghost.repos FOR VALUES FROM ('2013-01-01') TO ('2014-01-01');
CREATE TABLE ghost_partitions.repos_2014 PARTITION OF ghost.repos FOR VALUES FROM ('2014-01-01') TO ('2015-01-01');
CREATE TABLE ghost_partitions.repos_2015 PARTITION OF ghost.repos FOR VALUES FROM ('2015-01-01') TO ('2016-01-01');
CREATE TABLE ghost_partitions.repos_2016 PARTITION OF ghost.repos FOR VALUES FROM ('2016-01-01') TO ('2017-01-01');
CREATE TABLE ghost_partitions.repos_2017 PARTITION OF ghost.repos FOR VALUES FROM ('2017-01-01') TO ('2018-01-01');
CREATE TABLE ghost_partitions.repos_2018 PARTITION OF ghost.repos FOR VALUES FROM ('2018-01-01') TO ('2019-01-01');
CREATE TABLE ghost_partitions.repos_2019 PARTITION OF ghost.repos FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');
CREATE TABLE ghost_partitions.repos_2020 PARTITION OF ghost.repos FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');
CREATE TABLE ghost_partitions.repos_2021 PARTITION OF ghost.repos FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');
CREATE TABLE ghost_partitions.repos_2022 PARTITION OF ghost.repos FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE ghost_partitions.repos_2023 PARTITION OF ghost.repos FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE ghost_partitions.repos_2024 PARTITION OF ghost.repos FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');