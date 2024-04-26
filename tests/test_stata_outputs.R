cli_redbold <- function(text) cli::col_red(cli::style_bold(text))

compare_ig_fet <- function(acronym, z_or_c) {
  dta_dir <- file.path("tests", "outputs", "ig_fet")
  dta_path <- file.path(dta_dir, paste0(acronym, "_", z_or_c, ".dta"))
  stata <- if (file.exists(dta_path)) haven::read_dta(file = dta_path) else {
      cat("\t")
      cli::cli_alert_danger(text = "File not found: {.file {dta_path}}")
      return(FALSE)
  }

  dbl_z_or_c <- switch(
    z_or_c, z2v = -3:3, c2v = c(0.03, 0.05, 0.1, 0.5, 0.9, 0.95, 0.97)
  )

  roundto <- ifelse(test = acronym %in% c("pifga", "rifga", "sdrfga", "poffga",
                                 "sffga", "avfga", "pvfga", "cmfga", "gaftcd",
                                 "gwgfga"),
                    yes = 2,
                    no = ifelse(acronym %in% c("efwfga", "gafcrl"),
                                yes = 0, no = 1))

  # R implementation is already validated against z-score/centile tables
  z_or_c_r <- switch(z_or_c, z2v = "zscore", c2v = "centile")
  fn <- get(paste0("ig_fet_", acronym, "_", z_or_c_r, "2value"),
            envir = loadNamespace("gigs"))
  reference <- lapply(dbl_z_or_c, \(X) {
    round(fn(X, stata[[1]]), digits = roundto)
  }) |>
    do.call(what = "cbind") |>
    as.data.frame()
  stata <- stata[-1]

  chr_z_or_c <- switch(z_or_c, z2v = "Z-scores", c2v = "Centiles")
  paste0(chr_z_or_c, "s")
  if (!all(is.na(stata)) & !is.null(reference)) {
    cat("\t")
    tryCatch(expr = {
      testthat::expect_equal(stata, reference, tolerance = 0.01,
                             check.attributes = FALSE)
      cli::cli_alert_success(
        text = "{chr_z_or_c} in {acronym}: {cli::col_green('succeeded')}"
      )
      return(TRUE)
    }, error = function(e) {
      cli::cli_alert_danger(
        text = "{chr_z_or_c} in {acronym}: {cli_redbold(text = 'failed')}"
      )
      return(FALSE)
    })
  }
}

compare_ig_nbs <- function(acronym, sex, z_or_c) {
  sex_str <- if (sex == "M") "male" else if (sex == "F") "female"

  z_or_c_stata <- if (z_or_c == "z") "z2v" else if (z_or_c == "c") "c2v"
  dta <- file.path("tests", "outputs", "ig_nbs",
            paste0(acronym, "_", z_or_c_stata, "_", sex_str, ".dta"))

  stata <- if (file.exists(dta)) haven::read_dta(file = dta) else {
    is_bodycomp_z2v <- z_or_c_stata == "z2v" & (acronym %in% c("fmfga", "ffmfga", "bfpfga"))
    if (is_bodycomp_z2v) {
      cli::cli_alert_info(text = "File not found: {.file {dta}}")
      return(TRUE)
    } else {
      cli::cli_alert_danger(text = "File not found: {.file {dta}}")
      return(FALSE)
    }
  }

  z_or_p_r <- if (stringr::str_detect(z_or_c, pattern = "z")) {
    "z-scores"
  } else {
    "centiles"
  }
  reference <- gigs::ig_nbs[[acronym]][[sex_str]][[z_or_p_r]]
  if (sex == "M") {
    tolerance <- switch(acronym,
                        fmfga = 2,
                        ffmfga = 6,
                        bfpfga = 0.11,
                        0.003)
  } else if (sex == "F") {
    tolerance <- switch(acronym,
                        fmfga = 0,
                        ffmfga = 1,
                        bfpfga = 0.11,
                        0.003)
  }

  if (!all(is.na(stata)) & !is.null(reference)) {
    cat("\t")
    tryCatch(expr = {
      testthat::expect_equivalent(stata, reference, tolerance = tolerance)
      cli::cli_alert_success(paste0(tools::toTitleCase(sex_str), " ", z_or_p_r,
                                    " in ", acronym,  ": ",
                                    cli::col_green("succeeded")))
      return(TRUE)
    }, error = function(e) {
      cli::cli_alert_danger(paste0(tools::toTitleCase(sex_str), " ", z_or_p_r,
                                   " in ", acronym,  ": ",
                                   cli_redbold(text = "failed")))
      return(FALSE)
    })
  }
}

compare_ig_png <- function(acronym, sex, z_or_c) {
  sex_str <- if (sex == "M") "male" else if (sex == "F") "female"

  z_or_p_stata <- if (z_or_c == "z") "z2v"  else if (z_or_c == "c") "c2v"
  dta <- file.path("tests", "outputs", "ig_png",
            paste0(acronym, "_", z_or_p_stata, "_", sex_str, ".dta"))

  stata <- if (file.exists(dta)) haven::read_dta(file = dta) else {
      cat("\t")
      cli::cli_alert_danger("File not found: {.file {dta}}\n")
      return(FALSE)
  }

  z_or_p_r <- if (stringr::str_detect(z_or_c, pattern = "z")) {
    "z-scores"
  } else {
    "centiles"
  }
  reference <- gigs::ig_png[[acronym]][[sex_str]][[z_or_p_r]]
  tolerance <- 0.01

  if (!all(is.na(stata)) & !is.null(reference)) {
    cat("\t")
    tryCatch(expr = {
      testthat::expect_equivalent(stata, reference, tolerance = tolerance)
      cli::cli_alert_success(paste0(tools::toTitleCase(sex_str), " ", z_or_p_r,
                                    " in ", acronym,  ": ",
                                    cli::col_green("succeeded")))
      return(TRUE)
    }, error = function(e) {
      cli::cli_alert_danger(paste0(tools::toTitleCase(sex_str), " ", z_or_p_r,
                                   " in ", acronym,  ": ",
                                   cli_redbold(text = "failed")))
      return(FALSE)
    })
  }
}

compare_who_gs <- function(acronym, sex, z_or_c) {
  sex_str <- if (sex == "M") "male" else if (sex == "F") "female"

  z_or_c_stata <- if (z_or_c == "z") "z2v"  else if (z_or_c == "c") "c2v"
  dta <- file.path("tests", "outputs", "who_gs",
            paste0(acronym, "_", z_or_c_stata, "_", sex_str, ".dta"))

  stata <- if (file.exists(dta)) haven::read_dta(file = dta) else {
      cat("\t")
      cli::cli_alert_danger(text = "File not found: {.file {dta}}")
      return(FALSE)
  }

  z_or_p_r <- if (stringr::str_detect(z_or_c, pattern = "z")) {
    "z-scores"
  } else {
    "centiles"
  }
  reference <- gigs::who_gs[[acronym]][[sex_str]][[z_or_p_r]]
  tolerance <- 10e-5

  if (!all(is.na(stata)) & !is.null(reference)) {
    cat("\t")
    tryCatch(expr = {
      testthat::expect_equivalent(stata[, c(1, 3:9)], reference[, c(1, 3:9)],
                                  tolerance = tolerance)
      cli::cli_alert_success(paste0(tools::toTitleCase(sex_str), " ", z_or_p_r,
                                    " in ", acronym,  ": ",
                                    cli::col_green("succeeded")))
      return(TRUE)
    }, error = function(e) {
      cli::cli_alert_danger(paste0(tools::toTitleCase(sex_str), " ", z_or_p_r,
                                   " in ", acronym,  ": ",
                                   cli_redbold(text = "failed")))
      return(FALSE)
    })
  }
}

compare_interpolation <- function(standard, acronym, sex) {
  dta_dir <- file.path("tests", "outputs", "interpolation")
  dta_path <- file.path(dta_dir,
                        paste(standard, acronym, sex, "interped.dta",
                              sep = "_"))
  tbl <- if (file.exists(dta_path)) haven::read_dta(file = dta_path) else {
      cat("\t")
      cli::cli_alert_danger(text = "File not found: {.file {dta_path}}")
      return(FALSE)
  }

  gigs_expr <- str2expression(
    text = paste0("gigs::",
                  paste(standard, acronym, "zscore2value", sep = "_"),
                  "(z = z, xvar, sex = sex)"))

  tbl <- tbl |>
    dplyr::rename(xvar = 1) |>
    dplyr::mutate(r_col = eval(gigs_expr),
                  difference = r_col - stata_col)

  tolerance <- testthat::testthat_tolerance()
  stata <- tbl$stata_col
  reference <- tbl$r_col
  nice_standard <- toupper(stringr::str_replace(standard, "_", " "))
  nice_sex <- if (unique(tbl$sex) == "M") "males" else "females"
  consistent_lgl <- tryCatch(expr = {
    testthat::expect_equivalent(stata, reference,
                                tolerance = tolerance)
    TRUE
  }, error = function(e) {
    FALSE
  })
  cli_fn <- if (consistent_lgl) cli::cli_alert_success else cli::cli_alert_danger
  consistent_str <- if (consistent_lgl) "consistent" else "inconsistent"
  consistent_fn <- if (consistent_lgl) cli::col_green else cli::col_red
  cat("\t")
  cli_fn(paste0("Interpolation is ", consistent_fn(consistent_str), " for ",
                nice_sex, " in ", nice_standard, " {.var {acronym}}", "."))
  if (!consistent_lgl) {
    cat("\t  Mean difference was:", mean(tbl$difference, na.rm = TRUE), "\n")
    dplyr::mutate(tbl, debug = eval(gigs_expr))
    plot(tbl$xvar, tbl$difference)
  }
  consistent_lgl
}

wait_time_secs <- 1
cli::cli_h1(text = "INTERGROWTH-21st Fetal Growth Standards")
acronyms <- rep.int(names(gigs::ig_fet), times = rep(2, length(names(gigs::ig_fet))))
zc <- rep_len(c("c2v", "z2v"), length.out = length(acronyms))
ig_fet <- mapply(FUN = compare_ig_fet, acronyms, zc)
if (!interactive()) Sys.sleep(wait_time_secs)

cli::cli_h1(text = "INTERGROWTH-21st Newborn Size Standards")
acronyms <- rep.int(names(gigs::ig_nbs), times = rep(4, length(names(gigs::ig_nbs))))
sexes <- rep_len(c("M", "M", "F", "F"), length.out = length(acronyms))
zc <- rep_len(c("z", "c", "z", "c"), length.out = length(acronyms))
ig_nbs <- mapply(FUN = compare_ig_nbs, acronyms, sexes, zc)
if (!interactive()) Sys.sleep(wait_time_secs)

cli::cli_h1(text = "INTERGROWTH-21st Postnatal Growth Standards")
acronyms <- rep.int(names(gigs::ig_png), times = rep(4, length(names(gigs::ig_png))))
sexes <- rep_len(c("M", "M", "F", "F"), length.out = length(acronyms))
zc <- rep_len(c("z", "c", "z", "c"), length.out = length(acronyms))
ig_png <- mapply(FUN = compare_ig_png, acronyms, sexes, zc)
if (!interactive()) Sys.sleep(wait_time_secs)

cli::cli_h1(text = "WHO Child Growth Standards")
acronyms <- rep.int(names(gigs::who_gs), times = rep(4, length(names(gigs::who_gs))))
sexes <- rep_len(c("M", "M", "F", "F"), length.out = length(acronyms))
zc <- rep_len(c("z", "c", "z", "c"), length.out = length(acronyms))
who_gs <- mapply(FUN = compare_who_gs, acronyms, sexes, zc)
if (!interactive()) Sys.sleep(wait_time_secs)

cli::cli_h1(text = "Interpolation of coefficients")
ig_nbs_with_coeffs <- c("wfga", "lfga", "hcfga")
standards <- c(rep("who_gs", length(gigs::who_gs_coeffs) * 2),
               rep("ig_nbs", length(ig_nbs_with_coeffs) * 2))
acronyms <- c(rep.int(names(gigs::who_gs_coeffs),
                      times = rep(2, length(names(gigs::who_gs_coeffs)))),
              rep.int(ig_nbs_with_coeffs,
                      times = rep(2, length(ig_nbs_with_coeffs))))
sexes <- rep_len(c("M", "F"), length.out = length(acronyms))
interpolation <- mapply(FUN = compare_interpolation, standards, acronyms, sexes)
if (!interactive()) Sys.sleep(wait_time_secs)

cli::cli_h1(text = "Overall")
overall <- unlist(c(ig_nbs, ig_png, ig_fet, who_gs, interpolation))
if (all(overall)) {
  cli::cli_alert_success(text = "All tests passed!")
} else {
  num_overall <- length(overall)
  num_passed <- sum(overall)
  num_failed <- num_overall - num_passed
  cli::cli_alert_danger(text = "{num_failed} of {num_overall} test{?s} failed.")
}
