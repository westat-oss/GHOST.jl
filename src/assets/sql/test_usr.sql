CREATE TABLE ghost.test_usr (
    id text,
    acctype text NOT NULL,
    login text NOT NULL,
    PRIMARY KEY (id)
);
ALTER TABLE ghost.test_usr OWNER TO postgres;
