library(readr)
library(dplyr)
library(rlang)

#-----------------------------------
# Global configuration
#-----------------------------------
CSV_PATH <- "data/crosswalk_2013_2023_lookup.csv"

COLUMNS_TO_RETURN <- c(
  "summary"
  
)
