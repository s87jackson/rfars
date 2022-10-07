#' Internal function that takes care of basic CSV reading

read_basic_csv <- function(x, wd, rawfiles){

  readr::read_csv(
    paste0(wd, rawfiles$filename[rawfiles$cleaned==x]),
    col_types = cols(),
    show_col_types = FALSE
    ) %>%
  janitor::clean_names() %>%
  usenames() %>%
  return()

}
