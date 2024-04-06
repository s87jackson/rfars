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


#' (Internal) Label unlabelled values in imported SAS files
#'
#' @param lbl_vector A vector with labels
#' @param wd Working directory for files
#' @param x NCSA table name (sas file name)
#' @param varname Variable name or label
#'
#' @importFrom rlang .data
#' @importFrom stats setNames


# Function to automatically label unlabeled values
  auto_label_unlabeled_values <- function(
    lbl_vector,
    wd=wd,
    x=x,
    varname) {

  # Extract existing labels and values
    existing_labels <- attr(lbl_vector, "labels")
    existing_labels <- existing_labels[!duplicated(names(existing_labels))]

    all_values <- unique(lbl_vector)

    unlabeled_values <- setdiff(all_values, existing_labels)

    #if(is.null(existing_labels) || length(existing_labels) == 0){

      # Check for entries in previous years
        if(grepl("FARS data", wd))    this_codebook <- rfars::fars_codebook
        if(grepl("GESCRSS data", wd)) this_codebook <- rfars::gescrss_codebook
        mini_dict <-
          this_codebook %>%
          filter(
            .data$name_ncsa==varname,
            .data$file==x,
            grepl("2020", .data$years))

        if(nrow(mini_dict) > 0){
          new_labels <- setNames(mini_dict$value, mini_dict$value_label)
        } else{
          new_labels <- setNames(as.character(all_values), all_values)
          new_labels <- new_labels[!duplicated(names(new_labels))]
        }


    #}

    # Create new labels for unlabeled values, using the value itself as the label
      more_labels <- setNames(as.character(unlabeled_values), unlabeled_values)

    # Combine existing and new labels
      combined_labels <- c(existing_labels, new_labels, more_labels)
      combined_labels <- combined_labels[!duplicated(names(combined_labels))]
      combined_labels <- combined_labels[!duplicated(combined_labels)]

    # Return the vector with updated labels
      return(
        haven::labelled(
          as.character(lbl_vector),
          labels = combined_labels
          )
        )

}

