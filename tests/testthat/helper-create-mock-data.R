# Helper functions to create mock FARS data for testing

#' Create a minimal mock FARS object for testing
#'
#' @return A FARS object with all expected structure but minimal data
create_mock_fars <- function() {

  # Create minimal flat data
  flat <- data.frame(
    year = c(2020, 2020, 2020, 2021, 2021),
    state = factor(c("Virginia", "Virginia", "Maryland", "Virginia", "Maryland")),
    st_case = c(100001, 100002, 200001, 100001, 200001),
    id = c(2020100001, 2020100002, 2020200001, 2021100001, 2021200001),
    veh_no = c(1, 1, 1, 1, 1),
    per_no = c(1, 1, 1, 1, 1),
    county = c(51, 51, 24, 51, 24),
    city = c(100, 200, 300, 100, 300),
    lon = c(-77.5, -77.6, -76.6, -77.5, -76.6),
    lat = c(38.0, 38.1, 39.3, 38.0, 39.3),
    month = factor(c("January", "February", "March", "January", "February")),
    rur_urb = factor(c("Rural", "Urban", "Urban", "Rural", "Urban")),
    per_typ = factor(c(
      "Driver of a Motor Vehicle In-Transport",
      "Pedestrian",
      "Bicyclist",
      "Driver of a Motor Vehicle In-Transport",
      "Passenger of a Motor Vehicle In-Transport"
    )),
    inj_sev = factor(c(
      "Fatal Injury (K)",
      "Fatal Injury (K)",
      "Suspected Serious Injury (A)",
      "Fatal Injury (K)",
      "Suspected Minor Injury (B)"
    )),
    age = c("25", "45", "32", "68", "12"),
    speedrel = factor(c("Yes", "No", "No", "No", "Yes")),
    body_typ = factor(c(
      "Passenger Car",
      NA,
      NA,
      "Single-unit straight truck or Cab-Chassis (GVWR > 26,000 lbs.)",
      "Passenger Car"
    )),
    alc_res = c("0.15", "0.00", "0.00", "0.00", "0.00"),
    dr_drink = factor(c("Yes", NA, NA, "No", NA)),
    drugs = factor(c("No", NA, NA, "Yes", NA)),
    hit_run = factor(c("No", "Yes", "No", "No", "No")),
    rollover = factor(c("No Rollover", "No Rollover", "Rollover - Tripped", "No Rollover", "No Rollover")),
    tow_veh = factor(c(NA, NA, NA, "One Trailing Unit", NA)),
    stringsAsFactors = FALSE
  )

  # Create multi_acc data
  multi_acc <- data.frame(
    state = factor(c("Virginia", "Virginia", "Maryland")),
    st_case = as.character(c(100001, 100002, 200001)),
    name = factor(c("weather1", "weather1", "crashrf")),
    value = factor(c("Clear", "Rain", "Police Pursuit Involved")),
    year = factor(c(2020, 2020, 2020)),
    stringsAsFactors = FALSE
  )

  # Create multi_veh data
  multi_veh <- data.frame(
    state = factor(c("Virginia", "Virginia", "Maryland")),
    st_case = as.character(c(100001, 100002, 200001)),
    veh_no = c(1, 1, 1),
    name = factor(c("drdistract", "drdistract", "mdrdstrd")),
    value = factor(c("Looked But Did Not See", "Not Distracted", "Talking or Listening to Cellular Phone")),
    year = factor(c(2020, 2020, 2020)),
    stringsAsFactors = FALSE
  )

  # Create multi_per data
  multi_per <- data.frame(
    state = factor(c("Virginia", "Virginia", "Maryland")),
    st_case = as.character(c(100001, 100002, 200001)),
    veh_no = c(1, 1, 1),
    per_no = c(1, 1, 1),
    name = factor(c("race", "race", "personrf")),
    value = factor(c("White", "Black or African American", "None")),
    year = factor(c(2020, 2020, 2020)),
    stringsAsFactors = FALSE
  )

  # Create events data
  events <- data.frame(
    state = factor(c("Virginia", "Virginia", "Maryland", "Virginia")),
    st_case = as.character(c(100001, 100002, 200001, 100001)),
    veh_no = c(1, 1, 1, 1),
    veventnum = c(1, 1, 1, 2),
    vnumber1 = c(0, 0, 0, 2),
    vnumber2 = c(0, 0, 0, 0),
    soe = factor(c(
      "Motor Vehicle In-Transport",
      "Pedestrian",
      "Ran Off Roadway - Right",
      "Tree (Standing Only)"
    )),
    year = factor(c(2020, 2020, 2020, 2020)),
    stringsAsFactors = FALSE
  )

  # Create codebook data
  codebook <- data.frame(
    source = factor(c("FARS", "FARS", "FARS")),
    file = factor(c("accident", "vehicle", "person")),
    name_ncsa = factor(c("STATE", "VEH_NO", "PER_NO")),
    name_rfars = factor(c("state", "veh_no", "per_no")),
    label = factor(c("State Number", "Vehicle Number", "Person Number")),
    value = c("51", "1", "1"),
    value_label = c("Virginia", "Vehicle 1", "Person 1"),
    stringsAsFactors = FALSE
  )

  # Create FARS object
  fars_obj <- list(
    flat = flat,
    multi_acc = multi_acc,
    multi_veh = multi_veh,
    multi_per = multi_per,
    events = events,
    codebook = codebook
  )

  class(fars_obj) <- c("list", "FARS")

  return(fars_obj)
}


#' Create a minimal mock GESCRSS object for testing
#'
#' @return A GESCRSS object with all expected structure but minimal data
create_mock_gescrss <- function() {

  # Create minimal flat data with weights
  flat <- data.frame(
    year = c(2020, 2020, 2021),
    casenum = c(100001, 100002, 100001),
    id = c(2020100001, 2020100002, 2021100001),
    veh_no = c(1, 1, 1),
    per_no = c(1, 1, 1),
    region = factor(c("South", "Northeast", "South")),
    urbanicity = factor(c("urban area", "rural area", "urban area")),
    per_typ = factor(c(
      "Driver of a Motor Vehicle In-Transport",
      "Pedestrian",
      "Driver of a Motor Vehicle In-Transport"
    )),
    inj_sev = factor(c(
      "Fatal Injury (K)",
      "Suspected Serious Injury (A)",
      "Suspected Minor Injury (B)"
    )),
    weight = c(1000, 1500, 1200),
    stringsAsFactors = FALSE
  )

  # Create simplified multi files
  multi_acc <- data.frame(
    casenum = as.character(c(100001, 100002)),
    name = factor(c("weather", "weather")),
    value = factor(c("Clear", "Rain")),
    year = factor(c(2020, 2020)),
    stringsAsFactors = FALSE
  )

  multi_veh <- data.frame(
    casenum = as.character(c(100001, 100002)),
    veh_no = c(1, 1),
    name = factor(c("drdistract", "drdistract")),
    value = factor(c("Not Distracted", "Talking to Passenger")),
    year = factor(c(2020, 2020)),
    stringsAsFactors = FALSE
  )

  multi_per <- data.frame(
    casenum = as.character(c(100001, 100002)),
    veh_no = c(1, 1),
    per_no = c(1, 1),
    name = factor(c("race", "race")),
    value = factor(c("White", "Hispanic or Latino")),
    year = factor(c(2020, 2020)),
    stringsAsFactors = FALSE
  )

  events <- data.frame(
    casenum = as.character(c(100001, 100002)),
    veh_no = c(1, 1),
    veventnum = c(1, 1),
    soe = factor(c("Motor Vehicle In-Transport", "Pedestrian")),
    year = factor(c(2020, 2020)),
    stringsAsFactors = FALSE
  )

  codebook <- data.frame(
    source = factor(c("GESCRSS", "GESCRSS")),
    file = factor(c("accident", "vehicle")),
    name_ncsa = factor(c("CASENUM", "VEH_NO")),
    name_rfars = factor(c("casenum", "veh_no")),
    label = factor(c("Case Number", "Vehicle Number")),
    value = c("100001", "1"),
    value_label = c("Case 100001", "Vehicle 1"),
    stringsAsFactors = FALSE
  )

  # Create GESCRSS object
  gescrss_obj <- list(
    flat = flat,
    multi_acc = multi_acc,
    multi_veh = multi_veh,
    multi_per = multi_per,
    events = events,
    codebook = codebook
  )

  class(gescrss_obj) <- c("list", "GESCRSS")

  return(gescrss_obj)
}


#' Create a simple data frame for testing helper functions
create_test_df <- function() {
  data.frame(
    year = c(2020, 2020, 2021),
    st_case = c(100001, 100002, 100001),
    veh_no = c(1, 2, 1),
    per_no = c(1, 1, 1),
    original_var = c(1, 2, 3),
    imputed_var = c(1, 999, 3),
    stringsAsFactors = FALSE
  )
}
