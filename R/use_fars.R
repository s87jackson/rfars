#' Use FARS data files
#'
#' Combine multiple years of prepared FARS data stored in CSV files and bring
#'     into the current environment.
#'
#' @param prepared_dir Directory where prepared files are currently saved.
#' @param multi Which multiple-value-per-entity files to be returned. Can be
#'     any of \code{c("acc", "veh", "per")} or \code{NULL} (the default) to
#'     return only the combined flat files.
#'
#' @return Returns either a single data frame (if \code{multi=NULL}) or a list
#'     containing the combined flat file data frame and specified \code{multi}
#'     files.
#'
#' @seealso \code{download_fars()} \code{prep_fars()} \code{get_fars()}
#' @examples
#' myData <- use_fars()

#' @export
use_fars <- function(prepared_dir=getwd(), multi=NULL){

  temp <-
    list.files(prepared_dir, full.names = TRUE, pattern = "_flat") %>%
    lapply(function(x){read_csv(x) %>% mutate_at(c("lat", "lon"), as.numeric)}) %>%
    bind_rows

  if(is.null(multi)){

    return(temp)

  } else{

    out <- list("flat" = temp)

    if("acc" %in% multi){
      out[["multi_acc"]] <-
        list.files(prepared_dir, full.names = TRUE, pattern = "multi_acc") %>%
          lapply(readr::read_csv) %>%
          bind_rows
    }

    if("veh" %in% multi){
      out[["multi_veh"]] <-
        list.files(prepared_dir, full.names = TRUE, pattern = "multi_veh") %>%
          lapply(readr::read_csv) %>%
          bind_rows
    }

    if("per" %in% multi){
      out[["multi_per"]] <-
        list.files(prepared_dir, full.names = TRUE, pattern = "multi_per") %>%
          lapply(readr::read_csv) %>%
          bind_rows
    }

    return(out)

  }

  }
