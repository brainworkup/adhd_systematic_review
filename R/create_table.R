library(gt)
library(dplyr)

create_table <- function(df, title, subtitle) {
  # Generate the gt table using the provided dataframe (df)
  gt_table <- df |>
    gt() |>
    tab_header(
      title = md(title),
      subtitle = md(subtitle)
    ) |>
    # Relabel columns using exact column names from the CSV
    cols_label(
      Study = "Study",
      Sample_Size_ADHD = "Sample Size (ADHD)",
      Age_Mean_SD_ADHD = "Age (Mean ± SD) (ADHD)",
      Gender_ADHD = "Gender (ADHD)",
      Sample_Size_Controls = "Sample Size (Controls)",
      Age_Mean_SD_Controls = "Age (Mean ± SD) (Controls)",
      Gender_Controls = "Gender (Controls)",
      Measure_Name = "Diagnostic Measure",
      Diagnostic_Accuracy = "Diagnostic Accuracy",
      Sensitivity = "Sensitivity",
      Specificity = "Specificity",
      NPV = "Negative Predictive Value",
      PPV = "Positive Predictive Value",
      Notes = "Notes"
    ) |>
    # Format all columns as markdown to handle any formatting within the cells
    fmt_markdown(columns = everything()) |>
    # Optional: Add table lines for a more publication-like look
    opt_table_lines()

  # Return the table
  return(gt_table)
}
