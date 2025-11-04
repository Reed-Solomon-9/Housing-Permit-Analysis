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

--All contractors in dataset

SELECT
	contractor_name,
	COUNT(*) AS num_permits

FROM san_diego_permit_data

GROUP BY contractor_name

ORDER BY COUNT(*) DESC
	
