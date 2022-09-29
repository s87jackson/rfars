library(tidyr)
library(dplyr)
library(rio)


tableList <- rio::import_list("data-raw/Appendix F Changes in Data Elements by Data File and Year.xlsx", setclass = "tbl")

for(i in 1:length(tableList)){

  names(tableList[[i]]) <- paste0(names(tableList)[i], ".", janitor::make_clean_names(names(tableList[[i]])))
  names(tableList[[i]])[1] <- "year"

}

fars_data_changes <- purrr::reduce(tableList, full_join, by="year")

usethis::use_data(fars_data_changes, overwrite = TRUE)
