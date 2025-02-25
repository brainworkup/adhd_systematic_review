# Version 2

library(readr)

# Read the CSV file
studies <- read_csv("studies.csv", col_types = cols())

# Rename

library(dplyr)
studies <- studies %>%
  rename(
    # key = Refid,
    author = Author,
    title = Title,
    abstract = Abstract,
    journal = Journal,
    year = Year,
    volume = Volume,
    number = Number,
    pages = Pages,
    doi = DOI,
    keywords = Keywords
  )


# Function to create a BibTeX entry from a single row (one-row data frame)
make_bib_entry <- function(row) {
  # Create a citation key from first author's last name and year
  first_author <- strsplit(row$author, ",")[[1]][1]
  first_author <- gsub(" ", "", first_author) # Remove spaces
  citation_key <- paste0(first_author, row$year)

  sprintf(
    "@article{%s,
  author = {%s},
  title = {%s},
  abstract = {%s},
  keywords = {%s},
  journal = {%s},
  year = {%s},%s%s%s%s
}\n",
    citation_key,
    row$author,
    row$title,
    row$abstract,
    row$keywords,
    row$journal,
    row$year,
    if (!is.na(row$volume) && row$volume != "") sprintf("\n  volume = {%s},", row$volume) else "",
    if (!is.na(row$number) && row$number != "") sprintf("\n  number = {%s},", row$number) else "",
    if (!is.na(row$pages) && row$pages != "") sprintf("\n  pages = {%s},", row$pages) else "",
    if (!is.na(row$doi) && row$doi != "") sprintf("\n  doi = {%s},", row$doi) else ""
  )
}

# Split the data frame into a list of rows and apply the function
bib_entries <- sapply(split(studies, seq(nrow(studies))), make_bib_entry)

# Write the entries to a file
writeLines(bib_entries, "references.bib")
cat("BibLaTeX file 'references.bib' created successfully!\n")
