select *
from nyc19..AB_NYC_2019;

--Data Cleaning and Transformation Steps:
--1. Remove Duplicates
Select id, count(*) as duplicates
from nyc19..AB_NYC_2019
group by id
having count(*) > 1 -- we dont have any id of airbnb that are duplicates

-- retrieves host_id that are same for multiple id of listings. it identifies hosts who have multiple airbnb
SELECT a.host_id
FROM nyc19..AB_NYC_2019 as a
join nyc19..AB_NYC_2019 as b
on a.host_id = b.host_id
where a.id != b.id --no duplicates

-- shows how many times hosts are repeated. it means it shows which host has more than one airbnb listing. 
Select host_id, HOST_NAME, count(*) as duplicates
from nyc19..AB_NYC_2019
group by host_id, host_name
having count(*) > 1

--2. Handle Missing Values
--•	Fill Missing Values with Default Values:
-- checking for null values

SELECT id, name, host_id, host_name, neighbourhood_group, neighbourhood, latitude, longitude, room_type, price, minimum_nights, number_of_reviews, 
calculated_host_listings_count, availability_365
FROM nyc19..AB_NYC_2019
where id is null 
or host_id is null
or neighbourhood_group is null
or neighbourhood is null
or latitude is null
or longitude is null
or room_type is null
or price is null
or minimum_nights is null
or number_of_reviews is null
or calculated_host_listings_count is null
or availability_365 is null;

--•	Remove Rows with Critical Missing Values:
DELETE FROM nyc19..AB_NYC_2019
WHERE longitude is null;

-- drop last_review as we wont be needing it for our visualization
alter table nyc19..AB_NYC_2019
Drop column last_review;

--3. Standardize Data Formats
--•	Standardize Text Fields:
select 
concat(
upper(left(name, 1)),
lower(substring(name, 2, Len(name)-1)))
from nyc19..AB_NYC_2019;
-- update table
update nyc19..AB_NYC_2019
set name = concat(
upper(left(name, 1)),
lower(substring(name, 2, Len(name)-1)))
--check
select *
from nyc19..AB_NYC_2019;

-- remove * from name
select name, charindex('*', name)
from nyc19..AB_NYC_2019

select name, charindex('*', name)
from nyc19..AB_NYC_2019
where charindex('*', name) > 0


select 
substring(name, 1, charindex('*', name)),
name
from nyc19..AB_NYC_2019;

select  name,
RIGHT(name, LEN(name) - CHARINDEX('*', name))
from nyc19..AB_NYC_2019
WHERE CHARINDEX('*', name) > 0

update nyc19..AB_NYC_2019
set name = RIGHT(name, LEN(name) - CHARINDEX('*', name)) WHERE CHARINDEX('*', name) > 0

select  name,
RIGHT(name, LEN(name) - CHARINDEX('*', name))
from nyc19..AB_NYC_2019
WHERE CHARINDEX('*', name) > 0


--check
select *
from nyc19..AB_NYC_2019;

--•	Trim Whitespace:
update nyc19..AB_NYC_2019
set name = trim(name)



--4. Transform Data Types
--•	Ensure Numeric Fields Are Properly Formatted:
select price,
round(price,2)
from nyc19..AB_NYC_2019
-- check if there is any abnormality. 
--checking price
select a.price
from nyc19..AB_NYC_2019 as a
where a.price not in (select round(b.price,2)
from nyc19..AB_NYC_2019 as b)
--checking minimum_nights
select a.minimum_nights
from nyc19..AB_NYC_2019 as a
where a.minimum_nights not in (select round(b.minimum_nights,2)
from nyc19..AB_NYC_2019 as b)
--checking number_of_reviews
select a.number_of_reviews
from nyc19..AB_NYC_2019 as a
where a.number_of_reviews not in (select round(b.number_of_reviews,2)
from nyc19..AB_NYC_2019 as b)

--check
select *
from nyc19..AB_NYC_2019;


--5. Create Aggregated Views for Analysis
--•	Average Availability by Neighborhood:
select neighbourhood, AVG(availability_365) as avg_availability
from nyc19..AB_NYC_2019
group by neighbourhood;

-- creating view for the selection statement
--CREATE VIEW view_AvgAvailabilityByNeighbourhood AS
--SELECT neighbourhood, AVG(availability_365) AS avg_availability
--FROM nyc19..AB_NYC_2019
--GROUP BY neighbourhood;


----drop view view_AvgAvailabilityByNeighbourhood

--select *
--from [view_AvgAvailabilityByNeighbourhood]

-- Drop the view if it already exists
IF OBJECT_ID('dbo.AvgAvailabilityByNeighbourhood', 'V') IS NOT NULL
    DROP VIEW dbo.AvgAvailabilityByNeighbourhood;

-- Create the view
CREATE VIEW dbo.AvgAvailabilityByNeighbourhood AS
SELECT neighbourhood, AVG(availability_365) AS avg_availability
FROM nyc19..AB_NYC_2019
GROUP BY neighbourhood;

SELECT 
    v.name AS ViewName, 
    s.name AS SchemaName, 
    v.create_date
FROM 
    sys.views v
JOIN 
    sys.schemas s ON v.schema_id = s.schema_id
WHERE 
    v.name = 'AvgAvailabilityByNeighbourhood';


SELECT 
    v.name AS ViewName, 
    s.name AS SchemaName, 
    v.create_date
FROM 
    sys.views v
JOIN 
    sys.schemas s ON v.schema_id = s.schema_id
WHERE 
    s.name = 'dbo';

SELECT 
    OBJECT_ID('dbo.AvgAvailabilityByNeighbourhood', 'V') AS ViewID;

USE nyc19;
GO

-- Check if the view exists
SELECT 
    v.name AS ViewName, 
    s.name AS SchemaName, 
    v.create_date
FROM 
    sys.views v
JOIN 
    sys.schemas s ON v.schema_id = s.schema_id
WHERE 
    s.name = 'dbo';

SELECT DB_NAME() AS CurrentDatabase;

USE nyc19;
GO

-- Drop the view if it already exists
IF OBJECT_ID('dbo.AvgAvailabilityByNeighbourhood', 'V') IS NOT NULL
    DROP VIEW dbo.AvgAvailabilityByNeighbourhood;
GO

-- Create the view
CREATE VIEW dbo.AvgAvailabilityByNeighbourhood AS
SELECT neighbourhood, AVG(availability_365) AS avg_availability
FROM nyc19..AB_NYC_2019
GROUP BY neighbourhood;
GO

SELECT 
    v.name AS ViewName, 
    s.name AS SchemaName, 
    v.create_date
FROM 
    sys.views v
JOIN 
    sys.schemas s ON v.schema_id = s.schema_id
WHERE 
    s.name = 'dbo'
    AND v.name = 'AvgAvailabilityByNeighbourhood';


--•	Average Price by Room Type and Neighborhood:
select neighbourhood,room_type, avg(price) as avg_price
from nyc19..AB_NYC_2019
group by neighbourhood, room_type;

-- Drop the view if it already exists
IF OBJECT_ID('dbo.AvgPriceByRoomTypeAndNeighbourhood', 'V') IS NOT NULL
    DROP VIEW dbo.AvgPriceByRoomTypeAndNeighbourhood;
GO

-- Create the view
CREATE VIEW dbo.AvgPriceByRoomTypeAndNeighbourhood AS
select neighbourhood,room_type, avg(price) as avg_price
from nyc19..AB_NYC_2019
group by neighbourhood, room_type;
GO

SELECT 
    v.name AS ViewName, 
    s.name AS SchemaName, 
    v.create_date
FROM 
    sys.views v
JOIN 
    sys.schemas s ON v.schema_id = s.schema_id
WHERE 
    s.name = 'dbo'
    AND v.name = 'AvgPriceByRoomTypeAndNeighbourhood';

-- create view for the selection statement
--create view AvgPriceByRoomTypeAndNeighbourhood as 
--select neighbourhood,room_type, avg(price) as avg_price
--from nyc19..AB_NYC_2019
--group by neighbourhood, room_type;


--select *
--from AvgPriceByRoomTypeAndNeighbourhood;

--SELECT * 
--FROM sys.views 
--WHERE name = 'AvgPriceByRoomTypeAndNeighbourhood';

--•	Top Hosts by Number of Listings:
select host_id, host_name, count(*) as airbinb_listing
from nyc19..AB_NYC_2019
group by host_id, host_name
order by airbinb_listing desc

-- Drop the view if it already exists
IF OBJECT_ID('dbo.TopHostByListing', 'V') IS NOT NULL
    DROP VIEW dbo.TopHostByListing;
GO

-- Create the view
CREATE VIEW dbo.TopHostByListing AS
select host_id, host_name, count(*) as airbinb_listing
from nyc19..AB_NYC_2019
group by host_id, host_name
GO

SELECT 
    v.name AS ViewName, 
    s.name AS SchemaName, 
    v.create_date
FROM 
    sys.views v
JOIN 
    sys.schemas s ON v.schema_id = s.schema_id
WHERE 
    s.name = 'dbo'
    AND v.name = 'TopHostByListing';

----Creating View for the selection statement
--Create View TopHostByListing as
--select host_id, host_name, count(*) as airbinb_listing
--from nyc19..AB_NYC_2019
--group by host_id, host_name

Select *
from TopHostByListing
order by airbinb_listing desc;


--6. Data Validation and Integrity Checks
--•	Check for Outliers or Unexpected Values:
Select *
from nyc19..AB_NYC_2019
where price < 0
or minimum_nights < 1
or availability_365 < 0 or availability_365 > 365;

--•	Verify Consistency:
SELECT neighbourhood, COUNT(*) AS listing_count
FROM nyc19..AB_NYC_2019
GROUP BY neighbourhood
HAVING COUNT(*) > 1000
