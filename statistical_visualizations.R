# Statistical and Machine Learning Visualizations
library(cluster)    # For clustering
library(factoextra) # For clustering visualization
library(rpart)      # For decision trees
library(rpart.plot) # For tree visualization

create_statistical_viz <- function(data, viz_type, params = list()) {
  switch(viz_type,
    "cluster" = visualize_clustering(data, params),
    "pca" = visualize_pca(data),
    "correlation" = visualize_correlation(data),
    "decision_tree" = visualize_decision_tree(data, params),
    "time_series" = visualize_time_series(data),
    stop("Unsupported statistical visualization type")
  )
}

visualize_clustering <- function(data, params) {
  # K-means clustering
  k <- params$k %||% 3
  km <- kmeans(scale(data), centers = k)
  
  fviz_cluster(km, data = data,
               palette = c("#2E9FDF", "#00AFBB", "#E7B800"),
               geom = "point",
               ellipse.type = "convex",
               ggtheme = theme_minimal())
}

visualize_pca <- function(data) {
  # PCA analysis
  pca_result <- prcomp(data, scale. = TRUE)
  
  fviz_pca_biplot(pca_result,
                  repel = TRUE,
                  col.var = "#2E9FDF",
                  col.ind = "#696969")
}

visualize_correlation <- function(data) {
  correlation <- cor(data)
  corrplot(correlation,
           method = "color",
           type = "upper",
           order = "hclust",
           addCoef.col = "black",
           tl.col = "black",
           tl.srt = 45)
} 