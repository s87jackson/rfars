#' Prepare downloaded GES/CRSS files for use
#'
#' @param y year, to be passed from \code{prep_gescrss}
#' @param wd working directory, , to be passed from \code{prep_gescrss}
#' @param rawfiles dataframe translating filenames into standard terms,
#'     to be passed from \code{prep_gescrss}
#' @param prepared_dir the location where prepared files will be saved,
#'     to be passed from \code{prep_gescrss}
#' @param regions (Optional) Inherits from get_gescrss()
#'
#' @return Produces six files: yyyy_flat.rds, yyyy_multi_acc.rds,
#'     yyyy_multi_veh.rds, yyyy_multi_per.rds, yyyy_events.rds, and codebook.rds
#'
#' @importFrom rlang .data


prep_gescrss <- function(y, wd, rawfiles, prepared_dir, regions){


# Setup

  gescrss.accident <- gescrss.vehicle <- gescrss.person <- NULL

  gescrss.vsoe <- gescrss.distract <- gescrss.drimpair <- gescrss.factor <-
    gescrss.maneuver <- gescrss.violatn <- gescrss.vision <- gescrss.damage <- gescrss.vehiclesf <-
    gescrss.pvehiclesf <- gescrss.driverrf <- gescrss.pbtype <- NULL

  gescrss.nmcrash <- gescrss.nmimpair <- gescrss.nmprior <- gescrss.nmdistract <-
    gescrss.drugs <- gescrss.personrf <- gescrss.crashrf <- NULL

  if(y %in% 2016:2021)          my_catfile <- paste0(wd, "format-64/formats.sas7bcat")
  if(y %in% c(2011, 2014:2015)) my_catfile <- paste0(wd, "formats.sas7bcat")
  if(y %in% 2012:2013)          my_catfile <- paste0(wd, "formats-64/formats.sas7bcat") #note the extra s

  myregions <-
    rfars::geo_relations %>%
    filter(.data$region_abbr %in% regions) %>%
    pull("region") %>%
    unique()


# Core files ----

  ## accident ----

  gescrss.accident <-
    read_basic_sas(x = "accident", wd = wd, rawfiles = rawfiles, catfile = my_catfile) %>%
    use_imp("alcohol", "alchl_im") %>%
    use_imp("harm_ev", "event1_im") %>%
    use_imp("hour", "hour_im") %>%
    use_imp("lgt_cond", "lgtcon_im") %>%
    use_imp("man_coll", "mancol_im") %>%
    use_imp("max_sev", "maxsev_im") %>%
    use_imp("minute", "minute_im") %>%
    use_imp("num_inj", "no_inj_im") %>%
    use_imp("reljct2", "reljct2_im") %>%
    use_imp("weather", "weathr_im") %>%
    use_imp("day_week", "wkdy_im")

  if(y %in% 2011:2018) gescrss.accident <- use_imp(gescrss.accident, "reljct1", "reljct1_im")


  ## vehicle ----

  gescrss.vehicle <-
    read_basic_sas(x = "vehicle", wd = wd, rawfiles = rawfiles, catfile = my_catfile) %>%
    select(-starts_with("vin"), -ends_with("vin")) %>%
    rm_cols.g(a=gescrss.accident, b=NULL) %>%
    use_imp("impact1", "impact1_im") %>%
    use_imp("mod_year", "mdlyr_im") %>%
    use_imp("max_vsev", "mxvsev_im") %>%
    use_imp("num_injv", "numinj_im") %>%
    use_imp("p_crash1", "pcrash1_im") %>%
    use_imp("veh_alch", "v_alch_im") %>%
    use_imp("m_harm", "vevent_im")

  if(y %in% 2011:2019) gescrss.vehicle <- use_imp(gescrss.vehicle, "hit_run", "hitrun_im")

  if(y %in% 2011:2020) gescrss.vehicle <- use_imp(gescrss.vehicle, "body_typ", "bdytyp_im")


  ## person ----

  gescrss.person <-
    read_basic_sas(x = "person", wd = wd, rawfiles = rawfiles, catfile = my_catfile) %>%
    rm_cols.g(a=gescrss.accident, b=gescrss.vehicle) %>%
    use_imp("age", "age_im") %>%
    use_imp("ejection", "eject_im") %>%
    use_imp("inj_sev", "injsev_im") %>%
    use_imp("drinking", "peralch_im") %>%
    use_imp("seat_pos", "seat_im") %>%
    use_imp("sex", "sex_im")



# Accident-level files ----

  ## weather ----

  if(y %in% 2020:2021){
    gescrss.weather <- read_basic_sas(x = "weather", wd = wd, rawfiles = rawfiles, catfile = my_catfile)
  } else{
    gescrss.weather <- select(gescrss.accident, "casenum", "weather1", "weather2")
  }

  gescrss.accident <-  select(gescrss.accident, -contains("weather"))


  ## crashrf ----

  if(y %in% 2020:2021) gescrss.crashrf <- read_basic_sas(x = "crashrf", wd = wd, rawfiles = rawfiles, catfile = my_catfile)

  if(y %in% 2012:2019) gescrss.crashrf <- select(gescrss.accident, "casenum", "cf1", "cf2", "cf3")

  gescrss.accident <-  select(gescrss.accident, -any_of(c("cf1", "cf2", "cf3")))



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
             "pvehiclesf",
             "driverrf")){

    if(i %in% rawfiles$cleaned){
      assign(
        paste0("gescrss.", i),
        read_basic_sas(x = i, wd = wd, rawfiles = rawfiles, catfile = my_catfile) %>%
          rm_cols.g(a=gescrss.accident, b=gescrss.vehicle))
      }
  }


  ### driverrf ----

  if(y %in% 2012:2019){
    gescrss.driverrf <- select(gescrss.vehicle, "casenum", "veh_no", "dr_sf1", "dr_sf2", "dr_sf3", "dr_sf4")
    gescrss.vehicle <-  select(gescrss.vehicle, -any_of(c("dr_sf1", "dr_sf2", "dr_sf3", "dr_sf4")))
  }

  ### vehiclesf ----

  if(y %in% 2012:2019){
    gescrss.vehiclesf <- select(gescrss.vehicle, "casenum", "veh_no", "veh_sc1", "veh_sc2")
    gescrss.vehicle   <- select(gescrss.vehicle, -any_of(c("veh_sc1", "veh_sc2")))
  }


# Person-level files ----

  ## pbtype ----

  if(y %in% 2014:2021){
    gescrss.pbtype <-
      read_basic_sas(x = "pbtype", wd = wd, rawfiles = rawfiles, catfile = my_catfile) %>%
      select(-any_of(c("pbage", "pbsex"))) %>%
      rm_cols.g(a=gescrss.accident, b=gescrss.vehicle)
  }


  ## safetyeq ----

  gescrss.safetyeq <-
    read_basic_sas(x = "safetyeq", wd = wd, rawfiles = rawfiles, catfile = my_catfile) %>%
    rm_cols.g(a=gescrss.accident, b=gescrss.vehicle)


  ## personrf ----

  if(y %in% 2012:2019){
    gescrss.personrf <- select(gescrss.person, "casenum", "veh_no", "per_no", "p_sf1", "p_sf2", "p_sf3")
    gescrss.person   <- select(gescrss.person, -any_of(c("p_sf1", "p_sf2", "p_sf3")))
  }


  ## drugs ----

  if(y %in% 2011:2016){
    gescrss.drugs  <- select(gescrss.person, "casenum", "veh_no", "per_no", "drugres1", "drugres2", "drugres3", "drugtst1", "drugtst2", "drugtst3")
    gescrss.person <- select(gescrss.person, -any_of(c("drugres1", "drugres2", "drugres3", "drugtst1", "drugtst2", "drugtst3")))
  }


  ## multi-row files ----

    for(i in c("nmcrash",
               "nmimpair",
               "nmprior",
               "nmdistract" #starting in 2019
    )){

      if(i %in% rawfiles$cleaned){
        assign(
          paste0("gescrss.", i),
          read_basic_sas(x = i, wd = wd, rawfiles = rawfiles, catfile = my_catfile)
          %>% rm_cols.g(a=gescrss.accident, b=gescrss.vehicle))
      }
    }




# Produce flat file ----

  flat <-
    filter(gescrss.accident, .data$region %in% myregions) %>%
    left_join(gescrss.person, by = c("casenum")) %>% #! This order (accident >> person >> vehicle) is very important for including non-motorists
    left_join(gescrss.vehicle, by = c("casenum", "veh_no"))

  if(!is.null(gescrss.pbtype))   flat <- left_join(flat, gescrss.pbtype,   by=c("casenum", "veh_no", "per_no"))
  if(!is.null(gescrss.safetyeq)) flat <- left_join(flat, gescrss.safetyeq, by=c("casenum", "veh_no", "per_no"))

  names_flat <-
    janitor::make_clean_names(names(flat)) %>%
    setdiff(c("year", "casenum", "state", "st_case", "veh_no", "per_no", "weight", "psu", "psustrat", "region", "stratum", "pj")) %>%
    sort()

  flat <-
    as.data.frame(flat) %>%
    mutate(id = paste0(.data$year, .data$casenum)) %>% # Generate state-independent id for each crash
    select("year","region","psu", "psustrat", "casenum", "weight",
           "id", "veh_no", "per_no",
           any_of(names_flat))



# Concatenate long files for multi-row files ----

  ## Accident-level ----

  if(is.null(gescrss.crashrf)){
    multi_acc <- gescrss.weather %>% mutate_all(as.character) %>% pivot_longer(cols = -1)
  } else{
    multi_acc <- bind_rows(
      gescrss.weather %>% mutate_all(as.character) %>% pivot_longer(cols = -1),
      gescrss.crashrf %>% mutate_all(as.character) %>% pivot_longer(cols = -1)
      )
  }

  multi_acc <-
    as.data.frame(multi_acc) %>%
    filter(!(.data$value %in% c("None", "Unknown", "Not Reported", "No Additional Atmospheric Conditions"))) %>%
    mutate(year = y)


  ## Vehicle-level ----

  multi_veh <-  mutate_all(gescrss.distract, as.character) %>% pivot_longer(cols = -c(1:2))

  for(i in list(gescrss.vehiclesf,
                gescrss.driverrf,
                gescrss.drimpair,
                gescrss.factor,
                gescrss.maneuver,
                gescrss.violatn,
                gescrss.vision,
                gescrss.damage)){

    if(!is.null(i)) multi_veh <- bind_rows(multi_veh, mutate_all(i, as.character) %>% pivot_longer(cols = -c(1:2)))

  }

  multi_veh <-
    as.data.frame(multi_veh) %>%
    filter(!(.data$value %in% c("None", "Unknown", "Not Reported", "No Additional Atmospheric Conditions"))) %>%
    mutate(year = y)


  ## Person-level ----

  multi_per <- mutate_all(gescrss.nmcrash, as.character) %>% pivot_longer(cols = -c(1:3))

  for(i in list(gescrss.personrf,
                gescrss.drugs,
                gescrss.nmimpair,
                gescrss.nmprior,
                gescrss.nmdistract)){

    if(!is.null(i)) multi_per <- bind_rows(multi_per, mutate_all(i, as.character) %>% pivot_longer(cols = -c(1:3)))

  }

  multi_per <-
    as.data.frame(multi_per) %>%
    filter(!(.data$value %in% c("None", "Unknown", "Not Reported", "No Additional Atmospheric Conditions"))) %>%
    mutate(year = y)


  ## Events ----

  soe <- as.data.frame(gescrss.vsoe) %>% mutate(year = y)


# return ----

  saveRDS(flat,      paste0(prepared_dir, "/", y, "_flat.rds"))
  saveRDS(multi_acc, paste0(prepared_dir, "/", y, "_multi_acc.rds"))
  saveRDS(multi_veh, paste0(prepared_dir, "/", y, "_multi_veh.rds"))
  saveRDS(multi_per, paste0(prepared_dir, "/", y, "_multi_per.rds"))
  saveRDS(soe,       paste0(prepared_dir, "/", y, "_events.rds"))

}
