#===============================================================================
# Create my own hexwall
#===============================================================================

# Packages
library(data.table)
source("hexwall2.R")

#-------------------------------------------------------------------------------
# Customised grouping
#-------------------------------------------------------------------------------

# Check sorted by color
hexwall("myhex", sticker_row_size = 9, sticker_width = 200, 
        sort_mode = "colour", background_color = NA)

# get all logos
logos = list.files("./all_logos")

# make data.table
d <- data.table(logos_png = logos)

# remove .png
d[, logos := gsub("\\.png$", "", logos)]

# groups
main = c("RStudio", "datatable", "ggplot2", "future")
plotting = c("patchwork", "viridis")
data = c("tidyverse", "readxl", "lubridate", "scales", "stringr")
documenting = c("markdown", "broom", "knitr", "blogdown")
spatial = c("sf", "terra", "spatialsample")
developing = c("devtools", "roxygen2", "testthat", "usethis", "purrr", "pkgdown")
other = c("tools4watlas", "shinyr", "rayshader")

# combine
x = c(data, spatial, main, plotting, documenting, developing, other)

# new order
first_row = c("sf", "terra", "spatialsample", "broom", "readxl", "lubridate", "scales", "stringr", "shinyr")
second_row = c("RStudio", "datatable", "tidyverse", "ggplot2", "patchwork", "viridis", "rayshader", "future")
third_row = c("devtools", "roxygen2", "testthat", "usethis", "purrr", "markdown", "knitr", "blogdown", "pkgdown")

# combine
x = c(first_row, second_row, third_row)

# check if any are missing
d[!(logos %in% x)]

# order by x
d = d[order(factor(logos, levels = x))]
d[, order := stringr::str_pad(.I, 2, pad = "0")]

# empty folder
do.call(file.remove, list(list.files("./my_logos", full.names = TRUE)))

# copy and rename logos
d[, all_logos_path := paste0("./all_logos/", logos, ".png")]
d[, my_logos_path := paste0("./my_logos/", order, "_", logos, ".png")]
file.copy(d$all_logos_path, d$my_logos_path)

# Check sorted by color
image <- hexwall("my_logos", sticker_row_size = 10, sticker_width = 200, 
                 sort_mode = "filename", background_color = "white")

# trim
image <- image_trim(image)

# preview
image

# save
image_write(image, path = "my_hexwall.png", format = "png")
