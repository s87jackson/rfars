#' Prepare FARS data
#'
#' Combine raw files to create analysis-ready FARS data files.
#'
#' @param raw_dir Directory where raw files are currently saved.
#' @param states (Optional) states to keep. Leave as NULL to keep all states.
#'     Can be specified as full state name (e.g. "Virginia"), abbreviation ("VA"),
#'     or FIPS code (51).
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
#' prep_fars()
#' prep_fars("Virginia")
#' prep_fars("NC")


#' @export
prep_fars <- function(raw_dir = getwd(), states = NULL){

  # raw_dir = "test environment/FARS data/raw"
  # states  = "VA"

  # Ask permission to download files to the user's computer
    x <- readline(paste0("We will now create several CSV files and save them in ", raw_dir, "\n Proceed? (Y/N) \n"))
    if(!(x %in% c("y", "Y"))) return(message("Operation cancelled."))

  # Determine years from existing files
    years <-
      data.frame(year=list.files(raw_dir)) %>%
      mutate(year = as.numeric(year)) %>%
      filter(!is.na(year)) %>%
      pull(year)

  # Create directory for prepared files
    prepared_dir <- gsub(pattern = "raw", replacement = "prepared", x = raw_dir)
    dir.create(prepared_dir, showWarnings = FALSE)

  # Optional state filter
    if(!is.null(states)){
      geo_filtered <-
        rfars::geo_relations %>%
        filter(
          fips_state %in% states | state_name_abbr %in% states | state_name_full %in% states
          ) #this lets the user specify states in any of these ways
      } else{
        geo_filtered <- rfars::geo_relations
      }



for(y in years){ # y = 2016

  # Logistics
    message(paste("Importing the raw", y, "files..................."))
    wd <- paste0(raw_dir, "/", y, "/") %>% gsub(pattern = "//", replacement = "/", x = .)


  # Get list of raw data files
    rawfiles <-
      data.frame(filename = list.files(wd, recursive = TRUE)) %>%
      mutate(cleaned  = stringr::str_to_lower(filename) %>%
               gsub(x=., pattern = ".csv", replacement = "")
             )


  # Year-specific import-then-export-CSV functions
    if(y==2020) prep_fars_2020(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2019) prep_fars_2019(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2018) prep_fars_2018(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2017) prep_fars_2017(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2016) prep_fars_2017(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2015) prep_fars_2017(y, wd, rawfiles, prepared_dir, geo_filtered)
    # Prior to 2015, only the encoded variables were provided
      #if(y==2014) prep_fars_2017(y, wd, rawfiles, prepared_dir, geo_filtered)
      #if(y==2013) prep_fars_2013(y, wd, rawfiles, prepared_dir, geo_filtered)
      #if(y==2012) prep_fars_2013(y, wd, rawfiles, prepared_dir, geo_filtered)
      #if(y==2011) prep_fars_2011(y, wd, rawfiles, prepared_dir, geo_filtered)

  } # ends the loop through years

  message(paste0("Prepared data files have been saved to ", prepared_dir))

  return(invisible(prepared_dir))

}
