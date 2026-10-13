# Global configurations and settings
# Fail fast on the hard Shiny dependencies the app cannot boot without.
required_pkgs <- c(
  # Hard Shiny UI/render dependencies
  "shiny", "shinydashboard", "shinydashboardPlus", "shinyjs",
  "shinyWidgets", "DT", "waiter", "fresh", "bs4Dash",
  "plotly", "rmarkdown",
  # Needed by the sourced helpers (visualization_pipeline.R attaches it)
  "ggplot2", "tidyverse"
)
missing_pkgs <- required_pkgs[!vapply(required_pkgs, requireNamespace,
                                      logical(1), quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  stop("Missing required packages: ", paste(missing_pkgs, collapse = ", "),
       "\nInstall with: install.packages(c(\"",
       paste(missing_pkgs, collapse = "\", \""), "\"))", call. = FALSE)
}

# requireNamespace only checks; the UI/server evaluate unqualified calls from
# these packages, so attaching them is what makes the app boot (review finding B1).
invisible(lapply(required_pkgs, library, character.only = TRUE))

# Source all helper functions
source("preprocessing.R")
source("themes.R")
source("advanced_visualizations.R")
source("statistical_visualizations.R")
source("visualization_pipeline.R")

# Global settings
options(shiny.maxRequestSize = 100 * 1024^2) # Allow up to 100MB file uploads
