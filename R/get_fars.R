#' Get FARS data
#'
#' Bring FARS data into the current environment, whether by downloading it anew
#'     or by using pre-existing files.
#'
#' @export
#'
#' @param years Years to be downloaded, in yyyy (character or numeric formats),
#'     currently limited to 2015-2020 (the default).
#' @param states (Optional) States to keep. Leave as NULL (the default) to keep
#'     all states. Can be specified as full state name (e.g. "Virginia"),
#'     abbreviation ("VA"), or FIPS code (51).
#' @param dir Directory in which to search for or save a 'FARS data' folder. If
#'     NULL (the default), files are downloaded and unzipped to temporary
#'     directories and prepared in memory.
#' @param proceed Logical, whether or not to proceed with downloading files without
#'     asking for user permission (defaults to FALSE, thus asking permission)
#'
#' @return A FARS data object (a list with five tibbles: flat, multi_acc,
#'     multi_veh, multi_per, events)
#'
#' @details This function downloads raw data from \href{https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/FARS/}{NHTSA}.
#'    If no directory (dir) is specified, raw CSV files are downloaded into the
#'    tempdir(), where they are also prepared, combined, and then brought into
#'    the current environment. If you specify a directory (dir), the function will
#'    look there for a 'FARS data' folder. If not found, it will be created and
#'    populated with raw and prepared CSV files. If the directory is found, the
#'    function makes sure all requested years are present and asks permission
#'    to download any missing years.
#'
#'    The object returned is a list with class 'FARS'. It has five tibbles:
#'    flat, multi_acc, multi_veh, multi_per, events.
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
#'    collected in the yyyy_multi_[acc/veh/per].csv files in long format.
#'    These files contain crash, vehicle, and person identifiers, and two
#'    variables labelled \code{name} and \code{value}. These correspond to
#'    variable names from the raw data files and the corresponding values,
#'    respectively.
#'
#'    The events tibble provides a sequence of events for all vehicles involved
#'    in the crash. See Crash Sequences vignette for an example.
#'
#'    Consult the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813254}{Analytical User’s Manual}
#'    for more information.
#'
#' @examples
#' \donttest{
#' myFARS <- get_fars(years = 2019:2020, states = "51")
#' myFARS <- get_fars(years = 2020, states = "NC")
#' }

get_fars <- function(years     = 2015:2020,
                     states    = NULL,
                     dir       = NULL,
                     proceed   = FALSE
                     ){

  # Check years ----
    validate_years(years)

  # Check states ----
    validate_states(states)


  # Download data without saving or checking hard drive ----

    if(is.null(dir)){

      dest_files <-
        tempdir() %>%
        stringr::str_replace_all(stringr::fixed("\\"), "/") %>%
        stringr::str_c("/FARS data")

      dest_raw   <- paste0(dest_files, "/raw")
      dest_prepd <- paste0(dest_files, "/prepd")

      dir.create(dest_files, showWarnings = FALSE)
      dir.create(dest_raw,   showWarnings = FALSE)
      dir.create(dest_prepd, showWarnings = FALSE)

      download_fars(years = years, dest_raw = dest_raw, dest_prepd = dest_prepd)

      return(use_fars(prepared_dir = dest_prepd, years = years, states = states))

    }


  # Look for pre-existing data ----

    if(!is.null(dir)){

      # dir = getwd()

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
          if(!(x %in% c("y", "Y"))) return(message("Download cancelled.\n"))
        }

        dir.create(dest_files, showWarnings = FALSE)
        dir.create(dest_raw,   showWarnings = FALSE)
        dir.create(dest_prepd, showWarnings = FALSE)

        download_fars(years = years, dest_raw = dest_raw, dest_prepd = dest_prepd)

        return(use_fars(prepared_dir = dest_prepd, years = years, states = states))

      }



    if(nrow(my_dir)==1){ # Some data found ----

       check_dir <- paste0(my_dir$path, "/prepd")

       # Check years
         files_found <- list.files(check_dir, pattern = "_flat.csv")
         years_found <- stringr::word(files_found, sep = "_")
         years_needed  <- setdiff(years, years_found)

         if(length(years_needed) > 0){

           if(!proceed){
            x <-
              paste0(
                paste(years_needed, collapse = ", "),
                " not found in ", dir,
                "\nEnter '1' to download them or any other key to skip") %>%
              readline()
            if(x == "1") download_fars(years = years_needed, dest_raw = dest_raw, dest_prepd = dest_prepd)
           }

          message(paste0("Downloading years ", paste(years_needed, collapse = ", ")))
          download_fars(years = years_needed, dest_raw = dest_raw, dest_prepd = dest_prepd)

         }

         return(use_fars(prepared_dir = dest_prepd, years = years, states = states))


    }


    if(nrow(my_dir)>1){ #Ambiguous
      stop("Multiple 'FARS data' folders found. Please specify using the 'dir' parameter.")
    }

    }


}
