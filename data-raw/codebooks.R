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
  #readRDS("FARS data/prepd/codebook.rds") %>%
  myFARS$codebook %>%
  mutate(across(everything(), iconv, from="UTF-8", to="ASCII")) %>%
  left_join(fars_defs, by = "name_ncsa") %>%
  relocate(all_of(c("Definition", "Additional Information")), .after = "label")


gescrss_codebook <-
  #readRDS("GESCRSS data/prepd/codebook.rds") %>%
  myCRSS$codebook %>%
  mutate(across(everything(), iconv, from="UTF-8", to="ASCII")) %>%
  left_join(crss_defs, by = "name_ncsa") %>%
  relocate(all_of(c("Definition", "Additional Information")), .after = "label")

# For uploading to Zenodo
  write_csv(fars_codebook, "fars_codebook.csv")
  write_parquet(fars_codebook, "fars_codebook.parquet")
  write_csv(gescrss_codebook, "gescrss_codebook.csv")
  write_parquet(gescrss_codebook, "gescrss_codebook.parquet")

# For the package
  usethis::use_data(fars_codebook, overwrite = TRUE)
  usethis::use_data(gescrss_codebook, overwrite = TRUE)
