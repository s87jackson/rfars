## Update

-   Created sample data for use in Readme and vignettes to avoid errors caused by internet connectivity lapses.
-   Added extensive testing suite.


## Test environments

-   local windows install (x86_64-w64-mingw32/x64 (64-bit)), R 4.4.0
-   Ubuntu 22.04.2, Microsoft Windows Server 2022 10.0.20348, macOS 12.6.5 (via GitHub's R CMD Check workflow)


## Latest R CMD check results

```         
── R CMD check ──────────────────────────────────────────────────
─  using log directory 'C:/Users/SteveJackson/AppData/Local/Temp/Rtmpug6jux/rfars.Rcheck' (364ms)
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
✔  checking package dependencies (2s)
✔  checking if this is a source package ...
✔  checking if there is a namespace
✔  checking for executable files (1.5s)
✔  checking for hidden files and directories ...
✔  checking for portable file names
✔  checking whether package 'rfars' can be installed (9.8s)
✔  checking installed package size ... 
✔  checking package directory (1.2s)
N  checking for future file timestamps (365ms)
   unable to verify current time
✔  checking 'build' directory
✔  checking DESCRIPTION meta-information (567ms)
✔  checking top-level files ...
✔  checking for left-over files
✔  checking index information (377ms)
✔  checking package subdirectories (1.2s)
✔  checking code files for non-ASCII characters ... 
✔  checking R files for syntax errors ... 
✔  checking whether the package can be loaded (877ms)
✔  checking whether the package can be loaded with stated dependencies (775ms)
✔  checking whether the package can be unloaded cleanly (891ms)
✔  checking whether the namespace can be loaded with stated dependencies (773ms)
✔  checking whether the namespace can be unloaded cleanly (862ms)
✔  checking loading without being on the library search path (1.4s)
✔  checking dependencies in R code (2.1s)
✔  checking S3 generic/method consistency (984ms)
✔  checking replacement functions (765ms)
✔  checking foreign function calls (877ms)
✔  checking R code for possible problems (8.3s)
✔  checking Rd files (545ms)
✔  checking Rd metadata ... 
✔  checking Rd line widths ... 
✔  checking Rd cross-references (978ms)
✔  checking for missing documentation entries (882ms)
✔  checking for code/documentation mismatches (2.6s)
✔  checking Rd \usage sections (1.4s)
✔  checking Rd contents ... 
✔  checking for unstated dependencies in examples (340ms)
✔  checking contents of 'data' directory (394ms)
✔  checking data for non-ASCII characters (650ms)
✔  checking LazyData
✔  checking data for ASCII and uncompressed saves ... 
✔  checking R/sysdata.rda ... 
✔  checking installed files from 'inst/doc' ... 
✔  checking files in 'vignettes' ... 
✔  checking examples (2.1s)
✔  checking for unstated dependencies in 'tests' ... 
─  checking tests ...
    [132s] OKestthat.R'
   * checking for unstated dependencies in vignettes ... OK
   * checking package vignettes ... OK
   * checking re-building of vignette outputs ... [23s] OK
   * checking for non-standard things in the check directory ... OK
   * checking for detritus in the temp directory ... OK
   * DONE
   
   Status: 1 NOTE
   See
     'C:/Users/SteveJackson/AppData/Local/Temp/Rtmpug6jux/rfars.Rcheck/00check.log'
   for details.
   
── R CMD check results ───────────────────────── rfars 2.0.2 ────
Duration: 3m 33.1s
```
