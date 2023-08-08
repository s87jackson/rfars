## code to prepare 2-year toy datasets

library(tidyr)
library(dplyr)

temp <- rfars::get_fars(years = 2019:2020, states = "VA")

fars_1920_va_flat <- select(temp$flat,
                            "year", "state", "st_case", "id",
                            "veh_no", "per_no", "per_typ", "body_typ",
                            "lon", "lat", "rur_urb",
                            "age", "sex",
                            "hit_run", "speedrel",
                            "hour",
                            "inj_sev",
                            "lgt_cond",
                            "man_coll", "rest_use",
                            "typ_int", "vtrafcon",
                            "reljct1", "reljct2", "rel_road",
                            contains("alc_"),
                            contains("drug"),
                            contains("drunk"),
                            )

usethis::use_data(fars_1920_va_flat, overwrite = TRUE)




temp <- rfars::get_gescrss(years = 2019:2020, regions = "mw")

gescrss_1920_mw_flat <- select(temp$flat,
                               "year", "region", "psu", "psustrat", "casenum", "weight", "id",
                              "veh_no", "per_no", "per_typ",
                              "urbanicity",
                              "age", "sex",
                              "hit_run", "speedrel",
                              "hour",
                              "inj_sev",
                              "lgt_cond",
                              "man_coll", "rest_use",
                              "typ_int", "vtrafcon",
                              "reljct1", "reljct2", "rel_road",
                              starts_with("alc"),
                              contains("drug"),
                              contains("drunk"))

usethis::use_data(gescrss_1920_mw_flat, overwrite = TRUE)


gescrss_1920_mw_events <- temp$events

usethis::use_data(gescrss_1920_mw_events, overwrite = TRUE)
