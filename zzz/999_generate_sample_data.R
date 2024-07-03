library(terra)

# Define regions and countries
regions <- c("Africa", "Asia", "Global")
countries <- list(
  Africa = c("Kenya", "Ethiopia", "Tanzania", "Nigeria", "Egypt"),
  Asia = c("India", "China", "Japan", "Indonesia", "Bangladesh"),
  Global = c()
)

# Create folder structure
dir.create("data", showWarnings = FALSE)
for (region in regions) {
  dir.create(file.path("data", region), showWarnings = FALSE)
  if (region != "Global") {
    for (country in countries[[region]]) {
      dir.create(file.path("data", region, country), showWarnings = FALSE)
    }
  }
}

# Generate sample raster data
generate_sample_raster <- function(name, rows = 100, cols = 100) {
  r <- rast(nrows = rows, ncols = cols, xmin = 0, xmax = 100)
  values(r) <- runif(ncell(r))
  writeRaster(r, filename = name, overwrite = TRUE)
}

# Create sample data for each country and global
for (region in regions) {
  if (region != "Global") {
    for (country in countries[[region]]) {
      for (i in 1:5) {  # Create 5 sample rasters per country
        generate_sample_raster(file.path("data", region, country, paste0("bio", i, ".tif")))
      }
    }
  } else {
    for (i in 1:5) {  # Create 5 sample global rasters
      generate_sample_raster(file.path("data", region, paste0("global_bio", i, ".tif")))
    }
  }
}

print("Folder structure and sample data created successfully.")