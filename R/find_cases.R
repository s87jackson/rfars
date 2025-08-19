#' (Internal) Find crashes involving distracted drivers
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param df The FARS or GESCRSS data object to be searched.
#'
#' @importFrom rlang .data

distracted_driver <- function(df){

  not_distracted <- c(
    "No Driver Present/Unknown if Driver present",
    "Not Distracted",
    "Not Reported",
    "Reported as Unknown if Distracted",
    "Unknown if Distracted"
  )

  if(any(class(df) %in% c("FARS", "GESCRSS"))){
    df$multi_veh %>%
      filter(.data$name %in% c("drdistract", "mdrdstrd"),
             !(.data$value %in% not_distracted)) %>%
      make_id() %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
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

    data.table::rbindlist(list(
      df$multi_acc %>%
        filter(.data$name == "crashrf",
               .data$value == "Police Pursuit Involved") %>%
        make_id() %>%
        select(.data$year, .data$id) %>%
        make_all_numeric() %>%
        distinct(),
      df$multi_acc %>%
        filter(.data$name == "cf1",
               .data$value == "Police Pursuit Involved") %>%
        make_id() %>%
        select(.data$year, .data$id) %>%
        make_all_numeric() %>%
        distinct(),
      df$multi_acc %>%
        filter(.data$name == "cf2",
               .data$value == "Police Pursuit Involved") %>%
        make_id() %>%
        select(.data$year, .data$id) %>%
        make_all_numeric() %>%
        distinct(),
      df$multi_acc %>%
        filter(.data$name == "cf3",
               .data$value == "Police Pursuit Involved") %>%
        make_id() %>%
        select(.data$year, .data$id) %>%
        make_all_numeric() %>%
        distinct()
    ), fill = TRUE) %>%
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
      filter(grepl("motorcycle|motored|moped|motor scooter", .data$body_typ, ignore.case = TRUE)) %>%
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
        "Other Cyclist")) %>%
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
#' @importFrom stringr word

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
#' @importFrom stringr word


alcohol <- function(df){

  message("Note: rfars::counts() uses the variables alc_res and dr_drink to determine alcohol involvement. NHTSA reports counts using multiple imputation to estimate missing BAC values. See vignette('Alcohol Counts', package = 'rfars') for more information.")

  if(any(class(df) %in% c("FARS"))){

    out <-
      df$flat %>%
      # filter(.data$dr_drink == "Yes") %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      mutate(
        bac = suppressWarnings(as.numeric(stringr::word(.data$alc_res))),
        alc_impaired = (
          between(.data$bac, 0.08, 0.94) |
            .data$bac %in% c(.098, .0998) |
            .data$dr_drink %in% c("01", "Yes")
        )
      ) %>%
      filter(.data$alc_impaired) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct()

  }

  if(any(class(df) %in% c("GESCRSS"))){

    out <-
      df$flat %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      mutate(
        bac = suppressWarnings(as.numeric(stringr::word(.data$alc_res))),
        alc_impaired = (
          between(.data$bac, 0.08, 0.94) |
            .data$bac %in% c(.098, .0998) |
            .data$drinking == "Yes (Alcohol Involved)"
        )
      ) %>%
      filter(.data$alc_impaired) %>%
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

    lt_inds <- c(
      "Step van (>10,000 lbs. GVWR)",
      "Single-unit straight truck or Cab-Chassis (10,000 lbs. < GVWR < or = 19,500 lbs.)",
      "Single-unit straight truck or Cab-Chassis (19,500 lbs. < GVWR < or = 26,000 lbs.)",
      "Single-unit straight truck or Cab-Chassis (GVWR > 26,000 lbs.)",
      "Single-unit straight truck or Cab-Chassis (GVWR unknown)",
      "Truck-tractor (Cab only, or with any number of trailing unit; any weight)",
      "Medium/Heavy Pickup (Ford Super Duty 450/550)",
      "Unknown if single unit or combination unit Medium Truck (10,000 lbs. < GVWR < 26,000 lbs.)",
      "Unknown if single unit or combination unit Heavy Truck (GVWR > 26,000 lbs.)",
      "Unknown medium/heavy truck type",
      "Medium/heavy Pickup (>10,000 lbs. GVWR)",
      "Step van (GVWR greater than 10,000 lbs.)",
      "Single-unit straight truck or Cab-Chassis (GVWR range 10,001 to 19,500 lbs.)",
      "Single-unit straight truck or Cab-Chassis (GVWR range 19,501 to 26,000 lbs.)",
      "Single-unit straight truck or Cab-Chassis (GVWR greater than 26,000 lbs.)",
      "Medium/heavy Pickup (GVWR greater than 10,000 lbs.)",
      "Unknown if single-unit or combination unit Medium Truck (GVWR range 10,001 lbs. to 26,000 lbs.)",
      "Unknown if single-unit or combination unit Heavy Truck (GVWR greater than 26,000 lbs.)")


    lt_inds2 <- c(  # BODY_TYP == Unknown truck type (light/medium/heavy) AMD
      "One Trailing Unit",
      "Two Trailing Units",
      "Three or More Trailing Units",
      "Yes, Number of Trailing Units Unknown")


    df$flat %>%
      filter(
        .data$body_typ %in% lt_inds |
        (.data$body_typ == "Unknown truck type (light/medium/heavy)" &
         .data$tow_veh %in% lt_inds2
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

    df$events %>%
      filter(.data$veventnum == 1,
             .data$soe %in% c(
               "Ran off Roadway - Direction Unknown",
               "Ran Off Roadway - Left",
               "Ran Off Roadway - Right",
               "Cross Median",
               "Cross Centerline",
               "End Departure",
               #Fixed object codes:
               "Boulder",
               "Building",
               "Impact Attenuator/Crash Cushion",
               "Bridge Pier or Support",
               "Bridge Rail (Includes parapet)",
               "Guardrail Face",
               "Concrete Traffic Barrier",
               "Other Traffic Barrier",
               "Utility Pole/Light Support",
               "Other Post, Other Pole or Other Supports",
               "Culvert",
               "Curb",
               "Ditch",
               "Embankment",
               "Fence",
               "Wall",
               "Fire Hydrant",
               "Shrubbery",
               "Tree (Standing Only)",
               "Other Fixed Object",
               "Traffic Signal Support",
               "Guardrail End",
               "Mail Box",
               "Cable Barrier",
               "Traffic Sign Support",
               "Post, Pole or Other Supports"
             )
      ) %>%
      make_id() %>%
      select(.data$id, .data$year) %>%
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
      filter(!grepl("8", .data$rollover)) %>%
      filter(!is.na(.data$rollover)) %>%
      select(.data$year, .data$id) %>%
      make_all_numeric() %>%
      distinct() %>%
      return()

  } else{

    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")

  }

}
