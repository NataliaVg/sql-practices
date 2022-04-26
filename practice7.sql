Cleanup data
Finding duplicates
Identify the columns 
Select them with group by and having

Find missing data (records with null values)
we can group and count
We can use nulls first on the order by

Constraints for some columns
  zip lenght must be 5

Steps to fix the data.
  1.- Create a backup table.
  CREATE TABLE <table name> as select <>
  2.- If it is possible create a new colu and work in the new col
    Fix the missing st values


1) Import data

CREATE TABLE meat_poultry_egg_establishments (
    establishment_number text CONSTRAINT est_number_key PRIMARY KEY,
    company text,
    street text,
    city text,
    st text,
    zip text,
    phone text,
    grant_date date,
    activities text,
    dbas text
);

COPY meat_poultry_egg_establishments
FROM '/tmp/MPI_Directory_by_Establishment_Name.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX company_idx ON meat_poultry_egg_establishments (company);

--6287 records
SELECT count(*) FROM meat_poultry_egg_establishments;

-- Finding multiple companies at the same address

SELECT company,
       street,
       city,
       st,
       count(*) AS address_count
FROM meat_poultry_egg_establishments
GROUP BY company, street, city, st
HAVING count(*) > 1
ORDER BY company, street, city, st;

-- Grouping and counting states

SELECT st, 
       count(*) AS st_count
FROM meat_poultry_egg_establishments
GROUP BY st
ORDER BY st;

-- Using IS NULL to find missing values in the st column

SELECT establishment_number,
       company,
       city,
       st,
       zip
FROM meat_poultry_egg_establishments
WHERE st IS NULL;

-- Using GROUP BY and count() to find inconsistent company names

SELECT company,
       count(*) AS company_count
FROM meat_poultry_egg_establishments
GROUP BY company
ORDER BY company ASC;

-- Using length() and count() to test the zip column

SELECT length(zip),
       count(*) AS length_count
FROM meat_poultry_egg_establishments
GROUP BY length(zip)
ORDER BY length(zip) ASC;

-- Filtering with length() to find short zip values

SELECT st,
       count(*) AS st_count
FROM meat_poultry_egg_establishments
WHERE length(zip) < 5
GROUP BY st
ORDER BY st ASC;

-- Listing 10-8: Backing up a table

CREATE TABLE meat_poultry_egg_establishments_backup AS
SELECT * FROM meat_poultry_egg_establishments;

-- Check number of records:
SELECT 
    (SELECT count(*) FROM meat_poultry_egg_establishments) AS original,
    (SELECT count(*) FROM meat_poultry_egg_establishments_backup) AS backup;

-- Listing 10-9: Creating and filling the st_copy column with ALTER TABLE and UPDATE

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN st_copy text;

UPDATE meat_poultry_egg_establishments
SET st_copy = st;

-- Listing 10-10: Checking values in the st and st_copy columns

SELECT st,
       st_copy
FROM meat_poultry_egg_establishments
WHERE st IS DISTINCT FROM st_copy
ORDER BY st;

-- Listing 10-11: Updating the st column for three establishments

UPDATE meat_poultry_egg_establishments
SET st = 'MN'
WHERE establishment_number = 'V18677A';

UPDATE meat_poultry_egg_establishments
SET st = 'AL'
WHERE establishment_number = 'M45319+P45319';

UPDATE meat_poultry_egg_establishments
SET st = 'WI'
WHERE establishment_number = 'M263A+P263A+V263A'
RETURNING establishment_number, company, city, st, zip;

-- Listing 10-12: Restoring original st column values

-- Restoring from the column backup
UPDATE meat_poultry_egg_establishments
SET st = st_copy;

-- Restoring from the table backup
UPDATE meat_poultry_egg_establishments original
SET st = backup.st
FROM meat_poultry_egg_establishments_backup backup
WHERE original.establishment_number = backup.establishment_number; 

-- Listing 10-13: Creating and filling the company_standard column

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN company_standard text;

UPDATE meat_poultry_egg_establishments
SET company_standard = company;

-- Listing 10-14: Using an UPDATE statement to modify column values that match a string

UPDATE meat_poultry_egg_establishments
SET company_standard = 'Armour-Eckrich Meats'
WHERE company LIKE 'Armour%'
RETURNING company, company_standard;

-- Listing 10-15: Creating and filling the zip_copy column

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN zip_copy text;

UPDATE meat_poultry_egg_establishments
SET zip_copy = zip;

-- Listing 10-16: Modify codes in the zip column missing two leading zeros

UPDATE meat_poultry_egg_establishments
SET zip = '00' || zip
WHERE st IN('PR','VI') AND length(zip) = 3;

-- Listing 10-17: Modify codes in the zip column missing one leading zero

UPDATE meat_poultry_egg_establishments
SET zip = '0' || zip
WHERE st IN('CT','MA','ME','NH','NJ','RI','VT') AND length(zip) = 4;

-- CHALLENGE add col

alter table meat_poultry_egg_establishments add column meat_processing boolean;
SELECT * FROM meat_poultry_egg_establishments;

UPDATE meat_poultry_egg_establishments
SET meat_processing = true
WHERE activities like '%Meat Processing%'

-- Delete duplicates

	DELETE FROM meat_poultry_egg_establishments
WHERE establishment_number not in (
	SELECT max(establishment_number)
FROM meat_poultry_egg_establishments
GROUP BY company, street, city, st
ORDER BY company, street, city, st
);

-- TRANSACTIONS
  help us to group db operations
  rollback
  commit
  
 -- data consistence
start transaction
update meat_poultry_egg_establishments 
SET company = 'gdl';
SELECT * FROM meat_poultry_egg_establishments;

-- DO NOT PUBLISH DATA
rollback;
SELECT * FROM meat_poultry_egg_establishments;

-- PUBLISH DATA
commit;
SELECT * FROM meat_poultry_egg_establishments;

-- Commit changes at the end:
START TRANSACTION;

UPDATE meat_poultry_egg_establishments
SET company = 'AGRO Merchants Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

COMMIT;


CREATE TABLE state_regions (
    st text CONSTRAINT st_key PRIMARY KEY,
    region text NOT NULL
);

COPY state_regions
FROM '/tmp/state_regions.csv'
WITH (FORMAT CSV, HEADER);

-- Adding and updating an inspection_deadline column

ALTER TABLE meat_poultry_egg_establishments
    ADD COLUMN inspection_deadline timestamp with time zone;

UPDATE meat_poultry_egg_establishments establishments
SET inspection_deadline = '2022-12-01 00:00 EST'
WHERE EXISTS (SELECT state_regions.region
              FROM state_regions
              WHERE establishments.st = state_regions.st 
                    AND state_regions.region = 'New England');
	
-- Viewing updated inspection_deadline values

SELECT st, inspection_deadline
FROM meat_poultry_egg_establishments
GROUP BY st, inspection_deadline
ORDER BY st;

-- Deleting rows matching an expression

DELETE FROM meat_poultry_egg_establishments
WHERE st IN('AS','GU','MP','PR','VI');

-- Listing 10-22: Removing a column from a table using DROP

ALTER TABLE meat_poultry_egg_establishments DROP COLUMN zip_copy;

-- Listing 10-23: Removing a table from a database using DROP

DROP TABLE meat_poultry_egg_establishments_backup;

-- Listing 10-24: Demonstrating a transaction block

-- Start transaction and perform update
START TRANSACTION;

UPDATE meat_poultry_egg_establishments
SET company = 'AGRO Merchantss Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

-- view changes
SELECT company
FROM meat_poultry_egg_establishments
WHERE company LIKE 'AGRO%'
ORDER BY company;

-- Revert changes
ROLLBACK;

-- See restored state
SELECT company
FROM meat_poultry_egg_establishments
WHERE company LIKE 'AGRO%'
ORDER BY company;

-- Alternately, commit changes at the end:
START TRANSACTION;

UPDATE meat_poultry_egg_establishments
SET company = 'AGRO Merchants Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

COMMIT;

-- Listing 10-25: Backing up a table while adding and filling a new column

CREATE TABLE meat_poultry_egg_establishments_backup AS
SELECT *,
       '2023-02-14 00:00 EST'::timestamp with time zone AS reviewed_date
FROM meat_poultry_egg_establishments;

-- Listing 10-26: Swapping table names using ALTER TABLE

ALTER TABLE meat_poultry_egg_establishments 
    RENAME TO meat_poultry_egg_establishments_temp;
ALTER TABLE meat_poultry_egg_establishments_backup 
    RENAME TO meat_poultry_egg_establishments;
ALTER TABLE meat_poultry_egg_establishments_temp 
    RENAME TO meat_poultry_egg_establishments_backup;
