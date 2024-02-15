## code to preserve the full codebooks

library(dplyr)

# If necessary, pull in a fresh codebook
#
# fars_codebook <-
#   readr::read_csv("FARS data/prepd/codebook.csv", show_col_types = FALSE) %>%
#   mutate(across(everything(), as.vector)) %>%
#   as.data.frame()
#
# gescrss_codebook <-
#   readr::read_csv("GESCRSS data/prepd/codebook.csv", show_col_types = FALSE) %>%
#   mutate(across(everything(), as.vector)) %>%
#   as.data.frame()
#
# usethis::use_data(fars_codebook, overwrite = TRUE)
# usethis::use_data(gescrss_codebook, overwrite = TRUE)



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



# Making these data files more compact
#
# load("data/fars_codebook.rda")
# load("data/gescrss_codebook.rda")
#
# fars_codebook <-
#   fars_codebook %>%
#   group_by_at(-2) %>%
#   summarize(years = paste0(year, collapse = ", "), .groups = "drop")
#
# gescrss_codebook <-
#   gescrss_codebook %>%
#   group_by_at(-2) %>%
#   summarize(years = paste0(year, collapse = ", "), .groups = "drop")
#
# usethis::use_data(fars_codebook, overwrite = TRUE)
# usethis::use_data(gescrss_codebook, overwrite = TRUE)



# Remove VPIC MODEL
#
# load("data/fars_codebook.rda")
# load("data/gescrss_codebook.rda")
#
# fars_codebook <- filter(fars_codebook, label != "vPIC Model")
# gescrss_codebook <- filter(gescrss_codebook, label != "vPIC Model")
#
# usethis::use_data(fars_codebook, overwrite = TRUE)
# usethis::use_data(gescrss_codebook, overwrite = TRUE)
