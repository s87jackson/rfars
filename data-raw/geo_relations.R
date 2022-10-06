## code to prepare `geo_relations` dataset

library(tidyr)
library(dplyr)
library(readr)
library(tidycensus)
library(tigris)

temp_county <- tigris::counties(year = 2010) %>% as.data.frame() %>% select(-geometry)
temp_states <- tigris::states(year = 2010) %>% as.data.frame() %>% select(-geometry)

for(i in 1:nrow(temp_states)){

    temp <- tigris::tracts(year = 2010, state = temp_states$STATEFP10[i])

    if(i == 1){
      temp_tracts <- temp
    } else{
      temp_tracts <- bind_rows(temp_tracts, temp)
    }

}

temp_tracts <- temp_tracts %>% as.data.frame() %>% select(-geometry)

geo_relations <-
  temp_county %>%
    select(fips_state = STATEFP10,
           fips_county = COUNTYFP10,
           county_name_abbr = NAME10,
           county_name_full = NAMELSAD10
           ) %>%
    full_join(
      temp_states %>%
        select(fips_state = STATEFP10,
               state_name_abbr = STUSPS10,
               state_name_full = NAME10)
      ) %>%
    full_join(
      temp_tracts %>%
        select(fips_state = STATEFP10,
               fips_county = COUNTYFP10,
               fips_tract = TRACTCE10)
    )

usethis::use_data(geo_relations, overwrite = TRUE)
