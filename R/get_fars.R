#' Get FARS data
#'
#' Bring FARS data into the current environment, whether by downloading it anew
#'     or by using pre-existing files.
#'
#' @export
#'
#' @param years Years to be downloaded, in yyyy (character or numeric formats),
#'     currently limited to 2011-2021 (the default).
#' @param states States to keep. Leave as NULL (the default) to keep
#'     all states. Can be specified as full state name (e.g. "Virginia"),
#'     abbreviation ("VA"), or FIPS code (51).
#' @param dir Directory in which to search for or save a 'FARS data' folder. If
#'     NULL (the default), files are downloaded and unzipped to temporary
#'     directories and prepared in memory.
#' @param proceed Logical, whether or not to proceed with downloading files without
#'     asking for user permission (defaults to FALSE, thus asking permission)
#' @param cache The name of an RDS file to save or use. If the specified file (e.g., 'myFARS.rds')
#'    exists in 'dir' it will be returned; if not, an RDS file of this name will be
#'    saved in 'dir' for quick use in subsequent calls.
#'
#' @return A FARS data object (list of six tibbles: flat, multi_acc,
#'     multi_veh, multi_per, events, and codebook), described below.
#'
#' @details This function downloads raw data from \href{https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/FARS/}{NHTSA}.
#'    If no directory (dir) is specified, SAS files are downloaded into a
#'    tempdir(), where they are also prepared, combined, and then brought into
#'    the current environment. If you specify a directory (dir), the function will
#'    look there for a 'FARS data' folder. If not found, it will be created and
#'    populated with raw and prepared SAS and RDS files. If the directory is found, the
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
#'    Please review the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813417}{FARS Analytical User's Manual}
#'
#'
#' @examples
#'
#'   \dontrun{
#'     myFARS <- get_fars(years = 2021, states = "VA")
#'   }


get_fars <- function(years   = 2011:2021,
                     states  = NULL,
                     dir     = NULL,
                     proceed = FALSE,
                     cache   = NULL
                     ){


  # Check for cached RDS file in dir
    if(!is.null(cache)){
      if(!is.null(dir)){
        if(cache %in% list.files(dir)){

          return(readRDS( gsub("//", "/", paste0(dir, "/", cache))))

        }
      }
    }


  # Check years ----
    ymax <- max(as.numeric(years), na.rm = TRUE)
    ymin <- min(as.numeric(years), na.rm = TRUE)
    if(ymin < 2011) stop("Data not yet available prior to 2011.")
    if(ymax > 2021) stop("Data not yet available beyond 2021.")


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

      download_fars(years = years, dest_raw = dest_raw, dest_prepd = dest_prepd, states=states)

      return(use_fars(dir = dir, prepared_dir = dest_prepd, cache = cache))

    }


  # Look for pre-existing data ----

    if(!is.null(dir)){

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

       check_dir <- paste0(my_dir$path, "/prepd")

       # Check years
         files_found <- list.files(check_dir, pattern = "_flat.rds")
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

}
