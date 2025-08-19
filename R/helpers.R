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

  if(length(intersect(c(original, imputed), names(df))) == 2){

    if(show) df %>% group_by({{original}}, {{imputed}}) %>% filter({{original}} != {{imputed}}) %>% summarize(n=n()) %>% print()

    a <- df[[original]]
    b <- df[[imputed]]

    varlabel <- attr(df[[original]], "label", exact = TRUE)

    #c <- ifelse(a != b, b, a)

    out <- df
    out[[original]] <- b

    attr(out[[original]], "label") <- varlabel

    out <- select(out, -all_of(imputed))

    return(out)

  } else{
    return(df)
  }

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
      data.table::rbindlist(fill = TRUE) %>%
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
    out$year <- as.numeric(as.character(out$year))

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



#' (Internal) Check SAS attributes
#'
#' @param data An object produced by haven::read_sas()
#'
#' @importFrom rlang .data

get_sas_attrs <- function(data) {
  data.frame(
    variable = names(data),
    label = sapply(data, function(x) if(is.null(attr(x, "label"))) "" else attr(x, "label")),
    sasFormat = sapply(data, function(x) if(is.null(attr(x, "format.sas"))) "" else attr(x, "format.sas")),
    has_labels = sapply(data, function(x) !is.null(attr(x, "labels"))),
    labels = I(lapply(data, function(x) {
      labs <- attr(x, "labels")
      if(is.null(labs)) return(NULL)
      data.frame(
        value = as.character(labs),
        value_label = names(labs),
        stringsAsFactors = FALSE
      )
    })),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
}







#' (Internal) Parse formats.sas instead of using a .sas7bcat file
#'
#' @param file_path The path of the formats.sas file
#'
#' @importFrom rlang .data
#' @import stringr
parse_sas_format <- function(file_path) {

  # Read the file
  lines <- readLines(file_path, warn = FALSE)

  # Find PROC FORMAT blocks
  proc_indices <- which(grepl("^PROC FORMAT", lines, ignore.case = TRUE))
  lines_from   <- proc_indices[1:(length(proc_indices)-1)]
  lines_to     <- proc_indices[2:(length(proc_indices))]
  line_nums    <- data.frame(from = lines_from,to = lines_to)

  # Initialize table
  result <- tibble(
    sasFormat = rep("", nrow(line_nums)),
    labels = vector("list", nrow(line_nums))
    )

  # Fill in table
  for (i in 1:nrow(line_nums)) {

    # Find format name
    format_name <-
      lines[line_nums$from[i]] %>%
      trimws() %>%
      stringr::word(-1)

    # Get values and value_labels
    format_lines <- lines[(line_nums$from[i]+1) : (line_nums$to[i]-2)]
    values <- stringr::word(format_lines, 1, sep = "=")
    labels <- stringr::word(format_lines, 2, sep = "=") %>% stringr::str_replace_all("'", "")

    # Make values numeric if numeric
    isNumeric <- all(!is.na( suppressMessages(suppressWarnings(as.numeric(values)))))
    if(isNumeric) values <- as.numeric(values)

    # Compile result
    result$sasFormat[i] <- format_name
    result$labels[[i]]    <- tibble(value = values, value_label = labels)

  }

  return(result)

}
