
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

## Getting Data

Here we import 5 years of data for Virginia. Note that
`get_fars`requires your permission to download the ZIP files from NHTSA
and save the prepared files on your hard drive. This only has to be run
once and defaults to saving everything in the current working directory.
The `use_fars`function looks in that directory for certain files and
compiles them into a list of data frames: `flat`, `multi_acc`,
`multi_veh`, and `multi_per`.

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

# get_fars(years = 2016:2020, states="Virginia")

myFARS <- use_fars()

#head(myFARS)
```

You can review the list of variables to help guide your analysis with:

``` r
View(fars_varnames)
```

## Counts

A first step in many transportation analyses involves counting the
number of relevant crashes, fatalities, or people involved. `counts`lets
users specify a time period and aggregation interval, and focus in on
specific road users and factors. It can be combined with `ggplot`to
quickly visualize counts.

``` r
library(ggplot2)

counts(myFARS,
       what = "crashes",
       when = 2016:2020,
       interval = c("year")
       ) %>%
  ggplot(aes(x=date, y=n, label=scales::comma(n))) + 
    geom_col() + 
    geom_label(vjust=1.2) +
    labs(x=NULL, y=NULL, title = "Annual Crashes in Virginia")
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

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

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

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

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

We can combine two `counts`to make a comparison. Here we compare the
number of speeding-related fatalities in rural and urban places:

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

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

## Mapping

We can take advantage of having access to the full data with maps. Here
we map the locations of pedbikes involved in fatal crashes in Virginia:

``` r
library(leaflet)
library(leaflet.extras)

myFARS$flat %>% 
  filter(per_typ %in% c("Bicyclist", "Pedestrian")) %>%
  #filter(per_typ %in% c("Bicyclist")) %>%
  leaflet() %>%
    addTiles() %>%
    addHeatmap(group = "Heatmap", radius=10, blur=20, minOpacity = .01, max = .2, cellSize = 10) %>%
    addCircleMarkers(
      radius = 1,
      color = "red",
      stroke = FALSE,
      fillOpacity = 0.7, group = "Crash Locations") %>%
    addLayersControl(
      overlayGroups = c("Crash Locations", "Heatmap"),
      options = layersControlOptions(collapsed = FALSE))
#> Assuming "lon" and "lat" are longitude and latitude, respectively
#> Assuming "lon" and "lat" are longitude and latitude, respectively
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

We can also use the `counts(..., filterOnly=TRUE)` to access the
filtered data prior to aggregating:

``` r
counts(myFARS, what = "fatalities", when = 2016:2020, involved = "alcohol", 
       filterOnly = TRUE) %>%
  leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    radius = 1,
    color = "red",
    stroke = FALSE,
    fillOpacity = 0.7)
#> Assuming "lon" and "lat" are longitude and latitude, respectively
#> Warning in validateCoords(lng, lat, funcName): Data contains 2 rows with either
#> missing or invalid lat/lon values and will be ignored
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

## Modeling

Having access to the full dataset also allows us to develop statistical
models. Here we fit a simple model of injury severity:

``` r
table(myFARS$flat$inj_sev)
#> 
#>         Died Prior to Crash*             Fatal Injury (K) 
#>                            1                         4100 
#>       No Apparent Injury (O)          Possible Injury (C) 
#>                         1657                          373 
#>   Suspected Minor Injury (B)    Suspected Minor Injury(B) 
#>                          933                          183 
#> Suspected Serious Injury (A)  Suspected Serious Injury(A) 
#>                         1014                          227 
#>         Unknown/Not Reported 
#>                           96
table(myFARS$flat$rest_mis)
#> 
#>                           No     No Indication of Mis-Use 
#>                         4667                         1769 
#>     None Used/Not Applicable Not a Motor Vehicle Occupant 
#>                         1436                          702 
#>   Yes, Indication of Mis-Use 
#>                           10

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
