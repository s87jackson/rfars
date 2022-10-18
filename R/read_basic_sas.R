#' Internal function that takes care of basic SAS importing
#'
#' @param x The cleaned name of the data table (CSV).
#' @param wd The working directory for these files
#' @param rawfiles The data frame connecting raw filenames to cleaned ones.

read_basic_sas <- function(x, wd, rawfiles){

  cat_file <- list.files(path = wd, pattern = "formats.sas7bcat",
                              full.names = TRUE, recursive = TRUE)[1]

  # message(cat_file)

  haven::read_sas(
    data_file = paste0(wd, rawfiles$filename[rawfiles$cleaned==x]),
    catalog_file = cat_file
    ) %>%
    mutate_all(haven::as_factor) %>%
  janitor::clean_names() %>%
  return()

}
