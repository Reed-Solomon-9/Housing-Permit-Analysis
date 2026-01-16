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
                               range = "A2:M1136") %>%

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
      new_units_per_1000_people +
      population_yoy,
      data = .x
    )
  )

print(modelsummary(
  reg_result_table,
  stars = TRUE,
  title = "Multivariate Results by Year",
  output = "latex"
))

# 2: This regression replaces the Y value of year-over-year PPSF
# (price/square foot) with the following year's change.

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

print(modelsummary(
  reg_result_table_2,
  stars = TRUE,
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "latex"
))

# 3: Regression including domestic and international migration

reg_result_table_3 <- filtered_t1 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_ppsf) ~
      scale(sfh_per_1000) +
      scale(new_multifamily_units_1000_people) +
      scale(population_yoy) +
      scale(percent_domestic_migration) +
      scale(percent_intl_migration),
      data = .x
    )
  )

print(modelsummary(
  reg_result_table_3,
  stars = TRUE,
  title = "Change In Price Per Square Foot, One Year Later, Domestic And International Migration Included",
  output = "latex"
))

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

print(modelsummary(
  reg_result_table_4,
  coef_map = c(
    "scale(units_per_1000)" = "New Housing Units",
    "scale(net_migration)" = "Net Migration"
  ),
  stars = TRUE,
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "latex"
))


# TOTALS: Regression for the total effect for the period from 2015 to 2023,
# rather than grouped by year.
filtered_total <- filter(
  housing_df_14_25,
  year >= 2015 | year <= 2023,
  !is.na(yoy_ppsf),
  !is.na(pop_yoy)
)

reg_result_table_total <- filtered_total %>%
  lm(
    scale(yoy_1_ppsf) ~
    scale(new_sfh_1000_people) +
    scale(new_multifamily_units_1000_people) +
    scale(population_yoy),
    data = .
  )

print(modelsummary(
  reg_result_table_total,
  stars = TRUE,
  title = "Change In Price Per Square Foot, One Year Later",
  output = "latex"
))

# TOTALS 2: Domestic and int'l migration included

reg_result_table_total_2 <- filtered_total %>%
  lm(
    scale(yoy_1_ppsf) ~
    scale(new_sfh_1000_people) +
    scale(new_multifamily_units_1000_people) +
    scale(population_yoy),
#    scale(percent_domestic_migration) +
#    scale(percent_intl_migration),
    data = .
  )

print(modelsummary(
  reg_result_table_total_2,
  stars = TRUE,
  title = "Change In Price Per Square Foot, One Year Later",
  output = "latex"
))

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

print(modelsummary(
  reg_result_table_5,
  coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(percent_net_dom_migration)" = "Domestic Migration",
    "scale(percent_net_intl_migration)" = "International Migration"
  ),
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "latex"
))

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

print(modelsummary(
  reg_result_table_6,
  coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(percent_net_dom_migration)" = "Domestic Migration",
    "scale(percent_net_intl_migration)" = "International Migration"
  ),
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "latex"
))

# 7: Model measuring only metro areas with at least 5 multifamily units per 1000 residents added

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

print(modelsummary(
  reg_result_table_7,
  coef_map = c(
    "scale(sfh_per_1000)" = "New Single Family Homes",
    "scale(mf_units_per_1000)" = "New Multifamily Units",
    "scale(percent_net_dom_migration)" = "Domestic Migration",
    "scale(percent_net_intl_migration)" = "International Migration"
  ),
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "latex"
))

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

print(modelsummary(
  reg_result_table_8,
  coef_map = c(
    "scale(units_per_1000)" = "New Housing Units",
    "scale(net_migration)" = "Net Migration"
  ),
  stars = TRUE,
  title = "Change In Asking Rents For 2-Bedroom Apartments",
  output = "latex"
))
