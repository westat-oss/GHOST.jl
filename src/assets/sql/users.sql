CREATE TABLE ghost.users 
(
    author_id text NOT NULL,
    author_name text,
    author_email text NOT NULL,
    PRIMARY KEY (author_id)
);
ALTER TABLE ghost.users OWNER TO postgres;