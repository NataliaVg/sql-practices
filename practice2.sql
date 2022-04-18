--Import practice

-------- 1 us_counties_pop_est_2019 --------

- 1.1 Create a table

CREATE TABLE us_counties_pop_est_2019 (
    state_fips text,                         -- State FIPS code
    county_fips text,                        -- County FIPS code
    region smallint,                         -- Region
    state_name text,                         -- State name	
    county_name text,                        -- County name
    area_land bigint,                        -- Area (Land) in square meters
    area_water bigint,                       -- Area (Water) in square meters
    internal_point_lat numeric(10,7),        -- Internal point (latitude)
    internal_point_lon numeric(10,7),        -- Internal point (longitude)
    pop_est_2018 integer,                    -- 2018-07-01 resident total population estimate
    pop_est_2019 integer,                    -- 2019-07-01 resident total population estimate
    births_2019 integer,                     -- Births from 2018-07-01 to 2019-06-30
    deaths_2019 integer,                     -- Deaths from 2018-07-01 to 2019-06-30
    international_migr_2019 integer,         -- Net international migration from 2018-07-01 to 2019-06-30
    domestic_migr_2019 integer,              -- Net domestic migration from 2018-07-01 to 2019-06-30
    residual_2019 integer,                   -- Residual for 2018-07-01 to 2019-06-30
    CONSTRAINT counties_2019_key PRIMARY KEY (state_fips, county_fips)	
);

- 1.2 Make the data available for the postgres user

cp us_counties_pop_est_2019.csv /tmp/

- 1.3 Import data

COPY us_counties_pop_est_2019 FROM '/tmp/us_counties_pop_est_2019.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM us_counties_pop_est_2019;

-------- 2 supervisor_salaries --------

- 2.1 Create table

CREATE TABLE supervisor_salaries (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    town text,
    county text,
    supervisor text,
    start_date text,
    salary numeric(10,2),
    benefits numeric(10,2)
);

- 2.2 Make the data available for the postgres user

cp supervisor_salaries.csv /tmp/

- 2.3 Import data

COPY supervisor_salaries (town, supervisor, salary) FROM '/tmp/supervisor_salaries.csv' 
WITH (FORMAT CSV, HEADER);

SELECT * FROM supervisor_salaries;

- 2.4 Import data with conditions

---- 2.4.1 Delete data from table

DELETE FROM supervisor_salaries;

---- 2.4.2 Import data from town New Brillig

COPY supervisor_salaries (town, supervisor, salary) 
FROM '/tmp/supervisor_salaries.csv' 
WITH (FORMAT CSV, HEADER)
WHERE town = 'New Brillig';

SELECT * FROM supervisor_salaries;

-------- 3 Temporary table --------

DELETE FROM supervisor_salaries;

- 3.1 Create table in memory with supervisor_salaries columns

CREATE TEMPORARY TABLE supervisor_salaries_temp 
    (LIKE supervisor_salaries INCLUDING ALL);
    
SELECT * FROM supervisor_salaries_temp;

- 3.2 Import data to supervisor_salaries_temp

COPY supervisor_salaries_temp (town, supervisor, salary) 
FROM '/tmp/supervisor_salaries.csv' 
WITH (FORMAT CSV, HEADER);

SELECT * FROM supervisor_salaries_temp;

- 3.3 Insert data to supervisor_salaries

INSERT INTO supervisor_salaries (town, county, supervisor, salary)
SELECT town, 'Mills', supervisor, salary
FROM supervisor_salaries_temp;

SELECT * FROM supervisor_salaries;

-------- 4 Export data --------

COPY us_counties_pop_est_2019
TO '/tmp/us_counties_export.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

cp /tmp/us_counties_export.txt .

-------- 5 Export columns --------

COPY us_counties_pop_est_2019 
    (county_name, internal_point_lat, internal_point_lon)
TO '/tmp/us_counties_latlon_export.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

cp /tmp/us_counties_latlon_export.txt .


-------- 6 Exporting query results with COPY --------

COPY (
    SELECT county_name, state_name
    FROM us_counties_pop_est_2019
    WHERE county_name ILIKE '%mill%'
     )
TO '/tmp/us_counties_mill_export.csv'
WITH (FORMAT CSV, HEADER);

cp /tmp/us_counties_mill_export.csv .
