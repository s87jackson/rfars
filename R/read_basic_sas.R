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
#'
#' @seealso read_basic_sas_nocat

read_basic_sas <- function(x,
                           wd,
                           rawfiles,
                           catfile=paste0(wd, "formats.sas7bcat"),
                           imps = NULL,
                           omits = NULL
                           ){

  if(catfile==FALSE){
    read_basic_sas_nocat(x=x, wd=wd, rawfiles=rawfiles, imps=imps, omits=omits)
    } else{

  temp <-
    haven::read_sas(
      data_file = paste0(wd, rawfiles$filename[rawfiles$cleaned==x]),
      catalog_file = catfile) %>%
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

  temp <- select(temp, -any_of(starts_with("vin_")))

  # Remove unnecessarily duplicated variables
  if(!is.null(omits)){
    cleanNames <- janitor::make_clean_names(names(temp))
    toRemove   <- setdiff(unique(omits), c("casenum", "state", "st_case", "veh_no", "per_no", "year"))
    temp       <- select(temp, -all_of(which(cleanNames %in% toRemove)))
  }


  temp_no_attrs <- mutate(temp, across(everything(), as.vector))

  for(i in 1:ncol(temp)){ # i=42; i=24; i=43; i=31; i=4

    if(names(temp)[i] %in% c("ST_CASE", "CASENUM", "WEIGHT", "LATITUDE", "LONGITUD")) next

    xvar <- select(temp, xvar=names(temp)[i])

    xlabels <-
      auto_label_unlabeled_values(
        lbl_vector=xvar$xvar,
        wd=wd,
        x=x,
        varname=names(temp)[i]
        ) %>%
      attr("labels", exact = TRUE)

    xvarlabel <- gsub(pattern = "Imputed ", replacement="", x=attr(xvar$xvar, "label", exact = TRUE))

    if(!is.null(xlabels)){

      varmap <- data.frame(
        value = xlabels,
        label = names(xlabels),
        row.names = NULL)

      exampleValues <- paste0("Examples: ", paste(varmap$value[1:20], collapse = ", ")) %>% substr(1, 40) %>% paste0("...")

      varmap_reduced <- varmap %>% filter(.data$value != .data$label)

      if(nrow(varmap_reduced)==0){
        varmap_reduced <-
          bind_rows(
            varmap_reduced,
            data.frame(value=exampleValues, label="(Self-evident)")
          )
      }

      my_codebook <- varmap_reduced %>%
        dplyr::rename(value_label = .data$label) %>%
        mutate(
          source = stringr::word(wd, -4, sep = "/") %>% stringr::word(1),
          year   = stringr::word(wd, -2, sep = "/"),
          file   = x,
          name_ncsa = names(temp)[i],
          name_rfars = names(temp)[i] %>% janitor::make_clean_names(),
          label = xvarlabel
        ) %>%
        select(all_of(c("source", "year", "file", "name_ncsa", "name_rfars", "label", "value", "value_label"))) %>%
        #Note that these are hardkeyed in download_gescrss and will require edits if the line above is changed
        mutate_all(as.character)

      appendRDS(my_codebook, file = "codebook.rds", wd = wd)


      original_name <- names(temp_no_attrs)[i]

      #cat(original_name)

      if(inherits(varmap$value, "character")) temp_no_attrs[[original_name]] <- as.character(temp_no_attrs[[original_name]])
      if(inherits(varmap$value, "integer") || inherits(varmap$value, "numeric")) temp_no_attrs[[original_name]] <- as.numeric(temp_no_attrs[[original_name]])

      temp_no_attrs <-
        temp_no_attrs %>%
        dplyr::rename(value = original_name) %>%
        left_join(varmap, by = "value") %>%
        #dplyr::rename(value = label) #%>%
        mutate(value = .data$label) %>%
        select(-all_of(c("label")))

      names(temp_no_attrs)[i] <- original_name

    }


  }

  outnames <-
    janitor::make_clean_names(names(temp_no_attrs)) %>%
    setdiff(c("year", "casenum", "state", "st_case", "veh_no", "per_no", "weight", "psu", "psustrat", "region", "stratum", "pj")) %>%
    sort()

  out <- temp_no_attrs %>%
    janitor::clean_names() %>%
    select(any_of(c("year", "casenum", "state", "st_case",
                    "veh_no", "per_no", "weight",
                    "psu", "psustrat", "region", "stratum", "pj")),
           any_of(outnames)
           )


  return(out)

    }

}
