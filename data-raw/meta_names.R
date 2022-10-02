## code to prepare `rural_pct` dataset

library(tidyr)
library(dplyr)
library(readr)

meta_names <-
  "data-raw/FARS_varnames.csv" %>%
  readr::read_csv(col_names = TRUE) %>%
  mutate(original_clean = janitor::make_clean_names(original))

usethis::use_data(meta_names, overwrite = TRUE)
