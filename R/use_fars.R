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
        data.table::rbindlist(fill = TRUE) %>%
        readr::type_convert() %>%
        distinct()

      })

    })

  # Rearrange
  flat <-
    bind_cols(
      select(flat,
             -.data$a1, -.data$a2, -.data$a3, -.data$a4, -.data$a5, -.data$a6, -.data$a7, -.data$a8, -.data$a9, -.data$a10,
             -.data$p1, -.data$p2, -.data$p3, -.data$p4, -.data$p5, -.data$p6, -.data$p7, -.data$p8, -.data$p9, -.data$p10),
      select(flat,
             .data$a1, .data$a2, .data$a3, .data$a4, .data$a5, .data$a6, .data$a7, .data$a8, .data$a9, .data$a10,
             .data$p1, .data$p2, .data$p3, .data$p4, .data$p5, .data$p6, .data$p7, .data$p8, .data$p9, .data$p10)
    )


  multi_acc <- import_multi("multi_acc.rds", where = prepared_dir) #%>% distinct()
  multi_veh <- import_multi("multi_veh.rds", where = prepared_dir) #%>% distinct()
  multi_per <- import_multi("multi_per.rds", where = prepared_dir) #%>% distinct()
  events    <- import_multi("_events.rds",   where = prepared_dir) #%>% distinct()

  codebook <- readRDS(file = paste0(prepared_dir, "/codebook.rds")) #%>% distinct()

  myReqs <- function(x) ifelse(is.character(x) & n_distinct(x)<1000, TRUE, FALSE)

  out <- list(
    "flat"      = flat %>% mutate_if(myReqs, factor),
    "multi_acc" = multi_acc %>% mutate_if(myReqs, factor),
    "multi_veh" = multi_veh %>% mutate_if(myReqs, factor),
    "multi_per" = multi_per %>% mutate_if(myReqs, factor),
    "events"    = events %>% mutate_if(myReqs, factor),
    "codebook"  = codebook %>% mutate_if(is.character, factor)
    )

  class(out) <- c(class(out), "FARS")

  if(!is.null(cache)){
    saveRDS(out,
            gsub("//", "/", paste0(dir, "/", cache))
            )
    }

  gc(verbose = F)

  return(out)

  }
