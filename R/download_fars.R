#' Download FARS data files
#'
#' Download annual files directly from NHTSA and unzip them
#'     into a newly created ~/FARS data/raw directory.
#'
#' @param years Years to be downloaded, in yyyy (character or numeric formats),
#'     currently limited to 2016-2020
#' @param save_dir Directory to store files
#' @param proceed Logical, should the downloading proceed without the user's
#'     permission (set to FALSE by default).
#'
#' @return Returns the location of the raw data data (\code{save_dir}/FARS data/raw),
#'     intended to be piped into \code{prep_fars}
#' @details Raw files are downloaded from \href{https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/FARS/}{NHTSA}
#'     and stored in \code{save_dir}/FARS data/raw/
#' @seealso \code{prep_fars}
#' @examples
#' \dontrun{
#' download_fars(c("2019", "2020"))
#' download_fars(2011:2020, proceed=TRUE)
#' }


#' @export
download_fars <- function(years, save_dir=getwd(), proceed=FALSE){

  # Check years
    validate_years(years)


  # Ask permission to download files to the user's computer
    if(!proceed){
      x <- readline("We will now download several files from https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/FARS/ \nProceed? (Y/N) \n")
      if(!(x %in% c("y", "Y"))) return(message("Download cancelled.\n"))
      }


  # Download and unzip raw data files
    for(y in 1:length(years)){

      zipfiledest = paste0(save_dir, "/FARS data ", years[y], ".zip")

      thisURL <- "https://static.nhtsa.gov/nhtsa/downloads/FARS/myYear/National/FARSmyYearNationalCSV.zip"

      gsub(x=thisURL, pattern = "myYear", replacement = as.character(years[y])) %>%
        downloader::download(dest=zipfiledest, mode="wb")

      utils::unzip(zipfiledest, exdir = paste0(save_dir, "/FARS data/raw/", years[y], "/"), overwrite = TRUE)

      unlink(zipfiledest)

    }

  # Tell user what happened
    message(paste0("Raw data files have been saved to ", save_dir, "/FARS data/raw/\n"))

  # Return the path to use as input for prep_fars
    return(invisible(paste0(save_dir, "/FARS data/raw/")))


}
