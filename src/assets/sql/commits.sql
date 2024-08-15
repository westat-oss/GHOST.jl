CREATE TABLE IF NOT EXISTS ghost.commits (
    branch text NOT NULL,
    id text NOT NULL,
    oid text NOT NULL,
    committedat timestamp NOT NULL,
    authors_email text [] NOT NULL,
    authors_name text [] NOT NULL,
    authors_id text [],
    additions bigint,
    deletions bigint,
    asof timestamp without time zone NOT NULL DEFAULT date_trunc(
        'second'::text,
        timezone('UTC'::text, CURRENT_TIMESTAMP)
    ),
    CONSTRAINT commits_pkey PRIMARY KEY (id, committedat) --,
    -- Partitioning the data makes this FK impossible 
    --CONSTRAINT branch FOREIGN KEY (branch, committedat) REFERENCES ghost.repos (branch, createdat)
) PARTITION BY RANGE (committedat);

ALTER TABLE ghost.commits OWNER TO postgres;
COMMENT ON TABLE ghost.commits IS 'Commits Information';
COMMENT ON COLUMN ghost.commits.branch IS 'Base Branch ID (foreign key)';
COMMENT ON COLUMN ghost.commits.id IS 'Commit ID';
COMMENT ON COLUMN ghost.commits.oid IS 'Git Object ID (SHA1)';
COMMENT ON COLUMN ghost.commits.committedat IS 'When was it committed?';
COMMENT ON COLUMN ghost.commits.authors_email IS 'The email in the Git commit.';
COMMENT ON COLUMN ghost.commits.authors_name IS 'The name in the Git commit.';
COMMENT ON COLUMN ghost.commits.authors_id IS 'GitHub Author';
COMMENT ON COLUMN ghost.commits.additions IS 'The number of additions in this commit.';
COMMENT ON COLUMN ghost.commits.deletions IS 'The number of deletions in this commit.';
COMMENT ON COLUMN ghost.commits.asof IS 'When was GitHub queried.';

CREATE TABLE ghost_partitions.commits_2009 PARTITION OF ghost.commits FOR VALUES FROM ('2000-01-01') TO ('2010-01-01');
CREATE TABLE ghost_partitions.commits_2010 PARTITION OF ghost.commits FOR VALUES FROM ('2010-01-01') TO ('2011-01-01');
CREATE TABLE ghost_partitions.commits_2011 PARTITION OF ghost.commits FOR VALUES FROM ('2011-01-01') TO ('2012-01-01');
CREATE TABLE ghost_partitions.commits_2012 PARTITION OF ghost.commits FOR VALUES FROM ('2012-01-01') TO ('2013-01-01');
CREATE TABLE ghost_partitions.commits_2013_01 PARTITION OF ghost.commits FOR VALUES FROM ('2013-01-01') TO ('2013-02-01');
CREATE TABLE ghost_partitions.commits_2013_02 PARTITION OF ghost.commits FOR VALUES FROM ('2013-02-01') TO ('2013-03-01');
CREATE TABLE ghost_partitions.commits_2013_03 PARTITION OF ghost.commits FOR VALUES FROM ('2013-03-01') TO ('2013-04-01');
CREATE TABLE ghost_partitions.commits_2013_04 PARTITION OF ghost.commits FOR VALUES FROM ('2013-04-01') TO ('2013-05-01');
CREATE TABLE ghost_partitions.commits_2013_05 PARTITION OF ghost.commits FOR VALUES FROM ('2013-05-01') TO ('2013-06-01');
CREATE TABLE ghost_partitions.commits_2013_06 PARTITION OF ghost.commits FOR VALUES FROM ('2013-06-01') TO ('2013-07-01');
CREATE TABLE ghost_partitions.commits_2013_07 PARTITION OF ghost.commits FOR VALUES FROM ('2013-07-01') TO ('2013-08-01');
CREATE TABLE ghost_partitions.commits_2013_08 PARTITION OF ghost.commits FOR VALUES FROM ('2013-08-01') TO ('2013-09-01');
CREATE TABLE ghost_partitions.commits_2013_09 PARTITION OF ghost.commits FOR VALUES FROM ('2013-09-01') TO ('2013-10-01');
CREATE TABLE ghost_partitions.commits_2013_10 PARTITION OF ghost.commits FOR VALUES FROM ('2013-10-01') TO ('2013-11-01');
CREATE TABLE ghost_partitions.commits_2013_11 PARTITION OF ghost.commits FOR VALUES FROM ('2013-11-01') TO ('2013-12-01');
CREATE TABLE ghost_partitions.commits_2013_12 PARTITION OF ghost.commits FOR VALUES FROM ('2013-12-01') TO ('2014-01-01');
CREATE TABLE ghost_partitions.commits_2014_01 PARTITION OF ghost.commits FOR VALUES FROM ('2014-01-01') TO ('2014-02-01');
CREATE TABLE ghost_partitions.commits_2014_02 PARTITION OF ghost.commits FOR VALUES FROM ('2014-02-01') TO ('2014-03-01');
CREATE TABLE ghost_partitions.commits_2014_03 PARTITION OF ghost.commits FOR VALUES FROM ('2014-03-01') TO ('2014-04-01');
CREATE TABLE ghost_partitions.commits_2014_04 PARTITION OF ghost.commits FOR VALUES FROM ('2014-04-01') TO ('2014-05-01');
CREATE TABLE ghost_partitions.commits_2014_05 PARTITION OF ghost.commits FOR VALUES FROM ('2014-05-01') TO ('2014-06-01');
CREATE TABLE ghost_partitions.commits_2014_06 PARTITION OF ghost.commits FOR VALUES FROM ('2014-06-01') TO ('2014-07-01');
CREATE TABLE ghost_partitions.commits_2014_07 PARTITION OF ghost.commits FOR VALUES FROM ('2014-07-01') TO ('2014-08-01');
CREATE TABLE ghost_partitions.commits_2014_08 PARTITION OF ghost.commits FOR VALUES FROM ('2014-08-01') TO ('2014-09-01');
CREATE TABLE ghost_partitions.commits_2014_09 PARTITION OF ghost.commits FOR VALUES FROM ('2014-09-01') TO ('2014-10-01');
CREATE TABLE ghost_partitions.commits_2014_10 PARTITION OF ghost.commits FOR VALUES FROM ('2014-10-01') TO ('2014-11-01');
CREATE TABLE ghost_partitions.commits_2014_11 PARTITION OF ghost.commits FOR VALUES FROM ('2014-11-01') TO ('2014-12-01');
CREATE TABLE ghost_partitions.commits_2014_12 PARTITION OF ghost.commits FOR VALUES FROM ('2014-12-01') TO ('2015-01-01');
CREATE TABLE ghost_partitions.commits_2015_01 PARTITION OF ghost.commits FOR VALUES FROM ('2015-01-01') TO ('2015-02-01');
CREATE TABLE ghost_partitions.commits_2015_02 PARTITION OF ghost.commits FOR VALUES FROM ('2015-02-01') TO ('2015-03-01');
CREATE TABLE ghost_partitions.commits_2015_03 PARTITION OF ghost.commits FOR VALUES FROM ('2015-03-01') TO ('2015-04-01');
CREATE TABLE ghost_partitions.commits_2015_04 PARTITION OF ghost.commits FOR VALUES FROM ('2015-04-01') TO ('2015-05-01');
CREATE TABLE ghost_partitions.commits_2015_05 PARTITION OF ghost.commits FOR VALUES FROM ('2015-05-01') TO ('2015-06-01');
CREATE TABLE ghost_partitions.commits_2015_06 PARTITION OF ghost.commits FOR VALUES FROM ('2015-06-01') TO ('2015-07-01');
CREATE TABLE ghost_partitions.commits_2015_07 PARTITION OF ghost.commits FOR VALUES FROM ('2015-07-01') TO ('2015-08-01');
CREATE TABLE ghost_partitions.commits_2015_08 PARTITION OF ghost.commits FOR VALUES FROM ('2015-08-01') TO ('2015-09-01');
CREATE TABLE ghost_partitions.commits_2015_09 PARTITION OF ghost.commits FOR VALUES FROM ('2015-09-01') TO ('2015-10-01');
CREATE TABLE ghost_partitions.commits_2015_10 PARTITION OF ghost.commits FOR VALUES FROM ('2015-10-01') TO ('2015-11-01');
CREATE TABLE ghost_partitions.commits_2015_11 PARTITION OF ghost.commits FOR VALUES FROM ('2015-11-01') TO ('2015-12-01');
CREATE TABLE ghost_partitions.commits_2015_12 PARTITION OF ghost.commits FOR VALUES FROM ('2015-12-01') TO ('2016-01-01');
CREATE TABLE ghost_partitions.commits_2016_01 PARTITION OF ghost.commits FOR VALUES FROM ('2016-01-01') TO ('2016-02-01');
CREATE TABLE ghost_partitions.commits_2016_02 PARTITION OF ghost.commits FOR VALUES FROM ('2016-02-01') TO ('2016-03-01');
CREATE TABLE ghost_partitions.commits_2016_03 PARTITION OF ghost.commits FOR VALUES FROM ('2016-03-01') TO ('2016-04-01');
CREATE TABLE ghost_partitions.commits_2016_04 PARTITION OF ghost.commits FOR VALUES FROM ('2016-04-01') TO ('2016-05-01');
CREATE TABLE ghost_partitions.commits_2016_05 PARTITION OF ghost.commits FOR VALUES FROM ('2016-05-01') TO ('2016-06-01');
CREATE TABLE ghost_partitions.commits_2016_06 PARTITION OF ghost.commits FOR VALUES FROM ('2016-06-01') TO ('2016-07-01');
CREATE TABLE ghost_partitions.commits_2016_07 PARTITION OF ghost.commits FOR VALUES FROM ('2016-07-01') TO ('2016-08-01');
CREATE TABLE ghost_partitions.commits_2016_08 PARTITION OF ghost.commits FOR VALUES FROM ('2016-08-01') TO ('2016-09-01');
CREATE TABLE ghost_partitions.commits_2016_09 PARTITION OF ghost.commits FOR VALUES FROM ('2016-09-01') TO ('2016-10-01');
CREATE TABLE ghost_partitions.commits_2016_10 PARTITION OF ghost.commits FOR VALUES FROM ('2016-10-01') TO ('2016-11-01');
CREATE TABLE ghost_partitions.commits_2016_11 PARTITION OF ghost.commits FOR VALUES FROM ('2016-11-01') TO ('2016-12-01');
CREATE TABLE ghost_partitions.commits_2016_12 PARTITION OF ghost.commits FOR VALUES FROM ('2016-12-01') TO ('2017-01-01');
CREATE TABLE ghost_partitions.commits_2017_01 PARTITION OF ghost.commits FOR VALUES FROM ('2017-01-01') TO ('2017-02-01');
CREATE TABLE ghost_partitions.commits_2017_02 PARTITION OF ghost.commits FOR VALUES FROM ('2017-02-01') TO ('2017-03-01');
CREATE TABLE ghost_partitions.commits_2017_03 PARTITION OF ghost.commits FOR VALUES FROM ('2017-03-01') TO ('2017-04-01');
CREATE TABLE ghost_partitions.commits_2017_04 PARTITION OF ghost.commits FOR VALUES FROM ('2017-04-01') TO ('2017-05-01');
CREATE TABLE ghost_partitions.commits_2017_05 PARTITION OF ghost.commits FOR VALUES FROM ('2017-05-01') TO ('2017-06-01');
CREATE TABLE ghost_partitions.commits_2017_06 PARTITION OF ghost.commits FOR VALUES FROM ('2017-06-01') TO ('2017-07-01');
CREATE TABLE ghost_partitions.commits_2017_07 PARTITION OF ghost.commits FOR VALUES FROM ('2017-07-01') TO ('2017-08-01');
CREATE TABLE ghost_partitions.commits_2017_08 PARTITION OF ghost.commits FOR VALUES FROM ('2017-08-01') TO ('2017-09-01');
CREATE TABLE ghost_partitions.commits_2017_09 PARTITION OF ghost.commits FOR VALUES FROM ('2017-09-01') TO ('2017-10-01');
CREATE TABLE ghost_partitions.commits_2017_10 PARTITION OF ghost.commits FOR VALUES FROM ('2017-10-01') TO ('2017-11-01');
CREATE TABLE ghost_partitions.commits_2017_11 PARTITION OF ghost.commits FOR VALUES FROM ('2017-11-01') TO ('2017-12-01');
CREATE TABLE ghost_partitions.commits_2017_12 PARTITION OF ghost.commits FOR VALUES FROM ('2017-12-01') TO ('2018-01-01');
CREATE TABLE ghost_partitions.commits_2018_01 PARTITION OF ghost.commits FOR VALUES FROM ('2018-01-01') TO ('2018-02-01');
CREATE TABLE ghost_partitions.commits_2018_02 PARTITION OF ghost.commits FOR VALUES FROM ('2018-02-01') TO ('2018-03-01');
CREATE TABLE ghost_partitions.commits_2018_03 PARTITION OF ghost.commits FOR VALUES FROM ('2018-03-01') TO ('2018-04-01');
CREATE TABLE ghost_partitions.commits_2018_04 PARTITION OF ghost.commits FOR VALUES FROM ('2018-04-01') TO ('2018-05-01');
CREATE TABLE ghost_partitions.commits_2018_05 PARTITION OF ghost.commits FOR VALUES FROM ('2018-05-01') TO ('2018-06-01');
CREATE TABLE ghost_partitions.commits_2018_06 PARTITION OF ghost.commits FOR VALUES FROM ('2018-06-01') TO ('2018-07-01');
CREATE TABLE ghost_partitions.commits_2018_07 PARTITION OF ghost.commits FOR VALUES FROM ('2018-07-01') TO ('2018-08-01');
CREATE TABLE ghost_partitions.commits_2018_08 PARTITION OF ghost.commits FOR VALUES FROM ('2018-08-01') TO ('2018-09-01');
CREATE TABLE ghost_partitions.commits_2018_09 PARTITION OF ghost.commits FOR VALUES FROM ('2018-09-01') TO ('2018-10-01');
CREATE TABLE ghost_partitions.commits_2018_10 PARTITION OF ghost.commits FOR VALUES FROM ('2018-10-01') TO ('2018-11-01');
CREATE TABLE ghost_partitions.commits_2018_11 PARTITION OF ghost.commits FOR VALUES FROM ('2018-11-01') TO ('2018-12-01');
CREATE TABLE ghost_partitions.commits_2018_12 PARTITION OF ghost.commits FOR VALUES FROM ('2018-12-01') TO ('2019-01-01');
CREATE TABLE ghost_partitions.commits_2019_01 PARTITION OF ghost.commits FOR VALUES FROM ('2019-01-01') TO ('2019-02-01');
CREATE TABLE ghost_partitions.commits_2019_02 PARTITION OF ghost.commits FOR VALUES FROM ('2019-02-01') TO ('2019-03-01');
CREATE TABLE ghost_partitions.commits_2019_03 PARTITION OF ghost.commits FOR VALUES FROM ('2019-03-01') TO ('2019-04-01');
CREATE TABLE ghost_partitions.commits_2019_04 PARTITION OF ghost.commits FOR VALUES FROM ('2019-04-01') TO ('2019-05-01');
CREATE TABLE ghost_partitions.commits_2019_05 PARTITION OF ghost.commits FOR VALUES FROM ('2019-05-01') TO ('2019-06-01');
CREATE TABLE ghost_partitions.commits_2019_06 PARTITION OF ghost.commits FOR VALUES FROM ('2019-06-01') TO ('2019-07-01');
CREATE TABLE ghost_partitions.commits_2019_07 PARTITION OF ghost.commits FOR VALUES FROM ('2019-07-01') TO ('2019-08-01');
CREATE TABLE ghost_partitions.commits_2019_08 PARTITION OF ghost.commits FOR VALUES FROM ('2019-08-01') TO ('2019-09-01');
CREATE TABLE ghost_partitions.commits_2019_09 PARTITION OF ghost.commits FOR VALUES FROM ('2019-09-01') TO ('2019-10-01');
CREATE TABLE ghost_partitions.commits_2019_10 PARTITION OF ghost.commits FOR VALUES FROM ('2019-10-01') TO ('2019-11-01');
CREATE TABLE ghost_partitions.commits_2019_11 PARTITION OF ghost.commits FOR VALUES FROM ('2019-11-01') TO ('2019-12-01');
CREATE TABLE ghost_partitions.commits_2019_12 PARTITION OF ghost.commits FOR VALUES FROM ('2019-12-01') TO ('2020-01-01');
CREATE TABLE ghost_partitions.commits_2020_01 PARTITION OF ghost.commits FOR VALUES FROM ('2020-01-01') TO ('2020-02-01');
CREATE TABLE ghost_partitions.commits_2020_02 PARTITION OF ghost.commits FOR VALUES FROM ('2020-02-01') TO ('2020-03-01');
CREATE TABLE ghost_partitions.commits_2020_03 PARTITION OF ghost.commits FOR VALUES FROM ('2020-03-01') TO ('2020-04-01');
CREATE TABLE ghost_partitions.commits_2020_04 PARTITION OF ghost.commits FOR VALUES FROM ('2020-04-01') TO ('2020-05-01');
CREATE TABLE ghost_partitions.commits_2020_05 PARTITION OF ghost.commits FOR VALUES FROM ('2020-05-01') TO ('2020-06-01');
CREATE TABLE ghost_partitions.commits_2020_06 PARTITION OF ghost.commits FOR VALUES FROM ('2020-06-01') TO ('2020-07-01');
CREATE TABLE ghost_partitions.commits_2020_07 PARTITION OF ghost.commits FOR VALUES FROM ('2020-07-01') TO ('2020-08-01');
CREATE TABLE ghost_partitions.commits_2020_08 PARTITION OF ghost.commits FOR VALUES FROM ('2020-08-01') TO ('2020-09-01');
CREATE TABLE ghost_partitions.commits_2020_09 PARTITION OF ghost.commits FOR VALUES FROM ('2020-09-01') TO ('2020-10-01');
CREATE TABLE ghost_partitions.commits_2020_10 PARTITION OF ghost.commits FOR VALUES FROM ('2020-10-01') TO ('2020-11-01');
CREATE TABLE ghost_partitions.commits_2020_11 PARTITION OF ghost.commits FOR VALUES FROM ('2020-11-01') TO ('2020-12-01');
CREATE TABLE ghost_partitions.commits_2020_12 PARTITION OF ghost.commits FOR VALUES FROM ('2020-12-01') TO ('2021-01-01');
CREATE TABLE ghost_partitions.commits_2021_01 PARTITION OF ghost.commits FOR VALUES FROM ('2021-01-01') TO ('2021-02-01');
CREATE TABLE ghost_partitions.commits_2021_02 PARTITION OF ghost.commits FOR VALUES FROM ('2021-02-01') TO ('2021-03-01');
CREATE TABLE ghost_partitions.commits_2021_03 PARTITION OF ghost.commits FOR VALUES FROM ('2021-03-01') TO ('2021-04-01');
CREATE TABLE ghost_partitions.commits_2021_04 PARTITION OF ghost.commits FOR VALUES FROM ('2021-04-01') TO ('2021-05-01');
CREATE TABLE ghost_partitions.commits_2021_05 PARTITION OF ghost.commits FOR VALUES FROM ('2021-05-01') TO ('2021-06-01');
CREATE TABLE ghost_partitions.commits_2021_06 PARTITION OF ghost.commits FOR VALUES FROM ('2021-06-01') TO ('2021-07-01');
CREATE TABLE ghost_partitions.commits_2021_07 PARTITION OF ghost.commits FOR VALUES FROM ('2021-07-01') TO ('2021-08-01');
CREATE TABLE ghost_partitions.commits_2021_08 PARTITION OF ghost.commits FOR VALUES FROM ('2021-08-01') TO ('2021-09-01');
CREATE TABLE ghost_partitions.commits_2021_09 PARTITION OF ghost.commits FOR VALUES FROM ('2021-09-01') TO ('2021-10-01');
CREATE TABLE ghost_partitions.commits_2021_10 PARTITION OF ghost.commits FOR VALUES FROM ('2021-10-01') TO ('2021-11-01');
CREATE TABLE ghost_partitions.commits_2021_11 PARTITION OF ghost.commits FOR VALUES FROM ('2021-11-01') TO ('2021-12-01');
CREATE TABLE ghost_partitions.commits_2021_12 PARTITION OF ghost.commits FOR VALUES FROM ('2021-12-01') TO ('2022-01-01');
CREATE TABLE ghost_partitions.commits_2022_01 PARTITION OF ghost.commits FOR VALUES FROM ('2022-01-01') TO ('2022-02-01');
CREATE TABLE ghost_partitions.commits_2022_02 PARTITION OF ghost.commits FOR VALUES FROM ('2022-02-01') TO ('2022-03-01');
CREATE TABLE ghost_partitions.commits_2022_03 PARTITION OF ghost.commits FOR VALUES FROM ('2022-03-01') TO ('2022-04-01');
CREATE TABLE ghost_partitions.commits_2022_04 PARTITION OF ghost.commits FOR VALUES FROM ('2022-04-01') TO ('2022-05-01');
CREATE TABLE ghost_partitions.commits_2022_05 PARTITION OF ghost.commits FOR VALUES FROM ('2022-05-01') TO ('2022-06-01');
CREATE TABLE ghost_partitions.commits_2022_06 PARTITION OF ghost.commits FOR VALUES FROM ('2022-06-01') TO ('2022-07-01');
CREATE TABLE ghost_partitions.commits_2022_07 PARTITION OF ghost.commits FOR VALUES FROM ('2022-07-01') TO ('2022-08-01');
CREATE TABLE ghost_partitions.commits_2022_08 PARTITION OF ghost.commits FOR VALUES FROM ('2022-08-01') TO ('2022-09-01');
CREATE TABLE ghost_partitions.commits_2022_09 PARTITION OF ghost.commits FOR VALUES FROM ('2022-09-01') TO ('2022-10-01');
CREATE TABLE ghost_partitions.commits_2022_10 PARTITION OF ghost.commits FOR VALUES FROM ('2022-10-01') TO ('2022-11-01');
CREATE TABLE ghost_partitions.commits_2022_11 PARTITION OF ghost.commits FOR VALUES FROM ('2022-11-01') TO ('2022-12-01');
CREATE TABLE ghost_partitions.commits_2022_12 PARTITION OF ghost.commits FOR VALUES FROM ('2022-12-01') TO ('2023-01-01');
CREATE TABLE ghost_partitions.commits_2023_01 PARTITION OF ghost.commits FOR VALUES FROM ('2023-01-01') TO ('2023-02-01');
CREATE TABLE ghost_partitions.commits_2023_02 PARTITION OF ghost.commits FOR VALUES FROM ('2023-02-01') TO ('2023-03-01');
CREATE TABLE ghost_partitions.commits_2023_03 PARTITION OF ghost.commits FOR VALUES FROM ('2023-03-01') TO ('2023-04-01');
CREATE TABLE ghost_partitions.commits_2023_04 PARTITION OF ghost.commits FOR VALUES FROM ('2023-04-01') TO ('2023-05-01');
CREATE TABLE ghost_partitions.commits_2023_05 PARTITION OF ghost.commits FOR VALUES FROM ('2023-05-01') TO ('2023-06-01');
CREATE TABLE ghost_partitions.commits_2023_06 PARTITION OF ghost.commits FOR VALUES FROM ('2023-06-01') TO ('2023-07-01');
CREATE TABLE ghost_partitions.commits_2023_07 PARTITION OF ghost.commits FOR VALUES FROM ('2023-07-01') TO ('2023-08-01');
CREATE TABLE ghost_partitions.commits_2023_08 PARTITION OF ghost.commits FOR VALUES FROM ('2023-08-01') TO ('2023-09-01');
CREATE TABLE ghost_partitions.commits_2023_09 PARTITION OF ghost.commits FOR VALUES FROM ('2023-09-01') TO ('2023-10-01');
CREATE TABLE ghost_partitions.commits_2023_10 PARTITION OF ghost.commits FOR VALUES FROM ('2023-10-01') TO ('2023-11-01');
CREATE TABLE ghost_partitions.commits_2023_11 PARTITION OF ghost.commits FOR VALUES FROM ('2023-11-01') TO ('2023-12-01');
CREATE TABLE ghost_partitions.commits_2023_12 PARTITION OF ghost.commits FOR VALUES FROM ('2023-12-01') TO ('2024-01-01');
CREATE TABLE ghost_partitions.commits_2024_01 PARTITION OF ghost.commits FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE ghost_partitions.commits_2024_02 PARTITION OF ghost.commits FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
CREATE TABLE ghost_partitions.commits_2024_03 PARTITION OF ghost.commits FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
CREATE TABLE ghost_partitions.commits_2024_04 PARTITION OF ghost.commits FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
CREATE TABLE ghost_partitions.commits_2024_05 PARTITION OF ghost.commits FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
CREATE TABLE ghost_partitions.commits_2024_06 PARTITION OF ghost.commits FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
CREATE TABLE ghost_partitions.commits_2024_07 PARTITION OF ghost.commits FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
CREATE TABLE ghost_partitions.commits_2024_08 PARTITION OF ghost.commits FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
CREATE TABLE ghost_partitions.commits_2024_09 PARTITION OF ghost.commits FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
CREATE TABLE ghost_partitions.commits_2024_10 PARTITION OF ghost.commits FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
CREATE TABLE ghost_partitions.commits_2024_11 PARTITION OF ghost.commits FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
CREATE TABLE ghost_partitions.commits_2024_12 PARTITION OF ghost.commits FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');