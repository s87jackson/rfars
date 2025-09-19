
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

`rfars` allows users to download the last 10 years of FARS and GES/CRSS
data with just one line of code. The result is a full, rich dataset
ready for mapping, modeling, and other downstream analysis. Codebooks
with variable definitions and value labels support an informed analysis
of the data (see `vignette("Searchable Codebooks", package = "rfars")`
for more information). Helper functions are also provided to produce
common counts and comparisons.

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
`rfars` package. These functions download and process data files
directly from [NHTSA’s FTP
Site](https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/), or pull
the prepared data stored on your local machine, or (as of Version 2.0)
pull the prepared data from Zenodo. The data files hosted on Zenodo are
stable, have DOIs, and replicate the data that would be produced by
`get_fars()` and `get_gescrss()`, but in a fraction of the time.

They take the parameters `years` and `states` (FARS) or `regions`
(GES/CRSS). As the source data files follow an annual structure, `years`
determines how many file sets are downloaded or loaded, and
`states`/`regions` filters the resulting dataset. Downloading and
processing these files can take several minutes. Before downloading,
`rfars` will inform you that it’s about to download files and asks your
permission to do so. To skip this dialog, set `proceed = TRUE`. You can
use the `dir` and `cache` parameters to save an RDS file to your local
machine. The `dir` parameter specifies the directory, and `cache` names
the file (be sure to include the .rds file extension).

Executing the code below will download the prepared FARS database for
2014-2023.

``` r
myFARS <- get_fars(proceed = TRUE)
```

We could also download the prepared GES/CRSS database:

``` r
myCRSS <- get_gescrss(proceed = TRUE)
```

`get_fars()` and `get_gescrss()` return a list with six tibbles: `flat`,
`multi_acc`, `multi_veh`, `multi_per`, `events`, and `codebook`.

Each row in the `flat` tibble corresponds to a person involved in a
crash. As there may be multiple people and/or vehicles involved in one
crash, some variable-values are repeated within a crash or vehicle. Each
crash is uniquely identified with `id`, which is a combination of `year`
and `st_case`. Note that `st_case` is not unique across years, for
example, `st_case` 510001 will appear in each year. The `id` variable
attempts to avoid this issue.

``` r
glimpse(myFARS$flat, width = 80)
#> Rows: 867,460
#> Columns: 227
#> $ year          <dbl> 2014, 2014, 2014, 2014, 2014, 2014, 2014, 2014, 2014, 20…
#> $ state         <fct> Alabama, Alabama, Alabama, Alabama, Alabama, Alabama, Al…
#> $ st_case       <dbl> 10001, 10001, 10002, 10003, 10003, 10003, 10003, 10003, …
#> $ id            <dbl> 201410001, 201410001, 201410002, 201410003, 201410003, 2…
#> $ veh_no        <dbl> 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 2, 2, 2, 3, 1, 1, 1, 2,…
#> $ per_no        <dbl> 1, 2, 1, 1, 2, 3, 4, 1, 2, 3, 1, 1, 2, 3, 1, 1, 1, 1, 1,…
#> $ county        <dbl> 71, 71, 59, 125, 125, 125, 125, 125, 125, 125, 121, 121,…
#> $ city          <dbl> 0, 0, 0, 3050, 3050, 3050, 3050, 3050, 3050, 3050, 2275,…
#> $ lon           <dbl> -85.98141, -85.98141, -87.77212, -87.52591, -87.52591, -…
#> $ lat           <dbl> 34.62372, 34.62372, 34.39743, 33.19717, 33.19717, 33.197…
#> $ acc_type      <fct> "Drive Off Road", "Drive Off Road", "Drive Off Road", "S…
#> $ age           <fct> 24 Years, 30 Years, 52 Years, 22 Years, 21 Years, 18 Yea…
#> $ air_bag       <fct> "Deployed- Combination", "Deployed- Combination", "Deplo…
#> $ alc_det       <fct> "Observed", "Not Reported", "Not Reported", "Not Reporte…
#> $ alc_res       <fct> "0.26 % BAC", "Test Not Given", "0.31 % BAC", "Test Not …
#> $ alc_status    <fct> Test Given, Test Not Given, Test Given, Test Not Given, …
#> $ arr_hour      <fct> 1:00am-1:59am, 1:00am-1:59am, 1:00pm-1:59pm, 3:00am-3:59…
#> $ arr_min       <fct> 35, 35, 50, 10, 10, 10, 10, 10, 10, 10, 15, 15, 15, 15, …
#> $ atst_typ      <fct> "Blood", "Test Not Given", "Blood", "Test Not Given", "T…
#> $ bikecgp       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ bikectype     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ bikedir       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ bikeloc       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ bikepos       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ body_typ      <fct> "4-door sedan, hardtop", "4-door sedan, hardtop", "Stand…
#> $ bus_use       <fct> "Not a Bus", "Not a Bus", "Not a Bus", "Not a Bus", "Not…
#> $ cargo_bt      <fct> Not Applicable (N/A), Not Applicable (N/A), Not Applicab…
#> $ cdl_stat      <fct> Suspended, Suspended, No (CDL), No (CDL), No (CDL), No (…
#> $ cert_no       <fct> ************, ************, ************, ************, …
#> $ day           <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3,…
#> $ day_week      <fct> Wednesday, Wednesday, Wednesday, Wednesday, Wednesday, W…
#> $ death_da      <fct> 1, Not Applicable (Non-Fatal), 1, Not Applicable (Non-Fa…
#> $ death_hr      <fct> 1:00-1:59, Not Applicable (Non-fatal), 13:00-13:59, Not …
#> $ death_mn      <fct> 15, Not Applicable (Non-fatal), 45, Not Applicable (Non-…
#> $ death_mo      <fct> January, Not Applicable (Non-Fatal), January, Not Applic…
#> $ death_tm      <chr> "115", "8888", "1345", "8888", "8888", "8888", "8888", "…
#> $ death_yr      <fct> 2014, Not Applicable (Non-fatal), 2014, Not Applicable (…
#> $ deaths        <dbl> 1, 1, 1, 0, 0, 0, 0, 2, 2, 2, 1, 0, 0, 0, 0, 1, 1, 0, 1,…
#> $ deformed      <fct> "Disabling Damage", "Disabling Damage", "Disabling Damag…
#> $ doa           <fct> Died at Scene, Not Applicable, Not Applicable, Not Appli…
#> $ dr_drink      <fct> Yes, Yes, Yes, No, No, No, No, No, No, No, No, No, No, N…
#> $ dr_hgt        <fct> 64, 64, 71, 999, 999, 999, 999, 63, 63, 63, 65, 74, 74, …
#> $ dr_pres       <fct> Yes, Yes, Yes, Yes, Yes, Yes, Yes, Yes, Yes, Yes, Yes, Y…
#> $ dr_wgt        <fct> 135 lbs., 135 lbs., 225 lbs., Unknown, Unknown, Unknown,…
#> $ dr_zip        <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ drinking      <fct> Yes (Alcohol Involved), Not Reported, Yes (Alcohol Invol…
#> $ drug_det      <fct> "Not Reported", "Not Reported", "Not Reported", "Not Rep…
#> $ drugs         <fct> Unknown, Not Reported, No (drugs not involved), Unknown,…
#> $ drunk_dr      <dbl> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,…
#> $ dstatus       <fct> Test Given, Test Not Given, Test Given, Test Not Given, …
#> $ ej_path       <fct> "Not Ejected/Not Applicable", "Not Ejected/Not Applicabl…
#> $ ejection      <fct> Not Ejected, Not Ejected, Not Ejected, Not Ejected, Not …
#> $ emer_use      <fct> "Not Applicable", "Not Applicable", "Not Applicable", "N…
#> $ extricat      <fct> Extricated, Not Extricated or Not Applicable, Not Extric…
#> $ fatals        <dbl> 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ fire_exp      <fct> No or Not Reported, No or Not Reported, No or Not Report…
#> $ first_mo      <fct> November, November, No Record, No Record, No Record, No …
#> $ first_yr      <fct> 2011, 2011, No Record, No Record, No Record, No Record, …
#> $ gvwr          <fct> "Not Applicable", "Not Applicable", "Not Applicable", "N…
#> $ harm_ev       <fct> "Boulder", "Boulder", "Tree (Standing Only)", "Motor Veh…
#> $ haz_cno       <fct> Not Applicable, Not Applicable, Not Applicable, Not Appl…
#> $ haz_id        <fct> Not Applicable, Not Applicable, Not Applicable, Not Appl…
#> $ haz_inv       <fct> No, No, No, No, No, No, No, No, No, No, No, No, No, No, …
#> $ haz_plac      <fct> Not Applicable, Not Applicable, Not Applicable, Not Appl…
#> $ haz_rel       <fct> Not Applicable, Not Applicable, Not Applicable, Not Appl…
#> $ hispanic      <fct> "Non-Hispanic", "Not A Fatality (not Applicable)", "Non-…
#> $ hit_run       <fct> No, No, No, Yes, Yes, Yes, Yes, No, No, No, No, No, No, …
#> $ hosp_hr       <fct> Unknown, Unknown, Unknown, Unknown, Unknown, Unknown, Un…
#> $ hosp_mn       <fct> Unknown EMS Hospital Arrival Time, Unknown EMS Hospital …
#> $ hospital      <fct> Not Transported, EMS Air, EMS Ground, Not Transported, N…
#> $ hour          <fct> 1:00am-1:59am, 1:00am-1:59am, 1:00pm-1:59pm, 3:00am-3:59…
#> $ impact1       <fct> "11 Clock Point", "11 Clock Point", "12 Clock Point", "1…
#> $ inj_sev       <fct> "Fatal Injury (K)", "Suspected Minor Injury(B)", "Fatal …
#> $ j_knife       <fct> Not an Articulated Vehicle, Not an Articulated Vehicle, …
#> $ l_compl       <fct> No valid license for this class vehicle, No valid licens…
#> $ l_endors      <fct> "No Endorsements required for this vehicle", "No Endorse…
#> $ l_restri      <fct> "No Restrictions or Not Applicable", "No Restrictions or…
#> $ l_state       <fct> Alabama, Alabama, Alabama, Alabama, Alabama, Alabama, Al…
#> $ l_status      <fct> Suspended, Suspended, Suspended, Not licensed, Not licen…
#> $ l_type        <fct> Full Driver License, Full Driver License, Full Driver Li…
#> $ lag_hrs       <fct> 0, 999, 0, 999, 999, 999, 999, 0, 0, 999, 0, 999, 999, 9…
#> $ lag_mins      <fct> 0, 99, 15, 99, 99, 99, 99, 0, 13, 99, 0, 99, 99, 99, 99,…
#> $ last_mo       <fct> April, April, No Record, No Record, No Record, No Record…
#> $ last_yr       <fct> 2013, 2013, No Record, No Record, No Record, No Record, …
#> $ lgt_cond      <fct> Dark - Not Lighted, Dark - Not Lighted, Daylight, Dark -…
#> $ location      <fct> "Occupant of a Motor Vehicle", "Occupant of a Motor Vehi…
#> $ m_harm        <fct> "Tree (Standing Only)", "Tree (Standing Only)", "Tree (S…
#> $ mak_mod       <chr> "Toyota Corolla", "Toyota Corolla", "Dodge Ram Pickup", …
#> $ make          <fct> Toyota, Toyota, Dodge, Chevrolet, Chevrolet, Chevrolet, …
#> $ man_coll      <fct> Not a Collision with Motor Vehicle In-Transport, Not a C…
#> $ mcarr_i1      <fct> Not Applicable, Not Applicable, Not Applicable, Not Appl…
#> $ mcarr_i2      <fct> Not Applicable, Not Applicable, Not Applicable, Not Appl…
#> $ mcarr_id      <fct> Not Applicable, Not Applicable, Not Applicable, Not Appl…
#> $ milept        <fct> None, None, None, None, None, None, None, None, None, No…
#> $ minute        <fct> 15, 15, 30, 7, 7, 7, 7, 7, 7, 7, 0, 0, 0, 0, 0, 30, 0, 4…
#> $ mod_year      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ model         <dbl> 32, 32, 482, 37, 37, 37, 37, 40, 40, 40, 472, 461, 461, …
#> $ month         <fct> January, January, January, January, January, January, Ja…
#> $ motdir        <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ motman        <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ msafeqmt      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nhs           <fct> This section IS NOT on the NHS, This section IS NOT on t…
#> $ not_hour      <fct> Unknown, Unknown, Unknown, Unknown, Unknown, Unknown, Un…
#> $ not_min       <fct> Unknown, Unknown, Unknown, Unknown, Unknown, Unknown, Un…
#> $ numoccs       <fct> 02, 02, 01, 04, 04, 04, 04, 03, 03, 03, 01, 03, 03, 03, …
#> $ owner         <fct> "Driver (in this crash) Not Registered Owner (Other Priv…
#> $ p_crash1      <fct> Negotiating a Curve, Negotiating a Curve, Going Straight…
#> $ p_crash2      <fct> "Off the edge of the road on the left side", "Off the ed…
#> $ p_crash3      <fct> No Avoidance Maneuver, No Avoidance Maneuver, No Avoidan…
#> $ pbcwalk       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ pbswalk       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ pbszone       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ pcrash4       <fct> "Tracking", "Tracking", "Tracking", "Tracking", "Trackin…
#> $ pcrash5       <fct> "Departed roadway", "Departed roadway", "Departed roadwa…
#> $ pedcgp        <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ pedctype      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ peddir        <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ pedleg        <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ pedloc        <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ pedpos        <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ peds          <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ pedsnr        <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ per_typ       <fct> "Driver of a Motor Vehicle In-Transport", "Passenger of …
#> $ permvit       <dbl> 2, 2, 1, 7, 7, 7, 7, 7, 7, 7, 5, 5, 5, 5, 5, 1, 1, 2, 2,…
#> $ pernotmvit    <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ persons       <dbl> 2, 2, 1, 7, 7, 7, 7, 7, 7, 7, 5, 5, 5, 5, 5, 1, 1, 2, 2,…
#> $ prev_acc      <fct> None, None, None, None, None, None, None, None, None, No…
#> $ prev_dwi      <fct> 2, 2, None, None, None, None, None, None, None, None, No…
#> $ prev_oth      <fct> 1, 1, None, None, None, None, None, None, None, None, No…
#> $ prev_spd      <fct> 1, 1, None, None, None, None, None, None, None, None, No…
#> $ prev_sus      <fct> 6, 6, None, None, None, None, None, None, None, None, No…
#> $ pvh_invl      <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,…
#> $ race          <fct> "White", "Not a Fatality (not Applicable)", "White", "No…
#> $ rail          <fct> Not Applicable, Not Applicable, Not Applicable, Not Appl…
#> $ reg_stat      <fct> Alabama, Alabama, Alabama, Alabama, Alabama, Alabama, Al…
#> $ rel_road      <fct> On Roadside, On Roadside, On Roadside, On Roadway, On Ro…
#> $ reljct1       <fct> No, No, No, No, No, No, No, No, No, No, No, No, No, No, …
#> $ reljct2       <fct> Non-Junction, Non-Junction, Non-Junction, Intersection, …
#> $ rest_mis      <fct> "No", "No", "No", "No", "No", "No", "No", "No", "No", "N…
#> $ rest_use      <fct> "Shoulder and Lap Belt Used", "Shoulder and Lap Belt Use…
#> $ road_fnc      <fct> Rural-Minor Collector, Rural-Minor Collector, Rural-Loca…
#> $ rolinloc      <fct> On Roadside, On Roadside, No Rollover, No Rollover, No R…
#> $ rollover      <fct> "Rollover, Tripped by Object/Vehicle", "Rollover, Trippe…
#> $ route         <fct> County Road, County Road, County Road, U.S. Highway, U.S…
#> $ rur_urb       <fct> Rural, Rural, Rural, Urban, Urban, Urban, Urban, Urban, …
#> $ sch_bus       <fct> No, No, No, No, No, No, No, No, No, No, No, No, No, No, …
#> $ seat_pos      <fct> "Front Seat, Left Side", "Front Seat, Right Side", "Fron…
#> $ sex           <fct> Male, Female, Male, Male, Female, Male, Male, Female, Fe…
#> $ sp_jur        <fct> No Special Jurisdiction, No Special Jurisdiction, No Spe…
#> $ spec_use      <fct> "No Special Use", "No Special Use", "No Special Use", "N…
#> $ speedrel      <fct> "Yes, Exceeded Speed Limit", "Yes, Exceeded Speed Limit"…
#> $ str_veh       <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ tow_veh       <fct> "No Trailing Units", "No Trailing Units", "No Trailing U…
#> $ towed         <fct> "Towed Due to Disabling Damage", "Towed Due to Disabling…
#> $ trav_sp       <fct> 070 MPH, 070 MPH, 040 MPH, Unknown, Unknown, Unknown, Un…
#> $ tway_id       <chr> "CR-67", "CR-67", "CR-26", "US-SR 6", "US-SR 6", "US-SR …
#> $ tway_id2      <chr> NA, NA, NA, "VERTERAN'S MEMORIAL PKWY", "VERTERAN'S MEMO…
#> $ typ_int       <fct> "Not an Intersection", "Not an Intersection", "Not an In…
#> $ underide      <fct> "No Underride or Override Noted", "No Underride or Overr…
#> $ unittype      <fct> Motor Vehicle In-Transport (Inside or Outside the Traffi…
#> $ v_config      <fct> "Not Applicable", "Not Applicable", "Not Applicable", "N…
#> $ valign        <fct> Curve Right, Curve Right, Straight, Straight, Straight, …
#> $ ve_forms      <dbl> 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 1, 1, 2, 2,…
#> $ ve_total      <dbl> 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 1, 1, 3, 3,…
#> $ vin           <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ vnum_lan      <fct> Two lanes, Two lanes, Two lanes, Five lanes, Five lanes,…
#> $ vpavetyp      <fct> "Blacktop, Bituminous, or Asphalt", "Blacktop, Bituminou…
#> $ vprofile      <fct> "Level", "Level", "Level", "Level", "Level", "Level", "L…
#> $ vspd_lim      <fct> 45 MPH, 45 MPH, 40 MPH, 45 MPH, 45 MPH, 45 MPH, 45 MPH, …
#> $ vsurcond      <fct> "Dry", "Dry", "Dry", "Dry", "Dry", "Dry", "Dry", "Dry", …
#> $ vtcont_f      <fct> "No Controls", "No Controls", "No Controls", "Device Fun…
#> $ vtrafcon      <fct> No Controls, No Controls, No Controls, Traffic control s…
#> $ vtrafway      <fct> "Two-Way, Not Divided", "Two-Way, Not Divided", "Two-Way…
#> $ work_inj      <fct> No, Not Applicable (not a fatality), No, Not Applicable …
#> $ wrk_zone      <fct> "None", "None", "None", "None", "None", "None", "None", …
#> $ func_sys      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ rd_owner      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ cityname      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ countyname    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ statename     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ trlr1vin      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ trlr2vin      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ trlr3vin      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmhelmet      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmlight       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmothpre      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmothpro      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmpropad      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmrefclo      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ prev_sus1     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ prev_sus2     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ prev_sus3     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ helm_mis      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ helm_use      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ gvwr_from     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ gvwr_to       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ icfinalbody   <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ trlr1gvwr     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ trlr2gvwr     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ trlr3gvwr     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ vpicbodyclass <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ vpicmake      <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ vpicmodel     <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ underoverride <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ devmotor      <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ devtype       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ acc_config    <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ a1            <dbl> 26, 26, 31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17…
#> $ a2            <dbl> 26, 26, 31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 0, 1…
#> $ a3            <dbl> 26, 26, 31, 14, 14, 14, 14, 14, 14, 14, 0, 0, 0, 0, 0, 0…
#> $ a4            <dbl> 26, 26, 31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17…
#> $ a5            <dbl> 26, 26, 31, 17, 17, 17, 17, 17, 17, 17, 0, 0, 0, 0, 0, 0…
#> $ a6            <dbl> 26, 26, 31, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 1…
#> $ a7            <dbl> 26, 26, 31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17…
#> $ a8            <dbl> 26, 26, 31, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0…
#> $ a9            <dbl> 26, 26, 31, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0…
#> $ a10           <dbl> 26, 26, 31, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0…
#> $ p1            <dbl> 26, NA, 31, 0, NA, NA, NA, 0, NA, NA, 0, 0, NA, NA, 0, 0…
#> $ p2            <dbl> 26, NA, 31, 0, NA, NA, NA, 0, NA, NA, 0, 0, NA, NA, 0, 1…
#> $ p3            <dbl> 26, NA, 31, 14, NA, NA, NA, 0, NA, NA, 0, 0, NA, NA, 0, …
#> $ p4            <dbl> 26, NA, 31, 0, NA, NA, NA, 0, NA, NA, 0, 0, NA, NA, 0, 0…
#> $ p5            <dbl> 26, NA, 31, 17, NA, NA, NA, 0, NA, NA, 0, 0, NA, NA, 0, …
#> $ p6            <dbl> 26, NA, 31, 15, NA, NA, NA, 0, NA, NA, 0, 0, NA, NA, 0, …
#> $ p7            <dbl> 26, NA, 31, 0, NA, NA, NA, 0, NA, NA, 0, 0, NA, NA, 0, 0…
#> $ p8            <dbl> 26, NA, 31, 15, NA, NA, NA, 0, NA, NA, 0, 0, NA, NA, 0, …
#> $ p9            <dbl> 26, NA, 31, 16, NA, NA, NA, 0, NA, NA, 0, 0, NA, NA, 0, …
#> $ p10           <dbl> 26, NA, 31, 15, NA, NA, NA, 0, NA, NA, 0, 0, NA, NA, 0, …
```

The `multi_` tibbles contain those variables for which there may be a
varying number of values for any entity (e.g., driver impairments,
vehicle events, weather conditions at time of crash). Each tibble has
the requisite data elements corresponding to the entity: `multi_acc`
includes `st_case` and `year`, `multi_veh` adds `veh_no` (vehicle
number), and `multi_per` adds `per_no` (person number).

The top name-value pairs of each tibble are shown below.

``` r
myFARS$multi_acc %>% 
  filter(!is.na(value)) %>% 
  group_by(name, value) %>% 
  summarize(n=n(), .groups = "drop") %>% 
  arrange(desc(n)) %>% slice(1:10) %>% 
  select(name, value, n) %>% 
  knitr::kable(format = "html", caption = "Top Name-Value Pairs for the multi_acc Object")
```

<table>
<caption>
Top Name-Value Pairs for the multi_acc Object
</caption>
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
weather1
</td>
<td style="text-align:left;">
Clear
</td>
<td style="text-align:right;">
140091
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
111657
</td>
</tr>
<tr>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:right;">
71250
</td>
</tr>
<tr>
<td style="text-align:left;">
weather1
</td>
<td style="text-align:left;">
Cloudy
</td>
<td style="text-align:right;">
29829
</td>
</tr>
<tr>
<td style="text-align:left;">
weather
</td>
<td style="text-align:left;">
Cloudy
</td>
<td style="text-align:right;">
21034
</td>
</tr>
<tr>
<td style="text-align:left;">
weather1
</td>
<td style="text-align:left;">
Rain
</td>
<td style="text-align:right;">
14058
</td>
</tr>
<tr>
<td style="text-align:left;">
weather
</td>
<td style="text-align:left;">
Rain
</td>
<td style="text-align:right;">
10382
</td>
</tr>
<tr>
<td style="text-align:left;">
cf1
</td>
<td style="text-align:left;">
Motor Vehicle struck by falling cargo,or something that came loose from
or something that was set in motion by a vehicle
</td>
<td style="text-align:right;">
3995
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
3549
</td>
</tr>
<tr>
<td style="text-align:left;">
weather2
</td>
<td style="text-align:left;">
Cloudy
</td>
<td style="text-align:right;">
2205
</td>
</tr>
</tbody>
</table>

``` r
myFARS$multi_veh %>% 
  filter(!is.na(value)) %>% 
  group_by(name, value) %>% 
  summarize(n=n(), .groups = "drop") %>% 
  arrange(desc(n)) %>% slice(1:10) %>% 
  select(name, value, n) %>% 
  knitr::kable(format = "html", caption = "Top Name-Value Pairs for the multi_veh Object")
```

<table>
<caption>
Top Name-Value Pairs for the multi_veh Object
</caption>
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
mvisobsc
</td>
<td style="text-align:left;">
No Obstruction Noted
</td>
<td style="text-align:right;">
282785
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
253863
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
220560
</td>
</tr>
<tr>
<td style="text-align:left;">
vehiclecc
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:right;">
218470
</td>
</tr>
<tr>
<td style="text-align:left;">
mdareas
</td>
<td style="text-align:left;">
12 Clock Value
</td>
<td style="text-align:right;">
211504
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
169994
</td>
</tr>
<tr>
<td style="text-align:left;">
mdrdstrd
</td>
<td style="text-align:left;">
Not Distracted
</td>
<td style="text-align:right;">
155771
</td>
</tr>
<tr>
<td style="text-align:left;">
vehiclesf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:right;">
118399
</td>
</tr>
<tr>
<td style="text-align:left;">
vehiclesf
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:right;">
115082
</td>
</tr>
<tr>
<td style="text-align:left;">
mdareas
</td>
<td style="text-align:left;">
11 Clock Value
</td>
<td style="text-align:right;">
109333
</td>
</tr>
</tbody>
</table>

``` r
myFARS$multi_per %>% 
  filter(!is.na(value)) %>% 
  group_by(name, value) %>% 
  summarize(n=n(), .groups = "drop") %>% 
  arrange(desc(n)) %>% slice(1:10) %>% 
  select(name, value, n) %>% 
  knitr::kable(format = "html", caption = "Top Name-Value Pairs for the multi_per Object")
```

<table>
<caption>
Top Name-Value Pairs for the multi_per Object
</caption>
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
370399
</td>
</tr>
<tr>
<td style="text-align:left;">
drugres3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:right;">
317417
</td>
</tr>
<tr>
<td style="text-align:left;">
drugtst3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:right;">
317349
</td>
</tr>
<tr>
<td style="text-align:left;">
drugres2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:right;">
305828
</td>
</tr>
<tr>
<td style="text-align:left;">
drugtst2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:right;">
305735
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
304882
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
304880
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
257238
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
201623
</td>
</tr>
<tr>
<td style="text-align:left;">
drugtst1
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:right;">
199168
</td>
</tr>
</tbody>
</table>

The `events` tibble provides a sequence of numbered events for each
vehicle in each crash. See the vignette(“Crash Sequence of Events”,
package = “rfars”) for more information.

``` r
head(myFARS$events, 10) %>% 
  knitr::kable(format="html", caption = "Preview of events Object")
```

<table>
<caption>
Preview of events Object
</caption>
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
Alabama
</td>
<td style="text-align:left;">
10001
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
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Alabama
</td>
<td style="text-align:left;">
10001
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
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Alabama
</td>
<td style="text-align:left;">
10001
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
11 Clock Point
</td>
<td style="text-align:left;">
Boulder
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Alabama
</td>
<td style="text-align:left;">
10001
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
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Alabama
</td>
<td style="text-align:left;">
10001
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
Top
</td>
<td style="text-align:left;">
Tree (Standing Only)
</td>
<td style="text-align:left;">
5
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Alabama
</td>
<td style="text-align:left;">
10001
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
Not Reported
</td>
<td style="text-align:left;">
Boulder
</td>
<td style="text-align:left;">
6
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Alabama
</td>
<td style="text-align:left;">
10001
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
Non-Collision
</td>
<td style="text-align:left;">
Immersion or Partial Immersion
</td>
<td style="text-align:left;">
7
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Alabama
</td>
<td style="text-align:left;">
10002
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
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Alabama
</td>
<td style="text-align:left;">
10002
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
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Alabama
</td>
<td style="text-align:left;">
10002
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
12 Clock Point
</td>
<td style="text-align:left;">
Tree (Standing Only)
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
2014
</td>
</tr>
</tbody>
</table>

The `codebook` tibble provides a searchable codebook for the data,
useful if you know what concept you’re looking for but not the variable
that describes it. `rfars` also includes pre-loaded codebooks for FARS
and GESCRSS (`rfars::fars_codebook` and `rfars::gescrss_codebook`). See
`vignette('Searchable Codebooks', package = 'rfars')` for more
information.

## Counts

See `vignette("Counts", package = "rfars")` for information on the
pre-loaded `annual_counts` dataframe and the `counts()` function. Also
see `vignette("Alcohol Counts", package = "rfars")` for details on how
BAC values are imputed and reported in *Traffic Safety Facts*.

## Helpful Links

- [National Highway Traffic Safety Administration
  (NHTSA)](https://www.nhtsa.gov/)
- [Fatality Analysis Reporting System
  (FARS)](https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars)
- [Fatality and Injury Reporting System Tool
  (FIRST)](https://cdan.dot.gov/query)
- [FARS Analytical User’s
  Manual](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813706)
- [General Estimates System
  (GES)](https://www.nhtsa.gov/national-automotive-sampling-system/nass-general-estimates-system)
- [Crash Report Sampling System
  (CRSS)](https://www.nhtsa.gov/crash-data-systems/crash-report-sampling-system)
- [CRSS Analytical User’s
  Manual](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813707)
- [NCSA and Other Data
  Sources](https://cdan.dot.gov/Homepage/MotorVehicleCrashDataOverview.htm)
- [NHTSA FTP
  Site](https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/)
