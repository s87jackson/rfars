## code to preserve the full codebooks

library(dplyr)

# If necessary, pull in a fresh codebook

prep_codebook <- function(df){

  return(
    df %>%
      mutate(across(everything(), iconv, from="UTF-8", to="ASCII")) %>%
      group_by_at(-2) %>%
      summarize(years = paste0(year, collapse = ", "), .groups = "drop")
      )
}

fars_codebook <-
  readRDS("FARS data/prepd/codebook.rds") %>%
  prep_codebook()

gescrss_codebook <-
  readRDS("GESCRSS data/prepd/codebook.rds") %>%
  prep_codebook()

# usethis::use_data(fars_codebook, overwrite = TRUE)
# usethis::use_data(gescrss_codebook, overwrite = TRUE)
