# rfars 2.0.0

* Added data from 2023
* Added 'Definition' and 'Additional Information' fields from the User Manuals to the codebooks
* Significantly improved speed and memory usage
* Improved data processing status updates
* Fixed a bug in downloading 2020 data
* Added multiple imputation BAC data elements `a1`:`a10` and `p1`:`p10` to `get_fars()` output (the `flat` object)
* Added "Alcohol Counts" vignette to provide guidance on using multiple imputation data
* Added `involved = "each"` parameter option to `counts()` function
* Added `annual_counts` dataset
* Dropped support for data older than 2014

# rfars 1.2.0

* Added data from 2022
* Fixed bugs with 2012-2016
* Added status updates to let you know the data is being processed
* Implemented a methodology to use prior codebook entries when formats are unavailable
* Fixed a bug causing the omission of motor carrier IDs
* Integrated rfars into a web application to bring crash data to non-R-users

# rfars 1.1.0

* Streamlined the README content
* Cleaned up the vignettes
* Incremented the version number to communicate the end of the beta testing stage

# rfars 0.3.1

* Adjusted code to account for file structure changes by data provider

# rfars 0.3.0

* Expanded FARS coverage to 2011-2021
* Added get_gescrss() to get GES/CRSS data
* Modified the get_ functions to produce a codebook.csv file
* Included a codebook.rds file for quick reference
* The geo_relations table now includes NHTSA regions
* Improved the counts() function
* Added a compare_counts() function
* SAS files are pulled from NHTSA, rather than the CSVs
* Consolidated all prep_fars_yyyy functions into prep_fars()


# rfars 0.2.0

* Added the ability to download FARS data to a tempdir.
* Improved documentation.
* Streamlined the workflow to be contained in get_fars().
* Developed a hex sticker.


# rfars 0.1.0

* Added a `NEWS.md` file to track changes to the package.
