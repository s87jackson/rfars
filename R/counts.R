#' Generate a variety of counts from FARS data
#'
#' @param FARS The input FARS data with flat and multi components.
#' @param what What to count: crashes, fatalities, people involved.
#' @param when The years over which to count.
#' @param interval The interval in which to count: months or years.
#' @param where Where to count: can specify rural/urban and/or state (e.g.,
#'     where = "rural Virginia", where = "rural", where = "North Carolina")
#' @param who The type of person to count: driver, passenger, pedestrian,
#'     bicyclist, or motorcyclist.
#' @param involved Factors involved with the crash. Can be any of: distracted
#'     driver, drowsy driver, police pursuit, motorcycle, pedalcyclist,
#'     bicyclist, pedestrian, pedbike, young driver, older driver, speeding,
#'     alcohol, drugs, hit and run, roadway departure, rollover, or large
#'     trucks.
#' @param filterOnly Logical, whether to only filter or reduce to counts.
#'
#' @details ...
#'
#' @importFrom timetk pad_by_time
#' @import lubridate
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' get_fars(years = 2016:2020, states="Virginia") %>%
#'   use_fars()
#'   counts(
#'     what = "fatalities",
#'     when = 2016:2020,
#'     who = c("bicyclists", "pedestrians"),
#'     where = "urban"
#'     ) %>%
#'   ggplot(aes(x=date, y=n, label=scales::comma(n))) + geom_col() + geom_label()
#'   }




#' @export
counts <- function(FARS, what="crashes",
                   when, interval="year",
                   where=NULL, who=NULL, involved=NULL,
                   filterOnly=FALSE){

  flat <- FARS$flat

  # Involved
    if("distracted driver" %in% involved) flat <- inner_join(flat, distracted_driver(FARS), by = c("year", "state", "st_case"))
    if("drowsy driver" %in% involved)     flat <- inner_join(flat, drowsy_driver(FARS), by = c("year", "state", "st_case"))
    if("police pursuit" %in% involved)    flat <- inner_join(flat, police_pursuit(FARS), by = c("year", "state", "st_case"))
    if("motorcycle" %in% involved)        flat <- inner_join(flat, motorcycle(FARS), by = c("year", "state", "st_case"))
    if("pedalcyclist" %in% involved)      flat <- inner_join(flat, pedalcyclist(FARS), by = c("year", "state", "st_case"))
    if("pedestrian" %in% involved)        flat <- inner_join(flat, pedestrian(FARS), by = c("year", "state", "st_case"))
    if("bicyclist" %in% involved)         flat <- inner_join(flat, bicyclist(FARS), by = c("year", "state", "st_case"))
    if("pedbike" %in% involved)           flat <- inner_join(flat, pedbike(FARS), by = c("year", "state", "st_case"))
    if("young driver" %in% involved)      flat <- inner_join(flat, young_driver(FARS), by = c("year", "state", "st_case"))
    if("older driver" %in% involved)      flat <- inner_join(flat, older_driver(FARS), by = c("year", "state", "st_case"))
    if("speeding" %in% involved)          flat <- inner_join(flat, speeding(FARS), by = c("year", "state", "st_case"))
    if("alcohol" %in% involved)           flat <- inner_join(flat, alcohol(FARS), by = c("year", "state", "st_case"))
    if("drugs" %in% involved)             flat <- inner_join(flat, drugs(FARS), by = c("year", "state", "st_case"))

    if("large trucks" %in% involved)      flat <- inner_join(flat, large_trucks(FARS), by = c("year", "state", "st_case"))

    if("hit and run" %in% involved) flat <- flat %>% filter(.data$hit_run == "Yes")
    if("roadway departure" %in% involved) flat <- flat %>% filter(grepl("departure", .data$acc_type, ignore.case = TRUE))
    if("rollover" %in% involved) flat <- flat %>% filter(!grepl("No Roll", .data$rollover))

    # large trucks

  # When and interval
    #when = 2020
    #when = 2016:2020
    #interval = "month"
    #interval = "year"
    #interval = c("year", "month")
    flat <-
      flat %>%
      filter(data.table::between(.data$year, when[1], when[length(when)])) %>%
      group_by(across(all_of(interval)), .add=FALSE)


  # Who
    #who = "bicyclists"
    #who = "drivers"
    if(!is.null(who)){

      who_convert <- data.frame(
        simple = c("bicyclists", "pedestrians", "drivers", "passengers"),
        indata = c("Bicyclist", "Pedestrian",
                   "Driver of a Motor Vehicle In-Transport",
                   "Passenger of a Motor Vehicle In-Transport")
        )

      flat <-
        flat %>%
        filter(.data$per_typ %in% who_convert$indata[who_convert$simple %in% who])

    }


  # What
    #what = "crashes"
    #what = "fatalities"
    #what = "people"

    if(what == "fatalities") flat <- flat %>% filter(.data$inj_sev=="Fatal Injury (K)")


  # Where
    #where = "rural Virginia"
    #where = "rural"
    #where = "urban Virginia"
    #where = "Virginia"

    if(!is.null(where)){

      if(grepl("rural", tolower(where))) flat <- flat %>% filter(.data$rur_urb == "Rural")
      if(grepl("urban", tolower(where))) flat <- flat %>% filter(.data$rur_urb == "Urban")

      where_state <- gsub(x = where, "rural", "", ignore.case = FALSE)
      where_state <- gsub(x = where_state, "urban", "", ignore.case = FALSE)
      where_state <- trimws(where_state)

      if(!is.null(where_state) & where_state != "") flat <- flat %>% filter(.data$state == where_state)

    }


  # Count

    if(!filterOnly){

      if(what == "crashes") flat <- flat %>% summarize(n=n_distinct(.data$id))

      if(what %in% c("fatalities", "people")) {
        flat <- flat %>% summarize(n=n_distinct(.data$id, .data$veh_no, .data$per_no))
        }


    # Pad
      if("year" %in% interval & "month" %in% interval){

        flat <-
          flat %>%
          ungroup() %>%
          mutate(date = lubridate::make_date(.data$year, match(.data$month, month.name))) %>%
          timetk::pad_by_time(.date_var = .data$date, .by = "month", .pad_value = 0) %>%
          mutate(month = lubridate::month(.data$date, label = TRUE, abbr = FALSE),
                 year  = lubridate::year(.data$date))

      }

      if(length(interval)==1){

        if(interval == "year"){

          flat <-
            flat %>%
            ungroup() %>%
            mutate(date = lubridate::make_date(.data$year)) %>%
            timetk::pad_by_time(.date_var = .data$date, .by = "year", .pad_value = 0) %>%
            mutate(year  = lubridate::year(.data$date))

        }


        if(interval == "month"){

          flat <-
            data.frame(month = month.name) %>%
            left_join(ungroup(flat)) %>%
            mutate(n = ifelse(is.na(n), 0, n))

        }

      }

    }


  # return
    return(flat)

}
