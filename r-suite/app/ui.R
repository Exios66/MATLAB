# Enhanced User Interface
ui <- dashboardPage(
  dark = TRUE,
  dashboardHeader(
    title = "Advanced Data Visualization Suite",
    leftUi = tagList(
      dropdownButton(
        "Quick Actions",
        icon = icon("bolt"),
        status = "primary",
        buttonList(
          actionButton("quick_scatter", "Quick Scatter"),
          actionButton("quick_hist", "Quick Histogram"),
          actionButton("quick_box", "Quick Box Plot")
        )
      )
    )
  ),
  
  dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      menuItem("Data Import & Preprocessing", tabName = "data_prep", icon = icon("database")),
      menuItem("Basic Visualizations", tabName = "basic_viz", icon = icon("chart-bar")),
      menuItem("Advanced Visualizations", tabName = "advanced_viz", icon = icon("chart-line")),
      menuItem("Statistical Analysis", tabName = "stats", icon = icon("calculator")),
      menuItem("Interactive Dashboard", tabName = "dashboard", icon = icon("tachometer-alt")),
      menuItem("Export & Share", tabName = "export", icon = icon("share-alt"))
    ),
    
    # Conditional Panels for each menu item
    conditionalPanel(
      condition = "input.sidebar == 'data_prep'",
      fileInput("file", "Upload Data File",
                accept = c(".csv", ".xlsx", ".rds", ".feather")),
      selectInput("preprocess_steps", "Preprocessing Steps",
                 choices = c("Clean", "Transform", "Engineer"),
                 multiple = TRUE)
    )
  ),
  
  dashboardBody(
    useWaiter(), # Loading screens
    useShinyjs(), # JavaScript functionality
    
    # Custom CSS
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    
    tabItems(
      # Data Preparation Tab
      tabItem(tabName = "data_prep",
        fluidRow(
          box(
            title = "Data Preview",
            width = 12,
            DTOutput("data_preview")
          )
        ),
        fluidRow(
          box(
            title = "Data Quality Report",
            width = 6,
            verbatimTextOutput("data_summary")
          ),
          box(
            title = "Preprocessing Options",
            width = 6,
            checkboxGroupInput("preprocessing_options",
                             "Select Options:",
                             choices = c(
                               "Handle Missing Values" = "missing",
                               "Remove Outliers" = "outliers",
                               "Feature Scaling" = "scaling",
                               "Feature Engineering" = "engineering"
                             ))
          )
        )
      ),
      
      # Basic Visualizations Tab
      tabItem(tabName = "basic_viz",
        fluidRow(
          box(
            title = "Visualization Controls",
            width = 3,
            selectInput("plot_type", "Plot Type",
                       choices = c("Scatter", "Bar", "Line", "Box", "Histogram")),
            selectInput("x_var", "X Variable", choices = NULL),
            selectInput("y_var", "Y Variable", choices = NULL),
            selectInput("color_var", "Color Variable", choices = NULL),
            selectInput("facet_var", "Facet Variable", choices = NULL),
            checkboxInput("interactive", "Make Interactive", value = TRUE)
          ),
          box(
            title = "Visualization Output",
            width = 9,
            plotlyOutput("main_plot", height = "600px")
          )
        )
      ),
      
      # Advanced Visualizations Tab
      tabItem(tabName = "advanced_viz",
        fluidRow(
          box(
            title = "Advanced Plot Controls",
            width = 3,
            selectInput("advanced_plot_type", "Plot Type",
                       choices = c("Treemap", "Network", "Sunburst", "Sankey",
                                 "3D Scatter", "Heatmap", "Parallel Coordinates")),
            uiOutput("dynamic_controls")
          ),
          box(
            title = "Advanced Visualization Output",
            width = 9,
            plotlyOutput("advanced_plot", height = "600px")
          )
        )
      ),
      
      # Statistical Analysis Tab
      tabItem(tabName = "stats",
        navbarPage("Statistical Analysis",
          tabPanel("Descriptive Stats",
            fluidRow(
              box(verbatimTextOutput("desc_stats")),
              box(plotOutput("dist_plot"))
            )
          ),
          tabPanel("Correlation Analysis",
            fluidRow(
              box(plotOutput("corr_plot")),
              box(DTOutput("corr_table"))
            )
          ),
          tabPanel("Clustering",
            fluidRow(
              box(
                selectInput("cluster_method", "Clustering Method",
                           choices = c("K-means", "Hierarchical", "DBSCAN")),
                numericInput("n_clusters", "Number of Clusters", value = 3)
              ),
              box(plotOutput("cluster_plot"))
            )
          )
        )
      ),
      
      # Export Tab
      tabItem(tabName = "export",
        fluidRow(
          box(
            title = "Export Options",
            width = 12,
            selectInput("export_format", "Export Format",
                       choices = c("PDF", "HTML", "PNG", "Interactive HTML")),
            selectInput("export_plots", "Select Plots to Export",
                       choices = NULL, multiple = TRUE),
            downloadButton("download_report", "Generate Report"),
            actionButton("share_btn", "Share Visualizations")
          )
        )
      )
    )
  )
) 