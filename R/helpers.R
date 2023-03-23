#' (Internal) use_imp
#'
#' An internal function that uses imputed variables (present in many GES/CRSS tables)
#'
#' @param df The input data frame.
#' @param original The original, non-imputed variable.
#' @param imputed The imputed variable (often with an _im suffix).
#' @param show Logical (FALSE by default) Show differences between original and imputed values.
#'
#' @importFrom rlang .data
#' @importFrom data.table ':='

use_imp <- function(df, original, imputed, show=FALSE){

  if(show) df %>% group_by({{original}}, {{imputed}}) %>% filter({{original}} != {{imputed}}) %>% summarize(n=n()) %>% print()

  df %>%
    mutate({{original}} := ifelse({{original}} != {{imputed}}, {{imputed}}, {{original}})) %>%
    select(-{{imputed}}) %>%
    return()

}



#' (Internal) rm_cols.g
#'
#' An internal function that removes variables that are unnecessarily duplicated across GES/CRSS tables.
#'
#' @param df The input data frame.
#' @param a The original, non-imputed variable.
#' @param b The imputed variable (often with an _im suffix).
#'
#' @importFrom rlang .data

rm_cols.g <- function(df, a, b){

  out <- df %>% select(-setdiff(intersect(names(a), names(df)), c("casenum")))

  if(!is.null(b)) out <- out %>% select(-setdiff(intersect(names(b), names(out)), c("casenum", "veh_no")))

  return(out)

}

#' (Internal) rm_cols.f
#'
#' An internal function that removes variables that are unnecessarily duplicated across FARS tables.
#'
#' @param df The input data frame.
#' @param a The original, non-imputed variable.
#' @param b The imputed variable (often with an _im suffix).
#'
#' @importFrom rlang .data

rm_cols.f <- function(df, a, b){

  out <- df %>% select(-setdiff(intersect(names(a), names(df)), c("state", "st_case")))

  if(!is.null(b)) out <- out %>% select(-setdiff(intersect(names(b), names(out)), c("state", "st_case", "veh_no")))

  return(out)

}

#' (Internal) Import the multi_ files
#'
#' An internal function that imports the multi_ files
#'
#' @param filename The filename (e.g. "multi_acc.csv") to be imported
#' @param where The directory to search within
#'
#' @importFrom rlang .data

import_multi <- function(filename, where){

    out <-
      data.frame(path = list.files(where, full.names = TRUE, pattern = filename, recursive = TRUE)) %>%
      mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
      pull(.data$path) %>%
      lapply(function(x){
          readRDS(x) %>%
          mutate_all(as.character)
          }) %>%
      bind_rows() %>%
      as.data.frame()

    return(out)

  }


#' (Internal) Validate user-provided list of states
#'
#' @param states States specified in get_fars, prep_fars, or counts


validate_states <- function(states){

  if(!is.null(states)){

    for(state in states){

        state_check <-
          state %in% unique(c(
            rfars::geo_relations$state_name_abbr,
            rfars::geo_relations$state_name_full,
            rfars::geo_relations$fips_state
            )
            )

        if(!state_check) stop(paste0("'", state, "' not recognized. Please check rfars::geo_relations for valid ways to specify states (state_name_abbr, state_name_full, or fips_state)."))

    }
    }

}



#' (Internal) Generate an ID variable
#'
#' @param df The dataframe from which to make the id

make_id <- function(df){

  if("st_case" %in% names(df)){

    out <- df
    out$id <- paste0(out$year, out$st_case)

  }

  if("casenum" %in% names(df)){

    out <- df
    out$id <- paste0(out$year, out$casenum)

  }

  return(out)

}


#' (Internal) Make id and year numeric
#'
#' @param df The input dataframe

make_all_numeric <- function(df){

  if(all(c("year", "id") %in% names(df))){

    out <- df
    out$id <- as.numeric(out$id)
    out$year <- as.numeric(out$year)

  }

  return(out)

}


#' (Internal) Append RDS files
#'
#' @param object The object to save or append
#' @param file The name of the file to be saved to be saved
#' @param wd The directory to check

appendRDS <- function(object, file, wd){

  if(!file.exists(paste0(wd, "/", file))){

    saveRDS(object=object, file=paste0(wd, "/", file))

  } else{

    df.new <- rbind(readRDS(paste0(wd, "/", file)), object)
    saveRDS(df.new, paste0(wd, "/", file))

  }

}
