# Analysis of Relationship between New Housing Permits and Prices Nationwide

## Summary
This study incorporates permit and population data from the US Census Bureau, as well as real estate price data from Redfin, to attempt to establish a statistical relationship between housing construction and prices. The study covers 128 metro areas over the years 2017 through 2024 for sale prices, and 41 metro areas from 2020 through 2024 for rents. 

My results show a statistically significant effect of the number of building permits issued two years prior on home prices in most years studied, as well as for the entire timespan, and with a particularly strong negative effect from 2022 through 2024 and a positive effect in 2021. The effect of new building permits on rents was less clear, perhaps due to sample size issues, but the overall effect of new housing on rents was moderately negative. The effects were calculated using a standard multivariate linear regression model.

## Data 
This analysis uses the following data:
- Building permit data for every county in a Census Bureau Statistical Area (CBSA) in the United States from from 2015 through 2022. The data can be accessed in CSV form through [this webpage.](https://www2.census.gov/econ/bps/County/)
  The links marked with an "a" before the file extension pertain to full years.
- Population data for every county in the United States that is in a CBSA from 2016 through 2024. The data was sourced from the US Census Bureau on [this page](https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/) for the years 2016 through 2019 (with intercensal population totals from the last link on [this page](https://www2.census.gov/programs-surveys/popest/tables/2010-2020/intercensal/county/), and the first link on [this page](https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/metro/totals/) for 2020 through 2024.
  
- Housing market data from Redfin.  Redfin, the large online brokerage, generously makes highly complete data publicly available for home sales nationwide, and also features a table with asking rents in large multifamily buildings in 41 major metropolitan areas. The Redfin home sales table includes data from 1828 out of 1844 counties in the 2023 Vintage CBSA- missing only five counties from Mississippi (2 CBSAs), one county in Hawai'i with a population estimate of 81 people, and the ten parrishes that make up the Baton Rouge, Louisiana CBSA. These areas are home to roughly 95% of the USA population. The home sales dataset can be found on [this page](https://www.redfin.com/news/data-center/) (the description says there are 43 metro areas in the dataset but there are 41 that actually have asking rent prices).<br>
<br>The rents dataset has data on asking rents for apartments of various sizes in buildings with 25 or more units, from March 2019 through August 2025. I downloaded the rent data as a crosstab from [this page.](https://www.redfin.com/news/data-center/rental-market-data/)

## Methodology
The objective of this study was to establish the relationship between new homebuilding and housing prices. There are many factors that determine the price of housing, but I chose to focus on new housing and population changes, representing supply and demand in a basic economic paradigm. As population changes are strongly correlated with home prices, I needed to control for it in order to best isolate the effect of housing supply on price. I ran a few different versions of a linear regression model featuring the following inputs:
- New housing units permitted per 1000 residents, two years ago
- New single family homes permitted per 1000 residents, two years ago
- New multifamily housing units permitted per 1000 residents, two years ago
- Year-over-year population change
- year-over-year net domestic migration
- year-over-year net international migration
- year-over-year net total migration

I chose to measure building permits issued two years prior simply because I am skeptical that a promised future house affects the price of housing, and two years is a rough estimate of the time from the permit being issued (which is itself quite far along in the process to build a home or development) to the home being ready for someone to move in. Population, as a metric, has the advantage of being very easy to acquire accurate data; it also intuitively makes sense as an estimation of the total demand for housing.

I chose to separate single family and multifamily home construction because I suspect they affect the market in different ways, and I believe that measuring the effects of them seperately has significant usefulness. I included net migration as a subsititute for population growth in the rents model because I hypothesize that demand for apartments is more sensitive to migration than to natural population change through births and deaths.

I measured prices as the year-over-year changes in price per square foot for home sales, and the year-over-year change in 2-bedroom asking rent for rents.
In the linear regression models, I used scales for each input and output to measure how the relative change in each input, measured in standard deviations, affected the output. 

For the home sales models, I measured only the metro areas with populations over 500,000 people (measured in 2024) to avoid the result becoming undesirably noisy. I also omitted metro areas in Connecticut because the state reconsituted its county equivalents during the timespan I measured, and Redfin did not have the granularity requred to measure them correctly. My models covered the 128 largest metro areas in the USA.

## Results
For each of housing sale prices and rents, I produced a linear model for each individual year as well as for the entire timespan measured.<br><br>

<img width="1002" height="501" alt="Table 1" src="https://github.com/user-attachments/assets/764ae98e-91e8-43d4-9e84-ef1d04d069de" /><br><br>

Table 1 shows the effects of single family home and multifamily construction on home prices for each year 2018 through 2024 (n = 128). Population has a positive effect for all years, statistically significant in all but 1. 
New single family homes had a negative relationship with home prices in all but one year in the dataset, statisitically significant in 3 of 7 years. 
Multifamily units had a negative relationship with home prices in all but 2 years in the dataset, and all 5 of the negative relationships were statistically significant.

The adjusted R-squared values for the annual splits ranged from .164 in 2020 to .619 in 2022.<br><br> 

<img width="242" height="350" alt="Table 2" src="https://github.com/user-attachments/assets/8df77115-5e28-4480-b0e9-8f1e4b83490e" /><br>

Table 2 contains the overall relationship between these metrics and home prices for the entire period between 2018 and 2024. The result shows a statistically signigicant negative relationship between new multifamily units and home sale prices, and a significant positive relationship between population growth and prices. 
However, the adjusted R-squared value for this cumulative table is quite low, indicating that the effects were distinct between different years.<br><br>

<img width="504" height="350" alt="Table 3" src="https://github.com/user-attachments/assets/519e827f-e60c-44e9-b4be-48c9c27d698e" /><br><br>

Table 3 shows the effects of single family home and multifamily construction on asking rents from 2020 to 2024 (n = 41). Population has a positive effect in all 5 years, statistically significant in 3 of 5. New single family homes have a negative relationship with asking rents in all 5 years, statistically significant in 2 of 5. 

New multifamily units had a mixed relationship with asking rents in this study. 3 of the years showed a statistically insignificant effect, while there was a significant negative relationship in 2020 and a significant positive relationship in 2024. <br><br>

<img width="242" height="350" alt="Table 4" src="https://github.com/user-attachments/assets/9380c525-9168-476d-b436-809bcc2796ec" /><br><br>

Table 4 shows the effect of these three metrics on asking rents over the entire timespan from 2020 to 2024. Unintuitive results such as a reversed effect from population growth, as well as an adjusted R-squared of .025, suggest that there are effects between years that are drowning out what I attempted to measure.









