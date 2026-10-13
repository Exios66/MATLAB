# Statistical Visualizations
# factoextra/rpart/cluster/corrplot replaced during repair: everything here is
# base stats + ggplot2, so all three helpers run with locally installed packages.
library(ggplot2)
library(rlang) # %||%

create_statistical_viz <- function(data, viz_type, params = list()) {
  switch(viz_type,
    "cluster" = visualize_clustering(data, params),
    "pca" = visualize_pca(data),
    "correlation" = visualize_correlation(data),
    stop("Unsupported statistical visualization type")
  )
}

pick_numeric_cols <- function(data) names(data)[vapply(data, is.numeric, logical(1))]

visualize_clustering <- function(data, params) {
  # K-means clustering, projected onto the two principal components
  k <- params$k %||% 3
  nums <- data[pick_numeric_cols(data)]
  if (ncol(nums) < 2 || nrow(nums) < k) {
    stop("Clustering needs at least 2 numeric columns and at least k rows")
  }
  km <- kmeans(scale(nums), centers = k)
  pcs <- as.data.frame(prcomp(nums, scale. = TRUE)$x[, 1:2])
  names(pcs) <- c("PC1", "PC2")
  pcs$cluster <- factor(km$cluster)

  ggplot(pcs, aes(x = PC1, y = PC2, color = cluster)) +
    geom_point(size = 2, alpha = 0.8) +
    labs(title = "K-means Clustering", color = "Cluster") +
    theme_minimal()
}

visualize_pca <- function(data) {
  nums <- data[pick_numeric_cols(data)]
  if (ncol(nums) < 2) stop("PCA needs at least 2 numeric columns")
  pca <- prcomp(nums, scale. = TRUE)
  ind <- as.data.frame(pca$x[, 1:2])
  names(ind) <- c("PC1", "PC2")
  arrows <- data.frame(
    name = rownames(pca$rotation),
    x = 0, y = 0,
    xend = pca$rotation[, 1], yend = pca$rotation[, 2]
  )

  ggplot() +
    geom_point(data = ind, aes(x = PC1, y = PC2)) +
    geom_segment(
      data = arrows,
      aes(x = x, y = y, xend = xend, yend = yend, color = name), show.legend = FALSE
    ) +
    labs(title = "PCA Biplot") +
    theme_minimal()
}

visualize_correlation <- function(data) {
  # ggplot2 correlation heatmap (replaces corrplot)
  nums <- data[pick_numeric_cols(data)]
  if (ncol(nums) < 2) stop("Correlation needs at least 2 numeric columns")
  corr_long <- as.data.frame(as.table(cor(as.matrix(nums))))
  names(corr_long) <- c("var1", "var2", "value")

  ggplot(corr_long, aes(x = var1, y = var2, fill = value)) +
    geom_tile() +
    geom_text(aes(label = round(value, 2)), size = 3) +
    scale_fill_gradient2(low = "#E74C3C", mid = "#F1C40F", high = "#2E9FDF", limits = c(-1, 1)) +
    labs(title = "Correlation Matrix", x = NULL, y = NULL, fill = "r") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}
