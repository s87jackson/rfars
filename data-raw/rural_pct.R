## code to prepare `rural_pct` dataset

library(tidyr)
library(dplyr)
library(readr)

rural_pct <-
  read_csv("data-raw/rural_pct.csv",
           #col_types = cols(.default = "c"),
           col_names = c("FIPS", "pop2010_total", "pop2010_urban",
                         "pop2010_rural", "pop2010_rural_pct"),
           skip = 1
           ) %>%
  mutate(FIPS = as.character(FIPS) %>% stringr::str_pad(5, "left", "0"))

usethis::use_data(rural_pct, overwrite = TRUE)
