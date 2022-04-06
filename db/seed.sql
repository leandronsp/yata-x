DROP EXTENSION IF EXISTS pgcrypto;
DROP TABLE IF EXISTS users;

CREATE EXTENSION pgcrypto;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(100) UNIQUE NOT NULL,
  password TEXT NOT NULL
);

INSERT INTO users
  (email, password)
  VALUES
  ('user1@example.com', crypt('pass', gen_salt('bf'))),
  ('user2@example.com', crypt('pass', gen_salt('bf'))),
  ('user3@example.com', crypt('pass', gen_salt('bf')));
