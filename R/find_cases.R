#' (Internal) Find various cases
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param FARS The FARS data object to be searched.


distracted_driver <- function(FARS){

  bind_rows(
    FARS$multi_veh %>%
      filter(name == "drdistract",
             value != "Not Distracted") %>%
      select(state, st_case, year) %>%
      unique(),
    FARS$multi_veh %>%
      filter(name == "mdrdstrd",
             value != "Not Distracted") %>%
      select(state, st_case, year) %>%
      unique()
    ) %>%
    return()

}


drowsy_driver <- function(FARS){

  FARS$multi_veh %>%
    filter(name == "drimpair",
           value == "Asleep or Fatigued") %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}


police_pursuit <- function(FARS){

  FARS$multi_acc %>%
    filter(name == "crashrf",
           value == "Police Pursuit Involved") %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}


motorcycle <- function(FARS){

  FARS$flat %>%
    filter(grepl("motorcycle", body_typ, ignore.case = TRUE)) %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()
}


pedalcyclist <- function(FARS){

  FARS$flat %>%
    filter(per_typ %in% c(
      "Bicyclist",
      "Person on Non-Motorized Personal Conveyance")) %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}


pedestrian <- function(FARS){

  FARS$flat %>%
    filter(per_typ == "Pedestrian") %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}


bicyclist <- function(FARS){

  FARS$flat %>%
    filter(per_typ == "Bicyclist") %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}


pedbike <- function(FARS){

  FARS$flat %>%
    filter(per_typ %in% c("Pedestrian", "Bicyclist")) %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}


young_driver <- function(FARS){

  message("Note: Young drivers are defined as those between the ages of 15 and 20.")

  FARS$flat %>%
    filter(per_typ == "Driver of a Motor Vehicle In-Transport") %>%
    mutate(age_n = as.numeric(stringr::word(age, 1, sep = " "))) %>%
    filter(data.table::between(age_n, 15, 20, incbounds = TRUE)) %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}


older_driver <- function(FARS){

  message("Note: Older drivers are defined as those aged 65+.")

  FARS$flat %>%
    filter(per_typ == "Driver of a Motor Vehicle In-Transport") %>%
    mutate(age_n = as.numeric(stringr::word(age, 1, sep = " "))) %>%
    filter(age_n >= 65) %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}


speeding <- function(FARS){

  FARS$flat %>%
    filter(grepl("Yes", speedrel)) %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}


alcohol <- function(FARS){

  FARS$flat %>%
    filter(dr_drink == "Yes") %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}


drugs <- function(FARS){

  FARS$flat %>%
    filter(per_typ == "Driver of a Motor Vehicle In-Transport") %>%
    filter(grepl("Yes", drugs)) %>%
    select(state, st_case, year) %>%
    unique() %>%
    return()

}
