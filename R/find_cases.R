#' (Internal) Find various cases
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param FARS The FARS data object to be searched.
#'
#' @importFrom rlang .data


distracted_driver <- function(FARS){

  bind_rows(
    FARS$multi_veh %>%
      filter(.data$name == "drdistract",
             .data$value != "Not Distracted") %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique(),
    FARS$multi_veh %>%
      filter(.data$name == "mdrdstrd",
             .data$value != "Not Distracted") %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique()
    ) %>%
    return()

}


drowsy_driver <- function(FARS){

  FARS$multi_veh %>%
    filter(.data$name == "drimpair",
           .data$value == "Asleep or Fatigued") %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


police_pursuit <- function(FARS){

  FARS$multi_acc %>%
    filter(.data$name == "crashrf",
           .data$value == "Police Pursuit Involved") %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


motorcycle <- function(FARS){

  FARS$flat %>%
    filter(grepl("motorcycle", .data$body_typ, ignore.case = TRUE)) %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()
}


pedalcyclist <- function(FARS){

  FARS$flat %>%
    filter(.data$per_typ %in% c(
      "Bicyclist",
      "Person on Non-Motorized Personal Conveyance")) %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


pedestrian <- function(FARS){

  FARS$flat %>%
    filter(.data$per_typ == "Pedestrian") %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


bicyclist <- function(FARS){

  FARS$flat %>%
    filter(.data$per_typ == "Bicyclist") %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


pedbike <- function(FARS){

  FARS$flat %>%
    filter(.data$per_typ %in% c("Pedestrian", "Bicyclist")) %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


young_driver <- function(FARS){

  message("Note: Young drivers are defined as those between the ages of 15 and 20.")

  FARS$flat %>%
    filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
    mutate(age_n = as.numeric(stringr::word(.data$age, 1, sep = " "))) %>%
    filter(data.table::between(.data$age_n, 15, 20, incbounds = TRUE)) %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


older_driver <- function(FARS){

  message("Note: Older drivers are defined as those aged 65+.")

  FARS$flat %>%
    filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
    mutate(age_n = as.numeric(stringr::word(.data$age, 1, sep = " "))) %>%
    filter(.data$age_n >= 65) %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


speeding <- function(FARS){

  FARS$flat %>%
    filter(grepl("Yes", .data$speedrel)) %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


alcohol <- function(FARS){

  FARS$flat %>%
    filter(.data$dr_drink == "Yes") %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


drugs <- function(FARS){

  FARS$flat %>%
    filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
    filter(grepl("Yes", .data$drugs)) %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}
