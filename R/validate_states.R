#' (Internal) Validate user-provided list of states
#'
#' @param states States specified in get_fars, prep_fars, or counts


validate_states <- function(states){

  if(!is.null(states)){

    for(state in states){

        state_check <-
          state %in% unique(c(
            rfars::geo_relations$state_name_abbr,
            rfars::geo_relations$state_name_full,
            rfars::geo_relations$fips_state
            )
            )

        if(!state_check) stop(paste0("'", state, "' not recognized. Please check rfars::geo_relations for valid ways to specify states (state_name_abbr, state_name_full, or fips_state)."))

    }
    }

}
