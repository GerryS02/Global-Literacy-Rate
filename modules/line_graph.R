# UI function for the line graph module
lineUI <- function(id){
  
  ns <- NS(id)  # Namespace to prevent ID conflicts in Shiny modules
  
  fluidRow(
    
    # Left column: country selection
    column(3,
      wellPanel(
        h4("Select Countries"),
        selectInput(
          ns("countries"),                    # Namespaced input ID
          "Choose countries:",                # Label above dropdown
          choices = unique(df$entity),       # All countries from the data
          selected = c("Spain", "Netherlands", "Germany", "United Kingdom", "Mexico"),
          multiple = TRUE                     # Allow multiple selection
        ),
        br()
      )
    ),
    
    # Right column: line chart output
    column(9,
      plotlyOutput(ns("line_graph"))         # Placeholder for Plotly line chart
    ),
    
    # Year range slider at full width
    column(12,
      wellPanel(
        sliderInput(
          ns("year_range"),
          "Select Year Range:",
          min = min(df$year),
          max = max(df$year),
          value = c(1475, 2023),
          sep = "",
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


# Server function for the line graph module
lineServer <- function(id, df){
  
  moduleServer(id, function(input, output, session){
    
    output$line_graph <- renderPlotly({
      
      # Get user selections
      selected_countries <- input$countries
      yr_range <- input$year_range
      
      # Filter dataset for selected countries and year range
      countries <- df |>
        filter(entity %in% selected_countries) |>
        filter(year >= yr_range[1], year <= yr_range[2]) |>
        filter(!is.na(literacy_rate))
      
      # Check number of observations per country
      country_counts <- countries |>
        count(entity)
      
      # Validate: must have at least 2 data points per country
      validate(
        need(
          nrow(countries) > 0 && any(country_counts$n >= 2),
          paste(
            "\nInsufficient data for the selected countries between",
            yr_range[1], "and", yr_range[2], ".\n",
            "Try selecting a wider year range or different countries."
          )
        )
      )
      
      # Build ggplot
      g <- ggplot(countries, aes(x = year, y = literacy_rate, group = entity)) +
        
        # Line with color mapping and custom hover text
        geom_line(aes(
          color = entity,
          text = paste0(entity, ": ", round(literacy_rate, 1), "%")
        )) +
        
        # Points on the line (without legend)
        geom_point(aes(color = entity), show.legend = FALSE) +
        
        # Y-axis formatting (0-100%)
        scale_y_continuous(
          limits = c(0, 100),
          breaks = seq(0, 100, 20),
          labels = function(x) paste0(x, "%")
        ) +
        
        # Labels
        labs(
          title = paste0("Literacy rate, ", yr_range[1], " to ", yr_range[2]),
          y = "Literacy rate",
          x = "Year",
          color = "Countries"
        )
      
      # Convert ggplot to Plotly
      p <- ggplotly(g, tooltip = "text")
      
      # Remove hover from points and customize line hover
      for(i in seq_along(p$x$data)){
        
        # Skip hover on points
        if(p$x$data[[i]]$mode == "markers"){
          p$x$data[[i]]$hoverinfo <- "skip"
        }
        
        # Customize hover on lines
        if(p$x$data[[i]]$mode == "lines"){
          p$x$data[[i]]$hovertemplate <- paste0("%{text}<extra></extra>")
        }
      }
      
      # Unified hover mode
      p <- p |>
        layout(
          hovermode = "x unified",
          xaxis = list(hoverformat = "d")
        )
      
      # Return the interactive plot
      p
    })
    
  })
}
