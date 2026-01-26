# Home Prices Rise Slower In Markets That Build Housing

This study analyzes market shifts across a seven-year period (2018–2024) and, controlling for population growth, quantifies how new construction directly moderates price appreciation. The results reveal a trend: in five of the last seven years, the addition of a single multifamily unit per thousand residents correlated with a 1% to 2% nominal decrease in the growth rate of price per square foot.

The analysis also highlights the nuance of housing types and market cycles. While multifamily units showed a consistent cooling effect, the impact of single-family permits was more specialized, reaching statistical significance in three of the seven years studied. The effect of both single family and multifamily housing was reversed in 2021, a unique year where home prices exploded by over 17% nationwide; and when the COVID-19 pandemic, fiscal stimulus, and a period of expansionary monetary policy were likely sources of omitted variable bias.

This analysis adds to the growing body of evidence demonstrating that building more new housing is the clear and straightforward solution to the housing affordability problem that has become the single biggest economic issue facing young families, and Americans trying to start families.<br><br>

<img width="2400" height="1050" alt="price_forest_plot" src="https://github.com/user-attachments/assets/878b533b-2597-4596-9422-679897c93e91" /><br><br>

The forest plot above illustrates the effect of new single family homes, multifamily units, and population growth on home prices. This study measures new housing units through building permits issued two years prior. This choice allows for accurate estimates of new housing inventory, and avoids simultaneity bias by using population at the time of permit issuance as the denominator.<br><br>

There is reason to believe that 2021 was a singular year for home prices, and that the positive relationship in this model for that year is a historical anomaly. For example, home prices increased massively nationwide in 2021 compared to other years within the timespan covered by Redfin housing data, for all counties as well as for large metro areas:

<img width="900" height="556" alt="Nationwide Annual Change, Home Price Per Square Foot" src="https://github.com/user-attachments/assets/40c54ee3-c619-4e22-a3ae-a5aa4f7808e7" />

While the "cooling effect" of new construction is most pronounced in home sales, a similar trend persists in the rental market. My analysis of asking rents for two-bedroom apartments reveals a consistent, though more moderate, negative correlation with new multifamily permits.

<img width="2400" height="1050" alt="rent_forest_plot" src="https://github.com/user-attachments/assets/b289d40f-0c3f-4e9b-93ea-07b27424756e" /><br><br>

The model shows a negative relationship between new single family homes and asking rents, though it would benefit from a larger sample, in terms of both years and number of markets (n = 41).

**Data Sources:** Housing market statistics provided by Redfin Data Center. Population and building permit data sourced from the U.S. Census Bureau Population Estimates Program (PEP) and Building Permits Survey (BPS).<br>


### Methodology & Technical Implementation Highlights

**Data Orchestration**<br>
SQL (PostgreSQL): Performed high-volume joins between Redfin’s weekly market TSVs and US Census Bureau population datasets. Developed custom cleaning scripts to resolve geographic naming mismatches across different data vintages (2013 vs. 2023).

Google Sheets: Engineered a functional unpivoting logic using REDUCE and LAMBDA to transform decade-wide Census tables into a relational "long" format for time-series analysis. Applied array and filtering logic to allow for reliable integration of future data.

**Econometric Design**<br>
Endogeneity & Simultaneity: Mitigated simultaneity bias by utilizing lagged independent variables (t-2). This ensures the model captures the supply-side impact of building permits on future prices, rather than current price growth driving immediate permitting activity. 

Variable Normalization: To ensure comparability across market sizes, all housing permits were scaled to units per 1,000 residents. Conducted robustness checks by splitting the analysis into yearly cross-sections (2018–2024), accounting for time-varying macroeconomic shocks such as interest rate volatility and the 2021 demand spike.

Back-Transformation: Used a custom R function to convert standardized Z-score coefficients back into nominal percentage points, ensuring the findings were interpretable for non-technical stakeholders.

**Model Integrity**<br>
Outlier Management: Utilized SQL window functions to identify and remove price-per-square-foot anomalies (5x regional mean) that would have biased the regression slopes.

Significance Testing: Applied the modelsummary and fixest packages in R to generate LaTeX-formatted tables with consistent standard error reporting and significance stars.

**Next Steps**<br>
U.S. Census population data for 2025 will be released in the coming weeks, and this will allow me to include 2025 in this analysis. As there is negative raw correlation between new homes built two years prior (2023) and 2025 home prices, it is likely that this inclusion will make the overall result more robust. A clearer picture of what causes home prices to change could also be discovered through adding metrics such as income.

Full technical documentation and code for this analysis is available in the GitHub [repository](https://github.com/Reed-Solomon-9/Housing-Permit-Analysis), and other relevant data is located in my Google Sheets [workbook](https://docs.google.com/spreadsheets/d/1iMcNK9optOYsxhKkWHpMaFekGg6laP4Bg2kJylIvdTc/edit?gid=588298634#gid=588298634).
