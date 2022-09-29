## code to prepare `geo_relations` dataset

library(tidyr)
library(dplyr)
library(readr)

geo_relations <-
  read_csv("data-raw/geo relations 2015.csv",
           col_types = cols(.default = "c")) %>%
  separate(`2015 Geography Name`, c("county_name", "state_name"), sep = ", ", remove = TRUE) %>%
  mutate(
    FIPS = stringr::str_pad(`2015 GEOID`, 5, "left", "0"),
    state_fips = substr(FIPS, 1, 2),
    county_fips = substr(FIPS, 3, 5)
    ) %>%
  select(
    FIPS,
    state_fips,
    county_fips,
    state_abbr = State,
    state_name,
    county_name
    )

usethis::use_data(geo_relations, overwrite = TRUE)
