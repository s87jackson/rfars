#' (INTERNAL) Use decoded variables instead of encoded ones
#'
#' The raw data files include two versions of many data elements: an encoded one
#'     (using numbers to indicate characteristics such as injury severity,
#'     relation to the roadway, race, etc.) and another that has already been
#'     decoded. These variables are labelled according to the convention: x and
#'     xname, where the latter is the decoded version. This internal function
#'     goes through a given data frame, removing the decoded versions and
#'     renaming the encoded ones to remove the 'name' suffix.
#'
#' @param df Data frame with both versions of some variables.
#'
#' @return A data frame with the encoded variables replaced with decoded versions.
#'
#' @seealso \code{prep_fars()}
#'
#' @importFrom rlang .data


usenames <- function(df){

  replacenames <-
    data.frame(varname = names(df)) %>%
    mutate(hasname = grepl("name", .data$varname),
           varname = ifelse(.data$hasname, gsub(pattern = "name", replacement = "", x=.data$varname), .data$varname)
           ) %>%
    group_by(.data$varname) %>%
    summarize(n=n()) %>%
    mutate(t =
             grepl("hour", .data$varname) |
             grepl("min", .data$varname) |
             grepl("hr", .data$varname) |
             grepl("mn", .data$varname) |
             grepl("hrs", .data$varname) |
             grepl("mins", .data$varname),
           t = ifelse(.data$varname %in% c("crashrf", "mnmdstrd"), FALSE, .data$t)
           ) %>%
    filter(n==2, !t)

  df2 <- df %>%
    select(-all_of(replacenames$varname),
          -any_of(c("hourname", "minutename",
                  "arr_hourname", "arr_minname",
                  "not_hourname", "not_minname",
                  "death_hrname", "death_mnname",
                  "lag_hrsname", "lag_minsname",
                  "hosp_hrname", "hosp_mnname")))

  names(df2) <- gsub(x = names(df2), pattern = "name", replacement = "")

  return(df2)

}
