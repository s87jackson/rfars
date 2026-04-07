#' Get FARS data
#'
#' Bring FARS data into the current environment, whether by downloading it anew
#'     or by using pre-existing files.
#'
#' @export
#'
#' @param years Years to be downloaded, in yyyy (character or numeric formats,
#'     defaults to last 10 years).
#' @param states States to keep. Leave as NULL (the default) to keep
#'     all states. Can be specified as full state name (e.g. "Virginia"),
#'     abbreviation ("VA"), or FIPS code (51).
#' @param source The source of the data: 'zenodo' (the default) pulls the prepared
#'    dataset from \href{https://zenodo.org/records/19441135}{Zenodo}, 'nhtsa'
#'    pulls the raw files from \href{https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/}{NHTSA's FTP site} and prepares them on your machine.
#'    'zenodo' is much faster and provides the same dataset produced by using source='nhtsa' but is limited to the most recent 10 years of data.
#' @param proceed Logical, whether or not to proceed with downloading files without
#'     asking for user permission (defaults to FALSE, thus asking permission)
#' @param dir Directory in which to search for or save a 'FARS data' folder. If
#'     NULL (the default), files are downloaded and unzipped to temporary
#'     directories and prepared in memory. Required if cache is specified.
#' @param cache The name of an RDS file to save or use (e.g., 'myFARS.rds').
#'    If the file exists in 'dir', it will be returned directly. If not, data will
#'    be downloaded and an RDS file of this name will be saved in 'dir'. Requires
#'    'dir' to be specified.
#'
#' @return A FARS data object (list of six tibbles: flat, multi_acc,
#'    multi_veh, multi_per, events, and codebook), described below.
#'
#' @details This function provides the FARS database for the specified years and states.
#'    By default, it pulls from a Zenodo repository for speed and memory efficiency.
#'    It can also pull the raw files from NHTSA and process them in memory, or
#'    use an RDS file saved on your machine.
#'
#'    If source = 'nhtsa' and no directory (dir) is specified, SAS files are downloaded into a
#'    tempdir(), where they are also prepared, combined, and then brought into
#'    the current environment. If you specify a directory (dir), the function will
#'    look there for a 'FARS data' folder. If not found, it will be created and
#'    populated with raw and prepared SAS and RDS files, otherwise the
#'    function makes sure all requested years are present and asks permission
#'    to download any missing years.
#'
#'    The object returned is a list with class 'FARS'. It contains six tibbles:
#'    flat, multi_acc, multi_veh, multi_per, events, and codebook.
#'
#'    Flat files are wide-formatted and presented at the person level.
#'    All \emph{crashes} involve at least one motor \emph{vehicle}, each of
#'    which may contain one or multiple \emph{people}. These are the three
#'    entities of crash data. The flat files therefore repeat some data elements
#'    across multiple rows. Please conduct your analysis with your entity in mind.
#'
#'    Some data elements can include multiple values for any data level
#'    (e.g., multiple weather conditions corresponding to the crash, or multiple
#'    crash factors related to vehicle or person). These elements have been
#'    collected in the yyyy_multi_[acc/veh/per].rds files in long format.
#'    These files contain crash, vehicle, and person identifiers, and two
#'    variables labelled \code{name} and \code{value}. These correspond to
#'    variable names from the raw data files and the corresponding values,
#'    respectively.
#'
#'    The events tibble provides a sequence of events for all vehicles involved
#'    in the crash. See Crash Sequences vignette for an example.
#'
#'    Finally, the codebook tibble serves as a searchable codebook for all files of any given year.
#'
#'    Please review the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813794}{FARS Analytical User's Manual}
#'
#'
#' @examples
#'
#'   \dontrun{
#'     # Use defaults to get 10 years of national data
#'     myFARS <- get_fars()
#'
#'     # Get latest year of data
#'     myFARS <- get_fars(2023)
#'
#'     # Get data for one state
#'     myFARS <- get_fars(states = "VA")
#'   }


get_fars <- function(years   = 2015:2024,
                     states  = NULL,
                     source  = c("zenodo", "nhtsa")[1],
                     proceed = FALSE,
                     dir     = NULL,
                     cache   = NULL
){


  # Validate inputs ----
  if (!source %in% c("zenodo", "nhtsa")) stop("source must be either 'zenodo' or 'nhtsa'")
  source <- match.arg(source)

  if (!is.null(cache) && is.null(dir)) stop("`cache` requires `dir` to be specified.")

  # Check years ----
  ymax <- max(as.numeric(years), na.rm = TRUE)
  ymin <- min(as.numeric(years), na.rm = TRUE)
  if(ymin < 2014) stop("Data not available prior to 2014.")
  if(ymax > 2024) stop("Data not yet available beyond 2024.")


  # Check states ----
  validate_states(states)


  # Find years already on disk ----
  years_found <- character(0)
  if(!is.null(dir)){
    years_found <-
      data.frame(x=list.files(dir, pattern = "_flat.rds", recursive = TRUE)) %>%
      filter(grepl("FARS", x)) %>%
      mutate(x = stringr::word(x, -1, sep="/") %>% stringr::word(1, sep="_")) %>%
      pluck("x")
  }


  # Cache check ----
  if(!is.null(cache) && !is.null(dir)){

    cache_path <- file.path(dir, cache)

    if(file.exists(cache_path)){

      temp <- readRDS(cache_path)
      cached_years <- unique(temp$flat$year)

      if(all(years %in% cached_years)){
        message("Loading cached data from: ", cache_path)
        temp$flat      <- dplyr::filter(temp$flat, year %in% years)
        temp$multi_acc <- dplyr::filter(temp$multi_acc, year %in% years)
        temp$multi_veh <- dplyr::filter(temp$multi_veh, year %in% years)
        temp$multi_per <- dplyr::filter(temp$multi_per, year %in% years)
        temp$events    <- dplyr::filter(temp$events, year %in% years)
        temp$codebook  <- temp$codebook
        return(temp)

      } else {
        missing_yrs <- setdiff(years, cached_years)
        message(
          "Cache found at ", cache_path, " but is missing years: ",
          paste(missing_yrs, collapse = ", "), ". Downloading from ", source, "."
        )
      }

    } else {
      message("Cache file not found. Will save to: ", cache_path, " after download.")
    }

  }


  # Zenodo ----
  if(source == "zenodo"){

    if(!proceed){
      x <- readline("We will now download the processed file from https://zenodo.org/records/19441135/files/FARS_2015-2024.rds?download=1 \nProceed? (Y/N) \n")
      if(!(x %in% c("y", "Y"))) stop(message("Download cancelled.\n"))
    }

    url  <- "https://zenodo.org/records/19441135/files/FARS_2015-2024.rds?download=1"
    dest <- tempfile(fileext = ".rds")

    if (!check_internet_connection()) {
      message("Internet connection not available. Unable to download FARS data from Zenodo.")
      message("Please check your internet connection and try again.")
      return(invisible(NULL))
    }

    download_result <- try(
      downloader::download(url, dest, mode = "wb"),
      silent = TRUE
    )

    if (inherits(download_result, "try-error")) {
      message("Failed to download FARS data from Zenodo.")
      message(paste0("URL attempted: ", url))
      return(invisible(NULL))
    }

    fars_zen <- readRDS(dest)

    # Filter years
    fars_zen$flat      <- dplyr::filter(fars_zen$flat, year %in% years)
    fars_zen$multi_acc <- dplyr::filter(fars_zen$multi_acc, year %in% years)
    fars_zen$multi_veh <- dplyr::filter(fars_zen$multi_veh, year %in% years)
    fars_zen$multi_per <- dplyr::filter(fars_zen$multi_per, year %in% years)
    fars_zen$events    <- dplyr::filter(fars_zen$events, year %in% years)

    # Filter states
    if(!is.null(states)){

      geo_filtered <-
        rfars::geo_relations %>%
        filter(.data$fips_state %in% states | .data$state_name_abbr %in% states | .data$state_name_full %in% states)

      fars_zen$flat <- dplyr::filter(fars_zen$flat, .data$state %in% geo_filtered$state_name_full)

      filter_frame <-
        distinct(fars_zen$flat, .data$year, .data$state, .data$st_case) %>%
        mutate_at("st_case", as.character) %>%
        mutate_at("year", factor)

      fars_zen$multi_acc <- inner_join(fars_zen$multi_acc, filter_frame, by = c("state", "st_case", "year"))
      fars_zen$multi_veh <- inner_join(fars_zen$multi_veh, filter_frame, by = c("state", "st_case", "year"))
      fars_zen$multi_per <- inner_join(fars_zen$multi_per, filter_frame, by = c("state", "st_case", "year"))
      fars_zen$events    <- inner_join(fars_zen$events, filter_frame, by = c("state", "st_case", "year"))

    }

    # Save to cache if requested
    if(!is.null(cache) && !is.null(dir)){
      cache_path <- file.path(dir, cache)
      message("Saving data to cache: ", cache_path)
      saveRDS(fars_zen, cache_path)
    }

    return(fars_zen)

  }


  # NHTSA: download to temp (no persistent dir) ----

  if(is.null(dir)){

    message("No dir specified. Downloading to temporary directory (data will not persist).")

    dest_files <-
      tempdir() %>%
      stringr::str_replace_all(stringr::fixed("\\"), "/") %>%
      stringr::str_c("/FARS data")

    dest_raw   <- paste0(dest_files, "/raw")
    dest_prepd <- paste0(dest_files, "/prepd")

    dir.create(dest_files, showWarnings = FALSE)
    dir.create(dest_raw,   showWarnings = FALSE)
    dir.create(dest_prepd, showWarnings = FALSE)

    download_fars(
      years = years,
      dest_raw = dest_raw,
      dest_prepd = dest_prepd,
      states=states)

    return(
      use_fars(
        dir = dir,
        prepared_dir = dest_prepd,
        cache = cache
      )
    )

  }


  # NHTSA: persistent dir ----

  my_dir <-
    data.frame(path=list.dirs(dir)) %>%
    mutate(folder = stringr::word(.data$path, start = -1, end = -1, sep = "/")) %>%
    filter(.data$folder == "FARS data")

  dest_files <- paste0(dir, "/FARS data")
  dest_raw   <- paste0(dir, "/FARS data/raw")
  dest_prepd <- paste0(dir, "/FARS data/prepd")


  if(nrow(my_dir)==0){ ## No data found ----

    if(!proceed){
      x <- readline("We will now download several files from https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/FARS/ \nProceed? (Y/N) \n")
      if(!(x %in% c("y", "Y"))) stop(message("Download cancelled.\n"))
    }

    dir.create(dest_files, showWarnings = FALSE)
    dir.create(dest_raw,   showWarnings = FALSE)
    dir.create(dest_prepd, showWarnings = FALSE)

    download_fars(years = years, dest_raw = dest_raw, dest_prepd = dest_prepd, states = states)

    return(use_fars(dir = dir, prepared_dir = dest_prepd, cache = cache))

  }


  if(nrow(my_dir)==1){ # Some data found ----

    years_needed  <- setdiff(years, years_found)

    if(length(years_needed) > 0){

      if(!proceed){
        x <-
          paste0(
            paste(years_needed, collapse = ", "),
            " not found in ", dir,
            "\nEnter '1' to download them or any other key to skip") %>%
          readline()
        if(x == "1"){
          download_fars(years = years_needed, dest_raw = dest_raw, dest_prepd = dest_prepd, states=states)
        } else{
          stop("Download cancelled.\n")
        }
      } else{
        message(paste0("Downloading years ", paste(years_needed, collapse = ", ")))
        download_fars(years = years_needed, dest_raw = dest_raw, dest_prepd = dest_prepd, states=states)
      }
    }

    return(use_fars(dir = dir, prepared_dir = dest_prepd, cache = cache))

  }


  if(nrow(my_dir)>1){ #Ambiguous
    stop("Multiple 'FARS data' folders found. Please re-specify the 'dir' parameter.")
  }

}
