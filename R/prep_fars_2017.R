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


prep_fars_2017 <- function(y, wd, rawfiles, prepared_dir, geo_filtered){



# core files ----

  ## accident ----

    fars.accident <-
      read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="accident"]), col_types = cols()) %>%
      janitor::clean_names() %>%
      usenames()


  ## vehicle ----

    fars.vehicle <-
      read_csv(paste0(wd, rawfiles$filename[rawfiles$cleaned=="vehicle"]), col_types = cols()) %>%
      janitor::clean_names() %>%
      usenames() %>%
      select(
        -starts_with("vin_"),
        -setdiff(intersect(names(fars.accident), names(.)),
                 c("state", "st_case")),
        -gvwr #discontinued...vpic
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

        # NOTE this moves from the accident file to the weather file in 2020

        fars.weather <-
          fars.accident %>%
          select(state, st_case, weather1, weather2) %>%
          mutate_all(as.character) %>%
          pivot_longer(cols = -c(1:2), values_to = "weather") %>%
          select(-name) %>%
          filter(weather != "No Additional Atmospheric Conditions")

        fars.accident <- fars.accident %>% select(-contains("weather"))


    ### crashrf ----

        # NOTE this moves from the accident file to the weather file in 2020

        fars.crashrf <-
          fars.accident %>%
          select(state, st_case, cf1, cf2, cf3) %>%
          mutate_all(as.character) %>%
          pivot_longer(cols = -c(1:2), values_to = "crashrf") %>%
          select(-name) %>%
          unique()

        fars.accident <- fars.accident %>% select(-c(cf1, cf2, cf3))



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

        # NOTE this was moved from the vehicle file in 2020

        fars.vehiclesf <-
          fars.vehicle %>%
          select(state, st_case, veh_no, veh_sc1, veh_sc2) %>%
          mutate_all(as.character) %>%
          pivot_longer(cols = -c(1:3), values_to = "vehiclesf") %>%
          select(-name) %>%
          unique()

        fars.vehicle <- fars.vehicle %>% select(-starts_with("veh_sc"))


    ### x pvehiclesf ----

    ### driverrf ----

        # NOTE this was moved from the vehicle file in 2020

        fars.driverrf <-
          fars.vehicle %>%
          select(state, st_case, veh_no, dr_sf1, dr_sf2, dr_sf3, dr_sf4) %>%
          mutate_all(as.character) %>%
          pivot_longer(cols = -c(1:3), values_to = "driverrf") %>%
          select(-name) %>%
          unique()

        fars.vehicle <- fars.vehicle %>% select(-starts_with("dr_sf"))




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

        # NOTE this was moved from the person file in 2018

        fars.drugs <-
          fars.person %>%
          select(state, st_case, veh_no, per_no, drugtst1:drugres3) %>%
          mutate_all(as.character) %>%
          pivot_longer(cols = -c(1:4)) %>%
          mutate(what = substr(name, 5, 7),
                 what = ifelse(what=="tst", "drugspec", "drugres"),
                 num  = substr(name, 8, 8)) %>%
          select(-name) %>%
          unique() %>%
          pivot_wider(names_from = "what", values_from = "value") %>%
          select(-num) %>%
          unique()

        fars.person <- fars.person %>% select(-starts_with("drugtst"), -starts_with("drugres"))


    ### race ----

        # NOTE this was moved from the person file in 2019

        fars.race <-
          fars.person %>%
          select(state, st_case, veh_no, per_no, race) %>%
          mutate_all(as.character) %>%
          pivot_longer(cols = -c(1:4), values_to = "race") %>%
          select(-name) %>%
          unique()

        fars.person <- fars.person %>% select(-race)


    ### personrf ----

        # NOTE this was moved from the person file in 2020

        fars.personrf <-
          fars.person %>%
          select(state, st_case, veh_no, per_no, p_sf1, p_sf2, p_sf3) %>%
          mutate_all(as.character) %>%
          pivot_longer(cols = -c(1:4), values_to = "personrf") %>%
          select(-name) %>%
          unique()

        fars.person <- fars.person %>% select(-starts_with("p_sf"))



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
