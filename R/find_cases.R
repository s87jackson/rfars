#' (Internal) Find crashes involving distracted drivers
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

distracted_driver <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){
    bind_rows(
      df$multi_veh %>%
        filter(.data$name == "drdistract",
               .data$value != "Not Distracted") %>%
        make_id() %>%
        select(.data$year, .data$id) %>%
        make_all_numeric() %>%
        distinct(),
      df$multi_veh %>%
        filter(.data$name == "mdrdstrd",
               .data$value != "Not Distracted") %>%
        make_id() %>%
        select(.data$year, .data$id) %>%
        make_all_numeric() %>%
        distinct()
      ) %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving police pursuits
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

police_pursuit <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$multi_acc %>%
      filter(.data$name == "crashrf",
           .data$value == "Police Pursuit Involved") %>%
      make_id() %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving motorcycles
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

motorcycle <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(grepl("motorcycle", .data$body_typ, ignore.case = TRUE)) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving pedalcyclists
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

pedalcyclist <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(.data$per_typ %in% c(
        "Bicyclist",
        "Person on Non-Motorized Personal Conveyance")) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving pedestrians
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

pedestrian <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(.data$per_typ == "Pedestrian") %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving bicyclists
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

bicyclist <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(.data$per_typ == "Bicyclist") %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving pedstrians or bicyclists
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

pedbike <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(.data$per_typ %in% c("Pedestrian", "Bicyclist")) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving drivers of a given age
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#' @param age_min Lower bound on driver age (inclusive).
#' @param age_max Upper bound on driver age (inclusive).
#'
#' @importFrom rlang .data

driver_age <- function(df, age_min, age_max){

  if(any(!is.numeric(age_min), !is.numeric(age_max))) stop("Enter age min and max as numeric")

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      mutate(age_n = suppressWarnings(as.numeric(stringr::word(.data$age, 1, sep = " ")))) %>%
      filter(!is.na(.data$age_n)) %>%
      filter(dplyr::between(.data$age_n, age_min, age_max)) %>%
      select("year", "id") %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving speeding
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

speeding <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(grepl("Yes", .data$speedrel)) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving alcohol
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

alcohol <- function(df){

  if(any(class(df) %in% c("FARS"))){

    out <-
      df$flat %>%
      filter(.data$dr_drink == "Yes") %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct()

    }

  if(any(class(df) %in% c("GESCRSS"))){

    out <-
      df$flat %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      filter(grepl("Yes", .data$drinking)) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct()

  }


  if(any(class(df) %in% c("FARS", "GESCRSS"))){
    return(out)
  } else{
    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")
  }

}


#' (Internal) Find crashes involving drugs
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

drugs <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      filter(grepl("Yes", .data$drugs)) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving large trucks
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

large_trucks <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(
        .data$body_typ %in% c(
          "Step van (>10,000 lbs. GVWR)",
          "Single-unit straight truck or Cab-Chassis (GVWR range 10,001 to 19,500 lbs.)",
          "Single-unit straight truck or Cab-Chassis (10,000 lbs. < GVWR < or = 19,500 lbs.)",
          "Single-unit straight truck or Cab-Chassis (GVWR range 19,501 to 26,000 lbs.)",
          "Single-unit straight truck or Cab-Chassis (19,500 lbs. < GVWR < or = 26,000 lbs.)",
          "Single-unit straight truck or Cab-Chassis (GVWR > 26,000 lbs.)",
          "Single-unit straight truck or Cab-Chassis (GVWR greater than 26,000 lbs.)",
          "Single-unit straight truck or Cab-Chassis (GVWR unknown)",
          "Truck-tractor (Cab only, or with any number of trailing unit; any weight)",
          "Medium/heavy Pickup (>10,000 lbs. GVWR)",
          "Medium/heavy Pickup (GVWR greater than 10,000 lbs.)",
          "Unknown medium/heavy truck type"
        ) |
        (.data$body_typ == "Unknown medium/heavy truck type" &
         .data$tow_veh %in% c("One Trailing Unit",
                              "Two Trailing Units")
         )
      ) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find hit and run crashes
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

hit_and_run <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(.data$hit_run == "Yes") %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving road departures
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

road_depart <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(grepl("departure", .data$acc_type, ignore.case = TRUE)) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}


#' (Internal) Find crashes involving rollovers
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

rollover <- function(df){

  if(any(class(df) %in% c("FARS", "GESCRSS"))){

    df$flat %>%
      filter(!grepl("No Roll", .data$rollover)) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}
