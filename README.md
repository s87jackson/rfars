
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
2014
</td>
<td style="text-align:left;">
2014
</td>
<td style="text-align:left;">
2014
</td>
<td style="text-align:left;">
2014
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
state
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
South Dakota
</td>
</tr>
<tr>
<td style="text-align:left;">
st_case
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
460097
</td>
</tr>
<tr>
<td style="text-align:left;">
id
</td>
<td style="text-align:left;">
2014270304
</td>
<td style="text-align:left;">
2014270304
</td>
<td style="text-align:left;">
2014270304
</td>
<td style="text-align:left;">
2014460097
</td>
<td style="text-align:left;">
2014460097
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
1
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
2
</td>
</tr>
<tr>
<td style="text-align:left;">
county
</td>
<td style="text-align:left;">
113
</td>
<td style="text-align:left;">
113
</td>
<td style="text-align:left;">
113
</td>
<td style="text-align:left;">
11
</td>
<td style="text-align:left;">
11
</td>
</tr>
<tr>
<td style="text-align:left;">
city
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
lon
</td>
<td style="text-align:left;">
-96.20801
</td>
<td style="text-align:left;">
-96.20801
</td>
<td style="text-align:left;">
-96.20801
</td>
<td style="text-align:left;">
-96.64642
</td>
<td style="text-align:left;">
-96.64642
</td>
</tr>
<tr>
<td style="text-align:left;">
lat
</td>
<td style="text-align:left;">
48.15133
</td>
<td style="text-align:left;">
48.15133
</td>
<td style="text-align:left;">
48.15133
</td>
<td style="text-align:left;">
44.23894
</td>
<td style="text-align:left;">
44.23894
</td>
</tr>
<tr>
<td style="text-align:left;">
acc_type
</td>
<td style="text-align:left;">
Initial Opposite Directions (Left/Right)
</td>
<td style="text-align:left;">
Initial Opposite Directions (Going Straight)
</td>
<td style="text-align:left;">
Initial Opposite Directions (Going Straight)
</td>
<td style="text-align:left;">
Drive Off Road
</td>
<td style="text-align:left;">
Drive Off Road
</td>
</tr>
<tr>
<td style="text-align:left;">
age
</td>
<td style="text-align:left;">
68 Years
</td>
<td style="text-align:left;">
58 Years
</td>
<td style="text-align:left;">
83 Years
</td>
<td style="text-align:left;">
28 Years
</td>
<td style="text-align:left;">
24 Years
</td>
</tr>
<tr>
<td style="text-align:left;">
air_bag
</td>
<td style="text-align:left;">
Deployed- Front
</td>
<td style="text-align:left;">
Deployed- Front
</td>
<td style="text-align:left;">
Deployed- Front
</td>
<td style="text-align:left;">
Deployed- Front
</td>
<td style="text-align:left;">
Deployed- Front
</td>
</tr>
<tr>
<td style="text-align:left;">
alc_det
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
Not Reported
</td>
</tr>
<tr>
<td style="text-align:left;">
alc_res
</td>
<td style="text-align:left;">
0.00 % BAC
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
Not Reported
</td>
<td style="text-align:left;">
0.25 % BAC
</td>
<td style="text-align:left;">
Unknown if tested
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
Not Reported
</td>
<td style="text-align:left;">
Test Given
</td>
<td style="text-align:left;">
UnKnown if Tested
</td>
</tr>
<tr>
<td style="text-align:left;">
arr_hour
</td>
<td style="text-align:left;">
6:00pm-6:59pm
</td>
<td style="text-align:left;">
6:00pm-6:59pm
</td>
<td style="text-align:left;">
6:00pm-6:59pm
</td>
<td style="text-align:left;">
Unknown EMS Scene Arrival Hour
</td>
<td style="text-align:left;">
Unknown EMS Scene Arrival Hour
</td>
</tr>
<tr>
<td style="text-align:left;">
arr_min
</td>
<td style="text-align:left;">
21
</td>
<td style="text-align:left;">
21
</td>
<td style="text-align:left;">
21
</td>
<td style="text-align:left;">
Unknown EMS Scene Arrival Minutes
</td>
<td style="text-align:left;">
Unknown EMS Scene Arrival Minutes
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
Not Reported
</td>
<td style="text-align:left;">
Unknown Test Type
</td>
<td style="text-align:left;">
Unknown if Tested
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
Minivan (Chrysler Town and Country, Caravan, Grand Caravan, Voyager,
Voyager, Honda-Odyssey, …)
</td>
<td style="text-align:left;">
4-door sedan, hardtop
</td>
<td style="text-align:left;">
4-door sedan, hardtop
</td>
<td style="text-align:left;">
4-door sedan, hardtop
</td>
<td style="text-align:left;">
4-door sedan, hardtop
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
Valid
</td>
<td style="text-align:left;">
Valid
</td>
</tr>
<tr>
<td style="text-align:left;">
cert_no
</td>
<td style="text-align:left;">
\*\*\*\*\*\*\*\*\*\*\*\*
</td>
<td style="text-align:left;">
\*\*\*\*\*\*\*\*\*\*\*\*
</td>
<td style="text-align:left;">
\*\*\*\*\*\*\*\*\*\*\*\*
</td>
<td style="text-align:left;">
\*\*\*\*\*\*\*\*\*\*\*\*
</td>
<td style="text-align:left;">
\*\*\*\*\*\*\*\*\*\*\*\*
</td>
</tr>
<tr>
<td style="text-align:left;">
day
</td>
<td style="text-align:left;">
11
</td>
<td style="text-align:left;">
11
</td>
<td style="text-align:left;">
11
</td>
<td style="text-align:left;">
28
</td>
<td style="text-align:left;">
28
</td>
</tr>
<tr>
<td style="text-align:left;">
day_week
</td>
<td style="text-align:left;">
Thursday
</td>
<td style="text-align:left;">
Thursday
</td>
<td style="text-align:left;">
Thursday
</td>
<td style="text-align:left;">
Sunday
</td>
<td style="text-align:left;">
Sunday
</td>
</tr>
<tr>
<td style="text-align:left;">
death_da
</td>
<td style="text-align:left;">
Not Applicable (Non-Fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-Fatal)
</td>
<td style="text-align:left;">
11
</td>
<td style="text-align:left;">
Not Applicable (Non-Fatal)
</td>
<td style="text-align:left;">
28
</td>
</tr>
<tr>
<td style="text-align:left;">
death_hr
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
20:00-20:59
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
1:00-1:59
</td>
</tr>
<tr>
<td style="text-align:left;">
death_mn
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
5
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
6
</td>
</tr>
<tr>
<td style="text-align:left;">
death_mo
</td>
<td style="text-align:left;">
Not Applicable (Non-Fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-Fatal)
</td>
<td style="text-align:left;">
December
</td>
<td style="text-align:left;">
Not Applicable (Non-Fatal)
</td>
<td style="text-align:left;">
September
</td>
</tr>
<tr>
<td style="text-align:left;">
death_tm
</td>
<td style="text-align:left;">
8888
</td>
<td style="text-align:left;">
8888
</td>
<td style="text-align:left;">
2005
</td>
<td style="text-align:left;">
8888
</td>
<td style="text-align:left;">
106
</td>
</tr>
<tr>
<td style="text-align:left;">
death_yr
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
2014
</td>
<td style="text-align:left;">
Not Applicable (Non-fatal)
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
deaths
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
No
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
No
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
dr_hgt
</td>
<td style="text-align:left;">
69
</td>
<td style="text-align:left;">
59
</td>
<td style="text-align:left;">
59
</td>
<td style="text-align:left;">
999
</td>
<td style="text-align:left;">
999
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
200 lbs.
</td>
<td style="text-align:left;">
250 lbs.
</td>
<td style="text-align:left;">
250 lbs.
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
</tr>
<tr>
<td style="text-align:left;">
dr_zip
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
drinking
</td>
<td style="text-align:left;">
Unknown (Police Reported)
</td>
<td style="text-align:left;">
No (Alcohol Not Involved)
</td>
<td style="text-align:left;">
Not Reported
</td>
<td style="text-align:left;">
Yes (Alcohol Involved)
</td>
<td style="text-align:left;">
Not Reported
</td>
</tr>
<tr>
<td style="text-align:left;">
drug_det
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
Not Reported
</td>
</tr>
<tr>
<td style="text-align:left;">
drugs
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
No (drugs not involved)
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
</tr>
<tr>
<td style="text-align:left;">
drunk_dr
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
1
</td>
<td style="text-align:left;">
1
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
Not Reported
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
Unknown if Tested
</td>
</tr>
<tr>
<td style="text-align:left;">
ej_path
</td>
<td style="text-align:left;">
Not Ejected/Not Applicable
</td>
<td style="text-align:left;">
Not Ejected/Not Applicable
</td>
<td style="text-align:left;">
Not Ejected/Not Applicable
</td>
<td style="text-align:left;">
Not Ejected/Not Applicable
</td>
<td style="text-align:left;">
Through Side Window
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
Unknown
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
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
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
No Record
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
No Record
</td>
</tr>
<tr>
<td style="text-align:left;">
first_yr
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
No Record
</td>
<td style="text-align:left;">
No Record
</td>
</tr>
<tr>
<td style="text-align:left;">
gvwr
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
Other Post, Other Pole or Other Supports
</td>
<td style="text-align:left;">
Other Post, Other Pole or Other Supports
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
hispanic
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
Not A Fatality (not Applicable)
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
6:00pm-6:59pm
</td>
<td style="text-align:left;">
6:00pm-6:59pm
</td>
<td style="text-align:left;">
6:00pm-6:59pm
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
</tr>
<tr>
<td style="text-align:left;">
hosp_mn
</td>
<td style="text-align:left;">
47
</td>
<td style="text-align:left;">
47
</td>
<td style="text-align:left;">
47
</td>
<td style="text-align:left;">
Unknown EMS Hospital Arrival Time
</td>
<td style="text-align:left;">
Unknown EMS Hospital Arrival Time
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
EMS Ground
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
6:00pm-6:59pm
</td>
<td style="text-align:left;">
6:00pm-6:59pm
</td>
<td style="text-align:left;">
6:00pm-6:59pm
</td>
<td style="text-align:left;">
0:00am-0:59am
</td>
<td style="text-align:left;">
0:00am-0:59am
</td>
</tr>
<tr>
<td style="text-align:left;">
impact1
</td>
<td style="text-align:left;">
1 Clock Point
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
</tr>
<tr>
<td style="text-align:left;">
inj_sev
</td>
<td style="text-align:left;">
Suspected Serious Injury(A)
</td>
<td style="text-align:left;">
Suspected Serious Injury(A)
</td>
<td style="text-align:left;">
Fatal Injury (K)
</td>
<td style="text-align:left;">
Suspected Serious Injury(A)
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
Restrictions, Compliance Unknown
</td>
<td style="text-align:left;">
Restrictions, Compliance Unknown
</td>
<td style="text-align:left;">
Restrictions, Compliance Unknown
</td>
<td style="text-align:left;">
Restrictions Complied With
</td>
<td style="text-align:left;">
Restrictions Complied With
</td>
</tr>
<tr>
<td style="text-align:left;">
l_state
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
Minnesota
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
999
</td>
<td style="text-align:left;">
999
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
999
</td>
<td style="text-align:left;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
lag_mins
</td>
<td style="text-align:left;">
99
</td>
<td style="text-align:left;">
99
</td>
<td style="text-align:left;">
53
</td>
<td style="text-align:left;">
99
</td>
<td style="text-align:left;">
51
</td>
</tr>
<tr>
<td style="text-align:left;">
last_mo
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
No Record
</td>
<td style="text-align:left;">
No Record
</td>
</tr>
<tr>
<td style="text-align:left;">
last_yr
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
No Record
</td>
<td style="text-align:left;">
No Record
</td>
</tr>
<tr>
<td style="text-align:left;">
lgt_cond
</td>
<td style="text-align:left;">
Dark - Not Lighted
</td>
<td style="text-align:left;">
Dark - Not Lighted
</td>
<td style="text-align:left;">
Dark - Not Lighted
</td>
<td style="text-align:left;">
Dark - Not Lighted
</td>
<td style="text-align:left;">
Dark - Not Lighted
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
Rollover/Overturn
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
Dodge Caravan/Grand Caravan
</td>
<td style="text-align:left;">
Ford Taurus/Taurus X
</td>
<td style="text-align:left;">
Ford Taurus/Taurus X
</td>
<td style="text-align:left;">
Chevrolet Lumina
</td>
<td style="text-align:left;">
Chevrolet Lumina
</td>
</tr>
<tr>
<td style="text-align:left;">
make
</td>
<td style="text-align:left;">
Dodge
</td>
<td style="text-align:left;">
Ford
</td>
<td style="text-align:left;">
Ford
</td>
<td style="text-align:left;">
Chevrolet
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
Angle
</td>
<td style="text-align:left;">
Angle
</td>
<td style="text-align:left;">
Angle
</td>
<td style="text-align:left;">
Not a Collision with Motor Vehicle In-Transport
</td>
<td style="text-align:left;">
Not a Collision with Motor Vehicle In-Transport
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
minute
</td>
<td style="text-align:left;">
12
</td>
<td style="text-align:left;">
12
</td>
<td style="text-align:left;">
12
</td>
<td style="text-align:left;">
15
</td>
<td style="text-align:left;">
15
</td>
</tr>
<tr>
<td style="text-align:left;">
mod_year
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
model
</td>
<td style="text-align:left;">
442
</td>
<td style="text-align:left;">
17
</td>
<td style="text-align:left;">
17
</td>
<td style="text-align:left;">
20
</td>
<td style="text-align:left;">
20
</td>
</tr>
<tr>
<td style="text-align:left;">
month
</td>
<td style="text-align:left;">
December
</td>
<td style="text-align:left;">
December
</td>
<td style="text-align:left;">
December
</td>
<td style="text-align:left;">
September
</td>
<td style="text-align:left;">
September
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
msafeqmt
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
This section IS NOT on the NHS
</td>
<td style="text-align:left;">
This section IS NOT on the NHS
</td>
<td style="text-align:left;">
This section IS NOT on the NHS
</td>
<td style="text-align:left;">
This section IS NOT on the NHS
</td>
<td style="text-align:left;">
This section IS NOT on the NHS
</td>
</tr>
<tr>
<td style="text-align:left;">
not_hour
</td>
<td style="text-align:left;">
6:00pm-6:59pm
</td>
<td style="text-align:left;">
6:00pm-6:59pm
</td>
<td style="text-align:left;">
6:00pm-6:59pm
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
</td>
</tr>
<tr>
<td style="text-align:left;">
not_min
</td>
<td style="text-align:left;">
12
</td>
<td style="text-align:left;">
12
</td>
<td style="text-align:left;">
12
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
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
02
</td>
<td style="text-align:left;">
02
</td>
</tr>
<tr>
<td style="text-align:left;">
owner
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
<td style="text-align:left;">
Driver (in this crash) Not Registered Owner (Other Private Owner Listed)
</td>
<td style="text-align:left;">
Driver (in this crash) Not Registered Owner (Other Private Owner Listed)
</td>
</tr>
<tr>
<td style="text-align:left;">
p_crash1
</td>
<td style="text-align:left;">
Turning Left
</td>
<td style="text-align:left;">
Going Straight
</td>
<td style="text-align:left;">
Going Straight
</td>
<td style="text-align:left;">
Going Straight
</td>
<td style="text-align:left;">
Going Straight
</td>
</tr>
<tr>
<td style="text-align:left;">
p_crash2
</td>
<td style="text-align:left;">
Turning left at junction
</td>
<td style="text-align:left;">
From opposite direction over left lane line
</td>
<td style="text-align:left;">
From opposite direction over left lane line
</td>
<td style="text-align:left;">
Over the lane line on right side of travel lane
</td>
<td style="text-align:left;">
Over the lane line on right side of travel lane
</td>
</tr>
<tr>
<td style="text-align:left;">
p_crash3
</td>
<td style="text-align:left;">
No Avoidance Maneuver
</td>
<td style="text-align:left;">
Steering right
</td>
<td style="text-align:left;">
Steering right
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
Unknown
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
Tracking
</td>
</tr>
<tr>
<td style="text-align:left;">
pcrash5
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
Passenger of a Motor Vehicle In-Transport
</td>
</tr>
<tr>
<td style="text-align:left;">
permvit
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
2
</td>
<td style="text-align:left;">
2
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
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
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
prev_sus
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
race
</td>
<td style="text-align:left;">
Not a Fatality (not Applicable)
</td>
<td style="text-align:left;">
Not a Fatality (not Applicable)
</td>
<td style="text-align:left;">
White
</td>
<td style="text-align:left;">
Not a Fatality (not Applicable)
</td>
<td style="text-align:left;">
White
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
reg_stat
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
Minnesota
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
On Roadside
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
Non-Junction
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
rest_use
</td>
<td style="text-align:left;">
Shoulder and Lap Belt Used
</td>
<td style="text-align:left;">
Shoulder and Lap Belt Used
</td>
<td style="text-align:left;">
Unknown
</td>
<td style="text-align:left;">
None Used
</td>
<td style="text-align:left;">
None Used
</td>
</tr>
<tr>
<td style="text-align:left;">
road_fnc
</td>
<td style="text-align:left;">
Rural-Minor Arterial
</td>
<td style="text-align:left;">
Rural-Minor Arterial
</td>
<td style="text-align:left;">
Rural-Minor Arterial
</td>
<td style="text-align:left;">
Rural-Major Collector
</td>
<td style="text-align:left;">
Rural-Major Collector
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
On Roadside
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
Rollover, Tripped by Object/Vehicle
</td>
<td style="text-align:left;">
Rollover, Tripped by Object/Vehicle
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
State Highway
</td>
<td style="text-align:left;">
State Highway
</td>
</tr>
<tr>
<td style="text-align:left;">
rur_urb
</td>
<td style="text-align:left;">
Rural
</td>
<td style="text-align:left;">
Rural
</td>
<td style="text-align:left;">
Rural
</td>
<td style="text-align:left;">
Rural
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
Front Seat, Right Side
</td>
<td style="text-align:left;">
Front Seat, Left Side
</td>
<td style="text-align:left;">
Front Seat, Right Side
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
Female
</td>
<td style="text-align:left;">
Male
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
No Special Use
</td>
<td style="text-align:left;">
No Special Use
</td>
<td style="text-align:left;">
No Special Use
</td>
<td style="text-align:left;">
No Special Use
</td>
<td style="text-align:left;">
No Special Use
</td>
</tr>
<tr>
<td style="text-align:left;">
speedrel
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
towed
</td>
<td style="text-align:left;">
Towed Due to Disabling Damage
</td>
<td style="text-align:left;">
Towed Due to Disabling Damage
</td>
<td style="text-align:left;">
Towed Due to Disabling Damage
</td>
<td style="text-align:left;">
Towed Due to Disabling Damage
</td>
<td style="text-align:left;">
Towed Due to Disabling Damage
</td>
</tr>
<tr>
<td style="text-align:left;">
trav_sp
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
031 MPH
</td>
<td style="text-align:left;">
031 MPH
</td>
</tr>
<tr>
<td style="text-align:left;">
tway_id
</td>
<td style="text-align:left;">
US-59
</td>
<td style="text-align:left;">
US-59
</td>
<td style="text-align:left;">
US-59
</td>
<td style="text-align:left;">
SR-324
</td>
<td style="text-align:left;">
SR-324
</td>
</tr>
<tr>
<td style="text-align:left;">
tway_id2
</td>
<td style="text-align:left;">
CR-31
</td>
<td style="text-align:left;">
CR-31
</td>
<td style="text-align:left;">
CR-31
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
typ_int
</td>
<td style="text-align:left;">
Four-Way Intersection
</td>
<td style="text-align:left;">
Four-Way Intersection
</td>
<td style="text-align:left;">
Four-Way Intersection
</td>
<td style="text-align:left;">
Not an Intersection
</td>
<td style="text-align:left;">
Not an Intersection
</td>
</tr>
<tr>
<td style="text-align:left;">
underide
</td>
<td style="text-align:left;">
No Underride or Override Noted
</td>
<td style="text-align:left;">
No Underride or Override Noted
</td>
<td style="text-align:left;">
No Underride or Override Noted
</td>
<td style="text-align:left;">
No Underride or Override Noted
</td>
<td style="text-align:left;">
No Underride or Override Noted
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
Straight
</td>
</tr>
<tr>
<td style="text-align:left;">
ve_forms
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
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
ve_total
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
<td style="text-align:left;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
vin
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
vnum_lan
</td>
<td style="text-align:left;">
Two lanes
</td>
<td style="text-align:left;">
Two lanes
</td>
<td style="text-align:left;">
Two lanes
</td>
<td style="text-align:left;">
Two lanes
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
Level
</td>
</tr>
<tr>
<td style="text-align:left;">
vspd_lim
</td>
<td style="text-align:left;">
60 MPH
</td>
<td style="text-align:left;">
60 MPH
</td>
<td style="text-align:left;">
60 MPH
</td>
<td style="text-align:left;">
55 MPH
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
No Controls
</td>
<td style="text-align:left;">
No Controls
</td>
<td style="text-align:left;">
No Controls
</td>
<td style="text-align:left;">
No Controls
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
No Controls
</td>
<td style="text-align:left;">
No Controls
</td>
<td style="text-align:left;">
No Controls
</td>
<td style="text-align:left;">
No Controls
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
Two-Way, Not Divided
</td>
<td style="text-align:left;">
Two-Way, Not Divided
</td>
<td style="text-align:left;">
Two-Way, Not Divided
</td>
<td style="text-align:left;">
Two-Way, Not Divided
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
Not Applicable (not a fatality)
</td>
<td style="text-align:left;">
Not Applicable (not a fatality)
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
Not Applicable (not a fatality)
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
func_sys
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
rd_owner
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
cityname
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
countyname
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
statename
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
trlr1vin
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
trlr2vin
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
trlr3vin
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
prev_sus1
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
prev_sus2
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
prev_sus3
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
helm_mis
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
helm_use
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
gvwr_from
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
gvwr_to
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
icfinalbody
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
trlr1gvwr
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
trlr2gvwr
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
trlr3gvwr
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
vpicbodyclass
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
vpicmake
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
vpicmodel
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
underoverride
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
devmotor
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
devtype
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
acc_config
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
a1
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
25
</td>
<td style="text-align:left;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
a2
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
25
</td>
<td style="text-align:left;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
a3
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
25
</td>
<td style="text-align:left;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
a4
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
25
</td>
<td style="text-align:left;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
a5
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
25
</td>
<td style="text-align:left;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
a6
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
25
</td>
<td style="text-align:left;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
a7
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
25
</td>
<td style="text-align:left;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
a8
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
25
</td>
<td style="text-align:left;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
a9
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
25
</td>
<td style="text-align:left;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
a10
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
25
</td>
<td style="text-align:left;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
p1
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
p2
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
p3
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
p4
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
p5
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
p6
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
p7
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
p8
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
p9
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
p10
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
25
</td>
<td style="text-align:left;">
NA
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
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
weather1
</td>
<td style="text-align:left;">
Cloudy
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
weather1
</td>
<td style="text-align:left;">
Cloudy
</td>
<td style="text-align:left;">
2014
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
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
weather1
</td>
<td style="text-align:left;">
Cloudy
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
weather1
</td>
<td style="text-align:left;">
Cloudy
</td>
<td style="text-align:left;">
2014
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
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugtst1
</td>
<td style="text-align:left;">
Blood
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugtst2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugtst3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres1
</td>
<td style="text-align:left;">
Tested, No Drugs Found/Negative
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugtst1
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugtst2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugtst3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres1
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugtst2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugtst3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugres2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugres3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugtst1
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugtst2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugtst3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres1
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
drugres3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugtst1
</td>
<td style="text-align:left;">
Unknown if Tested
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugtst2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugtst3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugres1
</td>
<td style="text-align:left;">
Unknown if Tested
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugres2
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
drugres3
</td>
<td style="text-align:left;">
Test Not Given
</td>
<td style="text-align:left;">
2014
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
Minnesota
</td>
<td style="text-align:left;">
270304
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
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
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
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
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
2
</td>
<td style="text-align:left;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
Minnesota
</td>
<td style="text-align:left;">
270304
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
12 Clock Point
</td>
<td style="text-align:left;">
Ditch
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
South Dakota
</td>
<td style="text-align:left;">
460097
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
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
South Dakota
</td>
<td style="text-align:left;">
460097
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
12 Clock Point
</td>
<td style="text-align:left;">
Other Post, Other Pole or Other Supports
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
South Dakota
</td>
<td style="text-align:left;">
460097
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
2014
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
