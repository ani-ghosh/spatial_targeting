
# install.packages("remotes")
# remotes::install_github("rspatial/geodata")

wc <- geodata::worldclim_country("KEN", var="bio", path="data/raster/africa/kenya/")
wcg <- geodata::worldclim_global(var="bio", res = 10, path="data/global")
