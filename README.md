
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rfars

<!-- badges: start -->
<!-- badges: end -->

The goal of rfars is to simplify the process of analyzing FARS data. The
[Fatality and Injury Reporting System Tool](https://cdan.dot.gov/query)
allows users to generate queries, and can produce simple tables and
graphs. This suffices for simple analysis, but often leaves researchers
wanting more. Digging any deeper, however, involves a time-consuming
process of downloading annual ZIP files and attempting to stitch them
together - after first combing through the immense [data
dictionary](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813254)
to determine the required variables and table names. `rfars`allows users
to download five years of FARS data with just two lines of code. The
result is a full, rich dataset ready for mapping, modeling, and other
downstream analysis. Helper functions are also provided to produce
common counts and comparisons. A companion package `rfarsplus`provides
exposure data and facilitates the calculation of various rates.

## Installation

You can install the latest version of `rfars`from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("s87jackson/rfars")
```

``` r
library(rfars)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(ggplot2)
library(leaflet)
library(leaflet.extras)
```

## Getting and Using FARS Data

Use the `get_fars()` function to download the ZIP files from NHTSA and
save the prepared files to your hard drive. This only has to be run once
and defaults to saving everything in the current working directory.
Below we import 5 years of data for Virginia. Note that `get_fars()`
requires your permission to download the ZIP files and store prepared
CSVs locally.

``` r
get_fars(years = 2015:2020, states="Virginia")
```

The `use_fars()` function looks in that directory for certain files and
compiles them into a list of four data frames: `flat`, `multi_acc`,
`multi_veh`, and `multi_per`. The `flat` file contains all variables for
which there is just one value per person, vehicle, or crash (e.g., age,
travel speed, lighting). Each row in this table corresponds to a person
involved in a crash. As there may be multiple people and/or vehicles
involved in one crash, some variable-values are repeated within a crash
or vehicle. Each crash is uniquely identified with `id`, which is a
combination of `year` and `st_case`. Note that `st_case` is not unique
across years, for example, `st_case` 510001 will appear in each year.
The `id` variable attempts to avoid this issue.

The `multi_` files contain those variables for which there may be
multiple values for any entity (e.g., driver impairments, vehicle
events, weather conditions at time of crash). Each table has the
requisite data elements corresponding to the entity: `multi_acc`
includes `st_case` and `year`, `multi_veh` adds `veh_no` (vehicle
number), and `multi_per` adds `per_no` (person number).

``` r
myFARS <- use_fars("FARS data", years = 2015:2020) 
#> 
#> ── Column specification ────────────────────────────────────────────────────────
#> cols(
#>   .default = col_character(),
#>   year = col_double(),
#>   st_case = col_double(),
#>   id = col_double(),
#>   veh_no = col_double(),
#>   per_no = col_double(),
#>   county = col_double(),
#>   city = col_double(),
#>   ve_total = col_double(),
#>   ve_forms = col_double(),
#>   pvh_invl = col_double(),
#>   peds = col_double(),
#>   pernotmvit = col_double(),
#>   permvit = col_double(),
#>   persons = col_double(),
#>   day = col_double(),
#>   minute = col_double(),
#>   fatals = col_double(),
#>   drunk_dr = col_double(),
#>   str_veh = col_double(),
#>   model = col_double()
#>   # ... with 1 more columns
#> )
#> ℹ Use `spec()` for the full column specifications.

str(myFARS)
#> List of 4
#>  $ flat     : tibble [10,150 × 199] (S3: tbl_df/tbl/data.frame)
#>   ..$ year         : num [1:10150] 2015 2015 2015 2015 2015 ...
#>   ..$ state        : chr [1:10150] "Virginia" "Virginia" "Virginia" "Virginia" ...
#>   ..$ st_case      : num [1:10150] 510001 510002 510002 510003 510004 ...
#>   ..$ id           : num [1:10150] 2.02e+09 2.02e+09 2.02e+09 2.02e+09 2.02e+09 ...
#>   ..$ veh_no       : num [1:10150] 1 0 1 1 1 2 2 1 1 1 ...
#>   ..$ per_no       : num [1:10150] 1 1 1 1 1 1 2 1 1 2 ...
#>   ..$ county       : num [1:10150] 143 840 840 185 143 143 143 25 37 37 ...
#>   ..$ city         : num [1:10150] 0 2640 2640 0 0 0 0 0 0 0 ...
#>   ..$ lon          : num [1:10150] -79.2 -78.2 -78.2 -81.8 -79.3 ...
#>   ..$ lat          : num [1:10150] 37 39.2 39.2 37 37.1 ...
#>   ..$ ve_total     : num [1:10150] 1 1 1 1 2 2 2 1 1 1 ...
#>   ..$ ve_forms     : num [1:10150] 1 1 1 1 2 2 2 1 1 1 ...
#>   ..$ pvh_invl     : num [1:10150] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ peds         : num [1:10150] 0 1 1 0 0 0 0 0 0 0 ...
#>   ..$ pernotmvit   : num [1:10150] 0 1 1 0 0 0 0 0 0 0 ...
#>   ..$ permvit      : num [1:10150] 1 1 1 1 3 3 3 1 2 2 ...
#>   ..$ persons      : num [1:10150] 1 1 1 1 3 3 3 1 2 2 ...
#>   ..$ day          : num [1:10150] 1 2 2 2 4 4 4 3 6 6 ...
#>   ..$ month        : chr [1:10150] "January" "January" "January" "January" ...
#>   ..$ day_week     : chr [1:10150] "Thursday" "Friday" "Friday" "Friday" ...
#>   ..$ hour         : chr [1:10150] "3:00pm-3:59pm" "6:00pm-6:59pm" "6:00pm-6:59pm" "1:00pm-1:59pm" ...
#>   ..$ minute       : num [1:10150] 30 59 59 55 15 15 15 58 19 19 ...
#>   ..$ nhs          : chr [1:10150] "This section IS NOT on the NHS" "This section IS NOT on the NHS" "This section IS NOT on the NHS" "This section IS NOT on the NHS" ...
#>   ..$ rur_urb      : chr [1:10150] "Rural" "Urban" "Urban" "Rural" ...
#>   ..$ func_sys     : chr [1:10150] "Major Collector" "Local" "Local" "Major Collector" ...
#>   ..$ rd_owner     : chr [1:10150] "State Highway Agency" "Not Reported" "Not Reported" "State Highway Agency" ...
#>   ..$ route        : chr [1:10150] "County Road" "Unknown" "Unknown" "County Road" ...
#>   ..$ tway_id      : chr [1:10150] "CR-668" "HANDLEY BLVD" "HANDLEY BLVD" "CR-609" ...
#>   ..$ tway_id2     : chr [1:10150] NA "S STEWARD ST" "S STEWARD ST" NA ...
#>   ..$ milept       : chr [1:10150] "68" "None" "None" "87" ...
#>   ..$ sp_jur       : chr [1:10150] "No Special Jurisdiction" "No Special Jurisdiction" "No Special Jurisdiction" "No Special Jurisdiction" ...
#>   ..$ harm_ev      : chr [1:10150] "Other Post, Other Pole or Other Supports" "Pedalcyclist" "Pedalcyclist" "Rollover/Overturn" ...
#>   ..$ man_coll     : chr [1:10150] "Not a Collision with Motor Vehicle In-Transport" "Not a Collision with Motor Vehicle In-Transport" "Not a Collision with Motor Vehicle In-Transport" "Not a Collision with Motor Vehicle In-Transport" ...
#>   ..$ reljct1      : chr [1:10150] "No" "No" "No" "No" ...
#>   ..$ reljct2      : chr [1:10150] "Non-Junction" "Intersection" "Intersection" "Non-Junction" ...
#>   ..$ typ_int      : chr [1:10150] "Not an Intersection" "T-Intersection" "T-Intersection" "Not an Intersection" ...
#>   ..$ wrk_zone     : chr [1:10150] "None" "None" "None" "None" ...
#>   ..$ rel_road     : chr [1:10150] "On Roadside" "On Roadway" "On Roadway" "Outside Trafficway" ...
#>   ..$ lgt_cond     : chr [1:10150] "Daylight" "Dark - Lighted" "Dark - Lighted" "Daylight" ...
#>   ..$ sch_bus      : chr [1:10150] "No" "No" "No" "No" ...
#>   ..$ rail         : chr [1:10150] "Not Applicable" "Not Applicable" "Not Applicable" "Not Applicable" ...
#>   ..$ not_hour     : chr [1:10150] "Unknown" "7:00pm-7:59pm" "7:00pm-7:59pm" "1:00pm-1:59pm" ...
#>   ..$ not_min      : chr [1:10150] "Unknown" "0" "0" "59" ...
#>   ..$ arr_hour     : chr [1:10150] "Unknown EMS Scene Arrival Hour" "7:00pm-7:59pm" "7:00pm-7:59pm" "2:00pm-2:59pm" ...
#>   ..$ arr_min      : chr [1:10150] "Unknown EMS Scene Arrival Minutes" "5" "5" "8" ...
#>   ..$ hosp_hr      : chr [1:10150] "Unknown" "7:00pm-7:59pm" "7:00pm-7:59pm" "2:00pm-2:59pm" ...
#>   ..$ hosp_mn      : chr [1:10150] "Unknown EMS Hospital Arrival Time" "20" "20" "36" ...
#>   ..$ fatals       : num [1:10150] 1 1 1 1 1 1 1 1 1 1 ...
#>   ..$ drunk_dr     : num [1:10150] 1 0 0 0 1 1 1 0 0 0 ...
#>   ..$ str_veh      : num [1:10150] 0 1 0 0 0 0 0 0 0 0 ...
#>   ..$ age          : chr [1:10150] "70 Years" "59 Years" "68 Years" "62 Years" ...
#>   ..$ sex          : chr [1:10150] "Male" "Female" "Female" "Female" ...
#>   ..$ per_typ      : chr [1:10150] "Driver of a Motor Vehicle In-Transport" "Bicyclist" "Driver of a Motor Vehicle In-Transport" "Driver of a Motor Vehicle In-Transport" ...
#>   ..$ inj_sev      : chr [1:10150] "Fatal Injury (K)" "Fatal Injury (K)" "No Apparent Injury (O)" "Fatal Injury (K)" ...
#>   ..$ seat_pos     : chr [1:10150] "Front Seat, Left Side" "Not a Motor Vehicle Occupant" "Front Seat, Left Side" "Front Seat, Left Side" ...
#>   ..$ rest_use     : chr [1:10150] "None Used" "Not a Motor Vehicle Occupant" "Shoulder and Lap Belt Used" "Shoulder and Lap Belt Used" ...
#>   ..$ rest_mis     : chr [1:10150] "No" "Not a Motor Vehicle Occupant" "No" "No" ...
#>   ..$ air_bag      : chr [1:10150] "Deployed- Front" "Not a Motor Vehicle Occupant" "Not Deployed" "Not Deployed" ...
#>   ..$ ejection     : chr [1:10150] "Not Ejected" "Not Applicable" "Not Ejected" "Not Ejected" ...
#>   ..$ ej_path      : chr [1:10150] "Ejection Path Not Applicable" "Ejection Path Not Applicable" "Ejection Path Not Applicable" "Ejection Path Not Applicable" ...
#>   ..$ extricat     : chr [1:10150] "Not Extricated or Not Applicable" "Not Extricated or Not Applicable" "Not Extricated or Not Applicable" "Not Extricated or Not Applicable" ...
#>   ..$ drinking     : chr [1:10150] "No (Alcohol Not Involved)" "Unknown (Police Reported)" "No (Alcohol Not Involved)" "No (Alcohol Not Involved)" ...
#>   ..$ alc_det      : chr [1:10150] "Not Reported" "Not Reported" "Not Reported" "Not Reported" ...
#>   ..$ alc_status   : chr [1:10150] "Test Given" "Test Given" "Test Given" "Test Not Given" ...
#>   ..$ atst_typ     : chr [1:10150] "Blood" "Blood" "Blood" "Test Not Given" ...
#>   ..$ alc_res      : chr [1:10150] "0.105 % BAC" "0.000 % BAC" "0.000 % BAC" "Test Not Given" ...
#>   ..$ drugs        : chr [1:10150] "No (drugs not involved)" "Unknown" "No (drugs not involved)" "No (drugs not involved)" ...
#>   ..$ drug_det     : chr [1:10150] "Not Reported" "Not Reported" "Not Reported" "Not Reported" ...
#>   ..$ dstatus      : chr [1:10150] "Test Given" "Test Given" "Test Given" "Test Not Given" ...
#>   ..$ hospital     : chr [1:10150] "EMS Unknown Mode" "EMS Unknown Mode" "Not Transported" "EMS Unknown Mode" ...
#>   ..$ doa          : chr [1:10150] "Not Applicable" "Not Applicable" "Not Applicable" "Not Applicable" ...
#>   ..$ death_da     : chr [1:10150] "1" "2" "Not Applicable (Non-Fatal)" "5" ...
#>   ..$ death_mo     : chr [1:10150] "January" "January" "Not Applicable (Non-Fatal)" "January" ...
#>   ..$ death_yr     : chr [1:10150] "2015" "2015" "Not Applicable (Non-fatal)" "2015" ...
#>   ..$ death_hr     : chr [1:10150] "17:00-17:59" "19:00-19:59" "Not Applicable (Non-fatal)" "20:00-20:59" ...
#>   ..$ death_mn     : chr [1:10150] "51" "39" "Not Applicable (Non-fatal)" "15" ...
#>   ..$ death_tm     : chr [1:10150] "1751" "1939" "8888" "2015" ...
#>   ..$ lag_hrs      : chr [1:10150] "2" "0" "Unknown" "78" ...
#>   ..$ lag_mins     : chr [1:10150] "21" "40" "Unknown" "20" ...
#>   ..$ work_inj     : chr [1:10150] "No" "No" "Not Applicable (not a fatality)" "No" ...
#>   ..$ hispanic     : chr [1:10150] "Non-Hispanic" "Non-Hispanic" "Not A Fatality (not Applicable)" "Non-Hispanic" ...
#>   ..$ location     : chr [1:10150] "Occupant of a Motor Vehicle" "At Intersection - Not In Crosswalk" "Occupant of a Motor Vehicle" "Occupant of a Motor Vehicle" ...
#>   ..$ numoccs      : chr [1:10150] "01" NA "01" "01" ...
#>   ..$ unittype     : chr [1:10150] "Motor Vehicle In-Transport (Inside or Outside the Trafficway)" NA "Motor Vehicle In-Transport (Inside or Outside the Trafficway)" "Motor Vehicle In-Transport (Inside or Outside the Trafficway)" ...
#>   ..$ hit_run      : chr [1:10150] "No" NA "No" "No" ...
#>   ..$ reg_stat     : chr [1:10150] "Virginia" NA "Virginia" "Virginia" ...
#>   ..$ owner        : chr [1:10150] "Driver (in this crash) was  Registered Owner" NA "Driver (in this crash) was  Registered Owner" "Driver (in this crash) was  Registered Owner" ...
#>   ..$ make         : chr [1:10150] "Volvo" NA "Ford" "Chevrolet" ...
#>   ..$ model        : num [1:10150] 43 NA 401 16 38 39 39 481 404 404 ...
#>   ..$ mak_mod      : chr [1:10150] "Volvo 70 Series (For XC70 for 2014 on, use model code 402)" NA "Ford Bronco (thru 1977)/Bronco II/Explorer/Explorer Sport" "Chevrolet Cavalier" ...
#>   ..$ body_typ     : chr [1:10150] "Station Wagon (excluding van and truck based)" NA "Compact Utility (Utility Vehicle Categories \"Small\" and \"Midsize\")" "2-door sedan,hardtop,coupe" ...
#>   ..$ mod_year     : chr [1:10150] "2001" NA "2004" "1999" ...
#>   ..$ vin          : chr [1:10150] "YV1SZ58D1110" NA "1FMZU73W64ZA" "1G1JC1246X72" ...
#>   ..$ tow_veh      : chr [1:10150] "No Trailing Units" NA "No Trailing Units" "No Trailing Units" ...
#>   ..$ j_knife      : chr [1:10150] "Not an Articulated Vehicle" NA "Not an Articulated Vehicle" "Not an Articulated Vehicle" ...
#>   ..$ mcarr_i1     : chr [1:10150] "Not Applicable" NA "Not Applicable" "Not Applicable" ...
#>   ..$ mcarr_i2     : chr [1:10150] "Not Applicable" NA "Not Applicable" "Not Applicable" ...
#>   ..$ mcarr_id     : chr [1:10150] "Not Applicable" NA "Not Applicable" "Not Applicable" ...
#>   ..$ v_config     : chr [1:10150] "Not Applicable" NA "Not Applicable" "Not Applicable" ...
#>   .. [list output truncated]
#>  $ multi_acc:'data.frame':   736346 obs. of  5 variables:
#>   ..$ state  : chr [1:736346] "Alabama" "Alabama" "Alabama" "Alabama" ...
#>   ..$ st_case: num [1:736346] 10001 10001 10001 10001 10001 ...
#>   ..$ name   : chr [1:736346] "eventnum" "vnumber1" "aoi1" "soe" ...
#>   ..$ value  : chr [1:736346] "1" "1" "Non-Harmful Event" "Ran Off Roadway - Right" ...
#>   ..$ year   : num [1:736346] NA NA NA NA NA NA NA NA NA NA ...
#>  $ multi_veh:'data.frame':   697788 obs. of  6 variables:
#>   ..$ state  : chr [1:697788] "Alabama" "Alabama" "Alabama" "Alabama" ...
#>   ..$ st_case: num [1:697788] 10001 10002 10003 10004 10005 ...
#>   ..$ veh_no : num [1:697788] 1 1 1 1 1 2 1 1 1 1 ...
#>   ..$ name   : chr [1:697788] "vehiclesf" "vehiclesf" "vehiclesf" "vehiclesf" ...
#>   ..$ value  : chr [1:697788] "None" "None" "None" "None" ...
#>   ..$ year   : num [1:697788] NA NA NA NA NA NA NA NA NA NA ...
#>  $ multi_per:'data.frame':   478029 obs. of  7 variables:
#>   ..$ state  : chr [1:478029] "Alabama" "Alabama" "Alabama" "Alabama" ...
#>   ..$ st_case: num [1:478029] 10001 10002 10003 10003 10004 ...
#>   ..$ veh_no : num [1:478029] 1 1 1 1 1 1 2 1 1 1 ...
#>   ..$ per_no : num [1:478029] 1 1 1 2 1 1 1 1 2 1 ...
#>   ..$ name   : chr [1:478029] "race" "race" "race" "race" ...
#>   ..$ value  : chr [1:478029] "White" "White" "Black" "Not a Fatality (not Applicable)" ...
#>   ..$ year   : num [1:478029] NA NA NA NA NA NA NA NA NA NA ...
#>  - attr(*, "class")= chr [1:2] "list" "FARS"
```

You can review the list of variables to help guide your analysis with:

``` r
View(fars_varnames)
```

## Counts

A first step in many transportation analyses involves counting the
number of relevant crashes, fatalities, or people involved. `counts()`
lets users specify a time period and aggregation interval, and focus in
on specific road users and factors. It can be combined with `ggplot()`
to quickly visualize counts.

``` r
counts(
  myFARS,
  what = "crashes",
  when = 2015:2020,
  interval = c("year")
  ) %>%
  ggplot(aes(x=date, y=n, label=scales::comma(n))) + 
    geom_col() + 
    geom_label(vjust=1.2) +
    labs(x=NULL, y=NULL, title = "Fatal Crashes in Virginia")
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

``` r
counts(
  myFARS,
  what = "fatalities",
  when = 2015:2020,
  interval = c("year")
  ) %>%
  ggplot(aes(x=date, y=n, label=scales::comma(n))) + 
    geom_col() + 
    geom_label(vjust=1.2) +
    labs(x=NULL, y=NULL, title = "Fatalities in Virginia")
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

``` r
counts(myFARS,
       what = "fatalities",
       when = 2015:2020,
       where = "rural",
       interval = c("year")
       ) %>%
  ggplot(aes(x=date, y=n, label=scales::comma(n))) + 
    geom_col() + 
    geom_label(vjust=1.2) +
    labs(x=NULL, y=NULL, title = "Rural Fatalities in Virginia")
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

``` r
counts(myFARS,
       what = "fatalities",
       when = 2015:2020,
       where = "rural",
       interval = c("year"),
       involved = "speeding"
       ) %>%
  ggplot(aes(x=date, y=n, label=scales::comma(n))) + 
    geom_col() + 
    geom_label(vjust=1.2) +
    labs(x=NULL, y=NULL, title = "Speeding-Related Fatalities\nin Rural Virginia")
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

We can combine two `counts()` results to make a comparison. Here we
compare the number of speeding-related fatalities in rural and urban
Virginia:

``` r
bind_rows(
  counts(myFARS,
       what = "fatalities",
       when = 2015:2020,
       where = "rural",
       interval = c("year"),
       involved = "speeding"
       ) %>%
    mutate(where = "Rural"),
  counts(myFARS,
       what = "fatalities",
       when = 2015:2020,
       where = "urban",
       interval = c("year"),
       involved = "speeding"
       ) %>%
    mutate(where = "Urban")
    ) %>%
  ggplot(aes(x=date, y=n, label=scales::comma(n))) + 
    geom_col() + 
    geom_label(vjust=1.2) +
    facet_wrap(.~where) +
    labs(x=NULL, y=NULL, title = "Speeding-Related Fatalities in Virginia", fill=NULL)
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

## Mapping

We can take advantage of having access to the full data with maps.

Here we map pedestrian and bicyclist fatalities in Virginia:

``` r
counts(
  myFARS, 
  what = "crashes", 
  when = 2015:2020, 
  involved = "pedbike", 
  filterOnly = TRUE
  ) %>%
leaflet() %>%
  addTiles() %>%
  addHeatmap(group = "Heatmap", radius=10, blur=20, minOpacity = .01, max = .2, cellSize = 1) %>%
  addCircleMarkers(
    radius = 1.5,
    color = "red",
    stroke = FALSE,
    fillOpacity = 0.7, group = "Crash Locations") 
#> Assuming "lon" and "lat" are longitude and latitude, respectively
#> Assuming "lon" and "lat" are longitude and latitude, respectively
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

Drug-related crashes:

``` r
counts(
  myFARS, 
  what = "crashes", 
  when = 2015:2020, 
  involved = "drugs", 
  filterOnly = TRUE
  ) %>%
  filter(!is.na(lat), !is.na(lon)) %>%
leaflet() %>%
  addTiles() %>%
  addHeatmap(group = "Heatmap", radius=10, blur=20, minOpacity = .01, max = .2, cellSize = 1) %>%
  addCircleMarkers(
    radius = 1.5,
    color = "red",
    stroke = FALSE,
    fillOpacity = 0.7, group = "Crash Locations") 
#> Assuming "lon" and "lat" are longitude and latitude, respectively
#> Assuming "lon" and "lat" are longitude and latitude, respectively
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="100%" />

Older driver crashes:

``` r
counts(
  myFARS, 
  what = "crashes", 
  when = 2015:2020, 
  involved = "older driver", 
  filterOnly = TRUE
  ) %>%
  filter(!is.na(lat), !is.na(lon)) %>%
leaflet() %>%
  addTiles() %>%
  addHeatmap(group = "Heatmap", radius=10, blur=20, minOpacity = .01, max = .2, cellSize = 1) %>%
  addCircleMarkers(
    radius = 1.5,
    color = "red",
    stroke = FALSE,
    fillOpacity = 0.7, group = "Crash Locations") 
#> Note: Older drivers are defined as those aged 65+.
#> Warning in mask$eval_all_mutate(quo): NAs introduced by coercion
#> Assuming "lon" and "lat" are longitude and latitude, respectively
#> Assuming "lon" and "lat" are longitude and latitude, respectively
```

<img src="man/figures/README-unnamed-chunk-12-1.png" width="100%" />

Young drivers:

``` r
counts(
  myFARS, 
  what = "crashes", 
  when = 2015:2020, 
  involved = "young driver", 
  filterOnly = TRUE
  ) %>%
  filter(!is.na(lat), !is.na(lon)) %>%
leaflet() %>%
  addTiles() %>%
  addHeatmap(group = "Heatmap", radius=10, blur=20, minOpacity = .01, max = .2, cellSize = 1) %>%
  addCircleMarkers(
    radius = 1.5,
    color = "red",
    stroke = FALSE,
    fillOpacity = 0.7, group = "Crash Locations") 
#> Note: Young drivers are defined as those between the ages of 15 and 20.
#> Warning in mask$eval_all_mutate(quo): NAs introduced by coercion
#> Assuming "lon" and "lat" are longitude and latitude, respectively
#> Assuming "lon" and "lat" are longitude and latitude, respectively
```

<img src="man/figures/README-unnamed-chunk-13-1.png" width="100%" />

## Modeling

Having access to the full dataset also allows us to develop statistical
models. Here we fit a simple model of injury severity:

``` r
#table(myFARS$flat$inj_sev)
#table(myFARS$flat$rest_mis)

myFARS$flat %>%
  mutate(kabco = case_when(inj_sev == "Fatal Injury (K)" ~ 4,
                           inj_sev %in% c("Suspected Serious Injury (A)", 
                                          "Suspected Serious Injury(A)") ~ 3,
                           inj_sev %in% c("Suspected Minor Injury (B)", 
                                          "Suspected Minor Injury(B)") ~ 2,
                           inj_sev == "Possible Injury (C)" ~ 1,
                           inj_sev == "No Apparent Injury (O)" ~ 0,
                           TRUE ~ as.numeric(NA)
                           ),
         age_n = gsub("\\D+","", age) %>% as.numeric()) %>%
  lm(kabco ~ age_n + rest_mis, data = .) %>%
  summary()
#> 
#> Call:
#> lm(formula = kabco ~ age_n + rest_mis, data = .)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -3.7808 -0.7348  0.3485  1.2451  2.1121 
#> 
#> Coefficients:
#>                                        Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)                           2.4272879  0.0351888  68.979  < 2e-16 ***
#> age_n                                 0.0057484  0.0007201   7.983 1.59e-15 ***
#> rest_misNo Indication of Mis-Use     -0.5451382  0.0386219 -14.115  < 2e-16 ***
#> rest_misNone Used/Not Applicable      0.8821676  0.0439629  20.066  < 2e-16 ***
#> rest_misNot a Motor Vehicle Occupant  1.1925480  0.0538214  22.158  < 2e-16 ***
#> rest_misYes                           1.5612153  1.4130621   1.105    0.269    
#> rest_misYes, Indication of Mis-Use   -0.1939693  0.4476258  -0.433    0.665    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 1.413 on 9522 degrees of freedom
#>   (621 observations deleted due to missingness)
#> Multiple R-squared:  0.1222, Adjusted R-squared:  0.1217 
#> F-statistic:   221 on 6 and 9522 DF,  p-value: < 2.2e-16
```
