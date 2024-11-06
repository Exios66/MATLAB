# Core Data Manipulation and Visualization Libraries
library(tidyverse)  # Includes ggplot2, dplyr, tidyr, readr, etc.
library(data.table) # Fast data manipulation
library(scales)     # Better axis scaling and colors
library(viridis)    # Color-blind friendly palettes
library(plotly)     # Interactive plots
library(highcharter)# Interactive charts
library(leaflet)    # Interactive maps
library(sf)         # Spatial data handling
library(forecast)   # Time series visualization
library(corrplot)   # Correlation visualization
library(gridExtra)  # Arrange multiple plots
library(DT)         # Interactive data tables

# Advanced Statistical Visualization
library(GGally)     # Extension to ggplot2
library(ggridges)   # Ridgeline plots
library(ggrepel)    # Better label placement
library(gganimate)  # Animated visualizations
library(factoextra) # Clustering visualization
library(networkD3)  # Network graphs
library(wordcloud2) # Word clouds

# Theme Setting for Consistent Visualization
theme_set(theme_minimal())

# Custom Color Palettes
custom_palette <- c("#2C3E50", "#E74C3C", "#ECF0F1", "#3498DB", "#2ECC71")

# Main Visualization Function
create_visualization <- function(data, viz_type = "auto", interactive = TRUE) {
  if(!is.data.frame(data)) {
    stop("Input must be a data frame")
  }
  
  # Automatic visualization selection based on data structure
  if(viz_type == "auto") {
    viz_type <- suggest_visualization(data)
  }
  
  # Create visualization based on type
  plot <- switch(viz_type,
    "scatter" = create_scatter_plot(data, interactive),
    "bar" = create_bar_plot(data, interactive),
    "line" = create_line_plot(data, interactive),
    "box" = create_box_plot(data, interactive),
    "histogram" = create_histogram(data, interactive),
    "density" = create_density_plot(data, interactive),
    "correlation" = create_correlation_plot(data, interactive),
    "map" = create_map_visualization(data, interactive),
    stop("Unsupported visualization type")
  )
  
  return(plot)
}

# Helper Functions
suggest_visualization <- function(data) {
  # Logic to suggest appropriate visualization based on data structure
  n_numeric <- sum(sapply(data, is.numeric))
  n_categorical <- sum(sapply(data, is.factor))
  n_datetime <- sum(sapply(data, inherits, "POSIXct"))
  
  if(n_numeric >= 2) return("scatter")
  if(n_categorical > 0 && n_numeric > 0) return("bar")
  if(n_datetime > 0) return("line")
  return("bar")
}

# Specific Plot Creation Functions
create_scatter_plot <- function(data, interactive = TRUE) {
  p <- ggplot(data, aes(x = data[[1]], y = data[[2]])) +
       geom_point(aes(color = data[[3]])) +
       scale_color_viridis_d() +
       labs(title = "Scatter Plot")
  
  if(interactive) return(ggplotly(p))
  return(p)
}

create_bar_plot <- function(data, interactive = TRUE) {
  p <- ggplot(data, aes(x = data[[1]], y = data[[2]])) +
       geom_bar(stat = "identity") +
       theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  if(interactive) return(ggplotly(p))
  return(p)
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

# Example Usage
# data <- read_csv("your_data.csv")
# viz <- create_visualization(data, "scatter", interactive = TRUE)
# export_visualization(viz, "output_visualization", "html") 