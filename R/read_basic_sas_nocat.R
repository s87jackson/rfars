#' (Internal) Takes care of basic SAS file reading when the bcat file creates an issue
#'
#' @param x The cleaned name of the data table (SAS7BDAT).
#' @param wd The working directory for these files
#' @param rawfiles The data frame connecting raw filenames to cleaned ones.
#'
#' @importFrom sas7bdat read.sas7bdat
#' @importFrom rlang .data


read_basic_sas_nocat <- function(x, wd, rawfiles){

  # Parse the formats.sas file
    format_sas <-
      list.files(path = wd, pattern = "Format1", full.names = TRUE, ignore.case = T) %>%
      readLines() %>%
      as.data.frame() %>%
      set_names("x") %>%
      mutate(fmat = stringr::word(x, 2, sep = "; VALUE") %>% zoo::na.locf(na.rm = FALSE)) %>%
      filter(grepl("='", x)) %>%
      separate(x, c("value", "label"), sep = "='") %>%
      mutate(label = stringr::str_remove(.data$label, "'"),
             fmat = trimws(.data$fmat))

  # Read in the bdat file
    temp <- read.sas7bdat(paste0(wd, rawfiles$filename[rawfiles$cleaned==x]))

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
      #filter(!is.na(fmat))
      mutate(value = stringr::str_pad(.data$value, 2, "left", "0") %>% as.character()) %>%
      left_join(format_sas, by = c("fmat", "value")) %>%
      mutate(value2 = dplyr::coalesce(.data$label, .data$value)) %>%
      select(-any_of(c("value", "fmat", "label")))

    formatted <-
      formatted %>%
      group_by_at(1:which(names(formatted)=="varname")) %>% mutate(rownum = row_number()) %>%
      # dplyr::group_by(STATE, ST_CASE, VEH_NO, varname) %>%
      # dplyr::summarise(n = dplyr::n(), .groups = "drop") %>%
      # dplyr::filter(n > 1L)
      pivot_wider(names_from = "varname", values_from = "value2") %>%
      select(-"rownum") %>% distinct()

  # Codebook
    my_codebook <-
      key %>%
      mutate(name_rfars = janitor::make_clean_names(.data$varname)) %>%
      inner_join(format_sas, by = "fmat") %>%
      dplyr::rename(value_label = .data$label) %>%
      mutate(
        source = stringr::word(wd, -4, sep = "/") %>% stringr::word(1),
        year   = stringr::word(wd, -2, sep = "/"),
        file   = x,
        name_ncsa = .data$varname,
        label = .data$xvarlabel
        ) %>%
      select(source, "year", "file", "name_ncsa", "name_rfars", "label", "value", "value_label") %>%
      #Note that these are hardkeyed in download_gescrss/fars and will require edits if the line above is changed
      mutate_all(as.character)

    appendRDS(my_codebook, "codebook.rds", wd = wd)

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
