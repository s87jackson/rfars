#' Prepare FARS data
#'
#' Combine raw files to create analysis-ready FARS data files.
#'
#' @param raw_dir Directory where raw files are currently saved.
#' @param states (Optional) States to keep. Leave as NULL to keep all states.
#'     Can be specified as full state name (e.g. "Virginia"), abbreviation ("VA"),
#'     or FIPS code (51).
#' @param years (Optional) Years to keep. Leave as NULL to use all years of data
#'     that exist in the raw_dir.
#' @param proceed Logical, should the downloading proceed without the user's
#'     permission (set to FALSE by default).
#'
#' @return Produces four files for each year: yyyy_flat.csv, yyyy_multi_acc.csv,
#'     yyyy_multi_veh.csv, and yyyy_multi_per.csv.
#'
#' @details Flat files are wide-formatted and presented at the person level.
#'     All \emph{crashes} involve at least one motor \emph{vehicle}, each of
#'     which may contain one or multiple \emph{people}. These are the three
#'     entities of crash data. The flat files therefore repeat some data elements
#'     across multiple rows. Please conduct your analysis with your entity in mind. \cr \cr
#'     Some data elements can include multiple values for any data level
#'     (e.g., multiple weather conditions corresponding to the crash, or multiple
#'     crash factors related to vehicle or person). All of these elements have been
#'     collected in the yyyy_multi_[acc/veh/per].csv files in long format.
#'     These files contain crash, vehicle, and person identifiers, and two
#'     variables labelled \code{name} and \code{value}. These correspond to
#'     variable names from the raw data files and the corresponding values,
#'     respectively. \cr \cr
#'     The flat files contain one row per person (which may result in multiple
#'     rows for associated vehicles and crashes), but the multi files can
#'     contain a variable number of rows for any crash entity. \cr \cr
#'     Consult the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813254}{Analytical User’s Manual}
#'     for more information.
#'
#' @examples
#' \dontrun{
#' prep_fars("Virginia")
#' prep_fars()
#' prep_fars("NC")
#' }
#'
#' @importFrom rlang .data


#' @export
prep_fars <- function(raw_dir = "FARS data/raw", states = NULL, years = NULL, proceed=FALSE){

  # Check value for states
    validate_states(states)


  # Check years
    if(is.null(years)){
      years <- list.files(raw_dir)
    } else{
      validate_years(years)
    }


  # Create directory for prepared files
    prepared_dir <- gsub(pattern = "raw", replacement = "prepared", x = raw_dir)
    dir.create(prepared_dir, showWarnings = FALSE)


  # Ask permission to download files to the user's computer
    if(!proceed){
      x <- readline(paste0("We will now create several CSV files and save them in ", prepared_dir, "\n Proceed? (Y/N) \n"))
      if(!(x %in% c("y", "Y"))) return(message("Operation cancelled."))
      }


  # Optional state filter
    if(!is.null(states)){
      geo_filtered <-
        rfars::geo_relations %>%
        filter(
          .data$fips_state %in% states | .data$state_name_abbr %in% states | .data$state_name_full %in% states
          ) #this lets the user specify states in any of these ways
      } else{
        geo_filtered <- rfars::geo_relations
      }



for(y in years){ # y = 2014

  # Logistics
    message(paste("Preparing the", y, "files..................."))
    wd <- paste0(raw_dir, "/", y, "/")
    wd <- gsub(pattern = "//", replacement = "/", x = wd)
    wd <- gsub(pattern = "~/", replacement = "", x = wd)


  # Get list of raw data files
    rawfiles <-
      data.frame(filename = list.files(wd, recursive = TRUE)) %>%
      mutate(cleaned  = stringr::str_to_lower(.data$filename),
             cleaned  = gsub(x=.data$cleaned, pattern = ".csv", replacement = ""),
             cleaned  = gsub(x=.data$cleaned, pattern = ".sas7bdat", replacement = "")
             )


  # Year-specific import-then-export-CSV functions
    if(y==2020)          prep_fars_2020(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2019)          prep_fars_2019(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2018)          prep_fars_2018(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y %in% 2016:2017) prep_fars_2017(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y %in% 2014:2015) prep_fars_2015(y, wd, rawfiles, prepared_dir, geo_filtered)
    #if(y %in% 2012:2013) prep_fars_2013(y, wd, rawfiles, prepared_dir, geo_filtered)
    #if(y==2011)          prep_fars_2011(y, wd, rawfiles, prepared_dir, geo_filtered)

  } # ends the loop through years

  message(paste0("Prepared data files have been saved to ", prepared_dir, "\n"))

  return(invisible(prepared_dir))

}
