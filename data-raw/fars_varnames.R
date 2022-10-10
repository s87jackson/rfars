library(tidyr)
library(dplyr)
library(readr)

fars_varnames <-
  "data-raw/FARS_varnames.csv" %>%
  readr::read_csv(col_names = TRUE) %>%
  mutate(
    original_clean = janitor::make_clean_names(original),
    structure = case_when(
      table %in% c("key") ~ "key",
      table %in% c("accident", "vehicle", "person", "pbtype", "safetyeq") ~ "flat",
      TRUE ~ "multi"
    )) %>%
  select(structure, table, original, original_clean, friendly)

usethis::use_data(fars_varnames, overwrite = TRUE)
