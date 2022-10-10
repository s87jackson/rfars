#' Use FARS data files
#'
#' Combine multiple years of prepared FARS data stored in CSV files and bring
#'     into the current environment.
#'
#' @param prepared_dir Directory where prepared files are currently saved.
#' @param years (Optional) Years to use.
#'
#' @return Returns either a single data frame (if \code{multi=NULL}) or a list
#'     containing the combined flat file data frame and specified \code{multi}
#'     files.
#'
#' @seealso \code{download_fars()} \code{prep_fars()} \code{get_fars()}
#' @examples
#' \dontrun{
#' myData <- use_fars()
#' }

#' @export
use_fars <- function(prepared_dir=getwd(), years = NULL){

  flat <-

    suppressWarnings({ #this is just for the small number of coercion errors with mutate_at(lat, lon, as.numeric)

      list.files(prepared_dir, full.names = TRUE, pattern = "_flat.csv", recursive = TRUE) %>%
      lapply(function(x){
        readr::read_csv(x, show_col_types = FALSE) %>%
        mutate_at(c("lat", "lon"), as.numeric)
        }) %>%
      bind_rows() %>%
      as.data.frame()

    })


  multi_acc <-
      list.files(prepared_dir, full.names = TRUE, pattern = "multi_acc", recursive = TRUE) %>%
      lapply(readr::read_csv, show_col_types = FALSE) %>%
      bind_rows() %>%
      as.data.frame()

  multi_veh <-
    list.files(prepared_dir, full.names = TRUE, pattern = "multi_veh", recursive = TRUE) %>%
    lapply(readr::read_csv, show_col_types = FALSE) %>%
    bind_rows() %>%
    as.data.frame()

  multi_per <-
    list.files(prepared_dir, full.names = TRUE, pattern = "multi_per", recursive = TRUE) %>%
    lapply(readr::read_csv, show_col_types = FALSE) %>%
    bind_rows() %>%
    as.data.frame()

  if(!is.null(years)){
    flat <- flat %>% filter(year %in% years)
    multi_acc <- multi_acc %>% filter(year %in% years)
    multi_veh <- multi_veh %>% filter(year %in% years)
    multi_per <- multi_per %>% filter(year %in% years)
  }


  out <- list(
    "flat" = flat,
    "multi_acc" = multi_acc,
    "multi_veh" = multi_veh,
    "multi_per" = multi_per)


  return(out)

  }
