# Advanced Visualization Types
library(treemap)    # For treemaps
library(sunburstR)  # For sunburst charts
library(waffle)     # For waffle charts
library(streamgraph)# For streamgraphs
library(circlize)   # For circular visualizations
library(dendextend) # For dendrograms
library(ggridges)   # For ridge plots
library(ggalluvial) # For alluvial diagrams

create_advanced_visualization <- function(data, viz_type, interactive = TRUE) {
  switch(viz_type,
    "treemap" = create_treemap(data),
    "sunburst" = create_sunburst(data),
    "waffle" = create_waffle_chart(data),
    "stream" = create_streamgraph(data),
    "circular" = create_circular_plot(data),
    "dendrogram" = create_dendrogram(data),
    "ridge" = create_ridge_plot(data),
    "alluvial" = create_alluvial_diagram(data),
    "network" = create_network_graph(data),
    stop("Unsupported visualization type")
  )
}

create_treemap <- function(data) {
  treemap(data,
          index = c("group", "subgroup"),
          vSize = "value",
          type = "index",
          palette = "Set3",
          title = "Treemap Visualization")
}

create_ridge_plot <- function(data) {
  ggplot(data, aes(x = value, y = category, fill = category)) +
    geom_density_ridges(alpha = 0.6) +
    theme_ridges() +
    theme(legend.position = "none")
}

create_network_graph <- function(data) {
  nodes <- data$nodes
  edges <- data$edges
  
  forceNetwork(Links = edges, Nodes = nodes,
               Source = "source", Target = "target",
               NodeID = "name", Group = "group",
               opacity = 0.8,
               linkDistance = 100,
               charge = -300)
} 