library(tidyr)
library(dplyr)


fars_data_structure <-
  readxl::read_excel("data-raw/data structure.xlsx") %>%
  filter(is.na(exclude)) %>%
  select(-exclude)


usethis::use_data(fars_data_structure, overwrite = TRUE)

