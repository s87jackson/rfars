# Setup file for testthat
# This file is run once before all tests

# Load test fixtures (real FARS/GESCRSS data, sampled to small size)
# NOTE: Fixtures are created by data-raw/create-test-fixtures.R
fixture_dir <- testthat::test_path("fixtures")

# Check if fixtures exist
fars_fixture <- file.path(fixture_dir, "test_fars.rds")
gescrss_fixture <- file.path(fixture_dir, "test_gescrss.rds")

if (!file.exists(fars_fixture) || !file.exists(gescrss_fixture)) {
  stop(
    "Test fixtures not found. Please run data-raw/create-test-fixtures.R first.\n",
    "This script downloads real data and creates small test fixtures.\n",
    "Run: source('data-raw/create-test-fixtures.R')"
  )
}

# Load fixtures for all tests
test_fars <- readRDS(fars_fixture)
test_gescrss <- readRDS(gescrss_fixture)

# Also keep the old names for backward compatibility with tests already written
mock_fars <- test_fars
mock_gescrss <- test_gescrss

# Store original options
original_options <- options()
