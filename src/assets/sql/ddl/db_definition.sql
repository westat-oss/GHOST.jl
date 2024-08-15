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
    spdx character varying(20) NOT NULL,
    name character varying(90) NOT NULL
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
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
)
PARTITION BY RANGE (createdat);


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

--
-- Name: commits_2009; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2009 (
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
);


ALTER TABLE ghost_partitions.commits_2009 OWNER TO postgres;

--
-- Name: commits_2010; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2010 (
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
);


ALTER TABLE ghost_partitions.commits_2010 OWNER TO postgres;

--
-- Name: commits_2011; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2011 (
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
);


ALTER TABLE ghost_partitions.commits_2011 OWNER TO postgres;

--
-- Name: commits_2012; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2012 (
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
);


ALTER TABLE ghost_partitions.commits_2012 OWNER TO postgres;

--
-- Name: commits_2013_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_01 (
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
);


ALTER TABLE ghost_partitions.commits_2013_01 OWNER TO postgres;

--
-- Name: commits_2013_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_02 (
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
);


ALTER TABLE ghost_partitions.commits_2013_02 OWNER TO postgres;

--
-- Name: commits_2013_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_03 (
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
);


ALTER TABLE ghost_partitions.commits_2013_03 OWNER TO postgres;

--
-- Name: commits_2013_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_04 (
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
);


ALTER TABLE ghost_partitions.commits_2013_04 OWNER TO postgres;

--
-- Name: commits_2013_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_05 (
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
);


ALTER TABLE ghost_partitions.commits_2013_05 OWNER TO postgres;

--
-- Name: commits_2013_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_06 (
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
);


ALTER TABLE ghost_partitions.commits_2013_06 OWNER TO postgres;

--
-- Name: commits_2013_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_07 (
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
);


ALTER TABLE ghost_partitions.commits_2013_07 OWNER TO postgres;

--
-- Name: commits_2013_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_08 (
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
);


ALTER TABLE ghost_partitions.commits_2013_08 OWNER TO postgres;

--
-- Name: commits_2013_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_09 (
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
);


ALTER TABLE ghost_partitions.commits_2013_09 OWNER TO postgres;

--
-- Name: commits_2013_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_10 (
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
);


ALTER TABLE ghost_partitions.commits_2013_10 OWNER TO postgres;

--
-- Name: commits_2013_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_11 (
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
);


ALTER TABLE ghost_partitions.commits_2013_11 OWNER TO postgres;

--
-- Name: commits_2013_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2013_12 (
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
);


ALTER TABLE ghost_partitions.commits_2013_12 OWNER TO postgres;

--
-- Name: commits_2014_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_01 (
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
);


ALTER TABLE ghost_partitions.commits_2014_01 OWNER TO postgres;

--
-- Name: commits_2014_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_02 (
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
);


ALTER TABLE ghost_partitions.commits_2014_02 OWNER TO postgres;

--
-- Name: commits_2014_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_03 (
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
);


ALTER TABLE ghost_partitions.commits_2014_03 OWNER TO postgres;

--
-- Name: commits_2014_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_04 (
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
);


ALTER TABLE ghost_partitions.commits_2014_04 OWNER TO postgres;

--
-- Name: commits_2014_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_05 (
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
);


ALTER TABLE ghost_partitions.commits_2014_05 OWNER TO postgres;

--
-- Name: commits_2014_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_06 (
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
);


ALTER TABLE ghost_partitions.commits_2014_06 OWNER TO postgres;

--
-- Name: commits_2014_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_07 (
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
);


ALTER TABLE ghost_partitions.commits_2014_07 OWNER TO postgres;

--
-- Name: commits_2014_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_08 (
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
);


ALTER TABLE ghost_partitions.commits_2014_08 OWNER TO postgres;

--
-- Name: commits_2014_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_09 (
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
);


ALTER TABLE ghost_partitions.commits_2014_09 OWNER TO postgres;

--
-- Name: commits_2014_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_10 (
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
);


ALTER TABLE ghost_partitions.commits_2014_10 OWNER TO postgres;

--
-- Name: commits_2014_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_11 (
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
);


ALTER TABLE ghost_partitions.commits_2014_11 OWNER TO postgres;

--
-- Name: commits_2014_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2014_12 (
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
);


ALTER TABLE ghost_partitions.commits_2014_12 OWNER TO postgres;

--
-- Name: commits_2015_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_01 (
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
);


ALTER TABLE ghost_partitions.commits_2015_01 OWNER TO postgres;

--
-- Name: commits_2015_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_02 (
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
);


ALTER TABLE ghost_partitions.commits_2015_02 OWNER TO postgres;

--
-- Name: commits_2015_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_03 (
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
);


ALTER TABLE ghost_partitions.commits_2015_03 OWNER TO postgres;

--
-- Name: commits_2015_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_04 (
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
);


ALTER TABLE ghost_partitions.commits_2015_04 OWNER TO postgres;

--
-- Name: commits_2015_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_05 (
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
);


ALTER TABLE ghost_partitions.commits_2015_05 OWNER TO postgres;

--
-- Name: commits_2015_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_06 (
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
);


ALTER TABLE ghost_partitions.commits_2015_06 OWNER TO postgres;

--
-- Name: commits_2015_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_07 (
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
);


ALTER TABLE ghost_partitions.commits_2015_07 OWNER TO postgres;

--
-- Name: commits_2015_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_08 (
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
);


ALTER TABLE ghost_partitions.commits_2015_08 OWNER TO postgres;

--
-- Name: commits_2015_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_09 (
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
);


ALTER TABLE ghost_partitions.commits_2015_09 OWNER TO postgres;

--
-- Name: commits_2015_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_10 (
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
);


ALTER TABLE ghost_partitions.commits_2015_10 OWNER TO postgres;

--
-- Name: commits_2015_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_11 (
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
);


ALTER TABLE ghost_partitions.commits_2015_11 OWNER TO postgres;

--
-- Name: commits_2015_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2015_12 (
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
);


ALTER TABLE ghost_partitions.commits_2015_12 OWNER TO postgres;

--
-- Name: commits_2016_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_01 (
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
);


ALTER TABLE ghost_partitions.commits_2016_01 OWNER TO postgres;

--
-- Name: commits_2016_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_02 (
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
);


ALTER TABLE ghost_partitions.commits_2016_02 OWNER TO postgres;

--
-- Name: commits_2016_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_03 (
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
);


ALTER TABLE ghost_partitions.commits_2016_03 OWNER TO postgres;

--
-- Name: commits_2016_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_04 (
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
);


ALTER TABLE ghost_partitions.commits_2016_04 OWNER TO postgres;

--
-- Name: commits_2016_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_05 (
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
);


ALTER TABLE ghost_partitions.commits_2016_05 OWNER TO postgres;

--
-- Name: commits_2016_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_06 (
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
);


ALTER TABLE ghost_partitions.commits_2016_06 OWNER TO postgres;

--
-- Name: commits_2016_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_07 (
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
);


ALTER TABLE ghost_partitions.commits_2016_07 OWNER TO postgres;

--
-- Name: commits_2016_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_08 (
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
);


ALTER TABLE ghost_partitions.commits_2016_08 OWNER TO postgres;

--
-- Name: commits_2016_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_09 (
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
);


ALTER TABLE ghost_partitions.commits_2016_09 OWNER TO postgres;

--
-- Name: commits_2016_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_10 (
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
);


ALTER TABLE ghost_partitions.commits_2016_10 OWNER TO postgres;

--
-- Name: commits_2016_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_11 (
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
);


ALTER TABLE ghost_partitions.commits_2016_11 OWNER TO postgres;

--
-- Name: commits_2016_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2016_12 (
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
);


ALTER TABLE ghost_partitions.commits_2016_12 OWNER TO postgres;

--
-- Name: commits_2017_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_01 (
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
);


ALTER TABLE ghost_partitions.commits_2017_01 OWNER TO postgres;

--
-- Name: commits_2017_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_02 (
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
);


ALTER TABLE ghost_partitions.commits_2017_02 OWNER TO postgres;

--
-- Name: commits_2017_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_03 (
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
);


ALTER TABLE ghost_partitions.commits_2017_03 OWNER TO postgres;

--
-- Name: commits_2017_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_04 (
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
);


ALTER TABLE ghost_partitions.commits_2017_04 OWNER TO postgres;

--
-- Name: commits_2017_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_05 (
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
);


ALTER TABLE ghost_partitions.commits_2017_05 OWNER TO postgres;

--
-- Name: commits_2017_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_06 (
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
);


ALTER TABLE ghost_partitions.commits_2017_06 OWNER TO postgres;

--
-- Name: commits_2017_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_07 (
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
);


ALTER TABLE ghost_partitions.commits_2017_07 OWNER TO postgres;

--
-- Name: commits_2017_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_08 (
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
);


ALTER TABLE ghost_partitions.commits_2017_08 OWNER TO postgres;

--
-- Name: commits_2017_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_09 (
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
);


ALTER TABLE ghost_partitions.commits_2017_09 OWNER TO postgres;

--
-- Name: commits_2017_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_10 (
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
);


ALTER TABLE ghost_partitions.commits_2017_10 OWNER TO postgres;

--
-- Name: commits_2017_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_11 (
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
);


ALTER TABLE ghost_partitions.commits_2017_11 OWNER TO postgres;

--
-- Name: commits_2017_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2017_12 (
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
);


ALTER TABLE ghost_partitions.commits_2017_12 OWNER TO postgres;

--
-- Name: commits_2018_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_01 (
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
);


ALTER TABLE ghost_partitions.commits_2018_01 OWNER TO postgres;

--
-- Name: commits_2018_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_02 (
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
);


ALTER TABLE ghost_partitions.commits_2018_02 OWNER TO postgres;

--
-- Name: commits_2018_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_03 (
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
);


ALTER TABLE ghost_partitions.commits_2018_03 OWNER TO postgres;

--
-- Name: commits_2018_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_04 (
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
);


ALTER TABLE ghost_partitions.commits_2018_04 OWNER TO postgres;

--
-- Name: commits_2018_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_05 (
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
);


ALTER TABLE ghost_partitions.commits_2018_05 OWNER TO postgres;

--
-- Name: commits_2018_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_06 (
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
);


ALTER TABLE ghost_partitions.commits_2018_06 OWNER TO postgres;

--
-- Name: commits_2018_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_07 (
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
);


ALTER TABLE ghost_partitions.commits_2018_07 OWNER TO postgres;

--
-- Name: commits_2018_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_08 (
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
);


ALTER TABLE ghost_partitions.commits_2018_08 OWNER TO postgres;

--
-- Name: commits_2018_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_09 (
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
);


ALTER TABLE ghost_partitions.commits_2018_09 OWNER TO postgres;

--
-- Name: commits_2018_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_10 (
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
);


ALTER TABLE ghost_partitions.commits_2018_10 OWNER TO postgres;

--
-- Name: commits_2018_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_11 (
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
);


ALTER TABLE ghost_partitions.commits_2018_11 OWNER TO postgres;

--
-- Name: commits_2018_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2018_12 (
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
);


ALTER TABLE ghost_partitions.commits_2018_12 OWNER TO postgres;

--
-- Name: commits_2019_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_01 (
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
);


ALTER TABLE ghost_partitions.commits_2019_01 OWNER TO postgres;

--
-- Name: commits_2019_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_02 (
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
);


ALTER TABLE ghost_partitions.commits_2019_02 OWNER TO postgres;

--
-- Name: commits_2019_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_03 (
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
);


ALTER TABLE ghost_partitions.commits_2019_03 OWNER TO postgres;

--
-- Name: commits_2019_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_04 (
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
);


ALTER TABLE ghost_partitions.commits_2019_04 OWNER TO postgres;

--
-- Name: commits_2019_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_05 (
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
);


ALTER TABLE ghost_partitions.commits_2019_05 OWNER TO postgres;

--
-- Name: commits_2019_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_06 (
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
);


ALTER TABLE ghost_partitions.commits_2019_06 OWNER TO postgres;

--
-- Name: commits_2019_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_07 (
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
);


ALTER TABLE ghost_partitions.commits_2019_07 OWNER TO postgres;

--
-- Name: commits_2019_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_08 (
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
);


ALTER TABLE ghost_partitions.commits_2019_08 OWNER TO postgres;

--
-- Name: commits_2019_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_09 (
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
);


ALTER TABLE ghost_partitions.commits_2019_09 OWNER TO postgres;

--
-- Name: commits_2019_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_10 (
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
);


ALTER TABLE ghost_partitions.commits_2019_10 OWNER TO postgres;

--
-- Name: commits_2019_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_11 (
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
);


ALTER TABLE ghost_partitions.commits_2019_11 OWNER TO postgres;

--
-- Name: commits_2019_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2019_12 (
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
);


ALTER TABLE ghost_partitions.commits_2019_12 OWNER TO postgres;

--
-- Name: commits_2020_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_01 (
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
);


ALTER TABLE ghost_partitions.commits_2020_01 OWNER TO postgres;

--
-- Name: commits_2020_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_02 (
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
);


ALTER TABLE ghost_partitions.commits_2020_02 OWNER TO postgres;

--
-- Name: commits_2020_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_03 (
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
);


ALTER TABLE ghost_partitions.commits_2020_03 OWNER TO postgres;

--
-- Name: commits_2020_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_04 (
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
);


ALTER TABLE ghost_partitions.commits_2020_04 OWNER TO postgres;

--
-- Name: commits_2020_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_05 (
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
);


ALTER TABLE ghost_partitions.commits_2020_05 OWNER TO postgres;

--
-- Name: commits_2020_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_06 (
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
);


ALTER TABLE ghost_partitions.commits_2020_06 OWNER TO postgres;

--
-- Name: commits_2020_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_07 (
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
);


ALTER TABLE ghost_partitions.commits_2020_07 OWNER TO postgres;

--
-- Name: commits_2020_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_08 (
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
);


ALTER TABLE ghost_partitions.commits_2020_08 OWNER TO postgres;

--
-- Name: commits_2020_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_09 (
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
);


ALTER TABLE ghost_partitions.commits_2020_09 OWNER TO postgres;

--
-- Name: commits_2020_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_10 (
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
);


ALTER TABLE ghost_partitions.commits_2020_10 OWNER TO postgres;

--
-- Name: commits_2020_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_11 (
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
);


ALTER TABLE ghost_partitions.commits_2020_11 OWNER TO postgres;

--
-- Name: commits_2020_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2020_12 (
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
);


ALTER TABLE ghost_partitions.commits_2020_12 OWNER TO postgres;

--
-- Name: commits_2021_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_01 (
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
);


ALTER TABLE ghost_partitions.commits_2021_01 OWNER TO postgres;

--
-- Name: commits_2021_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_02 (
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
);


ALTER TABLE ghost_partitions.commits_2021_02 OWNER TO postgres;

--
-- Name: commits_2021_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_03 (
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
);


ALTER TABLE ghost_partitions.commits_2021_03 OWNER TO postgres;

--
-- Name: commits_2021_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_04 (
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
);


ALTER TABLE ghost_partitions.commits_2021_04 OWNER TO postgres;

--
-- Name: commits_2021_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_05 (
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
);


ALTER TABLE ghost_partitions.commits_2021_05 OWNER TO postgres;

--
-- Name: commits_2021_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_06 (
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
);


ALTER TABLE ghost_partitions.commits_2021_06 OWNER TO postgres;

--
-- Name: commits_2021_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_07 (
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
);


ALTER TABLE ghost_partitions.commits_2021_07 OWNER TO postgres;

--
-- Name: commits_2021_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_08 (
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
);


ALTER TABLE ghost_partitions.commits_2021_08 OWNER TO postgres;

--
-- Name: commits_2021_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_09 (
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
);


ALTER TABLE ghost_partitions.commits_2021_09 OWNER TO postgres;

--
-- Name: commits_2021_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_10 (
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
);


ALTER TABLE ghost_partitions.commits_2021_10 OWNER TO postgres;

--
-- Name: commits_2021_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_11 (
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
);


ALTER TABLE ghost_partitions.commits_2021_11 OWNER TO postgres;

--
-- Name: commits_2021_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2021_12 (
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
);


ALTER TABLE ghost_partitions.commits_2021_12 OWNER TO postgres;

--
-- Name: commits_2022_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_01 (
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
);


ALTER TABLE ghost_partitions.commits_2022_01 OWNER TO postgres;

--
-- Name: commits_2022_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_02 (
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
);


ALTER TABLE ghost_partitions.commits_2022_02 OWNER TO postgres;

--
-- Name: commits_2022_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_03 (
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
);


ALTER TABLE ghost_partitions.commits_2022_03 OWNER TO postgres;

--
-- Name: commits_2022_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_04 (
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
);


ALTER TABLE ghost_partitions.commits_2022_04 OWNER TO postgres;

--
-- Name: commits_2022_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_05 (
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
);


ALTER TABLE ghost_partitions.commits_2022_05 OWNER TO postgres;

--
-- Name: commits_2022_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_06 (
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
);


ALTER TABLE ghost_partitions.commits_2022_06 OWNER TO postgres;

--
-- Name: commits_2022_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_07 (
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
);


ALTER TABLE ghost_partitions.commits_2022_07 OWNER TO postgres;

--
-- Name: commits_2022_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_08 (
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
);


ALTER TABLE ghost_partitions.commits_2022_08 OWNER TO postgres;

--
-- Name: commits_2022_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_09 (
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
);


ALTER TABLE ghost_partitions.commits_2022_09 OWNER TO postgres;

--
-- Name: commits_2022_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_10 (
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
);


ALTER TABLE ghost_partitions.commits_2022_10 OWNER TO postgres;

--
-- Name: commits_2022_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_11 (
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
);


ALTER TABLE ghost_partitions.commits_2022_11 OWNER TO postgres;

--
-- Name: commits_2022_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2022_12 (
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
);


ALTER TABLE ghost_partitions.commits_2022_12 OWNER TO postgres;

--
-- Name: commits_2023_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_01 (
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
);


ALTER TABLE ghost_partitions.commits_2023_01 OWNER TO postgres;

--
-- Name: commits_2023_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_02 (
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
);


ALTER TABLE ghost_partitions.commits_2023_02 OWNER TO postgres;

--
-- Name: commits_2023_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_03 (
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
);


ALTER TABLE ghost_partitions.commits_2023_03 OWNER TO postgres;

--
-- Name: commits_2023_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_04 (
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
);


ALTER TABLE ghost_partitions.commits_2023_04 OWNER TO postgres;

--
-- Name: commits_2023_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_05 (
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
);


ALTER TABLE ghost_partitions.commits_2023_05 OWNER TO postgres;

--
-- Name: commits_2023_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_06 (
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
);


ALTER TABLE ghost_partitions.commits_2023_06 OWNER TO postgres;

--
-- Name: commits_2023_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_07 (
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
);


ALTER TABLE ghost_partitions.commits_2023_07 OWNER TO postgres;

--
-- Name: commits_2023_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_08 (
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
);


ALTER TABLE ghost_partitions.commits_2023_08 OWNER TO postgres;

--
-- Name: commits_2023_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_09 (
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
);


ALTER TABLE ghost_partitions.commits_2023_09 OWNER TO postgres;

--
-- Name: commits_2023_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_10 (
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
);


ALTER TABLE ghost_partitions.commits_2023_10 OWNER TO postgres;

--
-- Name: commits_2023_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_11 (
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
);


ALTER TABLE ghost_partitions.commits_2023_11 OWNER TO postgres;

--
-- Name: commits_2023_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2023_12 (
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
);


ALTER TABLE ghost_partitions.commits_2023_12 OWNER TO postgres;

--
-- Name: commits_2024_01; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_01 (
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
);


ALTER TABLE ghost_partitions.commits_2024_01 OWNER TO postgres;

--
-- Name: commits_2024_02; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_02 (
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
);


ALTER TABLE ghost_partitions.commits_2024_02 OWNER TO postgres;

--
-- Name: commits_2024_03; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_03 (
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
);


ALTER TABLE ghost_partitions.commits_2024_03 OWNER TO postgres;

--
-- Name: commits_2024_04; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_04 (
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
);


ALTER TABLE ghost_partitions.commits_2024_04 OWNER TO postgres;

--
-- Name: commits_2024_05; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_05 (
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
);


ALTER TABLE ghost_partitions.commits_2024_05 OWNER TO postgres;

--
-- Name: commits_2024_06; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_06 (
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
);


ALTER TABLE ghost_partitions.commits_2024_06 OWNER TO postgres;

--
-- Name: commits_2024_07; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_07 (
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
);


ALTER TABLE ghost_partitions.commits_2024_07 OWNER TO postgres;

--
-- Name: commits_2024_08; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_08 (
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
);


ALTER TABLE ghost_partitions.commits_2024_08 OWNER TO postgres;

--
-- Name: commits_2024_09; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_09 (
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
);


ALTER TABLE ghost_partitions.commits_2024_09 OWNER TO postgres;

--
-- Name: commits_2024_10; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_10 (
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
);


ALTER TABLE ghost_partitions.commits_2024_10 OWNER TO postgres;

--
-- Name: commits_2024_11; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_11 (
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
);


ALTER TABLE ghost_partitions.commits_2024_11 OWNER TO postgres;

--
-- Name: commits_2024_12; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.commits_2024_12 (
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
);


ALTER TABLE ghost_partitions.commits_2024_12 OWNER TO postgres;

--
-- Name: repos_2007; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2007 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2007 OWNER TO postgres;

--
-- Name: repos_2008; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2008 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2008 OWNER TO postgres;

--
-- Name: repos_2009; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2009 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2009 OWNER TO postgres;

--
-- Name: repos_2010; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2010 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2010 OWNER TO postgres;

--
-- Name: repos_2011; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2011 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2011 OWNER TO postgres;

--
-- Name: repos_2012; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2012 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2012 OWNER TO postgres;

--
-- Name: repos_2013; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2013 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2013 OWNER TO postgres;

--
-- Name: repos_2014; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2014 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2014 OWNER TO postgres;

--
-- Name: repos_2015; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2015 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2015 OWNER TO postgres;

--
-- Name: repos_2016; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2016 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2016 OWNER TO postgres;

--
-- Name: repos_2017; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2017 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2017 OWNER TO postgres;

--
-- Name: repos_2018; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2018 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2018 OWNER TO postgres;

--
-- Name: repos_2019; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2019 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2019 OWNER TO postgres;

--
-- Name: repos_2020; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2020 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2020 OWNER TO postgres;

--
-- Name: repos_2021; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2021 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2021 OWNER TO postgres;

--
-- Name: repos_2022; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2022 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2022 OWNER TO postgres;

--
-- Name: repos_2023; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2023 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2023 OWNER TO postgres;

--
-- Name: repos_2024; Type: TABLE; Schema: ghost_partitions; Owner: postgres
--

CREATE TABLE ghost_partitions.repos_2024 (
    id text NOT NULL,
    spdx character varying(12) NOT NULL,
    slug text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    description text,
    primarylanguage text,
    branch text,
    commits bigint NOT NULL,
    asof timestamp without time zone DEFAULT date_trunc('second'::text, timezone('UTC'::text, CURRENT_TIMESTAMP)) NOT NULL,
    status text DEFAULT 'Init'::text NOT NULL
);


ALTER TABLE ghost_partitions.repos_2024 OWNER TO postgres;

--
-- Name: commits_2009; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2009 FOR VALUES FROM ('2000-01-01 00:00:00') TO ('2010-01-01 00:00:00');


--
-- Name: commits_2010; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2010 FOR VALUES FROM ('2010-01-01 00:00:00') TO ('2011-01-01 00:00:00');


--
-- Name: commits_2011; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2011 FOR VALUES FROM ('2011-01-01 00:00:00') TO ('2012-01-01 00:00:00');


--
-- Name: commits_2012; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2012 FOR VALUES FROM ('2012-01-01 00:00:00') TO ('2013-01-01 00:00:00');


--
-- Name: commits_2013_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_01 FOR VALUES FROM ('2013-01-01 00:00:00') TO ('2013-02-01 00:00:00');


--
-- Name: commits_2013_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_02 FOR VALUES FROM ('2013-02-01 00:00:00') TO ('2013-03-01 00:00:00');


--
-- Name: commits_2013_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_03 FOR VALUES FROM ('2013-03-01 00:00:00') TO ('2013-04-01 00:00:00');


--
-- Name: commits_2013_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_04 FOR VALUES FROM ('2013-04-01 00:00:00') TO ('2013-05-01 00:00:00');


--
-- Name: commits_2013_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_05 FOR VALUES FROM ('2013-05-01 00:00:00') TO ('2013-06-01 00:00:00');


--
-- Name: commits_2013_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_06 FOR VALUES FROM ('2013-06-01 00:00:00') TO ('2013-07-01 00:00:00');


--
-- Name: commits_2013_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_07 FOR VALUES FROM ('2013-07-01 00:00:00') TO ('2013-08-01 00:00:00');


--
-- Name: commits_2013_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_08 FOR VALUES FROM ('2013-08-01 00:00:00') TO ('2013-09-01 00:00:00');


--
-- Name: commits_2013_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_09 FOR VALUES FROM ('2013-09-01 00:00:00') TO ('2013-10-01 00:00:00');


--
-- Name: commits_2013_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_10 FOR VALUES FROM ('2013-10-01 00:00:00') TO ('2013-11-01 00:00:00');


--
-- Name: commits_2013_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_11 FOR VALUES FROM ('2013-11-01 00:00:00') TO ('2013-12-01 00:00:00');


--
-- Name: commits_2013_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2013_12 FOR VALUES FROM ('2013-12-01 00:00:00') TO ('2014-01-01 00:00:00');


--
-- Name: commits_2014_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_01 FOR VALUES FROM ('2014-01-01 00:00:00') TO ('2014-02-01 00:00:00');


--
-- Name: commits_2014_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_02 FOR VALUES FROM ('2014-02-01 00:00:00') TO ('2014-03-01 00:00:00');


--
-- Name: commits_2014_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_03 FOR VALUES FROM ('2014-03-01 00:00:00') TO ('2014-04-01 00:00:00');


--
-- Name: commits_2014_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_04 FOR VALUES FROM ('2014-04-01 00:00:00') TO ('2014-05-01 00:00:00');


--
-- Name: commits_2014_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_05 FOR VALUES FROM ('2014-05-01 00:00:00') TO ('2014-06-01 00:00:00');


--
-- Name: commits_2014_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_06 FOR VALUES FROM ('2014-06-01 00:00:00') TO ('2014-07-01 00:00:00');


--
-- Name: commits_2014_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_07 FOR VALUES FROM ('2014-07-01 00:00:00') TO ('2014-08-01 00:00:00');


--
-- Name: commits_2014_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_08 FOR VALUES FROM ('2014-08-01 00:00:00') TO ('2014-09-01 00:00:00');


--
-- Name: commits_2014_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_09 FOR VALUES FROM ('2014-09-01 00:00:00') TO ('2014-10-01 00:00:00');


--
-- Name: commits_2014_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_10 FOR VALUES FROM ('2014-10-01 00:00:00') TO ('2014-11-01 00:00:00');


--
-- Name: commits_2014_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_11 FOR VALUES FROM ('2014-11-01 00:00:00') TO ('2014-12-01 00:00:00');


--
-- Name: commits_2014_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2014_12 FOR VALUES FROM ('2014-12-01 00:00:00') TO ('2015-01-01 00:00:00');


--
-- Name: commits_2015_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_01 FOR VALUES FROM ('2015-01-01 00:00:00') TO ('2015-02-01 00:00:00');


--
-- Name: commits_2015_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_02 FOR VALUES FROM ('2015-02-01 00:00:00') TO ('2015-03-01 00:00:00');


--
-- Name: commits_2015_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_03 FOR VALUES FROM ('2015-03-01 00:00:00') TO ('2015-04-01 00:00:00');


--
-- Name: commits_2015_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_04 FOR VALUES FROM ('2015-04-01 00:00:00') TO ('2015-05-01 00:00:00');


--
-- Name: commits_2015_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_05 FOR VALUES FROM ('2015-05-01 00:00:00') TO ('2015-06-01 00:00:00');


--
-- Name: commits_2015_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_06 FOR VALUES FROM ('2015-06-01 00:00:00') TO ('2015-07-01 00:00:00');


--
-- Name: commits_2015_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_07 FOR VALUES FROM ('2015-07-01 00:00:00') TO ('2015-08-01 00:00:00');


--
-- Name: commits_2015_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_08 FOR VALUES FROM ('2015-08-01 00:00:00') TO ('2015-09-01 00:00:00');


--
-- Name: commits_2015_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_09 FOR VALUES FROM ('2015-09-01 00:00:00') TO ('2015-10-01 00:00:00');


--
-- Name: commits_2015_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_10 FOR VALUES FROM ('2015-10-01 00:00:00') TO ('2015-11-01 00:00:00');


--
-- Name: commits_2015_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_11 FOR VALUES FROM ('2015-11-01 00:00:00') TO ('2015-12-01 00:00:00');


--
-- Name: commits_2015_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2015_12 FOR VALUES FROM ('2015-12-01 00:00:00') TO ('2016-01-01 00:00:00');


--
-- Name: commits_2016_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_01 FOR VALUES FROM ('2016-01-01 00:00:00') TO ('2016-02-01 00:00:00');


--
-- Name: commits_2016_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_02 FOR VALUES FROM ('2016-02-01 00:00:00') TO ('2016-03-01 00:00:00');


--
-- Name: commits_2016_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_03 FOR VALUES FROM ('2016-03-01 00:00:00') TO ('2016-04-01 00:00:00');


--
-- Name: commits_2016_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_04 FOR VALUES FROM ('2016-04-01 00:00:00') TO ('2016-05-01 00:00:00');


--
-- Name: commits_2016_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_05 FOR VALUES FROM ('2016-05-01 00:00:00') TO ('2016-06-01 00:00:00');


--
-- Name: commits_2016_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_06 FOR VALUES FROM ('2016-06-01 00:00:00') TO ('2016-07-01 00:00:00');


--
-- Name: commits_2016_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_07 FOR VALUES FROM ('2016-07-01 00:00:00') TO ('2016-08-01 00:00:00');


--
-- Name: commits_2016_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_08 FOR VALUES FROM ('2016-08-01 00:00:00') TO ('2016-09-01 00:00:00');


--
-- Name: commits_2016_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_09 FOR VALUES FROM ('2016-09-01 00:00:00') TO ('2016-10-01 00:00:00');


--
-- Name: commits_2016_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_10 FOR VALUES FROM ('2016-10-01 00:00:00') TO ('2016-11-01 00:00:00');


--
-- Name: commits_2016_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_11 FOR VALUES FROM ('2016-11-01 00:00:00') TO ('2016-12-01 00:00:00');


--
-- Name: commits_2016_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2016_12 FOR VALUES FROM ('2016-12-01 00:00:00') TO ('2017-01-01 00:00:00');


--
-- Name: commits_2017_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_01 FOR VALUES FROM ('2017-01-01 00:00:00') TO ('2017-02-01 00:00:00');


--
-- Name: commits_2017_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_02 FOR VALUES FROM ('2017-02-01 00:00:00') TO ('2017-03-01 00:00:00');


--
-- Name: commits_2017_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_03 FOR VALUES FROM ('2017-03-01 00:00:00') TO ('2017-04-01 00:00:00');


--
-- Name: commits_2017_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_04 FOR VALUES FROM ('2017-04-01 00:00:00') TO ('2017-05-01 00:00:00');


--
-- Name: commits_2017_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_05 FOR VALUES FROM ('2017-05-01 00:00:00') TO ('2017-06-01 00:00:00');


--
-- Name: commits_2017_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_06 FOR VALUES FROM ('2017-06-01 00:00:00') TO ('2017-07-01 00:00:00');


--
-- Name: commits_2017_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_07 FOR VALUES FROM ('2017-07-01 00:00:00') TO ('2017-08-01 00:00:00');


--
-- Name: commits_2017_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_08 FOR VALUES FROM ('2017-08-01 00:00:00') TO ('2017-09-01 00:00:00');


--
-- Name: commits_2017_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_09 FOR VALUES FROM ('2017-09-01 00:00:00') TO ('2017-10-01 00:00:00');


--
-- Name: commits_2017_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_10 FOR VALUES FROM ('2017-10-01 00:00:00') TO ('2017-11-01 00:00:00');


--
-- Name: commits_2017_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_11 FOR VALUES FROM ('2017-11-01 00:00:00') TO ('2017-12-01 00:00:00');


--
-- Name: commits_2017_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2017_12 FOR VALUES FROM ('2017-12-01 00:00:00') TO ('2018-01-01 00:00:00');


--
-- Name: commits_2018_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_01 FOR VALUES FROM ('2018-01-01 00:00:00') TO ('2018-02-01 00:00:00');


--
-- Name: commits_2018_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_02 FOR VALUES FROM ('2018-02-01 00:00:00') TO ('2018-03-01 00:00:00');


--
-- Name: commits_2018_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_03 FOR VALUES FROM ('2018-03-01 00:00:00') TO ('2018-04-01 00:00:00');


--
-- Name: commits_2018_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_04 FOR VALUES FROM ('2018-04-01 00:00:00') TO ('2018-05-01 00:00:00');


--
-- Name: commits_2018_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_05 FOR VALUES FROM ('2018-05-01 00:00:00') TO ('2018-06-01 00:00:00');


--
-- Name: commits_2018_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_06 FOR VALUES FROM ('2018-06-01 00:00:00') TO ('2018-07-01 00:00:00');


--
-- Name: commits_2018_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_07 FOR VALUES FROM ('2018-07-01 00:00:00') TO ('2018-08-01 00:00:00');


--
-- Name: commits_2018_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_08 FOR VALUES FROM ('2018-08-01 00:00:00') TO ('2018-09-01 00:00:00');


--
-- Name: commits_2018_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_09 FOR VALUES FROM ('2018-09-01 00:00:00') TO ('2018-10-01 00:00:00');


--
-- Name: commits_2018_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_10 FOR VALUES FROM ('2018-10-01 00:00:00') TO ('2018-11-01 00:00:00');


--
-- Name: commits_2018_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_11 FOR VALUES FROM ('2018-11-01 00:00:00') TO ('2018-12-01 00:00:00');


--
-- Name: commits_2018_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2018_12 FOR VALUES FROM ('2018-12-01 00:00:00') TO ('2019-01-01 00:00:00');


--
-- Name: commits_2019_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_01 FOR VALUES FROM ('2019-01-01 00:00:00') TO ('2019-02-01 00:00:00');


--
-- Name: commits_2019_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_02 FOR VALUES FROM ('2019-02-01 00:00:00') TO ('2019-03-01 00:00:00');


--
-- Name: commits_2019_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_03 FOR VALUES FROM ('2019-03-01 00:00:00') TO ('2019-04-01 00:00:00');


--
-- Name: commits_2019_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_04 FOR VALUES FROM ('2019-04-01 00:00:00') TO ('2019-05-01 00:00:00');


--
-- Name: commits_2019_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_05 FOR VALUES FROM ('2019-05-01 00:00:00') TO ('2019-06-01 00:00:00');


--
-- Name: commits_2019_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_06 FOR VALUES FROM ('2019-06-01 00:00:00') TO ('2019-07-01 00:00:00');


--
-- Name: commits_2019_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_07 FOR VALUES FROM ('2019-07-01 00:00:00') TO ('2019-08-01 00:00:00');


--
-- Name: commits_2019_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_08 FOR VALUES FROM ('2019-08-01 00:00:00') TO ('2019-09-01 00:00:00');


--
-- Name: commits_2019_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_09 FOR VALUES FROM ('2019-09-01 00:00:00') TO ('2019-10-01 00:00:00');


--
-- Name: commits_2019_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_10 FOR VALUES FROM ('2019-10-01 00:00:00') TO ('2019-11-01 00:00:00');


--
-- Name: commits_2019_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_11 FOR VALUES FROM ('2019-11-01 00:00:00') TO ('2019-12-01 00:00:00');


--
-- Name: commits_2019_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2019_12 FOR VALUES FROM ('2019-12-01 00:00:00') TO ('2020-01-01 00:00:00');


--
-- Name: commits_2020_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_01 FOR VALUES FROM ('2020-01-01 00:00:00') TO ('2020-02-01 00:00:00');


--
-- Name: commits_2020_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_02 FOR VALUES FROM ('2020-02-01 00:00:00') TO ('2020-03-01 00:00:00');


--
-- Name: commits_2020_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_03 FOR VALUES FROM ('2020-03-01 00:00:00') TO ('2020-04-01 00:00:00');


--
-- Name: commits_2020_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_04 FOR VALUES FROM ('2020-04-01 00:00:00') TO ('2020-05-01 00:00:00');


--
-- Name: commits_2020_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_05 FOR VALUES FROM ('2020-05-01 00:00:00') TO ('2020-06-01 00:00:00');


--
-- Name: commits_2020_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_06 FOR VALUES FROM ('2020-06-01 00:00:00') TO ('2020-07-01 00:00:00');


--
-- Name: commits_2020_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_07 FOR VALUES FROM ('2020-07-01 00:00:00') TO ('2020-08-01 00:00:00');


--
-- Name: commits_2020_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_08 FOR VALUES FROM ('2020-08-01 00:00:00') TO ('2020-09-01 00:00:00');


--
-- Name: commits_2020_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_09 FOR VALUES FROM ('2020-09-01 00:00:00') TO ('2020-10-01 00:00:00');


--
-- Name: commits_2020_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_10 FOR VALUES FROM ('2020-10-01 00:00:00') TO ('2020-11-01 00:00:00');


--
-- Name: commits_2020_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_11 FOR VALUES FROM ('2020-11-01 00:00:00') TO ('2020-12-01 00:00:00');


--
-- Name: commits_2020_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2020_12 FOR VALUES FROM ('2020-12-01 00:00:00') TO ('2021-01-01 00:00:00');


--
-- Name: commits_2021_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_01 FOR VALUES FROM ('2021-01-01 00:00:00') TO ('2021-02-01 00:00:00');


--
-- Name: commits_2021_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_02 FOR VALUES FROM ('2021-02-01 00:00:00') TO ('2021-03-01 00:00:00');


--
-- Name: commits_2021_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_03 FOR VALUES FROM ('2021-03-01 00:00:00') TO ('2021-04-01 00:00:00');


--
-- Name: commits_2021_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_04 FOR VALUES FROM ('2021-04-01 00:00:00') TO ('2021-05-01 00:00:00');


--
-- Name: commits_2021_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_05 FOR VALUES FROM ('2021-05-01 00:00:00') TO ('2021-06-01 00:00:00');


--
-- Name: commits_2021_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_06 FOR VALUES FROM ('2021-06-01 00:00:00') TO ('2021-07-01 00:00:00');


--
-- Name: commits_2021_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_07 FOR VALUES FROM ('2021-07-01 00:00:00') TO ('2021-08-01 00:00:00');


--
-- Name: commits_2021_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_08 FOR VALUES FROM ('2021-08-01 00:00:00') TO ('2021-09-01 00:00:00');


--
-- Name: commits_2021_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_09 FOR VALUES FROM ('2021-09-01 00:00:00') TO ('2021-10-01 00:00:00');


--
-- Name: commits_2021_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_10 FOR VALUES FROM ('2021-10-01 00:00:00') TO ('2021-11-01 00:00:00');


--
-- Name: commits_2021_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_11 FOR VALUES FROM ('2021-11-01 00:00:00') TO ('2021-12-01 00:00:00');


--
-- Name: commits_2021_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2021_12 FOR VALUES FROM ('2021-12-01 00:00:00') TO ('2022-01-01 00:00:00');


--
-- Name: commits_2022_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_01 FOR VALUES FROM ('2022-01-01 00:00:00') TO ('2022-02-01 00:00:00');


--
-- Name: commits_2022_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_02 FOR VALUES FROM ('2022-02-01 00:00:00') TO ('2022-03-01 00:00:00');


--
-- Name: commits_2022_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_03 FOR VALUES FROM ('2022-03-01 00:00:00') TO ('2022-04-01 00:00:00');


--
-- Name: commits_2022_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_04 FOR VALUES FROM ('2022-04-01 00:00:00') TO ('2022-05-01 00:00:00');


--
-- Name: commits_2022_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_05 FOR VALUES FROM ('2022-05-01 00:00:00') TO ('2022-06-01 00:00:00');


--
-- Name: commits_2022_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_06 FOR VALUES FROM ('2022-06-01 00:00:00') TO ('2022-07-01 00:00:00');


--
-- Name: commits_2022_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_07 FOR VALUES FROM ('2022-07-01 00:00:00') TO ('2022-08-01 00:00:00');


--
-- Name: commits_2022_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_08 FOR VALUES FROM ('2022-08-01 00:00:00') TO ('2022-09-01 00:00:00');


--
-- Name: commits_2022_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_09 FOR VALUES FROM ('2022-09-01 00:00:00') TO ('2022-10-01 00:00:00');


--
-- Name: commits_2022_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_10 FOR VALUES FROM ('2022-10-01 00:00:00') TO ('2022-11-01 00:00:00');


--
-- Name: commits_2022_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_11 FOR VALUES FROM ('2022-11-01 00:00:00') TO ('2022-12-01 00:00:00');


--
-- Name: commits_2022_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2022_12 FOR VALUES FROM ('2022-12-01 00:00:00') TO ('2023-01-01 00:00:00');


--
-- Name: commits_2023_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_01 FOR VALUES FROM ('2023-01-01 00:00:00') TO ('2023-02-01 00:00:00');


--
-- Name: commits_2023_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_02 FOR VALUES FROM ('2023-02-01 00:00:00') TO ('2023-03-01 00:00:00');


--
-- Name: commits_2023_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_03 FOR VALUES FROM ('2023-03-01 00:00:00') TO ('2023-04-01 00:00:00');


--
-- Name: commits_2023_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_04 FOR VALUES FROM ('2023-04-01 00:00:00') TO ('2023-05-01 00:00:00');


--
-- Name: commits_2023_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_05 FOR VALUES FROM ('2023-05-01 00:00:00') TO ('2023-06-01 00:00:00');


--
-- Name: commits_2023_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_06 FOR VALUES FROM ('2023-06-01 00:00:00') TO ('2023-07-01 00:00:00');


--
-- Name: commits_2023_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_07 FOR VALUES FROM ('2023-07-01 00:00:00') TO ('2023-08-01 00:00:00');


--
-- Name: commits_2023_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_08 FOR VALUES FROM ('2023-08-01 00:00:00') TO ('2023-09-01 00:00:00');


--
-- Name: commits_2023_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_09 FOR VALUES FROM ('2023-09-01 00:00:00') TO ('2023-10-01 00:00:00');


--
-- Name: commits_2023_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_10 FOR VALUES FROM ('2023-10-01 00:00:00') TO ('2023-11-01 00:00:00');


--
-- Name: commits_2023_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_11 FOR VALUES FROM ('2023-11-01 00:00:00') TO ('2023-12-01 00:00:00');


--
-- Name: commits_2023_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2023_12 FOR VALUES FROM ('2023-12-01 00:00:00') TO ('2024-01-01 00:00:00');


--
-- Name: commits_2024_01; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_01 FOR VALUES FROM ('2024-01-01 00:00:00') TO ('2024-02-01 00:00:00');


--
-- Name: commits_2024_02; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_02 FOR VALUES FROM ('2024-02-01 00:00:00') TO ('2024-03-01 00:00:00');


--
-- Name: commits_2024_03; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_03 FOR VALUES FROM ('2024-03-01 00:00:00') TO ('2024-04-01 00:00:00');


--
-- Name: commits_2024_04; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_04 FOR VALUES FROM ('2024-04-01 00:00:00') TO ('2024-05-01 00:00:00');


--
-- Name: commits_2024_05; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_05 FOR VALUES FROM ('2024-05-01 00:00:00') TO ('2024-06-01 00:00:00');


--
-- Name: commits_2024_06; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_06 FOR VALUES FROM ('2024-06-01 00:00:00') TO ('2024-07-01 00:00:00');


--
-- Name: commits_2024_07; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_07 FOR VALUES FROM ('2024-07-01 00:00:00') TO ('2024-08-01 00:00:00');


--
-- Name: commits_2024_08; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_08 FOR VALUES FROM ('2024-08-01 00:00:00') TO ('2024-09-01 00:00:00');


--
-- Name: commits_2024_09; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_09 FOR VALUES FROM ('2024-09-01 00:00:00') TO ('2024-10-01 00:00:00');


--
-- Name: commits_2024_10; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_10 FOR VALUES FROM ('2024-10-01 00:00:00') TO ('2024-11-01 00:00:00');


--
-- Name: commits_2024_11; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_11 FOR VALUES FROM ('2024-11-01 00:00:00') TO ('2024-12-01 00:00:00');


--
-- Name: commits_2024_12; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.commits ATTACH PARTITION ghost_partitions.commits_2024_12 FOR VALUES FROM ('2024-12-01 00:00:00') TO ('2025-01-01 00:00:00');


--
-- Name: repos_2007; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2007 FOR VALUES FROM ('2007-01-01 00:00:00') TO ('2008-01-01 00:00:00');


--
-- Name: repos_2008; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2008 FOR VALUES FROM ('2008-01-01 00:00:00') TO ('2009-01-01 00:00:00');


--
-- Name: repos_2009; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2009 FOR VALUES FROM ('2009-01-01 00:00:00') TO ('2010-01-01 00:00:00');


--
-- Name: repos_2010; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2010 FOR VALUES FROM ('2010-01-01 00:00:00') TO ('2011-01-01 00:00:00');


--
-- Name: repos_2011; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2011 FOR VALUES FROM ('2011-01-01 00:00:00') TO ('2012-01-01 00:00:00');


--
-- Name: repos_2012; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2012 FOR VALUES FROM ('2012-01-01 00:00:00') TO ('2013-01-01 00:00:00');


--
-- Name: repos_2013; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2013 FOR VALUES FROM ('2013-01-01 00:00:00') TO ('2014-01-01 00:00:00');


--
-- Name: repos_2014; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2014 FOR VALUES FROM ('2014-01-01 00:00:00') TO ('2015-01-01 00:00:00');


--
-- Name: repos_2015; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2015 FOR VALUES FROM ('2015-01-01 00:00:00') TO ('2016-01-01 00:00:00');


--
-- Name: repos_2016; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2016 FOR VALUES FROM ('2016-01-01 00:00:00') TO ('2017-01-01 00:00:00');


--
-- Name: repos_2017; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2017 FOR VALUES FROM ('2017-01-01 00:00:00') TO ('2018-01-01 00:00:00');


--
-- Name: repos_2018; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2018 FOR VALUES FROM ('2018-01-01 00:00:00') TO ('2019-01-01 00:00:00');


--
-- Name: repos_2019; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2019 FOR VALUES FROM ('2019-01-01 00:00:00') TO ('2020-01-01 00:00:00');


--
-- Name: repos_2020; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2020 FOR VALUES FROM ('2020-01-01 00:00:00') TO ('2021-01-01 00:00:00');


--
-- Name: repos_2021; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2021 FOR VALUES FROM ('2021-01-01 00:00:00') TO ('2022-01-01 00:00:00');


--
-- Name: repos_2022; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2022 FOR VALUES FROM ('2022-01-01 00:00:00') TO ('2023-01-01 00:00:00');


--
-- Name: repos_2023; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2023 FOR VALUES FROM ('2023-01-01 00:00:00') TO ('2024-01-01 00:00:00');


--
-- Name: repos_2024; Type: TABLE ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost.repos ATTACH PARTITION ghost_partitions.repos_2024 FOR VALUES FROM ('2024-01-01 00:00:00') TO ('2025-01-01 00:00:00');


--
-- Name: commits commits_pkey; Type: CONSTRAINT; Schema: ghost; Owner: postgres
--

ALTER TABLE ONLY ghost.commits
    ADD CONSTRAINT commits_pkey PRIMARY KEY (id, committedat);


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: ghost; Owner: postgres
--

ALTER TABLE ONLY ghost.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (spdx);


--
-- Name: queries nonoverlappingqueries; Type: CONSTRAINT; Schema: ghost; Owner: postgres
--

ALTER TABLE ONLY ghost.queries
    ADD CONSTRAINT nonoverlappingqueries EXCLUDE USING gist (created WITH &&, spdx WITH =);


--
-- Name: CONSTRAINT nonoverlappingqueries ON queries; Type: COMMENT; Schema: ghost; Owner: postgres
--

COMMENT ON CONSTRAINT nonoverlappingqueries ON ghost.queries IS 'No duplicate for queries';


--
-- Name: pats pats_pkey; Type: CONSTRAINT; Schema: ghost; Owner: postgres
--

ALTER TABLE ONLY ghost.pats
    ADD CONSTRAINT pats_pkey PRIMARY KEY (login);


--
-- Name: repos repos_branch; Type: CONSTRAINT; Schema: ghost; Owner: postgres
--

ALTER TABLE ONLY ghost.repos
    ADD CONSTRAINT repos_branch UNIQUE (branch, createdat);


--
-- Name: repos repos_pkey; Type: CONSTRAINT; Schema: ghost; Owner: postgres
--

ALTER TABLE ONLY ghost.repos
    ADD CONSTRAINT repos_pkey PRIMARY KEY (id, createdat);


--
-- Name: test_usr test_usr_pkey; Type: CONSTRAINT; Schema: ghost; Owner: postgres
--

ALTER TABLE ONLY ghost.test_usr
    ADD CONSTRAINT test_usr_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: ghost; Owner: postgres
--

ALTER TABLE ONLY ghost.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (author_id);


--
-- Name: commits_2009 commits_2009_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2009
    ADD CONSTRAINT commits_2009_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2010 commits_2010_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2010
    ADD CONSTRAINT commits_2010_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2011 commits_2011_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2011
    ADD CONSTRAINT commits_2011_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2012 commits_2012_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2012
    ADD CONSTRAINT commits_2012_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_01 commits_2013_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_01
    ADD CONSTRAINT commits_2013_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_02 commits_2013_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_02
    ADD CONSTRAINT commits_2013_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_03 commits_2013_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_03
    ADD CONSTRAINT commits_2013_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_04 commits_2013_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_04
    ADD CONSTRAINT commits_2013_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_05 commits_2013_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_05
    ADD CONSTRAINT commits_2013_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_06 commits_2013_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_06
    ADD CONSTRAINT commits_2013_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_07 commits_2013_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_07
    ADD CONSTRAINT commits_2013_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_08 commits_2013_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_08
    ADD CONSTRAINT commits_2013_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_09 commits_2013_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_09
    ADD CONSTRAINT commits_2013_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_10 commits_2013_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_10
    ADD CONSTRAINT commits_2013_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_11 commits_2013_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_11
    ADD CONSTRAINT commits_2013_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2013_12 commits_2013_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2013_12
    ADD CONSTRAINT commits_2013_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_01 commits_2014_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_01
    ADD CONSTRAINT commits_2014_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_02 commits_2014_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_02
    ADD CONSTRAINT commits_2014_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_03 commits_2014_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_03
    ADD CONSTRAINT commits_2014_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_04 commits_2014_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_04
    ADD CONSTRAINT commits_2014_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_05 commits_2014_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_05
    ADD CONSTRAINT commits_2014_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_06 commits_2014_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_06
    ADD CONSTRAINT commits_2014_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_07 commits_2014_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_07
    ADD CONSTRAINT commits_2014_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_08 commits_2014_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_08
    ADD CONSTRAINT commits_2014_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_09 commits_2014_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_09
    ADD CONSTRAINT commits_2014_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_10 commits_2014_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_10
    ADD CONSTRAINT commits_2014_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_11 commits_2014_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_11
    ADD CONSTRAINT commits_2014_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2014_12 commits_2014_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2014_12
    ADD CONSTRAINT commits_2014_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_01 commits_2015_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_01
    ADD CONSTRAINT commits_2015_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_02 commits_2015_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_02
    ADD CONSTRAINT commits_2015_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_03 commits_2015_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_03
    ADD CONSTRAINT commits_2015_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_04 commits_2015_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_04
    ADD CONSTRAINT commits_2015_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_05 commits_2015_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_05
    ADD CONSTRAINT commits_2015_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_06 commits_2015_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_06
    ADD CONSTRAINT commits_2015_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_07 commits_2015_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_07
    ADD CONSTRAINT commits_2015_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_08 commits_2015_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_08
    ADD CONSTRAINT commits_2015_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_09 commits_2015_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_09
    ADD CONSTRAINT commits_2015_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_10 commits_2015_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_10
    ADD CONSTRAINT commits_2015_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_11 commits_2015_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_11
    ADD CONSTRAINT commits_2015_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2015_12 commits_2015_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2015_12
    ADD CONSTRAINT commits_2015_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_01 commits_2016_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_01
    ADD CONSTRAINT commits_2016_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_02 commits_2016_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_02
    ADD CONSTRAINT commits_2016_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_03 commits_2016_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_03
    ADD CONSTRAINT commits_2016_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_04 commits_2016_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_04
    ADD CONSTRAINT commits_2016_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_05 commits_2016_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_05
    ADD CONSTRAINT commits_2016_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_06 commits_2016_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_06
    ADD CONSTRAINT commits_2016_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_07 commits_2016_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_07
    ADD CONSTRAINT commits_2016_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_08 commits_2016_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_08
    ADD CONSTRAINT commits_2016_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_09 commits_2016_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_09
    ADD CONSTRAINT commits_2016_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_10 commits_2016_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_10
    ADD CONSTRAINT commits_2016_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_11 commits_2016_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_11
    ADD CONSTRAINT commits_2016_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2016_12 commits_2016_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2016_12
    ADD CONSTRAINT commits_2016_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_01 commits_2017_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_01
    ADD CONSTRAINT commits_2017_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_02 commits_2017_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_02
    ADD CONSTRAINT commits_2017_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_03 commits_2017_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_03
    ADD CONSTRAINT commits_2017_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_04 commits_2017_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_04
    ADD CONSTRAINT commits_2017_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_05 commits_2017_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_05
    ADD CONSTRAINT commits_2017_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_06 commits_2017_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_06
    ADD CONSTRAINT commits_2017_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_07 commits_2017_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_07
    ADD CONSTRAINT commits_2017_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_08 commits_2017_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_08
    ADD CONSTRAINT commits_2017_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_09 commits_2017_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_09
    ADD CONSTRAINT commits_2017_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_10 commits_2017_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_10
    ADD CONSTRAINT commits_2017_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_11 commits_2017_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_11
    ADD CONSTRAINT commits_2017_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2017_12 commits_2017_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2017_12
    ADD CONSTRAINT commits_2017_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_01 commits_2018_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_01
    ADD CONSTRAINT commits_2018_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_02 commits_2018_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_02
    ADD CONSTRAINT commits_2018_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_03 commits_2018_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_03
    ADD CONSTRAINT commits_2018_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_04 commits_2018_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_04
    ADD CONSTRAINT commits_2018_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_05 commits_2018_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_05
    ADD CONSTRAINT commits_2018_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_06 commits_2018_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_06
    ADD CONSTRAINT commits_2018_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_07 commits_2018_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_07
    ADD CONSTRAINT commits_2018_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_08 commits_2018_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_08
    ADD CONSTRAINT commits_2018_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_09 commits_2018_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_09
    ADD CONSTRAINT commits_2018_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_10 commits_2018_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_10
    ADD CONSTRAINT commits_2018_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_11 commits_2018_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_11
    ADD CONSTRAINT commits_2018_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2018_12 commits_2018_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2018_12
    ADD CONSTRAINT commits_2018_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_01 commits_2019_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_01
    ADD CONSTRAINT commits_2019_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_02 commits_2019_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_02
    ADD CONSTRAINT commits_2019_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_03 commits_2019_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_03
    ADD CONSTRAINT commits_2019_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_04 commits_2019_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_04
    ADD CONSTRAINT commits_2019_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_05 commits_2019_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_05
    ADD CONSTRAINT commits_2019_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_06 commits_2019_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_06
    ADD CONSTRAINT commits_2019_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_07 commits_2019_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_07
    ADD CONSTRAINT commits_2019_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_08 commits_2019_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_08
    ADD CONSTRAINT commits_2019_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_09 commits_2019_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_09
    ADD CONSTRAINT commits_2019_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_10 commits_2019_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_10
    ADD CONSTRAINT commits_2019_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_11 commits_2019_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_11
    ADD CONSTRAINT commits_2019_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2019_12 commits_2019_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2019_12
    ADD CONSTRAINT commits_2019_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_01 commits_2020_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_01
    ADD CONSTRAINT commits_2020_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_02 commits_2020_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_02
    ADD CONSTRAINT commits_2020_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_03 commits_2020_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_03
    ADD CONSTRAINT commits_2020_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_04 commits_2020_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_04
    ADD CONSTRAINT commits_2020_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_05 commits_2020_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_05
    ADD CONSTRAINT commits_2020_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_06 commits_2020_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_06
    ADD CONSTRAINT commits_2020_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_07 commits_2020_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_07
    ADD CONSTRAINT commits_2020_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_08 commits_2020_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_08
    ADD CONSTRAINT commits_2020_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_09 commits_2020_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_09
    ADD CONSTRAINT commits_2020_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_10 commits_2020_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_10
    ADD CONSTRAINT commits_2020_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_11 commits_2020_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_11
    ADD CONSTRAINT commits_2020_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2020_12 commits_2020_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2020_12
    ADD CONSTRAINT commits_2020_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_01 commits_2021_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_01
    ADD CONSTRAINT commits_2021_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_02 commits_2021_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_02
    ADD CONSTRAINT commits_2021_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_03 commits_2021_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_03
    ADD CONSTRAINT commits_2021_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_04 commits_2021_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_04
    ADD CONSTRAINT commits_2021_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_05 commits_2021_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_05
    ADD CONSTRAINT commits_2021_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_06 commits_2021_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_06
    ADD CONSTRAINT commits_2021_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_07 commits_2021_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_07
    ADD CONSTRAINT commits_2021_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_08 commits_2021_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_08
    ADD CONSTRAINT commits_2021_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_09 commits_2021_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_09
    ADD CONSTRAINT commits_2021_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_10 commits_2021_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_10
    ADD CONSTRAINT commits_2021_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_11 commits_2021_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_11
    ADD CONSTRAINT commits_2021_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2021_12 commits_2021_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2021_12
    ADD CONSTRAINT commits_2021_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_01 commits_2022_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_01
    ADD CONSTRAINT commits_2022_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_02 commits_2022_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_02
    ADD CONSTRAINT commits_2022_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_03 commits_2022_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_03
    ADD CONSTRAINT commits_2022_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_04 commits_2022_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_04
    ADD CONSTRAINT commits_2022_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_05 commits_2022_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_05
    ADD CONSTRAINT commits_2022_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_06 commits_2022_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_06
    ADD CONSTRAINT commits_2022_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_07 commits_2022_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_07
    ADD CONSTRAINT commits_2022_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_08 commits_2022_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_08
    ADD CONSTRAINT commits_2022_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_09 commits_2022_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_09
    ADD CONSTRAINT commits_2022_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_10 commits_2022_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_10
    ADD CONSTRAINT commits_2022_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_11 commits_2022_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_11
    ADD CONSTRAINT commits_2022_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2022_12 commits_2022_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2022_12
    ADD CONSTRAINT commits_2022_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_01 commits_2023_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_01
    ADD CONSTRAINT commits_2023_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_02 commits_2023_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_02
    ADD CONSTRAINT commits_2023_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_03 commits_2023_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_03
    ADD CONSTRAINT commits_2023_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_04 commits_2023_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_04
    ADD CONSTRAINT commits_2023_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_05 commits_2023_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_05
    ADD CONSTRAINT commits_2023_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_06 commits_2023_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_06
    ADD CONSTRAINT commits_2023_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_07 commits_2023_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_07
    ADD CONSTRAINT commits_2023_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_08 commits_2023_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_08
    ADD CONSTRAINT commits_2023_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_09 commits_2023_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_09
    ADD CONSTRAINT commits_2023_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_10 commits_2023_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_10
    ADD CONSTRAINT commits_2023_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_11 commits_2023_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_11
    ADD CONSTRAINT commits_2023_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2023_12 commits_2023_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2023_12
    ADD CONSTRAINT commits_2023_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_01 commits_2024_01_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_01
    ADD CONSTRAINT commits_2024_01_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_02 commits_2024_02_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_02
    ADD CONSTRAINT commits_2024_02_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_03 commits_2024_03_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_03
    ADD CONSTRAINT commits_2024_03_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_04 commits_2024_04_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_04
    ADD CONSTRAINT commits_2024_04_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_05 commits_2024_05_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_05
    ADD CONSTRAINT commits_2024_05_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_06 commits_2024_06_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_06
    ADD CONSTRAINT commits_2024_06_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_07 commits_2024_07_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_07
    ADD CONSTRAINT commits_2024_07_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_08 commits_2024_08_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_08
    ADD CONSTRAINT commits_2024_08_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_09 commits_2024_09_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_09
    ADD CONSTRAINT commits_2024_09_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_10 commits_2024_10_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_10
    ADD CONSTRAINT commits_2024_10_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_11 commits_2024_11_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_11
    ADD CONSTRAINT commits_2024_11_pkey PRIMARY KEY (id, committedat);


--
-- Name: commits_2024_12 commits_2024_12_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.commits_2024_12
    ADD CONSTRAINT commits_2024_12_pkey PRIMARY KEY (id, committedat);


--
-- Name: repos_2007 repos_2007_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2007
    ADD CONSTRAINT repos_2007_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2007 repos_2007_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2007
    ADD CONSTRAINT repos_2007_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2008 repos_2008_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2008
    ADD CONSTRAINT repos_2008_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2008 repos_2008_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2008
    ADD CONSTRAINT repos_2008_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2009 repos_2009_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2009
    ADD CONSTRAINT repos_2009_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2009 repos_2009_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2009
    ADD CONSTRAINT repos_2009_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2010 repos_2010_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2010
    ADD CONSTRAINT repos_2010_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2010 repos_2010_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2010
    ADD CONSTRAINT repos_2010_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2011 repos_2011_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2011
    ADD CONSTRAINT repos_2011_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2011 repos_2011_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2011
    ADD CONSTRAINT repos_2011_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2012 repos_2012_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2012
    ADD CONSTRAINT repos_2012_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2012 repos_2012_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2012
    ADD CONSTRAINT repos_2012_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2013 repos_2013_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2013
    ADD CONSTRAINT repos_2013_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2013 repos_2013_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2013
    ADD CONSTRAINT repos_2013_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2014 repos_2014_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2014
    ADD CONSTRAINT repos_2014_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2014 repos_2014_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2014
    ADD CONSTRAINT repos_2014_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2015 repos_2015_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2015
    ADD CONSTRAINT repos_2015_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2015 repos_2015_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2015
    ADD CONSTRAINT repos_2015_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2016 repos_2016_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2016
    ADD CONSTRAINT repos_2016_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2016 repos_2016_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2016
    ADD CONSTRAINT repos_2016_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2017 repos_2017_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2017
    ADD CONSTRAINT repos_2017_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2017 repos_2017_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2017
    ADD CONSTRAINT repos_2017_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2018 repos_2018_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2018
    ADD CONSTRAINT repos_2018_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2018 repos_2018_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2018
    ADD CONSTRAINT repos_2018_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2019 repos_2019_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2019
    ADD CONSTRAINT repos_2019_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2019 repos_2019_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2019
    ADD CONSTRAINT repos_2019_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2020 repos_2020_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2020
    ADD CONSTRAINT repos_2020_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2020 repos_2020_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2020
    ADD CONSTRAINT repos_2020_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2021 repos_2021_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2021
    ADD CONSTRAINT repos_2021_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2021 repos_2021_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2021
    ADD CONSTRAINT repos_2021_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2022 repos_2022_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2022
    ADD CONSTRAINT repos_2022_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2022 repos_2022_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2022
    ADD CONSTRAINT repos_2022_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2023 repos_2023_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2023
    ADD CONSTRAINT repos_2023_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2023 repos_2023_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2023
    ADD CONSTRAINT repos_2023_pkey PRIMARY KEY (id, createdat);


--
-- Name: repos_2024 repos_2024_branch_createdat_key; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2024
    ADD CONSTRAINT repos_2024_branch_createdat_key UNIQUE (branch, createdat);


--
-- Name: repos_2024 repos_2024_pkey; Type: CONSTRAINT; Schema: ghost_partitions; Owner: postgres
--

ALTER TABLE ONLY ghost_partitions.repos_2024
    ADD CONSTRAINT repos_2024_pkey PRIMARY KEY (id, createdat);


--
-- Name: commits_2009_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2009_pkey;


--
-- Name: commits_2010_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2010_pkey;


--
-- Name: commits_2011_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2011_pkey;


--
-- Name: commits_2012_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2012_pkey;


--
-- Name: commits_2013_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_01_pkey;


--
-- Name: commits_2013_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_02_pkey;


--
-- Name: commits_2013_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_03_pkey;


--
-- Name: commits_2013_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_04_pkey;


--
-- Name: commits_2013_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_05_pkey;


--
-- Name: commits_2013_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_06_pkey;


--
-- Name: commits_2013_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_07_pkey;


--
-- Name: commits_2013_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_08_pkey;


--
-- Name: commits_2013_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_09_pkey;


--
-- Name: commits_2013_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_10_pkey;


--
-- Name: commits_2013_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_11_pkey;


--
-- Name: commits_2013_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2013_12_pkey;


--
-- Name: commits_2014_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_01_pkey;


--
-- Name: commits_2014_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_02_pkey;


--
-- Name: commits_2014_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_03_pkey;


--
-- Name: commits_2014_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_04_pkey;


--
-- Name: commits_2014_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_05_pkey;


--
-- Name: commits_2014_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_06_pkey;


--
-- Name: commits_2014_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_07_pkey;


--
-- Name: commits_2014_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_08_pkey;


--
-- Name: commits_2014_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_09_pkey;


--
-- Name: commits_2014_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_10_pkey;


--
-- Name: commits_2014_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_11_pkey;


--
-- Name: commits_2014_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2014_12_pkey;


--
-- Name: commits_2015_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_01_pkey;


--
-- Name: commits_2015_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_02_pkey;


--
-- Name: commits_2015_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_03_pkey;


--
-- Name: commits_2015_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_04_pkey;


--
-- Name: commits_2015_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_05_pkey;


--
-- Name: commits_2015_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_06_pkey;


--
-- Name: commits_2015_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_07_pkey;


--
-- Name: commits_2015_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_08_pkey;


--
-- Name: commits_2015_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_09_pkey;


--
-- Name: commits_2015_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_10_pkey;


--
-- Name: commits_2015_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_11_pkey;


--
-- Name: commits_2015_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2015_12_pkey;


--
-- Name: commits_2016_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_01_pkey;


--
-- Name: commits_2016_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_02_pkey;


--
-- Name: commits_2016_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_03_pkey;


--
-- Name: commits_2016_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_04_pkey;


--
-- Name: commits_2016_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_05_pkey;


--
-- Name: commits_2016_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_06_pkey;


--
-- Name: commits_2016_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_07_pkey;


--
-- Name: commits_2016_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_08_pkey;


--
-- Name: commits_2016_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_09_pkey;


--
-- Name: commits_2016_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_10_pkey;


--
-- Name: commits_2016_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_11_pkey;


--
-- Name: commits_2016_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2016_12_pkey;


--
-- Name: commits_2017_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_01_pkey;


--
-- Name: commits_2017_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_02_pkey;


--
-- Name: commits_2017_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_03_pkey;


--
-- Name: commits_2017_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_04_pkey;


--
-- Name: commits_2017_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_05_pkey;


--
-- Name: commits_2017_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_06_pkey;


--
-- Name: commits_2017_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_07_pkey;


--
-- Name: commits_2017_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_08_pkey;


--
-- Name: commits_2017_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_09_pkey;


--
-- Name: commits_2017_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_10_pkey;


--
-- Name: commits_2017_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_11_pkey;


--
-- Name: commits_2017_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2017_12_pkey;


--
-- Name: commits_2018_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_01_pkey;


--
-- Name: commits_2018_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_02_pkey;


--
-- Name: commits_2018_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_03_pkey;


--
-- Name: commits_2018_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_04_pkey;


--
-- Name: commits_2018_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_05_pkey;


--
-- Name: commits_2018_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_06_pkey;


--
-- Name: commits_2018_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_07_pkey;


--
-- Name: commits_2018_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_08_pkey;


--
-- Name: commits_2018_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_09_pkey;


--
-- Name: commits_2018_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_10_pkey;


--
-- Name: commits_2018_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_11_pkey;


--
-- Name: commits_2018_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2018_12_pkey;


--
-- Name: commits_2019_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_01_pkey;


--
-- Name: commits_2019_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_02_pkey;


--
-- Name: commits_2019_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_03_pkey;


--
-- Name: commits_2019_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_04_pkey;


--
-- Name: commits_2019_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_05_pkey;


--
-- Name: commits_2019_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_06_pkey;


--
-- Name: commits_2019_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_07_pkey;


--
-- Name: commits_2019_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_08_pkey;


--
-- Name: commits_2019_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_09_pkey;


--
-- Name: commits_2019_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_10_pkey;


--
-- Name: commits_2019_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_11_pkey;


--
-- Name: commits_2019_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2019_12_pkey;


--
-- Name: commits_2020_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_01_pkey;


--
-- Name: commits_2020_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_02_pkey;


--
-- Name: commits_2020_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_03_pkey;


--
-- Name: commits_2020_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_04_pkey;


--
-- Name: commits_2020_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_05_pkey;


--
-- Name: commits_2020_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_06_pkey;


--
-- Name: commits_2020_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_07_pkey;


--
-- Name: commits_2020_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_08_pkey;


--
-- Name: commits_2020_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_09_pkey;


--
-- Name: commits_2020_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_10_pkey;


--
-- Name: commits_2020_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_11_pkey;


--
-- Name: commits_2020_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2020_12_pkey;


--
-- Name: commits_2021_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_01_pkey;


--
-- Name: commits_2021_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_02_pkey;


--
-- Name: commits_2021_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_03_pkey;


--
-- Name: commits_2021_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_04_pkey;


--
-- Name: commits_2021_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_05_pkey;


--
-- Name: commits_2021_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_06_pkey;


--
-- Name: commits_2021_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_07_pkey;


--
-- Name: commits_2021_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_08_pkey;


--
-- Name: commits_2021_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_09_pkey;


--
-- Name: commits_2021_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_10_pkey;


--
-- Name: commits_2021_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_11_pkey;


--
-- Name: commits_2021_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2021_12_pkey;


--
-- Name: commits_2022_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_01_pkey;


--
-- Name: commits_2022_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_02_pkey;


--
-- Name: commits_2022_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_03_pkey;


--
-- Name: commits_2022_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_04_pkey;


--
-- Name: commits_2022_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_05_pkey;


--
-- Name: commits_2022_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_06_pkey;


--
-- Name: commits_2022_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_07_pkey;


--
-- Name: commits_2022_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_08_pkey;


--
-- Name: commits_2022_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_09_pkey;


--
-- Name: commits_2022_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_10_pkey;


--
-- Name: commits_2022_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_11_pkey;


--
-- Name: commits_2022_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2022_12_pkey;


--
-- Name: commits_2023_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_01_pkey;


--
-- Name: commits_2023_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_02_pkey;


--
-- Name: commits_2023_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_03_pkey;


--
-- Name: commits_2023_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_04_pkey;


--
-- Name: commits_2023_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_05_pkey;


--
-- Name: commits_2023_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_06_pkey;


--
-- Name: commits_2023_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_07_pkey;


--
-- Name: commits_2023_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_08_pkey;


--
-- Name: commits_2023_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_09_pkey;


--
-- Name: commits_2023_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_10_pkey;


--
-- Name: commits_2023_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_11_pkey;


--
-- Name: commits_2023_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2023_12_pkey;


--
-- Name: commits_2024_01_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_01_pkey;


--
-- Name: commits_2024_02_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_02_pkey;


--
-- Name: commits_2024_03_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_03_pkey;


--
-- Name: commits_2024_04_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_04_pkey;


--
-- Name: commits_2024_05_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_05_pkey;


--
-- Name: commits_2024_06_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_06_pkey;


--
-- Name: commits_2024_07_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_07_pkey;


--
-- Name: commits_2024_08_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_08_pkey;


--
-- Name: commits_2024_09_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_09_pkey;


--
-- Name: commits_2024_10_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_10_pkey;


--
-- Name: commits_2024_11_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_11_pkey;


--
-- Name: commits_2024_12_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.commits_pkey ATTACH PARTITION ghost_partitions.commits_2024_12_pkey;


--
-- Name: repos_2007_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2007_branch_createdat_key;


--
-- Name: repos_2007_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2007_pkey;


--
-- Name: repos_2008_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2008_branch_createdat_key;


--
-- Name: repos_2008_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2008_pkey;


--
-- Name: repos_2009_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2009_branch_createdat_key;


--
-- Name: repos_2009_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2009_pkey;


--
-- Name: repos_2010_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2010_branch_createdat_key;


--
-- Name: repos_2010_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2010_pkey;


--
-- Name: repos_2011_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2011_branch_createdat_key;


--
-- Name: repos_2011_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2011_pkey;


--
-- Name: repos_2012_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2012_branch_createdat_key;


--
-- Name: repos_2012_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2012_pkey;


--
-- Name: repos_2013_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2013_branch_createdat_key;


--
-- Name: repos_2013_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2013_pkey;


--
-- Name: repos_2014_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2014_branch_createdat_key;


--
-- Name: repos_2014_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2014_pkey;


--
-- Name: repos_2015_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2015_branch_createdat_key;


--
-- Name: repos_2015_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2015_pkey;


--
-- Name: repos_2016_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2016_branch_createdat_key;


--
-- Name: repos_2016_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2016_pkey;


--
-- Name: repos_2017_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2017_branch_createdat_key;


--
-- Name: repos_2017_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2017_pkey;


--
-- Name: repos_2018_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2018_branch_createdat_key;


--
-- Name: repos_2018_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2018_pkey;


--
-- Name: repos_2019_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2019_branch_createdat_key;


--
-- Name: repos_2019_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2019_pkey;


--
-- Name: repos_2020_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2020_branch_createdat_key;


--
-- Name: repos_2020_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2020_pkey;


--
-- Name: repos_2021_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2021_branch_createdat_key;


--
-- Name: repos_2021_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2021_pkey;


--
-- Name: repos_2022_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2022_branch_createdat_key;


--
-- Name: repos_2022_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2022_pkey;


--
-- Name: repos_2023_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2023_branch_createdat_key;


--
-- Name: repos_2023_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2023_pkey;


--
-- Name: repos_2024_branch_createdat_key; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_branch ATTACH PARTITION ghost_partitions.repos_2024_branch_createdat_key;


--
-- Name: repos_2024_pkey; Type: INDEX ATTACH; Schema: ghost_partitions; Owner: postgres
--

ALTER INDEX ghost.repos_pkey ATTACH PARTITION ghost_partitions.repos_2024_pkey;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

