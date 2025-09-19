#' (Internal) Takes care of basic SAS file reading
#'
#' @param x The cleaned name of the data table (SAS7BDAT).
#' @param wd The working directory for these files
#' @param rawfiles The data frame connecting raw filenames to cleaned ones.
#' @param catfile The location of the sas7bcat file
#' @param imps A named list to be passed to use_imp(). Each item's name represents
#'   the non-imputed variable name; the item itself represents the related imputed variable.
#' @param omits Character vector of columns to omit
#'
#' @importFrom haven read_sas
#' @importFrom rlang .data
#' @importFrom utils txtProgressBar setTxtProgressBar
#'
#' @seealso read_basic_sas_nocat

read_basic_sas <- function(x,
                           wd,
                           rawfiles,
                           catfile,
                           imps = NULL,
                           omits = NULL
                           ){

  # Import the sas file
  temp <-
    haven::read_sas(
      data_file = paste0(wd, rawfiles$filename[rawfiles$cleaned==x]),
      catalog_file = catfile
    ) %>%
    select(-any_of(starts_with("vin_"))) %>%
    dplyr::distinct()

  # Take care of imputed variables
    if(!is.null(imps)){
      names(imps) <- toupper(names(imps))
      imps <- toupper(imps)
      for(i in 1:length(imps)){
        temp <- use_imp(
          df = temp,
          original = names(imps)[i],
          imputed = as.character(imps[i])
          )
      }
    }

  # Remove unnecessarily duplicated variables
  if(!is.null(omits)){
    cleanNames <- janitor::make_clean_names(names(temp))
    toRemove   <- setdiff(unique(omits), c("casenum", "state", "st_case", "veh_no", "per_no", "year"))
    temp       <- select(temp, -all_of(which(cleanNames %in% toRemove)))
  }

  # Get all of the formatting from the sas file
  if(!is.null(catfile)){
    formatData <- get_sas_attrs(temp)
  } else{
    formatData <-
      get_sas_attrs(temp) %>%
      select(-all_of("labels")) %>%
      left_join(
        parse_sas_format(
          file_path = list.files(
            path = wd,
            pattern = "^Format\\d{2}\\.sas$",
            ignore.case = TRUE,
            full.names = TRUE,
            recursive = T)
        ),
        by = "sasFormat"
      )
  }

  # Add labels for A1:A10 and P1:P10
  formatData$label[formatData$variable %in% c(paste0("A", 1:10), paste0("P", 1:10))] <- "Imputed BAC Value"

  # Produce a clean df
  temp_no_attrs <- mutate(temp, across(everything(), as.vector))

  # Batch process variable labeling and codebook generation
  skip_vars <- c("ST_CASE", "CASENUM", "WEIGHT", "LATITUDE", "LONGITUD")
  process_vars <- setdiff(names(temp), skip_vars)

  all_codebooks <- list()

  if (length(process_vars) > 0) {

    pb <- txtProgressBar(min = 0, max = length(process_vars)-1, style = 3)  # Initialize progress bar

    for (i in seq_along(process_vars)) {

      setTxtProgressBar(pb, i)

      var_name  <- process_vars[i]
      col_idx   <- which(names(temp) == var_name)
      xvar      <- select(temp, xvar = all_of(var_name))
      xvarlabel <- formatData[["label"]][formatData$variable == var_name]
      y         <- stringr::str_extract(wd, "[^/]+(?=/[^/]*$)")

      varmap    <- formatData[["labels"]][formatData$variable == var_name][[1]]

      if(any(str_detect(varmap$value, ";"))){
        varmap    <- varmap[1:(min(which(str_detect(varmap$value, ";")))-1),]
      }


      if(is.null(varmap)){

        all_codebooks[[var_name]] <-
          tibble(
            source = stringr::str_extract(wd, "\\b(FARS|GESCRSS)\\b"),
            !! rlang::sym(y) := 1,   # creates column `year` = 1
            file = x,
            name_ncsa = var_name,
            name_rfars = janitor::make_clean_names(var_name),
            label = xvarlabel,
            value = as.character(NA),
            value_label = "(Self-evident)"
          ) %>%
          select(all_of(c("source", y, "file", "name_ncsa", "name_rfars", "label", "value", "value_label"))) %>%
          mutate(across(everything(), as.character))

      } else{

        # Apply value transformations
        original_name <- names(temp_no_attrs)[col_idx]

        if(inherits(temp_no_attrs[[original_name]], "numeric") && inherits(varmap$value, "character")){
          varmap$value <- suppressMessages( suppressWarnings( as.numeric(varmap$value) ))
        }

        if (inherits(varmap$value, "character")) {
          temp_no_attrs[[original_name]] <- as.character(temp_no_attrs[[original_name]])
        }

        if (inherits(varmap$value, "integer") || inherits(varmap$value, "numeric")) {
          temp_no_attrs[[original_name]] <- suppressMessages( suppressWarnings( as.numeric(temp_no_attrs[[original_name]])))
        }

        temp_no_attrs <- temp_no_attrs %>%
          dplyr::rename(value = all_of(original_name)) %>%
          left_join(varmap, by = "value") %>%
          mutate(value = .data$value_label) %>%
          select(-all_of("value_label"))

        names(temp_no_attrs)[col_idx] <- original_name

        all_codebooks[[var_name]] <-
          varmap %>%
          mutate(
            source = stringr::str_extract(wd, "\\b(FARS|GESCRSS)\\b"),
            !! rlang::sym(y) := 1,   # creates column `year` = 1
            file = x,
            name_ncsa = var_name,
            name_rfars = janitor::make_clean_names(var_name),
            label = xvarlabel
          ) %>%
          select(all_of(c("source", y, "file", "name_ncsa", "name_rfars", "label", "value", "value_label"))) %>%
          mutate(across(everything(), as.character))

      }

    }

  }

  close(pb)  # Close progress bar when done

  # Single batch write of all codebooks
  if (length(all_codebooks) > 0) {
    combined_codebook <-
      data.table::rbindlist(all_codebooks, fill = TRUE) %>%
      select(all_of(c("source", "file", "name_ncsa", "name_rfars", "label", "value", "value_label", y)))
    appendRDS(combined_codebook, file = "codebook.rds", wd = wd)
  }

  outnames <-
    janitor::make_clean_names(names(temp_no_attrs)) %>%
    setdiff(c("year", "casenum", "state", "st_case", "veh_no", "per_no", "weight", "psu", "psustrat", "region", "stratum", "pj")) %>%
    sort()

  out <-
    temp_no_attrs %>%
    janitor::clean_names() %>%
    select(
      any_of(c("year", "casenum", "state", "st_case",
               "veh_no", "per_no", "weight",
               "psu", "psustrat", "region", "stratum", "pj")),
      any_of(outnames),
      any_of(sprintf("a%d", 1:10)),
      any_of(sprintf("p%d", 1:10))
    )

  if("a10" %in% names(out)) out <- relocate(out, .data$a10, .after = .data$a9)
  if("p10" %in% names(out)) out <- relocate(out, .data$p10, .after = .data$p9)

  return(out)

}
