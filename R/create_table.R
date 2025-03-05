library(gt)
library(dplyr)

create_table <- function(demographics_data) {
  # Generate the gt table
  demographics_table <- demographics_data |>
    gt() |>
    tab_header(
      title = md("Demographics Table for Adult ADHD Review"),
      subtitle = md("**Neuroimaging Studies Demographics Summary**")
    ) |>
    # Relabel columns
    cols_label(
      Study = "Study",
      `Sample Size` = "Sample Size",
      `Age (Mean ± SD)` = "Age (Mean ± SD)",
      Gender = "Gender",
      `ADHD Subtypes` = "ADHD Subtypes",
      `Imaging Modality` = "Imaging Modality",
      `Key Demographic Notes` = "Key Demographic Notes"
    ) |>
    # Format all columns as markdown to handle any formatting within the cells
    fmt_markdown(columns = everything()) |>
    # Optional: Add table lines for a more publication-like look
    opt_table_lines()

  # Return the table
  return(demographics_table)
}

# Example usage:
# Assuming `demographics_data` is your dataset
# demographics_table <- create_demographics_table(demographics_data)
# demographics_table
