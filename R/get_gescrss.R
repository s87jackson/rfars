#' Get GES/CRSS data
#'
#' Bring GES/CRSS data into the current environment, whether by downloading it anew
#'     or by using pre-existing files.
#'
#' @export
#'
#' @param years Years to be downloaded, in yyyy (character or numeric formats,
#'     defaults to last 10 years).
#' @param regions (Optional) Regions to keep: mw=midwest, ne=northeast, s=south, w=west.
#' @param source The source of the data: 'zenodo' (the default) pulls the prepared
#'    dataset from \href{https://doi.org/10.5281/zenodo.17155802}{Zenodo}, 'nhtsa'
#'    pulls the raw files from NHTSA's FTP site and prepares them on your machine.
#'    'zenodo' is much faster and provides the same dataset produced by using source='nhtsa'.
#' @param proceed Logical, whether or not to proceed with downloading files without
#'     asking for user permission (defaults to FALSE, thus asking permission)
#' @param dir Directory in which to search for or save a 'GESCRSS data' folder. If
#'     NULL (the default), files are downloaded and unzipped to temporary
#'     directories and prepared in memory. Ignored if source = 'zenodo'.
#' @param cache The name of an RDS file to save or use. If the specified file (e.g., 'myFARS.rds')
#'    exists in 'dir' it will be returned; if not, an RDS file of this name will be
#'    saved in 'dir' for quick use in subsequent calls. Ignored if source = 'zenodo'.
#'
#' @return A GESCRSS data object (a list with six tibbles: flat, multi_acc,
#'     multi_veh, multi_per, events, and codebook).
#'
#' @details This function provides the GES/CRSS database for the specified years and regions
#'    By default, it pulls from a Zenodo repository for speed and memory efficiency.
#'    It can also pull the raw files from \href{https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/}{NHTSA} and process them in memory, or
#'    use an RDS file saved on your machine.
#'
#'    If source = 'nhtsa' and no directory (dir) is specified, SAS files are downloaded into a
#'    tempdir(), where they are also prepared, combined, and then brought into
#'    the current environment. If you specify a directory (dir), the function will
#'    look there for a 'GESCRSS data' folder. If not found, it will be created and
#'    populated with raw and prepared SAS and RDS files, otherwise the
#'    function makes sure all requested years are present and asks permission
#'    to download any missing years.
#'
#'    The object returned is a list with class 'GESCRSS'. It contains six tibbles:
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
#'    The codebook tibble serves as a searchable codebook for all files of any given year.
#'
#'    Please review the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813707}{CRSS Analytical User's Manual}
#'
#'    Regions are as follows:
#'       mw = Midwest   = OH, IN, IL, MI, WI, MN, ND, SD, NE, IA, MO, KS
#'       ne = Northeast = PA, NJ, NY, NH, VT, RI, MA, ME, CT
#'       s  = South     = MD, DE, DC, WV, VA, KY, TN, NC, SC, GA, FL, AL, MS, LA, AR, OK, TX
#'       w  = West      = MT, ID, WA, OR, CA, NV, NM, AZ, UT, CO, WY, AK, HI
#'
#'
#' @examples
#'
#'   \dontrun{
#'     # Use defaults to get 10 years of national data
#'     myCRSS <- get_gescrss()
#'
#'     # Get latest year of data
#'     myCRSS <- get_gescrss(2023)
#'
#'     # Get data for one region
#'     myCRSS <- get_gescrss(regions = "s")
#'   }

get_gescrss <- function(years     = 2014:2023,
                        regions   = c("mw", "ne", "s", "w"),
                        source  = c("zenodo", "nhtsa"),
                        proceed   = FALSE,
                        dir       = NULL,
                        cache     = NULL
                        ){


  # Check years ----
  ymax <- max(as.numeric(years), na.rm = TRUE)
  ymin <- min(as.numeric(years), na.rm = TRUE)
  if(ymin < 2014) stop("Data not available prior to 2014.")
  if(ymax > 2023) stop("Data not available beyond 2023.")


  # Find years in dir ----
  if(!is.null(dir)){
    years_found <-
      data.frame(x=list.files(dir, pattern = "_flat.rds", recursive = TRUE)) %>%
      filter(grepl("GESCRSS", x)) %>%
      mutate(x = stringr::word(x, -1, sep="/") %>% stringr::word(1, sep="_")) %>%
      pluck("x")
  }


  # Check regions ----
  if(any(!regions %in% c("mw", "ne", "s", "w"))) stop("Specify regions as: mw (midwest), ne (northeast), s (south), w (west).")


  # Zenodo ----
  if(!(source[1] %in% c("zenodo", "nhtsa"))) stop("source must be either 'zenodo' or 'nhtsa'")

  if(source[1]=="zenodo"){

    if(!proceed){
      x <- readline("We will now download the processed file from https://zenodo.org/records/17581418/files/GESCRSS.rds?download=1 \nProceed? (Y/N) \n")
      if(!(x %in% c("y", "Y"))) stop(message("Download cancelled.\n"))
    }

    # Download
    url <- "https://zenodo.org/records/17581418/files/GESCRSS.rds?download=1"
    dest <- tempfile(fileext = ".rds")

    # Check internet connection before attempting download
    if (!check_internet_connection()) {
      message("Internet connection not available. Unable to download GES/CRSS data from Zenodo.")
      message("Please check your internet connection and try again.")
      return(invisible(NULL))
    }

    # Attempt download with error handling
    download_result <- try(
      downloader::download(url, dest, mode = "wb"),
      silent = TRUE
    )

    if (inherits(download_result, "try-error")) {
      message("Failed to download GES/CRSS data from Zenodo.")
      message(paste0("URL attempted: ", url))
      return(invisible(NULL))
    }

    gescrss_zen <- readRDS(dest)

    # Filter years
    gescrss_zen$flat      <- dplyr::filter(gescrss_zen$flat, .data$year %in% years)
    gescrss_zen$multi_acc <- dplyr::filter(gescrss_zen$multi_acc, .data$year %in% years)
    gescrss_zen$multi_veh <- dplyr::filter(gescrss_zen$multi_veh, .data$year %in% years)
    gescrss_zen$multi_per <- dplyr::filter(gescrss_zen$multi_per, .data$year %in% years)
    gescrss_zen$events    <- dplyr::filter(gescrss_zen$events, .data$year %in% years)

    # Filter regions
    if(!is.null(regions)){

      myregions <-
        rfars::geo_relations %>%
        filter(.data$region_abbr %in% regions) %>%
        pull("region") %>%
        unique()

      gescrss_zen$flat <- dplyr::filter(gescrss_zen$flat, .data$region %in% myregions)

      filter_frame <-
        distinct(gescrss_zen$flat, .data$year, .data$casenum) %>%
        mutate_at("casenum", as.character) %>%
        mutate_at("year", factor)

      gescrss_zen$multi_acc <- inner_join(gescrss_zen$multi_acc, filter_frame, by = c("casenum", "year"))
      gescrss_zen$multi_veh <- inner_join(gescrss_zen$multi_veh, filter_frame, by = c("casenum", "year"))
      gescrss_zen$multi_per <- inner_join(gescrss_zen$multi_per, filter_frame, by = c("casenum", "year"))
      gescrss_zen$events    <- inner_join(gescrss_zen$events, filter_frame, by = c("casenum", "year"))

    }

    return(gescrss_zen)

  }


  # Cached RDS file in dir ----
  if(!is.null(cache) && !is.null(dir) && cache %in% list.files(dir)){

    temp <- readRDS(gsub("//", "/", paste0(dir, "/", cache)))

    if(all(years %in% years_found)){
      temp$flat      <- dplyr::filter(temp$flat, year %in% years)
      temp$multi_acc <- dplyr::filter(temp$multi_acc, year %in% years)
      temp$multi_veh <- dplyr::filter(temp$multi_veh, year %in% years)
      temp$multi_per <- dplyr::filter(temp$multi_per, year %in% years)
      temp$events    <- dplyr::filter(temp$events, year %in% years)
      temp$codebook  <- temp$codebook

      return(temp)

    } else{
      message("Not all years requested exist in cache. Downloading data anew for given years.")
    }

  }


  # Download data without saving or checking hard drive ----

    if(is.null(dir)){

      dest_files <-
        tempdir() %>%
        stringr::str_replace_all(stringr::fixed("\\"), "/") %>%
        stringr::str_c("/GESCRSS data")

      dest_raw   <- paste0(dest_files, "/raw")
      dest_prepd <- paste0(dest_files, "/prepd")

      dir.create(dest_files, showWarnings = FALSE)
      dir.create(dest_raw,   showWarnings = FALSE)
      dir.create(dest_prepd, showWarnings = FALSE)

      download_gescrss(
        years = years,
        dest_raw = dest_raw,
        dest_prepd = dest_prepd,
        regions = regions)

      return(
        use_gescrss(
          dir = dir,
          prepared_dir = dest_prepd,
          cache = cache
          )
        )

    }


  # Look for pre-existing data ----

    if(!is.null(dir)){ #...in this folder

      my_dir <-
        data.frame(path=list.dirs(dir)) %>%
        mutate(folder = stringr::word(.data$path, start = -1, end = -1, sep = "/")) %>%
        filter(.data$folder == "GESCRSS data")

      dest_files <- paste0(dir, "/GESCRSS data")
      dest_raw   <- paste0(dir, "/GESCRSS data/raw")
      dest_prepd <- paste0(dir, "/GESCRSS data/prepd")


      if(nrow(my_dir)==0){ ## No data found ----

        if(!proceed){
          x <- readline("We will now download several files from https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/  \nProceed? (Y/N) \n")
          if(!(x %in% c("y", "Y"))) return(message("Download cancelled.\n"))
        }

        dir.create(dest_files, showWarnings = FALSE)
        dir.create(dest_raw,   showWarnings = FALSE)
        dir.create(dest_prepd, showWarnings = FALSE)

        download_gescrss(years = years, dest_raw = dest_raw, dest_prepd = dest_prepd, regions = regions)

        return(use_gescrss(dir = dir, prepared_dir = dest_prepd, cache = cache))

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
              download_gescrss(years = years, dest_raw = dest_raw, dest_prepd = dest_prepd, regions = regions)
            } else{
              stop("Download cancelled.\n")
            }
           } else{
             message(paste0("Downloading years ", paste(years_needed, collapse = ", ")))
             download_gescrss(years = years_needed, dest_raw = dest_raw, dest_prepd = dest_prepd, regions = regions)
           }
         }

         return(use_gescrss(dir = dir, prepared_dir = dest_prepd, cache = cache))


    }


    if(nrow(my_dir)>1){ #Ambiguous
      stop("Multiple 'GESCRSS data' folders found. Please specify using the 'dir' parameter.")
    }

    }


}
