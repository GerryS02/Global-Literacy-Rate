library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(rnaturalearth)

# Load Data
source("data/load_data.R")

# Load Modules
source("modules/map.R")
source("modules/line_graph.R")

# UI
ui <- fluidPage(
  
  # App title
  titlePanel("Global Literacy Rate"),
  
  # Description paragraph
  p(
    "This visualization shows the share of adults aged 15 and older who can read and write a simple statement about their everyday life.",
    br(),
    "Literacy is a key foundation for education and opportunity, though definitions and measurement have varied across countries and over time."
  ),
  
  # Tabs for Map and Line Graph
  tabsetPanel(
    
    # Map Tab -> calls the UI function from map.R module
    tabPanel("Map",
      mapUI("map1")
    ),

    # Line Graph Tab -> calls the UI function from line_graph.R module
    tabPanel("Line",
      lineUI("line1")
    )
    
  )
)

# Server
server <- function(input, output, session) {

  # Map Server
  mapServer("map1", df, world)
  
  # Line Graph Server
  lineServer("line1", df)
  
}

# Run the App
shinyApp(ui, server)
