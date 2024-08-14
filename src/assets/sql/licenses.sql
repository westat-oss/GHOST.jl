CREATE TABLE IF NOT EXISTS ghost.licenses (
    spdx character varying(20) PRIMARY KEY,
    name character varying(90) NOT NULL
);
ALTER TABLE ghost.licenses OWNER TO postgres;
COMMENT ON TABLE ghost.licenses IS 'OSI-approved machine detectable licenses';
COMMENT ON COLUMN ghost.licenses.spdx IS 'SPDX license ID';
COMMENT ON COLUMN ghost.licenses.name IS 'Name of the license';
