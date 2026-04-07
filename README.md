
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

`rfars` allows users to download the last 10+ years of FARS and GES/CRSS
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

Then load `rfars` and some helpful packages:

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

`get_fars()` and `get_gescrss()` take the parameters `years` and
`states` (FARS) or `regions` (GES/CRSS). As the source data files follow
an annual structure, `years` determines how many file sets are
downloaded or loaded, and `states`/`regions` filters the resulting
dataset. Downloading and processing these files can take several
minutes. Before downloading, `rfars` will inform you that it’s about to
download files and asks your permission to do so. To skip this dialog,
set `proceed = TRUE`. You can use the `dir` and `cache` parameters to
save an RDS file to your local machine. The `dir` parameter specifies
the directory, and `cache` names the file (be sure to include the .rds
file extension).

Executing the code below will download the prepared FARS and GES/CRSS
databases for 2014-2023.

``` r
myFARS <- get_fars(proceed = TRUE)
myCRSS <- get_gescrss(proceed = TRUE)
```

`get_fars()` and `get_gescrss()` return a list with six dataframes:
`flat`, `multi_acc`, `multi_veh`, `multi_per`, `events`, and `codebook`.

The tables below show records for randomly selected crashes to
illustrate the content and structure of the data. The tables are
transposed for readability.

Each row in the `flat` dataframe corresponds to a person involved in a
crash. As there may be multiple people and/or vehicles involved in one
crash, some variable-values are repeated within a crash or vehicle. Each
crash is uniquely identified with `id`, which is a combination of `year`
and `st_case`. Note that `st_case` is not unique across years, for
example, `st_case` 510001 will appear in each year. The `id` variable
attempts to avoid this issue. The GES/CRSS data includes a `weight`
variable that indicates how many crashes each row represents.

<table>
<caption>
The ‘flat’ dataframe (transposed for readability)
</caption>
<tbody>
<tr>
<td style="text-align:left;">
year
</td>
<td style="text-align:left;">
2024
</td>
<td style="text-align:left;">
2024
</td>
<td style="text-align:left;">
2024
</td>
<td style="text-align:left;">
2024
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
state
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Ohio
</td>
</tr>
<tr>
<td style="text-align:left;">
st_case
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
390256
</td>
</tr>
<tr>
<td style="text-align:left;">
id
</td>
<td style="text-align:left;">
2024130177
</td>
<td style="text-align:left;">
2024130177
</td>
<td style="text-align:left;">
2024130177
</td>
<td style="text-align:left;">
2024130177
</td>
<td style="text-align:left;">
2024390256
</td>
</tr>
<tr>
<td style="text-align:left;">
veh_no
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
per_no
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
county
</td>
<td style="text-align:left;">
89
</td>
<td style="text-align:left;">
89
</td>
<td style="text-align:left;">
89
</td>
<td style="text-align:left;">
89
</td>
<td style="text-align:left;">
129
</td>
</tr>
<tr>
<td style="text-align:left;">
city
</td>
<td style="text-align:left;">
1610
</td>
<td style="text-align:left;">
1610
</td>
<td style="text-align:left;">
1610
</td>
<td style="text-align:left;">
1610
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
lon
</td>
<td style="text-align:left;">
-84.22238
</td>
<td style="text-align:left;">
-84.22238
</td>
<td style="text-align:left;">
-84.22238
</td>
<td style="text-align:left;">
-84.22238
</td>
<td style="text-align:left;">
-82.92455
</td>
</tr>
<tr>
<td style="text-align:left;">
lat
</td>
<td style="text-align:left;">
33.74721
</td>
<td style="text-align:left;">
33.74721
</td>
<td style="text-align:left;">
33.74721
</td>
<td style="text-align:left;">
33.74721
</td>
<td style="text-align:left;">
39.50034
</td>
</tr>
<tr>
<td style="text-align:left;">
acc_type
</td>
<td style="text-align:left;">
K83-Changing Trafficway, Vehicle Turning-Turn Into Path-Turn Into
Opposite Directions (Going Straight)
</td>
<td style="text-align:left;">
K82-Changing Trafficway, Vehicle Turning-Turn Into Path-Turn Into
Opposite Directions (Turning Left)
</td>
<td style="text-align:left;">
K82-Changing Trafficway, Vehicle Turning-Turn Into Path-Turn Into
Opposite Directions (Turning Left)
</td>
<td style="text-align:left;">
M98-Other Crash Type
</td>
<td style="text-align:left;">
B7-Single Driver-Left Roadside Departure-Control/Traction Loss
</td>
</tr>
<tr>
<td style="text-align:left;">
age
</td>
<td style="text-align:left;">
47 Years
</td>
<td style="text-align:left;">
26 Years
</td>
<td style="text-align:left;">
21 Years
</td>
<td style="text-align:left;">
58 Years
</td>
<td style="text-align:left;">
69 Years
</td>
</tr>
<tr>
<td style="text-align:left;">
air_bag
</td>
<td style="text-align:left;">
Deployed- Combination
</td>
<td style="text-align:left;">
Deployed- Combination
</td>
<td style="text-align:left;">
Deployed- Combination
</td>
<td style="text-align:left;">
Deployed- Combination
</td>
<td style="text-align:left;">
Not Deployed
</td>
</tr>
<tr>
<td style="text-align:left;">
alc_res
</td>
<td style="text-align:left;">
0.169 % BAC
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
0.000 % BAC
</td>
<td style="text-align:left;">
Test Not Given
</td>
</tr>
<tr>
<td style="text-align:left;">
alc_status
</td>
<td style="text-align:left;">
Test Given
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
Test Given
</td>
<td style="text-align:left;">
Test Not Given
</td>
</tr>
<tr>
<td style="text-align:left;">
arr_hour
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
9:00am-9:59am
</td>
</tr>
<tr>
<td style="text-align:left;">
arr_min
</td>
<td style="text-align:left;">
45
</td>
<td style="text-align:left;">
45
</td>
<td style="text-align:left;">
45
</td>
<td style="text-align:left;">
45
</td>
<td style="text-align:left;">
14
</td>
</tr>
<tr>
<td style="text-align:left;">
atst_typ
</td>
<td style="text-align:left;">
Blood
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
Blood
</td>
<td style="text-align:left;">
Test Not Given
</td>
</tr>
<tr>
<td style="text-align:left;">
bikecgp
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
bikectype
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
bikedir
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
bikeloc
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
bikepos
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
body_typ
</td>
<td style="text-align:left;">
5-door/4-door hatchback
</td>
<td style="text-align:left;">
4-door sedan, hardtop
</td>
<td style="text-align:left;">
4-door sedan, hardtop
</td>
<td style="text-align:left;">
Compact Utility (Utility Vehicle Categories "Small" and "Midsize")
</td>
<td style="text-align:left;">
Minivan (Chrysler Town and Country, Caravan, Grand Caravan, Voyager,
Voyager, Honda-Odyssey, …)
</td>
</tr>
<tr>
<td style="text-align:left;">
bus_use
</td>
<td style="text-align:left;">
Not a Bus
</td>
<td style="text-align:left;">
Not a Bus
</td>
<td style="text-align:left;">
Not a Bus
</td>
<td style="text-align:left;">
Not a Bus
</td>
<td style="text-align:left;">
Not a Bus
</td>
</tr>
<tr>
<td style="text-align:left;">
cargo_bt
</td>
<td style="text-align:left;">
Not Applicable (N/A)
</td>
<td style="text-align:left;">
Not Applicable (N/A)
</td>
<td style="text-align:left;">
Not Applicable (N/A)
</td>
<td style="text-align:left;">
Not Applicable (N/A)
</td>
<td style="text-align:left;">
Not Applicable (N/A)
</td>
</tr>
<tr>
<td style="text-align:left;">
cdl_stat
</td>
<td style="text-align:left;">
No (CDL)
</td>
<td style="text-align:left;">
No (CDL)
</td>
<td style="text-align:left;">
No (CDL)
</td>
<td style="text-align:left;">
No (CDL)
</td>
<td style="text-align:left;">
No (CDL)
</td>
</tr>
<tr>
<td style="text-align:left;">
cityname
</td>
<td style="text-align:left;">
DECATUR
</td>
<td style="text-align:left;">
DECATUR
</td>
<td style="text-align:left;">
DECATUR
</td>
<td style="text-align:left;">
DECATUR
</td>
<td style="text-align:left;">
NOT APPLICABLE
</td>
</tr>
<tr>
<td style="text-align:left;">
countyname
</td>
<td style="text-align:left;">
DEKALB (89)
</td>
<td style="text-align:left;">
DEKALB (89)
</td>
<td style="text-align:left;">
DEKALB (89)
</td>
<td style="text-align:left;">
DEKALB (89)
</td>
<td style="text-align:left;">
PICKAWAY (129)
</td>
</tr>
<tr>
<td style="text-align:left;">
day
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
20
</td>
</tr>
<tr>
<td style="text-align:left;">
day_week
</td>
<td style="text-align:left;">
Sunday
</td>
<td style="text-align:left;">
Sunday
</td>
<td style="text-align:left;">
Sunday
</td>
<td style="text-align:left;">
Sunday
</td>
<td style="text-align:left;">
Saturday
</td>
</tr>
<tr>
<td style="text-align:left;">
death_da
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
Not Applicable (Non-Fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-Fatal)
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
20
</td>
</tr>
<tr>
<td style="text-align:left;">
death_hr
</td>
<td style="text-align:left;">
23:00-23:59
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
23:00-23:59
</td>
<td style="text-align:left;">
10:00-10:59
</td>
</tr>
<tr>
<td style="text-align:left;">
death_mn
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
42
</td>
<td style="text-align:left;">
9
</td>
</tr>
<tr>
<td style="text-align:left;">
death_mo
</td>
<td style="text-align:left;">
March
</td>
<td style="text-align:left;">
Not Applicable (Non-Fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-Fatal)
</td>
<td style="text-align:left;">
March
</td>
<td style="text-align:left;">
April
</td>
</tr>
<tr>
<td style="text-align:left;">
death_tm
</td>
<td style="text-align:left;">
2325
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
2342
</td>
<td style="text-align:left;">
1009
</td>
</tr>
<tr>
<td style="text-align:left;">
death_yr
</td>
<td style="text-align:left;">
2024
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
2024
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
deaths
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
deformed
</td>
<td style="text-align:left;">
Disabling Damage
</td>
<td style="text-align:left;">
Disabling Damage
</td>
<td style="text-align:left;">
Disabling Damage
</td>
<td style="text-align:left;">
Disabling Damage
</td>
<td style="text-align:left;">
Disabling Damage
</td>
</tr>
<tr>
<td style="text-align:left;">
devmotor
</td>
<td style="text-align:left;">
8
</td>
<td style="text-align:left;">
8
</td>
<td style="text-align:left;">
8
</td>
<td style="text-align:left;">
8
</td>
<td style="text-align:left;">
8
</td>
</tr>
<tr>
<td style="text-align:left;">
devtype
</td>
<td style="text-align:left;">
Occupant of a Motor Vehicle
</td>
<td style="text-align:left;">
Occupant of a Motor Vehicle
</td>
<td style="text-align:left;">
Occupant of a Motor Vehicle
</td>
<td style="text-align:left;">
Occupant of a Motor Vehicle
</td>
<td style="text-align:left;">
Occupant of a Motor Vehicle
</td>
</tr>
<tr>
<td style="text-align:left;">
doa
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
dr_drink
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
</tr>
<tr>
<td style="text-align:left;">
dr_hgt
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
68
</td>
</tr>
<tr>
<td style="text-align:left;">
dr_pres
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
Yes
</td>
</tr>
<tr>
<td style="text-align:left;">
dr_wgt
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
140 lbs.
</td>
</tr>
<tr>
<td style="text-align:left;">
dr_zip
</td>
<td style="text-align:left;">
30034
</td>
<td style="text-align:left;">
30294
</td>
<td style="text-align:left;">
30294
</td>
<td style="text-align:left;">
30083
</td>
<td style="text-align:left;">
43113
</td>
</tr>
<tr>
<td style="text-align:left;">
drinking
</td>
<td style="text-align:left;">
Reported as Unknown
</td>
<td style="text-align:left;">
Reported as Unknown
</td>
<td style="text-align:left;">
Not Reported
</td>
<td style="text-align:left;">
Reported as Unknown
</td>
<td style="text-align:left;">
Not Reported
</td>
</tr>
<tr>
<td style="text-align:left;">
drugs
</td>
<td style="text-align:left;">
Reported as Unknown
</td>
<td style="text-align:left;">
Reported as Unknown
</td>
<td style="text-align:left;">
Not Reported
</td>
<td style="text-align:left;">
Reported as Unknown
</td>
<td style="text-align:left;">
Not Reported
</td>
</tr>
<tr>
<td style="text-align:left;">
dstatus
</td>
<td style="text-align:left;">
Test Given
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
Test Given
</td>
<td style="text-align:left;">
Test Given
</td>
</tr>
<tr>
<td style="text-align:left;">
ej_path
</td>
<td style="text-align:left;">
Ejection Path Not Applicable
</td>
<td style="text-align:left;">
Ejection Path Not Applicable
</td>
<td style="text-align:left;">
Ejection Path Not Applicable
</td>
<td style="text-align:left;">
Ejection Path Not Applicable
</td>
<td style="text-align:left;">
Ejection Path Unknown
</td>
</tr>
<tr>
<td style="text-align:left;">
ejection
</td>
<td style="text-align:left;">
Not Ejected
</td>
<td style="text-align:left;">
Not Ejected
</td>
<td style="text-align:left;">
Not Ejected
</td>
<td style="text-align:left;">
Not Ejected
</td>
<td style="text-align:left;">
Totally Ejected
</td>
</tr>
<tr>
<td style="text-align:left;">
emer_use
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
extricat
</td>
<td style="text-align:left;">
Not Extricated or Not Applicable
</td>
<td style="text-align:left;">
Not Extricated or Not Applicable
</td>
<td style="text-align:left;">
Not Extricated or Not Applicable
</td>
<td style="text-align:left;">
Not Extricated or Not Applicable
</td>
<td style="text-align:left;">
Not Extricated or Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
fatals
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
fire_exp
</td>
<td style="text-align:left;">
No or Not Reported
</td>
<td style="text-align:left;">
No or Not Reported
</td>
<td style="text-align:left;">
No or Not Reported
</td>
<td style="text-align:left;">
No or Not Reported
</td>
<td style="text-align:left;">
No or Not Reported
</td>
</tr>
<tr>
<td style="text-align:left;">
first_mo
</td>
<td style="text-align:left;">
February
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
February
</td>
</tr>
<tr>
<td style="text-align:left;">
first_yr
</td>
<td style="text-align:left;">
2024
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
func_sys
</td>
<td style="text-align:left;">
Minor Arterial
</td>
<td style="text-align:left;">
Minor Arterial
</td>
<td style="text-align:left;">
Minor Arterial
</td>
<td style="text-align:left;">
Minor Arterial
</td>
<td style="text-align:left;">
Local
</td>
</tr>
<tr>
<td style="text-align:left;">
gvwr_from
</td>
<td style="text-align:left;">
Class 1: 6,000 lbs. or less (2,722 kg or less)
</td>
<td style="text-align:left;">
Class 1: 6,000 lbs. or less (2,722 kg or less)
</td>
<td style="text-align:left;">
Class 1: 6,000 lbs. or less (2,722 kg or less)
</td>
<td style="text-align:left;">
Class 1: 6,000 lbs. or less (2,722 kg or less)
</td>
<td style="text-align:left;">
Class 1: 6,000 lbs. or less (2,722 kg or less)
</td>
</tr>
<tr>
<td style="text-align:left;">
gvwr_to
</td>
<td style="text-align:left;">
Class 1: 6,000 lbs. or less (2,722 kg or less)
</td>
<td style="text-align:left;">
Class 1: 6,000 lbs. or less (2,722 kg or less)
</td>
<td style="text-align:left;">
Class 1: 6,000 lbs. or less (2,722 kg or less)
</td>
<td style="text-align:left;">
Class 1: 6,000 lbs. or less (2,722 kg or less)
</td>
<td style="text-align:left;">
Class 1: 6,000 lbs. or less (2,722 kg or less)
</td>
</tr>
<tr>
<td style="text-align:left;">
harm_ev
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Ditch
</td>
</tr>
<tr>
<td style="text-align:left;">
haz_cno
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
haz_id
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
haz_inv
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
</tr>
<tr>
<td style="text-align:left;">
haz_plac
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
haz_rel
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
helm_mis
</td>
<td style="text-align:left;">
None Used/Not Applicable
</td>
<td style="text-align:left;">
None Used/Not Applicable
</td>
<td style="text-align:left;">
None Used/Not Applicable
</td>
<td style="text-align:left;">
None Used/Not Applicable
</td>
<td style="text-align:left;">
None Used/Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
helm_use
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
hispanic
</td>
<td style="text-align:left;">
Non-Hispanic
</td>
<td style="text-align:left;">
Not A Fatality (not Applicable)
</td>
<td style="text-align:left;">
Not A Fatality (not Applicable)
</td>
<td style="text-align:left;">
Non-Hispanic
</td>
<td style="text-align:left;">
Non-Hispanic
</td>
</tr>
<tr>
<td style="text-align:left;">
hit_run
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
</tr>
<tr>
<td style="text-align:left;">
hosp_hr
</td>
<td style="text-align:left;">
11:00pm-11:59pm
</td>
<td style="text-align:left;">
11:00pm-11:59pm
</td>
<td style="text-align:left;">
11:00pm-11:59pm
</td>
<td style="text-align:left;">
11:00pm-11:59pm
</td>
<td style="text-align:left;">
9:00am-9:59am
</td>
</tr>
<tr>
<td style="text-align:left;">
hosp_mn
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
45
</td>
</tr>
<tr>
<td style="text-align:left;">
hospital
</td>
<td style="text-align:left;">
EMS Ground
</td>
<td style="text-align:left;">
EMS Ground
</td>
<td style="text-align:left;">
Not Transported for Treatment
</td>
<td style="text-align:left;">
EMS Ground
</td>
<td style="text-align:left;">
EMS Ground
</td>
</tr>
<tr>
<td style="text-align:left;">
hour
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
8:00am-8:59am
</td>
</tr>
<tr>
<td style="text-align:left;">
icfinalbody
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
impact1
</td>
<td style="text-align:left;">
12 Clock Point
</td>
<td style="text-align:left;">
12 Clock Point
</td>
<td style="text-align:left;">
12 Clock Point
</td>
<td style="text-align:left;">
12 Clock Point
</td>
<td style="text-align:left;">
11 Clock Point
</td>
</tr>
<tr>
<td style="text-align:left;">
inj_sev
</td>
<td style="text-align:left;">
Fatal Injury (K)
</td>
<td style="text-align:left;">
Suspected Minor Injury (B)
</td>
<td style="text-align:left;">
No Apparent Injury (O)
</td>
<td style="text-align:left;">
Fatal Injury (K)
</td>
<td style="text-align:left;">
Fatal Injury (K)
</td>
</tr>
<tr>
<td style="text-align:left;">
j_knife
</td>
<td style="text-align:left;">
Not an Articulated Vehicle
</td>
<td style="text-align:left;">
Not an Articulated Vehicle
</td>
<td style="text-align:left;">
Not an Articulated Vehicle
</td>
<td style="text-align:left;">
Not an Articulated Vehicle
</td>
<td style="text-align:left;">
Not an Articulated Vehicle
</td>
</tr>
<tr>
<td style="text-align:left;">
l_compl
</td>
<td style="text-align:left;">
Valid license for this class vehicle
</td>
<td style="text-align:left;">
Valid license for this class vehicle
</td>
<td style="text-align:left;">
Valid license for this class vehicle
</td>
<td style="text-align:left;">
Valid license for this class vehicle
</td>
<td style="text-align:left;">
Valid license for this class vehicle
</td>
</tr>
<tr>
<td style="text-align:left;">
l_endors
</td>
<td style="text-align:left;">
No Endorsements required for this vehicle
</td>
<td style="text-align:left;">
No Endorsements required for this vehicle
</td>
<td style="text-align:left;">
No Endorsements required for this vehicle
</td>
<td style="text-align:left;">
No Endorsements required for this vehicle
</td>
<td style="text-align:left;">
No Endorsements required for this vehicle
</td>
</tr>
<tr>
<td style="text-align:left;">
l_restri
</td>
<td style="text-align:left;">
No Restrictions or Not Applicable
</td>
<td style="text-align:left;">
No Restrictions or Not Applicable
</td>
<td style="text-align:left;">
No Restrictions or Not Applicable
</td>
<td style="text-align:left;">
No Restrictions or Not Applicable
</td>
<td style="text-align:left;">
Restrictions, Compliance Unknown
</td>
</tr>
<tr>
<td style="text-align:left;">
l_state
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Ohio
</td>
</tr>
<tr>
<td style="text-align:left;">
l_status
</td>
<td style="text-align:left;">
Valid
</td>
<td style="text-align:left;">
Valid
</td>
<td style="text-align:left;">
Valid
</td>
<td style="text-align:left;">
Valid
</td>
<td style="text-align:left;">
Valid
</td>
</tr>
<tr>
<td style="text-align:left;">
l_type
</td>
<td style="text-align:left;">
Full Driver License
</td>
<td style="text-align:left;">
Full Driver License
</td>
<td style="text-align:left;">
Full Driver License
</td>
<td style="text-align:left;">
Full Driver License
</td>
<td style="text-align:left;">
Full Driver License
</td>
</tr>
<tr>
<td style="text-align:left;">
lag_hrs
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
lag_mins
</td>
<td style="text-align:left;">
45
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
12
</td>
</tr>
<tr>
<td style="text-align:left;">
last_mo
</td>
<td style="text-align:left;">
February
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
February
</td>
</tr>
<tr>
<td style="text-align:left;">
last_yr
</td>
<td style="text-align:left;">
2024
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
No Record
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
lgt_cond
</td>
<td style="text-align:left;">
Dark - Lighted
</td>
<td style="text-align:left;">
Dark - Lighted
</td>
<td style="text-align:left;">
Dark - Lighted
</td>
<td style="text-align:left;">
Dark - Lighted
</td>
<td style="text-align:left;">
Daylight
</td>
</tr>
<tr>
<td style="text-align:left;">
location
</td>
<td style="text-align:left;">
Occupant of a Motor Vehicle
</td>
<td style="text-align:left;">
Occupant of a Motor Vehicle
</td>
<td style="text-align:left;">
Occupant of a Motor Vehicle
</td>
<td style="text-align:left;">
Occupant of a Motor Vehicle
</td>
<td style="text-align:left;">
Occupant of a Motor Vehicle
</td>
</tr>
<tr>
<td style="text-align:left;">
m_harm
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Rollover/Overturn
</td>
</tr>
<tr>
<td style="text-align:left;">
mak_mod
</td>
<td style="text-align:left;">
Ford Focus
</td>
<td style="text-align:left;">
Nissan/Datsun Altima
</td>
<td style="text-align:left;">
Nissan/Datsun Altima
</td>
<td style="text-align:left;">
Honda CR-V
</td>
<td style="text-align:left;">
Chevrolet Uplander
</td>
</tr>
<tr>
<td style="text-align:left;">
make
</td>
<td style="text-align:left;">
Ford
</td>
<td style="text-align:left;">
Nissan/Datsun
</td>
<td style="text-align:left;">
Nissan/Datsun
</td>
<td style="text-align:left;">
Honda
</td>
<td style="text-align:left;">
Chevrolet
</td>
</tr>
<tr>
<td style="text-align:left;">
man_coll
</td>
<td style="text-align:left;">
Front-to-Front
</td>
<td style="text-align:left;">
Front-to-Front
</td>
<td style="text-align:left;">
Front-to-Front
</td>
<td style="text-align:left;">
Front-to-Front
</td>
<td style="text-align:left;">
The First Harmful Event was Not a Collision with a Motor Vehicle in
Transport
</td>
</tr>
<tr>
<td style="text-align:left;">
mcarr_i1
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
mcarr_i2
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
mcarr_id
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
milept
</td>
<td style="text-align:left;">
28
</td>
<td style="text-align:left;">
28
</td>
<td style="text-align:left;">
28
</td>
<td style="text-align:left;">
28
</td>
<td style="text-align:left;">
None
</td>
</tr>
<tr>
<td style="text-align:left;">
minute
</td>
<td style="text-align:left;">
40
</td>
<td style="text-align:left;">
40
</td>
<td style="text-align:left;">
40
</td>
<td style="text-align:left;">
40
</td>
<td style="text-align:left;">
57
</td>
</tr>
<tr>
<td style="text-align:left;">
mod_year
</td>
<td style="text-align:left;">
2015
</td>
<td style="text-align:left;">
2019
</td>
<td style="text-align:left;">
2019
</td>
<td style="text-align:left;">
2016
</td>
<td style="text-align:left;">
2005
</td>
</tr>
<tr>
<td style="text-align:left;">
model
</td>
<td style="text-align:left;">
37
</td>
<td style="text-align:left;">
47
</td>
<td style="text-align:left;">
47
</td>
<td style="text-align:left;">
402
</td>
<td style="text-align:left;">
444
</td>
</tr>
<tr>
<td style="text-align:left;">
month
</td>
<td style="text-align:left;">
March
</td>
<td style="text-align:left;">
March
</td>
<td style="text-align:left;">
March
</td>
<td style="text-align:left;">
March
</td>
<td style="text-align:left;">
April
</td>
</tr>
<tr>
<td style="text-align:left;">
motdir
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
motman
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
nhs
</td>
<td style="text-align:left;">
This Section IS NOT on the NHS
</td>
<td style="text-align:left;">
This Section IS NOT on the NHS
</td>
<td style="text-align:left;">
This Section IS NOT on the NHS
</td>
<td style="text-align:left;">
This Section IS NOT on the NHS
</td>
<td style="text-align:left;">
This Section IS NOT on the NHS
</td>
</tr>
<tr>
<td style="text-align:left;">
nmhelmet
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
nmlight
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
nmothpre
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
nmothpro
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
nmpropad
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
nmrefclo
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
not_hour
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
10:00pm-10:59pm
</td>
<td style="text-align:left;">
9:00am-9:59am
</td>
</tr>
<tr>
<td style="text-align:left;">
not_min
</td>
<td style="text-align:left;">
40
</td>
<td style="text-align:left;">
40
</td>
<td style="text-align:left;">
40
</td>
<td style="text-align:left;">
40
</td>
<td style="text-align:left;">
5
</td>
</tr>
<tr>
<td style="text-align:left;">
numoccs
</td>
<td style="text-align:left;">
01
</td>
<td style="text-align:left;">
02
</td>
<td style="text-align:left;">
02
</td>
<td style="text-align:left;">
01
</td>
<td style="text-align:left;">
01
</td>
</tr>
<tr>
<td style="text-align:left;">
owner
</td>
<td style="text-align:left;">
Driver (in this crash) was Registered Owner
</td>
<td style="text-align:left;">
Driver (in this crash) Not Registered Owner (Other Private Owner Listed)
</td>
<td style="text-align:left;">
Driver (in this crash) Not Registered Owner (Other Private Owner Listed)
</td>
<td style="text-align:left;">
Driver (in this crash) was Registered Owner
</td>
<td style="text-align:left;">
Driver (in this crash) was Registered Owner
</td>
</tr>
<tr>
<td style="text-align:left;">
p_crash1
</td>
<td style="text-align:left;">
Going Straight
</td>
<td style="text-align:left;">
Turning Left
</td>
<td style="text-align:left;">
Turning Left
</td>
<td style="text-align:left;">
Going Straight
</td>
<td style="text-align:left;">
Negotiating a Curve
</td>
</tr>
<tr>
<td style="text-align:left;">
p_crash2
</td>
<td style="text-align:left;">
Crossing Over (Passing Through) Junction
</td>
<td style="text-align:left;">
Turning Left
</td>
<td style="text-align:left;">
Turning Left
</td>
<td style="text-align:left;">
From opposite direction over left lane line
</td>
<td style="text-align:left;">
Traveling Too Fast for Conditions or Road Configuration
</td>
</tr>
<tr>
<td style="text-align:left;">
p_crash3
</td>
<td style="text-align:left;">
Unknown/Not Reported
</td>
<td style="text-align:left;">
Unknown/Not Reported
</td>
<td style="text-align:left;">
Unknown/Not Reported
</td>
<td style="text-align:left;">
No Avoidance Maneuver
</td>
<td style="text-align:left;">
Unknown/Not Reported
</td>
</tr>
<tr>
<td style="text-align:left;">
pbcwalk
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
pbswalk
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
pbszone
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
pcrash4
</td>
<td style="text-align:left;">
Tracking
</td>
<td style="text-align:left;">
Tracking
</td>
<td style="text-align:left;">
Tracking
</td>
<td style="text-align:left;">
Tracking
</td>
<td style="text-align:left;">
Skidding longitudinally rotation less than 30 degrees
</td>
</tr>
<tr>
<td style="text-align:left;">
pcrash5
</td>
<td style="text-align:left;">
Stayed on roadway, but left original travel lane
</td>
<td style="text-align:left;">
Stayed in original travel lane
</td>
<td style="text-align:left;">
Stayed in original travel lane
</td>
<td style="text-align:left;">
Stayed in original travel lane
</td>
<td style="text-align:left;">
Departed roadway
</td>
</tr>
<tr>
<td style="text-align:left;">
pedcgp
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
pedctype
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
peddir
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
pedleg
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
pedloc
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
pedpos
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
peds
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
pedsnr
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
per_typ
</td>
<td style="text-align:left;">
Driver of a Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Driver of a Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Passenger of a Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Driver of a Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Driver of a Motor Vehicle In-Transport
</td>
</tr>
<tr>
<td style="text-align:left;">
permvit
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
pernotmvit
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
persons
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
prev_acc
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
</tr>
<tr>
<td style="text-align:left;">
prev_dwi
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
</tr>
<tr>
<td style="text-align:left;">
prev_oth
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
prev_spd
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
</tr>
<tr>
<td style="text-align:left;">
prev_sus1
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
</tr>
<tr>
<td style="text-align:left;">
prev_sus2
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
</tr>
<tr>
<td style="text-align:left;">
prev_sus3
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
</tr>
<tr>
<td style="text-align:left;">
pvh_invl
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
rail
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
rd_owner
</td>
<td style="text-align:left;">
State Highway Agency
</td>
<td style="text-align:left;">
State Highway Agency
</td>
<td style="text-align:left;">
State Highway Agency
</td>
<td style="text-align:left;">
State Highway Agency
</td>
<td style="text-align:left;">
County Highway Agency
</td>
</tr>
<tr>
<td style="text-align:left;">
reg_stat
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Ohio
</td>
</tr>
<tr>
<td style="text-align:left;">
rel_road
</td>
<td style="text-align:left;">
On Roadway
</td>
<td style="text-align:left;">
On Roadway
</td>
<td style="text-align:left;">
On Roadway
</td>
<td style="text-align:left;">
On Roadway
</td>
<td style="text-align:left;">
On Roadside
</td>
</tr>
<tr>
<td style="text-align:left;">
reljct1
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
No
</td>
</tr>
<tr>
<td style="text-align:left;">
reljct2
</td>
<td style="text-align:left;">
Intersection
</td>
<td style="text-align:left;">
Intersection
</td>
<td style="text-align:left;">
Intersection
</td>
<td style="text-align:left;">
Intersection
</td>
<td style="text-align:left;">
Non-Junction
</td>
</tr>
<tr>
<td style="text-align:left;">
rest_mis
</td>
<td style="text-align:left;">
No Indication of Misuse
</td>
<td style="text-align:left;">
No Indication of Misuse
</td>
<td style="text-align:left;">
None Used/Not Applicable
</td>
<td style="text-align:left;">
None Used/Not Applicable
</td>
<td style="text-align:left;">
None Used/Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
rest_use
</td>
<td style="text-align:left;">
Shoulder and Lap Belt Used
</td>
<td style="text-align:left;">
Shoulder and Lap Belt Used
</td>
<td style="text-align:left;">
Reported as Unknown
</td>
<td style="text-align:left;">
None Used/Not Applicable
</td>
<td style="text-align:left;">
None Used/Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
rolinloc
</td>
<td style="text-align:left;">
No Rollover
</td>
<td style="text-align:left;">
No Rollover
</td>
<td style="text-align:left;">
No Rollover
</td>
<td style="text-align:left;">
No Rollover
</td>
<td style="text-align:left;">
On Roadside
</td>
</tr>
<tr>
<td style="text-align:left;">
rollover
</td>
<td style="text-align:left;">
No Rollover
</td>
<td style="text-align:left;">
No Rollover
</td>
<td style="text-align:left;">
No Rollover
</td>
<td style="text-align:left;">
No Rollover
</td>
<td style="text-align:left;">
Rollover
</td>
</tr>
<tr>
<td style="text-align:left;">
route
</td>
<td style="text-align:left;">
U.S. Highway
</td>
<td style="text-align:left;">
U.S. Highway
</td>
<td style="text-align:left;">
U.S. Highway
</td>
<td style="text-align:left;">
U.S. Highway
</td>
<td style="text-align:left;">
County
</td>
</tr>
<tr>
<td style="text-align:left;">
rur_urb
</td>
<td style="text-align:left;">
Urban
</td>
<td style="text-align:left;">
Urban
</td>
<td style="text-align:left;">
Urban
</td>
<td style="text-align:left;">
Urban
</td>
<td style="text-align:left;">
Rural
</td>
</tr>
<tr>
<td style="text-align:left;">
sch_bus
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
</tr>
<tr>
<td style="text-align:left;">
seat_pos
</td>
<td style="text-align:left;">
Front Seat, Left Side
</td>
<td style="text-align:left;">
Front Seat, Left Side
</td>
<td style="text-align:left;">
Second Seat, Right Side
</td>
<td style="text-align:left;">
Front Seat, Left Side
</td>
<td style="text-align:left;">
Front Seat, Left Side
</td>
</tr>
<tr>
<td style="text-align:left;">
sex
</td>
<td style="text-align:left;">
Male
</td>
<td style="text-align:left;">
Female
</td>
<td style="text-align:left;">
Male
</td>
<td style="text-align:left;">
Female
</td>
<td style="text-align:left;">
Male
</td>
</tr>
<tr>
<td style="text-align:left;">
sp_jur
</td>
<td style="text-align:left;">
No Special Jurisdiction
</td>
<td style="text-align:left;">
No Special Jurisdiction
</td>
<td style="text-align:left;">
No Special Jurisdiction
</td>
<td style="text-align:left;">
No Special Jurisdiction
</td>
<td style="text-align:left;">
No Special Jurisdiction
</td>
</tr>
<tr>
<td style="text-align:left;">
spec_use
</td>
<td style="text-align:left;">
No Special Use Noted
</td>
<td style="text-align:left;">
No Special Use Noted
</td>
<td style="text-align:left;">
No Special Use Noted
</td>
<td style="text-align:left;">
No Special Use Noted
</td>
<td style="text-align:left;">
No Special Use Noted
</td>
</tr>
<tr>
<td style="text-align:left;">
speedrel
</td>
<td style="text-align:left;">
Yes, Specifics Unknown
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
</tr>
<tr>
<td style="text-align:left;">
statename
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
Ohio
</td>
</tr>
<tr>
<td style="text-align:left;">
str_veh
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
tow_veh
</td>
<td style="text-align:left;">
No Trailers
</td>
<td style="text-align:left;">
No Trailers
</td>
<td style="text-align:left;">
No Trailers
</td>
<td style="text-align:left;">
No Trailers
</td>
<td style="text-align:left;">
No Trailers
</td>
</tr>
<tr>
<td style="text-align:left;">
towed
</td>
<td style="text-align:left;">
Towed
</td>
<td style="text-align:left;">
Towed
</td>
<td style="text-align:left;">
Towed
</td>
<td style="text-align:left;">
Towed
</td>
<td style="text-align:left;">
Towed
</td>
</tr>
<tr>
<td style="text-align:left;">
trav_sp
</td>
<td style="text-align:left;">
Not Reported
</td>
<td style="text-align:left;">
Not Reported
</td>
<td style="text-align:left;">
Not Reported
</td>
<td style="text-align:left;">
Not Reported
</td>
<td style="text-align:left;">
Reported as Unknown
</td>
</tr>
<tr>
<td style="text-align:left;">
trlr1gvwr
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
</tr>
<tr>
<td style="text-align:left;">
trlr1vin
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
</tr>
<tr>
<td style="text-align:left;">
trlr2gvwr
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
</tr>
<tr>
<td style="text-align:left;">
trlr2vin
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
</tr>
<tr>
<td style="text-align:left;">
trlr3gvwr
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
</tr>
<tr>
<td style="text-align:left;">
trlr3vin
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
<td style="text-align:left;">
No Trailing Units
</td>
</tr>
<tr>
<td style="text-align:left;">
tway_id
</td>
<td style="text-align:left;">
US-278 SR-12 COVINGTON HWY
</td>
<td style="text-align:left;">
US-278 SR-12 COVINGTON HWY
</td>
<td style="text-align:left;">
US-278 SR-12 COVINGTON HWY
</td>
<td style="text-align:left;">
US-278 SR-12 COVINGTON HWY
</td>
<td style="text-align:left;">
CR-9 KINGSTON PI
</td>
</tr>
<tr>
<td style="text-align:left;">
tway_id2
</td>
<td style="text-align:left;">
S INDIAN CREEK DRIVE
</td>
<td style="text-align:left;">
S INDIAN CREEK DRIVE
</td>
<td style="text-align:left;">
S INDIAN CREEK DRIVE
</td>
<td style="text-align:left;">
S INDIAN CREEK DRIVE
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
typ_int
</td>
<td style="text-align:left;">
T-Intersection
</td>
<td style="text-align:left;">
T-Intersection
</td>
<td style="text-align:left;">
T-Intersection
</td>
<td style="text-align:left;">
T-Intersection
</td>
<td style="text-align:left;">
Not an Intersection
</td>
</tr>
<tr>
<td style="text-align:left;">
underoverride
</td>
<td style="text-align:left;">
No Underride or Override
</td>
<td style="text-align:left;">
No Underride or Override
</td>
<td style="text-align:left;">
No Underride or Override
</td>
<td style="text-align:left;">
No Underride or Override
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
unittype
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport (Inside or Outside the Trafficway)
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport (Inside or Outside the Trafficway)
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport (Inside or Outside the Trafficway)
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport (Inside or Outside the Trafficway)
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport (Inside or Outside the Trafficway)
</td>
</tr>
<tr>
<td style="text-align:left;">
v_config
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
Not Applicable
</td>
</tr>
<tr>
<td style="text-align:left;">
valign
</td>
<td style="text-align:left;">
Straight
</td>
<td style="text-align:left;">
Straight
</td>
<td style="text-align:left;">
Straight
</td>
<td style="text-align:left;">
Straight
</td>
<td style="text-align:left;">
Curve - Right
</td>
</tr>
<tr>
<td style="text-align:left;">
ve_forms
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
ve_total
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
vin
</td>
<td style="text-align:left;">
1FADP3K2XFL3
</td>
<td style="text-align:left;">
1N4BL4DV9KC1
</td>
<td style="text-align:left;">
1N4BL4DV9KC1
</td>
<td style="text-align:left;">
2HKRM3H73GH5
</td>
<td style="text-align:left;">
1GNDV23L55D2
</td>
</tr>
<tr>
<td style="text-align:left;">
vnum_lan
</td>
<td style="text-align:left;">
Five lanes
</td>
<td style="text-align:left;">
Three lanes
</td>
<td style="text-align:left;">
Three lanes
</td>
<td style="text-align:left;">
Five lanes
</td>
<td style="text-align:left;">
Two lanes
</td>
</tr>
<tr>
<td style="text-align:left;">
vpavetyp
</td>
<td style="text-align:left;">
Blacktop, Bituminous, or Asphalt
</td>
<td style="text-align:left;">
Blacktop, Bituminous, or Asphalt
</td>
<td style="text-align:left;">
Blacktop, Bituminous, or Asphalt
</td>
<td style="text-align:left;">
Blacktop, Bituminous, or Asphalt
</td>
<td style="text-align:left;">
Blacktop, Bituminous, or Asphalt
</td>
</tr>
<tr>
<td style="text-align:left;">
vpicbodyclass
</td>
<td style="text-align:left;">
5
</td>
<td style="text-align:left;">
13
</td>
<td style="text-align:left;">
13
</td>
<td style="text-align:left;">
7
</td>
<td style="text-align:left;">
2
</td>
</tr>
<tr>
<td style="text-align:left;">
vpicmake
</td>
<td style="text-align:left;">
460
</td>
<td style="text-align:left;">
478
</td>
<td style="text-align:left;">
478
</td>
<td style="text-align:left;">
474
</td>
<td style="text-align:left;">
467
</td>
</tr>
<tr>
<td style="text-align:left;">
vpicmodel
</td>
<td style="text-align:left;">
1779
</td>
<td style="text-align:left;">
1904
</td>
<td style="text-align:left;">
1904
</td>
<td style="text-align:left;">
1865
</td>
<td style="text-align:left;">
4588
</td>
</tr>
<tr>
<td style="text-align:left;">
vprofile
</td>
<td style="text-align:left;">
Level
</td>
<td style="text-align:left;">
Level
</td>
<td style="text-align:left;">
Level
</td>
<td style="text-align:left;">
Level
</td>
<td style="text-align:left;">
Grade, Unknown Slope
</td>
</tr>
<tr>
<td style="text-align:left;">
vspd_lim
</td>
<td style="text-align:left;">
45 MPH
</td>
<td style="text-align:left;">
35 MPH
</td>
<td style="text-align:left;">
35 MPH
</td>
<td style="text-align:left;">
45 MPH
</td>
<td style="text-align:left;">
55 MPH
</td>
</tr>
<tr>
<td style="text-align:left;">
vsurcond
</td>
<td style="text-align:left;">
Dry
</td>
<td style="text-align:left;">
Dry
</td>
<td style="text-align:left;">
Dry
</td>
<td style="text-align:left;">
Dry
</td>
<td style="text-align:left;">
Dry
</td>
</tr>
<tr>
<td style="text-align:left;">
vtcont_f
</td>
<td style="text-align:left;">
Device Functioning Properly
</td>
<td style="text-align:left;">
Device Functioning Properly
</td>
<td style="text-align:left;">
Device Functioning Properly
</td>
<td style="text-align:left;">
Device Functioning Properly
</td>
<td style="text-align:left;">
No Controls
</td>
</tr>
<tr>
<td style="text-align:left;">
vtrafcon
</td>
<td style="text-align:left;">
Traffic control signal(on colors) not known whether or not Pedestrian
Signal
</td>
<td style="text-align:left;">
Traffic control signal(on colors) not known whether or not Pedestrian
Signal
</td>
<td style="text-align:left;">
Traffic control signal(on colors) not known whether or not Pedestrian
Signal
</td>
<td style="text-align:left;">
Traffic control signal(on colors) not known whether or not Pedestrian
Signal
</td>
<td style="text-align:left;">
No Controls
</td>
</tr>
<tr>
<td style="text-align:left;">
vtrafway
</td>
<td style="text-align:left;">
Two-Way, Not Divided With a Continuous Left-Turn Lane
</td>
<td style="text-align:left;">
Two-Way, Not Divided
</td>
<td style="text-align:left;">
Two-Way, Not Divided
</td>
<td style="text-align:left;">
Two-Way, Not Divided With a Continuous Left-Turn Lane
</td>
<td style="text-align:left;">
Two-Way, Not Divided
</td>
</tr>
<tr>
<td style="text-align:left;">
work_inj
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
Not Applicable (not a fatality)
</td>
<td style="text-align:left;">
Not Applicable (not a fatality)
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
</td>
</tr>
<tr>
<td style="text-align:left;">
wrk_zone
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
None
</td>
</tr>
<tr>
<td style="text-align:left;">
a1
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
a2
</td>
<td style="text-align:left;">
45
</td>
<td style="text-align:left;">
45
</td>
<td style="text-align:left;">
45
</td>
<td style="text-align:left;">
45
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
a3
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
a4
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
a5
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
a6
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
a7
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
a8
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
a9
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
a10
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
19
</td>
</tr>
<tr>
<td style="text-align:left;">
p1
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
p2
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
45
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
p3
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
p4
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
p5
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
p6
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
p7
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
p8
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
p9
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
p10
</td>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
9
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
19
</td>
</tr>
</tbody>
</table>

The `multi_` dataframes contain those variables for which there may be a
varying number of values for any entity (e.g., driver impairments,
vehicle events, weather conditions at time of crash). Each dataframe has
the requisite data elements corresponding to the entity: `multi_acc`
includes `st_case` and `year`, `multi_veh` adds `veh_no` (vehicle
number), and `multi_per` adds `per_no` (person number).

<table>
<caption>
The ‘multi_acc’ dataframe
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
name
</th>
<th style="text-align:left;">
value
</th>
<th style="text-align:left;">
year
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
weather
</td>
<td style="text-align:left;">
Clear
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
weather
</td>
<td style="text-align:left;">
Clear
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:left;">
2024
</td>
</tr>
</tbody>
</table>
<table>
<caption>
The ‘multi_veh’ dataframe
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
name
</th>
<th style="text-align:left;">
value
</th>
<th style="text-align:left;">
year
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
weather
</td>
<td style="text-align:left;">
Clear
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
weather
</td>
<td style="text-align:left;">
Clear
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
crashrf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:left;">
2024
</td>
</tr>
</tbody>
</table>
<table>
<caption>
The ‘multi_per’ dataframe
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
per_no
</th>
<th style="text-align:left;">
name
</th>
<th style="text-align:left;">
value
</th>
<th style="text-align:left;">
year
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
personrf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
personrf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
personrf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
personrf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
multrace
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
order
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
race
</td>
<td style="text-align:left;">
Black or African American
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
multrace
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
order
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
race
</td>
<td style="text-align:left;">
Not a Fatality (not applicable)
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
multrace
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
order
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
race
</td>
<td style="text-align:left;">
Not a Fatality (not applicable)
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
multrace
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
order
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
race
</td>
<td style="text-align:left;">
Black or African American
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Other Screening Test Method \[Specify:\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Presumptive Positive
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Narcotic Analgesics, Type Unknown \[Opioids/Opiates\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Mass Spectrometry \[LC/MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Tested for Drugs, Drugs Detected, Unknown Quantity
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Cocaethylene (ethylbenzoylecgonine)
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
0.1
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Mass Spectrometry \[LC/MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Actual Drug Quantity
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Benzoylecgonine
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
mg/L
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Mass Spectrometry \[LC/MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Actual Drug Quantity
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Delta 9-tetrahydrocannabinol \[THC\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
ng/mL
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Other Screening Test Method \[Specify:\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
None Detected/Below Threshold
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
None Detected/Below Threshold
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Mass Spectrometry \[LC/MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
None Detected/Below Threshold
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
None Detected/Below Threshold
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
personrf
</td>
<td style="text-align:left;">
None Noted
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
multrace
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
order
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
race
</td>
<td style="text-align:left;">
White
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Time of Flight-Mass Spectrometry \[LC/TOF-MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Presumptive Positive
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Amlodipine
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Time of Flight-Mass Spectrometry \[LC/TOF-MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Presumptive Positive
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Caffeine
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Time of Flight-Mass Spectrometry \[LC/TOF-MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Presumptive Positive
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Cotinine
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Time of Flight-Mass Spectrometry \[LC/TOF-MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Presumptive Positive
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Nicotine
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
Not Applicable
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
3.4
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Tandem Mass Spectrometry \[LC/MS-MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Actual Drug Quantity
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Buprenorphine
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
ng/mL
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
2.3
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Tandem Mass Spectrometry \[LC/MS-MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Actual Drug Quantity
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Norbuprenorphine
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
ng/mL
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
130
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Tandem Mass Spectrometry \[LC/MS-MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Actual Drug Quantity
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Diphenhydramine
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
ng/mL
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugactqty
</td>
<td style="text-align:left;">
8.4
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugmethod
</td>
<td style="text-align:left;">
Liquid Chromatography/Tandem Mass Spectrometry \[LC/MS-MS\]
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugqty
</td>
<td style="text-align:left;">
Actual Drug Quantity
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres
</td>
<td style="text-align:left;">
Lorazepam
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugspec
</td>
<td style="text-align:left;">
Whole Blood
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
druguom
</td>
<td style="text-align:left;">
ng/mL
</td>
<td style="text-align:left;">
2024
</td>
</tr>
</tbody>
</table>

The `events` dataframe provides a sequence of events for each vehicle in
each crash. See the vignette(“Crash Sequence of Events”, package =
“rfars”) for more information.

<table>
<caption>
The ‘events’ dataframe
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
Georgia
</td>
<td style="text-align:left;">
130177
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
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
Right-Back Side
</td>
<td style="text-align:left;">
Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
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
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
130177
</td>
<td style="text-align:left;">
3
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
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
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
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
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
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
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
2024
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
390256
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
2024
</td>
</tr>
</tbody>
</table>

The `codebook` dataframe provides a searchable codebook for the data,
useful if you know what concept you’re looking for but not the variable
that describes it. `rfars` also includes pre-loaded codebooks for FARS
and GESCRSS (`rfars::fars_codebook` and `rfars::gescrss_codebook`). See
`vignette('Searchable Codebooks', package = 'rfars')` for more
information.

## Counts

See `vignette("Counts", package = "rfars")` for information on the
pre-loaded `annual_counts` dataframe and the `counts()` and
`compare_counts()` functions. Also see
`vignette("Alcohol Counts", package = "rfars")` for details on how BAC
values are imputed and reported in *Traffic Safety Facts*.

## Helpful Links

- [National Highway Traffic Safety Administration
  (NHTSA)](https://www.nhtsa.gov/)
- [Fatality Analysis Reporting System
  (FARS)](https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars)
- [Fatality and Injury Reporting System Tool
  (FIRST)](https://cdan.dot.gov/query)
- [FARS Analytical User’s
  Manual](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813794)
- [General Estimates System
  (GES)](https://www.nhtsa.gov/national-automotive-sampling-system/nass-general-estimates-system)
- [Crash Report Sampling System
  (CRSS)](https://www.nhtsa.gov/crash-data-systems/crash-report-sampling-system)
- [CRSS Analytical User’s
  Manual](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813796)
- [NCSA and Other Data
  Sources](https://cdan.dot.gov/Homepage/MotorVehicleCrashDataOverview.htm)
- [NHTSA FTP
  Site](https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/)
