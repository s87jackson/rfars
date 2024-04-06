#' (Internal) Takes care of basic SAS file reading when the bcat file creates an issue
#'
#' @param x The cleaned name of the data table (SAS7BDAT).
#' @param wd The working directory for these files
#' @param rawfiles The data frame connecting raw filenames to cleaned ones.
#' @param imps A named list to be passed to use_imp(). Each item's name represents
#'   the non-imputed variable name; the item itself represents the related imputed variable.
#' @param omits Character vector of columns to omit
#'
#' @importFrom sas7bdat read.sas7bdat
#' @importFrom rlang .data


read_basic_sas_nocat <- function(x, wd, rawfiles, imps=NULL, omits=NULL){

  # Parse the formats.sas file
    format_sas <-
      list.files(path = wd, pattern = "\\.sas$", full.names = TRUE, ignore.case = T, recursive = T)[1] %>%
      readLines(encoding = "UTF-8") %>%
      iconv("UTF-8", "UTF-8",sub='') %>%
      as.data.frame() %>%
      set_names("x") %>%
      mutate(fmat = stringr::word(x, 2, sep = "; VALUE") %>% zoo::na.locf(na.rm = FALSE)) %>%
      filter(grepl("='", x)) %>%
      separate(x, c("value", "label"), sep = "='") %>%
      mutate(label = stringr::str_remove(.data$label, "'"),
             fmat = trimws(.data$fmat))

  # Read in the bdat file
    temp <- read.sas7bdat(paste0(wd, rawfiles$filename[rawfiles$cleaned==x]))

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

  # Pull the variable-format pairs out of the bdat file
    key <- attr(temp, "column.info") %>% unlist()

    key <- data.frame(name=names(key), value=key) %>%
      filter(.data$name %in% c("name", "format", "label"))  %>%
      mutate(varname = ifelse(.data$name=="name", .data$value, as.character(NA)) %>% zoo::na.locf(na.rm = FALSE)) %>%
      filter(.data$name %in% c("format", "label")) %>%
      pivot_wider(names_from = "name", values_from = "value") %>%
      select("varname", fmat=.data$format, xvarlabel=.data$label) %>%
      dplyr::distinct() %>%
      filter(!is.na(.data$fmat), .data$fmat != "$")

  # Remove the attributes of the bdat file
    temp_no_attrs <- temp %>% mutate(across(everything(), as.vector))

  # Apply the formats
    formatted <-
      temp_no_attrs %>%
      distinct() %>%
      mutate_all(as.character) %>%
      pivot_longer(-any_of(c("STATE", "ST_CASE", "VEH_NO", "PER_NO", "VEVENTNUM")), names_to = "varname") %>%
      left_join(select(key, -"xvarlabel"), by = "varname") %>%
      mutate(value = stringr::str_pad(.data$value, 2, "left", "0") %>% as.character()) %>%
      left_join(format_sas, by = c("fmat", "value")) %>%
      mutate(value2 = dplyr::coalesce(.data$label, .data$value)) %>%
      select(-any_of(c("value", "fmat", "label")))

    formatted <- formatted %>%
      group_by_at(1:which(names(formatted)=="varname")) %>% mutate(rownum = row_number()) %>%
      pivot_wider(names_from = "varname", values_from = "value2") %>%
      select(-"rownum") %>% distinct()


  for(i in 1:ncol(formatted)){ # i=42; i=24; i=43; i=31; i=4

    if(names(formatted)[i] %in% c("ST_CASE", "CASENUM", "WEIGHT", "LATITUDE", "LONGITUD")) next

      varmap <- key %>%
        filter(.data$varname== names(formatted)[i]) %>%
        #left_join(format_sas, by = join_by(fmat)) %>%
        left_join(format_sas) %>%
        select(all_of(c("value", "label")))

      xvarlabel <- key$xvarlabel[key$varname== names(formatted)[i]]

      if(nrow(varmap)>0){

        exampleValues <- paste0("Examples: ", paste(varmap$value[1:20], collapse = ", ")) %>% substr(1, 40) %>% paste0("...")

        varmap_reduced <- varmap %>% filter(.data$value != .data$label)

        if(nrow(varmap_reduced)==0){
          varmap_reduced <-
            bind_rows(
              varmap_reduced,
              data.frame(value=exampleValues, label="(Self-evident)"))
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
          #Note that these are hardkeyed in download_fars and will require edits if the line above is changed
          mutate_all(as.character)

      appendRDS(my_codebook, file = "codebook.rds", wd = wd)

    }

  }



  # Return

    outnames <-
      janitor::make_clean_names(names(formatted)) %>%
      setdiff(c("year", "casenum", "state", "st_case", "veh_no", "per_no", "weight", "psu", "psustrat", "region", "stratum", "pj")) %>%
      sort()

    out <-
      formatted %>%
      ungroup() %>%
      janitor::clean_names() %>%
      select(any_of(c("year", "casenum", "state", "st_case",
                      "veh_no", "per_no", "weight",
                      "psu", "psustrat", "region", "stratum", "pj")),
             all_of(outnames)
             ) %>%
      distinct()


  return(out)


}
