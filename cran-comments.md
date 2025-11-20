## Update

-   Small update to data processing and Zenodo links for downloading.


## Test environments

-   local windows install (x86_64-w64-mingw32/x64 (64-bit)), R 4.4.0
-   Ubuntu 22.04.2, Microsoft Windows Server 2022 10.0.20348, macOS 12.6.5 (via GitHub's R CMD Check workflow)


## Latest R CMD check results

```         
> devtools::check(args = c('--as-cran'), check_dir = tempdir())
══ Documenting ═════════════════════════════════════════════════════════════════════════════════════════════════════
ℹ Updating rfars documentation
ℹ Loading rfars

══ Building ════════════════════════════════════════════════════════════════════════════════════════════════════════
Setting env vars:
• CFLAGS    : -Wall -pedantic -fdiagnostics-color=always
• CXXFLAGS  : -Wall -pedantic -fdiagnostics-color=always
• CXX11FLAGS: -Wall -pedantic -fdiagnostics-color=always
• CXX14FLAGS: -Wall -pedantic -fdiagnostics-color=always
• CXX17FLAGS: -Wall -pedantic -fdiagnostics-color=always
• CXX20FLAGS: -Wall -pedantic -fdiagnostics-color=always
── R CMD build ─────────────────────────────────────────────────────────────────────────────────────────────────────
✔  checking for file 'C:\Users\SteveJackson\OneDrive - Toxcel\rfars/DESCRIPTION' ...
─  preparing 'rfars': (1m 19s)
✔  checking DESCRIPTION meta-information ...
─  installing the package to build vignettes
✔  creating vignettes (26.4s)
─  checking for LF line-endings in source and make files and shell scripts (5.3s)
─  checking for empty or unneeded directories
   Removed empty directory 'rfars/tests/testthat/_snaps'
─  building 'rfars_2.0.2.tar.gz'
   
══ Checking ════════════════════════════════════════════════════════════════════════════════════════════════════════
Setting env vars:
• _R_CHECK_CRAN_INCOMING_REMOTE_               : FALSE
• _R_CHECK_CRAN_INCOMING_                      : FALSE
• _R_CHECK_FORCE_SUGGESTS_                     : FALSE
• _R_CHECK_PACKAGES_USED_IGNORE_UNUSED_IMPORTS_: FALSE
• NOT_CRAN                                     : true
── R CMD check ─────────────────────────────────────────────────────────────────────────────────────────────────────
─  using log directory 'C:/Users/SteveJackson/AppData/Local/Temp/Rtmp0Ei8m1/rfars.Rcheck' (343ms)
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
✔  checking package dependencies (2.2s)
✔  checking if this is a source package ...
✔  checking if there is a namespace
✔  checking for executable files (1.6s)
✔  checking for hidden files and directories ...
✔  checking for portable file names
✔  checking whether package 'rfars' can be installed (9.7s)
✔  checking installed package size ... 
✔  checking package directory (915ms)
N  checking for future file timestamps ... 
   unable to verify current time
✔  checking 'build' directory
✔  checking DESCRIPTION meta-information (357ms)
✔  checking top-level files ...
✔  checking for left-over files
✔  checking index information ... 
✔  checking package subdirectories (924ms)
✔  checking code files for non-ASCII characters ... 
✔  checking R files for syntax errors ... 
✔  checking whether the package can be loaded (887ms)
✔  checking whether the package can be loaded with stated dependencies (777ms)
✔  checking whether the package can be unloaded cleanly (870ms)
✔  checking whether the namespace can be loaded with stated dependencies (775ms)
✔  checking whether the namespace can be unloaded cleanly (866ms)
✔  checking loading without being on the library search path (1.2s)
✔  checking dependencies in R code (2.1s)
✔  checking S3 generic/method consistency (875ms)
✔  checking replacement functions (888ms)
✔  checking foreign function calls (993ms)
✔  checking R code for possible problems (7.6s)
✔  checking Rd files (541ms)
✔  checking Rd metadata ... 
✔  checking Rd line widths ... 
✔  checking Rd cross-references (761ms)
✔  checking for missing documentation entries (773ms)
✔  checking for code/documentation mismatches (2.5s)
✔  checking Rd \usage sections (1.3s)
✔  checking Rd contents ... 
✔  checking for unstated dependencies in examples ... 
✔  checking contents of 'data' directory ... 
✔  checking data for non-ASCII characters (556ms)
✔  checking LazyData
✔  checking data for ASCII and uncompressed saves ... 
✔  checking R/sysdata.rda ... 
✔  checking installed files from 'inst/doc' ... 
✔  checking files in 'vignettes' ... 
✔  checking examples (1.9s)
✔  checking for unstated dependencies in 'tests' ... 
─  checking tests ...
    [562s] OKestthat.R'
   * checking for unstated dependencies in vignettes ... OK
   * checking package vignettes ... OK
   * checking re-building of vignette outputs ... [20s] OK
   * checking for non-standard things in the check directory ... OK
   * checking for detritus in the temp directory ... OK
   * DONE
   
   Status: 1 NOTE
   See
     'C:/Users/SteveJackson/AppData/Local/Temp/Rtmp0Ei8m1/rfars.Rcheck/00check.log'
   for details.
   
── R CMD check results ──────────────────────────────────────────────────────────────────────────── rfars 2.0.2 ────
Duration: 10m 35.4s

❯ checking for future file timestamps ... NOTE
  unable to verify current time

0 errors ✔ | 0 warnings ✔ | 1 note ✖
```
