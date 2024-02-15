
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
myFARS <- get_fars(years = 2021, states = "VA", proceed = TRUE)
```

We could have saved that file locally with:

``` r
myFARS <- get_fars(years=2021, states = "VA", proceed = TRUE, dir = getwd(), cache = "myFARS.rds")
```

Note that you can assign and save this data with one function call.

We could similarly get one year of CRSS data for the south (MD, DE, DC,
WV, VA, KY, TN, NC, SC, GA, FL, AL, MS, LA, AR, OK, TX):

``` r
myCRSS <- get_gescrss(years = 2021, regions = "s", proceed = TRUE)
myCRSS <- get_gescrss(years = 2021, regions = "s", proceed = TRUE, dir = getwd(), cache = "myCRSS.rds")
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
#> Rows: 1,969
#> Columns: 196
#> $ year          <dbl> 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021…
#> $ state         <chr> "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Vir…
#> $ st_case       <dbl> 510001, 510001, 510001, 510002, 510002, 510003, 510003, 510004, 510005, 5100…
#> $ id            <dbl> 2021510001, 2021510001, 2021510001, 2021510002, 2021510002, 2021510003, 2021…
#> $ veh_no        <dbl> 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 0, 1, 1, 1, 2, 1, 2, 1, 2…
#> $ per_no        <dbl> 1, 2, 3, 1, 2, 1, 1, 1, 1, 2, 1, 2, 1, 1, 2, 1, 1, 1, 1, 2, 3, 1, 1, 1, 1, 1…
#> $ county        <dbl> 143, 143, 143, 35, 35, 83, 83, 15, 730, 730, 33, 33, 59, 61, 61, 61, 800, 81…
#> $ city          <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 1910, 1910, 0, 0, 0, 0, 0, 0, 2390, 2540, 2540, 2540…
#> $ lon           <dbl> -79.29690, -79.29690, -79.29690, -80.70023, -80.70023, -78.96757, -78.96757,…
#> $ lat           <dbl> 36.58791, 36.58791, 36.58791, 36.78224, 36.78224, 36.87302, 36.87302, 37.931…
#> $ acc_type      <chr> "A1-Single Driver-Right Roadside Departure-Drive Off Road", "A1-Single Drive…
#> $ age           <chr> "26 Years", "27 Years", "24 Years", "20 Years", "21 Years", "79 Years", "28 …
#> $ air_bag       <chr> "Deployed- Front", "Deployed- Front", "Not Deployed", "Deployed- Side (door,…
#> $ alc_det       <chr> "Not Reported", "Not Reported", "Not Reported", "Not Reported", "Not Reporte…
#> $ alc_res       <chr> "0.101 % BAC", "Test Not Given", "Test Not Given", "Test Not Given", "Test N…
#> $ alc_status    <chr> "Test Given", "Test Not Given", "Test Not Given", "Test Not Given", "Test No…
#> $ arr_hour      <chr> "Unknown EMS Scene Arrival Hour", "Unknown EMS Scene Arrival Hour", "Unknown…
#> $ arr_min       <chr> "Unknown EMS Scene Arrival Minutes", "Unknown EMS Scene Arrival Minutes", "U…
#> $ atst_typ      <chr> "Vitreous", "Test Not Given", "Test Not Given", "Test Not Given", "Test Not …
#> $ bikecgp       <chr> NA, NA, NA, NA, NA, "Not a Cyclist", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ bikectype     <chr> NA, NA, NA, NA, NA, "Not a Cyclist", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ bikedir       <chr> NA, NA, NA, NA, NA, "Not a Cyclist", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ bikeloc       <chr> NA, NA, NA, NA, NA, "Not a Cyclist", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ bikepos       <chr> NA, NA, NA, NA, NA, "Not a Cyclist", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ body_typ      <chr> "Compact Utility (Utility Vehicle Categories \"Small\" and \"Midsize\")", "C…
#> $ bus_use       <chr> "Not a Bus", "Not a Bus", "Not a Bus", "Not a Bus", "Not a Bus", NA, "Not a …
#> $ cargo_bt      <chr> "Not Applicable (N/A)", "Not Applicable (N/A)", "Not Applicable (N/A)", "Not…
#> $ cdl_stat      <chr> "No (CDL)", "No (CDL)", "No (CDL)", "No (CDL)", "No (CDL)", NA, "No (CDL)", …
#> $ cityname      <chr> "NOT APPLICABLE", "NOT APPLICABLE", "NOT APPLICABLE", "NOT APPLICABLE", "NOT…
#> $ countyname    <chr> "PITTSYLVANIA (143)", "PITTSYLVANIA (143)", "PITTSYLVANIA (143)", "CARROLL (…
#> $ day           <dbl> 1, 1, 1, 2, 2, 6, 6, 6, 6, 6, 5, 5, 8, 4, 4, 4, 11, 6, 6, 6, 6, 6, 11, 11, 1…
#> $ day_week      <chr> "Friday", "Friday", "Friday", "Saturday", "Saturday", "Wednesday", "Wednesda…
#> $ death_da      <chr> "1", "Not Applicable (Non-Fatal)", "Not Applicable (Non-Fatal)", "Not Applic…
#> $ death_hr      <chr> "2:00-2:59", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "No…
#> $ death_mn      <chr> "28", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "Not Appli…
#> $ death_mo      <chr> "January", "Not Applicable (Non-Fatal)", "Not Applicable (Non-Fatal)", "Not …
#> $ death_tm      <chr> NA, "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "Not Applica…
#> $ death_yr      <chr> "2021", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "Not App…
#> $ deaths        <dbl> 1, 1, 1, 1, 1, NA, 0, 1, 1, 1, 2, 2, 1, 1, 1, 0, 1, NA, 0, 0, 0, 0, 1, 0, 1,…
#> $ deformed      <chr> "Disabling Damage", "Disabling Damage", "Disabling Damage", "Disabling Damag…
#> $ doa           <chr> "Died at Scene", "Not Applicable", "Not Applicable", "Not Applicable", "Died…
#> $ dr_drink      <chr> "Yes", "Yes", "Yes", "Yes", "Yes", NA, "No", "No", "No", "No", "No", "No", "…
#> $ dr_hgt        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ dr_pres       <chr> "Yes", "Yes", "Yes", "Yes", "Yes", NA, "Yes", "Yes", "Yes", "Yes", "Yes", "Y…
#> $ dr_wgt        <chr> "265 lbs.", "265 lbs.", "265 lbs.", "170 lbs.", "170 lbs.", NA, "240 lbs.", …
#> $ dr_zip        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ drinking      <chr> "Reported as Unknown", "Not Reported", "Not Reported", "Yes (Alcohol Involve…
#> $ drug_det      <chr> "Not Reported", "Not Reported", "Not Reported", "Not Reported", "Not Reporte…
#> $ drugs         <chr> "Reported as Unknown", "Not Reported", "Not Reported", "No (drugs not involv…
#> $ dstatus       <chr> "Test Given", "Test Not Given", "Test Not Given", "Test Not Given", "Test No…
#> $ ej_path       <chr> "Ejection Path Not Applicable", "Ejection Path Not Applicable", "Ejection Pa…
#> $ ejection      <chr> "Not Ejected", "Not Ejected", "Totally Ejected", "Totally Ejected", "Totally…
#> $ emer_use      <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ extricat      <chr> "Not Extricated or Not Applicable", "Not Extricated or Not Applicable", "Not…
#> $ fatals        <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ fire_exp      <chr> "No or Not Reported", "No or Not Reported", "No or Not Reported", "No or Not…
#> $ first_mo      <chr> "January", "January", "January", "No Record", "No Record", NA, "February", "…
#> $ first_yr      <chr> "2017", "2017", "2017", "No Record", "No Record", NA, "2016", "2019", "2020"…
#> $ func_sys      <chr> "Minor Collector", "Minor Collector", "Minor Collector", "Minor Arterial", "…
#> $ gvwr_from     <chr> "Class 1: 6,000 lbs. or less (2,722 kg or less)", "Class 1: 6,000 lbs. or le…
#> $ gvwr_to       <chr> "Class 1: 6,000 lbs. or less (2,722 kg or less)", "Class 1: 6,000 lbs. or le…
#> $ harm_ev       <chr> "Tree (Standing Only)", "Tree (Standing Only)", "Tree (Standing Only)", "Rol…
#> $ haz_cno       <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ haz_id        <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ haz_inv       <chr> "No", "No", "No", "No", "No", NA, "No", "No", "No", "No", "No", "No", "No", …
#> $ haz_plac      <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ haz_rel       <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ helm_mis      <chr> "None Used/Not Applicable", "None Used/Not Applicable", "None Used/Not Appli…
#> $ helm_use      <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ hispanic      <chr> "Non-Hispanic", "Not A Fatality (not Applicable)", "Not A Fatality (not Appl…
#> $ hit_run       <chr> "No", "No", "No", "No", "No", NA, "No", "No", "No", "No", "No", "No", "No", …
#> $ hosp_hr       <chr> "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Not Applicable (Not …
#> $ hosp_mn       <chr> "Unknown EMS Hospital Arrival Time", "Unknown EMS Hospital Arrival Time", "U…
#> $ hospital      <chr> "Not Transported for Treatment", "EMS Unknown Mode", "EMS Unknown Mode", "EM…
#> $ hour          <chr> "1:00am-1:59am", "1:00am-1:59am", "1:00am-1:59am", "10:00pm-10:59pm", "10:00…
#> $ icfinalbody   <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ impact1       <chr> "1 Clock Point", "1 Clock Point", "1 Clock Point", "Non-Collision", "Non-Col…
#> $ inj_sev       <chr> "Fatal Injury (K)", "Suspected Serious Injury (A)", "Suspected Serious Injur…
#> $ j_knife       <chr> "Not an Articulated Vehicle", "Not an Articulated Vehicle", "Not an Articula…
#> $ l_compl       <chr> "Valid license for this class vehicle", "Valid license for this class vehicl…
#> $ l_endors      <chr> "No Endorsements required for this vehicle", "No Endorsements required for t…
#> $ l_restri      <chr> "No Restrictions or Not Applicable", "No Restrictions or Not Applicable", "N…
#> $ l_state       <chr> "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", NA, "Virginia", …
#> $ l_status      <chr> "Valid", "Valid", "Valid", "Valid", "Valid", NA, "Valid", "Valid", "Valid", …
#> $ l_type        <chr> "Full Driver License", "Full Driver License", "Full Driver License", "Full D…
#> $ lag_hrs       <chr> NA, "Unknown", "Unknown", "Unknown", NA, NA, "Unknown", NA, "Unknown", NA, N…
#> $ lag_mins      <chr> NA, "Unknown", "Unknown", "Unknown", NA, NA, "Unknown", NA, "Unknown", NA, N…
#> $ last_mo       <chr> "June", "June", "June", "No Record", "No Record", NA, "July", "October", "No…
#> $ last_yr       <chr> "2019", "2019", "2019", "No Record", "No Record", NA, "2018", "2019", "2020"…
#> $ lgt_cond      <chr> "Dark - Not Lighted", "Dark - Not Lighted", "Dark - Not Lighted", "Dark - No…
#> $ location      <chr> "Occupant of a Motor Vehicle", "Occupant of a Motor Vehicle", "Occupant of a…
#> $ m_harm        <chr> "Tree (Standing Only)", "Tree (Standing Only)", "Tree (Standing Only)", "Tre…
#> $ mak_mod       <chr> "Jeep / Kaiser-Jeep / Willys- Jeep Cherokee (1984-on) (For Grand Cherokee fo…
#> $ make          <chr> "Jeep / Kaiser-Jeep / Willys- Jeep", "Jeep / Kaiser-Jeep / Willys- Jeep", "J…
#> $ man_coll      <chr> "The First Harmful Event was Not a Collision with a Motor Vehicle in Transpo…
#> $ mcarr_i1      <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ mcarr_i2      <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ mcarr_id      <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ milept        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ minute        <dbl> 50, 50, 50, 22, 22, 44, 44, 47, 50, 50, 5, 5, 45, 22, 22, 22, 54, 35, 35, 35…
#> $ mod_year      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ model         <dbl> 404, 404, 404, 37, 37, NA, 472, 407, 421, 421, 401, 401, 706, 40, 40, 33, 40…
#> $ month         <chr> "January", "January", "January", "January", "January", "January", "January",…
#> $ motdir        <chr> NA, NA, NA, NA, NA, "Not Applicable", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ motman        <chr> NA, NA, NA, NA, NA, "Not Applicable", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ nhs           <chr> "Unknown if this section is on the NHS", "Unknown if this section is on the …
#> $ nmhelmet      <chr> NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmlight       <chr> NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmothpre      <chr> NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmothpro      <chr> NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmpropad      <chr> NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmrefclo      <chr> NA, NA, NA, NA, NA, "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ not_hour      <chr> "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown",…
#> $ not_min       <chr> "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown if Notified"…
#> $ numoccs       <chr> "03", "03", "03", "02", "02", NA, "01", "01", "02", "02", "02", "02", "01", …
#> $ owner         <chr> "Driver (in this crash) was  Registered Owner", "Driver (in this crash) was …
#> $ p_crash1      <chr> "Going Straight", "Going Straight", "Going Straight", "Negotiating a Curve",…
#> $ p_crash2      <chr> "Off the edge of the road on the right side", "Off the edge of the road on t…
#> $ p_crash3      <chr> "Unknown/Not Reported", "Unknown/Not Reported", "Unknown/Not Reported", "Unk…
#> $ pbcwalk       <chr> NA, NA, NA, NA, NA, "None Noted", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ pbswalk       <chr> NA, NA, NA, NA, NA, "None Noted", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ pbszone       <chr> NA, NA, NA, NA, NA, "None Noted", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ pcrash4       <chr> "Tracking", "Tracking", "Tracking", "Tracking", "Tracking", NA, "Tracking", …
#> $ pcrash5       <chr> "Departed roadway", "Departed roadway", "Departed roadway", "Departed roadwa…
#> $ pedcgp        <chr> NA, NA, NA, NA, NA, "Pedestrian in Roadway - Circumstances Unknown", NA, NA,…
#> $ pedctype      <chr> NA, NA, NA, NA, NA, "Standing in Roadway", NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ peddir        <chr> NA, NA, NA, NA, NA, "Not Applicable", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ pedleg        <chr> NA, NA, NA, NA, NA, "Not Applicable", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ pedloc        <chr> NA, NA, NA, NA, NA, "Not At Intersection", NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ pedpos        <chr> NA, NA, NA, NA, NA, "Travel Lane", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ peds          <dbl> 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0…
#> $ pedsnr        <chr> NA, NA, NA, NA, NA, "Not Applicable", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ per_typ       <chr> "Driver of a Motor Vehicle In-Transport", "Passenger of a Motor Vehicle In-T…
#> $ permvit       <dbl> 3, 3, 3, 2, 2, 1, 1, 1, 2, 2, 2, 2, 1, 3, 3, 3, 1, 4, 4, 4, 4, 4, 2, 2, 3, 3…
#> $ pernotmvit    <dbl> 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0…
#> $ persons       <dbl> 3, 3, 3, 2, 2, 1, 1, 1, 2, 2, 2, 2, 1, 3, 3, 3, 1, 4, 4, 4, 4, 4, 2, 2, 3, 3…
#> $ prev_acc      <chr> "None", "None", "None", "None", "None", NA, "None", "None", "None", "None", …
#> $ prev_dwi      <chr> "None", "None", "None", "None", "None", NA, "None", "None", "None", "None", …
#> $ prev_oth      <chr> "1", "1", "1", "None", "None", NA, "3", "None", "None", "None", "None", "Non…
#> $ prev_spd      <chr> "1", "1", "1", "None", "None", NA, "None", "2", "1", "1", "None", "None", "N…
#> $ prev_sus1     <chr> "None", "None", "None", "None", "None", NA, "None", "None", "None", "None", …
#> $ prev_sus2     <chr> "None", "None", "None", "None", "None", NA, "None", "None", "None", "None", …
#> $ prev_sus3     <chr> "2", "2", "2", "None", "None", NA, "None", "None", "None", "None", "1", "1",…
#> $ pvh_invl      <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ rail          <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ rd_owner      <chr> "State Highway Agency", "State Highway Agency", "State Highway Agency", "Sta…
#> $ reg_stat      <chr> "North Carolina", "North Carolina", "North Carolina", "Virginia", "Virginia"…
#> $ rel_road      <chr> "On Roadside", "On Roadside", "On Roadside", "On Roadside", "On Roadside", "…
#> $ reljct1       <chr> "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No"…
#> $ reljct2       <chr> "Non-Junction", "Non-Junction", "Non-Junction", "Non-Junction", "Non-Junctio…
#> $ rest_mis      <chr> "No Indication of Misuse", "No Indication of Misuse", "None Used/Not Applica…
#> $ rest_use      <chr> "Shoulder and Lap Belt Used", "Shoulder and Lap Belt Used", "None Used/Not A…
#> $ rolinloc      <chr> "No Rollover", "No Rollover", "No Rollover", "On Roadside", "On Roadside", N…
#> $ rollover      <chr> "No Rollover", "No Rollover", "No Rollover", "Rollover, Untripped", "Rollove…
#> $ route         <chr> "County Road", "County Road", "County Road", "U.S. Highway", "U.S. Highway",…
#> $ rur_urb       <chr> "Rural", "Rural", "Rural", "Rural", "Rural", "Rural", "Rural", "Rural", "Urb…
#> $ sch_bus       <chr> "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No"…
#> $ seat_pos      <chr> "Front Seat, Left Side", "Front Seat, Right Side", "Second Seat, Middle", "F…
#> $ sex           <chr> "Male", "Female", "Male", "Male", "Male", "Female", "Male", "Male", "Not Rep…
#> $ sp_jur        <chr> "No Special Jurisdiction", "No Special Jurisdiction", "No Special Jurisdicti…
#> $ spec_use      <chr> "No Special Use Noted", "No Special Use Noted", "No Special Use Noted", "No …
#> $ speedrel      <chr> "Yes, Exceeded Speed Limit", "Yes, Exceeded Speed Limit", "Yes, Exceeded Spe…
#> $ statename     <chr> "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Vir…
#> $ str_veh       <dbl> 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ tow_veh       <chr> "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trailing …
#> $ towed         <chr> "Towed Due to Disabling Damage", "Towed Due to Disabling Damage", "Towed Due…
#> $ trav_sp       <chr> "070 MPH", "070 MPH", "070 MPH", "065 MPH", "065 MPH", NA, "055 MPH", "065 M…
#> $ trlr1gvwr     <chr> "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trailing …
#> $ trlr1vin      <chr> "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trailing …
#> $ trlr2gvwr     <chr> "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trailing …
#> $ trlr2vin      <chr> "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trailing …
#> $ trlr3gvwr     <chr> "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trailing …
#> $ trlr3vin      <chr> "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trailing …
#> $ tway_id       <chr> "CR-655", "CR-655", "CR-655", "US-221", "US-221", "CR-641", "CR-641", "CR-60…
#> $ tway_id2      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "OLD TAVERN RD", "OLD TA…
#> $ typ_int       <chr> "Not an Intersection", "Not an Intersection", "Not an Intersection", "Not an…
#> $ underoverride <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ unittype      <chr> "Motor Vehicle In-Transport (Inside or Outside the Trafficway)", "Motor Vehi…
#> $ v_config      <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ valign        <chr> "Straight", "Straight", "Straight", "Curve - Left", "Curve - Left", NA, "Cur…
#> $ ve_forms      <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3…
#> $ ve_total      <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3…
#> $ vin           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ vnum_lan      <chr> "Two lanes", "Two lanes", "Two lanes", "Two lanes", "Two lanes", NA, "Two la…
#> $ vpavetyp      <chr> "Blacktop, Bituminous, or Asphalt", "Blacktop, Bituminous, or Asphalt", "Bla…
#> $ vpicbodyclass <chr> "Sport Utility Vehicle (SUV)/Multi-Purpose Vehicle (MPV)", "Sport Utility Ve…
#> $ vpicmake      <chr> "Jeep", "Jeep", "Jeep", "Ford", "Ford", NA, "Toyota", "Jeep", "Chevrolet", "…
#> $ vpicmodel     <chr> "Grand Cherokee", "Grand Cherokee", "Grand Cherokee", "Focus", "Focus", NA, …
#> $ vprofile      <chr> "Level", "Level", "Level", "Grade, Unknown Slope", "Grade, Unknown Slope", N…
#> $ vspd_lim      <chr> "45 MPH", "45 MPH", "45 MPH", "55 MPH", "55 MPH", NA, "55 MPH", "45 MPH", "6…
#> $ vsurcond      <chr> "Dry", "Dry", "Dry", "Dry", "Dry", NA, "Dry", "Dry", "Dry", "Dry", "Dry", "D…
#> $ vtcont_f      <chr> "No Controls", "No Controls", "No Controls", "No Controls", "No Controls", N…
#> $ vtrafcon      <chr> "No Controls", "No Controls", "No Controls", "No Controls", "No Controls", N…
#> $ vtrafway      <chr> "Two-Way, Not Divided", "Two-Way, Not Divided", "Two-Way, Not Divided", "Two…
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
80
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
25
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
20
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
10
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
8
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
5
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
4
</td>
</tr>
<tr>
<td style="text-align:left;">
weather
</td>
<td style="text-align:left;">
Clear
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
Other Maintenance or Construction-Created Condition
</td>
<td style="text-align:right;">
2
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
1278
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
1223
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
1041
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
1011
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
907
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
845
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
831
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
709
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
637
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
571
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
multrace
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:right;">
1966
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
1132
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
1132
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
996
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
968
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
582
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
385
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
262
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
225
</td>
</tr>
<tr>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Cannabinoid, Type Unknown
</td>
<td style="text-align:right;">
166
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
Non-Harmful Event
</td>
<td style="text-align:left;">
Ran Off Roadway - Right
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2021
</td>
</tr>
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
1 Clock Point
</td>
<td style="text-align:left;">
Tree (Standing Only)
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2021
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
Non-Harmful Event
</td>
<td style="text-align:left;">
Cross Centerline
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2021
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
Non-Harmful Event
</td>
<td style="text-align:left;">
Ran Off Roadway - Left
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2021
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
Non-Collision
</td>
<td style="text-align:left;">
Rollover/Overturn
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
2021
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
4 Clock Point
</td>
<td style="text-align:left;">
Tree (Standing Only)
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
2021
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
11 Clock Point
</td>
<td style="text-align:left;">
Pedestrian
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2021
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
2
</td>
<td style="text-align:left;">
2021
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
11 Clock Point
</td>
<td style="text-align:left;">
Ditch
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
2021
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
510004
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
Non-Harmful Event
</td>
<td style="text-align:left;">
Cross Centerline
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2021
</td>
</tr>
</tbody>
</table>

The `codebook` tibble provides a searchable codebook for the data,
useful if you know what concept you’re looking for but not the variable
that describes it. The `rfars` package includes a codebook for FARS and
GESCRSS (`rfars::fars_codebook` and `rfars::gescrss_codebook`). These
tables span 2011-2021 whereas the `codebook` object returned from
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
