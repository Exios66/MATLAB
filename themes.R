# Custom Themes and Color Palettes
library(RColorBrewer)

# Modern minimalist theme
theme_modern <- function() {
  theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      panel.grid.major = element_line(color = "grey90"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
}

# Dark theme
theme_dark_custom <- function() {
  theme_dark() +
    theme(
      plot.background = element_rect(fill = "#2C3E50"),
      panel.background = element_rect(fill = "#34495E"),
      text = element_text(color = "white"),
      axis.text = element_text(color = "white"),
      panel.grid = element_line(color = "grey30")
    )
}

# Corporate theme
theme_corporate <- function() {
  theme_classic() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.title = element_text(face = "bold", size = 12),
      legend.position = "right",
      panel.background = element_rect(fill = "white"),
      panel.grid.major = element_line(color = "grey95")
    )
}

# Color palettes
palette_modern <- scale_color_manual(
  values = c("#2C3E50", "#E74C3C", "#3498DB", "#2ECC71", "#F1C40F")
)

palette_pastel <- scale_color_manual(
  values = c("#FFB3BA", "#BAFFC9", "#BAE1FF", "#FFFFBA", "#FFB3F7")
)

palette_corporate <- scale_color_brewer(palette = "Set2") 