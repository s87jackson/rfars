
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rfars <img src="man/figures/logo.svg" align="right" width="120"/>

<!-- badges: start -->

[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/rfars)](https://cran.r-project.org/package=rfars)
[![R CMD
Check](https://github.com/s87jackson/rfars/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/s87jackson/rfars/actions/workflows/R-CMD-check.yaml)
[![](https://cranlogs.r-pkg.org/badges/grand-total/rfars)](https://CRAN.R-project.org/package=rfars)

<!-- badges: end -->

The goal of `rfars` is to facilitate transportation safety analysis by
simplifying the process of extracting data from official crash
databases. The [National Highway Traffic Safety
Administration](https://www.nhtsa.gov/) collects and publishes a census
of fatal crashes in the [Fatality Analysis Reporting
System](https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars)
and a sample of fatal and non-fatal crashes in the [Crash Report
Sampling
System](https://www.nhtsa.gov/crash-data-systems/crash-report-sampling-system)
(an evolution of the [General Estimates
System](https://www.nhtsa.gov/national-automotive-sampling-system/nass-general-estimates-system)).
The [Fatality and Injury Reporting System
Tool](https://cdan.dot.gov/query) allows users to query these databases,
and can produce simple tables and graphs. This suffices for simple
analysis, but often leaves researchers wanting more. Digging any deeper,
however, involves a time-consuming process of downloading annual ZIP
files and attempting to stitch them together - after first combing
through immense data dictionaries to determine the required variables
and table names.

`rfars` allows users to download FARS and GES/CRSS data back to 2011
with just one line of code. The result is a full, rich dataset ready for
mapping, modeling, and other downstream analysis. Helper functions are
also provided to produce common counts and comparisons.

## Installation

You can install the latest version of `rfars` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("s87jackson/rfars")
```

or the CRAN stable release with:

``` r
install.packages("rfars")
```

Then load rfars and some helpful packages:

``` r
library(rfars)
library(dplyr)
```

## Getting and Using Data

The `get_fars()` and `get_gescrss()` are the primary functions of the
`rfars` package. These functions either download and process data files
directly from [NHTSA’s FTP
Site](https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/), or pull
the prepared file stored on your local machine. They take the functions
`years` and `states` (FARS) or `regions` (GES/CRSS). As the source data
files follow an annual structure, `years` determines how many file sets
are downloaded, and `states`/`regions` filters the resulting dataset.
Downloading and processing these files can take several minutes. Before
downloading `rfars` will inform you that it’s about to download files
and asks your permission to do so. To skip this dialog, set
`proceed = TRUE`. You can use the `dir` and `cache` parameters to save
an RDS file to your local machine. The `dir` parameter specifices the
directory, and `cache` names the file (be sure to include the .rds file
extension).

Here we get one year of FARS data for Virginia:

``` r
myFARS <- get_fars(years = 2022, states = "VA", proceed = TRUE)
#> ✓ 2022 data downloaded
#> Preparing raw data files...
#> ✓ Accident file processed
#> ✓ Vehicle file processed
#> ✓ Person file processed
#> ✓ Weather file(s) processed
#> ✓ Crash risk factors file processed
#> ✓ Vehicle-level files processed
#> ✓ PBtype file processed
#> ✓ SafetyEq file processed
#> ✓ Person-level files processed
#> ✓ Flat file constructed
#> ✓ Multi_acc file constructed
#> ✓ Multi_veh file constructed
#> ✓ Multi_per file constructed
#> ✓ SOE file constructed
#> ✓ Prepared files saved in C:/Users/s87ja/AppData/Local/Temp/RtmpOI3o4P/FARS data/prepd/2022
#> ✓ Codebook file saved in C:/Users/s87ja/AppData/Local/Temp/RtmpOI3o4P/FARS data/prepd/
```

We could have saved that file locally with:

``` r
myFARS <- get_fars(years=2022, states = "VA", proceed = TRUE, dir = getwd(), cache = "myFARS.rds")
```

Note that you can assign and save this data with one function call.

We could similarly get one year of CRSS data for the south (MD, DE, DC,
WV, VA, KY, TN, NC, SC, GA, FL, AL, MS, LA, AR, OK, TX):

``` r
myCRSS <- get_gescrss(years = 2022, regions = "s", proceed = TRUE)
myCRSS <- get_gescrss(years = 2022, regions = "s", proceed = TRUE, dir = getwd(), cache = "myCRSS.rds")
```

The data returned by `get_fars()` and `get_gescrss()` adhere to the same
structure: a list with six tibbles: `flat`, `multi_acc`, `multi_veh`,
`multi_per`, `events`, and `codebook`. FARS and GES/CRSS share many but
not all data elements. See the [FARS Analytical User’s
Manual](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813417)
and [CRSS Analytical User’s
Manual](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813436)
for more information.

The following section decribes the results from `get_fars()` but largely
applies to `get_gescrss()` as well.

The `flat` tibble contains all variables for which there is just one
value per crash (“accident”), vehicle, or person (e.g., intersection
type, travel speed, age). Each row corresponds to a person involved in a
crash. As there may be multiple people and/or vehicles involved in one
crash, some variable-values are repeated within a crash or vehicle. Each
crash is uniquely identified with `id`, which is a combination of `year`
and `st_case`. Note that `st_case` is not unique across years, for
example, `st_case` 510001 will appear in each year. The `id` variable
attempts to avoid this issue.

``` r
glimpse(myFARS$flat, width = 100)
#> Rows: 2,107
#> Columns: 196
#> $ year          <dbl> 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2022…
#> $ state         <chr> "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Vir…
#> $ st_case       <dbl> 510001, 510001, 510001, 510001, 510001, 510001, 510002, 510002, 510002, 5100…
#> $ id            <dbl> 2022510001, 2022510001, 2022510001, 2022510001, 2022510001, 2022510001, 2022…
#> $ veh_no        <dbl> 0, 1, 1, 1, 1, 1, 1, 2, 2, 0, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2…
#> $ per_no        <dbl> 1, 1, 2, 3, 4, 5, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1…
#> $ county        <dbl> 117, 117, 117, 117, 117, 117, 177, 177, 177, 73, 73, 73, 153, 155, 171, 171,…
#> $ city          <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2370, 2370, 0, 0, 468, 0, 0, 440, …
#> $ lon           <dbl> -78.40886, -78.40886, -78.40886, -78.40886, -78.40886, -78.40886, -77.63212,…
#> $ lat           <dbl> 36.66222, 36.66222, 36.66222, 36.66222, 36.66222, 36.66222, 38.17428, 38.174…
#> $ acc_type      <chr> NA, "C13-Single Driver-Forward Impact-Pedestrian/ Animal", "C13-Single Drive…
#> $ age           <chr> "59 Years", "17 Years", "Not Reported", "Not Reported", "Not Reported", "Not…
#> $ air_bag       <chr> "Not a Motor Vehicle Occupant", "Not Deployed", "Not Reported", "Not Reporte…
#> $ alc_res       <chr> "0.197 % BAC", "Test Not Given", "Test Not Given", "Test Not Given", "Test N…
#> $ alc_status    <chr> "Test Given", "Test Not Given", "Test Not Given", "Test Not Given", "Test No…
#> $ arr_hour      <chr> "Unknown EMS Scene Arrival Hour", "Unknown EMS Scene Arrival Hour", "Unknown…
#> $ arr_min       <chr> "Unknown if Arrived", "Unknown if Arrived", "Unknown if Arrived", "Unknown i…
#> $ atst_typ      <chr> "Vitreous", "Test Not Given", "Test Not Given", "Test Not Given", "Test Not …
#> $ bikecgp       <chr> "Bicyclist Failed to Yield - Sign-Controlled Intersection", NA, NA, NA, NA, …
#> $ bikectype     <chr> "Bicyclist Ride Through - Sign-Controlled Intersection", NA, NA, NA, NA, NA,…
#> $ bikedir       <chr> "Facing Traffic", NA, NA, NA, NA, NA, NA, NA, NA, "Not a Cyclist", NA, NA, N…
#> $ bikeloc       <chr> "At Intersection", NA, NA, NA, NA, NA, NA, NA, NA, "Not a Cyclist", NA, NA, …
#> $ bikepos       <chr> "Travel Lane", NA, NA, NA, NA, NA, NA, NA, NA, "Not a Cyclist", NA, NA, NA, …
#> $ body_typ      <chr> NA, "Large utility (ANSI D16.1 Utility Vehicle Categories and \"Full Size\" …
#> $ bus_use       <chr> NA, "Not a Bus", "Not a Bus", "Not a Bus", "Not a Bus", "Not a Bus", "Not a …
#> $ cargo_bt      <chr> NA, "Not Applicable (N/A)", "Not Applicable (N/A)", "Not Applicable (N/A)", …
#> $ cdl_stat      <chr> NA, "No (CDL)", "No (CDL)", "No (CDL)", "No (CDL)", "No (CDL)", "No (CDL)", …
#> $ cityname      <chr> "NOT APPLICABLE", "NOT APPLICABLE", "NOT APPLICABLE", "NOT APPLICABLE", "NOT…
#> $ countyname    <chr> "MECKLENBURG (117)", "MECKLENBURG (117)", "MECKLENBURG (117)", "MECKLENBURG …
#> $ day           <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 5, 3, 3, 5, 8, 2, 8, 8, 1, 1, 1, 7, 7…
#> $ day_week      <chr> "Saturday", "Saturday", "Saturday", "Saturday", "Saturday", "Saturday", "Sat…
#> $ death_da      <chr> "1", "Not Applicable (Non-Fatal)", "Not Applicable (Non-Fatal)", "Not Applic…
#> $ death_hr      <chr> "16:00-16:59", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "…
#> $ death_mn      <chr> "28", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "Not Appli…
#> $ death_mo      <chr> "January", "Not Applicable (Non-Fatal)", "Not Applicable (Non-Fatal)", "Not …
#> $ death_tm      <chr> "1628", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "Not App…
#> $ death_yr      <chr> "2022", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "Not App…
#> $ deaths        <dbl> NA, 0, 0, 0, 0, 0, 0, 1, 1, NA, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1,…
#> $ deformed      <chr> NA, "7", "7", "7", "7", "7", "Disabling Damage", "Disabling Damage", "Disabl…
#> $ devmotor      <dbl> 3, NA, NA, NA, NA, NA, NA, NA, NA, 0, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ devtype       <dbl> 3, NA, NA, NA, NA, NA, NA, NA, NA, 0, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ doa           <chr> "Died at Scene", "Not Applicable", "Not Applicable", "Not Applicable", "Not …
#> $ dr_drink      <chr> NA, "No", "No", "No", "No", "No", "No", "No", "No", NA, "No", "No", "Yes", "…
#> $ dr_hgt        <chr> NA, "69", "69", "69", "69", "69", "62", "63", "63", NA, "67", "69", "67", "7…
#> $ dr_pres       <chr> NA, "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", NA, "Yes", "Yes"…
#> $ dr_wgt        <chr> NA, "130 lbs.", "130 lbs.", "130 lbs.", "130 lbs.", "130 lbs.", "140 lbs.", …
#> $ dr_zip        <chr> NA, "23893", "23893", "23893", "23893", "23893", "23024", "22551", "22551", …
#> $ drinking      <chr> "Reported as Unknown", "No (Alcohol Not Involved)", "Not Reported", "Not Rep…
#> $ drugs         <chr> "Reported as Unknown", "No (drugs not involved)", "Not Reported", "Not Repor…
#> $ dstatus       <chr> "Test Given", "Test Not Given", "Test Not Given", "Test Not Given", "Test No…
#> $ ej_path       <chr> "Ejection Path Not Applicable", "Ejection Path Not Applicable", "Ejection Pa…
#> $ ejection      <chr> "Not Applicable", "Not Ejected", "Not Reported", "Not Reported", "Not Report…
#> $ emer_use      <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ extricat      <chr> "Not Extricated or Not Applicable", "Not Extricated or Not Applicable", "Not…
#> $ fatals        <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ fire_exp      <chr> NA, "No or Not Reported", "No or Not Reported", "No or Not Reported", "No or…
#> $ first_mo      <chr> NA, "November", "November", "November", "November", "November", "No Record",…
#> $ first_yr      <chr> NA, "2021", "2021", "2021", "2021", "2021", "No Record", "No Record", "No Re…
#> $ func_sys      <chr> "Principal Arterial - Other", "Principal Arterial - Other", "Principal Arter…
#> $ gvwr_from     <chr> NA, "Class 2: 6,001 - 10,000 lbs. (2,722 - 4,536 kg)", "Class 2: 6,001 - 10,…
#> $ gvwr_to       <chr> NA, "Class 2: 6,001 - 10,000 lbs. (2,722 - 4,536 kg)", "Class 2: 6,001 - 10,…
#> $ harm_ev       <chr> "Pedalcyclist", "Pedalcyclist", "Pedalcyclist", "Pedalcyclist", "Pedalcyclis…
#> $ haz_cno       <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ haz_id        <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ haz_inv       <chr> NA, "No", "No", "No", "No", "No", "No", "No", "No", NA, "No", "No", "No", "N…
#> $ haz_plac      <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ haz_rel       <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ helm_mis      <chr> "Not a Motor Vehicle Occupant", "None Used/Not Applicable", "None Used/Not A…
#> $ helm_use      <chr> "Not a Motor Vehicle Occupant", "Not Applicable", "Not Applicable", "Not App…
#> $ hispanic      <chr> "Non-Hispanic", "Not A Fatality (not Applicable)", "Not A Fatality (not Appl…
#> $ hit_run       <chr> NA, "No", "No", "No", "No", "No", "No", "No", "No", NA, "No", "No", "No", "N…
#> $ hosp_hr       <chr> "Not Applicable (Not Transported)", "Not Applicable (Not Transported)", "Not…
#> $ hosp_mn       <chr> "Not Applicable (Not Transported)", "Not Applicable (Not Transported)", "Not…
#> $ hospital      <chr> "Not Transported for Treatment", "Not Transported for Treatment", "Not Trans…
#> $ hour          <chr> "4:00pm-4:59pm", "4:00pm-4:59pm", "4:00pm-4:59pm", "4:00pm-4:59pm", "4:00pm-…
#> $ icfinalbody   <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ impact1       <chr> NA, "12 Clock Point", "12 Clock Point", "12 Clock Point", "12 Clock Point", …
#> $ inj_sev       <chr> "Fatal Injury (K)", "No Apparent Injury (O)", "No Apparent Injury (O)", "No …
#> $ j_knife       <chr> NA, "Not an Articulated Vehicle", "Not an Articulated Vehicle", "Not an Arti…
#> $ l_compl       <chr> NA, "Valid license for this class vehicle", "Valid license for this class ve…
#> $ l_endors      <chr> NA, "No Endorsements required for this vehicle", "No Endorsements required f…
#> $ l_restri      <chr> NA, "Restrictions, Compliance Unknown", "Restrictions, Compliance Unknown", …
#> $ l_state       <chr> NA, "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", …
#> $ l_status      <chr> NA, "Valid", "Valid", "Valid", "Valid", "Valid", "Valid", "Valid", "Valid", …
#> $ l_type        <chr> NA, "Full Driver License", "Full Driver License", "Full Driver License", "Fu…
#> $ lag_hrs       <chr> "0", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unkn…
#> $ lag_mins      <chr> "6", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unkn…
#> $ last_mo       <chr> NA, "November", "November", "November", "November", "November", "No Record",…
#> $ last_yr       <chr> NA, "2021", "2021", "2021", "2021", "2021", "No Record", "No Record", "No Re…
#> $ lgt_cond      <chr> "Daylight", "Daylight", "Daylight", "Daylight", "Daylight", "Daylight", "Day…
#> $ location      <chr> "At Intersection - Not In Crosswalk", "Occupant of a Motor Vehicle", "Occupa…
#> $ m_harm        <chr> NA, "Pedalcyclist", "Pedalcyclist", "Pedalcyclist", "Pedalcyclist", "Pedalcy…
#> $ mak_mod       <chr> NA, "GMC Fullsize Jimmy/Yukon", "GMC Fullsize Jimmy/Yukon", "GMC Fullsize Ji…
#> $ make          <chr> NA, "GMC", "GMC", "GMC", "GMC", "GMC", "Chevrolet", "Ford", "Ford", NA, "Int…
#> $ man_coll      <chr> "The First Harmful Event was Not a Collision with a Motor Vehicle in Transpo…
#> $ mcarr_i1      <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ mcarr_i2      <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ mcarr_id      <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ milept        <chr> "3586", "3586", "3586", "3586", "3586", "3586", "370", "370", "370", "101", …
#> $ minute        <chr> "22", "22", "22", "22", "22", "22", "55", "55", "55", "35", "35", "35", "11"…
#> $ mod_year      <chr> NA, "2016", "2016", "2016", "2016", "2016", "2019", "2008", "2008", NA, "201…
#> $ model         <dbl> NA, 421, 421, 421, 421, 421, 422, 481, 481, NA, 881, 37, 43, 404, 32, 881, 4…
#> $ month         <chr> "January", "January", "January", "January", "January", "January", "January",…
#> $ motdir        <chr> "Not a Pedestrian", NA, NA, NA, NA, NA, NA, NA, NA, "Not Applicable", NA, NA…
#> $ motman        <chr> "Not a Pedestrian", NA, NA, NA, NA, NA, NA, NA, NA, "Not Applicable", NA, NA…
#> $ nhs           <chr> "This section IS ON the NHS", "This section IS ON the NHS", "This section IS…
#> $ nmhelmet      <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, …
#> $ nmlight       <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, …
#> $ nmothpre      <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, …
#> $ nmothpro      <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, …
#> $ nmpropad      <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, …
#> $ nmrefclo      <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, …
#> $ not_hour      <chr> "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown",…
#> $ not_min       <chr> "Unknown if Notified", "Unknown if Notified", "Unknown if Notified", "Unknow…
#> $ numoccs       <chr> NA, "05", "05", "05", "05", "05", "01", "02", "02", NA, "01", "01", "01", "0…
#> $ owner         <chr> NA, "Driver (in this crash) Not Registered Owner (Other Private Owner Listed…
#> $ p_crash1      <chr> NA, "Negotiating a Curve", "Negotiating a Curve", "Negotiating a Curve", "Ne…
#> $ p_crash2      <chr> NA, "Pedalcyclist or other non-motorist in road", "Pedalcyclist or other non…
#> $ p_crash3      <chr> NA, "Unknown/Not Reported", "Unknown/Not Reported", "Unknown/Not Reported", …
#> $ pbcwalk       <chr> "None Noted", NA, NA, NA, NA, NA, NA, NA, NA, "None Noted", NA, NA, NA, NA, …
#> $ pbswalk       <chr> "None Noted", NA, NA, NA, NA, NA, NA, NA, NA, "None Noted", NA, NA, NA, NA, …
#> $ pbszone       <chr> "None Noted", NA, NA, NA, NA, NA, NA, NA, NA, "None Noted", NA, NA, NA, NA, …
#> $ pcrash4       <chr> NA, "Tracking", "Tracking", "Tracking", "Tracking", "Tracking", "Tracking", …
#> $ pcrash5       <chr> NA, "Stayed in original travel lane", "Stayed in original travel lane", "Sta…
#> $ pedcgp        <chr> "Not a Pedestrian", NA, NA, NA, NA, NA, NA, NA, NA, "Unusual Circumstances",…
#> $ pedctype      <chr> "Not a Pedestrian", NA, NA, NA, NA, NA, NA, NA, NA, "Disabled Vehicle-Relate…
#> $ peddir        <chr> "Not a Pedestrian", NA, NA, NA, NA, NA, NA, NA, NA, "Not Applicable", NA, NA…
#> $ pedleg        <chr> "Not a Pedestrian", NA, NA, NA, NA, NA, NA, NA, NA, "Not Applicable", NA, NA…
#> $ pedloc        <chr> "Not a Pedestrian", NA, NA, NA, NA, NA, NA, NA, NA, "Not At Intersection", N…
#> $ pedpos        <chr> "Not a Pedestrian", NA, NA, NA, NA, NA, NA, NA, NA, "Other/Unknown", NA, NA,…
#> $ peds          <dbl> 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ pedsnr        <chr> "Not a Pedestrian", NA, NA, NA, NA, NA, NA, NA, NA, "Not Applicable", NA, NA…
#> $ per_typ       <chr> "Bicyclist", "Driver of a Motor Vehicle In-Transport", "Passenger of a Motor…
#> $ permvit       <dbl> 5, 5, 5, 5, 5, 5, 3, 3, 3, 2, 2, 2, 1, 1, 2, 2, 1, 1, 1, 2, 2, 3, 3, 3, 3, 3…
#> $ pernotmvit    <dbl> 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ persons       <dbl> 5, 5, 5, 5, 5, 5, 3, 3, 3, 2, 2, 2, 1, 1, 2, 2, 1, 1, 1, 2, 2, 3, 3, 3, 3, 3…
#> $ prev_acc      <chr> NA, "1", "1", "1", "1", "1", "None", "None", "None", NA, "3", "None", "None"…
#> $ prev_dwi      <chr> NA, "None", "None", "None", "None", "None", "None", "None", "None", NA, "Non…
#> $ prev_oth      <chr> NA, "None", "None", "None", "None", "None", "None", "None", "None", NA, "4",…
#> $ prev_spd      <chr> NA, "None", "None", "None", "None", "None", "None", "None", "None", NA, "2",…
#> $ prev_sus1     <chr> NA, "None", "None", "None", "None", "None", "None", "None", "None", NA, "Non…
#> $ prev_sus2     <chr> NA, "None", "None", "None", "None", "None", "None", "None", "None", NA, "Non…
#> $ prev_sus3     <chr> NA, "None", "None", "None", "None", "None", "None", "None", "None", NA, "4",…
#> $ pvh_invl      <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ rail          <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ rd_owner      <chr> "State Highway Agency", "State Highway Agency", "State Highway Agency", "Sta…
#> $ reg_stat      <chr> NA, "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", …
#> $ rel_road      <chr> "On Roadway", "On Roadway", "On Roadway", "On Roadway", "On Roadway", "On Ro…
#> $ reljct1       <chr> "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "Yes…
#> $ reljct2       <chr> "Intersection-Related", "Intersection-Related", "Intersection-Related", "Int…
#> $ rest_mis      <chr> "Not a Motor Vehicle Occupant", "No Indication of Mis-Use", "None Used/Not A…
#> $ rest_use      <chr> "Not a Motor Vehicle Occupant", "Shoulder and Lap Belt Used", "Not Reported"…
#> $ rolinloc      <chr> NA, "No Rollover", "No Rollover", "No Rollover", "No Rollover", "No Rollover…
#> $ rollover      <chr> NA, "No Rollover", "No Rollover", "No Rollover", "No Rollover", "No Rollover…
#> $ route         <chr> "U.S. Highway", "U.S. Highway", "U.S. Highway", "U.S. Highway", "U.S. Highwa…
#> $ rur_urb       <chr> "Rural", "Rural", "Rural", "Rural", "Rural", "Rural", "Rural", "Rural", "Rur…
#> $ sch_bus       <chr> "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No"…
#> $ seat_pos      <chr> "Not a Motor Vehicle Occupant", "Front Seat, Left Side", "Not Reported", "No…
#> $ sex           <chr> "Male", "Male", "Not Reported", "Not Reported", "Not Reported", "Not Reporte…
#> $ sp_jur        <chr> "No Special Jurisdiction", "No Special Jurisdiction", "No Special Jurisdicti…
#> $ spec_use      <chr> NA, "No Special Use", "No Special Use", "No Special Use", "No Special Use", …
#> $ speedrel      <chr> NA, "Yes, Exceeded Speed Limit", "Yes, Exceeded Speed Limit", "Yes, Exceeded…
#> $ statename     <chr> "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Vir…
#> $ str_veh       <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ tow_veh       <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ towed         <chr> NA, "Not Reported", "Not Reported", "Not Reported", "Not Reported", "Not Rep…
#> $ trav_sp       <chr> NA, "060 MPH", "060 MPH", "060 MPH", "060 MPH", "060 MPH", "065 MPH", "Stopp…
#> $ trlr1gvwr     <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ trlr1vin      <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ trlr2gvwr     <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ trlr2vin      <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ trlr3gvwr     <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ trlr3vin      <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ tway_id       <chr> "US-58", "US-58", "US-58", "US-58", "US-58", "US-58", "SR-208/LAKE ANNA PKWY…
#> $ tway_id2      <chr> "JEFFERSON ST", "JEFFERSON ST", "JEFFERSON ST", "JEFFERSON ST", "JEFFERSON S…
#> $ typ_int       <chr> "Four-Way Intersection", "Four-Way Intersection", "Four-Way Intersection", "…
#> $ underoverride <dbl> NA, 7, 7, 7, 7, 7, 0, 0, 0, NA, 0, 0, 7, 7, 0, 0, 7, 7, 7, 7, 7, 0, 0, 0, 0,…
#> $ unittype      <chr> NA, "Motor Vehicle In-Transport (Inside or Outside the Trafficway)", "Motor …
#> $ v_config      <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ valign        <chr> NA, "Curve - Right", "Curve - Right", "Curve - Right", "Curve - Right", "Cur…
#> $ ve_forms      <dbl> 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2…
#> $ ve_total      <dbl> 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2…
#> $ vin           <chr> NA, "1GKS2BKC8GR3", "1GKS2BKC8GR3", "1GKS2BKC8GR3", "1GKS2BKC8GR3", "1GKS2BK…
#> $ vnum_lan      <chr> NA, "Five lanes", "Five lanes", "Five lanes", "Five lanes", "Five lanes", "T…
#> $ vpavetyp      <chr> NA, "Blacktop, Bituminous, or Asphalt", "Blacktop, Bituminous, or Asphalt", …
#> $ vpicbodyclass <chr> NA, "Sport Utility Vehicle (SUV)/Multi-Purpose Vehicle (MPV)", "Sport Utilit…
#> $ vpicmake      <chr> NA, "GMC", "GMC", "GMC", "GMC", "GMC", "Chevrolet", "Ford", "Ford", NA, "Int…
#> $ vpicmodel     <chr> NA, "Yukon", "Yukon", "Yukon", "Yukon", "Yukon", "Suburban", "F-150", "F-150…
#> $ vprofile      <chr> NA, "Level", "Level", "Level", "Level", "Level", "Level", "Level", "Level", …
#> $ vspd_lim      <chr> NA, "55 MPH", "55 MPH", "55 MPH", "55 MPH", "55 MPH", "55 MPH", "55 MPH", "5…
#> $ vsurcond      <chr> NA, "Dry", "Dry", "Dry", "Dry", "Dry", "Wet", "Wet", "Wet", NA, "Dry", "Dry"…
#> $ vtcont_f      <chr> NA, "No Controls", "No Controls", "No Controls", "No Controls", "No Controls…
#> $ vtrafcon      <chr> NA, "No Controls", "No Controls", "No Controls", "No Controls", "No Controls…
#> $ vtrafway      <chr> NA, "Two-Way, Not Divided With a Continuous Left-Turn Lane", "Two-Way, Not D…
#> $ work_inj      <chr> "No", "Not Applicable (not a fatality)", "Not Applicable (not a fatality)", …
#> $ wrk_zone      <chr> "None", "None", "None", "None", "None", "None", "None", "None", "None", "Non…
```

The `multi_` tibbles contain those variables for which there may be a
varying number of values for any entity (e.g., driver impairments,
vehicle events, weather conditions at time of crash). Each tibble has
the requisite data elements corresponding to the entity: `multi_acc`
includes `st_case` and `year`, `multi_veh` adds `veh_no` (vehicle
number), and `multi_per` adds `per_no` (person number).

The top name-value pairs of each tibble are shown below.

``` r
myFARS$multi_acc %>% filter(!is.na(value)) %>% group_by(name, value) %>% summarize(n=n(), .groups = "drop") %>% arrange(desc(n)) %>% slice(1:10) %>% select(name, value, n) %>% knitr::kable(format = "html")
```

<table>
<thead>
<tr>
<th style="text-align:left;">
name
</th>
<th style="text-align:left;">
value
</th>
<th style="text-align:right;">
n
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
weather
</td>
<td style="text-align:left;">
Rain
</td>
<td style="text-align:right;">
96
</td>
</tr>
<tr>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
Motor Vehicle struck by falling cargo,or something that came loose from
or something that was set in motion by a vehicle
</td>
<td style="text-align:right;">
24
</td>
</tr>
<tr>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
Indication of a Stalled/Disabled Vehicle
</td>
<td style="text-align:right;">
12
</td>
</tr>
<tr>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
Police Pursuit Involved
</td>
<td style="text-align:right;">
11
</td>
</tr>
<tr>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
Recent/Previous Crash scene Nearby
</td>
<td style="text-align:right;">
7
</td>
</tr>
<tr>
<td style="text-align:left;">
weather
</td>
<td style="text-align:left;">
Fog, Smog, Smoke
</td>
<td style="text-align:right;">
6
</td>
</tr>
<tr>
<td style="text-align:left;">
weather
</td>
<td style="text-align:left;">
Snow
</td>
<td style="text-align:right;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
Regular Congestion
</td>
<td style="text-align:right;">
3
</td>
</tr>
<tr>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
Non-occupant struck by falling cargo, or something that came loose from,
or something that was set in motion by a vehicle
</td>
<td style="text-align:right;">
2
</td>
</tr>
<tr>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
10
</td>
<td style="text-align:right;">
1
</td>
</tr>
</tbody>
</table>

``` r
myFARS$multi_veh %>% filter(!is.na(value)) %>% group_by(name, value) %>% summarize(n=n(), .groups = "drop") %>% arrange(desc(n)) %>% slice(1:10) %>% select(name, value, n) %>% knitr::kable(format = "html")
```

<table>
<thead>
<tr>
<th style="text-align:left;">
name
</th>
<th style="text-align:left;">
value
</th>
<th style="text-align:right;">
n
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
vehiclecc
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:right;">
1352
</td>
</tr>
<tr>
<td style="text-align:left;">
vision
</td>
<td style="text-align:left;">
No Obstruction Noted
</td>
<td style="text-align:right;">
1264
</td>
</tr>
<tr>
<td style="text-align:left;">
damage
</td>
<td style="text-align:left;">
12 Clock Value
</td>
<td style="text-align:right;">
1093
</td>
</tr>
<tr>
<td style="text-align:left;">
drdistract
</td>
<td style="text-align:left;">
Not Distracted
</td>
<td style="text-align:right;">
1025
</td>
</tr>
<tr>
<td style="text-align:left;">
damage
</td>
<td style="text-align:left;">
11 Clock Value
</td>
<td style="text-align:right;">
917
</td>
</tr>
<tr>
<td style="text-align:left;">
damage
</td>
<td style="text-align:left;">
1 Clock Value
</td>
<td style="text-align:right;">
884
</td>
</tr>
<tr>
<td style="text-align:left;">
drimpair
</td>
<td style="text-align:left;">
None/Apparently Normal
</td>
<td style="text-align:right;">
736
</td>
</tr>
<tr>
<td style="text-align:left;">
damage
</td>
<td style="text-align:left;">
10 Clock Value
</td>
<td style="text-align:right;">
699
</td>
</tr>
<tr>
<td style="text-align:left;">
damage
</td>
<td style="text-align:left;">
2 Clock Value
</td>
<td style="text-align:right;">
635
</td>
</tr>
<tr>
<td style="text-align:left;">
damage
</td>
<td style="text-align:left;">
9 Clock Value
</td>
<td style="text-align:right;">
560
</td>
</tr>
</tbody>
</table>

``` r
myFARS$multi_per %>% filter(!is.na(value)) %>% group_by(name, value) %>% summarize(n=n(), .groups = "drop") %>% arrange(desc(n)) %>% slice(1:10) %>% select(name, value, n) %>% knitr::kable(format = "html")
```

<table>
<thead>
<tr>
<th style="text-align:left;">
name
</th>
<th style="text-align:left;">
value
</th>
<th style="text-align:right;">
n
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
order
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:right;">
2107
</td>
</tr>
<tr>
<td style="text-align:left;">
multrace
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:right;">
2096
</td>
</tr>
<tr>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:right;">
1292
</td>
</tr>
<tr>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:right;">
1236
</td>
</tr>
<tr>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:right;">
1236
</td>
</tr>
<tr>
<td style="text-align:left;">
race
</td>
<td style="text-align:left;">
Not a Fatality (not Applicable)
</td>
<td style="text-align:right;">
1099
</td>
</tr>
<tr>
<td style="text-align:left;">
race
</td>
<td style="text-align:left;">
White
</td>
<td style="text-align:right;">
597
</td>
</tr>
<tr>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Tested, No Drugs Found/Negative
</td>
<td style="text-align:right;">
579
</td>
</tr>
<tr>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Vitreous
</td>
<td style="text-align:right;">
353
</td>
</tr>
<tr>
<td style="text-align:left;">
race
</td>
<td style="text-align:left;">
Black or African American
</td>
<td style="text-align:right;">
254
</td>
</tr>
</tbody>
</table>

The `events` tibble provides a sequence of numbered events for each
vehicle in each crash. See the vignette for more information.

``` r
head(myFARS$events, 10) %>% knitr::kable(format="html")
```

<table>
<thead>
<tr>
<th style="text-align:left;">
state
</th>
<th style="text-align:left;">
st_case
</th>
<th style="text-align:left;">
veh_no
</th>
<th style="text-align:left;">
aoi
</th>
<th style="text-align:left;">
soe
</th>
<th style="text-align:left;">
veventnum
</th>
<th style="text-align:left;">
year
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510001
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
12 Clock Point
</td>
<td style="text-align:left;">
Pedalcyclist
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2022
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510002
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
12 Clock Point
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2022
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510002
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
6 Clock Point
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2022
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510003
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
Non-Harmful Event
</td>
<td style="text-align:left;">
Ran Off Roadway - Right
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2022
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510003
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
9 Clock Point
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2022
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510003
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
5 Clock Point
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
2022
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510003
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
Non-Collision
</td>
<td style="text-align:left;">
Rollover/Overturn
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
2022
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510003
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
Non-Harmful Event
</td>
<td style="text-align:left;">
Ran Off Roadway - Right
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2022
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510003
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
11 Clock Point
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2022
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510003
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
12 Clock Point
</td>
<td style="text-align:left;">
Pedestrian
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
2022
</td>
</tr>
</tbody>
</table>

The `codebook` tibble provides a searchable codebook for the data,
useful if you know what concept you’re looking for but not the variable
that describes it. The `rfars` package includes a codebook for FARS and
GESCRSS (`rfars::fars_codebook` and `rfars::gescrss_codebook`). These
tables span 2011-2022 whereas the `codebook` object returned from
`get_fars()` and `get_gescrss()` only include the specified `years`. See
the vignette for more information.

## Helpful Links

- [National Highway Traffic Safety Administration
  (NHTSA)](https://www.nhtsa.gov/)
- [Fatality Analysis Reporting System
  (FARS)](https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars)
- [Fatality and Injury Reporting System Tool
  (FIRST)](https://cdan.dot.gov/query)
- [FARS Analytical User’s
  Manual](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813417)
- [General Estimates System
  (GES)](https://www.nhtsa.gov/national-automotive-sampling-system/nass-general-estimates-system)
- [Crash Report Sampling System
  (CRSS)](https://www.nhtsa.gov/crash-data-systems/crash-report-sampling-system)
- [CRSS Analytical User’s
  Manual](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813436)
- [NCSA and Other Data
  Sources](https://cdan.dot.gov/Homepage/MotorVehicleCrashDataOverview.htm)
- [NHTSA FTP
  Site](https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/)
