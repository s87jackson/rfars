#' Handle yyyy data preparation
#'
#' @param y year, to be passed from \code{prep_fars}
#' @param wd working directory, , to be passed from \code{prep_fars}
#' @param rawfiles dataframe translating filenames into standard terms,
#'     to be passed from \code{prep_fars}
#' @param prepared_dir the location where prepared files will be saved,
#'     to be passed from \code{prep_fars}
#' @param geo_filtered dataframe of filtered geo-identifiers, to be passed
#'     from \code{prep_fars}
#'
#' @return Produces four files for each year: yyyy_flat.csv, yyyy_multi_acc.csv,
#'     yyyy_multi_veh.csv, and yyyy_multi_per.csv


prep_fars_2020 <- function(y, wd, rawfiles, prepared_dir, geo_filtered){



# core files ----

  ## accident ----

    fars.accident <-
      read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="accident"]), col_types = cols()) %>%
      janitor::clean_names() %>%
      usenames() %>%
      select(-weather)


  ## vehicle ----

    # NOTE several variables appear here for the first time:
    # "vpicmake"      "vpicmodel"     "vpicbodyclass"
    # "icfinalbody"   "gvwr_from"     "gvwr_to"       "trlr1gvwr"
    # "trlr2gvwr"     "trlr3gvwr"

    fars.vehicle <-
      read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="vehicle"]), col_types = cols()) %>%
      janitor::clean_names() %>%
      usenames() %>%
      select(
        -starts_with("vin_"),
        -setdiff(intersect(names(fars.accident), names(.)),
                 c("state", "st_case"))
        )


  ## person ----

    fars.person <-
      read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="person"]), col_types = cols()) %>%
      janitor::clean_names() %>%
      usenames() %>%
      select(-setdiff(intersect(names(fars.accident), names(.)), c("state", "st_case"))) %>%
      select(-setdiff(intersect(names(fars.vehicle), names(.)), c("state", "st_case", "veh_no")))


# accident-level files ----


  ## multiple-row files ----

    ### cevent ----

      fars.cevent <-
          read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="cevent"]), col_types = cols()) %>%
          janitor::clean_names() %>%
          usenames()


    ### weather ----

        fars.weather <-
          read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="weather"]), col_types = cols()) %>%
          janitor::clean_names() %>%
          usenames()


    ### crashrf ----

        fars.crashrf <-
          read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="crashrf"]), col_types = cols()) %>%
          janitor::clean_names() %>%
          usenames()



# vehicle-level files ----


  ## x parkwork ----


  ## multi-row files ----

    ### x vsoe ----
    ### x distract ----
    ### x drimpair ----
    ### x factor ----
    ### x maneuver ----
    ### x violatn ----
    ### x vision ----
    ### x damage ----

    ### vehiclesf ----

        fars.vehiclesf <-
          read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="vehiclesf"]), col_types = cols()) %>%
          janitor::clean_names() %>%
          usenames()


    ### x pvehiclesf ----

    ### driverrf ----

        fars.driverrf <-
          read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="driverrf"]), col_types = cols()) %>%
          janitor::clean_names() %>%
          usenames()




# person-level files ----

  ## pbtype ----

    fars.pbtype <-
      read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="pbtype"]), col_types = cols()) %>%
      janitor::clean_names() %>%
      usenames() %>%
      select(-setdiff(intersect(names(fars.person), names(.)), c("state", "st_case", "veh_no", "per_no"))) %>%
      select(-pbptype, -pbage, -pbsex)


  ## safetyeq ----

    fars.safetyeq <-
      read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="safetyeq"]), col_types = cols()) %>%
      janitor::clean_names() %>%
      usenames() %>%
      select(-setdiff(intersect(names(fars.person), names(.)), c("state", "st_case", "veh_no", "per_no")))


  ## multi-row files ----

    ### x nmcrash ----
    ### x nmimpair ----
    ### x nmprior ----
    ### x nmdistract ----

    ### drugs ----

        fars.drugs <-
          read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="drugs"]), col_types = cols()) %>%
          janitor::clean_names() %>%
          usenames()


    ### race ----

        fars.race <-
          read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="race"]), col_types = cols()) %>%
          janitor::clean_names() %>%
          usenames() %>%
          select(-setdiff(intersect(names(fars.person), names(.)), c("state", "st_case", "veh_no", "per_no")))


    ### personrf ----

        fars.personrf <-
          read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="personrf"]), col_types = cols()) %>%
          janitor::clean_names() %>%
          usenames() %>%
          select(-setdiff(intersect(names(fars.person), names(.)), c("state", "st_case", "veh_no", "per_no")))






# produce flat file ----

  fars <-
    fars.accident %>%
    left_join(fars.person) %>% #! This order (accident >> person >> vehicle) is very important for including non-motorists
    left_join(fars.vehicle) %>%
    left_join(fars.pbtype) %>%
    left_join(fars.safetyeq) %>%
    as.data.frame() %>%

  # State filter
    filter(state %in% geo_filtered$state_name) %>%

  # Dates
    mutate(
      date_crash = lubridate::make_datetime(year, match(month, month.name), day, hour, minute),
      date_death = lubridate::make_datetime(death_yr, match(death_mo, month.name), death_da, death_hr, death_mn),
      ) %>%

  # Generate state-independent id for each crash
    mutate(id = paste0(year, st_case)) %>%

  # Final organization
    select(year, state, st_case, id, date_crash, veh_no, per_no,
           county, city,
           lon = longitud,
           lat = latitude,
           everything())



# concatenate long files for multi-row files ----

  multi_acc <-
    bind_rows(
      fars.cevent %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:2)),
      fars.weather %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:2)),
      fars.crashrf %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:2))
      )

  multi_veh <-
    bind_rows(
      fars.vehiclesf %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3)),
      fars.driverrf %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3))
      )

  multi_per <-
    bind_rows(
      fars.race %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:4)),
      fars.personrf %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:4)),
      fars.drugs %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:4))
      )


# return ----

  write_csv(fars, paste0(prepared_dir, y, "_flat.csv"))
  write_csv(multi_acc, paste0(prepared_dir, y, "_multi_acc.csv"))
  write_csv(multi_veh, paste0(prepared_dir, y, "_multi_veh.csv"))
  write_csv(multi_per, paste0(prepared_dir, y, "_multi_per.csv"))

}
