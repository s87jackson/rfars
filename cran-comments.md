## Resubmission

This is a resubmission. In this version I have:

* Removed examples for unexported functions.

In previous resubmissions I:

* Put functions which download data in \donttest{}

* Streamlined some processes

* Added \value to .Rd files

* Added small executable examples to illustrate the use of exported functions and enable automatic testing.

* Avoided the issue of saving data to the hard drive by saving it to tempdir.

* Fixed the redirect URL that was causing the invalid URL note

* Downsized the vignettes to reduce the check time.

* Removed the words that were triggering the misspelling note.

* Rephrased the Description to not begin with 'this package'

* Removed some unnecessary content from Readme.

* Removed a function and dependency that is no longer required.
  
## Latest R CMD check results

    Duration: 6m 17.6s

    0 errors | 0 warnings | 0 notes
    
    R CMD check succeeded
    
* R CMD check was run on development version of R
