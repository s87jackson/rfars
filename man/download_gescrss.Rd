% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download_gescrss.R
\name{download_gescrss}
\alias{download_gescrss}
\title{(Internal) Download GES/CRSS data files}
\usage{
download_gescrss(years, dest_raw, dest_prepd, regions)
}
\arguments{
\item{years}{Years to be downloaded, in yyyy (character or numeric formats)}

\item{dest_raw}{Directory to store raw CSV files}

\item{dest_prepd}{Directory to store prepared CSV files}

\item{regions}{(Optional) Inherits from get_gescrss()}
}
\value{
Nothing directly to the current environment. Various CSV files are stored either in a temporary directory or dir as specified by the user.
}
\description{
Download files from NHTSA, unzip, and prepare them.
}
\details{
Raw files are downloaded directly from \href{https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/}{NHTSA}.
}
