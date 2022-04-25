1) CREATE INDEX street_idx ON new_york_addresses (street);

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'BROADWAY'; -------------------------------------1.38 seg

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = '52 STREET'; -------------------------------------1.124 seg

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'ZWICKY AVENUE';  -------------------------------------1.104 seg

CREATE INDEX street_idx ON new_york_addresses (street);

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'BROADWAY'; -------------------------------------1.88 seg

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = '52 STREET'; ------------------------------------- 666 mseg

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'ZWICKY AVENUE';  -------------------------------------341 mseg
