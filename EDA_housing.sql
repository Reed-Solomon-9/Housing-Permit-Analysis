DROP TABLE IF EXISTS national_housing_data_table;
CREATE TABLE national_housing_data_table (
PERIOD_BEGIN TIMESTAMP,	
PERIOD_END TIMESTAMP,	
REGION_TYPE	VARCHAR(50),
REGION_TYPE_ID VARCHAR(50),
REGION_NAME	VARCHAR(50),
REGION_ID VARCHAR(50),
DURATION VARCHAR(50),
ADJUSTED_AVERAGE_NEW_LISTINGS NUMERIC,	
ADJUSTED_AVERAGE_NEW_LISTINGS_YOY NUMERIC,
AVERAGE_PENDING_SALES_LISTING_UPDATES NUMERIC,
AVERAGE_PENDING_SALES_LISTING_UPDATES_YOY NUMERIC,
OFF_MARKET_IN_TWO_WEEKS	NUMERIC,
OFF_MARKET_IN_TWO_WEEKS_YOY	NUMERIC,
ADJUSTED_AVERAGE_HOMES_SOLD	NUMERIC,
ADJUSTED_AVERAGE_HOMES_SOLD_YOY	NUMERIC,
MEDIAN_NEW_LISTING_PRICE NUMERIC,
MEDIAN_NEW_LISTING_PRICE_YOY NUMERIC,
MEDIAN_SALE_PRICE NUMERIC,
MEDIAN_SALE_PRICE_YOY NUMERIC,
MEDIAN_DAYS_TO_CLOSE NUMERIC,
MEDIAN_DAYS_TO_CLOSE_YOY NUMERIC,
MEDIAN_NEW_LISTING_PPSF NUMERIC,
MEDIAN_NEW_LISTING_PPSF_YOY NUMERIC,
ACTIVE_LISTINGS NUMERIC,
ACTIVE_LISTINGS_YOY	NUMERIC,
MEDIAN_DAYS_ON_MARKET NUMERIC,
MEDIAN_DAYS_ON_MARKET_YOY NUMERIC,
PERCENT_ACTIVE_LISTINGS_WITH_PRICE_DROPS NUMERIC,	
PERCENT_ACTIVE_LISTINGS_WITH_PRICE_DROPS_YOY NUMERIC,
AGE_OF_INVENTORY NUMERIC,
AGE_OF_INVENTORY_YOY NUMERIC,
WEEKS_OF_SUPPLY	NUMERIC,
WEEKS_OF_SUPPLY_YOY	NUMERIC,
MEDIAN_PENDING_SQFT	NUMERIC,
MEDIAN_PENDING_SQFT_YOY	NUMERIC,
AVERAGE_SALE_TO_LIST_RATIO NUMERIC,
AVERAGE_SALE_TO_LIST_RATIO_YOY NUMERIC,
MEDIAN_SALE_PPSF NUMERIC,
MEDIAN_SALE_PPSF_YOY NUMERIC,
LAST_UPDATED TIMESTAMP
);

COPY national_housing_data_table FROM '/Users/reedw.solomon/Data_Folder/Redfin Housing Data/weekly_housing_market_data_most_recent.tsv000' DELIMITER '	' CSV HEADER NULL 'NA';


DROP TABLE IF EXISTS san_diego_permit_data;
CREATE TABLE san_diego_permit_data (
id VARCHAR(50),
record_id VARCHAR(50),
open_date TIMESTAMP,
issued_date TIMESTAMP,
record_status VARCHAR(50),
record_group VARCHAR(50),
record_type VARCHAR(50),
record_subtype VARCHAR(50),
record_category VARCHAR(50),
primary_scope_code VARCHAR(100),
use VARCHAR(10000),
homeowner_biz_owner VARCHAR(50),
street_address VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
zip_code VARCHAR(50),
full_address VARCHAR(200),
parcel_number VARCHAR(50),
valuation VARCHAR(50),
floor_area VARCHAR(50),
contractor_name VARCHAR(300),
contractor_address VARCHAR(100),
contractor_phone VARCHAR(50),
created_online BOOLEAN,
last_updated TIMESTAMP,
geocoded_column POINT
);

COPY san_diego_permit_data FROM '/Users/reedw.solomon/Data_Folder/Redfin Housing Data/San_Diego_Building_Permits_20251102.csv' DELIMITER ',' CSV HEADER;


--Create table for City of San Diego Development Permit data (closed)
DROP TABLE IF EXISTS san_diego_city_dev_permits;
CREATE TABLE san_diego_city_dev_permits (
PROJECT_ID VARCHAR(50),
JOB_ID VARCHAR(50),
APPROVAL_ID VARCHAR(50),
PROJECT_TITLE VARCHAR(500),
PROJECT_SCOPE VARCHAR(5000),
APPROVAL_SCOPE VARCHAR(5000),
APPROVAL_TYPE VARCHAR(500),
PROJECT_PROCESSING_CODE VARCHAR(50),
APPROVAL_PROCESSING_CODE VARCHAR(50),
APPROVAL_STATUS VARCHAR(50),
JOB_BC_CODE VARCHAR(50),
JOB_BC_CODE_DESCRIPTION VARCHAR(500),
APPROVAL_PERMIT_HOLDER VARCHAR(500),
ADDRESS_JOB VARCHAR(500),
JOB_APN VARCHAR(50),
LAT_JOB NUMERIC,
LNG_JOB NUMERIC,
DATE_PROJECT_CREATE TIMESTAMP,
DATE_PROJECT_COMPLETE TIMESTAMP,
DATE_APPROVAL_CREATE TIMESTAMP,
DATE_APPROVAL_ISSUE TIMESTAMP,
DATE_APPROVAL_CLOSE TIMESTAMP,
DATE_APPROVAL_EXPIRE TIMESTAMP,
APPROVAL_VALUATION NUMERIC,
APPROVAL_STORIES NUMERIC,
APPROVAL_FLOOR_AREA NUMERIC,
APPROVAL_DU_EXTREMELY_LOW NUMERIC,
APPROVAL_DU_VERY_LOW NUMERIC,
APPROVAL_DU_LOW NUMERIC,
APPROVAL_DU_MODERATE NUMERIC,
APPROVAL_DU_ABOVE_MODERATE NUMERIC,
APPROVAL_DU_BONUS NUMERIC,
APPROVAL_DU_FUTURE_DEMO NUMERIC,
APPROVAL_ADU_EXTREMELY_LOW NUMERIC,
APPROVAL_ADU_VERY_LOW NUMERIC,
APPROVAL_ADU_LOW NUMERIC,
APPROVAL_ADU_MODERATE NUMERIC,
APPROVAL_ADU_ABOVE_MODERATE NUMERIC,
APPROVAL_ADU_BONUS NUMERIC,
APPROVAL_ADU_TOTAL NUMERIC,
APPROVAL_JADU_EXTREMELY_LOW NUMERIC,
APPROVAL_JADU_VERY_LOW NUMERIC,
APPROVAL_JADU_LOW NUMERIC,
APPROVAL_JADU_MODERATE NUMERIC,
APPROVAL_JADU_ABOVE_MODERATE NUMERIC,
APPROVAL_JADU_BONUS NUMERIC,
APPROVAL_JADU_TOTAL NUMERIC
);

COPY san_diego_city_dev_permits FROM '/Users/reedw.solomon/Data_Folder/Redfin Housing Data/permits_set2_closed_datasd.csv' DELIMITER ',' CSV HEADER;
COPY san_diego_city_dev_permits FROM '/Users/reedw.solomon/Data_Folder/Redfin Housing Data/permits_set2_active_datasd.csv' DELIMITER ',' CSV HEADER;

--
SELECT 
	REGION_NAME,
	MEDIAN_SALE_PRICE

FROM national_housing_data_table

WHERE MEDIAN_SALE_PRICE IS NOT NULL

ORDER BY MEDIAN_SALE_PRICE DESC

LIMIT 1000


--total number of rows
SELECT
	COUNT(*)

FROM national_housing_data_table	


-- Grouped by Region
SELECT
	REGION_NAME,
	ROUND(AVG(MEDIAN_SALE_PRICE), 2),
	COUNT(*)

FROM national_housing_data_table

GROUP BY REGION_NAME

ORDER BY 
--AVG(MEDIAN_SALE_PRICE) DESC
count(*)

--find timespan (entire dataset was updated at same time)
SELECT
	MIN(LAST_UPDATED) as oldest_update,
	MAX(LAST_UPDATED) as newest_update

FROM national_housing_data_table

--examine all records for a single region
SELECT *

FROM 
 national_housing_data_table

WHERE REGION_NAME = 'Carson City, NV' 

ORDER BY PERIOD_END 

--Group percentage of homes with a price drop by year
SELECT 
	EXTRACT (YEAR FROM period_begin) AS year,
	ROUND(AVG(percent_active_listings_with_price_drops) FILTER(WHERE REGION_NAME LIKE '%Diego%') * 100, 1)  AS San_Diego_avg_percent_w_price_drop,
	ROUND(AVG(percent_active_listings_with_price_drops) FILTER(WHERE REGION_NAME LIKE 'Austin%') * 100, 1)  AS Austin_avg_percent_w_price_drop,
	ROUND(AVG(percent_active_listings_with_price_drops) * 100, 1) AS national_avg_percent_price_drop
	
	

FROM 
 national_housing_data_table


GROUP BY EXTRACT (YEAR FROM period_begin)

--Explore first rows of permit data table
SELECT *

FROM
	san_diego_permit_data

LIMIT 50	

--Find all values for selected qualitative columns
SELECT
	record_status,
	record_type,
	record_subtype,
	record_category	
	homeowner_biz_owner,
	--city,
	state,
	COUNT(*) AS num_permits

FROM san_diego_permit_data

GROUP BY 
	record_status,
	record_type,
	record_subtype,
	record_category,
	homeowner_biz_owner,
	--city,
	state

ORDER BY	
	COUNT(*) DESC

SELECT
	record_category,
	COUNT(*) AS num_permits

FROM san_diego_permit_data

GROUP BY 
	record_category

ORDER BY	
	COUNT(*) DESC	

--Establish timespan
SELECT 
	MIN(open_date) AS earliest_open_date,
	MAX(open_date) AS most_recent_open_date,
	MIN(issued_date) AS earliest_issue_date,
	MAX(issued_date) AS most_recent_issue_date,
	MIN(last_updated) AS earliest_update,
	MAX(last_updated) AS most_recent_update

	
FROM san_diego_permit_data

--Permits by category, year
SELECT
	record_category,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2003') AS num_permits_03,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2004') AS num_permits_04,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2005') AS num_permits_05,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2006') AS num_permits_06,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2007') AS num_permits_07,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2008') AS num_permits_08,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2009') AS num_permits_09,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2010') AS num_permits_10,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2011') AS num_permits_11,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2012') AS num_permits_12,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2013') AS num_permits_13,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2014') AS num_permits_14,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2015') AS num_permits_15,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2016') AS num_permits_16,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2017') AS num_permits_17,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2018') AS num_permits_18,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2019') AS num_permits_19,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2020') AS num_permits_20,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2021') AS num_permits_21,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2022') AS num_permits_22,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM issued_date) ::VARCHAR = '2023') AS num_permits_23,
	COUNT(*) FILTER (WHERE issued_date IS NULL) AS number_permits_no_issued_date,
	COUNT(*) AS total_num_permits
	
FROM san_diego_permit_data

GROUP BY 
	record_category

ORDER BY	
	COUNT(*) DESC

-- permits by open date (instead of issued date)	
SELECT
	record_category,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2003') AS num_permits_03,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2004') AS num_permits_04,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2005') AS num_permits_05,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2006') AS num_permits_06,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2007') AS num_permits_07,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2008') AS num_permits_08,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2009') AS num_permits_09,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2010') AS num_permits_10,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2011') AS num_permits_11,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2012') AS num_permits_12,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2013') AS num_permits_13,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2014') AS num_permits_14,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2015') AS num_permits_15,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2016') AS num_permits_16,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2017') AS num_permits_17,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2018') AS num_permits_18,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2019') AS num_permits_19,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2020') AS num_permits_20,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2021') AS num_permits_21,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2022') AS num_permits_22,
	COUNT(*) FILTER (WHERE EXTRACT (year FROM open_date) ::VARCHAR = '2023') AS num_permits_23,
	COUNT(*) FILTER (WHERE open_date IS NULL) AS number_permits_no_open_date,
	COUNT(*) AS total_num_permits
	
FROM san_diego_permit_data

GROUP BY 
	record_category

ORDER BY	
	COUNT(*) DESC
--All contractors in dataset

SELECT
	contractor_name,
	COUNT(*) AS num_permits

FROM san_diego_permit_data_2

GROUP BY contractor_name

ORDER BY COUNT(*) DESC

--Remove commas from number columns and cast them back to NUMERIC datatype, add column for permit processing time
DROP TABLE IF EXISTS san_diego_permit_data_2;
CREATE TABLE san_diego_permit_data_2 AS
SELECT
	REPLACE(id, ',', ''):: NUMERIC AS id,
	record_id,
	open_date,
	issued_date, 
	record_status,
	record_group,
	record_type,
	record_subtype,
	record_category,
	primary_scope_code,
	use,
	homeowner_biz_owner,
	street_address,
	city,
	state,
	zip_code,
	full_address,
	parcel_number,
	REPLACE(valuation, ',', ''):: NUMERIC AS valuation,
	REPLACE(floor_area, ',', ''):: NUMERIC AS floor_area,
	contractor_name,
	contractor_address,
	contractor_phone,
	created_online,
	last_updated,
	geocoded_column,
	(issued_date - open_date) AS processing_time

FROM san_diego_permit_data

--check new table
SELECT *

FROM san_diego_permit_data_2

Order By processing_time


--explore entries with open date after issued date
SELECT *

FROM san_diego_permit_data_2

WHERE processing_time < '0'

--Determine counts for each dimension. Dimensions are commented out for queries where they aren't used

SELECT
	--created_online,
	--record_status,
	--record_type,
	--record_subtype, 
	--record_category,	
	--homeowner_biz_owner,
	--city,
	state,
	COUNT(*) AS num_permits

FROM san_diego_permit_data_2

GROUP BY 
	--created_online
	--record_status,
	--record_type,
	--record_subtype,
	--record_category,	
	--homeowner_biz_owner,
	--city,
	state

ORDER BY COUNT(*) DESC

--Residential Alterations and contractors- how many are solar panel related?
SELECT
	contractor_name,
	COUNT(*) AS num_permits

FROM san_diego_permit_data_2

WHERE record_category != 'Residential Alteration-Addn' AND contractor_name IS NOT NULL

GROUP BY 
	contractor_name
ORDER BY COUNT(*) DESC	

--Number of permits excluding Residential Alterations/Additions
SELECT
	COUNT(*)

FROM san_diego_permit_data_2

WHERE record_category != 'Residential Alteration-Addn'	

--Number of permits for new residential construction
SELECT
	COUNT(*)

FROM san_diego_permit_data_2

WHERE record_category = 'Residential Alteration-Addn'	

--Check for large multifamly developers (not present)

SELECT *

FROM san_diego_permit_data_2

WHERE (contractor_name = 'Greystar%') OR (contractor_name = 'MG Properties%') OR (contractor_name = 'Streamline%') OR (contractor_name = 'Dinerstein%')

--Explore city permit table
SELECT
	*
FROM san_diego_city_dev_permits

LIMIT 500

--Determine # rows
SELECT
	COUNT(*) AS num_permits

FROM san_diego_city_dev_permits	

--Determine date range
SELECT 
	MIN(date_project_create) AS earliest_proj_create,
	MAX(date_project_create) AS latest_proj_create,
	MIN(date_project_complete) AS earliest_proj_complete,
	MAX(date_project_complete) AS latest_proj_complete,
	MIN(date_approval_create) AS earliest_approval_create,
	MAX(date_approval_create) AS latest_approval_create,
	MIN(date_approval_issue) AS earliest_approval_issue,
	MAX(date_approval_issue) AS latest_approval_issue,
	MIN(date_approval_close) AS earliest_approval_close,
	MAX(date_approval_close) AS latest_approval_close,
	MIN(date_approval_expire) AS earliest_approval_expire,
	MAX(date_approval_expire) AS latest_approval_expire

FROM san_diego_city_dev_permits	

--Determinee values for approval columns
SELECT
	approval_du_extremely_low,
	COUNT(*) AS num_permits

FROM san_diego_city_dev_permits

GROUP BY approval_du_extremely_low
--
SELECT
	approval_adu_moderate,
	COUNT(*) AS num_permits

FROM san_diego_city_dev_permits

GROUP BY approval_adu_moderate

--Check for primary key. Determine whether project_id or approval_id have all unique values, or if combinations of the two are all unique
SELECT 
	COUNT(*) as num_permits

FROM san_diego_city_dev_permits	

SELECT
	COUNT(DISTINCT project_id) as num_proj_ids

FROM san_diego_city_dev_permits
--
SELECT 
	COUNT(DISTINCT approval_id) AS num_approv_ids

FROM san_diego_city_dev_permits
--
SELECT
	approval_id,
	COUNT(*) AS num_permits

FROM san_diego_city_dev_permits

GROUP BY approval_id

ORDER BY COUNT(*) DESC

LIMIT 20

--
SELECT 
	project_id,
	job_id,
	approval_id,
	project_title,
	date_project_complete,
	date_approval_create

FROM san_diego_city_dev_permits

WHERE (approval_id = 'PMT-3236177') OR (approval_id = 'PMT-2589350') OR (approval_id = 'PMT-3236176') OR (approval_id = 'PMT-2529982')

ORDER BY approval_id
--
SELECT
	COUNT(DISTINCT job_id) AS num_job_ids

FROM san_diego_city_dev_permits

-- Number of appearances of each job ID
SELECT
	job_id,
	COUNT(*) AS num_permits

FROM san_diego_city_dev_permits

GROUP BY job_id

ORDER BY COUNT(*) DESC

LIMIT 20

--
SELECT 
	project_id,
	job_id,
	approval_id,
	project_title,
	date_project_complete, 
	date_approval_create

FROM san_diego_city_dev_permits

WHERE (job_id = 'JOB-072755')

--check null values for approval dates
SELECT *

FROM san_diego_city_dev_permits

WHERE date_approval_expire IS NULL

--Check values for approval floor area
SELECT 
	date_approval_create,
	project_title,
	project_scope,
	address_job,
	approval_floor_area,
	MIN(date_approval_create) OVER () AS first_approval_w_floor_area,
	MAX(date_approval_create) OVER () AS most_recent_approval_w_area
	

FROM san_diego_city_dev_permits

WHERE (approval_floor_area IS NOT NULL) AND (approval_floor_area > 0)

ORDER BY approval_floor_area DESC

--Focus on all permits on or after 3/18/2021
SELECT
	date_approval_create,
	project_title,
	project_scope,
	address_job,
	approval_floor_area

FROM san_diego_city_dev_permits

WHERE date_approval_create > '2021-03-18'

--determine values for DU, ADU, JADU columns
SELECT
	APPROVAL_DU_ABOVE_MODERATE,
	COUNT(*) AS num_permits

FROM san_diego_city_dev_permits

GROUP BY approval_du_above_moderate

--Check negative values in for DU, ADU, JADU columns
SELECT
	*

FROM san_diego_city_dev_permits

WHERE approval_du_above_moderate < 0

--Explore Tract permits in county permit table
SELECT
	*

FROM san_diego_permit_data_2

WHERE record_category = 'Commercial Multi-Bldg Parent' OR record_category = 'Tract Phase Parent' OR record_category = 'Tract Model' OR record_category = 'Tract Master Parent'
