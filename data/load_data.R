library(rnaturalearth)
library(sf)

# data set
df <- read.csv(
  "https://ourworldindata.org/grapher/cross-country-literacy-rates.csv?v=1&csvType=full&useColumnShortNames=true"
)

world <- ne_countries(scale = "medium", returnclass = "sf")
