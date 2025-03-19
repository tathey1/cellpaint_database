source("/Users/thomasathey/Documents/shavit-lab/fraenkel/data/aneesh/cellpaint_database/cellpaint_database/database_loader.R")



db_file <- "/Users/thomasathey/Documents/shavit-lab/fraenkel/data/aneesh/pilot.sqlite"
data_root <- "/Users/thomasathey/Documents/shavit-lab/fraenkel/data/aneesh"

# Create an instance of DatabaseLoader
db_loader <- DatabaseLoader$new(db_file = db_file, data_root = data_root)


plate <- 2
well <- list("B", 2, 1)
well2 <- 1
channel <- 1

line <- db_loader$get_line(plate, well, channel)
treatment <- db_loader$get_treatment(plate, well, channel)
image <- db_loader$get_image(plate, well2, channel)

# Plot the image
plot(1:2, type = "n", xlab = "", ylab = "")
rasterImage(image, 1, 1, 2, 2)  # Adjust plot area and image dimensions
title_text <- paste(line, "x", treatment)
title(main = title_text, col.main = "blue", font.main = 2, cex.main = 1.5)


# Close the database connection
db_loader$close_connection()