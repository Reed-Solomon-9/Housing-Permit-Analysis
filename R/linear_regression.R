library(googlesheets4)
library(dplyr)
library(janitor)
library(sjPlot)
library(broom)
library(stargazer)
library(modelsummary)
library(webshot2)
library(readr)
library(fixest)

gs4_auth()

# Load final housing sale price and rent tables, filter out null values, add a column for combined net migration.
sheet_url <- "https://docs.google.com/spreadsheets/d/1iMcNK9optOYsxhKkWHpMaFekGg6laP4Bg2kJylIvdTc/edit?gid=588298634#gid=588298634"

sales_df_14_25 <- read_sheet(
                               sheet_url,
                               sheet = "Final Table: Sales",
                               range = "A2:O1154") %>%

  clean_names() %>%

  filter(
    .,
    !is.na(yoy_ppsf),
    !is.na(pop_yoy)
  ) %>%

  mutate(
  sales_df_14_25, net_migration = percent_net_dom_migration + percent_net_intl_migration
  )
   
expanded_sales_df_14_25 <- read_sheet(
                               sheet_url,
                               sheet = "Final Table: Sales Expanded",
                               range = "A2:M8423") %>%

  clean_names() %>%

  filter(.,
    !is.na(yoy_ppsf),
    !is.na(pop_yoy)
  )

rents_df_19_25 <- read_sheet(
                               sheet_url,
                               sheet = "Final Table: Rents",
                               range = "A2:O289") %>%

  clean_names() %>%

  filter(.,
    !is.na(yoy_rent),
    !is.na(pop_yoy)
  ) %>%

  mutate(., 
    net_migration = percent_net_dom_migration + percent_net_intl_migration
  )


# Name coefficients for model variables
named_coefs <- c(
  "scale(units_per_1000)" = "New Housing Units",
  "scale(sfh_per_1000)" = "New Single Family Homes",
  "scale(mf_units_per_1000)" = "New Multifamily Units",
  "scale(pop_yoy)" = "Population Growth",
  "scale(percent_net_dom_migration)" = "Domestic Migration",
  "scale(percent_net_intl_migration)" = "International Migration",
  "scale(net_migration)" = "Net Migration",
  "scale(yoy_mortgage_rate_change)" = "Change in Mortgage Rate",

  "std_sfh_per_1000" = "New Single Family Homes",
  "std_sfh_squared" = "New Single Family Homes Squared",
  "std_mf_units_per_1000" = "New Multifamily Units",
  "std_mf_squared" = "New Multifamily Units Squared",
  "std_pop_yoy" = "Population Growth",
  "std_yoy_mortgage_rate_change" = "Change in Mortgage Rate"
)  

# Get standard deviations for important columns for each of the three tables

# For Sales table:
sd_sales_price <- sd(sales_df_14_25$yoy_ppsf, na.rm = TRUE)
sd_sales_all_units <- sd(sales_df_14_25$units_per_1000, na.rm = TRUE)
sd_sales_sfh_units <- sd(sales_df_14_25$sfh_per_1000, na.rm = TRUE)
sd_sales_mf_units <- sd(sales_df_14_25$mf_units_per_1000, na.rm = TRUE)
sd_sales_pop_change <- sd(sales_df_14_25$pop_yoy, na.rm = TRUE)
sd_sales_dom_mig <- sd(sales_df_14_25$percent_net_dom_migration, na.rm = TRUE)
sd_sales_intl_mig <- sd(sales_df_14_25$percent_net_intl_migration, na.rm = TRUE)
sd_sales_mortgage <- sd(sales_df_14_25$net_migration, na.rm = TRUE)

# For Rents table:
sd_rents_price <- sd(rents_df_19_25$yoy_ppsf, na.rm = TRUE)
sd_rents_all_units <- sd(rents_df_19_25$units_per_1000, na.rm = TRUE)
sd_rents_sfh_units <- sd(rents_df_19_25$sfh_per_1000, na.rm = TRUE)
sd_rents_mf_units <- sd(rents_df_19_25$mf_units_per_1000, na.rm = TRUE)
sd_rents_pop_change <- sd(rents_df_19_25$pop_yoy, na.rm = TRUE)
sd_rents_dom_mig <- sd(rents_df_19_25$percent_net_dom_migration, na.rm = TRUE)
sd_rents_intl_mig <- sd(rents_df_19_25$percent_net_intl_migration, na.rm = TRUE)
sd_rents_mortgage <- sd(rents_df_19_25$net_migration, na.rm = TRUE)

# For Expanded Sales table:
sd_exp_sales_price <- sd(expanded_sales_df_14_25$yoy_ppsf, na.rm = TRUE)
sd_exp_sales_all_units <- sd(expanded_sales_df_14_25$units_per_1000, na.rm = TRUE)
sd_exp_sales_sfh_units <- sd(expanded_sales_df_14_25$sfh_per_1000, na.rm = TRUE)
sd_exp_sales_mf_units <- sd(expanded_sales_df_14_25$mf_units_per_1000, na.rm = TRUE)
sd_exp_sales_pop_change <- sd(expanded_sales_df_14_25$pop_yoy, na.rm = TRUE)
sd_exp_sales_dom_mig <- sd(expanded_sales_df_14_25$percent_net_dom_migration, na.rm = TRUE)
sd_exp_sales_intl_mig <- sd(expanded_sales_df_14_25$percent_net_intl_migration, na.rm = TRUE)
sd_exp_sales_mortgage <- sd(expanded_sales_df_14_25$net_migration, na.rm = TRUE)

## Regression Models

# 1: regression with YOY Price Per Square Foot as Y value
# and new units permitted/100 people and YOY population change as X variables.

reg_result_table_1 <- sales_df_14_25 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      yoy_ppsf ~
      units_per_1000 +
      pop_yoy,
      data = .x
    )
  )

modelsummary(
  reg_result_table_1,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Multivariate Results by Year",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_1.tex"
)

# 2: YOY Sale price change by 2-years-ago SFH and Multifamily building permits, 
# and population growth.

reg_result_table_2 <- sales_df_14_25 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_ppsf) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(pop_yoy), data = .x
    )
  )

modelsummary(
  reg_result_table_2,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_2.tex"
)

coefs_2 <- coef(reg_result_table_2)



# 11: YOY Sale price change by 2-years-ago SFH and Multifamily building permits, 
# and population growth. This model includes metro areas with a 2024 population of 100,000 or greater.

reg_result_table_11 <- expanded_sales_df_14_25 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_ppsf) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(pop_yoy), data = .x
    )
  )

modelsummary(
  reg_result_table_11,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_11.tex"
)


# 3: Regression including domestic and international migration

reg_result_table_3 <- sales_df_14_25 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_ppsf) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(pop_yoy) +
      scale(percent_net_dom_migration) +
      scale(percent_net_intl_migration),
      data = .x
    )
  )

modelsummary(
  reg_result_table_3,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Change In Price Per Square Foot, Domestic And International Migration Included",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_3.tex"
)

# 4: Simple regression with only total housing units and net migration
mutated_t1 <- mutate(
  sales_df_14_25, net_migration = percent_net_dom_migration + percent_net_intl_migration
  )

reg_result_table_4 <- mutated_t1 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_ppsf) ~
      scale(units_per_1000) +
      scale(net_migration),
      data = .x
    )
  )

modelsummary(
  reg_result_table_4,
  coef_map = named_coefs,
  stars = TRUE,
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_4.tex"
)


# 9: Regression with SFH and Multifamily Housing and total net migration

reg_result_table_9 <- mutated_t1 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_ppsf) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(net_migration),
      data = .x
    )
  )

modelsummary(
  reg_result_table_9,
  coef_map = named_coefs,
  stars = TRUE,
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_9.tex"
)

# TOTALS 1: Regression for the total effect for the period from 2015 to 2023,
# rather than grouped by year.

reg_result_table_total_1 <- mutated_t1 %>%
  lm(
    scale(yoy_ppsf) ~
    scale(sfh_per_1000) +
    scale(mf_units_per_1000) +
    scale(net_migration) +
    scale(yoy_mortgage_rate_change),
    data = .
  )

modelsummary(
  reg_result_table_total_1,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Yearly Change In Price Per Square Foot, 2018-2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_total_1.tex"
)

# 5: Regression measuring effect of population and new building permits on 
# asking rents for 2-bedroom apartments, 2019-2025

reg_result_table_5 <- rents_df_19_25 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_rent) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(pop_yoy), data = .x
    )
  )

modelsummary(
  reg_result_table_5,
  coef_map = named_coefs,
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_5.tex"
)

# 6: Population replaced with net migration (The author posits
# that migration may affect rents more than births/deaths)
reg_result_table_6 <- rents_df_19_25 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_rent) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(percent_net_dom_migration) +
      scale(percent_net_intl_migration),
      data = .x
    )
  )  

modelsummary(
  reg_result_table_6,
  coef_map = named_coefs,
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_6.tex"
)

# 7: Rents model measuring only metro areas with at least 3 multifamily units per 1000 residents added

filtered_3_plus_mf <- rents_df_19_25 %>%
filter(
  mf_units_per_1000 > 3,
  !is.na(yoy_rent),
  !is.na(pop_yoy)
)

reg_result_table_7 <- filtered_3_plus_mf %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_rent) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(percent_net_dom_migration) +
      scale(percent_net_intl_migration),
      data = .x
    )
  )  

modelsummary(
  reg_result_table_7,
  coef_map = named_coefs,
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_7.tex"
)

# 8: Simplified rents model - effect on rents of total units permitted 2 years ago and net migration

mutated_t2 <- 

reg_result_table_8 <- mutated_t2 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_rent) ~
      scale(units_per_1000) +
      scale(net_migration),
      data = .x
    )
  )  

modelsummary(
  reg_result_table_8,
  coef_map = named_coefs,
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_8.tex"
)

# 10: Rents model with both SFH and Multifamily permits included,
# as well as net migration

reg_result_table_10 <- mutated_t2 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_rent) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(net_migration),
      data = .x
    )
  )  

modelsummary(
  reg_result_table_10,
  coef_map = named_coefs,
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_10.tex"
)


# TOTALS 2: Asking Rents over full timespan

reg_result_table_total_2 <- mutated_t2 %>%
  lm(
    scale(yoy_rent) ~
    scale(sfh_per_1000) +
    scale(mf_units_per_1000) +
    scale(net_migration) +
    scale(yoy_mortgage_rate_change),
    data = .
  )

modelsummary(
  reg_result_table_total_2,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Change In Asking Rents, 2020 - 2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_total_2.tex"
)

# TOTALS 3: PPSF over full timespan, only areas with 10+ new units per 1000 people

reg_result_table_total_3 <- filter(
  sales_df_14_25,
  units_per_1000 > 10,
  !is.na(yoy_ppsf),
  !is.na(pop_yoy)
) %>%

mutate(
  net_migration = (percent_net_dom_migration - percent_net_intl_migration)
) %>%

  lm(
    scale(yoy_ppsf) ~
    scale(sfh_per_1000) +
    scale(mf_units_per_1000) +
    scale(net_migration) +
    scale(yoy_mortgage_rate_change),
    data = .
  )

modelsummary(
  reg_result_table_total_3,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Change In Home Prices, Metro Areas with 10+ New Units Per 1000 Residents, 2018 - 2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_total_3.tex"
)

# TOTALS 4: Nonlinear model for home prices
 
reg_result_table_total_4 <- sales_df_14_25 %>%

mutate(., 
    std_yoy_ppsf = scale(yoy_ppsf),
    std_sfh_per_1000 = scale(sfh_per_1000),
    std_sfh_squared = I(scale(sfh_per_1000)^2),
    std_mf_units_per_1000 = scale(mf_units_per_1000),
    std_mf_squared = I(scale(mf_units_per_1000)^2),
    std_pop_yoy = scale(pop_yoy),
    std_yoy_mortgage_rate_change = scale(yoy_mortgage_rate_change)
) %>%

feols(
    std_yoy_ppsf ~
    std_sfh_per_1000 +
    std_sfh_squared +
    std_mf_units_per_1000 +
    std_mf_squared +
    std_pop_yoy +
    std_yoy_mortgage_rate_change,
    data = .
) %>%

modelsummary(
  .,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Change In Home Prices, Large US Metro Areas, 2018 - 2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_total_4.tex"
)


