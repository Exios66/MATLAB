# Core Data Manipulation and Visualization
# library() calls trimmed during repair to installed, actually-used packages.
library(tidyverse) # ggplot2, dplyr, tidyr, readr, purrr

# Theme Setting for Consistent Visualization
theme_set(theme_minimal())

# Custom Color Palettes
custom_palette <- c("#2C3E50", "#E74C3C", "#ECF0F1", "#3498DB", "#2ECC71")

pick_col <- function(data, predicate) names(data)[vapply(data, predicate, logical(1))][1]

# Main Visualization Function -- signature matches the call in app/server.R
create_visualization <- function(data, viz_type = "auto", x = NULL, y = NULL,
                                 color = NULL, facet = NULL, interactive = TRUE) {
  if (!is.data.frame(data)) {
    stop("Input must be a data frame")
  }
  if (identical(viz_type, "auto")) {
    viz_type <- suggest_visualization(data)
  }

  p <- switch(viz_type,
    "scatter" = create_scatter_plot(data, x, y, color, facet),
    "bar" = create_bar_plot(data, x, y, color, facet),
    "line" = create_line_plot(data, x, y, color, facet),
    "box" = create_box_plot(data, x, y, color, facet),
    "histogram" = create_histogram(data, x, color, facet),
    stop("Unsupported visualization type")
  )

  if (interactive) p <- plotly::ggplotly(p) # namespaced: plotly loads only at render time
  p
}

# Suggest a visualization from the data structure
# (only identifies types that still have a creator: scatter/bar/line)
suggest_visualization <- function(data) {
  n_numeric <- sum(vapply(data, is.numeric, logical(1)))
  n_categorical <- sum(vapply(data, is.factor, logical(1)))
  n_datetime <- sum(vapply(data, function(x) inherits(x, "POSIXct"), logical(1)))

  if (n_numeric >= 2) return("scatter")
  if (n_categorical > 0 && n_numeric > 0) return("bar")
  if (n_datetime > 0) return("line")
  "bar"
}

# Specific Plot Creation Functions
create_scatter_plot <- function(data, x = NULL, y = NULL, color = NULL, facet = NULL) {
  if (sum(vapply(data, is.numeric, logical(1))) < 2) {
    stop("Scatter plot needs at least 2 numeric columns")
  }
  x <- x %||% pick_col(data, is.numeric)
  y <- y %||% names(data[vapply(data, is.numeric, logical(1))])[2]

  p <- ggplot(data, aes(x = .data[[x]], y = .data[[y]])) +
        geom_point(alpha = 0.7) +
        labs(title = "Scatter Plot")

  if (!is.null(color) && color %in% names(data)) p <- p + aes(color = .data[[color]])
  if (!is.null(facet) && facet %in% names(data)) p <- p + facet_wrap(facet)
  p
}

create_bar_plot <- function(data, x = NULL, y = NULL, color = NULL, facet = NULL) {
  x <- x %||% pick_col(data, function(v) is.factor(v) || is.character(v))
  y <- y %||% pick_col(data, is.numeric)
  if (is.na(x) || is.na(y)) stop("Bar plot needs a grouping column and a numeric column")

  p <- ggplot(data, aes(x = .data[[x]], y = .data[[y]])) +
        geom_col() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        labs(title = "Bar Plot")

  if (!is.null(color) && color %in% names(data)) p <- p + aes(color = .data[[color]])
  if (!is.null(facet) && facet %in% names(data)) p <- p + facet_wrap(facet)
  p
}

create_line_plot <- function(data, x = NULL, y = NULL, color = NULL, facet = NULL) {
  x <- x %||% pick_col(data, function(v) inherits(v, "POSIXct") || inherits(v, "Date"))
  y <- y %||% pick_col(data, is.numeric)
  if (is.na(x) || is.na(y)) stop("Line plot needs a date/time column and a numeric column")

  p <- ggplot(data, aes(x = .data[[x]], y = .data[[y]])) +
        geom_line() +
        labs(title = "Line Plot")

  if (!is.null(color) && color %in% names(data)) p <- p + aes(color = .data[[color]])
  if (!is.null(facet) && facet %in% names(data)) p <- p + facet_wrap(facet)
  p
}

create_box_plot <- function(data, x = NULL, y = NULL, color = NULL, facet = NULL) {
  x <- x %||% pick_col(data, function(v) is.factor(v) || is.character(v))
  y <- y %||% pick_col(data, is.numeric)
  if (is.na(x) || is.na(y)) stop("Box plot needs a grouping column and a numeric column")

  p <- ggplot(data, aes(x = .data[[x]], y = .data[[y]])) +
        geom_boxplot() +
        labs(title = "Box Plot")

  if (!is.null(color) && color %in% names(data)) p <- p + aes(color = .data[[color]])
  if (!is.null(facet) && facet %in% names(data)) p <- p + facet_wrap(facet)
  p
}

create_histogram <- function(data, x = NULL, color = NULL, facet = NULL) {
  x <- x %||% pick_col(data, is.numeric)
  if (is.na(x)) stop("Histogram needs a numeric column")

  p <- ggplot(data, aes(x = .data[[x]])) +
        geom_histogram(bins = 30) +
        labs(title = "Histogram")

  if (!is.null(facet) && facet %in% names(data)) p <- p + facet_wrap(facet)
  p
}

# Data Export Functions
export_visualization <- function(plot, filename, format = "html") {
  switch(format,
    "html" = htmlwidgets::saveWidget(plot, paste0(filename, ".html")),
    "pdf" = ggsave(paste0(filename, ".pdf"), plot),
    "png" = ggsave(paste0(filename, ".png"), plot),
    stop("Unsupported format")
  )
}

# Example usage:
# data <- read_csv("your_data.csv")
# viz <- create_visualization(data, "scatter", x = "col_a", y = "col_b", interactive = FALSE)
# export_visualization(viz, "output_visualization", "png")
