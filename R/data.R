#' Synonym table for various geographical scales
#'
#' A dataset providing different ways to refer to states and counties.
#'
#' @format A data frame with 3,142 rows and 6 variables:
#' \describe{
#'   \item{FIPS}{5-digit FIPS code composed of \code{state_fips} and \code{county_fips}}
#'   \item{state_fips}{2-digit FIPS code indicating a state}
#'   \item{county_fips}{3-digit FIPS code indicating a county within a state}
#'   \item{state_abbr}{2-character, capitalized state abbreviations}
#'   \item{state_name}{fully spelled and case-sensitive state names}
#'   \item{county_name}{fully spelled and case-sensitive state names}
#' }
#' @source \url{https://www.census.gov/geographies/reference-files/2015/demo/popest/2015-fips.html}
"geo_relations"


#' County-level estimation of rurality
#'
#' A dataset provided by US Census describing urban and rural populations in
#'     all US counties based on the 2010 Census.
#'
#' @format A data frame with 3,142 rows and 5 variables:
#' \describe{
#'   \item{FIPS}{5-digit FIPS code composed of \code{state_fips} and \code{county_fips}}
#'   \item{pop2010_total}{total population of a given county}
#'   \item{pop2010_urban}{population living in urban areas}
#'   \item{pop2010_rural}{population living in rural areas}
#'   \item{pop2010_rural_pct}{the percentage (0-100) of a county's population
#'       living in rural areas, hence, the \emph{percent-rural}}
#' }
#' @source \url{https://www.census.gov/programs-surveys/geography/guidance/geo-areas/urban-rural.html}
"rural_pct"


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
