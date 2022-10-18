#' (Internal) Find various cases
#'
#' These internal functions take the FARS object created by use_fars and look
#'     for various cases, such as distracted or drowsy drivers.
#'
#' @param FARS The FARS data object to be searched.
#'
#' @importFrom rlang .data


distracted_driver <- function(FARS){

  if(!("FARS" %in% class(FARS))) stop("Input object is not of class 'FARS'")

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

  if(!("FARS" %in% class(FARS))) stop("Input object is not of class 'FARS'")

  FARS$multi_veh %>%
    filter(.data$name == "drimpair",
           .data$value == "Asleep or Fatigued") %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


police_pursuit <- function(FARS){

  if(!("FARS" %in% class(FARS))) stop("Input object is not of class 'FARS'")

  FARS$multi_acc %>%
    filter(.data$name == "crashrf",
           .data$value == "Police Pursuit Involved") %>%
    select(.data$state, .data$st_case, .data$year) %>%
    unique() %>%
    return()

}


motorcycle <- function(FARS){

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
      filter(grepl("motorcycle", .data$body_typ, ignore.case = TRUE)) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
    FARS %>%
      filter(grepl("motorcycle", .data$body_typ, ignore.case = TRUE)) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }

}


pedalcyclist <- function(FARS){

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
      filter(.data$per_typ %in% c(
        "Bicyclist",
        "Person on Non-Motorized Personal Conveyance")) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
     FARS %>%
      filter(.data$per_typ %in% c(
        "Bicyclist",
        "Person on Non-Motorized Personal Conveyance")) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }

}


pedestrian <- function(FARS){

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
      filter(.data$per_typ == "Pedestrian") %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
    FARS %>%
      filter(.data$per_typ == "Pedestrian") %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }

}


bicyclist <- function(FARS){

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
      filter(.data$per_typ == "Bicyclist") %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
    FARS %>%
      filter(.data$per_typ == "Bicyclist") %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }

}


pedbike <- function(FARS){

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
      filter(.data$per_typ %in% c("Pedestrian", "Bicyclist")) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
    FARS %>%
      filter(.data$per_typ %in% c("Pedestrian", "Bicyclist")) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }

}


young_driver <- function(FARS){

  message("Note: Young drivers are defined as those between the ages of 15 and 20.")

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      mutate(age_n = as.numeric(stringr::word(.data$age, 1, sep = " "))) %>%
      filter(data.table::between(.data$age_n, 15, 20, incbounds = TRUE)) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
    FARS %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      mutate(age_n = as.numeric(stringr::word(.data$age, 1, sep = " "))) %>%
      filter(data.table::between(.data$age_n, 15, 20, incbounds = TRUE)) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }

}


older_driver <- function(FARS){

  message("Note: Older drivers are defined as those aged 65+.")

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      mutate(age_n = as.numeric(stringr::word(.data$age, 1, sep = " "))) %>%
      filter(.data$age_n >= 65) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
    FARS %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      mutate(age_n = as.numeric(stringr::word(.data$age, 1, sep = " "))) %>%
      filter(.data$age_n >= 65) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }

}


speeding <- function(FARS){

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
      filter(grepl("Yes", .data$speedrel)) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
    FARS %>%
      filter(grepl("Yes", .data$speedrel)) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }

}


alcohol <- function(FARS){

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
      filter(.data$dr_drink == "Yes") %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
    FARS %>%
      filter(.data$dr_drink == "Yes") %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }

}


drugs <- function(FARS){

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      filter(grepl("Yes", .data$drugs)) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
    FARS %>%
      filter(.data$per_typ == "Driver of a Motor Vehicle In-Transport") %>%
      filter(grepl("Yes", .data$drugs)) %>%
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }

}


large_trucks <- function(FARS){

  if("FARS" %in% class(FARS)){
    FARS$flat %>%
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
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  } else{
    FARS %>%
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
      select(.data$state, .data$st_case, .data$year) %>%
      unique() %>%
      return()
  }


}
