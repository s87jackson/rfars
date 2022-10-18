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
#' prep_fars("Virginia")
#' \dontrun{
#' prep_fars()
#' prep_fars("NC")
#' }
#'
#' @importFrom rlang .data


#' @export
prep_fars <- function(raw_dir = "~/FARS data/raw", states = NULL, years = NULL){

  # Check value for states
    for(state in states){

      state_check <- state %in% unique(c(rfars::geo_relations$state_name_abbr,
                                    rfars::geo_relations$state_name_full,
                                    rfars::geo_relations$fips_state))

      if(!state_check) stop(paste0("'", state, "' not recognized. Please check rfars::geo_relations for valid ways to specify states (state_name_abbr, state_name_full, or fips_state)."))

    }


  # Check years
    if(is.null(years)) years <- list.files(raw_dir)

    ymax <- max(as.numeric(years), na.rm = TRUE)
    ymin <- min(as.numeric(years), na.rm = TRUE)

    if(ymin < 2014) stop("Data not (yet) available prior to 2014")
    if(ymax > 2020) stop("Data not available beyond 2020")


  # Create directory for prepared files
    prepared_dir <- gsub(pattern = "raw", replacement = "prepared", x = raw_dir)
    dir.create(prepared_dir, showWarnings = FALSE)


  # Ask permission to download files to the user's computer
    x <- readline(paste0("We will now create several CSV files and save them in ", prepared_dir, "\n Proceed? (Y/N) \n"))
    if(!(x %in% c("y", "Y"))) return(message("Operation cancelled."))


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



for(y in years){ # y = 2016

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
    if(y==2020) prep_fars_2020(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2019) prep_fars_2019(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2018) prep_fars_2018(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2017) prep_fars_2017(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2016) prep_fars_2017(y, wd, rawfiles, prepared_dir, geo_filtered)
    if(y==2015) prep_fars_2015(y, wd, rawfiles, prepared_dir, geo_filtered)


    # Years 2012-2014 have corrupt (?) sas7bcat files
    # Fortunately, we can use 2011 and 2015 to construct data dictionaries
    # The code below shows this:
    #
    # fars_data_changes %>%
    #   filter(data.table::between(year, 2011, 2015)) %>%
    #   pivot_longer(-1) %>%
    #   arrange(name, year) %>%
    #   group_by(name) %>% mutate(n = length(unique(value))) %>%
    #   filter(n>1) %>%
    #   pivot_wider(names_from="year", values_from="value") %>%
    #   #filter(`2011` != `2012`, `2014` != `2015`) %>%
    #   View()
    #
    # Next steps:
    #   Develop function to generate data dictionary from each raw file
    #   Determine which data dictionary (2011 or 2015) to use
    #   Develop logic to do this for 2012:2014

    # if(y==2014) prep_fars_2015(y, wd, rawfiles, prepared_dir, geo_filtered)
    # if(y==2013) prep_fars_2013(y, wd, rawfiles, prepared_dir, geo_filtered)
    # if(y==2012) prep_fars_2013(y, wd, rawfiles, prepared_dir, geo_filtered)

    if(y==2011) prep_fars_2011(y, wd, rawfiles, prepared_dir, geo_filtered)
    # NOTE prep_fars_2017 on y=2016 (example) is intentional as nothing changed during that year to warrant a new function

  } # ends the loop through years

  message(paste0("Prepared data files have been saved to ", prepared_dir, "\n"))

  return(invisible(prepared_dir))

}
