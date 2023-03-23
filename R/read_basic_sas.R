#' (Internal) Takes care of basic SAS file reading
#'
#' @param x The cleaned name of the data table (SAS7BDAT).
#' @param wd The working directory for these files
#' @param rawfiles The data frame connecting raw filenames to cleaned ones.
#' @param catfile The location of the sas7bcat file
#'
#' @importFrom haven read_sas
#' @importFrom rlang .data
#'
#' @seealso read_basic_sas_nocat

read_basic_sas <- function(x, wd, rawfiles, catfile=paste0(wd, "formats.sas7bcat")){

  if(catfile==FALSE){
    read_basic_sas_nocat(x=x, wd=wd, rawfiles=rawfiles)
    } else{

  temp <-
    haven::read_sas(
      data_file = paste0(wd, rawfiles$filename[rawfiles$cleaned==x]),
      catalog_file = catfile) %>%
    dplyr::distinct()

  temp_no_attrs <- temp %>% mutate(across(everything(), as.vector))


  for(i in 1:ncol(temp)){ # i=43

    if(names(temp)[i] %in% c("LATITUDE", "LONGITUD")) next

    xvar <- select(temp, xvar=names(temp)[i])

    xlabels <- attr(xvar$xvar, "labels", exact = TRUE)

    xvarlabel <- attr(xvar$xvar, "label", exact = TRUE)

    if(!is.null(xlabels)){

      varmap <- data.frame(
        value = xlabels,
        label = names(xlabels),
        row.names = NULL
      )

      is_imputed <- grepl(x = names(temp)[i], pattern = "_IM")

      if(!is_imputed){

        my_codebook <- varmap %>%
          dplyr::rename(value_label = .data$label) %>%
          mutate(
            source = stringr::word(wd, -4, sep = "/") %>% stringr::word(1),
            year   = stringr::word(wd, -2, sep = "/"),
            file   = x,
            name_ncsa = names(temp)[i],
            name_rfars = names(temp)[i] %>% janitor::make_clean_names(),
            label = xvarlabel
          ) %>%
          select(source, "year", "file", "name_ncsa", "name_rfars", "label", "value", "value_label") %>%
          #Note that these are hardkeyed in download_gescrss and will require edits if the line above is changed
          mutate_all(as.character)

        appendRDS(my_codebook, file = "codebook.rds", wd = wd)

      }

      original_name <- names(temp_no_attrs)[i]

      #cat(original_name)

      temp_no_attrs <-
        temp_no_attrs %>%
        dplyr::rename(value = original_name) %>%
        left_join(varmap, by = "value") %>%
        #dplyr::rename(value = label) #%>%
        mutate(value = .data$label) %>%
        select(-all_of("label"))

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
