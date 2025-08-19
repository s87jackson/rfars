#' Generate counts
#'
#' Use FARS or GES/CRSS data to generate commonly requested counts.
#'
#' @export
#'
#' @param df The input data object (must be of class 'FARS' or 'GESCRSS' as is produced by get_fars() and get_gescrss()).
#' @param what What to count: crashes (the default), fatalities, injuries, or people involved.
#' @param interval The interval in which to count: months or years (the default).
#' @param where Where to count. Must be a list with any of the elements:
#'    states (can be 'all', full or abbreviated state names, or FIPS codes),
#'    region ('all', 'ne', 'mw', 's', or 'w'; short for northeast, midwest, south, and west),
#'    urb ('all', 'rural', or 'urban'). Any un-specified elements are set to 'all' by default.
#' @param who The type of person to count: 'all' (default) 'drivers', 'passengers', 'pedestrians', or 'bicyclists'.
#' @param involved Factors involved with the crash: 'any' (the default, produces general counts),
#'     'each' (produces separate counts for each factor), 'distracted driver',
#'     'police pursuit', 'motorcycle', 'pedalcyclist', 'bicyclist', 'pedestrian',
#'     'pedbike', 'young driver', 'older driver', 'speeding','alcohol', 'drugs',
#'     'hit and run', 'roadway departure', 'rollover', or 'large trucks'.
#' @param filterOnly Logical, whether to only filter data or reduce to counts (FALSE by default).
#'
#' @return Either a filtered tibble (filterOnly=TRUE) or a tibble of counts
#'     (filterOnly=FALSE). If filterOnly=TRUE, the tibble that is returned is
#'     the 'flat' tibble from the input FARS object, filtered according to other
#'     parameters.
#'
#'     If `df` is a GESCRSS object, the counts returned are the sum of the appropriate weights.
#'
#' @import lubridate
#' @importFrom rlang .data
#' @importFrom stringr word
#'
#' @examples
#'
#'   \dontrun{
#'     counts(get_fars(years = 2019), where = list(states="Virginia", urb="rural"))
#'   }



counts <- function(df,
                   what=c("crashes", "fatalities", "injuries", "people")[1],
                   interval=c("year", "month")[1],
                   where=list(states="all",
                              region = c("all", "ne", "mw", "s", "w")[1],
                              urb=c("all", "rural", "urban")[1]),
                   who=c("all", "drivers", "passengers", "bicyclists", "pedestrians")[1],
                   involved = c("any", "each", "alcohol", "bicyclist", "distracted driver", "drugs", "hit and run", "large trucks", "motorcycle", "older driver", "pedalcyclist", "pedbike", "pedestrian", "police pursuit", "roadway departure", "rollover", "speeding", "young driver")[1],
                   filterOnly=FALSE){

  if(!(any(class(df) %in% c("FARS", "GESCRSS")))){
    stop("Input data must be of type FARS or GESCRSS. Use the results of get_fars() or get_gescrss().")
  }

  flat <- df$flat

  # Resolve unspecified parameters ----
    if(!("states" %in% names(where))) where[["states"]] <- "all"
    if(!("region" %in% names(where))) where[["region"]] <- "all"
    if(!("urb"    %in% names(where))) where[["urb"]] <- "all"


  # What ----
  # (also determines how counts are done)
    if(what == "fatalities") flat <- flat %>% filter(.data$inj_sev == "Fatal Injury (K)")
    if(what == "injuries")   flat <- flat %>% filter(.data$inj_sev %in% c("Incapacitating Injury (A)",
                                                                          "Suspected Serious Injury (A)",
                                                                          "Suspected Serious Injury(A)",
                                                                          "Non-incapacitating Evident Injury (B)",
                                                                          "Suspected Minor Injury (B)",
                                                                          "Suspected Minor Injury(B)",
                                                                          "Possible Injury (C)",
                                                                          "Injured, Severity Unknown"
                                                                          ))

  # Interval ----

    if("month" %in% interval){
      flat$date = lubridate::make_date(flat$year, match(flat$month, month.name))
    } else{
      flat$date = lubridate::make_date(flat$year, 1, 1)
      }

    interval <- c(interval, "date")

    flat <- flat %>% group_by(across(all_of(interval)), .add=FALSE)


  # Where ----

    if(where$states != "all"){

      mystates <- rfars::geo_relations %>% filter(.data$state_name_abbr %in% where$states |
                                                  .data$state_name_full %in% where$states |
                                                  .data$fips_state %in% where$states) %>%
        pull("state_name_full") %>% unique()

      if("FARS" %in% class(df)){
        validate_states(where$states)
        flat <- flat %>% filter(.data$state %in% mystates)
      }

      if("GESCRSS" %in% class(df)) stop("Cannot subset GESCRSS by state. Use region instead.")

    }


    if(where$region != "all"){

      if("GESCRSS" %in% class(df)){

        myregions <- filter(rfars::geo_relations, .data$region_abbr %in% where$region) %>% pull("region") %>% unique()
        flat <- filter(flat, .data$region %in% myregions)

      }

      if("FARS" %in% class(df)){

        myregionstates <- filter(rfars::geo_relations, .data$region_abbr %in% where$region) %>% pull("state_name_full") %>% unique()
        flat <- filter(flat, .data$state %in% myregionstates)

      }

    }


    if(where$urb != "all"){

      if("GESCRSS" %in% class(df)){

        myurb <- paste0(where$urb, " area")
        flat <- filter(flat, tolower(.data$urbanicity) == myurb)

      }

      if("FARS" %in% class(df)){

        flat <- filter(flat, tolower(.data$rur_urb) == tolower(where$urb))

      }

    }


  # Involved ----

    if ("any" %in% involved && length(involved) > 1) stop("'involved' cannot contain both 'any' and other values.")

    if ("each" %in% involved && length(involved) > 1) stop("'involved' cannot contain both 'each' and other values.")

    if ("each" %in% involved && filterOnly == TRUE) stop("To use involved = 'each', set filterOnly = FALSE")

    if(involved == "any") flat$involved <- "any"


    if(length(involved)>=1 && !(any(c("any", "each") %in% involved))){

      if("distracted driver" %in% involved) flat <- inner_join(flat, distracted_driver(df), by = c("year", "id"))
      if("police pursuit" %in% involved)    flat <- inner_join(flat, police_pursuit(df), by = c("year", "id"))
      if("alcohol" %in% involved)           flat <- inner_join(flat, alcohol(df), by = c("year", "id"))
      if("motorcycle" %in% involved)        flat <- inner_join(flat, motorcycle(df), by = c("year", "id"))
      if("pedalcyclist" %in% involved)      flat <- inner_join(flat, pedalcyclist(df), by = c("year", "id"))
      if("pedestrian" %in% involved)        flat <- inner_join(flat, pedestrian(df), by = c("year", "id"))
      if("bicyclist" %in% involved)         flat <- inner_join(flat, bicyclist(df), by = c("year", "id"))
      if("pedbike" %in% involved)           flat <- inner_join(flat, pedbike(df), by = c("year", "id"))
      if("young driver" %in% involved)      flat <- inner_join(flat, driver_age(df, 15, 20), by = c("year", "id"))
      if("older driver" %in% involved)      flat <- inner_join(flat, driver_age(df, 65, 100), by = c("year", "id"))
      if("speeding" %in% involved)          flat <- inner_join(flat, speeding(df), by = c("year", "id"))
      if("drugs" %in% involved)             flat <- inner_join(flat, drugs(df), by = c("year", "id"))
      if("large trucks" %in% involved)      flat <- inner_join(flat, large_trucks(df), by = c("year", "id"))
      if("hit and run" %in% involved)       flat <- inner_join(flat, hit_and_run(df), by = c("year", "id"))
      if("roadway departure" %in% involved) flat <- inner_join(flat, road_depart(df), by = c("year", "id"))
      if("rollover" %in% involved)          flat <- inner_join(flat, rollover(df), by = c("year", "id"))

      if(length(involved)==1){
        flat$involved <- involved
      } else{
        flat$involved <- paste(involved, collapse = " AND ")
      }

    }


    if(length(involved) == 1 && involved == "each"){

      # Master list of all possible types
      all_involved <- c(
        "alcohol", "bicyclist", "distracted driver", "drugs", "hit and run", "large trucks",
        "motorcycle", "older driver", "pedalcyclist", "pedbike", "pedestrian",
        "police pursuit", "roadway departure", "rollover", "speeding", "young driver"
      )

      # Named list of data-generating functions
      involved_functions <- list(
        "alcohol"             = alcohol,
        "bicyclist"           = bicyclist,
        "distracted driver"   = distracted_driver,
        "drugs"               = drugs,
        "hit and run"         = hit_and_run,
        "large trucks"        = large_trucks,
        "motorcycle"          = motorcycle,
        "older driver"        = function(df) driver_age(df, 65, 100),
        "pedalcyclist"        = pedalcyclist,
        "pedbike"             = pedbike,
        "pedestrian"          = pedestrian,
        "police pursuit"      = police_pursuit,
        "roadway departure"   = road_depart,
        "rollover"            = rollover,
        "speeding"            = speeding,
        "young driver"        = function(df) driver_age(df, 15, 20)
      )



      # Stack results
      combined <- map_dfr(
        all_involved,
        function(type) {
          result <- inner_join(flat, involved_functions[[type]](df), by = c("year", "id"))
          result$involved <- type
          result
        }
      )

      flat <- combined

    }




  # Who ----
    if(all(who != "all")){

      who_convert <- data.frame(
        simple = c("bicyclists", "pedestrians", "drivers", "passengers"),
        indata = c("Bicyclist", "Pedestrian",
                   "Driver of a Motor Vehicle In-Transport",
                   "Passenger of a Motor Vehicle In-Transport")
        )

      flat <- filter(flat, .data$per_typ %in% who_convert$indata[who_convert$simple %in% who])

    }


  # Count ----

    interval <- setdiff(interval, "date")

    if(filterOnly){

      return(flat)

    } else{

      if("GESCRSS" %in% class(df)){

        if(what == "crashes"){
          flat <- flat %>%
            select(any_of(c("id", interval, "weight", "involved", "date", "involved"))) %>%
            distinct() %>%
            group_by(across(any_of(c(interval, "involved")))) %>%
            summarize(n=sum(.data$weight, na.rm = T), .groups = "drop")
        }


        if(what %in% c("fatalities", "people", "injuries")) {
          flat <- flat %>%
            select(any_of(c("id", "veh_no", "per_no", interval, "weight", "involved", "date"))) %>%
            distinct() %>%
            group_by(across(any_of(c(interval, "involved")))) %>%
            summarize(n=sum(.data$weight, na.rm = T), .groups = "drop")
        }

      }

      if("FARS" %in% class(df)){

        if(what == "crashes"){
          flat <- flat %>%
            group_by(across(any_of(c(interval, "involved")))) %>%
            summarize(n=n_distinct(.data$id), .groups = "drop")
          }

        if(what %in% c("fatalities", "people", "injuries")) {
          flat <- flat %>%
            group_by(across(any_of(c(interval, "involved")))) %>%
            summarize(n=n_distinct(.data$id, .data$veh_no, .data$per_no), .groups = "drop")
          }

      }

    }


  # return ----

    if("month" %in% interval){
      flat$month_num <- match(flat$month, month.name)
      flat$month <- factor(month.abb[flat$month_num], levels = month.abb, ordered = TRUE)
    }


    if("involved" %in% names(flat)){
      flat %>%
        mutate(
          what=what,
          states= ifelse(is.null(where$states), "all", where$states),
          region=where$region,
          urb=where$urb,
          who=who
        ) %>%
        arrange(across(all_of(interval))) %>%
        select(any_of(c(interval, "what", "states", "region", "urb", "who", "involved", "n"))) %>%
        return()
    } else{
      flat %>%
        mutate(
          what=what,
          states= ifelse(is.null(where$states), "all", where$states),
          region=where$region,
          urb=where$urb,
          who=who,
          involved=involved
        ) %>%
        arrange(across(all_of(interval))) %>%
        select(any_of(c(interval, "what", "states", "region", "urb", "who", "involved", "n"))) %>%
        return()
    }



}
