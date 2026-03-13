# -------------------------
# Map Module
# -------------------------

# UI function for the map module
mapUI <- function(id) {
  
  ns <- NS(id)  # Namespace to avoid ID conflicts in Shiny modules
  
  fluidRow(
    
    # Map output (full width)
    column(12, plotlyOutput(ns("map"))),
    
    # Year slider below the map
    column(12,
      wellPanel(
        sliderInput(
          ns("year"),                     # Namespaced input ID
          "Select Year:",                 # Label above slider
          min = min(df$year),             # Minimum year from dataset
          max = max(df$year),             # Maximum year
          value = 1950,                   # Default value
          step = 1,
          sep = "",
          animate = TRUE,
          ticks = TRUE,
          animateOptions(interval = 300, loop = FALSE),
          width = "100%"
        )
      )
    ),
    
    # Footer with author and data source
    column(12,
      p(
        style = "font-size: 12px; color: #666;",
        "Created by Gerry Summers | Data Source: ",
        tags$a(
          "Literacy rate, 2023",
          href = "https://ourworldindata.org/grapher/cross-country-literacy-rates?tab=map&facet=none",
          target = "_blank"
        )
      )
    )
  )
}

# Server function for the map module
mapServer <- function(id, df, world) {
  
  moduleServer(id, function(input, output, session) {
    
    # Render interactive Plotly map
    output$map <- renderPlotly({
      
      yr <- input$year  # Get the selected year from slider
      
      # Filter dataset to latest available data per country for selected year
      map_data <- df |>
        filter(year <= yr, code != "") |>   # Keep only valid country codes
        arrange(code, desc(year)) |>        # Sort by country code and descending year
        distinct(code, .keep_all = TRUE)    # Keep only the latest data per country
      
      # Join map data with world polygons
      world_data <- world |>
        left_join(map_data, by = c("iso_a3_eh" = "code"))
      
      # Create hover text for each country
      world_data <- world_data |>
        mutate(
          hover_text = paste0(
            name, "<br>",
            "Year: ", coalesce(year, yr), "<br>",
            "Literacy: ", ifelse(!is.na(literacy_rate), paste0(literacy_rate, "%"), "No data")
          )
        )
      
      # Build ggplot map
      m <- ggplot(world_data) +
        geom_sf(aes(fill = literacy_rate, text = hover_text)) +  # Fill by literacy rate, hover text
        labs(
          title = paste0("Global Literacy Rate (", yr, ")"),
          fill = "Literacy Rate"
        ) +
        theme_minimal()
      
      # Convert to interactive Plotly map with hover text
      ggplotly(m, tooltip = "text")
      
    })
    
  })
}
