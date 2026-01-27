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
library(here)
library(ggplot2)
library(scales)

source(here("Regression_Models", "model_support.R"))

gs4_auth()

# Load final housing sale price and rent tables, filter out null values, add a column for combined net migration.
sheet_url <- "https://docs.google.com/spreadsheets/d/1iMcNK9optOYsxhKkWHpMaFekGg6laP4Bg2kJylIvdTc/edit?gid=588298634#gid=588298634"

sales_df_14_25 <- read_sheet(
                               sheet_url,
                               sheet = "Final Table: Sales",
                               range = "A2:P1154") %>%

  clean_names() %>%

  filter(
    .,
    !is.na(yoy_ppsf),
    !is.na(pop_yoy)
  ) %>%

  mutate(.,
   net_migration = percent_net_dom_migration + percent_net_intl_migration
  )
   
expanded_sales_df_14_25 <- read_sheet(
                               sheet_url,
                               sheet = "Final Table: Sales Expanded",
                               range = "A2:P8423") %>%

  clean_names() %>%

  filter(.,
    !is.na(yoy_ppsf),
    !is.na(pop_yoy)
  )

rents_df_19_25 <- read_sheet(
                               sheet_url,
                               sheet = "Final Table: Rents",
                               range = "A2:P289") %>%

  clean_names() %>%

  filter(.,
    !is.na(yoy_rent),
    !is.na(pop_yoy)
  ) %>%

  mutate(., 
    net_migration = percent_net_dom_migration + percent_net_intl_migration
  )

rents_all_sizes_df_19_25 <- read_sheet(
                               sheet_url,
                               sheet = "Final Table: Rents All Sizes",
                               range = "A2:R289") %>%

  clean_names() %>%

  filter(.,
    !is.na(yoy_rent),
    !is.na(pop_yoy)
  ) %>%

  mutate(., 
    net_migration = percent_net_dom_migration + percent_net_intl_migration
  ) 

## Regression Models

# 1: regression with YOY Price Per Square Foot as Y value
# and new units permitted/1000 people and YOY population change as X variables.

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

# Translate standardized coefficients back into raw values
raw_table_2 <- unstandardize_model(reg_result_table_2, sales_df_14_25)

modelsummary(
  raw_table_2,
  vcov = function(x) attr(x, "vcov"),
  stars = TRUE,
  coef_map = named_coefs,
  gof_omit = "IC|Log|F",
  title = "Percent Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_2_raw_values.tex"
)

plot2 <- modelplot(raw_table_2, coef_map = named_coefs) +
  geom_vline(xintercept = 0, linetype = "dotted", color = "black", size = 0.8) +
  labs(title = "Estimated Impact on Housing Prices",
       subtitle = "Percentage Point Change In Price Per Square Foot",
       x = "Effect Size (with 95% Confidence Interval)",
       y = ""
       ) +
  scale_color_manual(values = year_colors) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.subtitle = element_text(margin = margin(b = 15)),
    axis.title.x = element_text(margin = margin(t = 15), hjust = 0),
    plot.title = element_text(face = "bold"),
    legend.position = "right"
  ) +
  scale_x_continuous(
    limits = c(-3, 5), 
    breaks = seq(-3, 5, by = 1),
    labels = label_number(suffix = "%")
  )

ggsave(
  filename = here("Visuals", "price_forest_plot.png"),
  plot = plot2,             
  width = 8,            
  height = 5,         
  dpi = 300,          
  bg = "white"      
)

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

reg_result_table_4 <- sales_df_14_25 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_ppsf) ~
      scale(units_per_1000) +
      scale(pop_yoy),
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


raw_table_4 <- unstandardize_model(reg_result_table_4, sales_df_14_25)

modelsummary(
  raw_table_4,
  vcov = function(x) attr(x, "vcov"),
  stars = TRUE,
  coef_map = named_coefs,
  gof_omit = "IC|Log|F",
  title = "Percent Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_4_raw_values.tex"
)

# 9: Regression with SFH and Multifamily Housing and total net migration

reg_result_table_9 <- sales_df_14_25 %>%
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

# TOTALS 1: Regression for the total effect for the period from 2018 to 2024,
# rather than grouped by year.

reg_result_table_total_1 <- sales_df_14_25 %>%
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

raw_totals_table_1 <- unstandardize_model(reg_result_table_total_1, sales_df_14_25)

modelsummary(
  raw_totals_table_1,
  vcov = function(x) attr(x, "vcov"),
  stars = TRUE,
  coef_map = named_coefs,
  gof_omit = "IC|Log|F",
  title = "Yearly Change In Price Per Square Foot, 2018-2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_total_1_raw_values.tex"
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
  title = "Percent Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_5.tex"
)

raw_table_5 <- unstandardize_model(reg_result_table_5, rents_df_19_25)

modelsummary(
  raw_table_5,
  vcov = function(x) attr(x, "vcov"),
  stars = TRUE,
  coef_map = named_coefs,
  gof_omit = "IC|Log|F",
  title = "Percent Change In Asking Rents For 2-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_5_raw_values.tex"
)

plot5 <- modelplot(raw_table_5, coef_map = named_coefs) +
  geom_vline(xintercept = 0, linetype = "dotted", color = "black", size = 0.8) +
  labs(title = "Estimated Impact on 2-Bedroom Asking Rents",
       subtitle = "Percentage Point Change In Asking Rent",
       x = "Effect Size (with 95% Confidence Interval)",
       y = ""
       ) +
  scale_color_manual(values = year_colors) +     
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.subtitle = element_text(margin = margin(b = 15)),
    axis.title.x = element_text(margin = margin(t = 15), hjust = 0),
    plot.title = element_text(face = "bold"),
    legend.position = "right"
  ) +
  scale_x_continuous(
    limits = c(-3, 5), 
    breaks = seq(-3, 5, by = 1),
    labels = label_number(suffix = "%")
  )

ggsave(
  filename = here("Visuals", "rent_forest_plot.png"),
  plot = plot5,             
  width = 8,            
  height = 5,         
  dpi = 300,          
  bg = "white"      
)

# 6: Population replaced with net migration
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

reg_result_table_8 <- rents_df_19_25 %>%
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

reg_result_table_10 <- rents_df_19_25 %>%
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

reg_result_table_total_2 <- rents_df_19_25 %>%
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
    scale(pop_yoy) +
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

raw_table_total_3 <- unstandardize_model(reg_result_table_total_3, sales_df_14_25)

modelsummary(
  raw_table_total_3,
  stars = TRUE,
  vcov = function(x) attr(x, "vcov"),
  coef_map = named_coefs,
  gof_omit = "IC|Log|F",
  title = "Change In Home Prices, Metro Areas with 10+ New Units Per 1000 Residents, 2018 - 2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_total_3_raw_values.tex"
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

# 12: Model replacing percent change in price per square foot with dollar amount

reg_result_table_12 <- sales_df_14_25 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_ppsf_dollars) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(pop_yoy), data = .x
    )
  )

modelsummary(
  reg_result_table_12,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_12.tex"
)

# Translate standardized coefficients back into raw values
raw_table_12 <- unstandardize_model(reg_result_table_12, sales_df_14_25)

modelsummary(
  raw_table_12,
  vcov = function(x) attr(x, "vcov"),
  stars = TRUE,
  coef_map = named_coefs,
  gof_omit = "IC|Log|F",
  title = "Change In Sale Price Per Square Foot, All Homes",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_12_raw_values.tex"
)

# 13: Effect on sales by year of new housing in areas with 10+ new units

reg_result_table_13 <- filter(
  sales_df_14_25,
  units_per_1000 > 10,
  !is.na(yoy_ppsf),
  !is.na(pop_yoy)
) %>%

  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_ppsf) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(pop_yoy),
      data = .x
    )
  )

modelsummary(
  reg_result_table_13,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Change In Home Prices, Metro Areas with 10+ New Units Per 1000 Residents, 2018 - 2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_13.tex"
)

raw_table_13 <- unstandardize_model(reg_result_table_13, sales_df_14_25)

modelsummary(
  raw_table_13,
  stars = TRUE,
  vcov = function(x) attr(x, "vcov"),
  coef_map = named_coefs,
  gof_omit = "IC|Log|F",
  title = "Change In Home Prices, Metro Areas with 10+ New Units Per 1000 Residents, 2018 - 2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_13_raw_values.tex"
)

# 14: Effect on sales by year of new housing in areas with 8+ new units

reg_result_table_14 <- filter(
  sales_df_14_25,
  units_per_1000 > 8,
  !is.na(yoy_ppsf),
  !is.na(pop_yoy)
) %>%

  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_ppsf) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(pop_yoy),
      data = .x
    )
  )

modelsummary(
  reg_result_table_14,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Change In Home Prices, Metro Areas with 8+ New Units Per 1000 Residents, 2018 - 2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_14.tex"
)

raw_table_14 <- unstandardize_model(reg_result_table_14, sales_df_14_25)

modelsummary(
  raw_table_14,
  stars = TRUE,
  vcov = function(x) attr(x, "vcov"),
  coef_map = named_coefs,
  gof_omit = "IC|Log|F",
  title = "Change In Home Prices, Metro Areas with 8+ New Units Per 1000 Residents, 2018 - 2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_14_raw_values.tex"
)

# TOTALS 5: PPSF over full timespan, only areas with 8+ new units per 1000 people

reg_result_table_total_5 <- filter(
  sales_df_14_25,
  units_per_1000 > 8,
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
    scale(pop_yoy) +
    scale(yoy_mortgage_rate_change),
    data = .
  )

modelsummary(
  reg_result_table_total_5,
  stars = TRUE,
  coef_map = named_coefs,
  title = "Change In Home Prices, Metro Areas with 10+ New Units Per 1000 Residents, 2018 - 2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_total_5.tex"
)

raw_table_total_5 <- unstandardize_model(reg_result_table_total_5, sales_df_14_25)

modelsummary(
  raw_table_total_5,
  stars = TRUE,
  vcov = function(x) attr(x, "vcov"),
  coef_map = named_coefs,
  gof_omit = "IC|Log|F",
  title = "Change In Home Prices, Metro Areas with 10+ New Units Per 1000 Residents, 2018 - 2024",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_total_5_raw_values.tex"
)

# 14 Regression measuring effect of population and new building permits on asking rents for 1-Bedroom apartments 

reg_result_table_14 <- rents_all_sizes_df_19_25 %>%
  split(.$year) %>%
  purrr::map(
    ~ lm(
      scale(yoy_rent_1b) ~
      scale(sfh_per_1000) +
      scale(mf_units_per_1000) +
      scale(pop_yoy), data = .x
    )
  )

modelsummary(
  reg_result_table_14,
  coef_map = named_coefs,
  stars = TRUE,
  title = "Percent Change In Asking Rents For 1-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_14.tex"
)

raw_table_14 <- unstandardize_model(reg_result_table_14, rents_all_sizes_df_19_25)

modelsummary(
  raw_table_14,
  vcov = function(x) attr(x, "vcov"),
  stars = TRUE,
  coef_map = named_coefs,
  gof_omit = "IC|Log|F",
  title = "Percent Change In Asking Rents For 1-Bedroom Apartments",
  output = "/Users/reedw.solomon/Data_Folder/Redfin Housing Data/Regression Result Tables/LaTex Files/reg_result_table_14_raw_values.tex"
)