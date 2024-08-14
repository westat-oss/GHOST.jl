CREATE TABLE IF NOT EXISTS ghost.pats (
    login text,
    token text NOT NULL,
    CONSTRAINT pats_pkey PRIMARY KEY (login)
);
ALTER TABLE ghost.pats OWNER TO postgres;
