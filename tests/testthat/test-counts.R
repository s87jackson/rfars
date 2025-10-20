# Tests for counts() function in R/counts.R
# This is the most complex function with many parameters

# Basic functionality ----

test_that("counts returns a data frame by default", {
  result <- counts(mock_fars)
  expect_s3_class(result, "data.frame")
})

test_that("counts has required output columns", {
  result <- counts(mock_fars)
  expect_counts_output(result, interval = "year")
})

test_that("counts default is crashes by year", {
  result <- counts(mock_fars)
  expect_true("year" %in% names(result))
  expect_equal(result$what[1], "crashes")
})


# What parameter ----

test_that("counts crashes correctly", {
  result <- counts(mock_fars, what = "crashes")

  expect_equal(result$what[1], "crashes")
  expect_true("n" %in% names(result))
  expect_type(result$n, "integer")
})

test_that("counts fatalities correctly", {
  result <- counts(mock_fars, what = "fatalities")

  expect_equal(result$what[1], "fatalities")
  # Should only count those with Fatal Injury (K)
  expect_true(all(result$n >= 0))
})

test_that("counts injuries correctly", {
  result <- counts(mock_fars, what = "injuries")

  expect_equal(result$what[1], "injuries")
  expect_true(all(result$n >= 0))
})

test_that("counts people correctly", {
  result <- counts(mock_fars, what = "people")

  expect_equal(result$what[1], "people")
  expect_true(all(result$n >= 0))
})

test_that("fatalities counts only Fatal Injury (K)", {
  result <- counts(mock_fars, what = "fatalities")

  manual_count <- mock_fars$flat %>%
    dplyr::filter(inj_sev == "Fatal Injury (K)") %>%
    distinct(year, id, veh_no, per_no) %>%
    group_by(year) %>%
    summarize(n = n())

  expect_equal(sum(result$n), sum(manual_count$n))
})


# Interval parameter ----

test_that("counts by year creates year column", {
  result <- counts(mock_fars, interval = "year")

  expect_true("year" %in% names(result))
  expect_false("month" %in% names(result))
})

test_that("counts by month creates month column", {
  result <- counts(mock_fars, interval = "month")

  expect_true("month" %in% names(result))
})

test_that("counts by year and month create year and month columns", {
  result <- counts(mock_fars, interval = c("year", "month"))

  expect_true("year" %in% names(result))
  expect_true("month" %in% names(result))
})

test_that("month output uses abbreviated month names", {
  result <- counts(mock_fars, interval = "month")

  if (nrow(result) > 0) {
    expect_true(all(result$month %in% month.abb))
    expect_s3_class(result$month, "ordered")
  }
})



# Where parameter - states ----

test_that("counts filters by state for FARS", {
  result <- counts(mock_fars, where = list(states = "Virginia"))

  expect_s3_class(result, "data.frame")
  expect_equal(result$states[1], "Virginia")
})

test_that("counts filters by multiple states for FARS", {
  result <- counts(mock_fars, where = list(states = c("Virginia", "Maryland")))

  expect_s3_class(result, "data.frame")
  # Mock has both VA and MD
  expect_true(sum(result$n) >= 1)
})

test_that("counts handles state abbreviations", {
  result <- counts(mock_fars, where = list(states = "VA"))

  expect_s3_class(result, "data.frame")
  expect_equal(result$states[1], "VA")
})

test_that("counts defaults to all states when not specified", {
  result <- counts(mock_fars)

  expect_equal(result$states[1], "all")
})


# Where parameter - region ----

test_that("counts filters by region for GESCRSS", {
  result <- counts(mock_gescrss, where = list(region = "s"))

  expect_s3_class(result, "data.frame")
  expect_equal(result$region[1], "s")
})

test_that("counts filters by region for FARS", {
  # FARS can also be filtered by region
  result <- counts(mock_fars, where = list(region = "s"))

  expect_s3_class(result, "data.frame")
  expect_equal(result$region[1], "s")
})

test_that("counts handles multiple regions", {
  result <- counts(mock_gescrss, where = list(region = c("s", "ne")))

  expect_s3_class(result, "data.frame")
})


# Where parameter - urbanicity ----

test_that("counts filters by rural for FARS", {
  result <- counts(mock_fars, where = list(urb = "rural"))

  expect_s3_class(result, "data.frame")
  expect_equal(result$urb[1], "rural")
})

test_that("counts filters by urban for FARS", {
  result <- counts(mock_fars, where = list(urb = "urban"))

  expect_s3_class(result, "data.frame")
  expect_equal(result$urb[1], "urban")
})

test_that("counts filters by urbanicity for GESCRSS", {
  result <- counts(mock_gescrss, where = list(urb = "urban"))

  expect_s3_class(result, "data.frame")
  expect_equal(result$urb[1], "urban")
})

test_that("counts defaults to all urbanicity when not specified", {
  result <- counts(mock_fars)

  expect_equal(result$urb[1], "all")
})


# Where parameter - unspecified elements default to 'all' ----

test_that("counts handles partially specified where parameter", {
  result <- counts(mock_fars, where = list(states = "Virginia"))

  expect_equal(result$states[1], "Virginia")
  expect_equal(result$region[1], "all")
  expect_equal(result$urb[1], "all")
})


# Who parameter ----

test_that("counts filters by drivers", {
  result <- counts(mock_fars, who = "drivers")

  expect_equal(result$who[1], "drivers")
  expect_s3_class(result, "data.frame")
})

test_that("counts filters by passengers", {
  result <- counts(mock_fars, who = "passengers")

  expect_equal(result$who[1], "passengers")
  expect_s3_class(result, "data.frame")
})

test_that("counts filters by pedestrians", {
  result <- counts(mock_fars, who = "pedestrians")

  expect_equal(result$who[1], "pedestrians")
  expect_s3_class(result, "data.frame")
})

test_that("counts filters by bicyclists", {
  result <- counts(mock_fars, who = "bicyclists")

  expect_equal(result$who[1], "bicyclists")
  expect_s3_class(result, "data.frame")
})

test_that("counts defaults to all people when who not specified", {
  result <- counts(mock_fars)

  expect_equal(result$who[1], "all")
})


# Involved parameter - single factors ----

test_that("counts with involved='any' produces general counts", {
  result <- counts(mock_fars, involved = "any")

  expect_equal(result$involved[1], "any")
  expect_s3_class(result, "data.frame")
})

test_that("counts with involved='alcohol' filters correctly", {
  suppressMessages({
    result <- counts(mock_fars, involved = "alcohol")
  })

  expect_equal(result$involved[1], "alcohol")
  expect_s3_class(result, "data.frame")
})

test_that("counts with involved='speeding' filters correctly", {
  result <- counts(mock_fars, involved = "speeding")

  expect_equal(result$involved[1], "speeding")
  expect_s3_class(result, "data.frame")
})

test_that("counts with involved='pedestrian' filters correctly", {
  result <- counts(mock_fars, involved = "pedestrian")

  expect_equal(result$involved[1], "pedestrian")
  expect_true(sum(result$n) >= 1)
})


# Involved parameter - multiple factors ----

test_that("counts with multiple involved factors uses AND logic", {
  result <- counts(mock_fars, involved = c("speeding", "alcohol"))

  expect_equal(result$involved[1], "speeding AND alcohol")
  expect_s3_class(result, "data.frame")
})


# Involved parameter - 'each' ----

test_that("counts with involved='each' produces separate counts per factor", {
  result <- counts(mock_fars, involved = "each")

  expect_s3_class(result, "data.frame")
  expect_true("involved" %in% names(result))

  # Should have multiple rows for different involvement types
  expect_true(length(unique(result$involved)) > 1)
})

test_that("counts with involved='each' includes all factor types", {
  result <- counts(mock_fars, involved = "each")

  # Should include various types like alcohol, speeding, etc.
  expect_true(nrow(result) >= 10)  # At least several different types
})


# filterOnly parameter ----

test_that("counts with filterOnly=TRUE returns filtered flat tibble", {
  result <- counts(mock_fars, filterOnly = TRUE)

  expect_s3_class(result, "data.frame")
  # Should return flat file structure, not counts
  expect_true(all(c("year", "id", "state") %in% names(result)))
  expect_false("n" %in% names(result))
})

test_that("counts with filterOnly=FALSE returns counts", {
  result <- counts(mock_fars, filterOnly = FALSE)

  expect_s3_class(result, "data.frame")
  expect_true("n" %in% names(result))
})

test_that("filterOnly preserves filtering parameters", {
  result <- counts(mock_fars, where = list(states = "Virginia"), filterOnly = TRUE)

  # All returned rows should be from Virginia
  expect_true(all(result$state == "Virginia"))
})


# GESCRSS-specific functionality ----

test_that("counts uses weights for GESCRSS crashes", {
  result <- counts(mock_gescrss, what = "crashes")

  expect_s3_class(result, "data.frame")
  expect_true("n" %in% names(result))

  # Result should be sum of weights, not row count
  # Mock GESCRSS has 3 rows with weights 1000, 1500, 1200
  # With distinct IDs, should sum appropriately
  expect_true(result$n[1] > nrow(mock_gescrss$flat))
})

test_that("counts uses weights for GESCRSS people", {
  result <- counts(mock_gescrss, what = "people")

  expect_s3_class(result, "data.frame")
  # Should sum weights
  expect_type(result$n, "double")
})


# Output structure ----

test_that("counts output has proper column order", {
  result <- counts(mock_fars)

  # Should have interval first, then metadata
  col_names <- names(result)
  expect_true(which(col_names == "year") < which(col_names == "what"))
  expect_true(which(col_names == "what") < which(col_names == "n"))
})

test_that("counts output is properly ordered by interval", {
  result <- counts(mock_fars, interval = "year")

  # Should be ordered by year
  expect_equal(result$year, sort(result$year))
})

test_that("counts output includes all metadata columns", {
  result <- counts(mock_fars)

  expect_true(all(c("what", "states", "region", "urb", "who", "involved", "n") %in% names(result)))
})


# Integration tests - combining parameters ----

test_that("counts handles complex parameter combinations", {
  suppressMessages({
    result <- counts(
      mock_fars,
      what = "fatalities",
      interval = "year",
      where = list(states = "Virginia"),
      who = "drivers",
      involved = "alcohol"
    )
  })

  expect_counts_output(result)
  expect_equal(result$what[1], "fatalities")
  expect_equal(result$states[1], "Virginia")
  expect_equal(result$urb[1], "all")
  expect_equal(result$who[1], "drivers")
  expect_equal(result$involved[1], "alcohol")
})

test_that("counts with month interval and involved='each' works", {
  result <- counts(mock_fars, interval = "month", involved = "each")

  expect_s3_class(result, "data.frame")
  expect_true("month" %in% names(result))
  expect_true(length(unique(result$involved)) > 1)
})


# Edge cases ----

test_that("counts handles empty filter results gracefully", {
  # Filter to something that doesn't exist
  result <- counts(mock_fars, where = list(states = "Virginia", urb = "rural"), who = "bicyclists")

  expect_s3_class(result, "data.frame")
  # May have 0 counts but should still return structure
  expect_true("n" %in% names(result))
})
