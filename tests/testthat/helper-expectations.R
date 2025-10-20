# Custom expectations for rfars testing

#' Expect a valid FARS object
#'
#' @param obj The object to test
expect_fars_object <- function(obj) {
  # Check class
  expect_s3_class(obj, "FARS")

  # Check structure - should have 6 elements
  expect_named(obj, c("flat", "multi_acc", "multi_veh", "multi_per", "events", "codebook"))

  # Check each element is a data frame
  expect_s3_class(obj$flat, "data.frame")
  expect_s3_class(obj$multi_acc, "data.frame")
  expect_s3_class(obj$multi_veh, "data.frame")
  expect_s3_class(obj$multi_per, "data.frame")
  expect_s3_class(obj$events, "data.frame")
  expect_s3_class(obj$codebook, "data.frame")

  # Check flat has required columns
  expect_true(all(c("year", "state", "st_case", "id") %in% names(obj$flat)))

  # Check multi files have required columns
  expect_true(all(c("state", "st_case", "year", "name", "value") %in% names(obj$multi_acc)))
  expect_true(all(c("state", "st_case", "veh_no", "year", "name", "value") %in% names(obj$multi_veh)))
  expect_true(all(c("state", "st_case", "veh_no", "per_no", "year", "name", "value") %in% names(obj$multi_per)))

  # Check events has required columns
  expect_true(all(c("state", "st_case", "veh_no", "year") %in% names(obj$events)))

  # Check codebook structure
  expect_true(all(c("source", "file", "name_ncsa", "name_rfars", "label") %in% names(obj$codebook)))
}


#' Expect a valid GESCRSS object
#'
#' @param obj The object to test
expect_gescrss_object <- function(obj) {
  # Check class
  expect_s3_class(obj, "GESCRSS")

  # Check structure - should have 6 elements
  expect_named(obj, c("flat", "multi_acc", "multi_veh", "multi_per", "events", "codebook"))

  # Check each element is a data frame
  expect_s3_class(obj$flat, "data.frame")
  expect_s3_class(obj$multi_acc, "data.frame")
  expect_s3_class(obj$multi_veh, "data.frame")
  expect_s3_class(obj$multi_per, "data.frame")
  expect_s3_class(obj$events, "data.frame")
  expect_s3_class(obj$codebook, "data.frame")

  # Check flat has required columns (GESCRSS uses casenum, not st_case)
  expect_true(all(c("year", "casenum", "id", "weight") %in% names(obj$flat)))

  # Check multi files have required columns (GESCRSS uses casenum)
  expect_true(all(c("casenum", "year", "name", "value") %in% names(obj$multi_acc)))
  expect_true(all(c("casenum", "veh_no", "year", "name", "value") %in% names(obj$multi_veh)))
  expect_true(all(c("casenum", "veh_no", "per_no", "year", "name", "value") %in% names(obj$multi_per)))

  # Check events has required columns
  expect_true(all(c("casenum", "veh_no", "year") %in% names(obj$events)))
}


#' Expect a valid counts output
#'
#' @param obj The object to test
#' @param interval Expected interval ("year" or "month")
expect_counts_output <- function(obj, interval = "year") {
  # Check it's a data frame
  expect_s3_class(obj, "data.frame")

  # Check required columns exist
  expect_true("n" %in% names(obj))
  expect_true(interval %in% names(obj))

  # Check metadata columns
  expect_true(all(c("what", "states", "region", "urb", "who", "involved") %in% names(obj)))

  # Check n is numeric
  expect_type(obj$n, "integer")

  # Check no NA values in n
  expect_false(any(is.na(obj$n)))
}


#' Expect a valid year-id data frame (from find functions)
#'
#' @param obj The object to test
expect_year_id_df <- function(obj) {
  # Check it's a data frame
  expect_s3_class(obj, "data.frame")

  # Check required columns
  expect_named(obj, c("year", "id"))

  # Check both are numeric
  expect_type(obj$year, "double")
  expect_type(obj$id, "double")

  # Check no duplicates
  expect_equal(nrow(obj), nrow(dplyr::distinct(obj)))
}
