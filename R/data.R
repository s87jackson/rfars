#' Synonym table for various geographical scales
#'
#' A dataset providing different ways to refer to states and counties.
#'
#' @format A data frame with 3,142 rows and 6 variables:
#' \describe{
#'   \item{fips_state}{2-digit FIPS code indicating a state}
#'   \item{fips_county}{3-digit FIPS code indicating a county within a state}
#'   \item{fips_tract}{6-digit FIPS code indicating a tract within a county}
#'   \item{state_name_abbr}{2-character, capitalized state abbreviation}
#'   \item{state_name_full}{fully spelled and case-sensitive state name}
#'   \item{county_name_abbr}{abbreviated county name (usually minus the word 'County')}
#'   \item{county_name_full}{fully spelled and case-sensitive county name}
#' }
#' @source \url{https://www.census.gov/geographies/reference-files/2015/demo/popest/2015-fips.html}
"geo_relations"


#' FARS Variable Names
#'
#' A dataset that translates machine-readable variable names to friendly names
#'
#' @format A data frame with 468 rows and 4 columns
#' @details See \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813254}{2020 Analytical User’s Manual} for more information.
#'
#' \describe{
#'   \item{table}{the cleaned name of the data file}
#'   \item{original}{the original variable name}
#'   \item{friendly}{human-readable (friendly) version of the variable name}
#'   \item{original_clean}{the cleaned name of the variable}
#'  }
#' @source \url{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813254}
"fars_varnames"


#' Changes in FARS Data Elements by Data File and Year
#'
#' A dataset describing major changes to the FARS data system over time.
#'
#' @format A data frame with 46 rows and 480 columns.
#' @details See Appendix F of the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813254}{2020 Analytical User’s Manual} for more information.
#' @source \url{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813254}
"fars_data_changes"


#' FARS data structure
#'
#' A dataset describing the structure and level of each raw FARS data file.
#'
#' @format A data frame with 27 rows and 4 columns.
#' \describe{
#'   \item{tablename}{the cleaned name of the data file}
#'   \item{structure}{either one or multiple, indicating the number of rows per entity}
#'   \item{level}{the entity level (crash, vehicle, or person) or the data file}
#'   \item{year_created}{the first year that the data file was in use}
#' }
#' @source Page 19 of the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813254}{2020 Analytical User’s Manual}
"fars_data_structure"
