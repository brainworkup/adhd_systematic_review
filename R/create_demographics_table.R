#' Create a Formatted Demographics Table
#'
#' @description Creates a formatted gt table for demographic data summaries
#'
#' @param data A dataframe containing demographic data to display
#' @param title Table title (character string, can use markdown formatting)
#' @param subtitle Table subtitle (character string, can use markdown formatting)
#' @param col_labels Named vector for custom column labels (optional)
#'
#' @return A formatted gt table object
#'
#' @examples
#' create_demographics_table(
#'   demographics_data_neuroimaging,
#'   title = "Demographics Table for Adult ADHD Review",
#'   subtitle = "**Neuroimaging Studies Demographics Summary**"
#' )
#'
#' @import gt
#' @importFrom dplyr everything
create_demographics_table <- function(data,
                                      title = "Demographics Table",
                                      subtitle = NULL,
                                      col_labels = NULL) {
  # Initialize gt table
  table <- data |>
    gt() |>
    tab_header(
      title = md(title),
      subtitle = if (!is.null(subtitle)) md(subtitle) else NULL
    )

  # Apply column labels if provided
  if (!is.null(col_labels)) {
    table <- table |> cols_label(.list = col_labels)
  }

  # Format all columns as markdown to handle any formatting within the cells
  table <- table |>
    fmt_markdown(columns = everything()) |>
    opt_table_lines()

  return(table)
}
