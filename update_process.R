# Package Update Process

# Run this script step by step to update the rfars package

# Delete data folders and vignette outputs ----
temp_rtmp    <- dir(path = "C:/Users/SteveJackson/AppData/Local/Temp", pattern = "Rtmp", recursive = TRUE, full.names = TRUE, ignore.case = TRUE, include.dirs = TRUE)
temp_fars    <- dir(path = "C:/Users/SteveJackson/AppData/Local/Temp", pattern = "FARS data", recursive = TRUE, full.names = TRUE, ignore.case = TRUE, include.dirs = TRUE)
temp_gescrss <- dir(path = "C:/Users/SteveJackson/AppData/Local/Temp", pattern = "GESCRSS data", recursive = TRUE, full.names = TRUE, ignore.case = TRUE, include.dirs = TRUE)
proj_fars    <- dir(path = "C:/Users/SteveJackson/OneDrive - Toxcel/rfars", pattern = "FARS data", recursive = TRUE, full.names = TRUE, ignore.case = TRUE, include.dirs = TRUE)
proj_gescrss <- dir(path = "C:/Users/SteveJackson/OneDrive - Toxcel/rfars", pattern = "GESCRSS data", recursive = TRUE, full.names = TRUE, ignore.case = TRUE, include.dirs = TRUE)

all_paths <- c(temp_rtmp, temp_fars, temp_gescrss, proj_fars, proj_gescrss)

# Remove duplicates and delete
if (length(all_paths) > 0) {
  all_paths <- unique(all_paths)
  message(sprintf("Deleting %d folder(s)...", length(all_paths)))
  for (path in all_paths) {
    message(sprintf("  Deleting: %s", path))
    unlink(path, recursive = TRUE, force = TRUE)
  }
  message("Data folders deleted successfully")
} else {
  message("No data folders found to delete")
}

# Clean environment ----
rm(list = ls())

# Document ----
devtools::document(roclets = c('rd', 'collate', 'namespace', 'vignette'))

# Clean and install ----
message("MANUAL STEP: In RStudio: Build >> Install >> Clean and install")
readline(prompt = "Press [enter] to continue after clean install")

# Remove old check directory ----
message("Removing old check directory...")
unlink("C:/Users/SteveJackson/OneDrive - Toxcel/rfars.Rcheck", recursive = TRUE)

# Check package ----
message("Running devtools::check()...")
devtools::check(args = c('--as-cran'), check_dir = tempdir())

# Move Claude files ----
message("Moving Claude files to in_development...")

# Move .claude folder if it exists
if (dir.exists(".claude")) {
  message("  Moving .claude folder...")
  file.copy(".claude", "in_development", recursive = TRUE, overwrite = TRUE)
  unlink(".claude", recursive = TRUE)
}

# Move CLAUDE.md files
claude_md_files <- list.files(pattern = "^CLAUDE.*\\.md$", full.names = TRUE, recursive = FALSE)
if (length(claude_md_files) > 0) {
  for (file in claude_md_files) {
    message(sprintf("  Moving %s...", basename(file)))
    file.copy(file, file.path("in_development", basename(file)), overwrite = TRUE)
    file.remove(file)
  }
}

message("Claude files moved successfully")

# Delete docs folder ----
message("Deleting docs folder...")
if (dir.exists("docs")) {
  unlink("docs", recursive = TRUE, force = TRUE)
  message("  docs folder deleted successfully")
} else {
  message("  No docs folder found")
}

# Build pkgdown site ----
message("Building pkgdown site...")
pkgdown::build_site_github_pages()

# Git commit ----
message("MANUAL STEP: Git commit all changed files (Commit, Push)")
readline(prompt = "Press [enter] to continue after committing")

# CRAN submission prep ----
message("\n=== FOR CRAN SUBMISSION ===")
message("1. Update cran-comments.md")
message("2. Make sure version number in DESCRIPTION is accurate")
message("3. Run: devtools::submit_cran()")
message("4. See https://r-pkgs.org/release.html for more info")

devtools::submit_cran()
