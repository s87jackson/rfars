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

  # Check years
    ymax <- max(as.numeric(years), na.rm = TRUE)
    ymin <- min(as.numeric(years), na.rm = TRUE)

    if(ymin < 2015) stop("Data not available prior to 2015.")
    if(ymax > 2020) stop("Data not available beyond to 2020")

  # Ask permission to download files to the user's computer
    x <- readline("We will now download several files from https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/FARS/ \n Proceed? (Y/N) \n")
    if(!(x %in% c("y", "Y"))) return(message("Download cancelled."))


  # Download and unzip raw data files
    for(y in 1:length(years)){

      zipfiledest = paste0(save_dir, "/FARS data ", years[y], ".zip")

      "https://static.nhtsa.gov/nhtsa/downloads/FARS/myYear/National/FARSmyYearNationalCSV.zip" %>%
        gsub(x=., pattern = "myYear", replacement = as.character(years[y])) %>%
        downloader::download(dest=zipfiledest, mode="wb")

      utils::unzip(zipfiledest, exdir = paste0(save_dir, "/FARS data/raw/", years[y], "/"), overwrite = TRUE)

      unlink(zipfiledest)

    }

  # Tell user what happened
    message(paste0("Raw data files have been saved to ", save_dir, "/FARS data/raw/"))

  # Return the path to use as input for prep_fars
    return(invisible(paste0(save_dir, "/FARS data/raw/")))


}
