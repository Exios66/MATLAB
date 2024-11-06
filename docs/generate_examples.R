# Generate Example Visualizations for Gallery
library(tidyverse)
library(ggplot2)
library(plotly)
library(treemap)
library(networkD3)
library(factoextra)
library(corrplot)

# Create directory for images if it doesn't exist
dir.create("www/images", showWarnings = FALSE, recursive = TRUE)

# Generate sample data
set.seed(123)
sample_data <- tibble(
  x = rnorm(100),
  y = x * 2 + rnorm(100),
  category = sample(LETTERS[1:4], 100, replace = TRUE),
  value = abs(rnorm(100)),
  time = seq(as.Date("2023-01-01"), by = "day", length.out = 100)
)

# 1. Basic Visualizations
# Scatter Plot
basic_scatter <- ggplot(sample_data, aes(x = x, y = y, color = category)) +
  geom_point(alpha = 0.7) +
  theme_minimal() +
  labs(title = "Interactive Scatter Plot",
       x = "X Variable",
       y = "Y Variable") +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("www/images/scatter.png", basic_scatter, width = 8, height = 6)

# Bar Chart
basic_bar <- ggplot(sample_data, aes(x = category, y = value, fill = category)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Bar Chart by Category",
       x = "Category",
       y = "Value") +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("www/images/bar.png", basic_bar, width = 8, height = 6)

# Line Plot
basic_line <- ggplot(sample_data, aes(x = time, y = value, color = category)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Time Series Line Plot",
       x = "Time",
       y = "Value") +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("www/images/line.png", basic_line, width = 8, height = 6)

# 2. Advanced Visualizations
# Treemap
treemap_data <- aggregate(value ~ category, data = sample_data, sum)
png("www/images/treemap.png", width = 800, height = 600)
treemap(treemap_data,
        index = "category",
        vSize = "value",
        type = "index",
        title = "Category Distribution Treemap")
dev.off()

# Network Graph
nodes <- data.frame(
  name = LETTERS[1:4],
  group = 1:4
)
edges <- data.frame(
  source = sample(0:3, 10, replace = TRUE),
  target = sample(0:3, 10, replace = TRUE),
  value = runif(10)
)
network <- forceNetwork(Links = edges, Nodes = nodes,
                       Source = "source", Target = "target",
                       Value = "value", NodeID = "name",
                       Group = "group", opacity = 0.8)
saveNetwork(network, "www/images/network.html")
webshot::webshot("www/images/network.html", "www/images/network.png")

# 3. Statistical Visualizations
# Correlation Matrix
correlation_matrix <- cor(sample_data %>% select_if(is.numeric))
png("www/images/correlation.png", width = 800, height = 600)
corrplot(correlation_matrix,
         method = "color",
         type = "upper",
         order = "hclust",
         addCoef.col = "black",
         tl.col = "black",
         tl.srt = 45)
dev.off()

# Cluster Analysis
cluster_data <- scale(sample_data %>% select_if(is.numeric))
km <- kmeans(cluster_data, centers = 3)
cluster_plot <- fviz_cluster(km, data = cluster_data,
                           palette = c("#2E9FDF", "#00AFBB", "#E7B800"),
                           geom = "point",
                           ellipse.type = "convex",
                           ggtheme = theme_minimal())
ggsave("www/images/clustering.png", cluster_plot, width = 8, height = 6)

# Box Plot
box_plot <- ggplot(sample_data, aes(x = category, y = value, fill = category)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Value Distribution by Category",
       x = "Category",
       y = "Value") +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("www/images/boxplot.png", box_plot, width = 8, height = 6)

# Density Plot
density_plot <- ggplot(sample_data, aes(x = value, fill = category)) +
  geom_density(alpha = 0.5) +
  theme_minimal() +
  labs(title = "Density Distribution by Category",
       x = "Value",
       y = "Density") +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("www/images/density.png", density_plot, width = 8, height = 6) 