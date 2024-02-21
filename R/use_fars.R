#' (Internal) Use FARS data files
#'
#' Compile multiple years of prepared FARS data.
#'
#' @param dir Inherits from get_fars().
#' @param prepared_dir Inherits from get_fars().
#' @param cache Inherits from get_fars().
#'
#' @return Returns an object of class 'FARS' which is a list of six tibbles:
#'     flat, multi_acc, multi_veh, multi_per, events, and codebook.
#'
#' @details The `inj_sev` data through 2016 contains the typo `Injury(…)` (no whitespace),
#'     while data from 2017 onwards contains `Injury (…)` (correct space).
#'     Also, the order of months is alphabetical rather than chronological.
#'     Both these inconsistencies are cleaned up automatically.

use_fars <- function(dir, prepared_dir, cache){


  flat <-

    suppressWarnings({ #this is just for the small number of coercion errors with mutate_at(lat, lon, as.numeric)

      suppressMessages({

        data.frame(path = list.files(prepared_dir, full.names = TRUE, pattern = "_flat.rds", recursive = TRUE)) %>%
        mutate(year = stringr::word(.data$path, -1, sep = "/") %>% substr(1,4)) %>%
        pull(.data$path) %>%
        lapply(function(x){
          readRDS(x) %>%
          mutate_all(as.character)
          }) %>%
        bind_rows() %>%
        readr::type_convert() %>%
        distinct() %>%
        mutate(
          month = factor(month, levels = month.name, ordered = TRUE),
          inj_sev = gsub('Injury(', 'Injury (', inj_sev, fixed = TRUE)
        )

      })

    })


  multi_acc <- import_multi("multi_acc.rds", where = prepared_dir) #%>% distinct()
  multi_veh <- import_multi("multi_veh.rds", where = prepared_dir) #%>% distinct()
  multi_per <- import_multi("multi_per.rds", where = prepared_dir) #%>% distinct()
  events    <- import_multi("_events.rds",   where = prepared_dir) #%>% distinct()

  codebook <- readRDS(file = paste0(prepared_dir, "/codebook.rds")) #%>% distinct()

  out <- list(
    "flat"      = flat,
    "multi_acc" = multi_acc,
    "multi_veh" = multi_veh,
    "multi_per" = multi_per,
    "events"    = events,
    "codebook"  = codebook
    )

  class(out) <- c(class(out), "FARS")

  if(!is.null(cache)){
    saveRDS(out,
            gsub("//", "/", paste0(dir, "/", cache))
            )
    }

  return(out)

  }
