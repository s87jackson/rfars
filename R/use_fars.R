#' (Internal) Use FARS data files
#'
#' Combine multiple years of prepared FARS data stored in CSV files and bring
#'     into the current environment.
#'
#' @param prepared_dir Directory where prepared files are currently saved.
#' @param years (Optional) Years to keep.
#' @param states (Optional) States to keep.
#'
#' @return Returns an object of class 'FARS' which is a list of five tibbles:
#'     flat, multi_acc, multi_veh, multi_per, and events

use_fars <- function(prepared_dir="FARS data", years = NULL, states = NULL){

  if(is.null(years)){
      years <-
        list.files(paste0(prepared_dir, "/prepared")) %>%
        stringr::word(1, sep="_") %>%
        unique()
  }


  # Optional state filter ----
    if(!is.null(states)){
      geo_filtered <-
        rfars::geo_relations %>%
        filter(.data$fips_state %in% states | .data$state_name_abbr %in% states | .data$state_name_full %in% states)
      } else{
        geo_filtered <- rfars::geo_relations
      }



  flat <-

    suppressWarnings({ #this is just for the small number of coercion errors with mutate_at(lat, lon, as.numeric)

    suppressMessages({

      data.frame(path = list.files(prepared_dir, full.names = TRUE, pattern = "_flat.csv", recursive = TRUE)) %>%
      mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
      filter(.data$year %in% years) %>%
      pull(.data$path) %>%
      lapply(function(x){
        readr::read_csv(x, show_col_types = FALSE,
                        col_types = readr::cols(.default = readr::col_character())) %>%
        mutate_at(c("lat", "lon"), as.numeric)
        }) %>%
      bind_rows() %>%
      readr::type_convert() %>%
      filter(.data$state %in% unique(geo_filtered$state_name_full))

    }) #suppressMessages

    }) #suppressWarnings


  multi_acc <-
    data.frame(path = list.files(prepared_dir, full.names = TRUE, pattern = "multi_acc.csv", recursive = TRUE)) %>%
    mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
    filter(.data$year %in% years) %>%
    pull(.data$path) %>%
    lapply(readr::read_csv, show_col_types = FALSE) %>%
    bind_rows() %>%
    as.data.frame() %>%
    filter(.data$state %in% unique(geo_filtered$state_name_full))

  multi_veh <-
    data.frame(path = list.files(prepared_dir, full.names = TRUE, pattern = "multi_veh.csv", recursive = TRUE)) %>%
    mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
    filter(.data$year %in% years) %>%
    pull(.data$path) %>%
    lapply(readr::read_csv, show_col_types = FALSE) %>%
    bind_rows() %>%
    as.data.frame() %>%
    filter(.data$state %in% unique(geo_filtered$state_name_full))

  multi_per <-
    data.frame(path = list.files(prepared_dir, full.names = TRUE, pattern = "multi_per.csv", recursive = TRUE)) %>%
    mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
    filter(.data$year %in% years) %>%
    pull(.data$path) %>%
    lapply(readr::read_csv, show_col_types = FALSE) %>%
    bind_rows() %>%
    as.data.frame() %>%
    filter(.data$state %in% unique(geo_filtered$state_name_full))

  events <-
    data.frame(path = list.files(prepared_dir, full.names = TRUE, pattern = "_events.csv", recursive = TRUE)) %>%
    mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
    filter(.data$year %in% years) %>%
    pull(.data$path) %>%
    lapply(readr::read_csv, show_col_types = FALSE) %>%
    bind_rows() %>%
    as.data.frame() %>%
    filter(.data$state %in% unique(geo_filtered$state_name_full))


  out <- list(
    "flat" = flat,
    "multi_acc" = multi_acc,
    "multi_veh" = multi_veh,
    "multi_per" = multi_per,
    "events"    = events)

  class(out) <- c(class(out), "FARS")

  return(out)

  }
