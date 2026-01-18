# Analysis of Relationship between New Housing Permits and Prices Nationwide

## Summary
This study incorporates permit and population data from the US Census Bureau, as well as real estate price data from Redfin, to attempt to establish a statistical relationship between housing construction and prices. The study covers 128 metro areas over the years 2017 through 2024 for sale prices, and 41 metro areas from 2020 through 2024 for rents. 

My results show a statistically significant effect of the number of building permits issued two years prior on home prices in most years studied, as well as for the entire timespan, and with a particularly strong negative effect from 2022 through 2024 and a positive effect in 2021. The effect of new building permits on rents was less clear, perhaps due to sample size issues, but the overall effect of new housing on rents was moderately negative. The effects were calculated using a standard multivariate linear regression model.

## Data 
This analysis uses the following data:
- Building permit data for every county in a Census Bureau Statistical Area (CBSA) in the United States from from 2015 through 2022. The data can be accessed in CSV form through [this webpage.](https://www2.census.gov/econ/bps/County/)
  The links marked with an "a" before the file extension pertain to full years.
- Population data for every county in the United States that is in a CBSA from 2016 through 2024. The data was sourced from the US Census Bureau on [this page](https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/) for the years 2016 through 2019 (with intercensal population totals from the last link on [this page](https://www2.census.gov/programs-surveys/popest/tables/2010-2020/intercensal/county/)), and the first link on [this page](https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/metro/totals/) for 2020 through 2024.
  
- Housing market data from Redfin.  Redfin, the large online brokerage, generously makes highly complete data publicly available for home sales nationwide, and also features a table with asking rents in large multifamily buildings in 41 major metropolitan areas. The Redfin home sales table includes data from 1828 out of 1844 counties in the 2023 Vintage CBSA- missing only five counties from Mississippi (2 CBSAs), one county in Hawai'i with a population estimate of 81 people, and the ten parrishes that make up the Baton Rouge, Louisiana CBSA. 
