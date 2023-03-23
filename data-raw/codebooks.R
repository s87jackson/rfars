## code to preserve the full codebooks

library(dplyr)


fars_codebook <-
  readr::read_csv("FARS data/prepd/codebook.csv", show_col_types = FALSE) %>%
  mutate(across(everything(), as.vector)) %>%
  as.data.frame()

gescrss_codebook <-
  readr::read_csv("GESCRSS data/prepd/codebook.csv", show_col_types = FALSE) %>%
  mutate(across(everything(), as.vector)) %>%
  as.data.frame()

usethis::use_data(fars_codebook, overwrite = TRUE)
usethis::use_data(gescrss_codebook, overwrite = TRUE)
