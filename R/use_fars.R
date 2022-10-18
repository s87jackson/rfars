#' Use FARS data files
#'
#' Combine multiple years of prepared FARS data stored in CSV files and bring
#'     into the current environment.
#'
#' @param prepared_dir Directory where prepared files are currently saved.
#' @param years (Optional) Years to use.
#'
#' @return Returns either a single data frame (if \code{multi=NULL}) or a list
#'     containing the combined flat file data frame and specified \code{multi}
#'     files.
#'
#' @seealso \code{download_fars()} \code{prep_fars()} \code{get_fars()}
#' @examples
#' \dontrun{
#' myData <- use_fars()
#' }

#' @export
use_fars <- function(prepared_dir="FARS data", years = NULL){

  if(is.null(years)){
      years <-
        list.files(paste0(prepared_dir, "/prepared")) %>%
        stringr::word(1, sep="_") %>%
        unique()
      }


  flat <-

    suppressWarnings({ #this is just for the small number of coercion errors with mutate_at(lat, lon, as.numeric)

      data.frame(path = list.files(prepared_dir, full.names = TRUE, pattern = "_flat.csv", recursive = TRUE)) %>%
      mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
      filter(.data$year %in% years) %>%
      pull(.data$path) %>%
      lapply(function(x){
        readr::read_csv(x, show_col_types = FALSE,
                        col_types = readr::cols(.default = readr::col_character())) %>%
        mutate_at(c("lat", "lon"), as.numeric) #%>%
        # The variables below change format: mutate_at(c("city", "hour", "not_hour", "not_min", "arr_hour"), as.character)
        }) %>%
      bind_rows() %>%
      readr::type_convert()

      ## 2015 changes how county is coded...
      # as.data.frame() %>%
      # mutate(fips_county = gsub("[^[:digit:], ]", "", as.character(.data$county)) %>%
      #          stringr::str_pad(3, "left", "0")
      #        ) %>%
      # left_join(
      #   select(rfars::geo_relations, fips_county, county_name_abbr) %>% unique(),
      #   by = "fips_county"
      #   ) %>%
      # mutate(county = paste0(
      #   stringr::str_to_upper(.data$county_name_abbr),
      #   " (", as.character(county), ")")
      #   ) %>%
      # select(-fips_county, -county_name_abbr) %>%
      # mutate(city = as.character(.data$city))



    })


  multi_acc <-
    data.frame(path = list.files(prepared_dir, full.names = TRUE, pattern = "multi_acc", recursive = TRUE)) %>%
    mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
    filter(.data$year %in% years) %>%
    pull(.data$path) %>%
    lapply(readr::read_csv, show_col_types = FALSE) %>%
    bind_rows() %>%
    as.data.frame()

  multi_veh <-
    data.frame(path = list.files(prepared_dir, full.names = TRUE, pattern = "multi_veh", recursive = TRUE)) %>%
    mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
    filter(.data$year %in% years) %>%
    pull(.data$path) %>%
    lapply(readr::read_csv, show_col_types = FALSE) %>%
    bind_rows() %>%
    as.data.frame()

  multi_per <-
    data.frame(path = list.files(prepared_dir, full.names = TRUE, pattern = "multi_per", recursive = TRUE)) %>%
    mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
    filter(.data$year %in% years) %>%
    pull(.data$path) %>%
    lapply(readr::read_csv, show_col_types = FALSE) %>%
    bind_rows() %>%
    as.data.frame()


  out <- list(
    "flat" = flat,
    "multi_acc" = multi_acc,
    "multi_veh" = multi_veh,
    "multi_per" = multi_per)

  class(out) <- c(class(out), "FARS")

  return(out)

  }
