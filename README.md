### Project Overview

Data on home prices/rents, new building permits, and population was combined, organized, and modeled in order to quantify the impact of new housing on home prices nationwide. Regression analysis found a 1-2% nominal decrease in home price per square foot for every unit of multifamily housing added in large US metro areas, in 5 out of 7 years studied. The study covers 2018 through 2024, with data integration for 2025 arriving in late Q1 2026 after the release of 2025 US Census population estimates.

### Data 
This study incorporates permit and population data from the US Census Bureau, as well as real estate price data from Redfin, to attempt to establish a statistical relationship between housing construction and prices. The study covers 128 metro areas over the years 2017 through 2024 for sale prices, and 41 large-cap metro areas from 2020 through 2024 for rents. 

Data in this analysis comes from the following sources:
- Building permit data for every county in a Census Bureau Statistical Area (CBSA) in the United States from from 2015 through 2022. The data can be accessed in CSV form through [this webpage.](https://www2.census.gov/econ/bps/County/)
  The links marked with an "a" before the file extension pertain to full years.
- Population data for every county in the United States that is in a CBSA from 2016 through 2024. The data was sourced from the US Census Bureau on [this page](https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/) for the years 2016 through 2019 (with intercensal population totals from the last link on [this page](https://www2.census.gov/programs-surveys/popest/tables/2010-2020/intercensal/county/), and the first link on [this page](https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/metro/totals/) for 2020 through 2024.
  
- Housing market data from Redfin.  Redfin, the large online brokerage, generously makes highly complete data publicly available for home sales nationwide, and also features a table with asking rents in large multifamily buildings in 41 major metropolitan areas. The Redfin home sales table includes data from 1828 out of 1844 counties in the 2023 Vintage CBSA. These areas are home to roughly 95% of the USA population. The home sales dataset can be found on [this page](https://www.redfin.com/news/data-center/) .<br>
<br>The rents dataset has data on asking rents for apartments of various sizes in buildings with 25 or more units, from March 2019 through August 2025. The metro areas in the rents data are organized by the CBSA 2013 vintage. I downloaded the rent data as a crosstab from [this page.](https://www.redfin.com/news/data-center/rental-market-data/)

- Mortgage rate data from Freddie Mac. For the models where years were not split, I included the change in 30-year mortgage rate. This data from FRED, Federal Reserve Bank of St. Louis can be found [here.](https://fred.stlouisfed.org/series/MORTGAGE30US#notes)

The following variables were used in my analysis:

|Variable|Definition|Source|Role
:---|:---|:---|:---
yoy_ppsf|Annual % change in sale Price per sqft|Redfin Data Center|Dependent Variable
yoy_rent|Annual % change in asking rent for 2-bedroom apartments|Redfin Data Center|Dependent Variable
units_per_1000|New permits issued per 1,000 residents|US Census (BPS/PEP)|Independent Variable
sfh_per_1000|New Single Family Home permits issued per 1,000 residents|US Census (BPS/PEP)|Independent Variable
mf_per_1000|New Multifamily permits issued per 1,000 residents (total units added)|US Census (BPS/PEP)|Independent Variable
pop_yoy|Year-over-year % change in population|US Census (PEP)|Control Variable
net_migration|Annual net migration as % of population, international + domestic|US Census (PEP)|Control Variable
yoy_mortgage_rate_change|Annual change in Freddie Mac 30-year mortgage rate|FRED|Control Variable

### Repository Structure
/Regression_Models/: R scripts for running all regression models<br><br>
/SQL/: scripts and support file to transform raw CSV's into usable summary tables for housing price data and nationwide population change<br><br>
/data/: small CSV files used to assist with data cleaning and joining<br><br>
/Visuals/: Visualizations used in the analysis<br><br>
/Streamlined_CBSA_Crosswalk/: R scripts and Shiny app using a lookup table to return list of counties added and subtracted from CBSA's between the 2013 and 2023 vintages<br><br>

### Methodology
There are many factors that determine the price of housing, but I chose to focus on new housing and population changes, representing supply and demand in a basic economic paradigm. As population changes are strongly correlated with home prices, I needed to control for it in order to best isolate the effect of housing supply on price. I ran a few different versions of a linear regression model featuring the inputs outlined above.

A two-year lag was applied to permit data to account for the average duration between permit issuance and inventory completion. Population serves as an estimation of the total demand for housing.

Single family and multifamily home construction were separated because they affect the market in different ways. I included net migration as a subsititute for population growth in the rents model because I hypothesize that demand for apartments is more sensitive to migration than to natural population change through births and deaths.

I measured prices as the year-over-year changes in price per square foot for home sales, and the year-over-year change in 2-bedroom asking rent for rents.
In the linear regression models, I used standardized coefficients for each input and output to measure how the relative change in each input, measured in standard deviations, affected the output. 

For the home sales models, I measured only the metro areas with populations over 500,000 people (measured in 2024) to avoid the result becoming undesirably noisy. My models covered the 128 largest metro areas in the USA.

## Results
For each of housing sale prices and rents, I produced a standardized linear model for each individual year as well as for the entire timespan measured. **Results are expressed in Z-scores.** I later used an R function to unstandardize some of the model results to produce a more legible result, which can be seen in the forest plots in my result summary.<br><br>

<img width="1002" height="501" alt="Table 1" src="https://github.com/user-attachments/assets/764ae98e-91e8-43d4-9e84-ef1d04d069de" /><br><br>

Table 1 shows the effects of single family home and multifamily construction on home prices for each year 2018 through 2024 (n = 128). Population has a positive effect for all years, statistically significant in all but 1. 
New single family homes had a negative relationship with home prices in all but one year in the dataset, statistically significant in 3 of 7 years. 
Multifamily units had a negative relationship with home prices in all but 2 years in the dataset, and all 5 of the negative relationships were statistically significant.

The adjusted R-squared values for the annual splits ranged from .164 in 2020 to .619 in 2022.<br><br> 

<img width="242" height="392" alt="Table 2" src="https://github.com/user-attachments/assets/23295a5e-14d1-40f5-a5f2-da7907661da2" /><br>

Table 2 contains the overall relationship between these metrics and home prices for the entire period between 2018 and 2024. The result shows a statistically signigicant negative relationship between new multifamily units and home sale prices, and a significant positive relationship between population growth and prices. 
However, the adjusted R-squared value for this cumulative table is quite low, indicating that the effects were distinct between different years.<br><br>

I also isolated the metro area-years where over 10 new homes had been built per 1000 residents, and found a substantial cumulative effect in Table 3:

<img width="242" height="405" alt="Table 3" src="https://github.com/user-attachments/assets/d2a5b773-33fe-4dd8-bef6-db17ae62ddeb" /><br>

The sample size is smaller, but the effect of new housing was pronounced in markets where a significant quantity was built.<br><br>

<img width="504" height="350" alt="Table 4" src="https://github.com/user-attachments/assets/8789cf93-8613-448b-a22c-ae641e509101" /><br><br>

Table 4 shows the effects of single family home and multifamily construction on asking rents from 2020 to 2024 (n = 41). Population has a positive effect in all 5 years, statistically significant in 3 of 5. New single family homes have a negative relationship with asking rents in all 5 years, statistically significant in 2 of 5. 

New multifamily units had a mixed relationship with asking rents in this study. 3 of the years showed a statistically insignificant effect, while there was a significant negative relationship in 2020 and a significant positive relationship in 2024. <br><br>

<img width="242" height="392" alt="Table 5" src="https://github.com/user-attachments/assets/eab3401c-c695-4bbe-bd31-7aefd03200db" /><br><br>

Table 5 shows the effect of these three metrics on asking rents over the entire timespan from 2020 to 2024. Unintuitive results such as a reversed effect from population growth, as well as an adjusted R-squared of .025, suggest that there is significant omitted variable bias, and that prices are influenced by year-specific macroeconomic shocks.

That said, there is enough information, particularly in the home sale market, to say that it is likely that there exists a real relationship between increased new housing construction and lower housing prices. 

## Areas To Study Further

Though they appear to explain a significant amount of variation, population and new housing are not the only things that explain housing costs. Data on changes in income by metro area would be useful to include, as well as information about the share of jobs that can be done remotely.

Although the consensus among economists is that it has a minimal effect, I would also like to measure who owns the housing stock in various metro areas- how many homes are owned by large investment companies vs. individuals. I would also like to know how prices affect future population changes and migration. 

It would also be very useful to have more detailed rent data. Information like numbers of each size category in each metro area, as well as rent-price-per-square-foot would allow for more precise conclusions.

## Data Limitations

The data available from Redfin allowed for a comprehensive look at home prices during the specified time period. However, the dataset was missing five counties from Mississippi (2 CBSAs), one county in Hawai'i with a population estimate of 81 people, and the ten parishes that make up the Baton Rouge, Louisiana CBSA. I also had to omit all metro areas in Connecticut, as the state reconstituted its county equivalents during the timespan I measured, and Redfin did not have the granularity requred to measure them correctly. 
The rents dataset was described as featuring asking rents data for 43 US metro areas, but two of them did not contain any rent information.

