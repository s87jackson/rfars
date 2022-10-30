#' (Internal) Validate user-provided list of states
#'
#' @param years Years specified in download_fars, get_fars, prep_fars, or counts


validate_years <- function(years){

  ymax <- max(as.numeric(years), na.rm = TRUE)
  ymin <- min(as.numeric(years), na.rm = TRUE)

  if(ymin < 2015) stop("Data not available prior to 2015.")
  #if(ymax > 2020) stop("Data not available beyond 2020.")

}
