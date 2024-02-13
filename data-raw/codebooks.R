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

# Addressing check note: found 806 marked UTF-8 strings
#
# load("C:/Users/s87ja/Dropbox/Work/toXcel/FARS/rfars/data/fars_codebook.rda")
# load("C:/Users/s87ja/Dropbox/Work/toXcel/FARS/rfars/data/gescrss_codebook.rda")
# load("C:/Users/s87ja/Dropbox/Work/toXcel/FARS/rfars/data/geo_relations.rda")
#
# fars_codebook    <- fars_codebook    %>% mutate(across(everything(), iconv, from="UTF-8", to="ASCII"))
# gescrss_codebook <- gescrss_codebook %>% mutate(across(everything(), iconv, from="UTF-8", to="ASCII"))
# geo_relations    <- geo_relations %>% mutate(across(everything(), iconv, from="UTF-8", to="ASCII"))
#
# usethis::use_data(fars_codebook, overwrite = TRUE)
# usethis::use_data(gescrss_codebook, overwrite = TRUE)
# usethis::use_data(geo_relations, overwrite = TRUE)
