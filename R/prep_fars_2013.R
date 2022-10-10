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



# REMEMBER THAT THIS IS CURRENTLY LISTED IN .RBuildignore

prep_fars_2013 <- function(y, wd, rawfiles, prepared_dir, geo_filtered){



# core files ----

  ## accident ----

  fars.accident <- read_basic_csv(x = "accident", wd = wd, rawfiles = rawfiles)

  ## vehicle ----

  fars.vehicle <-
    read_basic_csv(x = "vehicle", wd = wd, rawfiles = rawfiles) %>%
    select(
      -starts_with("vin_"),
      -setdiff(intersect(names(fars.accident), names(.)),
               c("state", "st_case")),
      -contains("gvwr")
      )


  ## person ----

  fars.person <-
    read_basic_csv(x = "person", wd = wd, rawfiles = rawfiles) %>%
    select(-setdiff(intersect(names(fars.accident), names(.)), c("state", "st_case"))) %>%
    select(-setdiff(intersect(names(fars.vehicle), names(.)), c("state", "st_case", "veh_no")))


# accident-level files ----


  ## multiple-row files ----

    ### cevent ----

    fars.cevent <- read_basic_csv(x = "cevent", wd = wd, rawfiles = rawfiles)

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

    ### distract ----

    fars.distract <- read_basic_csv(x = "distract", wd = wd, rawfiles = rawfiles)

    ### drimpair ----

    fars.drimpair <- read_basic_csv(x = "drimpair", wd = wd, rawfiles = rawfiles)

    ### factor ----

    fars.factor <- read_basic_csv(x = "factor", wd = wd, rawfiles = rawfiles)

    ### maneuver ----

    fars.maneuver <- read_basic_csv(x = "maneuver", wd = wd, rawfiles = rawfiles)

    ### violatn ----

    fars.violatn <- read_basic_csv(x = "violatn", wd = wd, rawfiles = rawfiles)

    ### vision ----

    fars.vision <- read_basic_csv(x = "vision", wd = wd, rawfiles = rawfiles)

    ### damage ----

    fars.damage <- read_basic_csv(x = "damage", wd = wd, rawfiles = rawfiles)

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

    # NOTE this was moved from the vehicle file in 2020

    # fars.pvehiclesf <- fars.vehicle %>%
    #   select(state, st_case, veh_no, veh_sc1, veh_sc2) %>%
    #   mutate_all(as.character) %>%
    #   pivot_longer(cols = -c(1:3), values_to = "pvehiclesf") %>%
    #   select(-name) %>%
    #   unique()
    #
    # fars.vehicle <- fars.vehicle %>% select(-starts_with("veh_sc"))

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

  # NOTE data was not captured prior to 2014

  ## safetyeq ----

  fars.safetyeq <-
    read_basic_csv(x = "safetyeq", wd = wd, rawfiles = rawfiles) %>%
    select(-setdiff(intersect(names(fars.person), names(.)),
                    c("state", "st_case", "veh_no", "per_no")))


  ## multi-row files ----

    ### nmcrash ----

    fars.nmcrash <- read_basic_csv(x = "nmcrash", wd = wd, rawfiles = rawfiles)

    ### nmimpair ----

    fars.nmimpair <- read_basic_csv(x = "nmimpair", wd = wd, rawfiles = rawfiles)

    ### nmprior ----

    fars.nmprior <- read_basic_csv(x = "nmprior", wd = wd, rawfiles = rawfiles)

    ### x nmdistract ----

    # NOTE this data was not captured prior to 2019

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
    left_join(fars.person, by = c("state", "st_case")) %>%
    #! This order (accident >> person >> vehicle) is very important for including non-motorists
    left_join(fars.vehicle, by = c("state", "st_case", "veh_no")) %>%
    #left_join(fars.pbtype, by = c("state", "st_case", "veh_no", "per_no")) %>%
    left_join(fars.safetyeq, by = c("state", "st_case", "veh_no", "per_no")) %>%
    as.data.frame() %>%

  # State filter
    filter(state %in% unique(c(geo_filtered$state_name_full, geo_filtered$fips_state))) %>%

  # Dates
    # mutate(
    #   date_crash = lubridate::make_datetime(year, match(month, month.name), day, hour, minute),
    #   date_death = lubridate::make_datetime(death_yr, match(death_mo, month.name), death_da, death_hr, death_mn),
    #   ) %>%

  # Generate state-independent id for each crash
    mutate(id = paste0(year, st_case)) %>%

  # Final organization
    select(year, state, st_case, id,
           #date_crash,
           veh_no, per_no,
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
      fars.driverrf %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3)),
      fars.drimpair %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3)),
      fars.distract %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3)),
      fars.factor %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3)),
      fars.maneuver %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3)),
      fars.violatn %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3)),
      fars.vision %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3)),
      fars.damage %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3))
      )

  multi_per <-
    bind_rows(
      fars.race %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:4)),
      fars.personrf %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:4)),
      fars.drugs %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:4)),
      fars.nmcrash %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:4)),
      fars.nmimpair %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:4)),
      fars.nmprior %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:4))
      )


# return ----

  write_csv(fars, paste0(prepared_dir, y, "_flat.csv"))
  write_csv(multi_acc, paste0(prepared_dir, y, "_multi_acc.csv"))
  write_csv(multi_veh, paste0(prepared_dir, y, "_multi_veh.csv"))
  write_csv(multi_per, paste0(prepared_dir, y, "_multi_per.csv"))

}
