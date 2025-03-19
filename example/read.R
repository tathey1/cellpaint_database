library(DBI)
library(RSQLite)
library(jpeg)
library(png)
library(tiff)
library(magrittr)

DatabaseLoader <- setRefClass(
  "DatabaseLoader",
  fields = list(db_file = "character", data_root = "character", conn = "ANY", table_name = "character"),
  methods = list(
    initialize = function(db_file, data_root) {
      db_file <<- db_file
      data_root <<- data_root
      conn <<- dbConnect(SQLite(), db_file)
      
      tables <- dbGetQuery(conn, "SELECT name FROM sqlite_master WHERE type='table';")
      stopifnot(nrow(tables) == 1)
      table_name <<- tables$name[1]
      print(paste("Tables in the database:", table_name))
      
      for (table in tables$name) {
        command <- paste("PRAGMA table_info(", table, ")", sep = "")
        attributes <- dbGetQuery(conn, command)
        print(paste("Table:", table))
        for (i in 1:nrow(attributes)) {
          attr <- attributes[i, ]
          print(paste("Attribute:", attr$name, ", Type:", attr$type, ", Default Val:", attr$dflt_value, ", Primary Key:", attr$pk))
        }
      }
    },
    close_connection = function() {
      if (!is.null(conn)) {
        dbDisconnect(conn)
      }
    },
    get_image = function(plate, well, channel) {
      if (is.numeric(well)) {
        query <- sprintf("SELECT path_unmixed FROM images WHERE plate = %d AND site = %d AND channel_num = %d", plate, well, channel)
      } else if (is.list(well)) {
        query <- sprintf("SELECT path_unmixed FROM images WHERE plate = %d AND row = '%s' AND column = %d AND field = %d AND channel_num = %d", 
                         plate, well[[1]], well[[2]], well[[3]], channel)
      }
      rows <- dbGetQuery(conn, query)
      stopifnot(nrow(rows) == 1)
      path <- file.path(data_root, rows$path_unmixed)
      
      if (grepl("\\.jpg$", path, ignore.case = TRUE)) {
        return(readJPEG(path))
      } else if (grepl("\\.png$", path, ignore.case = TRUE)) {
        return(readPNG(path))
      } else if (grepl("\\.tif$|\\.tiff$", path, ignore.case = TRUE)) {
        return(readTIFF(path))
      } else {
        stop("Unsupported image format")
      }
    },
    get_treatment = function(plate, well, channel) {
      if (is.numeric(well)) {
        query <- sprintf("SELECT treatment FROM images WHERE plate = %d AND site = %d AND channel_num = %d", plate, well, channel)
      } else if (is.list(well)) {
        query <- sprintf("SELECT treatment FROM images WHERE plate = %d AND row = '%s' AND column = %d AND field = %d AND channel_num = %d", 
                         plate, well[[1]], well[[2]], well[[3]], channel)
      }
      rows <- dbGetQuery(conn, query)
      stopifnot(nrow(rows) == 1)
      return(rows$treatment)
    },
    get_line = function(plate, well, channel) {
      if (is.numeric(well)) {
        query <- sprintf("SELECT line FROM images WHERE plate = %d AND site = %d AND channel_num = %d", plate, well, channel)
      } else if (is.list(well)) {
        query <- sprintf("SELECT line FROM images WHERE plate = %d AND row = '%s' AND column = %d AND field = %d AND channel_num = %d", 
                         plate, well[[1]], well[[2]], well[[3]], channel)
      }
      rows <- dbGetQuery(conn, query)
      stopifnot(nrow(rows) == 1)
      return(rows$line)
    }
  )
)




db_file <- "/Users/thomasathey/Documents/shavit-lab/fraenkel/data/aneesh/pilot.sqlite"
data_root <- "/Users/thomasathey/Documents/shavit-lab/fraenkel/data/aneesh"

# Create an instance of DatabaseLoader
db_loader <- DatabaseLoader$new(db_file = db_file, data_root = data_root)


plate <- 2
well <- 1
channel <- 1 

image <- db_loader$get_image(plate, well, channel)

# Plot the image
plot(1:2, type = "n", xlab = "", ylab = "")
rasterImage(image, 1, 1, 2, 2)  # Adjust plot area and image dimensions

# Close the database connection
db_loader$close_connection()