
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
```

## Getting and Using FARS Data

Use the `get_fars()` function to download the ZIP files from NHTSA and
save the prepared files to your hard drive. This only has to be run once
and defaults to saving everything in the current working directory.
Below we import 5 years of data for Virginia. Note that `get_fars()`
requires your permission to download the ZIP files and store prepared
CSVs locally.

``` r
get_fars(years = 2016:2020, states="Virginia")
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
myFARS <- use_fars("FARS data") 

str(myFARS)
#> List of 4
#>  $ flat     :'data.frame':   8584 obs. of  196 variables:
#>   ..$ year         : num [1:8584] 2016 2016 2016 2016 2016 ...
#>   ..$ state        : chr [1:8584] "Virginia" "Virginia" "Virginia" "Virginia" ...
#>   ..$ st_case      : num [1:8584] 510001 510001 510001 510002 510002 ...
#>   ..$ id           : num [1:8584] 2.02e+09 2.02e+09 2.02e+09 2.02e+09 2.02e+09 ...
#>   ..$ veh_no       : num [1:8584] 1 2 3 1 2 2 2 2 3 1 ...
#>   ..$ per_no       : num [1:8584] 1 1 1 1 1 2 3 4 1 1 ...
#>   ..$ county       : chr [1:8584] "FAUQUIER (61)" "FAUQUIER (61)" "FAUQUIER (61)" "DANVILLE (590)" ...
#>   ..$ city         : chr [1:8584] "NOT APPLICABLE" "NOT APPLICABLE" "NOT APPLICABLE" "DANVILLE" ...
#>   ..$ lon          : num [1:8584] -77.8 -77.8 -77.8 -79.4 -79.4 ...
#>   ..$ lat          : num [1:8584] 38.5 38.5 38.5 36.6 36.6 ...
#>   ..$ ve_total     : num [1:8584] 3 3 3 3 3 3 3 3 3 2 ...
#>   ..$ ve_forms     : num [1:8584] 3 3 3 3 3 3 3 3 3 2 ...
#>   ..$ pvh_invl     : num [1:8584] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ peds         : num [1:8584] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ persons      : num [1:8584] 3 3 3 6 6 6 6 6 6 2 ...
#>   ..$ permvit      : num [1:8584] 3 3 3 6 6 6 6 6 6 2 ...
#>   ..$ pernotmvit   : num [1:8584] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ day          : num [1:8584] 3 3 3 2 2 2 2 2 2 4 ...
#>   ..$ month        : chr [1:8584] "January" "January" "January" "January" ...
#>   ..$ day_week     : chr [1:8584] "Sunday" "Sunday" "Sunday" "Saturday" ...
#>   ..$ hour         : num [1:8584] 15 15 15 14 14 14 14 14 14 8 ...
#>   ..$ minute       : num [1:8584] 27 27 27 4 4 4 4 4 4 38 ...
#>   ..$ nhs          : chr [1:8584] "This section IS NOT on the NHS" "This section IS NOT on the NHS" "This section IS NOT on the NHS" "This section IS ON the NHS" ...
#>   ..$ route        : chr [1:8584] "U.S. Highway" "U.S. Highway" "U.S. Highway" "U.S. Highway" ...
#>   ..$ tway_id      : chr [1:8584] "US-29" "US-29" "US-29" "US-" ...
#>   ..$ tway_id2     : chr [1:8584] "RT-651" "RT-651" "RT-651" NA ...
#>   ..$ rur_urb      : chr [1:8584] "Rural" "Rural" "Rural" "Rural" ...
#>   ..$ func_sys     : chr [1:8584] "Principal Arterial - Other" "Principal Arterial - Other" "Principal Arterial - Other" "Principal Arterial - Other" ...
#>   ..$ rd_owner     : chr [1:8584] "Not Reported" "Not Reported" "Not Reported" "Not Reported" ...
#>   ..$ milept       : chr [1:8584] "1717" "1717" "1717" "76" ...
#>   ..$ sp_jur       : chr [1:8584] "No Special Jurisdiction" "No Special Jurisdiction" "No Special Jurisdiction" "No Special Jurisdiction" ...
#>   ..$ harm_ev      : chr [1:8584] "Motor Vehicle In-Transport" "Motor Vehicle In-Transport" "Motor Vehicle In-Transport" "Motor Vehicle In-Transport" ...
#>   ..$ man_coll     : chr [1:8584] "Front-to-Rear" "Front-to-Rear" "Front-to-Rear" "Front-to-Rear" ...
#>   ..$ reljct1      : chr [1:8584] "No" "No" "No" "No" ...
#>   ..$ reljct2      : chr [1:8584] "Intersection-Related" "Intersection-Related" "Intersection-Related" "Non-Junction" ...
#>   ..$ typ_int      : chr [1:8584] "Four-Way Intersection" "Four-Way Intersection" "Four-Way Intersection" "Not an Intersection" ...
#>   ..$ wrk_zone     : chr [1:8584] "None" "None" "None" "None" ...
#>   ..$ rel_road     : chr [1:8584] "On Roadway" "On Roadway" "On Roadway" "On Roadway" ...
#>   ..$ lgt_cond     : chr [1:8584] "Daylight" "Daylight" "Daylight" "Daylight" ...
#>   ..$ sch_bus      : chr [1:8584] "No" "No" "No" "No" ...
#>   ..$ rail         : chr [1:8584] "Not Applicable" "Not Applicable" "Not Applicable" "Not Applicable" ...
#>   ..$ not_hour     : num [1:8584] 15 15 15 15 15 15 15 15 15 8 ...
#>   ..$ not_min      : num [1:8584] 27 27 27 6 6 6 6 6 6 41 ...
#>   ..$ arr_hour     : num [1:8584] 15 15 15 15 15 15 15 15 15 8 ...
#>   ..$ arr_min      : num [1:8584] 31 31 31 15 15 15 15 15 15 49 ...
#>   ..$ hosp_hr      : num [1:8584] 16 16 16 15 15 15 15 15 15 9 ...
#>   ..$ hosp_mn      : num [1:8584] 56 56 56 44 44 44 44 44 44 22 ...
#>   ..$ fatals       : num [1:8584] 1 1 1 1 1 1 1 1 1 1 ...
#>   ..$ drunk_dr     : num [1:8584] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ str_veh      : num [1:8584] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ age          : chr [1:8584] "55 Years" "52 Years" "60 Years" "48 Years" ...
#>   ..$ sex          : chr [1:8584] "Male" "Male" "Male" "Male" ...
#>   ..$ per_typ      : chr [1:8584] "Driver of a Motor Vehicle In-Transport" "Driver of a Motor Vehicle In-Transport" "Driver of a Motor Vehicle In-Transport" "Driver of a Motor Vehicle In-Transport" ...
#>   ..$ inj_sev      : chr [1:8584] "Fatal Injury (K)" "No Apparent Injury (O)" "No Apparent Injury (O)" "Possible Injury (C)" ...
#>   ..$ seat_pos     : chr [1:8584] "Front Seat, Left Side" "Front Seat, Left Side" "Front Seat, Left Side" "Front Seat, Left Side" ...
#>   ..$ rest_use     : chr [1:8584] "Helmet, Unknown if DOT Compliant" "Helmet, Unknown if DOT Compliant" "Helmet, Unknown if DOT Compliant" "Shoulder and Lap Belt Used" ...
#>   ..$ rest_mis     : chr [1:8584] "No" "No" "No" "No" ...
#>   ..$ air_bag      : chr [1:8584] "Not Applicable" "Not Applicable" "Not Applicable" "Deployed- Combination" ...
#>   ..$ ejection     : chr [1:8584] "Not Applicable" "Not Applicable" "Not Applicable" "Not Ejected" ...
#>   ..$ ej_path      : chr [1:8584] "Ejection Path Not Applicable" "Ejection Path Not Applicable" "Ejection Path Not Applicable" "Ejection Path Not Applicable" ...
#>   ..$ extricat     : chr [1:8584] "Not Extricated or Not Applicable" "Not Extricated or Not Applicable" "Not Extricated or Not Applicable" "Not Extricated or Not Applicable" ...
#>   ..$ drinking     : chr [1:8584] "No (Alcohol Not Involved)" "No (Alcohol Not Involved)" "No (Alcohol Not Involved)" "No (Alcohol Not Involved)" ...
#>   ..$ alc_det      : chr [1:8584] "Not Reported" "Not Reported" "Not Reported" "Not Reported" ...
#>   ..$ alc_status   : chr [1:8584] "Test Given" "Test Not Given" "Test Not Given" "Test Not Given" ...
#>   ..$ atst_typ     : chr [1:8584] "Blood" "Test Not Given" "Test Not Given" "Test Not Given" ...
#>   ..$ alc_res      : chr [1:8584] "0.000 % BAC" "Test Not Given" "Test Not Given" "Test Not Given" ...
#>   ..$ drugs        : chr [1:8584] "No (drugs not involved)" "No (drugs not involved)" "No (drugs not involved)" "No (drugs not involved)" ...
#>   ..$ drug_det     : chr [1:8584] "Not Reported" "Not Reported" "Not Reported" "Not Reported" ...
#>   ..$ dstatus      : chr [1:8584] "Test Given" "Test Not Given" "Test Not Given" "Test Not Given" ...
#>   ..$ hospital     : chr [1:8584] "EMS Ground" "Not Transported" "Not Transported" "Not Transported" ...
#>   ..$ doa          : chr [1:8584] "Not Applicable" "Not Applicable" "Not Applicable" "Not Applicable" ...
#>   ..$ death_da     : chr [1:8584] "3" "Not Applicable (Non-Fatal)" "Not Applicable (Non-Fatal)" "Not Applicable (Non-Fatal)" ...
#>   ..$ death_mo     : chr [1:8584] "January" "Not Applicable (Non-Fatal)" "Not Applicable (Non-Fatal)" "Not Applicable (Non-Fatal)" ...
#>   ..$ death_yr     : chr [1:8584] "2016" "Not Applicable (Non-fatal)" "Not Applicable (Non-fatal)" "Not Applicable (Non-fatal)" ...
#>   ..$ death_hr     : num [1:8584] 15 88 88 88 88 88 14 88 88 88 ...
#>   ..$ death_mn     : num [1:8584] 46 88 88 88 88 88 19 88 88 88 ...
#>   ..$ death_tm     : chr [1:8584] "1546" "Not Applicable (Non-fatal)" "Not Applicable (Non-fatal)" "Not Applicable (Non-fatal)" ...
#>   ..$ lag_hrs      : num [1:8584] 0 999 999 999 999 999 0 999 999 999 ...
#>   ..$ lag_mins     : num [1:8584] 19 99 99 99 99 99 15 99 99 99 ...
#>   ..$ work_inj     : chr [1:8584] "No" "Not Applicable (not a fatality)" "Not Applicable (not a fatality)" "Not Applicable (not a fatality)" ...
#>   ..$ hispanic     : chr [1:8584] "Non-Hispanic" "Not A Fatality (not Applicable)" "Not A Fatality (not Applicable)" "Not A Fatality (not Applicable)" ...
#>   ..$ location     : chr [1:8584] "Occupant of a Motor Vehicle" "Occupant of a Motor Vehicle" "Occupant of a Motor Vehicle" "Occupant of a Motor Vehicle" ...
#>   ..$ numoccs      : chr [1:8584] "01" "01" "01" "01" ...
#>   ..$ unittype     : chr [1:8584] "Motor Vehicle In-Transport (Inside or Outside the Trafficway)" "Motor Vehicle In-Transport (Inside or Outside the Trafficway)" "Motor Vehicle In-Transport (Inside or Outside the Trafficway)" "Motor Vehicle In-Transport (Inside or Outside the Trafficway)" ...
#>   ..$ hit_run      : chr [1:8584] "No" "No" "No" "No" ...
#>   ..$ reg_stat     : chr [1:8584] "Virginia" "Virginia" "Virginia" "Virginia" ...
#>   ..$ owner        : chr [1:8584] "Driver (in this crash) was  Registered Owner" "Driver (in this crash) was  Registered Owner" "Driver (in this crash) was  Registered Owner" "Driver (in this crash) was  Registered Owner" ...
#>   ..$ make         : chr [1:8584] "Other Make" "Other Make" "Other Make" "Chevrolet" ...
#>   ..$ model        : num [1:8584] 709 709 709 481 441 441 441 441 421 402 ...
#>   ..$ mak_mod      : chr [1:8584] "Other Make Unknown cc" "Other Make Unknown cc" "Other Make Unknown cc" "Chevrolet C, K, R, V-series pickup/Silverado" ...
#>   ..$ body_typ     : chr [1:8584] "Motorcycle" "Motorcycle" "Motorcycle" "Standard pickup (GVWR 4,500 to 10,00 lbs.)(Jeep Pickup, Comanche, Ram Pickup, D100-D350,....)" ...
#>   ..$ mod_year     : chr [1:8584] "2000" "1993" "2003" "2009" ...
#>   ..$ vin          : chr [1:8584] "ZCGAEDJH1YV0" "ZES1DB21XPRZ" "ZD4RPU04X3S0" "3GCEK23389G2" ...
#>   ..$ tow_veh      : chr [1:8584] "No Trailing Units" "No Trailing Units" "No Trailing Units" "No Trailing Units" ...
#>   ..$ j_knife      : chr [1:8584] "Not an Articulated Vehicle" "Not an Articulated Vehicle" "Not an Articulated Vehicle" "Not an Articulated Vehicle" ...
#>   ..$ mcarr_i1     : chr [1:8584] "Not Applicable" "Not Applicable" "Not Applicable" "Not Applicable" ...
#>   ..$ mcarr_i2     : chr [1:8584] "Not Applicable" "Not Applicable" "Not Applicable" "Not Applicable" ...
#>   ..$ mcarr_id     : chr [1:8584] "Not Applicable" "Not Applicable" "Not Applicable" "Not Applicable" ...
#>   ..$ v_config     : chr [1:8584] "Not Applicable" "Not Applicable" "Not Applicable" "Not Applicable" ...
#>   .. [list output truncated]
#>  $ multi_acc:'data.frame':   77413 obs. of  5 variables:
#>   ..$ state  : chr [1:77413] "Virginia" "Virginia" "Virginia" "Virginia" ...
#>   ..$ st_case: num [1:77413] 510001 510001 510001 510001 510001 ...
#>   ..$ name   : chr [1:77413] "eventnum" "vnumber1" "aoi1" "soe" ...
#>   ..$ value  : chr [1:77413] "1" "1" "12 Clock Point" "Motor Vehicle In-Transport" ...
#>   ..$ year   : num [1:77413] 2016 2016 2016 2016 2016 ...
#>  $ multi_veh:'data.frame':   78547 obs. of  6 variables:
#>   ..$ state  : chr [1:78547] "Virginia" "Virginia" "Virginia" "Virginia" ...
#>   ..$ st_case: num [1:78547] 510001 510001 510001 510002 510002 ...
#>   ..$ veh_no : num [1:78547] 1 2 3 1 2 3 1 2 1 1 ...
#>   ..$ name   : chr [1:78547] "vehiclesf" "vehiclesf" "vehiclesf" "vehiclesf" ...
#>   ..$ value  : chr [1:78547] "None" "None" "None" "None" ...
#>   ..$ year   : num [1:78547] 2016 2016 2016 2016 2016 ...
#>  $ multi_per:'data.frame':   54891 obs. of  7 variables:
#>   ..$ state  : chr [1:54891] "Virginia" "Virginia" "Virginia" "Virginia" ...
#>   ..$ st_case: num [1:54891] 510001 510001 510001 510002 510002 ...
#>   ..$ veh_no : num [1:54891] 1 2 3 1 2 2 2 2 3 1 ...
#>   ..$ per_no : num [1:54891] 1 1 1 1 1 2 3 4 1 1 ...
#>   ..$ name   : chr [1:54891] "race" "race" "race" "race" ...
#>   ..$ value  : chr [1:54891] "White" "Not a Fatality (not Applicable)" "Not a Fatality (not Applicable)" "Not a Fatality (not Applicable)" ...
#>   ..$ year   : num [1:54891] 2016 2016 2016 2016 2016 ...
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
counts(myFARS,
       what = "crashes",
       when = 2016:2020,
       interval = c("year")
       ) %>%
  ggplot(aes(x=date, y=n, label=scales::comma(n))) + 
    geom_col() + 
    geom_label(vjust=1.2) +
    labs(x=NULL, y=NULL, title = "Annual Fatal Crashes in Virginia")
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

``` r
counts(myFARS,
       what = "fatalities",
       when = 2016:2020,
       interval = c("year")
       ) %>%
  ggplot(aes(x=date, y=n, label=scales::comma(n))) + 
    geom_col() + 
    geom_label(vjust=1.2) +
    labs(x=NULL, y=NULL, title = "Annual Fatalities in Virginia")
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

``` r
counts(myFARS,
       what = "fatalities",
       when = 2016:2020,
       where = "rural",
       interval = c("year")
       ) %>%
  ggplot(aes(x=date, y=n, label=scales::comma(n))) + 
    geom_col() + 
    geom_label(vjust=1.2) +
    labs(x=NULL, y=NULL, title = "Annual Rural Fatalities in Virginia")
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

``` r
counts(myFARS,
       what = "fatalities",
       when = 2016:2020,
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
       when = 2016:2020,
       where = "rural",
       interval = c("year"),
       involved = "speeding"
       ) %>%
    mutate(where = "Rural"),
  counts(myFARS,
       what = "fatalities",
       when = 2016:2020,
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
library(leaflet)
library(leaflet.extras)

counts(
  myFARS, 
  what = "fatalities", 
  when = 2016:2020, 
  involved = "pedbike", 
  filterOnly = TRUE
  ) %>%
leaflet() %>%
  addTiles() %>%
  addHeatmap(group = "Heatmap", radius=10, blur=20, minOpacity = .01, max = .2, cellSize = 10) %>%
  addCircleMarkers(
    radius = 1.5,
    color = "red",
    stroke = FALSE,
    fillOpacity = 0.7, group = "Crash Locations") 
#> Assuming "lon" and "lat" are longitude and latitude, respectively
#> Assuming "lon" and "lat" are longitude and latitude, respectively
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

Drug-related fatalities:

``` r
counts(
  myFARS, 
  what = "fatalities", 
  when = 2016:2020, 
  involved = "drugs", 
  filterOnly = TRUE
  ) %>%
  filter(!is.na(lat), !is.na(lon)) %>%
leaflet() %>%
  addTiles() %>%
  addHeatmap(group = "Heatmap", radius=10, blur=20, minOpacity = .01, max = .2, cellSize = 10) %>%
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
  when = 2016:2020, 
  involved = "older driver", 
  filterOnly = TRUE
  ) %>%
  filter(!is.na(lat), !is.na(lon)) %>%
leaflet() %>%
  addTiles() %>%
  addHeatmap(group = "Heatmap", radius=10, blur=20, minOpacity = .01, max = .2, cellSize = 10) %>%
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
  when = 2016:2020, 
  involved = "young driver", 
  filterOnly = TRUE
  ) %>%
  filter(!is.na(lat), !is.na(lon)) %>%
leaflet() %>%
  addTiles() %>%
  addHeatmap(group = "Heatmap", radius=10, blur=20, minOpacity = .01, max = .2, cellSize = 10) %>%
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
#> -3.7767 -0.6870  0.3193  1.2169  2.1080 
#> 
#> Coefficients:
#>                                        Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)                           2.4440395  0.0380498  64.233  < 2e-16 ***
#> age_n                                 0.0056513  0.0007664   7.373 1.83e-13 ***
#> rest_misNo Indication of Mis-Use     -0.5576416  0.0392407 -14.211  < 2e-16 ***
#> rest_misNone Used/Not Applicable      0.8692978  0.0443118  19.618  < 2e-16 ***
#> rest_misNot a Motor Vehicle Occupant  1.1800812  0.0568344  20.763  < 2e-16 ***
#> rest_misYes, Indication of Mis-Use   -0.2095945  0.4391045  -0.477    0.633    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 1.385 on 8061 degrees of freedom
#>   (517 observations deleted due to missingness)
#> Multiple R-squared:  0.1377, Adjusted R-squared:  0.1372 
#> F-statistic: 257.5 on 5 and 8061 DF,  p-value: < 2.2e-16
```
