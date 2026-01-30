# This is an accompanying file for regression_models.R
# It contains display names assigned to each variable in my study, 
# and a custom function to translate regression coefficients from standard deviations
# to raw numbers.

# Name coefficients for model variables
named_coefs <- c(
  "scale(yoy_rent)" = "Yearly Change In Asking Rent",
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
  "std_yoy_mortgage_rate_change" = "Change in Mortgage Rate",

  "yoy_ppsf" = "Yearly Percent Change In Price Per Square Foot",
  "yoy_ppsf_dollars" = "Yearly Change In Price Per Square Foot, Dollars",
  "yoy_rent" = "Yearly Change In Asking Rent",
  "net_migration" = "Net Migration",
  "units_per_1000" = "New Housing Units",
  "pop_yoy" = "Population Growth"
)  

# Function to translate model results expressed as standard deviations back into raw numbers for interpretability
unstandardize_model <- function(mod_std, raw_data) {
  # Handle list of models
  if (inherits(mod_std, "list")) {
    return(lapply(mod_std, unstandardize_model, raw_data = raw_data))
  }
  
  mod_raw <- mod_std
  
  # Standard deviation of dependent variable
  dep_var <- as.character(formula(mod_std)[2])
  clean_y <- gsub("std_|scale\\(|\\)|I\\(|\\^2\\)", "", dep_var)
  sd_y <- sd(raw_data[[clean_y]], na.rm = TRUE)
  message(paste("Checking Y variable:", dep_var, "| SD_Y is:", sd_y))
  
  # Names for each coefficient used in model
  terms <- names(coef(mod_std))
  terms <- terms[terms != "(Intercept)"]

  v_cov <- vcov(mod_raw)
  
  # Perform operation for each coefficient
  for (term in terms) {
    # Regex pattern to include coefficients from quadratic models
    clean_name <- gsub("std_|scale\\(|\\)|I\\(|\\^2\\)", "", term)
    
    # Report progress on cleaning names
    message(paste("Processing term:", term, "-> Cleaned to:", clean_name))

    # Standard deviation of each independent variable
    if (clean_name %in% names(raw_data)) {
      sd_x <- sd(raw_data[[clean_name]], na.rm = TRUE)

      # Calculate ratios for linear or quadratic models
      ratio <- if(grepl("\\^2", term)) sd_y / (sd_x^2) else sd_y / sd_x

      old_var <- v_cov[term, term]

      # Place calculated raw coefficients back into model
      mod_raw$coefficients[term] <- mod_std$coefficients[term] * ratio

      # Variance-Covariance matrix for standard error
      v_cov[term, term] <- old_var * (ratio^2)

      # Multiply coefficients for non-percentage variables by 100 to express coefficient as percentage points
      if (clean_y != "yoy_ppsf_dollars") {
        if (clean_name %in% c("sfh_per_1000", "mf_units_per_1000", "units_per_1000")) {
          mod_raw$coefficients[term] <- mod_raw$coefficients[term] * 100
          v_cov[term, term] <- v_cov[term, term] * (100^2)
          message(paste("Multiplying", term, "into percentage points"))
        }         
      }
      else if (clean_name %in% c("pop_yoy", "yoy_rent", "percent_net_dom_migration", "percent_net_intl_migration", "net_migration", "yoy_mortgage_rate_change")) {
            mod_raw$coefficients[term] <- mod_raw$coefficients[term] / 100
            v_cov[term, term] <- v_cov[term, term] / (100^2)
            message(paste("Dividing", term, "into percentages"))
      }
      message(paste("Term:", term, "| Ratio:", round(ratio, 4)))
      message(paste("   Old Var:", old_var, "-> New Var:", v_cov[term, term]))

      
    } 
  }
  attr(mod_raw, "vcov") <- v_cov

  return(mod_raw)
}

# Colors for consistency across models
year_colors <- c(
  "2018" = "#6366F1", # Indigo 
  "2019" = "#10B981", # Emerald/Green 
  "2020" = "#F59E0B", # Amber/Orange
  "2021" = "#06B6D4", # Cyan/Light Blue
  "2022" = "#3B82F6", # Blue
  "2023" = "#E11D48", # Rose/Red
  "2024" = "#D946EF", # Fuchsia/Pink
  "2025" = "#8B5CF6" # Violet
  )

padding_for_thumbnails <- theme(
  plot.margin = margin(50, 50, 50, 50, "pt"),
  plot.background = element_rect(fill = "white", color = NA)
)