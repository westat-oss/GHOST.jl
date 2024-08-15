INSERT INTO ghost.users 
SELECT * FROM 
    (SELECT unnest(authors_id) AS id, unnest(authors_name) AS name, unnest(authors_email) AS email 
     FROM ghost.commits) AS authors  WHERE id IS NOT NULL 
ON CONFLICT ON CONSTRAINT users_pkey DO NOTHING;