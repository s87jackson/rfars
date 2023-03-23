#' (Internal) Download GES/CRSS data files
#'
#' Download files from NHTSA, unzip, and prepare them.
#'
#' @param years Years to be downloaded, in yyyy (character or numeric formats)
#' @param dest_raw Directory to store raw CSV files
#' @param dest_prepd Directory to store prepared CSV files
#' @param regions (Optional) Inherits from get_gescrss()
#'
#' @return Nothing directly to the current environment. Various CSV files are stored either in a temporary directory or dir as specified by the user.
#'
#' @details Raw files are downloaded from \href{https://static.nhtsa.gov/nhtsa/downloads/GES/}{GES} (2011-2015) and \href{https://static.nhtsa.gov/nhtsa/downloads/CRSS/}{CRSS} (2016-2020).


download_gescrss <- function(years,
                             dest_raw,
                             dest_prepd,
                             regions){

  for(y in years){

    dest_zip   <- tempfile() # creates and stores the name for where the zip file will be downloaded to

    dest_raw_y <- paste0(dest_raw, "/", y)

    my_url <- dplyr::case_when(
      y %in% 2016:2020 ~ paste0("https://static.nhtsa.gov/nhtsa/downloads/CRSS/", y, "/CRSS", y, "SAS.zip"),
      y == 2015        ~ paste0("https://static.nhtsa.gov/nhtsa/downloads/GES/GES", y-2000, "/GES", y, "sas.zip"),
      y == 2014        ~ paste0("https://static.nhtsa.gov/nhtsa/downloads/GES/GES", y-2000, "/GES", y, "SAS.zip"),
      y %in% 2011:2013 ~ paste0("https://static.nhtsa.gov/nhtsa/downloads/GES/GES", y-2000, "/GES", y-2000, "_PCSAS.zip"),
      TRUE             ~ "invalid year")

    try_my_url <- try(
      expr = downloader::download(my_url, destfile=dest_zip, mode="wb"),
      silent = TRUE)

    if(inherits(try_my_url, "try-error")){
      message(paste0("Failed to download data for year ", y)) # is this necessary? Maybe a different message
      next
    } else{

      utils::unzip(dest_zip, exdir = dest_raw_y, overwrite = TRUE)
      unlink(dest_zip)

      # Get list of raw data files
        rawfiles <-
          data.frame(filename = list.files(dest_raw_y)) %>%
          dplyr::mutate(
            type = stringr::word(.data$filename, start = -1, end = -1, sep = stringr::fixed(".")) %>% stringr::str_to_upper(),
            cleaned  = .data$filename %>%
              stringr::str_to_lower() %>%
              stringr::str_remove(".csv") %>%
              stringr::str_remove(".sas7bdat") %>%
              stringr::str_remove(".sas") %>%
              stringr::str_remove(".txt")
            ) %>%
          filter(stringr::str_to_upper(.data$type) %in% c("SAS7BDAT", "SAS"))


    # Fix dest_raw_y, dest_prepd
      if(substr(dest_raw_y, nchar(dest_raw_y), nchar(dest_raw_y)) != "/") dest_raw_y <- paste0(dest_raw_y, "/")
      if(substr(dest_prepd, nchar(dest_prepd), nchar(dest_prepd)) != "/") dest_prepd <- paste0(dest_prepd, "/")


    # Prep each file, producing annual CSVs
      prep_gescrss(y = y, wd = dest_raw_y, rawfiles = rawfiles, prepared_dir = dest_prepd, regions = regions)

    # Compile the codebook
      full_codebook <-
        dir(dest_raw, pattern = "codebook.rds", recursive=TRUE, full.names=TRUE) %>%
        map_dfr(readRDS) %>%
        distinct()

      saveRDS(full_codebook, paste0(dest_prepd, "codebook.rds"))

    }

    }

}
