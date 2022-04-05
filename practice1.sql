-- SQL PRACTICE 1 --

-- Write a query that lists the schools in alphabetical order along with the 
-- teachers ordered by the first name A-Z

SELECT school, first_name 
FROM teachers
ORDER BY school ASC, first_name ASC;

-- Write a query to find the one teacher whose first name starts with the
-- letter S and who earns more than $40000

SELECT * 
FROM teachers
WHERE first_name LIKE 'S%'
	AND salary >40000;
    
-- Rank teachers hired since January 1,2010 ordered by highest pay to lowest

SELECT * 
FROM teachers
WHERE hire_date >= '2010-01-01'
ORDER BY salary DESC;