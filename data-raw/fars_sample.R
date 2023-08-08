## code to prepare small sample of FARS data

library(tidyr)
library(dplyr)
library(readr)

temp <- rfars::get_fars(years = 2019:2020)

# temp0 <- temp

mysample <-
  temp$flat %>%
  select(year, st_case) %>%
  distinct() %>%
  group_by(year) %>%
  sample_frac(.005) %>%
  pull("st_case")

length(mysample)

temp$flat      <- filter(temp$flat, st_case %in% mysample)
temp$multi_acc <- filter(temp$multi_acc, st_case %in% mysample)
temp$multi_veh <- filter(temp$multi_veh, st_case %in% mysample)
temp$multi_per <- filter(temp$multi_per, st_case %in% mysample)
temp$events    <- filter(temp$events, st_case %in% mysample)

fars_1920_sample <- temp

usethis::use_data(fars_1920_sample, overwrite = TRUE)
