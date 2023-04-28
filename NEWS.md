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
* Included several sample datasets


# rfars 0.2.0

* Added the ability to download FARS data to a tempdir.
* Improved documentation.
* Streamlined the workflow to be contained in get_fars().
* Developed a hex sticker.


# rfars 0.1.0

* Added a `NEWS.md` file to track changes to the package.
