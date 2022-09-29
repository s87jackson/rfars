#' Download FARS data files
#'
#' Download annual files directly from NHTSA and unzip them
#'     into a newly created ~/FARS data/raw directory.
#'
#' @param years Years to be downloaded, in yyyy (character or numeric formats),
#'     currently limited to 2016-2020
#' @param save_dir Directory to store files
#'
#' @return Returns the location of the raw data data (\code{save_dir}/FARS data/raw),
#'     intended to be piped into \code{prep_fars}
#' @details Raw files are downloaded from \href{https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/FARS/}{NHTSA}
#'     and stored in \code{save_dir}/FARS data/raw/
#' @seealso \code{prep_fars}
#' @examples
#' download_fars(c("2019", "2020"))
#' download_fars(2016:2020)


#' @export
download_fars <- function(years, save_dir=getwd()){

  for(y in 1:length(years)){

    zipfiledest = paste0(save_dir, "/FARS data ", years[y], ".zip")

    "https://static.nhtsa.gov/nhtsa/downloads/FARS/myYear/National/FARSmyYearNationalCSV.zip" %>%
      gsub(x=., pattern = "myYear", replacement = as.character(years[y])) %>%
      downloader::download(dest=zipfiledest, mode="wb")

    utils::unzip(zipfiledest, exdir = paste0(save_dir, "/FARS data/raw/", years[y], "/"), overwrite = TRUE)

    unlink(zipfiledest)

  }

  message(paste0("Raw data files have been saved to ", save_dir, "/FARS data/raw/"))

  return(invisible(paste0(save_dir, "/FARS data/raw/")))


}
