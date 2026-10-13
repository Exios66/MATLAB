# Advanced Visualization Types
# Surviving dispatch arms: treemap, ridge, network (all others deleted).
# Dependencies: ggplot2 + rlang at load time; plotly/igraph only at call time
# via namespace (both are runtime deps of the Shiny app).
library(ggplot2)
library(rlang) # %||%

create_advanced_visualization <- function(data, viz_type, params = list()) {
  switch(viz_type,
    "treemap" = create_treemap(data, params),
    "ridge"   = create_ridge_plot(data, params),
    "network" = create_network_graph(data, params),
    stop("Unsupported visualization type")
  )
}

create_treemap <- function(data, params = list()) {
  cat_col <- params$grouping %||%
    names(data)[vapply(data, function(x) is.factor(x) || is.character(x), logical(1))][1]
  val_col <- params$value %||% names(data)[vapply(data, is.numeric, logical(1))][1]
  if (is.na(cat_col) || is.na(val_col)) {
    stop("Treemap needs a grouping column and a numeric value column")
  }
  agg <- aggregate(data[[val_col]], by = list(group = data[[cat_col]]), FUN = sum)
  plotly::plot_ly(agg, labels = ~group, values = ~x, type = "treemap") +
    plotly::layout(title = "Treemap Visualization")
}

create_ridge_plot <- function(data, params = list()) {
  # Base-ggplot2 ridgeline: per-category density, vertically offset (ggridges-free)
  cat_col <- params$category %||%
    names(data)[vapply(data, function(x) is.factor(x) || is.character(x), logical(1))][1]
  val_col <- params$value %||% names(data)[vapply(data, is.numeric, logical(1))][1]
  if (is.na(cat_col) || is.na(val_col)) {
    stop("Ridge plot needs a category column and a numeric value column")
  }
  groups <- sort(unique(data[[cat_col]]))
  dens <- lapply(seq_along(groups), function(i) {
    x <- data[[val_col]][data[[cat_col]] == groups[i]]
    if (length(unique(x)) < 2) return(NULL) # density() needs variation
    d <- density(na.omit(x))
    data.frame(x = d$x, y = d$y, group = groups[i], off = i)
  })
  dens <- do.call(rbind, Filter(Negate(is.null), dens))
  if (is.null(dens)) stop("Ridge plot needs at least 2 distinct values per category")

  ggplot(dens, aes(x = x, ymin = off, ymax = off + y, fill = group)) +
    geom_ribbon(alpha = 0.6, color = "grey30") +
    scale_y_continuous(
      breaks = dens$off[!duplicated(dens$off)], labels = unique(dens$group)
    ) +
    labs(title = "Ridge Plot", x = val_col, y = cat_col) +
    theme(legend.position = "none")
}

create_network_graph <- function(data, params = list()) {
  nodes <- data$nodes
  edges <- data$edges
  if (is.null(nodes) || is.null(edges)) {
    stop("Network plot needs data with 'nodes' and 'edges' components")
  }
  src <- params$source %||% "source"
  tgt <- params$target %||% "target"
  g <- igraph::graph_from_data_frame(edges[, c(src, tgt)], directed = FALSE, vertices = nodes)
  set.seed(1) # deterministic force-directed layout
  pos <- igraph::layout_with_fr(g)
  nd <- data.frame(name = nodes$name, x = pos[, 1], y = pos[, 2], group = nodes$group)
  ed <- igraph::as_edgelist(g, names = FALSE)
  edge_df <- data.frame(
    x = pos[ed[, 1], 1], y = pos[ed[, 1], 2],
    xend = pos[ed[, 2], 1], yend = pos[ed[, 2], 2]
  )

  ggplot() +
    geom_segment(data = edge_df, aes(x = x, y = y, xend = xend, yend = yend), color = "grey60") +
    geom_point(data = nd, aes(x = x, y = y, color = factor(group)), size = 4) +
    ggtitle("Network Graph") +
    theme_void() +
    labs(color = "group")
}
