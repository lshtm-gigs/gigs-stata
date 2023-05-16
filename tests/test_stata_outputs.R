compare_ig_nbs <- function(acronym, sex, z_or_p, interactive = FALSE) {
  sex_str <- if (sex == "M") "male" else if (sex == "F") "female"

  z_or_p_stata <- if (z_or_p == "z") "z2v"  else if (z_or_p == "p") "p2v"
  dta <- file.path("tests", "outputs", "ig_nbs",
            paste0(acronym, "_", z_or_p_stata, "_", sex_str, ".dta"))

  stata <- if (file.exists(dta)) foreign::read.dta(file = dta) else {
    is_bodycomp_z2v <- z_or_p_stata == "z2v" & (acronym %in% c("fmfga", "ffmfga", "bfpfga"))
    if (is_bodycomp_z2v) {
      cli::cli_alert_info(text = "File not found: {.file {dta}}")
      return(TRUE)
    } else {
      cli::cli_alert_danger(text = "File not found: {.file {dta}}")
      return(FALSE)
    }
  }

  z_or_p_r <- if (stringr::str_detect(z_or_p, pattern = "z")) {
    "zscores"
  } else {
    "percentiles"
  }
  reference <- gigs::ig_nbs[[acronym]][[sex_str]][[z_or_p_r]]
  if (sex == "M") {
    tolerance <- switch(acronym,
           fmfga = 7.0,
           ffmfga = 26,
           bfpfga = 0.5,
           0.003)
  } else if (sex == "F") {
    tolerance <- switch(acronym,
                        fmfga = 5.0,
                        ffmfga = 1,
                        bfpfga = 0.5,
                        0.003)
  }

  if (!all(is.na(stata)) & !is.null(reference)) {
    tryCatch(expr = {
      testthat::expect_equal(stata, reference,
                             check.attributes = FALSE,
                             tolerance = tolerance)
    }, error = function(e) {
      cli::cli_alert_danger(
        paste0(tools::toTitleCase(sex_str), " ", z_or_p_r, " in ", acronym,
               ": ", cli::col_red("failed"))
      )
      return(FALSE)
    }, finally = {
      cli::cli_alert_success(
        paste0(tools::toTitleCase(sex_str), " ", z_or_p_r, " in ", acronym,
               ": ", cli::col_green("succeeded"))
      )
      return(TRUE)
    })
  }
}

compare_ig_png <- function(acronym, sex, z_or_p, interactive = FALSE) {
  sex_str <- if (sex == "M") "male" else if (sex == "F") "female"

  z_or_p_stata <- if (z_or_p == "z") "z2v"  else if (z_or_p == "p") "p2v"
  dta <- file.path("tests", "outputs", "ig_png",
            paste0(acronym, "_", z_or_p_stata, "_", sex_str, ".dta"))

  stata <- if (file.exists(dta)) foreign::read.dta(file = dta) else {
      cat("\t")
      cli::cli_alert_danger("File not found: {dta}\n")
      return(FALSE)
  }

  z_or_p_r <- if (stringr::str_detect(z_or_p, pattern = "z")) {
    "zscores"
  } else {
    "percentiles"
  }
  reference <- gigs::ig_png[[acronym]][[sex_str]][[z_or_p_r]]
  tolerance <- 0.01

  if (!all(is.na(stata)) & !is.null(reference)) {
    tryCatch(expr = {
      testthat::expect_equal(stata, reference,
                             check.attributes = FALSE,
                             tolerance = tolerance)
    }, error = function(e) {
      cat("\t")
      cli::cli_alert_danger(paste0(tools::toTitleCase(sex_str), " ", z_or_p_r,
                                    " in ", acronym,  ": ",
                                   cli::col_red("failed")))
      return(FALSE)
    }, finally = {
      cat("\t")
      cli::cli_alert_success(paste0(tools::toTitleCase(sex_str), " ", z_or_p_r,
                                    " in ", acronym,
                                    ": ", cli::col_green("succeeded")))
      return(TRUE)
    })
  }
}

compare_who_gs <- function(acronym, sex, z_or_p, interactive = FALSE) {
  sex_str <- if (sex == "M") "male" else if (sex == "F") "female"

  z_or_p_stata <- if (z_or_p == "z") "z2v"  else if (z_or_p == "p") "p2v"
  dta <- file.path("tests", "outputs", "who_gs",
            paste0(acronym, "_", z_or_p_stata, "_", sex_str, ".dta"))

  stata <- if (file.exists(dta)) foreign::read.dta(file = dta) else {
      cat("\t")
      cli::cli_alert_danger(text = "File not found: {.file dta}")
      return(FALSE)
  }

  z_or_p_r <- if (stringr::str_detect(z_or_p, pattern = "z")) {
    "zscores"
  } else {
    "percentiles"
  }
  reference <- gigs::who_gs[[acronym]][[sex_str]][[z_or_p_r]]
  tolerance <- 0.01

  if (!all(is.na(stata)) & !is.null(reference)) {
    tryCatch(expr = {
      testthat::expect_equal(stata, reference,
                             check.attributes = FALSE,
                             tolerance = tolerance)
    }, error = function(e) {
      cat("\t")
      cli::cli_alert_danger(paste0(tools::toTitleCase(sex_str), " ", z_or_p_r,
                                   " in ", acronym,  ": ",
                                   cli::col_red("failed")))
      return(FALSE)
    }, finally = {
      cat("\t")
      cli::cli_alert_success(paste0(tools::toTitleCase(sex_str), " ", z_or_p_r,
                                    " in ", acronym,  ": ",
                                    cli::col_green("succeeded")))
      return(TRUE)
    })
  }
}


cli::cli_h1(text = "INTERGROWTH-21st Newborn Size Standards")
acronyms <- rep.int(names(gigs::ig_nbs), times = rep(2, length(names(gigs::ig_nbs))))
sexes <- rep_len(c("M", "F"), length.out = length(acronyms))
zp <- rep_len(c("z", "p"), length.out = length(acronyms))
ig_nbs <- mapply(FUN = compare_ig_nbs, acronyms, sexes, zp)

cli::cli_h1(text = "INTERGROWTH-21st Postnatal Growth Standards")
acronyms <- rep.int(names(gigs::ig_png), times = rep(2, length(names(gigs::ig_png))))
sexes <- rep_len(c("M", "F"), length.out = length(acronyms))
zp <- rep_len(c("z", "p"), length.out = length(acronyms))
ig_png <- mapply(FUN = compare_ig_png, acronyms, sexes, zp)

cli::cli_h1(text = "WHO Child Growth Standards")
acronyms <- rep.int(names(gigs::who_gs), times = rep(2, length(names(gigs::who_gs))))
sexes <- rep_len(c("M", "F"), length.out = length(acronyms))
zp <- rep_len(c("z", "p"), length.out = length(acronyms))
who_gs <- mapply(FUN = compare_who_gs, acronyms, sexes, zp)