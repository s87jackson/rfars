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
#'   \item{region}{fully spelled out and case-sensitive NHTSA region and constituent states}
#'   \item{region_abbr}{abbreviated NHTSA region (ne, mw, s, w)}
#' }
#' @source \url{https://www.census.gov/geographies/reference-files/2015/demo/popest/2015-fips.html}
"geo_relations"



#' FARS Codebook
#'
#' A table describing each FARS variable name, value, and corresponding value label.
#'
#' @format A data frame with 132,454 rows and 8 variables:
#' \describe{
#'    \item{source}{The source of the data (either FARS or GES/CRSS)}
#'    \item{years}{Years of the data element definition.}
#'    \item{file}{The data file that contains the given variable.}
#'    \item{name_ncsa}{The original name of the data element.}
#'    \item{name_rfars}{The modified data element name used in rfars}
#'    \item{label}{The label of the data element itself (not its constituent values).}
#'    \item{value}{The original value of the data element.}
#'    \item{value_label}{The de-coded value label.}
#'    }
#'
#' @details This codebook serves as a useful reference for researchers using FARS data.
#'    The 'source' variable is intended to help combine with the gescrss_codebook.
#'    Data elements are relatively stable but are occasionally discontinued, created anew,
#'    or modified. The 'year' variable helps indicate the availability of data elements,
#'    and differentiates between different definitions over time. Users should always
#'    check for discontinuities when tabulating cases.
#'
#'    The 'file' variable indicates the file in which the given data element originally appeared. Here, files refers to
#'    the SAS files downloaded from NHTSA. Most data elements stayed in their original
#'    file. Those that did not were moved to the multi_ files. For example, 'weather'
#'    originates from the 'accident' file, but appears in the multi_acc data object
#'    created by rfars.
#'
#'    The 'name_ncsa' variable describes the data element's name as assigned
#'    by NCSA (the organization within NHTSA that manages the database). To maximize
#'    compatibility between years and ease of use for programming, 'name_rfars'
#'    provides a cleaned naming convention (via janitor::clean_names()). Both
#'    names are provided here to help users find the corresponding entry in
#'    the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813254}{Analytical User’s Manual}
#'    but only the latter are used in the data produced by get_fars().
#'
#'    Each data element has a 'label', a more human-readable version of the
#'    element names. For example, the label for 'road_fnc' is 'Roadway Function Class'.
#'    These are not definitions but may provide enough information to help users
#'    conduct their analysis. Consult the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813254}{Analytical User’s Manual}
#'    for definitions and further details.
#'
#'    Each data element has multiple 'value'-'value_label' pairs: 'value' represents
#'    the original, non-human-readable value (usually a number), and 'value_label'
#'    represents the corresponding text value. For example, for 'road_fnc', 1 (the 'value')
#'    corresponds to 'Rural-Principal Arterial-Interstate' (the 'value_label'), 2 corresponds to
#'    'Rural-Principal Arterial-Other', etc.
#'
#' @seealso "gescrss_codebook"
"fars_codebook"



#' GESCRSS Codebook
#'
#' A table describing each GESCRSS variable name, value, and corresponding value label.
#'
#' @format A data frame with 85,907 rows and 8 variables:
#' \describe{
#'    \item{source}{The source of the data (either FARS or GESCRSS)}
#'    \item{years}{Years of the data element definition.}
#'    \item{file}{The data file that contains the given variable.}
#'    \item{name_ncsa}{The original name of the data element.}
#'    \item{name_rfars}{The modified data element name used in rfars}
#'    \item{label}{The label of the data element itself (not its constituent values).}
#'    \item{value}{The original value of the data element.}
#'    \item{value_label}{The de-coded value label.}
#'    }
#'
#' @details This codebook serves as a useful reference for researchers using GES/CRSS data.
#'    The 'source' variable is intended to help combine with the fars_codebook.
#'    Data elements are relatively stable but are occasionally discontinued, created anew,
#'    or modified. The 'year' variable helps indicate the availability of data elements,
#'    and differentiates between different definitions over time. Users should always
#'    check for discontinuities when tabulating cases.
#'
#'    The 'file' variable indicates the file in which the given data element originally appeared. Here, files refers to
#'    the SAS files downloaded from NHTSA. Most data elements stayed in their original
#'    file. Those that did not were moved to the multi_ files. For example, 'weather'
#'    originates from the 'accident' file, but appears in the multi_acc data object
#'    created by rfars.
#'
#'    The 'name_ncsa' variable describes the data element's name as assigned
#'    by NCSA (the organization within NHTSA that manages the database). To maximize
#'    compatibility between years and ease of use for programming, 'name_rfars'
#'    provides a cleaned naming convention (via janitor::clean_names()). Both
#'    names are provided here to help users find the corresponding entry in
#'    the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813236}{CRSS User Manual}
#'    but only the latter are used in the data produced by get_gescrss().
#'
#'    Each data element has a 'label', a more human-readable version of the
#'    element names. For example, the label for 'harm_ev' is 'First Harmful Event'.
#'    These are not definitions but may provide enough information to help users
#'    conduct their analysis. Consult the \href{https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/813236}{CRSS User Manual}
#'    for definitions and further details.
#'
#'    Each data element has multiple 'value'-'value_label' pairs: 'value' represents
#'    the original, non-human-readable value (usually a number), and 'value_label'
#'    represents the corresponding text value. For example, for 'harm_ev', 1 (the 'value')
#'    corresponds to 'Rollover/Overturn' (the 'value_label'), 2 corresponds to
#'    'Fire/Explosion', etc.
#'
#' @seealso "fars_codebook"
"gescrss_codebook"
