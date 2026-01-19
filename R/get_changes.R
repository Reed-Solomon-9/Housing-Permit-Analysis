#-----------------------------------
# Function: get_changes
#-----------------------------------
get_changes <- function(key_value) {

  df <- read_csv(CSV_PATH, show_col_types = FALSE)

  # Ensure there are at least two columns
  if (ncol(df) < 2) {
    abort("CSV must contain at least two columns for key lookup.")
  }

  key_col_1 <- names(df)[1]
  key_col_2 <- names(df)[2]

  # Filter on either key column
  filtered <- df %>%
    filter(
      .data[[key_col_1]] == key_value |
      .data[[key_col_2]] == key_value
    )

  # Error handling
  if (nrow(filtered) == 0) {
    abort("No matching record found for supplied key.")
  }

  if (nrow(filtered) > 1) {
    abort("Multiple records found; expected a unique match.")
  }

  # Select desired columns
  result <- filtered %>%
    select(all_of(COLUMNS_TO_RETURN))

  # Return as named list
  as.list(result)
}
