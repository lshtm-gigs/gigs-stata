logfile <- readr::read_lines("benchmarking/statabench.log")

logfile_to_df <- function(logfile, acronym) {
  pattern <- paste0("^For ", acronym, "|Average")
  log_subset <- logfile[grepl(x = logfile, pattern = pattern)]

  hits <- which(grepl(x = log_subset, pattern = paste0("^For ", acronym)))
  pasted <- paste(log_subset[hits], log_subset[hits + 1])

  n_inputs <- stringr::str_extract(pasted, pattern = "(?<=inputs\\: ).*(?= A)") |>
    as.integer()
  median <- stringr::str_extract(pasted, pattern = "(?<=runs\\: ).*(?= s)") |>
    as.double()
  desc_pattern <- paste0("(?<=", acronym, " ).*(?= -)")
  desc <- stringr::str_extract(pasted, pattern = desc_pattern)
  df <- data.frame(input_len = n_inputs,
                   median = median * 1000, # Convert secs to ms
                   desc = desc,
                   acronym = acronym)
}

stata_bench <- purrr::map_dfr(.x = c("who_gs", "ig_nbs", "ig_png", "ig_fet"),
                              .f = \(acronym) logfile_to_df(logfile, acronym))

write.csv(stata_bench, file = "benchmarking/statabench.csv", 
          row.names = FALSE)
							  