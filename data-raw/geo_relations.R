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
    ) %>%
  mutate(
    region = case_when(
      state_name_abbr %in% c("PA", "NJ", "NY", "NH", "VT", "RI", "MA", "ME", "CT") ~ "Northeast (PA, NJ, NY, NH, VT, RI, MA, ME, CT)",
      state_name_abbr %in% c("OH", "IN", "IL", "MI", "WI", "MN", "ND", "SD", "NE", "IA", "MO", "KS") ~ "Midwest (OH, IN, IL, MI, WI, MN, ND, SD, NE, IA, MO, KS)",
      state_name_abbr %in% c("MD", "DE", "DC", "WV", "VA", "KY", "TN", "NC", "SC", "GA", "FL", "AL", "MS", "LA", "AR", "OK", "TX") ~ "South (MD, DE, DC, WV, VA, KY, TN, NC, SC, GA, FL, AL, MS, LA, AR, OK, TX)",
      state_name_abbr %in% c("MT", "ID", "WA", "OR", "CA", "NV", "NM", "AZ", "UT", "CO", "WY", "AK", "HI") ~ "West (MT, ID, WA, OR, CA, NV, NM, AZ, UT, CO, WY, AK, HI)"),
    region_abbr = case_when(
      region == "Northeast (PA, NJ, NY, NH, VT, RI, MA, ME, CT)" ~ "ne",
      region == "Midwest (OH, IN, IL, MI, WI, MN, ND, SD, NE, IA, MO, KS)" ~ "mw",
      region == "South (MD, DE, DC, WV, VA, KY, TN, NC, SC, GA, FL, AL, MS, LA, AR, OK, TX)" ~ "s",
      region == "West (MT, ID, WA, OR, CA, NV, NM, AZ, UT, CO, WY, AK, HI)" ~ "w")

    ) %>%

  mutate_if(is.character, as.factor)

usethis::use_data(geo_relations, overwrite = TRUE)
