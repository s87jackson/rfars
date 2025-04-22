#' Prepare downloaded FARS files for use
#'
#' @param y year, to be passed from \code{prep_fars}
#' @param wd working directory, , to be passed from \code{prep_fars}
#' @param rawfiles dataframe translating filenames into standard terms,
#'     to be passed from \code{prep_fars}
#' @param prepared_dir the location where prepared files will be saved,
#'     to be passed from \code{prep_fars}
#' @param states (Optional) Inherits from get_fars()
#'
#' @return Produces six files: yyyy_flat.rds, yyyy_multi_acc.rds,
#'     yyyy_multi_veh.rds, yyyy_multi_per.rds, yyyy_events.rds, and codebook.rds
#'
#' @importFrom rlang .data


prep_fars <- function(y, wd, rawfiles, prepared_dir, states){

  cat("Preparing raw data files...\n")

# Setup

  fars.accident <- fars.vehicle <- fars.person <- NULL

  fars.vsoe <- fars.distract <- fars.drimpair <- fars.factor <-
    fars.maneuver <- fars.violatn <- fars.vision <- fars.damage <- fars.vehiclesf <-
    fars.pvehiclesf <- fars.driverrf <- fars.pbtype <- NULL

  fars.nmcrash <- fars.nmimpair <- fars.nmprior <- fars.nmdistract <-
    fars.drugs <- fars.race <- fars.personrf <- NULL

  my_catfile <-
    data.frame(filename = list.files(wd, recursive = T, full.names = T)) %>%
    filter(stringr::str_detect(.data$filename, "sas7bcat")) %>%
    arrange(desc(.data$filename)) %>%
    slice(1) %>%
    as.character()

  # if(y %in% 2016:2021)          my_catfile <- paste0(wd, "format-64/formats.sas7bcat")
  # if(y %in% c(2011, 2014:2015)) my_catfile <- paste0(wd, "formats.sas7bcat")
  if(y %in% 2021:2023) my_catfile <- paste0(wd, "format-viya/formats.sas7bcat")
  if(y %in% 2012:2013) my_catfile <- FALSE

  if(!is.null(states)){
    geo_filtered <-
      rfars::geo_relations %>%
      filter(.data$fips_state %in% states | .data$state_name_abbr %in% states | .data$state_name_full %in% states)
    } else{
      geo_filtered <- rfars::geo_relations
    }


# Core files ----

  ## accident ----

  if(y %in% 2015:2023){
    fars.accident <-
      read_basic_sas(x = "accident", wd = wd, rawfiles = rawfiles, catfile = my_catfile) %>%
      dplyr::distinct()
  }

  if(y %in% 2011:2014){
    fars.accident <-
      read_basic_sas(x = "accident", wd = wd, rawfiles = rawfiles, catfile = my_catfile) %>%
      dplyr::distinct() %>%
      mutate(rur_urb = case_when(
        grepl("Rural", .data$road_fnc) ~ "Rural",
        grepl("Urban", .data$road_fnc) ~ "Urban",
        TRUE ~ as.character(NA)))
  }

  cat(paste0("\u2713 ", "Accident file processed\n"))

  ## vehicle ----

  fars.vehicle <-
    read_basic_sas(
      x = "vehicle",
      wd = wd,
      rawfiles = rawfiles,
      catfile = my_catfile,
      omits = c(names(fars.accident))
      ) %>%
    select(-starts_with("vin_")) %>%
    dplyr::distinct()

  cat(paste0("\u2713 ", "Vehicle file processed\n"))

  ## person ----

  fars.person <-
    read_basic_sas(
      x = "person",
      wd = wd,
      rawfiles = rawfiles,
      catfile = my_catfile,
      omits = c(names(fars.accident), names(fars.vehicle))
      ) %>%
    dplyr::distinct()

  cat(paste0("\u2713 ", "Person file processed\n"))


# Accident-level files ----

  ## weather ----

  if(y %in% 2020:2023){
    fars.weather <- read_basic_sas(x = "weather", wd = wd, rawfiles = rawfiles, catfile = my_catfile)
  } else{
    fars.weather  <- select(fars.accident, "state", "st_case", "weather1", "weather2")
  }

  fars.accident <- select(fars.accident, -contains("weather"))

  cat(paste0("\u2713 ", "Weather file(s) processed\n"))


  ## crashrf ----

  if(y %in% 2020:2023){
    fars.crashrf <- read_basic_sas(x = "crashrf", wd = wd, rawfiles = rawfiles, catfile = my_catfile)
  } else{
    fars.crashrf  <- select(fars.accident, "state", "st_case", "cf1", "cf2", "cf3")
  }

  fars.accident <- select(fars.accident, -any_of(c("cf1", "cf2", "cf3")))

  cat(paste0("\u2713 ", "Crash risk factors file processed\n"))


# Vehicle-level files ----

  for(i in c("vsoe",
             "distract",
             "drimpair",
             "factor",
             "maneuver",
             "violatn",
             "vision",
             "damage",
             "vehiclesf",
             "pvehiclesf", #starts in 2020
             "driverrf")){

    if(i %in% rawfiles$cleaned){
      assign(
        paste0("fars.", i),
        read_basic_sas(
          x = i,
          wd = wd,
          rawfiles = rawfiles,
          catfile = my_catfile,
          omits = c(names(fars.accident), names(fars.vehicle))
          )
      )
    }
    }

  cat(paste0("\u2713 ", "Vehicle-level files processed\n"))

  ### driverrf ----

  if(y %in% 2011:2019){
    fars.driverrf <- select(fars.vehicle, "state", "st_case", "veh_no", "dr_sf1", "dr_sf2", "dr_sf3", "dr_sf4")
    fars.vehicle <-  select(fars.vehicle, -any_of(c("dr_sf1", "dr_sf2", "dr_sf3", "dr_sf4")))

    cat(paste0("\u2713 ", "Driver risk factor file processed\n"))

  }



  ### vehiclesf ----

  if(y %in% 2011:2019){
    fars.vehiclesf <- select(fars.vehicle, "state", "st_case", "veh_no", "veh_sc1", "veh_sc2")
    fars.vehicle   <- select(fars.vehicle, -any_of(c("veh_sc1", "veh_sc2")))

    cat(paste0("\u2713 ", "Vehicle risk factor file processed\n"))

  }


# Person-level files ----

  ## pbtype ----

  if(y %in% 2014:2023){
    fars.pbtype <-
      read_basic_sas(
        x = "pbtype",
        wd = wd,
        rawfiles = rawfiles,
        catfile = my_catfile,
        omits = c(names(fars.accident), names(fars.vehicle))
        ) %>%
      select(-any_of(c("pbptype", "pbage", "pbsex")))

    cat(paste0("\u2713 ", "PBtype file processed\n"))

  }


  ## safetyeq ----

  if(y %in% 2011:2023){
    fars.safetyeq <-
      read_basic_sas(
        x = "safetyeq",
        wd = wd,
        rawfiles = rawfiles,
        catfile = my_catfile,
        omits = c(names(fars.accident), names(fars.vehicle))
        )

    cat(paste0("\u2713 ", "SafetyEq file processed\n"))

  }


  ## personrf ----

  if(y %in% 2011:2019){
    fars.personrf <- select(fars.person, "state", "st_case", "veh_no", "per_no", "p_sf1", "p_sf2", "p_sf3")
    fars.person <-  select(fars.person, -any_of(c("p_sf1", "p_sf2", "p_sf3")))

    cat(paste0("\u2713 ", "Person risk factor file processed\n"))

  }


  ## drugs ----

  if(y %in% 2011:2017){
    fars.drugs  <- select(fars.person, "state", "st_case", "veh_no", "per_no", "drugtst1", "drugtst2", "drugtst3", "drugres1", "drugres2", "drugres3")
    fars.person <- select(fars.person, -any_of(c("drugtst1", "drugtst2", "drugtst3", "drugres1", "drugres2", "drugres3")))

    cat(paste0("\u2713 ", "Drugs file processed\n"))

  }


  ## multi-row files ----

    for(i in c("nmcrash",
               "nmimpair",
               "nmprior",
               "nmdistract", #starts in 2019
               "drugs",
               "race",
               "personrf"
    )){

      if(i %in% rawfiles$cleaned){
        assign(
          paste0("fars.", i),
          read_basic_sas(
            x = i,
            wd = wd,
            rawfiles = rawfiles,
            catfile = my_catfile,
            omits = c(names(fars.accident), names(fars.vehicle))
            )
          )
      }
    }

  cat(paste0("\u2713 ", "Person-level files processed\n"))


# Produce flat file ----

  if(is.null(states)){
    flat <- fars.accident
  } else{
    flat <- filter(fars.accident,
                   .data$state %in% unique(geo_filtered$state_name_full) |
                   .data$state %in% unique(geo_filtered$state_name_abbr) |
                   .data$state %in% unique(geo_filtered$fips_state)
                     )
  }

  flat <- flat %>%
    left_join(fars.person, by = c("state", "st_case")) %>% #! This order (accident >> person >> vehicle) is very important for including non-motorists
    left_join(fars.vehicle, by = c("state", "st_case", "veh_no"))

  if(!is.null(fars.pbtype))   flat <- left_join(flat, fars.pbtype,   by = c("state", "st_case", "veh_no", "per_no"))
  if(!is.null(fars.safetyeq)) flat <- left_join(flat, fars.safetyeq, by = c("state", "st_case", "veh_no", "per_no"))

  names_flat <-
    janitor::make_clean_names(names(flat)) %>%
    setdiff(c("year", "casenum", "state", "st_case", "veh_no", "per_no", "weight", "psu", "psustrat", "region", "stratum", "pj")) %>%
    sort()

  flat <-
    as.data.frame(flat) %>%
    mutate(id = paste0(.data$year, .data$st_case)) %>% # Generate state-independent id for each crash
    mutate_at(c("year", "st_case"), as.numeric) %>%
    select("year", "state", "st_case",
           "id", "veh_no", "per_no",
           "county", "city",
           lon = "longitud",
           lat = "latitude",
           any_of(names_flat)
           )

  cat(paste0("\u2713 ", "Flat file constructed\n"))



# Concatenate long files for multi-row files ----

  ## Accident-level ----

  multi_acc <-
    bind_rows(
      fars.weather %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:2)),
      fars.crashrf %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:2))
      ) %>%
    as.data.frame() %>%
    filter(!(.data$value %in% c("None", "Unknown", "Not Reported", "No Additional Atmospheric Conditions"))) %>%
    mutate(year = y) %>%
    mutate_at(c("st_case", "year"), as.numeric) %>%
    inner_join(select(flat, "st_case", "year") %>% distinct(), by = c("st_case", "year"))

  cat(paste0("\u2713 ", "Multi_acc file constructed\n"))


  ## Vehicle-level ----

  multi_veh <- fars.vehiclesf %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:3))

  for(i in list(fars.driverrf,
                fars.drimpair,
                fars.distract,
                fars.factor,
                fars.maneuver,
                fars.pvehiclesf,
                fars.violatn,
                fars.vision,
                fars.damage)){

    if(!is.null(i)) multi_veh <- bind_rows(multi_veh, mutate_all(i, as.character) %>% pivot_longer(cols = -c(1:3)))

  }

  multi_veh <-
    as.data.frame(multi_veh) %>%
    filter(!(.data$value %in% c("None", "Unknown", "Not Reported"))) %>%
    mutate(year = y) %>%
    mutate_at(c("st_case", "year"), as.numeric) %>%
    inner_join(select(flat, "st_case", "year") %>% distinct(), by = c("st_case", "year"))

  cat(paste0("\u2713 ", "Multi_veh file constructed\n"))


  ## Person-level ----

  multi_per <- fars.personrf %>% mutate_all(as.character) %>% pivot_longer(cols = -c(1:4))

  for(i in list(fars.race,
                fars.drugs,
                fars.nmcrash,
                fars.nmimpair,
                fars.nmprior,
                fars.nmdistract
  )){

    if(!is.null(i)){
      multi_per <- bind_rows(multi_per, mutate_all(i, as.character) %>% pivot_longer(cols = -c(1:4)))
    }

  }

  multi_per <-
    as.data.frame(multi_per) %>%
    filter(!(.data$value %in% c("None", "Unknown", "Not Reported"))) %>%
    mutate(year = y) %>%
    mutate_at(c("st_case", "year"), as.numeric) %>%
    inner_join(select(flat, "st_case", "year") %>% distinct(), by = c("st_case", "year"))

  cat(paste0("\u2713 ", "Multi_per file constructed\n"))


  ## Events ----

  soe <-
    as.data.frame(fars.vsoe) %>%
    mutate(year = y) %>%
    mutate_at(c("st_case", "year"), as.numeric) %>%
    inner_join(select(flat, "st_case", "year") %>% distinct(), by = c("st_case", "year"))

  cat(paste0("\u2713 ", "SOE file constructed\n"))


# return ----

  saveRDS(flat,      paste0(prepared_dir, "/", y, "_flat.rds"))
  saveRDS(multi_acc, paste0(prepared_dir, "/", y, "_multi_acc.rds"))
  saveRDS(multi_veh, paste0(prepared_dir, "/", y, "_multi_veh.rds"))
  saveRDS(multi_per, paste0(prepared_dir, "/", y, "_multi_per.rds"))
  saveRDS(soe,       paste0(prepared_dir, "/", y, "_events.rds"))

  cat(paste0("\u2713 ", "Prepared files saved in ", prepared_dir, y, "\n"))


}
