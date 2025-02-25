library(tidyverse)
library(pdftools)
library(here)
library(purrr)

process_papers <- function(pdf_dir) {
  pdf_files <- list.files(pdf_dir, pattern = ".pdf$", full.names = TRUE)

  results <- map_df(pdf_files, function(file) {
    text <- pdf_text(file)
    # Extract key information using regex patterns
    # Based on your protocol's requirements

    tibble(
      file_name = basename(file),
      text = list(text),
      processed_date = Sys.Date(),
      # Add other extracted fields
    )
  })

  return(results)
}
