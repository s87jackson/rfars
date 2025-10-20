## Update

-   Re-submitting as I believe the package was archived in error and have not been able to reach the review team via email.
-   Added extensive testing suite.


## Test environments

-   local windows install (x86_64-w64-mingw32/x64 (64-bit)), R 4.4.0
-   Ubuntu 22.04.2, Microsoft Windows Server 2022 10.0.20348, macOS 12.6.5 (via GitHub's R CMD Check workflow)


## Latest R CMD check results

```         
─  using log directory 'C:/Users/SteveJackson/AppData/Local/Temp/RtmpW6W1tz/rfars.Rcheck'
─  using R version 4.4.0 (2024-04-24 ucrt)
─  using platform: x86_64-w64-mingw32
─  R was compiled by
       gcc.exe (GCC) 13.2.0
       GNU Fortran (GCC) 13.2.0
─  running under: Windows 11 x64 (build 26100)
─  using session charset: UTF-8
─  using options '--no-manual --as-cran'
✔  checking for file 'rfars/DESCRIPTION'
─  checking extension type ... Package
─  this is package 'rfars' version '2.0.2'
─  package encoding: UTF-8
✔  checking package namespace information
✔  checking package dependencies (846ms)
✔  checking if this is a source package ...
✔  checking if there is a namespace
✔  checking for executable files (1.1s)
✔  checking for hidden files and directories ...
✔  checking for portable file names
✔  checking whether package 'rfars' can be installed (9.3s)
✔  checking installed package size ... 
✔  checking package directory (606ms)
✔  checking for future file timestamps (435ms)
✔  checking 'build' directory
✔  checking DESCRIPTION meta-information ... 
✔  checking top-level files ...
✔  checking for left-over files
✔  checking index information ... 
✔  checking package subdirectories (855ms)
✔  checking code files for non-ASCII characters ... 
✔  checking R files for syntax errors ... 
✔  checking whether the package can be loaded (671ms)
✔  checking whether the package can be loaded with stated dependencies (553ms)
✔  checking whether the package can be unloaded cleanly (662ms)
✔  checking whether the namespace can be loaded with stated dependencies (537ms)
✔  checking whether the namespace can be unloaded cleanly (757ms)
✔  checking loading without being on the library search path (978ms)
✔  checking dependencies in R code (1.4s)
✔  checking S3 generic/method consistency (647ms)
✔  checking replacement functions (528ms)
✔  checking foreign function calls (659ms)
✔  checking R code for possible problems (5.6s)
✔  checking Rd files ... 
✔  checking Rd metadata ... 
✔  checking Rd line widths ... 
✔  checking Rd cross-references (650ms)
✔  checking for missing documentation entries (776ms)
✔  checking for code/documentation mismatches (2.1s)
✔  checking Rd \usage sections (980ms)
✔  checking Rd contents ... 
✔  checking for unstated dependencies in examples ... 
✔  checking contents of 'data' directory (3.1s)
✔  checking data for non-ASCII characters (1.6s)
✔  checking LazyData
✔  checking data for ASCII and uncompressed saves ... 
✔  checking installed files from 'inst/doc' ... 
✔  checking files in 'vignettes' ... 
✔  checking examples (1.5s)
✔  checking for unstated dependencies in 'tests' ... 
─  checking tests ...
    [150s] OKestthat.R'
   * checking for unstated dependencies in vignettes ... OK
   * checking package vignettes ... OK
   * checking re-building of vignette outputs ... [122s] OK
   * checking for non-standard things in the check directory ... OK
   * checking for detritus in the temp directory ... OK
   * DONE
   
   Status: OK
   
── R CMD check results ─────────────────────────────────────────────────────────────── rfars 2.0.2 ────
Duration: 5m 15.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
