library(shiny)
library(shinydashboard)
library(leaflet)
library(DT)
library(shinyjs)
library(terra)
library(sf)

source("zzz/server_calculation.R")

ui <- dashboardPage(
  dashboardHeader(title = "Targeting Tools"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Land Suitability", tabName = "suitability", icon = icon("map")),
      menuItem("Land Similarity", tabName = "similarity", icon = icon("clone")),
      menuItem("Land Statistics", tabName = "statistics", icon = icon("chart-bar"))
    )
  ),
  dashboardBody(
    useShinyjs(),
    tags$head(
      tags$style(HTML("
        .content-wrapper {background-color: #fff;}
        .box {border-top: 3px solid #3c8dbc;}
        .table-container {max-height: 300px; overflow-y: auto;}
      "))
    ),
    tabItems(
      tabItem(tabName = "suitability",
              fluidRow(
                column(3,
                       box(width = NULL, title = "Data Selection", status = "primary",
                           selectInput("region", "Select Region:", choices = NULL),
                           selectInput("country", "Select Country:", choices = NULL),
                           uiOutput("raster_selector"),
                           actionButton("load_data", "Load Data", class = "btn-primary"),
                           fileInput("custom_raster", "Upload Custom Raster", accept = c(".tif", ".asc")),
                           textInput("custom_raster_name", "Custom Raster Name"),
                           hr(),
                           h4("Analysis"),
                           actionButton("run_analysis", "Run Analysis", class = "btn-success"),
                           actionButton("view_results", "View Results", class = "btn-info"),
                           downloadButton("download_results", "Download Results", class = "btn-primary")
                       )
                ),
                column(9,
                       box(width = NULL, title = "Selected Rasters", status = "primary",
                           div(class = "table-container", DTOutput("selected_rasters_table"))
                       ),
                       box(width = NULL, title = "Map", status = "primary",
                           leafletOutput("map", height = 500),
                           uiOutput("layer_controls")
                       )
                )
              )
      ),
      tabItem(tabName = "similarity",
              # Similar structure to suitability tab, adapted for similarity analysis
      ),
      tabItem(tabName = "statistics",
              # Similar structure to suitability tab, adapted for statistics analysis
      )
    )
  )
)

server <- function(input, output, session) {
  
  # Reactive values
  selected_rasters <- reactiveVal(list())
  raster_data <- reactiveVal(data.frame())
  suitability_result <- reactiveVal(NULL)
  
  # Initialize region selector
  observe({
    regions <- list.dirs("data", full.names = FALSE, recursive = FALSE)
    updateSelectInput(session, "region", choices = regions)
  })
  
  # Update country selector based on selected region
  observe({
    req(input$region)
    if (input$region == "Global") {
      updateSelectInput(session, "country", choices = "Global")
    } else {
      countries <- list.dirs(file.path("data", input$region), full.names = FALSE, recursive = FALSE)
      updateSelectInput(session, "country", choices = c("All", countries))
    }
  })
  
  # Update map view when region or country is selected
  observe({
    req(input$region, input$country)
    if (input$region == "Global") {
      leafletProxy("map") %>% setView(lng = 0, lat = 0, zoom = 2)
    } else if (input$country == "All") {
      switch(input$region,
             "Africa" = leafletProxy("map") %>% setView(lng = 20, lat = 0, zoom = 3),
             "Asia" = leafletProxy("map") %>% setView(lng = 100, lat = 30, zoom = 3),
             # Add more regions as needed
      )
    } else {
      # You might need to implement a lookup table or API call to get country coordinates
      # For now, we'll just zoom in a bit
      leafletProxy("map") %>% setView(zoom = 5)
    }
  })
  
  # Update raster selector
  output$raster_selector <- renderUI({
    req(input$region, input$country)
    if (input$region == "Global") {
      path <- file.path("data", input$region)
    } else if (input$country == "All") {
      path <- file.path("data", input$region)
    } else {
      path <- file.path("data", input$region, input$country)
    }
    
    rasters <- list.files(path, pattern = "\\.tif$", full.names = FALSE)
    if (length(rasters) == 0) {
      return(HTML("<p>No raster data available for the selected location.</p>"))
    } else {
      checkboxGroupInput("rasters", "Select Rasters:", choices = rasters)
    }
  })
  
  # Load data when button is clicked
  observeEvent(input$load_data, {
    req(input$region, input$country, input$rasters)
    
    withProgress(message = 'Loading data...', value = 0, {
      if (input$region == "Global") {
        path <- file.path("data", input$region)
      } else if (input$country == "All") {
        path <- file.path("data", input$region)
      } else {
        path <- file.path("data", input$region, input$country)
      }
      
      rasters <- file.path(path, input$rasters)
      
      if (length(rasters) == 0) {
        showNotification("No raster files selected.", type = "warning")
        return()
      }
      
      raster_list <- setNames(rasters, basename(rasters))
      selected_rasters(raster_list)
      
      # Process rasters and create initial data frame
      data <- lapply(seq_along(raster_list), function(i) {
        r <- rast(raster_list[[i]])
        incProgress(1/length(raster_list))
        c(names(raster_list)[i], round(minmax(r), 3))
      })
      
      df <- do.call(rbind, data)
      df <- as.data.frame(df)
      colnames(df) <- c("Raster", "Min Value", "Max Value")
      df$"Optimal From" <- NA
      df$"Optimal To" <- NA
      df$"Combine" <- FALSE
      
      raster_data(df)
      
      incProgress(1)
    })
  })
  
  # Add custom raster to selected rasters
  observeEvent(input$custom_raster, {
    req(input$custom_raster, input$custom_raster_name)
    custom_raster <- setNames(list(input$custom_raster$datapath), input$custom_raster_name)
    selected_rasters(c(selected_rasters(), custom_raster))
    
    # Update raster_data with the new custom raster
    r <- rast(custom_raster[[1]])
    new_row <- data.frame(
      Raster = input$custom_raster_name,
      "Min Value" = round(minmax(r)[1], 3),
      "Max Value" = round(minmax(r)[2], 3),
      "Optimal From" = NA,
      "Optimal To" = NA,
      Combine = FALSE
    )
    raster_data(rbind(raster_data(), new_row))
  })
  
  # Render selected rasters table
  output$selected_rasters_table <- renderDT({
    df <- raster_data()
    if (nrow(df) == 0) return(NULL)
    
    datatable(df, editable = TRUE, options = list(
      pageLength = 10,
      lengthMenu = c(5, 10, 15, 20),
      searching = FALSE
    )) %>% 
      formatRound(columns = c("Min Value", "Max Value", "Optimal From", "Optimal To"), digits = 3)
  })
  
  # Update raster_data when table is edited
  observeEvent(input$selected_rasters_table_cell_edit, {
    info <- input$selected_rasters_table_cell_edit
    df <- raster_data()
    df[info$row, info$col] <- info$value
    raster_data(df)
  })
  
  # Run suitability analysis
  observeEvent(input$run_analysis, {
    rasters <- selected_rasters()
    if (length(rasters) == 0) {
      showNotification("Please select at least one raster", type = "warning")
      return()
    }
    
    withProgress(message = 'Calculating land suitability...', value = 0, {
      # Load rasters
      r_list <- lapply(rasters, rast)
      
      # Get the edited values from the table
      table_data <- raster_data()
      
      # Calculate suitability using the separate function
      suitability <- calculate_suitability(r_list, table_data)
      suitability_result(suitability)
      
      incProgress(1)
    })
    
    showNotification("Analysis complete. Click 'View Results' to see the output.", type = "message")
  })
  
  # View results
  observeEvent(input$view_results, {
    req(suitability_result())
    
    # Update map with suitability results
    pal <- colorNumeric("viridis", values(suitability_result()), na.color = "transparent")
    
    leafletProxy("map") %>%
      clearImages() %>%
      addRasterImage(suitability_result(), colors = pal, opacity = 0.7, group = "Suitability") %>%
      addLayersControl(
        overlayGroups = c("Suitability", names(selected_rasters())),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      addLegend(pal = pal, values = values(suitability_result()), title = "Suitability")
  })
  
  # Layer controls
  output$layer_controls <- renderUI({
    req(selected_rasters())
    checkboxGroupInput("layer_visibility", "Toggle Layers:",
                       choices = c("Suitability", names(selected_rasters())),
                       selected = "Suitability")
  })
  
  # Update layer visibility
  observe({
    req(input$layer_visibility)
    leafletProxy("map") %>%
      hideGroup(setdiff(c("Suitability", names(selected_rasters())), input$layer_visibility)) %>%
      showGroup(input$layer_visibility)
  })
  
  # Download suitability results
  output$download_results <- downloadHandler(
    filename = function() {
      paste("suitability_", Sys.Date(), ".tif", sep="")
    },
    content = function(file) {
      req(suitability_result())
      writeRaster(suitability_result(), file)
    }
  )
  
  # Initialize map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 0, lat = 0, zoom = 2)
  })
}

# Run the application
shinyApp(ui = ui, server = server)