## Add user sites to GPS device
## Jon Skaggs
## initiated 2020-08-17

library(sf)

## Goal: convert spatial data from CSV to GPX then upload to a GPS device.
## Although this script forces the output file to retain all fields present in
## the CSV, GPS devices expect specific field names within the .GPX file to
## render names, descriptions, etc on the device screen. If you want, for
## example, your site names to appear as waypoint names, use the
## CSV_to_GPX_template.csv file in this directory to rename your field names.
## This script loads a CSV file with spatial data. Coordinates should be in
## decimal degrees and WGS84. Using the `sf` package, a dataframe is converted
## to a simple features object then exported as .GPX file.

## Install the `sf` package if you don't have it already. Specify user variables
## then run all lines. Once complete, navigate to the workspace and copy-paste
## the the .gpx file to the GPX folder on the GPS device using your file
## explorer (e.g. F:/Garmin/GPX/sites_joycesbranch_2018.gpx).


# User variables ----------------------------------------------------------


pathcsv <- "C:/Garmin/toGarmin/CSV_to_GPX_template.csv"
xfield <- "X"
yfield <- "Y"
GPXname <- "sites_joycesbranch_2018"


# Script ------------------------------------------------------------------


# Load CSV
pts <- sf::st_as_sf(read.csv(pathcsv), coords = c(xfield, yfield))

# Save points as GPX
sf::st_write(
  obj = pts,
  dsn = paste0("C:/Garmin/toGarmin/", GPXname, ".gpx"),
  driver  = "GPX",
  dataset_options="GPX_USE_EXTENSIONS=YES",
  overwrite = TRUE)
