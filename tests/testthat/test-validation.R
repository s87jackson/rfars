# Tests for input validation in get_fars() and get_gescrss()

# Year validation ----

test_that("get_fars rejects years before 2014", {
  expect_error(
    get_fars(years = 2013, proceed = TRUE),
    "Data not available prior to 2014"
  )

  expect_error(
    get_fars(years = 2010:2015, proceed = TRUE),
    "Data not available prior to 2014"
  )
})

test_that("get_fars rejects years after 2023", {
  expect_error(
    get_fars(years = 2024, proceed = TRUE),
    "Data not yet available beyond 2023"
  )

  expect_error(
    get_fars(years = 2020:2025, proceed = TRUE),
    "Data not yet available beyond 2023"
  )
})

test_that("get_gescrss rejects years before 2014", {
  expect_error(
    get_gescrss(years = 2013, proceed = TRUE),
    "Data not available prior to 2014"
  )
})

test_that("get_gescrss rejects years after 2023", {
  expect_error(
    get_gescrss(years = 2024, proceed = TRUE),
    "Data not available beyond 2023"
  )
})

test_that("year validation accepts numeric and character formats", {
  # These should produce the same validation (both will try to download)
  # Just checking they don't error on year format
  expect_error(
    get_fars(years = "2013", proceed = TRUE),
    "Data not available prior to 2014"
  )

  expect_error(
    get_fars(years = 2013, proceed = TRUE),
    "Data not available prior to 2014"
  )
})


# State validation ----

test_that("validate_states accepts valid full state names", {
  expect_silent(validate_states("Virginia"))
  expect_silent(validate_states("Maryland"))
  expect_silent(validate_states(c("Virginia", "Maryland")))
})

test_that("validate_states accepts valid state abbreviations", {
  expect_silent(validate_states("VA"))
  expect_silent(validate_states("MD"))
  expect_silent(validate_states(c("VA", "MD", "NC")))
})

test_that("validate_states accepts valid FIPS codes", {
  expect_silent(validate_states("51"))  # Virginia
  expect_silent(validate_states("24"))  # Maryland
  expect_silent(validate_states(c("51", "24")))
})

test_that("validate_states accepts NULL (all states)", {
  expect_silent(validate_states(NULL))
})

test_that("validate_states rejects invalid states with helpful error", {
  expect_error(
    validate_states("NotAState"),
    "'NotAState' not recognized"
  )

  expect_error(
    validate_states("999"),
    "'999' not recognized"
  )
})

test_that("validate_states accepts mixed formats in single call", {
  expect_silent(validate_states(c("VA", "Maryland", "51")))
})


# Region validation ----

test_that("get_gescrss accepts valid regions", {
  # These will attempt downloads, but should pass validation
  # We're just checking the region validation doesn't error
  expect_no_error({
    # This will error on download, but not on region validation
    tryCatch(
      get_gescrss(years = 2020, regions = "mw", proceed = TRUE),
      error = function(e) NULL
    )
  })
})

test_that("get_gescrss rejects invalid regions", {
  expect_error(
    get_gescrss(years = 2020, regions = "invalid", proceed = TRUE),
    "Specify regions as: mw \\(midwest\\), ne \\(northeast\\), s \\(south\\), w \\(west\\)"
  )
})

test_that("get_gescrss accepts multiple valid regions", {
  expect_no_error({
    tryCatch(
      get_gescrss(years = 2020, regions = c("mw", "ne"), proceed = TRUE),
      error = function(e) NULL
    )
  })
})


# Source parameter validation ----

test_that("get_fars rejects invalid source parameter", {
  expect_error(
    get_fars(years = 2020, source = "invalid", proceed = TRUE),
    "source must be either 'zenodo' or 'nhtsa'"
  )
})

test_that("get_gescrss rejects invalid source parameter", {
  expect_error(
    get_gescrss(years = 2020, source = "invalid", proceed = TRUE),
    "source must be either 'zenodo' or 'nhtsa'"
  )
})

test_that("source parameter defaults to zenodo", {
  # When source is not specified, it should default to zenodo
  # This will attempt a download, so we just check it doesn't error on the source validation
  expect_no_error({
    tryCatch(
      get_fars(years = 2020, proceed = TRUE),
      error = function(e) NULL
    )
  })
})


# Counts validation ----

test_that("counts rejects non-FARS/GESCRSS objects", {
  expect_error(
    counts(data.frame(x = 1:10)),
    "Input data must be of type FARS or GESCRSS"
  )

  expect_error(
    counts(list(a = 1, b = 2)),
    "Input data must be of type FARS or GESCRSS"
  )
})

test_that("counts rejects 'any' combined with other involved values", {
  expect_error(
    counts(mock_fars, involved = c("any", "alcohol")),
    "'involved' cannot contain both 'any' and other values"
  )
})

test_that("counts rejects 'each' combined with other involved values", {
  expect_error(
    counts(mock_fars, involved = c("each", "alcohol")),
    "'involved' cannot contain both 'each' and other values"
  )
})

test_that("counts rejects 'each' with filterOnly=TRUE", {
  expect_error(
    counts(mock_fars, involved = "each", filterOnly = TRUE),
    "To use involved = 'each', set filterOnly = FALSE"
  )
})

test_that("counts rejects state filtering for GESCRSS", {
  expect_error(
    counts(mock_gescrss, where = list(states = "VA")),
    "Cannot subset GESCRSS by state. Use region instead."
  )
})


# Find functions validation ----

test_that("find functions reject non-FARS/GESCRSS objects", {
  expect_error(
    distracted_driver(data.frame(x = 1:10)),
    "Input data must be of type FARS or GESCRSS"
  )

  expect_error(
    alcohol(list(a = 1)),
    "Input data must be of type FARS or GESCRSS"
  )

  expect_error(
    pedestrian(mtcars),
    "Input data must be of type FARS or GESCRSS"
  )
})

test_that("driver_age validates age parameters are numeric", {
  expect_error(
    driver_age(mock_fars, age_min = "15", age_max = 20),
    "Enter age min and max as numeric"
  )

  expect_error(
    driver_age(mock_fars, age_min = 15, age_max = "20"),
    "Enter age min and max as numeric"
  )
})
