
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
myFARS <- get_fars(years = 2023, states = "VA", proceed = TRUE)
#> ✓ 2023 data downloaded
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
#> ✓ Prepared files saved in C:/Users/STEVEJ~1/AppData/Local/Temp/Rtmp86XeJ3/FARS data/prepd/2023
#> ✓ Codebook file saved in C:/Users/STEVEJ~1/AppData/Local/Temp/Rtmp86XeJ3/FARS data/prepd/
```

We could have saved that file locally with:

``` r
myFARS <- get_fars(years=2023, states = "VA", proceed = TRUE, dir = getwd(), cache = "myFARS.rds")
```

Note that you can assign and save this data with one function call.

We could similarly get one year of CRSS data for the south (MD, DE, DC,
WV, VA, KY, TN, NC, SC, GA, FL, AL, MS, LA, AR, OK, TX):

``` r
myCRSS <- get_gescrss(years = 2023, regions = "s", proceed = TRUE)
myCRSS <- get_gescrss(years = 2023, regions = "s", proceed = TRUE, dir = getwd(), cache = "myCRSS.rds")
```

The data returned by `get_fars()` and `get_gescrss()` adhere to the same
structure: a list with six tibbles: `flat`, `multi_acc`, `multi_veh`,
`multi_per`, `events`, and `codebook`. FARS and GES/CRSS share many but
not all data elements. See the [FARS Analytical User’s
Manual](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813706)
and [CRSS Analytical User’s
Manual](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813707)
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
#> Rows: 1,789
#> Columns: 196
#> $ year          <dbl> 2023, 2023, 2023, 2023, 2023, 2023, 2023, 2023, 2023, 2023, 2023, 2023, 2023…
#> $ state         <chr> "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Vir…
#> $ st_case       <dbl> 510001, 510001, 510002, 510002, 510003, 510003, 510003, 510003, 510004, 5100…
#> $ id            <dbl> 2023510001, 2023510001, 2023510002, 2023510002, 2023510003, 2023510003, 2023…
#> $ veh_no        <dbl> 0, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 2, 3, 1, 1, 1, 2, 2, 2, 2, 2, 1, 2, 1, 2…
#> $ per_no        <dbl> 1, 1, 1, 1, 1, 2, 3, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 3, 4, 5, 1, 1, 1, 1…
#> $ county        <dbl> 810, 810, 1, 1, 125, 125, 125, 125, 33, 710, 770, 199, 199, 199, 87, 87, 53,…
#> $ city          <dbl> 2540, 2540, 0, 0, 0, 0, 0, 0, 0, 1760, 2100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ lon           <dbl> -76.03962, -76.03962, -75.55837, -75.55837, -78.93293, -78.93293, -78.93293,…
#> $ lat           <dbl> 36.63201, 36.63201, 37.87557, 37.87557, 37.70849, 37.70849, 37.70849, 37.708…
#> $ acc_config    <dbl> NA, 103, 401, 402, 502, 502, 502, 501, 102, 101, 998, 504, 503, 998, 102, 10…
#> $ age           <chr> "41 Years", "32 Years", "39 Years", "61 Years", "37 Years", "25 Years", "31 …
#> $ air_bag       <chr> "Not a Motor Vehicle Occupant", "Not Deployed", "Deployed- Combination", "No…
#> $ alc_res       <chr> "0.303 % BAC", "Test Not Given", "Test Not Given", "0.000 % BAC", "Test Not …
#> $ alc_status    <chr> "Test Given", "Test Not Given", "Test Not Given", "Test Given", "Test Not Gi…
#> $ arr_hour      <chr> "Unknown EMS Scene Arrival Hour", "Unknown EMS Scene Arrival Hour", "Unknown…
#> $ arr_min       <chr> "Unknown if Arrived", "Unknown if Arrived", "Unknown EMS Scene Arrival Minut…
#> $ atst_typ      <chr> "Vitreous", "Test Not Given", "Test Not Given", "Vitreous", "Test Not Given"…
#> $ bikecgp       <chr> "Not a Cyclist", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ bikectype     <chr> "Not a Cyclist", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ bikedir       <chr> "Not a Cyclist", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ bikeloc       <chr> "Not a Cyclist", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ bikepos       <chr> "Not a Cyclist", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ body_typ      <chr> NA, "Medium/heavy Pickup (GVWR greater than 10,000 lbs.)", "Minivan (Chrysle…
#> $ bus_use       <chr> NA, "Not a Bus", "Not a Bus", "Not a Bus", "Not a Bus", "Not a Bus", "Not a …
#> $ cargo_bt      <chr> NA, "Van/Enclosed Box", "Not Applicable (N/A)", "Not Applicable (N/A)", "Not…
#> $ cdl_stat      <chr> NA, "No (CDL)", "No (CDL)", "No (CDL)", "No (CDL)", "No (CDL)", "No (CDL)", …
#> $ cityname      <chr> "VIRGINIA BEACH", "VIRGINIA BEACH", "NOT APPLICABLE", "NOT APPLICABLE", "NOT…
#> $ countyname    <chr> "VIRGINIA BEACH (CITY) (810)", "VIRGINIA BEACH (CITY) (810)", "ACCOMACK (1)"…
#> $ day           <dbl> 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 5, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 7, 7…
#> $ day_week      <chr> "Sunday", "Sunday", "Sunday", "Sunday", "Monday", "Monday", "Monday", "Monda…
#> $ death_da      <chr> "1", "Not Applicable (Non-Fatal)", "Not Applicable (Non-Fatal)", "1", "Not A…
#> $ death_hr      <chr> "18:00-18:59", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "…
#> $ death_mn      <chr> "10", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "0", "Not …
#> $ death_mo      <chr> "January", "Not Applicable (Non-Fatal)", "Not Applicable (Non-Fatal)", "Janu…
#> $ death_tm      <chr> "1810", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "1700", …
#> $ death_yr      <chr> "2023", "Not Applicable (Non-fatal)", "Not Applicable (Non-fatal)", "2023", …
#> $ deaths        <dbl> NA, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, …
#> $ deformed      <chr> NA, "Not Reported", "Disabling Damage", "Disabling Damage", "Disabling Damag…
#> $ devmotor      <dbl> 0, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ devtype       <dbl> 0, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ doa           <chr> "Died at Scene", "Not Applicable", "Not Applicable", "Died at Scene", "Not A…
#> $ dr_drink      <chr> NA, "No", "No", "No", "No", "No", "No", "No", "Yes", "No", "Yes", "No", "No"…
#> $ dr_hgt        <chr> NA, "70", "63", "69", "59", "59", "59", "65", "72", "74", "72", "67", "72", …
#> $ dr_pres       <chr> NA, "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Y…
#> $ dr_wgt        <chr> NA, "170 lbs.", "170 lbs.", "180 lbs.", "115 lbs.", "115 lbs.", "115 lbs.", …
#> $ dr_zip        <chr> NA, "23457", "23421", "23308", "24554", "24554", "24554", "24572", "20746", …
#> $ drinking      <chr> "Yes (Alcohol Involved)", "No (Alcohol Not Involved)", "No (Alcohol Not Invo…
#> $ drugs         <chr> "Reported as Unknown", "No (drugs not involved)", "No (drugs not involved)",…
#> $ dstatus       <chr> "Test Given", "Test Not Given", "Test Not Given", "Test Given", "Test Not Gi…
#> $ ej_path       <chr> "Ejection Path Not Applicable", "Ejection Path Not Applicable", "Ejection Pa…
#> $ ejection      <chr> "Not Applicable", "Not Ejected", "Not Ejected", "Not Applicable", "Not Eject…
#> $ emer_use      <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ extricat      <chr> "Not Extricated or Not Applicable", "Not Extricated or Not Applicable", "Not…
#> $ fatals        <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ fire_exp      <chr> NA, "No or Not Reported", "No or Not Reported", "Yes", "No or Not Reported",…
#> $ first_mo      <chr> NA, "No Record", "No Record", "No Record", "March", "March", "March", "Septe…
#> $ first_yr      <chr> NA, "No Record", "No Record", "No Record", "2019", "2019", "2019", "2018", "…
#> $ func_sys      <chr> "Major Collector", "Major Collector", "Principal Arterial - Other", "Princip…
#> $ gvwr_from     <chr> NA, "Class 3: 10,001 - 14,000 lbs. (4,536 - 6,350 kg)", "Class 2: 6,001 - 10…
#> $ gvwr_to       <chr> NA, "Class 3: 10,001 - 14,000 lbs. (4,536 - 6,350 kg)", "Class 2: 6,001 - 10…
#> $ harm_ev       <chr> "Pedestrian", "Pedestrian", "Motor Vehicle In-Transport", "Motor Vehicle In-…
#> $ haz_cno       <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ haz_id        <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ haz_inv       <chr> NA, "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", …
#> $ haz_plac      <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ haz_rel       <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ helm_mis      <chr> "Not a Motor Vehicle Occupant", "None Used/Not Applicable", "None Used/Not A…
#> $ helm_use      <chr> "Not a Motor Vehicle Occupant", "Not Applicable", "Not Applicable", "Helmet,…
#> $ hispanic      <chr> "Non-Hispanic", "Not A Fatality (not Applicable)", "Not A Fatality (not Appl…
#> $ hit_run       <chr> NA, "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", …
#> $ hosp_hr       <chr> "Not Applicable (Not Transported)", "Not Applicable (Not Transported)", "Unk…
#> $ hosp_mn       <chr> "Not Applicable (Not Transported)", "Not Applicable (Not Transported)", "Unk…
#> $ hospital      <chr> "Not Transported for Treatment", "Not Transported for Treatment", "EMS Unkno…
#> $ hour          <chr> "6:00pm-6:59pm", "6:00pm-6:59pm", "4:00pm-4:59pm", "4:00pm-4:59pm", "9:00pm-…
#> $ icfinalbody   <chr> NA, "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", …
#> $ impact1       <chr> NA, "12 Clock Point", "1 Clock Point", "12 Clock Point", "3 Clock Point", "3…
#> $ inj_sev       <chr> "Fatal Injury (K)", "No Apparent Injury (O)", "Possible Injury (C)", "Fatal …
#> $ j_knife       <chr> NA, "No", "Not an Articulated Vehicle", "Not an Articulated Vehicle", "Not a…
#> $ l_compl       <chr> NA, "Valid license for this class vehicle", "No valid license for this class…
#> $ l_endors      <chr> NA, "No Endorsements required for this vehicle", "No Endorsements required f…
#> $ l_restri      <chr> NA, "Restrictions, Compliance Unknown", "No Restrictions or Not Applicable",…
#> $ l_state       <chr> NA, "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", …
#> $ l_status      <chr> NA, "Valid", "Suspended", "Valid", "Suspended", "Suspended", "Suspended", "V…
#> $ l_type        <chr> NA, "Full Driver License", "Full Driver License", "Full Driver License", "Fu…
#> $ lag_hrs       <chr> "0", "Unknown", "Unknown", "0", "Unknown", "0", "Unknown", "Unknown", "0", "…
#> $ lag_mins      <chr> "10", "Unknown", "Unknown", "6", "Unknown", "20", "Unknown", "Unknown", "0",…
#> $ last_mo       <chr> NA, "No Record", "No Record", "No Record", "March", "March", "March", "Septe…
#> $ last_yr       <chr> NA, "No Record", "No Record", "No Record", "2021", "2021", "2021", "2018", "…
#> $ lgt_cond      <chr> "Dark - Lighted", "Dark - Lighted", "Daylight", "Daylight", "Dark - Not Ligh…
#> $ location      <chr> "Not at Intersection - On Roadway, Not in Marked Crosswalk", "Occupant of a …
#> $ m_harm        <chr> NA, "Pedestrian", "Motor Vehicle In-Transport", "Motor Vehicle In-Transport"…
#> $ mak_mod       <chr> NA, "Chevrolet Medium/Heavy Pickup (pickup-style only - over 10,000 lbs)", "…
#> $ make          <chr> NA, "Chevrolet", "Honda", "Honda", "Chevrolet", "Chevrolet", "Chevrolet", "C…
#> $ man_coll      <chr> "The First Harmful Event was Not a Collision with a Motor Vehicle in Transpo…
#> $ mcarr_i1      <chr> NA, "US DOT", "Not Applicable", "Not Applicable", "Not Applicable", "Not App…
#> $ mcarr_i2      <chr> NA, "03036659", "Not Applicable", "Not Applicable", "Not Applicable", "Not A…
#> $ mcarr_id      <chr> NA, "5703036659", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ milept        <chr> "67", "67", "1337", "1337", "1016", "1016", "1016", "1016", "1170", "4036", …
#> $ minute        <dbl> 0, 0, 54, 54, 32, 32, 32, 32, 1, 21, 17, 22, 22, 22, 33, 33, 40, 40, 40, 40,…
#> $ mod_year      <chr> NA, "2015", "2008", "1997", "2005", "2005", "2005", "2016", "2017", "2020", …
#> $ model         <dbl> NA, 880, 441, 706, 2, 2, 2, 29, 40, 56, 403, 17, 481, 32, 16, 16, 404, 35, 3…
#> $ month         <chr> "January", "January", "January", "January", "January", "January", "January",…
#> $ motdir        <chr> "Not Applicable", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ motman        <chr> "Not Applicable", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ nhs           <chr> "This section IS NOT on the NHS", "This section IS NOT on the NHS", "This se…
#> $ nmhelmet      <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmlight       <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmothpre      <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmothpro      <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmpropad      <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ nmrefclo      <chr> "Not Reported", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ not_hour      <chr> "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "Unknown",…
#> $ not_min       <chr> "Unknown if Notified", "Unknown if Notified", "Unknown", "Unknown", "Unknown…
#> $ numoccs       <chr> NA, "01", "01", "01", "03", "03", "03", "01", "01", "01", "01", "01", "01", …
#> $ owner         <chr> NA, "Driver (in this crash) was  Registered Owner", "Driver (in this crash) …
#> $ p_crash1      <chr> NA, "Going Straight", "Turning Left", "Going Straight", "Going Straight", "G…
#> $ p_crash2      <chr> NA, "Pedestrian in road", "Turning Left", "From opposite direction  over lef…
#> $ p_crash3      <chr> NA, "Unknown/Not Reported", "Unknown/Not Reported", "Unknown/Not Reported", …
#> $ pbcwalk       <chr> "None Noted", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ pbswalk       <chr> "None Noted", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ pbszone       <chr> "None Noted", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ pcrash4       <chr> NA, "Tracking", "Tracking", "Tracking", "Tracking", "Tracking", "Tracking", …
#> $ pcrash5       <chr> NA, "Stayed in original travel lane", "Stayed in original travel lane", "Sta…
#> $ pedcgp        <chr> "Walking/Running Along Roadway", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ pedctype      <chr> "Walking/Running Along Roadway Against Traffic - From Front", NA, NA, NA, NA…
#> $ peddir        <chr> "Not Applicable", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ pedleg        <chr> "Not Applicable", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ pedloc        <chr> "Not At Intersection", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ pedpos        <chr> "Travel Lane", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ peds          <dbl> 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ pedsnr        <chr> "Not Applicable", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ per_typ       <chr> "Pedestrian", "Driver of a Motor Vehicle In-Transport", "Driver of a Motor V…
#> $ permvit       <dbl> 1, 1, 2, 2, 4, 4, 4, 4, 1, 1, 1, 3, 3, 3, 2, 2, 6, 6, 6, 6, 6, 6, 2, 2, 2, 2…
#> $ pernotmvit    <dbl> 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ persons       <dbl> 1, 1, 2, 2, 4, 4, 4, 4, 1, 1, 1, 3, 3, 3, 2, 2, 6, 6, 6, 6, 6, 6, 2, 2, 2, 2…
#> $ prev_acc      <chr> NA, "None", "None", "None", "None", "None", "None", "None", "None", "None", …
#> $ prev_dwi      <chr> NA, "None", "None", "None", "None", "None", "None", "None", "None", "None", …
#> $ prev_oth      <chr> NA, "None", "None", "None", "1", "1", "1", "None", "1", "None", "None", "Non…
#> $ prev_spd      <chr> NA, "None", "None", "None", "1", "1", "1", "1", "None", "None", "1", "None",…
#> $ prev_sus1     <chr> NA, "None", "None", "None", "None", "None", "None", "None", "None", "None", …
#> $ prev_sus2     <chr> NA, "None", "None", "None", "None", "None", "None", "None", "None", "None", …
#> $ prev_sus3     <chr> NA, "None", "None", "None", "1", "1", "1", "None", "None", "None", "1", "Non…
#> $ pvh_invl      <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ rail          <chr> "Not Applicable", "Not Applicable", "Not Applicable", "Not Applicable", "Not…
#> $ rd_owner      <chr> "City or Municipal Highway Agency", "City or Municipal Highway Agency", "Sta…
#> $ reg_stat      <chr> NA, "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", …
#> $ rel_road      <chr> "On Roadway", "On Roadway", "On Roadway", "On Roadway", "On Roadway", "On Ro…
#> $ reljct1       <chr> "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No"…
#> $ reljct2       <chr> "Non-Junction", "Non-Junction", "Intersection", "Intersection", "Intersectio…
#> $ rest_mis      <chr> "Not a Motor Vehicle Occupant", "None Used/Not Applicable", "No Indication o…
#> $ rest_use      <chr> "Not a Motor Vehicle Occupant", "None Used/Not Applicable", "Shoulder and La…
#> $ rolinloc      <chr> NA, "No Rollover", "No Rollover", "8", "No Rollover", "No Rollover", "No Rol…
#> $ rollover      <chr> NA, "No Rollover", "No Rollover", "8", "No Rollover", "No Rollover", "No Rol…
#> $ route         <chr> "Local Street - Municipality", "Local Street - Municipality", "U.S. Highway"…
#> $ rur_urb       <chr> "Urban", "Urban", "Rural", "Rural", "Rural", "Rural", "Rural", "Rural", "Rur…
#> $ sch_bus       <chr> "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No"…
#> $ seat_pos      <chr> "Not a Motor Vehicle Occupant", "Front Seat, Left Side", "Front Seat, Left S…
#> $ sex           <chr> "Male", "Male", "Male", "Male", "Female", "Female", "Male", "Female", "Male"…
#> $ sp_jur        <chr> "No Special Jurisdiction", "No Special Jurisdiction", "No Special Jurisdicti…
#> $ spec_use      <chr> NA, "No Special Use", "No Special Use", "No Special Use", "No Special Use", …
#> $ speedrel      <chr> NA, "No", "No", "No", "No", "No", "No", "No", "No", "No", "Yes, Exceeded Spe…
#> $ statename     <chr> "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Virginia", "Vir…
#> $ str_veh       <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ tow_veh       <chr> NA, "One Trailing Unit", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ towed         <chr> NA, "Not Reported", "6", "6", "6", "6", "6", "6", "6", "6", "6", "6", "6", "…
#> $ trav_sp       <chr> NA, "050 MPH", "015 MPH", "055 MPH", "025 MPH", "025 MPH", "025 MPH", "060 M…
#> $ trlr1gvwr     <chr> NA, "Not Reported", "No Trailing Units", "No Trailing Units", "No Trailing U…
#> $ trlr1vin      <chr> NA, "Not Reported", "No Trailing Units", "No Trailing Units", "No Trailing U…
#> $ trlr2gvwr     <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ trlr2vin      <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ trlr3gvwr     <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ trlr3vin      <chr> NA, "No Trailing Units", "No Trailing Units", "No Trailing Units", "No Trail…
#> $ tway_id       <chr> "MU-8669 PRINCESS ANNE RD", "MU-8669 PRINCESS ANNE RD", "US-13", "US-13", "U…
#> $ tway_id2      <chr> NA, NA, "CHESSER RD", "CHESSER RD", "RT-655", "RT-655", "RT-655", "RT-655", …
#> $ typ_int       <chr> "Not an Intersection", "Not an Intersection", "T-Intersection", "T-Intersect…
#> $ underoverride <dbl> NA, 7, 7, 7, 0, 0, 0, 0, 7, 7, 0, 0, 0, 0, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
#> $ unittype      <chr> NA, "Motor Vehicle In-Transport (Inside or Outside the Trafficway)", "Motor …
#> $ v_config      <chr> NA, "Truck Pulling Trailer(s)", "Not Applicable", "Not Applicable", "Not App…
#> $ valign        <chr> NA, "Straight", "Straight", "Straight", "Not Reported", "Not Reported", "Not…
#> $ ve_forms      <dbl> 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 1, 3, 3, 3, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2…
#> $ ve_total      <dbl> 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 2, 3, 3, 3, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2…
#> $ vin           <chr> NA, "1GC5KZC88FZ1", "5FNRL387X8B0", "1HFSC2231VA9", "2G1WF52E3591", "2G1WF52…
#> $ vnum_lan      <chr> NA, "Two lanes", "Three lanes", "Two lanes", "Two lanes", "Two lanes", "Two …
#> $ vpavetyp      <chr> NA, "Blacktop, Bituminous, or Asphalt", "Blacktop, Bituminous, or Asphalt", …
#> $ vpicbodyclass <chr> NA, "Pickup", "Minivan", "Motorcycle - Street", "Sedan/Saloon", "Sedan/Saloo…
#> $ vpicmake      <chr> NA, "Chevrolet", "Honda", "Honda", "Chevrolet", "Chevrolet", "Chevrolet", "C…
#> $ vpicmodel     <chr> NA, "Silverado", "Odyssey", "GL1500SE (GOLD WING SE)", "Impala", "Impala", "…
#> $ vprofile      <chr> NA, "Level", "Level", "Level", "Not Reported", "Not Reported", "Not Reported…
#> $ vspd_lim      <chr> NA, "45 MPH", "55 MPH", "55 MPH", "60 MPH", "60 MPH", "60 MPH", "60 MPH", "6…
#> $ vsurcond      <chr> NA, "Dry", "Dry", "Dry", "Dry", "Dry", "Dry", "Dry", "Dry", "Dry", "Dry", "N…
#> $ vtcont_f      <chr> NA, "No Controls", "No Controls", "No Controls", "Device Functioning Properl…
#> $ vtrafcon      <chr> NA, "No Controls", "No Controls", "No Controls", "Yield Sign", "Yield Sign",…
#> $ vtrafway      <chr> NA, "Two-Way, Not Divided", "Two-Way, Divided, Unprotected Median", "Two-Way…
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
91
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
19
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
17
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
9
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
8
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
3
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
2
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
2
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
1
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
1198
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
1113
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
1002
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
955
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
813
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
811
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
633
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
625
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
581
</td>
</tr>
<tr>
<td style="text-align:left;">
drimpair
</td>
<td style="text-align:left;">
Reported as Unknown if Impaired
</td>
<td style="text-align:right;">
516
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
drugactqty
</td>
<td style="text-align:left;">
-99
</td>
<td style="text-align:right;">
1883
</td>
</tr>
<tr>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
-9
</td>
<td style="text-align:right;">
1883
</td>
</tr>
<tr>
<td style="text-align:left;">
order
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:right;">
1789
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
1788
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
1252
</td>
</tr>
<tr>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:right;">
955
</td>
</tr>
<tr>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:right;">
955
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
955
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
955
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
876
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
Pedestrian
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2023
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
1 Clock Point
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2023
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
12 Clock Point
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2023
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
Non-Collision
</td>
<td style="text-align:left;">
Fire/Explosion
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2023
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
3 Clock Point
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2023
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
Ran Off Roadway - Left
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2023
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
12 Clock Point
</td>
<td style="text-align:left;">
Traffic Sign Support
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
2023
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
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2023
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
Ran Off Roadway - Left
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2023
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
1 Clock Point
</td>
<td style="text-align:left;">
Guardrail Face
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2023
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
