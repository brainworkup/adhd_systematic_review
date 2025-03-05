# Example of how to use the create_demographics_table function in your Quarto document

# In your Quarto setup chunk at the beginning of the document:
# -------------------------------------------------------------
# ```{r setup}
# library(gt)
# library(tibble)
# library(dplyr)
# source("R/create_demographics_table.R")
# ```

# Then in your document where you want to create the table:
# ---------------------------------------------------------
# ```{r}
# # Your existing data creation code remains the same
# demographics_data_neuroimaging <- tibble::tribble(
#   ~Study, ~`Sample Size`, ~`Age (Mean ± SD)`, ~Gender, ~`ADHD Subtypes`, ~`Imaging Modality`, ~`Key Demographic Notes`,
#   "Alves (2024)", "30 ADHD, 30 controls", "Not fully extracted", "Not fully extracted", "Not fully extracted", "fMRI", "Analysis used blood oxygenation level-dependent (BOLD) time series data",
#   # ... rest of your data ...
# )

# Instead of the original gt code, use the function:
demographics_table_neuroimaging <- create_demographics_table(
  data = demographics_data_neuroimaging,
  title = "Demographics Table for Adult ADHD Review",
  subtitle = "**Neuroimaging Studies Demographics Summary**"
)

# Display the table
demographics_table_neuroimaging
# ```

# Example with custom column labels (if needed):
# ----------------------------------------------
# ```{r}
# demographics_table_neuropsych <- create_demographics_table(
#   data = demographics_data_neuropsych,
#   title = "Demographics Table for Adult ADHD Review",
#   subtitle = "**Neuropsychological Studies Demographics Summary**",
#   col_labels = c(
#     "Study" = "Study",
#     "Sample Size" = "Sample Size",
#     "Age (Mean ± SD)" = "Age (Mean ± SD)",
#     "Gender" = "Gender",
#     "ADHD Subtypes" = "ADHD Subtypes",
#     "Assessment Measures" = "Assessment Measures",
#     "Key Demographic Notes" = "Key Demographic Notes"
#   )
# )
