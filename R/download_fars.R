#' Download FARS data files
#'
#' Download annual files directly from NHTSA and unzip them
#'     into a newly created ~/FARS data/raw directory.
#'
#' @param years Years to be downloaded, in yyyy (character or numeric formats)
#' @param dest_raw Directory to store raw CSV files
#' @param dest_prepd Directory to store prepared CSV file
#'
#' @return Nothing, called for side effects.
#'
#' @details Raw files are downloaded from \href{https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/FARS/}{NHTSA}.
#'
#' @examples
#' \dontrun{
#' download_fars(c("2019", "2020"))
#' download_fars(2011:2020, proceed=TRUE)
#' }


download_fars <- function(years,
                          dest_raw,
                          dest_prepd){

  for(y in years){

    dest_zip   <- tempfile() # creates and stores the name for where the zip file will be downloaded to

    dest_raw_y <- paste0(dest_raw, "/", y)

    my_url <- paste0(
      "https://static.nhtsa.gov/nhtsa/downloads/FARS/", y,
      "/National/FARS", y,
      "NationalCSV.zip")

    try_my_url <- try(
      expr = downloader::download(my_url, destfile=dest_zip, mode="wb"),
      silent = TRUE)

    if(inherits(try_my_url, "try-error")){

      message(paste0("Invalid value for year: ", y))
      next

    } else{

      utils::unzip(dest_zip, exdir = dest_raw_y, overwrite = TRUE)
      unlink(dest_zip)


      # Get list of raw data files
        rawfiles <-
          data.frame(filename = list.files(dest_raw_y)) %>%
          mutate(
            type = stringr::word(.data$filename, start = -1, end = -1, sep = stringr::fixed(".")),
            cleaned  = .data$filename %>%
              stringr::str_to_lower() %>%
              stringr::str_remove(".csv") %>%
              stringr::str_remove(".sas7bdat")
            ) %>%
          filter(stringr::str_to_upper(.data$type) == "CSV")

      # Year-specific import-then-export-CSV functions
        if(y==2020)          prep_fars_2020(y = y, wd = dest_raw_y, rawfiles = rawfiles, prepared_dir = dest_prepd)
        if(y==2019)          prep_fars_2019(y, dest_raw_y, rawfiles, dest_prepd)
        if(y==2018)          prep_fars_2018(y, dest_raw_y, rawfiles, dest_prepd)
        if(y %in% 2016:2017) prep_fars_2017(y, dest_raw_y, rawfiles, dest_prepd)
        if(y %in% 2014:2015) prep_fars_2015(y, dest_raw_y, rawfiles, dest_prepd)

    }

    }



}
