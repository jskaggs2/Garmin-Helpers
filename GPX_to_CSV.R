## Input GPX and output CSV
## Jon Skaggs
## initiated 2020-08-13

## Goal: Get GPX and DCIM data from Lance Lab GPS devices. Convert the GPX data
## to CSV. Save a copy of the original data. Tested on PC with WAYPOINT data.
## Not tested on Mac.

## After running this script, make sure all data was saved correctly. To reset
## the GPS device use Main Menu (Menu twice) > Setup > Reset > Recent All

library(sf)


# User variables ----------------------------------------------------------


# Define a working folder for data conversion.
path <- file.path("C:", "Garmin", "FromGarmin")

# The Lance Lab has two GPS units. Specify which one you are downloading data
# from here (GPS1 or GPS2).
gps_id <- "GPS2"

# Plug in the GPS device. Then specify its drive letter below.
gps_letter <- "F"


# Create file structure ---------------------------------------------------


# Check to see if `path` exists; if it doesn't, create it.
if(!(dir.exists(path))){
  dir.create(path)
}

# Create a file directory in `path`. Folder name should be today's date using
# YYYY-MM-DD.
infolder <- file.path(path, Sys.Date(), gps_id)
if(!(file.exists(infolder))){
  dir.create(infolder, recursive = TRUE)
}

# Define a path to the GPS GPX files.
d <- paste0(gps_letter, ":")
path_gpx <- file.path(d, "Garmin", "GPX")

# Define a path to the GPS photo files.
path_dcim <- file.path(d, "DCIM")


# Copy files from GPS -----------------------------------------------------


# Cursory check to protect data from overwrite. If the destination file is
# empty, proceed. If files already exist there, don't copy data and print a
# warning. If you get a warning here, check to see if data exists in the
# target directory!
if(length(list.files(infolder)) == 0){
  # Save a copy of the original data to your working folder.
  file.copy(from = path_gpx, to = infolder, recursive = TRUE)
  file.copy(from = path_dcim, to = infolder, recursive = TRUE)
}else{
  print(infolder)
  stop("Files already exist in the target destination folder.")
}

# Load GPX then export as CSV ---------------------------------------------


# Get list of data files to convert
infiles <- list.files(path = paste0(infolder, "/GPX"), pattern = ".gpx", full.names = TRUE)

# GPX can contain multiple layers; extract all layers with > 0 features.
# Loop over each input GPX.
for (gpx in infiles){
  # Use regex to extract an input GPX file name.
  gpx_name <- sub(pattern = ".*/", replacement = "", x = gpx)
  # Get metadata that describes multiple layers within a single GPX.
  layers <- sf::st_layers(gpx)
  # Only keep layers with more than one feature.
  layerskeep <- which(layers[["features"]] > 0)
  # Loop over each layer within each GPX that meet our condition.
  for (layer in layerskeep){
    # Get name of target layer.
    layername <- layers[["name"]][layer]
    # Read layer of interest.
    gpxlayer <- sf::st_read(gpx, layer = layername)
    # Define output file name.
    outfile <- paste0(infolder, "/", gpx_name, "_", layername, ".csv")
    # Write csv and retain X and Y coordinates as numeric fields.
    st_write(gpxlayer, outfile, layer_options = "GEOMETRY=AS_XY")
  }
}
