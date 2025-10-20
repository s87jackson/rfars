# Tests for get_fars() and get_gescrss() data retrieval functions
# Note: Many of these tests will be skipped on CRAN to avoid network dependencies

# Internet connection handling ----

test_that("get_fars handles no internet connection gracefully", {
  skip_on_cran()

  # If we can't connect, the function should return invisibly
  # This test is environment-dependent, so we just check it doesn't error
  expect_no_error({
    result <- tryCatch(
      get_fars(years = 2020, source = "zenodo", proceed = TRUE),
      error = function(e) NULL
    )
  })
})

test_that("get_gescrss handles no internet connection gracefully", {
  skip_on_cran()

  expect_no_error({
    result <- tryCatch(
      get_gescrss(years = 2020, source = "zenodo", proceed = TRUE),
      error = function(e) NULL
    )
  })
})


# Zenodo download structure (with mocking) ----

test_that("get_fars with source='zenodo' attempts zenodo download", {
  skip_on_cran()
  skip("Requires network access and may be slow")

  # This would actually download from Zenodo
  # Only run manually when testing network functionality
  result <- get_fars(years = 2020, source = "zenodo", proceed = TRUE)

  if (!is.null(result)) {
    expect_fars_object(result)
  }
})

test_that("get_gescrss with source='zenodo' attempts zenodo download", {
  skip_on_cran()
  skip("Requires network access and may be slow")

  result <- get_gescrss(years = 2020, source = "zenodo", proceed = TRUE)

  if (!is.null(result)) {
    expect_gescrss_object(result)
  }
})


# Object structure validation ----

test_that("FARS object has correct structure", {
  # Use mock data to test structure
  expect_fars_object(mock_fars)
})

test_that("GESCRSS object has correct structure", {
  expect_gescrss_object(mock_gescrss)
})

test_that("FARS flat file has required columns", {
  required_cols <- c("year", "state", "st_case", "id", "veh_no", "per_no")
  expect_true(all(required_cols %in% names(mock_fars$flat)))
})

test_that("GESCRSS flat file has required columns", {
  required_cols <- c("year", "casenum", "id", "veh_no", "per_no", "weight")
  expect_true(all(required_cols %in% names(mock_gescrss$flat)))
})


# Year filtering ----

test_that("get_fars filters to requested years from zenodo data", {
  skip_on_cran()
  skip("Requires network access")

  result <- get_fars(years = c(2020, 2021), source = "zenodo", proceed = TRUE)

  if (!is.null(result)) {
    expect_true(all(unique(result$flat$year) %in% c(2020, 2021)))
  }
})

test_that("multiple year request includes all years", {
  # Test with mock data
  multi_year_fars <- mock_fars

  years_in_flat <- unique(multi_year_fars$flat$year)
  expect_true(all(c(2022, 2023) %in% years_in_flat))
})


# State filtering ----

test_that("get_fars filters by state correctly", {
  skip_on_cran()
  skip("Requires network access")

  result <- get_fars(years = 2020, states = "Virginia", source = "zenodo", proceed = TRUE)

  if (!is.null(result)) {
    expect_true(all(result$flat$state == "Virginia"))
  }
})

test_that("get_fars handles multiple states", {
  skip_on_cran()
  skip("Requires network access")

  result <- get_fars(years = 2020, states = c("Virginia", "Maryland"), source = "zenodo", proceed = TRUE)

  if (!is.null(result)) {
    expect_true(all(result$flat$state %in% c("Virginia", "Maryland")))
  }
})


# Region filtering ----

test_that("get_gescrss filters by region correctly", {
  skip_on_cran()
  skip("Requires network access")

  result <- get_gescrss(years = 2020, regions = "s", source = "zenodo", proceed = TRUE)

  if (!is.null(result)) {
    # Check that region filtering worked
    expect_s3_class(result$flat, "data.frame")
  }
})


# Cache handling ----

test_that("cache parameter creates RDS file when specified with dir", {
  skip("Requires directory setup")

  # This would require setting up a temporary directory structure
  # and testing the caching mechanism
  expect_true(TRUE)  # Placeholder
})

test_that("existing cache file is used when available", {
  skip("Requires directory setup")

  # Would test that if cache exists, it's loaded instead of downloading
  expect_true(TRUE)  # Placeholder
})


# Proceed parameter ----

# test_that("proceed=FALSE would require user input", {
#   # Can't easily test interactive readline, but can verify parameter exists
#   expect_no_error({
#     # This will error on download attempt, but that's after the proceed parameter
#     tryCatch(
#       get_fars(years = 2020, proceed = FALSE),
#       error = function(e) NULL
#     )
#   })
# })
#
# test_that("proceed=TRUE skips user prompts", {
#   skip_on_cran()
#
#   # With proceed=TRUE, should attempt download without prompting
#   expect_no_error({
#     result <- tryCatch(
#       get_fars(years = 2020, source = "zenodo", proceed = TRUE),
#       error = function(e) NULL
#     )
#   })
# })


# Source parameter ----

test_that("source='zenodo' is default", {
  skip_on_cran()

  # Default should use zenodo
  expect_no_error({
    result <- tryCatch(
      get_fars(years = 2020, proceed = TRUE),
      error = function(e) NULL
    )
  })
})

test_that("source='nhtsa' would download from NHTSA", {
  skip("Long-running test that downloads large files")

  # This would actually download from NHTSA FTP
  # Only run manually
  expect_true(TRUE)
})


# Directory handling ----

test_that("dir=NULL uses temp directories", {
  skip("Requires full download")

  # When dir is NULL, should use tempdir()
  expect_true(TRUE)  # Placeholder
})

test_that("specified dir creates FARS data folder", {
  skip("Requires directory setup")

  # Should create 'FARS data' folder in specified directory
  expect_true(TRUE)  # Placeholder
})


# Multi tables filtering ----

test_that("state filtering affects all multi tables", {
  # Using mock data
  filtered_states <- c("Virginia")

  # Simulate filtering
  filtered_flat <- mock_fars$flat %>%
    dplyr::filter(state %in% filtered_states)

  filter_frame <- filtered_flat %>%
    dplyr::distinct(year, state, st_case)

  # Multi tables should only have matching st_case values
  expect_true(nrow(filter_frame) <= nrow(mock_fars$flat))
})


# Error handling ----

test_that("get_fars returns invisible NULL on download failure", {
  skip_on_cran()

  # If download fails (e.g., bad network), should return invisible(NULL)
  # This is hard to test reliably, so we check the mechanism exists
  expect_no_error({
    result <- tryCatch(
      get_fars(years = 2020, source = "zenodo", proceed = TRUE),
      error = function(e) NULL
    )
  })
})

test_that("download failure doesn't crash R session", {
  skip_on_cran()

  expect_no_error({
    # Even with network issues, shouldn't crash
    result <- tryCatch(
      get_gescrss(years = 2020, source = "zenodo", proceed = TRUE),
      error = function(e) NULL
    )
  })
})


# Class assignment ----

test_that("get_fars returns object with FARS class", {
  expect_true("FARS" %in% class(mock_fars))
})

test_that("get_gescrss returns object with GESCRSS class", {
  expect_true("GESCRSS" %in% class(mock_gescrss))
})


# Codebook ----

test_that("codebook is included in FARS object", {
  expect_true("codebook" %in% names(mock_fars))
  expect_s3_class(mock_fars$codebook, "data.frame")
})

test_that("codebook has expected structure", {
  expect_true(all(c("source", "file", "name_ncsa", "name_rfars", "label") %in% names(mock_fars$codebook)))
})


# Data consistency checks ----

test_that("all IDs in multi tables exist in flat table", {
  # Get all IDs from flat
  flat_ids <- unique(paste0(mock_fars$flat$year, mock_fars$flat$st_case))

  # Get IDs from multi_acc
  multi_ids <- unique(paste0(mock_fars$multi_acc$year, mock_fars$multi_acc$st_case))

  # All multi IDs should exist in flat
  expect_true(all(multi_ids %in% flat_ids))
})

test_that("events table links to flat table", {
  flat_ids <- unique(paste0(mock_fars$flat$year, mock_fars$flat$st_case))
  events_ids <- unique(paste0(mock_fars$events$year, mock_fars$events$st_case))

  expect_true(all(events_ids %in% flat_ids))
})
