# Enhanced Server Logic
server <- function(input, output, session) {
  # Reactive Values
  rv <- reactiveValues(
    data = NULL,
    processed_data = NULL,
    plots = list(),
    current_theme = theme_modern()
  )
  
  # Data Import and Processing
  observeEvent(input$file, {
    waiter_show(html = spin_loader())
    
    tryCatch({
      file_ext <- tools::file_ext(input$file$datapath)
      rv$data <- switch(file_ext,
        "csv" = read_csv(input$file$datapath),
        "xlsx" = read_excel(input$file$datapath),
        "rds" = readRDS(input$file$datapath),
        "feather" = read_feather(input$file$datapath)
      )
      
      # Update variable selection inputs
      updateSelectInput(session, "x_var", choices = names(rv$data))
      updateSelectInput(session, "y_var", choices = names(rv$data))
      updateSelectInput(session, "color_var", choices = c("None", names(rv$data)))
      updateSelectInput(session, "facet_var", choices = c("None", names(rv$data)))
      
    }, error = function(e) {
      showNotification(
        paste("Error loading file:", e$message),
        type = "error"
      )
    })
    
    waiter_hide()
  })
  
  # Preprocessing Observer
  observeEvent(input$preprocessing_options, {
    req(rv$data)
    waiter_show(html = spin_loader())
    
    rv$processed_data <- preprocess_data(
      rv$data,
      steps = input$preprocessing_options
    )
    
    waiter_hide()
  })
  
  # Basic Plot Generation
  output$main_plot <- renderPlotly({
    req(rv$processed_data)
    
    plot <- create_visualization(
      data = rv$processed_data,
      viz_type = tolower(input$plot_type),
      x = input$x_var,
      y = input$y_var,
      color = if(input$color_var != "None") input$color_var else NULL,
      facet = if(input$facet_var != "None") input$facet_var else NULL,
      interactive = input$interactive
    ) +
    rv$current_theme
    
    rv$plots[[length(rv$plots) + 1]] <- plot
    return(plot)
  })
  
  # Advanced Plot Generation
  output$advanced_plot <- renderPlotly({
    req(rv$processed_data)
    
    create_advanced_visualization(
      data = rv$processed_data,
      viz_type = tolower(input$advanced_plot_type),
      params = get_advanced_params()
    )
  })
  
  # Statistical Analysis Outputs
  output$desc_stats <- renderPrint({
    req(rv$processed_data)
    summary(rv$processed_data)
  })
  
  output$corr_plot <- renderPlot({
    req(rv$processed_data)
    visualize_correlation(rv$processed_data)
  })
  
  # Export Functionality
  output$download_report <- downloadHandler(
    filename = function() {
      paste0("visualization_report_", Sys.Date(), ".", input$export_format)
    },
    content = function(file) {
      params <- list(
        data = rv$processed_data,
        plots = rv$plots[input$export_plots]
      )
      
      rmarkdown::render(
        "report_template.Rmd",
        output_file = file,
        params = params,
        envir = new.env(parent = globalenv())
      )
    }
  )
  
  # Helper Functions
  get_advanced_params <- reactive({
    switch(input$advanced_plot_type,
      "Treemap" = list(
        grouping = input$treemap_group,
        value = input$treemap_value
      ),
      "Network" = list(
        source = input$network_source,
        target = input$network_target,
        weight = input$network_weight
      ),
      # Add more parameter sets for other plot types
    )
  })
} 