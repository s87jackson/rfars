library(tidyr)
library(dplyr)
library(readr)

fars_varnames <-
  "data-raw/FARS_varnames.csv" %>%
  readr::read_csv(col_names = TRUE) %>%
  mutate(original_clean = janitor::make_clean_names(original))

usethis::use_data(fars_varnames, overwrite = TRUE)
