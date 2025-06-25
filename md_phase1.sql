show tables;
-- exploring the tables
select* 
from visits;

select* 
from location;

select* 
from water_quality;

select* 
from water_source;

select* 
from well_pollution;select distinct type_of_water_source -- getting the unique water sources available,
from water_source
limit 5
;

-- Finding which water sources has the long queues of 500 plus minutes
select ws.type_of_water_source,
        v.visit_count,
        ws.type_of_water_source,
        v.time_in_queue
from water_source ws
inner join visits v ON V.source_id = ws.source_id
order by v.time_in_queue desc
limit 5
;

/*   tested the hypothesis by joining three tables
The surveyors only made multiple visits to shared taps and did not revisit other types of water sources.
  */ 
select wq.record_id,
       wq.subjective_quality_score,
        wq.visit_count,
       v.time_in_queue,
       ws.type_of_water_source
from water_quality as wq
JOIN visits as v ON v.record_id = wq.record_id
JOIN water_source as ws ON v.source_id = ws.source_id 
where 
wq.subjective_quality_score = 10
AND
ws.type_of_water_source in ('tap_in_home', 'tap_in_home_broken')
AND wq.visit_count >= 1
limit 5
;

-- checking the integrity of the data in the well pollution table
select* 
from well_pollution
where results = 'clean' AND biological > 0.01;

-- checking in the description column where there is the clean word followed by any other word

select*
from well_pollution
where description like 'clean %' AND biological > 0.01
limit 5
;

-- creating a new table from the results set of the query to test our result our result 

CREATE TABLE
md_water_services.well_pollution_copy
AS (
SELECT
*
FROM
md_water_services.well_pollution
);

-- making the changes now and testing them later in the new table created from the querry

-- Case 1a: Update 'Clean Bacteria: E. coli' descriptions
UPDATE
    well_pollution
SET
    description = 'Bacteria: E. coli'
WHERE
    description = 'Clean Bacteria: E. coli';

-- Case 1b: Update 'Clean Bacteria: Giardia Lamblia' descriptions
UPDATE
    well_pollution
SET
    description = 'Bacteria: Giardia Lamblia'
WHERE
    description = 'Clean Bacteria: Giardia Lamblia';

-- Case 2: Update 'Clean' results to 'Contaminated: Biological' where biological contamination exists
UPDATE
    well_pollution
SET
    results = 'Contaminated: Biological'
WHERE
    results = 'Clean' AND biological > 0.01;

 -- no rows affected meaning I have edited and replaced correctly
SELECT
*
FROM
well_pollution_copy
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);
