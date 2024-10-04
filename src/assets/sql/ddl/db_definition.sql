--
-- PostgreSQL database dump
--

-- Dumped from database version 12.20 (Ubuntu 12.20-1.pgdg20.04+1)
-- Dumped by pg_dump version 16.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ghost; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ghost;


ALTER SCHEMA ghost OWNER TO postgres;

--
-- Name: ghost_partitions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ghost_partitions;


ALTER SCHEMA ghost_partitions OWNER TO postgres;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


SET default_tablespace = '';

--
-- Name: commits; Type: TABLE; Schema: ghost; Owner: postgres
--

CREATE TABLE ghost.commits (
    branch text NOT NULL,
    id text NOT NULL,
    oid text NOT NULL,
    committedat timestamp without time zone NOT NULL,
    authors_email text[] NOT NULL,
    authors_name text[] NOT NULL,
    authors_id text[],
    additions bigint,
    deletions bigint,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL
)
PARTITION BY RANGE (committedat);


ALTER TABLE ghost.commits OWNER TO postgres;

--
-- Name: TABLE commits; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON TABLE ghost.commits IS 'Commits Information';


--
-- Name: COLUMN commits.branch; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.commits.branch IS 'Base Branch ID (foreign key)';


--
-- Name: COLUMN commits.id; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.commits.id IS 'Commit ID';


--
-- Name: COLUMN commits.oid; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.commits.oid IS 'Git Object ID (SHA1)';


--
-- Name: COLUMN commits.committedat; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.commits.committedat IS 'When was it committed?';


--
-- Name: COLUMN commits.authors_email; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.commits.authors_email IS 'The email in the Git commit.';


--
-- Name: COLUMN commits.authors_name; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.commits.authors_name IS 'The name in the Git commit.';


--
-- Name: COLUMN commits.authors_id; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.commits.authors_id IS 'GitHub Author';


--
-- Name: COLUMN commits.additions; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.commits.additions IS 'The number of additions in this commit.';


--
-- Name: COLUMN commits.deletions; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.commits.deletions IS 'The number of deletions in this commit.';


--
-- Name: COLUMN commits.asof; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.commits.asof IS 'When was GitHub queried.';


SET default_table_access_method = heap;

--
-- Name: licenses; Type: TABLE; Schema: ghost; Owner: postgres
--

CREATE TABLE ghost.licenses (
    spdx text NOT NULL,
    name text NOT NULL
);


ALTER TABLE ghost.licenses OWNER TO postgres;

--
-- Name: TABLE licenses; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON TABLE ghost.licenses IS 'OSI-approved machine detectable licenses';


--
-- Name: COLUMN licenses.spdx; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.licenses.spdx IS 'SPDX license ID';


--
-- Name: COLUMN licenses.name; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.licenses.name IS 'Name of the license';


--
-- Name: pats; Type: TABLE; Schema: ghost; Owner: postgres
--

CREATE TABLE ghost.pats (
    login text NOT NULL,
    token text NOT NULL
);


ALTER TABLE ghost.pats OWNER TO postgres;

--
-- Name: queries; Type: TABLE; Schema: ghost; Owner: postgres
--

CREATE TABLE ghost.queries (
    spdx text NOT NULL,
    created tsrange NOT NULL,
    count smallint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    done boolean DEFAULT false NOT NULL
);


ALTER TABLE ghost.queries OWNER TO postgres;

--
-- Name: TABLE queries; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON TABLE ghost.queries IS 'This table is a tracker for queries';


--
-- Name: COLUMN queries.spdx; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.queries.spdx IS 'The SPDX license ID';


--
-- Name: COLUMN queries.created; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.queries.created IS 'The time interval for the query';


--
-- Name: COLUMN queries.count; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.queries.count IS 'How many results for the query';


--
-- Name: COLUMN queries.asof; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.queries.asof IS 'When was GitHub queried about the information.';


--
-- Name: COLUMN queries.done; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.queries.done IS 'Has the repositories been collected?';


--
-- Name: repos; Type: TABLE; Schema: ghost; Owner: postgres
--

CREATE TABLE ghost.repos (
    id text NOT NULL,
    spdx text NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    topics text[],
    forks integer,
    isinorganization boolean,
    homepageurl text,
    dependencies text[],
    stargazers integer,
    watchers integer,
    releases integer,
    issues integer,
    commits integer NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
) PARTITION BY RANGE (createdat);

ALTER TABLE ghost.repos OWNER TO postgres;

--
-- Name: TABLE repos; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON TABLE ghost.repos IS 'Repository ID and base branch ID';


--
-- Name: COLUMN repos.id; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.repos.id IS 'Repository ID';


--
-- Name: COLUMN repos.spdx; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.repos.spdx IS 'SPDX license ID';


--
-- Name: COLUMN repos.slug; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.repos.slug IS 'Location of the respository';


--
-- Name: COLUMN repos.createdat; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.repos.createdat IS 'When was the repository created on GitHub?';


--
-- Name: COLUMN repos.description; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.repos.description IS 'Description of the respository';


--
-- Name: COLUMN repos.primarylanguage; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.repos.primarylanguage IS 'Primary language of the respository';


--
-- Name: COLUMN repos.branch; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.repos.branch IS 'Base branch ID';


--
-- Name: COLUMN repos.commits; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.repos.commits IS 'Number of commits in the branch until the end of the observation period';


--
-- Name: COLUMN repos.asof; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.repos.asof IS 'When was GitHub queried?';


--
-- Name: COLUMN repos.status; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON COLUMN ghost.repos.status IS 'Status of collection effort';


--
-- Name: test_usr; Type: TABLE; Schema: ghost; Owner: postgres
--

CREATE TABLE ghost.test_usr (
    id text NOT NULL,
    acctype text NOT NULL,
    login text NOT NULL
);


ALTER TABLE ghost.test_usr OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: ghost; Owner: postgres
--

CREATE TABLE ghost.users (
    author_id text NOT NULL,
    author_name text,
    author_email text NOT NULL
);


ALTER TABLE ghost.users OWNER TO postgres;

CREATE TABLE ghost_partitions.commits_1900_01 PARTITION OF ghost.commits FOR VALUES FROM ('1900-01-01') TO ('2009-01-01');
CREATE TABLE ghost_partitions.commits_2009_01 PARTITION OF ghost.commits FOR VALUES FROM ('2009-01-01') TO ('2010-01-01');
CREATE TABLE ghost_partitions.commits_2010_01 PARTITION OF ghost.commits FOR VALUES FROM ('2010-01-01') TO ('2011-01-01');
CREATE TABLE ghost_partitions.commits_2011_01 PARTITION OF ghost.commits FOR VALUES FROM ('2011-01-01') TO ('2012-01-01');
CREATE TABLE ghost_partitions.commits_2012_01 PARTITION OF ghost.commits FOR VALUES FROM ('2012-01-01') TO ('2013-01-01');
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
CREATE TABLE ghost_partitions.commits_2025_01 PARTITION OF ghost.commits FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE ghost_partitions.commits_2025_02 PARTITION OF ghost.commits FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE ghost_partitions.commits_2025_03 PARTITION OF ghost.commits FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');
CREATE TABLE ghost_partitions.commits_2025_04 PARTITION OF ghost.commits FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE ghost_partitions.commits_2025_05 PARTITION OF ghost.commits FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE ghost_partitions.commits_2025_06 PARTITION OF ghost.commits FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');
CREATE TABLE ghost_partitions.commits_2025_07 PARTITION OF ghost.commits FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');
CREATE TABLE ghost_partitions.commits_2025_08 PARTITION OF ghost.commits FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');
CREATE TABLE ghost_partitions.commits_2025_09 PARTITION OF ghost.commits FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');
CREATE TABLE ghost_partitions.commits_2025_10 PARTITION OF ghost.commits FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');
CREATE TABLE ghost_partitions.commits_2025_11 PARTITION OF ghost.commits FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
CREATE TABLE ghost_partitions.commits_2025_12 PARTITION OF ghost.commits FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');
CREATE TABLE ghost_partitions.commits_2026_01 PARTITION OF ghost.commits FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE ghost_partitions.commits_2026_02 PARTITION OF ghost.commits FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE ghost_partitions.commits_2026_03 PARTITION OF ghost.commits FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
CREATE TABLE ghost_partitions.commits_2026_04 PARTITION OF ghost.commits FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
CREATE TABLE ghost_partitions.commits_2026_05 PARTITION OF ghost.commits FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE ghost_partitions.commits_2026_06 PARTITION OF ghost.commits FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');
CREATE TABLE ghost_partitions.commits_2026_07 PARTITION OF ghost.commits FOR VALUES FROM ('2026-07-01') TO ('2026-08-01');
CREATE TABLE ghost_partitions.commits_2026_08 PARTITION OF ghost.commits FOR VALUES FROM ('2026-08-01') TO ('2026-09-01');
CREATE TABLE ghost_partitions.commits_2026_09 PARTITION OF ghost.commits FOR VALUES FROM ('2026-09-01') TO ('2026-10-01');
CREATE TABLE ghost_partitions.commits_2026_10 PARTITION OF ghost.commits FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');
CREATE TABLE ghost_partitions.commits_2026_11 PARTITION OF ghost.commits FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');
CREATE TABLE ghost_partitions.commits_2026_12 PARTITION OF ghost.commits FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');

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
CREATE TABLE ghost_partitions.repos_2025 PARTITION OF ghost.repos FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE ghost_partitions.repos_2026 PARTITION OF ghost.repos FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE TABLE ghost_partitions.repos_2027 PARTITION OF ghost.repos FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');
CREATE TABLE ghost_partitions.repos_2028 PARTITION OF ghost.repos FOR VALUES FROM ('2028-01-01') TO ('2029-01-01');

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

