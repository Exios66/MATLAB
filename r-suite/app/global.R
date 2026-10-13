# Global configurations and settings
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyjs)
library(shinyWidgets)
library(DT)
library(waiter)
library(fresh)
library(bs4Dash)
library(plotly)
library(rmarkdown)

# Source all helper functions
source("preprocessing.R")
source("themes.R")
source("advanced_visualizations.R")
source("statistical_visualizations.R")

# Global settings
options(shiny.maxRequestSize = 100*1024^2) # Allow up to 100MB file uploads 