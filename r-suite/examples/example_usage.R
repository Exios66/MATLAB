# Example usage of the surviving r-suite API.
# Deps needed per call: preprocess/pipeline/theme helpers run on tidyverse only;
# "treemap"/"cluster" additionally need plotly/igraph + kmeans runtime packages
# (see app/global.R for the full boot list).

library(tidyverse) # readr::read_csv

# Load data
data <- read_csv("your_data.csv")

# Preprocess
processed_data <- preprocess_data(data, steps = c("clean", "transform", "engineer"))

# Create various visualizations
viz1 <- create_visualization(processed_data, "scatter", interactive = FALSE) +
        theme_modern()

viz2 <- create_advanced_visualization(processed_data, "treemap", params = list())

viz3 <- create_statistical_viz(processed_data, "correlation")
