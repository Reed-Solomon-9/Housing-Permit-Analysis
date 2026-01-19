library(googlesheets4)
library(dplyr)
library(janitor)
library(sjPlot)
library(broom)
library(stargazer)
library(modelsummary)
library(webshot2)
library(readr)

gs4_auth()

# Load final housing sale price and rent tables
sheet_url <- "https://docs.google.com/spreadsheets/d/1iMcNK9optOYsxhKkWHpMaFekGg6laP4Bg2kJylIvdTc/edit?gid=588298634#gid=588298634"

housing_df_14_25 <- read_sheet(
                               sheet_url,
                               sheet = "Final Table: Sales",
                               range = "A2:M1154") %>%

  clean_names()


expanded_housing_df_14_25 <- read_sheet(
                               sheet_url,
                               sheet = "Final Table: Sales Expanded",
                               range = "A2:M8423") %>%

  clean_names()


rents_df_19_25 <- read_sheet(
                               sheet_url,
                               sheet = "Final Table: Rents",
                               range = "A2:M289") %>%

  clean_names()

# 1: regression with YOY Price Per Square Foot as Y value
# and new units permitted/100 people and YOY population change as X variables.
filtered_t1 <- filter(
  housing_df_14_25,
  !is.na(yoy_ppsf),
  !is.na(pop_yoy)
)

reg_result_table_1 <- filtered_t1 %>%
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
  title = "Multivariate Results by Year",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_1.tex"
)

# 2: YOY Sale price change by 2-years-ago SFH and Multifamily building permits, 
# and population growth.

reg_result_table_2 <- filtered_t1 %>%
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
  coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(pop_yoy)" = "Population Growth"
  ),
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_2.tex"
)

# 11: YOY Sale price change by 2-years-ago SFH and Multifamily building permits, 
# and population growth. This model includes metro areas with a 2024 population of 100,000 or greater.

filtered_t3 <- filter(
  expanded_housing_df_14_25,
  !is.na(yoy_ppsf),
  !is.na(pop_yoy)
)

reg_result_table_11 <- filtered_t3 %>%
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
  coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(pop_yoy)" = "Population Growth"
  ),
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_11.tex"
)


# 3: Regression including domestic and international migration

reg_result_table_3 <- filtered_t1 %>%
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
  title = "Change In Price Per Square Foot, One Year Later, Domestic And International Migration Included",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_3.tex"
)

# 4: Simple regression with only total housing units and net migration
mutated_t1 <- mutate(
  filtered_t1, net_migration = percent_net_dom_migration + percent_net_intl_migration
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
  coef_map = c(
    "scale(units_per_1000)" = "New Housing Units",
    "scale(net_migration)" = "Net Migration"
  ),
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
  coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(net_migration)" = "Net Migration"
  ),
  stars = TRUE,
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_9.tex"
)

# TOTALS: Regression for the total effect for the period from 2015 to 2023,
# rather than grouped by year.

reg_result_table_total_1 <- mutated_t1 %>%
  lm(
    scale(yoy_ppsf) ~
    scale(sfh_per_1000) +
    scale(mf_units_per_1000) +
    scale(net_migration),
    data = .
  )

modelsummary(
  reg_result_table_total_1,
  stars = TRUE,
    coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(net_migration)" = "Net Migration"
  ),
  title = "Change In Price Per Square Foot, One Year Later",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_total_1.tex"
)

# TOTALS 2: Domestic and int'l migration included

reg_result_table_total_2 <- filtered_total %>%
  lm(
    scale(yoy_ppsf) ~
    scale(sfh_per_1000) +
    scale(mf_units_per_1000) +
    scale(pop_yoy),
#    scale(percent_domestic_migration) +
#    scale(percent_intl_migration),
    data = .
  )

modelsummary(
  reg_result_table_total_2,
  stars = TRUE,
  title = "Change In Price Per Square Foot, One Year Later",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_total_2.tex"
)

# 5: Regression measuring effect of population and new building permits on 
# asking rents for 2-bedroom apartments, 2019-2025
filtered_t5 <- filter(
  rents_df_19_25,
  !is.na(yoy_rent),
  !is.na(pop_yoy)
)

reg_result_table_5 <- filtered_t5 %>%
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
  coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(pop_yoy)" = "Population Growth"
  ),
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_5.tex"
)

# 6: Population replaced with net migration (The author posits
# that migration may affect rents more than births/deaths)
reg_result_table_6 <- filtered_t5 %>%
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
  coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(percent_net_dom_migration)" = "Domestic Migration",
    "scale(percent_net_intl_migration)" = "International Migration"
  ),
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_6.tex"
)

# 7: Rents model measuring only metro areas with at least 3 multifamily units per 1000 residents added

filtered_t7 <- rents_df_19_25 %>%
filter(
  mf_units_per_1000 > 3,
  !is.na(yoy_rent),
  !is.na(pop_yoy)
)


reg_result_table_7 <- filtered_t7 %>%
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
  coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(percent_net_dom_migration)" = "Domestic Migration",
    "scale(percent_net_intl_migration)" = "International Migration"
  ),
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_7.tex"
)

# 8: Simplified rents model - effect on rents of total units permitted 2 years ago and net migration

mutated_t2 <- mutate(
  filtered_t5, net_migration = percent_net_dom_migration + percent_net_intl_migration
  )

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
  coef_map = c(
    "scale(units_per_1000)" = "New Housing Units",
    "scale(net_migration)" = "Net Migration"
  ),
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
  coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(net_migration)" = "Net Migration"
  ),
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_10.tex"
)