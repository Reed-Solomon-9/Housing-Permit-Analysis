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

COPY national_housing_data_table FROM '/Users/reedw.solomon/Data_Folder/Redfin Housing Data/weekly_housing_market_data_most_recent.tsv000 2' DELIMITER '	' CSV HEADER NULL 'NA';

--Redfin table with counties only (not their 2013 vintage metro areas), with county codes, 2023 CBSA codes, and 2023 metro division codes JOINED
DROP TABLE IF EXISTS codes_all_counties_2023;
CREATE TABLE codes_all_counties_2023 (
county_code_t2 VARCHAR(50),
cbsa_code VARCHAR(50),
metro_division VARCHAR(50)
);

COPY codes_all_counties_2023 FROM '/Users/reedw.solomon/Data_Folder/Redfin Housing Data/codes_all_csba_counties_2023_vintage.csv' DELIMITER ',' CSV HEADER;

--Clean region names to match with US Census data
UPDATE national_housing_data_table
SET region_name = REPLACE(region_name, 'City County', 'city')
WHERE region_name LIKE '%City County%';
UPDATE national_housing_data_table
SET region_name = REPLACE(region_name, 'Charles city', 'Charles City County')
WHERE region_name LIKE '%Charles city%';
UPDATE national_housing_data_table
SET region_name = REPLACE(region_name, 'James city', 'James City County')
WHERE region_name LIKE '%James city%';

UPDATE national_housing_data_table
SET region_name = REPLACE(region_name, ', VA', ' city, VA')
WHERE region_name LIKE '%, VA%' AND region_type_id = '5' AND region_name NOT LIKE '%County%';

UPDATE national_housing_data_table
SET region_name = REPLACE(region_name, '&', 'and')
WHERE region_name LIKE '%King &%' OR region_name LIKE '%Lewis &%';

UPDATE national_housing_data_table
SET region_name = REPLACE(region_name, 'Borough', 'Municipality')
WHERE region_name LIKE '%Anchorage%';

UPDATE national_housing_data_table
SET region_name = REPLACE(region_name, 'Borough', 'City and Borough')
WHERE region_name LIKE '%Juneau%';


--Codes added to national housing table by joining on county name (after cleaning table to ensure names match and resolving all mismatches)
DROP TABLE IF EXISTS national_housing_data_table_2;
CREATE TABLE national_housing_data_table_2 AS (

WITH table_w_county_codes AS(
SELECT
	*

FROM national_housing_data_table

FULL OUTER JOIN county_codes AS t2 ON t2.county_name = region_name 

WHERE region_type_id = '5' OR region_type_id IS NULL
)
SELECT
	*

FROM table_w_county_codes

LEFT JOIN codes_all_counties_2023 ON county_code = county_code_t2
);

ALTER TABLE national_housing_data_table_2
DROP COLUMN county_name,
DROP COLUMN county_code_t2;

UPDATE national_housing_data_table_2
SET county_code = '35013'
WHERE region_name LIKE '%Ana County, NM%';

UPDATE national_housing_data_table_2
SET cbsa_code = '29740'
WHERE region_name LIKE '%Ana County, NM%';

DELETE FROM national_housing_data_table_2 WHERE region_name IS NULL AND county_code = '35013';


--Homes sold per month and ppsf, 2017-2025
WITH year_extracted AS (
SELECT 
	EXTRACT (year FROM period_begin) AS year,
	county_code,
	region_name,
	adjusted_average_homes_sold,
	median_sale_ppsf,
	cbsa_code,
	CASE WHEN metro_division IS NOT NULL THEN metro_division ELSE cbsa_code END AS cbsa_or_metro,
	AVG(median_sale_ppsf) OVER(PARTITION BY county_code) AS timespan_avg_ppsf

FROM national_housing_data_table_2	

WHERE region_type_id = '5' AND county_code IS NOT NULL
)
SELECT
	county_code,
	region_name,
	--cbsa_code AS cbsa_2023_vintage,
	cbsa_or_metro AS cbsa_or_divsion_2023,
	ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2017) * 52, 0) AS homes_sold_2017,
	ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2018) * 52, 0) AS homes_sold_2018,
	ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2019) * 52, 0) AS homes_sold_2019,
	ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2020) * 52, 0) AS homes_sold_2020,
	ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2021) * 52, 0) AS homes_sold_2021,
	ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2022) * 52, 0) AS homes_sold_2022,
	ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2023) * 52, 0) AS homes_sold_2023,
	ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2024) * 52, 0) AS homes_sold_2024,
	ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2025) * 52, 0) AS homes_sold_2025,
	ROUND(AVG(median_sale_ppsf) FILTER(WHERE year = 2017 AND median_sale_ppsf < (5* timespan_avg_ppsf)), 2) AS ppsf_2017,
	ROUND(AVG(median_sale_ppsf) FILTER(WHERE year = 2018 AND median_sale_ppsf < (5* timespan_avg_ppsf)), 2) AS ppsf_2018,
	ROUND(AVG(median_sale_ppsf) FILTER(WHERE year = 2019 AND median_sale_ppsf < (5* timespan_avg_ppsf)), 2) AS ppsf_2019,
	ROUND(AVG(median_sale_ppsf) FILTER(WHERE year = 2020 AND median_sale_ppsf < (5* timespan_avg_ppsf)), 2) AS ppsf_2020,
	ROUND(AVG(median_sale_ppsf) FILTER(WHERE year = 2021 AND median_sale_ppsf < (5* timespan_avg_ppsf)), 2) AS ppsf_2021,
	ROUND(AVG(median_sale_ppsf) FILTER(WHERE year = 2022 AND median_sale_ppsf < (5* timespan_avg_ppsf)), 2) AS ppsf_2022,
	ROUND(AVG(median_sale_ppsf) FILTER(WHERE year = 2023 AND median_sale_ppsf < (5* timespan_avg_ppsf)), 2) AS ppsf_2023,
	ROUND(AVG(median_sale_ppsf) FILTER(WHERE year = 2024 AND median_sale_ppsf < (5* timespan_avg_ppsf)), 2) AS ppsf_2024,
	ROUND(AVG(median_sale_ppsf) FILTER(WHERE year = 2025 AND median_sale_ppsf < (5* timespan_avg_ppsf)), 2) AS ppsf_2025,
	--SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2017) * 52, 0)) OVER(PARTITION BY cbsa_code) AS cbsa_homes_sold_2017,
	--SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2018) * 52, 0)) OVER(PARTITION BY cbsa_code) AS cbsa_homes_sold_2018,
	--SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2019) * 52, 0)) OVER(PARTITION BY cbsa_code) AS cbsa_homes_sold_2019,
	--SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2020) * 52, 0)) OVER(PARTITION BY cbsa_code) AS cbsa_homes_sold_2020,
	--SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2021) * 52, 0)) OVER(PARTITION BY cbsa_code) AS cbsa_homes_sold_2021,
	--SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2022) * 52, 0)) OVER(PARTITION BY cbsa_code) AS cbsa_homes_sold_2022,
	--SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2023) * 52, 0)) OVER(PARTITION BY cbsa_code) AS cbsa_homes_sold_2023,
	--SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2024) * 52, 0)) OVER(PARTITION BY cbsa_code) AS cbsa_homes_sold_2024,
	--SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2025) * 52, 0)) OVER(PARTITION BY cbsa_code) AS cbsa_homes_sold_2025,
	SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2017) * 52, 0)) OVER(PARTITION BY cbsa_or_metro) AS cbsa_div_homes_sold_2017,
	SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2018) * 52, 0)) OVER(PARTITION BY cbsa_or_metro) AS cbsa_div_homes_sold_2018,
	SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2019) * 52, 0)) OVER(PARTITION BY cbsa_or_metro) AS cbsa_div_homes_sold_2019,
	SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2020) * 52, 0)) OVER(PARTITION BY cbsa_or_metro) AS cbsa_div_homes_sold_2020,
	SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2021) * 52, 0)) OVER(PARTITION BY cbsa_or_metro) AS cbsa_div_homes_sold_2021,
	SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2022) * 52, 0)) OVER(PARTITION BY cbsa_or_metro) AS cbsa_div_homes_sold_2022,
	SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2023) * 52, 0)) OVER(PARTITION BY cbsa_or_metro) AS cbsa_div_homes_sold_2023,
	SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2024) * 52, 0)) OVER(PARTITION BY cbsa_or_metro) AS cbsa_div_homes_sold_2024,
	SUM(ROUND(AVG(adjusted_average_homes_sold) FILTER(WHERE year = 2025) * 52, 0)) OVER(PARTITION BY cbsa_or_metro) AS cbsa_div_homes_sold_2025

FROM year_extracted

GROUP BY 
	county_code,
	region_name,
	--cbsa_code,
	cbsa_or_metro
	
--HAVING cbsa_or_metro IS NOT NULL

ORDER BY county_code
