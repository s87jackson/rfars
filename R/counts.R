#' Get FARS data
#'
#' This function is a wrapper for \code{download_fars} and \code{prep_fars}.
#'     It downloads raw files from NHTSA and produces analysis-ready data files.
#'
#' @inheritParams download_fars
#' @inheritParams prep_fars
#'
#' @details Prepared data files are stored in \code{save_dir}/FARS data/prepared/
#' @seealso \code{download_fars} \code{prep_fars}
#' @examples
#' get_fars(c("2019", "2020"))
#' get_fars(2016:2020, "Virginia")
#' get_fars(2020, "NC")

#' @export
counts <- function(df, what, when, interval, where, who, why){



}
