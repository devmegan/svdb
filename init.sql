\echo 'Creating database...'

\c vaults;

CREATE TABLE facilities (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL, 
  city VARCHAR(50) NOT NULL,
  country VARCHAR(3) NOT NULL
);

CREATE TABLE seeds (
  id SERIAL PRIMARY KEY,
  latin_name VARCHAR(50) NOT NULL,
  common_name VARCHAR(50) NOT NULL,
  type VARCHAR(50) NOT NULL
);

\echo 'Loading facilities data from fixtures...'

COPY facilities (name, city, country) 
FROM '/tmp/fixtures/facilities.csv' 
WITH (FORMAT csv);

\echo 'Facilities data loaded'
\echo 'Loading seeds data from fixtures...'

COPY seeds (latin_name, common_name, type) 
FROM '/tmp/fixtures/seeds.csv' 
WITH (FORMAT csv);

\echo 'Seeds data loaded'

CREATE TABLE facilities_seeds (
  id SERIAL PRIMARY KEY,
  facility_id INTEGER REFERENCES facilities(id),
  seed_id INTEGER REFERENCES seeds(id)
);

\echo 'Adding legume seeds to the Desert Legume Program vault...'

INSERT INTO facilities_seeds (facility_id, seed_id)
SELECT f.id, s.id
FROM seeds s
JOIN facilities f ON f.name = 'Desert Legume Program'
WHERE s.type = 'Legume';

\echo 'Adding seeds to other global facilities...'

INSERT INTO facilities_seeds (facility_id, seed_id)
SELECT f.id, s.id
FROM facilities f CROSS JOIN (
  SELECT *
  FROM seeds
  WHERE RANDOM() < (0.4 + (0.4 * RANDOM()))
  ORDER BY RANDOM()
) s -- generate a random percentage of seeds between 40% and 80% to assign to each facility
WHERE f.name <> 'Desert Legume Program';

\dt+;

\echo 'Success!'