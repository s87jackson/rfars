## produce the full codebooks

devtools::load_all()
library(dplyr)

# If necessary, pull in a fresh codebook
myFARS <- get_fars(dir = getwd(), cache = "myFARS.rds", proceed = T)
myCRSS <- get_gescrss(dir = getwd(), cache = "myGESCRSS.rds", proceed = T)

# Grab the definitions tables
source("data-raw/data_definitions.R")

# Combine and save
fars_codebook <-
  readRDS("FARS data/prepd/codebook.rds") %>%
  mutate(across(everything(), iconv, from="UTF-8", to="ASCII")) %>%
  left_join(fars_defs, by = "name_ncsa") %>%
  relocate(all_of(c("Definition", "Additional Information")), .after = "label")


gescrss_codebook <-
  readRDS("GESCRSS data/prepd/codebook.rds") %>%
  mutate(across(everything(), iconv, from="UTF-8", to="ASCII")) %>%
  left_join(crss_defs, by = "name_ncsa") %>%
  relocate(all_of(c("Definition", "Additional Information")), .after = "label")

usethis::use_data(fars_codebook, overwrite = TRUE)
usethis::use_data(gescrss_codebook, overwrite = TRUE)
