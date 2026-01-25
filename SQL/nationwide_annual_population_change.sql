--REQUIRES national_housing_data_table_2, created in full_housing_table_redfin.sql
--run full_housing_table_redfin.sql before this file.

--Create table with population totals for all counties in 2024
DROP TABLE IF EXISTS populations_2024_by_CBSA_or_div_2023;
CREATE TABLE populations_2024_by_CBSA_or_div_2023 (
CBSA_or_div_code VARCHAR(50),
pop_2024 NUMERIC
);

COPY populations_2024_by_CBSA_or_div_2023 FROM '/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Other Data/CBSA_2023_or_div_populations_2024.tsv' DELIMITER '	' HEADER;

--Table for average change in price per square foot nationwide by year
SELECT *
FROM populations_2024_by_CBSA_or_div_2023

WITH with_cbsa_or_division AS(
SELECT
	*,
	CASE WHEN metro_division IS NOT NULL THEN metro_division ELSE cbsa_code END AS cbsa_or_metro,
	AVG(median_sale_ppsf_yoy) OVER(PARTITION BY region_name) AS timespan_avg_ppsf_yoy,
	EXTRACT(YEAR FROM period_begin) AS year

FROM national_housing_data_table_2
)

SELECT 
	year,
	ROUND(AVG(median_sale_ppsf_yoy) FILTER(WHERE median_sale_ppsf_yoy < (5* timespan_avg_ppsf_yoy)), 4) AS yoy_ppsf

FROM with_cbsa_or_division

FULL OUTER JOIN populations_2024_by_CBSA_or_div_2023 ON cbsa_or_metro = cbsa_or_div_code

WHERE 
	--pop_2024 >= 500000 AND 
	MEDIAN_SALE_PPSF_YOY IS NOT NULL 

GROUP BY 
	year

ORDER BY year