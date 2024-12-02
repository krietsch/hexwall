#===============================================================================
# Create my own hexwall
#===============================================================================

# Packages
library(data.table)
library(hexSticker)
library(ggplot2)
source("hexwall2.R")

#-------------------------------------------------------------------------------
# Customised grouping
#-------------------------------------------------------------------------------

# Check sorted by color
hexwall("myhex", sticker_row_size = 9, sticker_width = 200, 
        sort_mode = "colour", background_color = "white")

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

# sorted by filename
image <- hexwall("my_logos", sticker_row_size = 10, sticker_width = 200, 
                 sort_mode = "filename", background_color = "white")

# trim
image <- image_trim(image)

# preview
image

#-------------------------------------------------------------------------------
# remove edges
#-------------------------------------------------------------------------------

# empty black plot
p <- ggplot() +
  theme_void() + # Removes all default axes, grid, and text
  theme(panel.background = element_rect(fill = "black", color = NA), 
        plot.background = element_rect(fill = "black", color = NA)) 

# black sticker
sticker(p, package = "", p_size = 12, p_y = 0.5,
        p_color = "black", h_fill = "black", h_color = "black",
        filename = "black_logo.png")

# create n files for mask
n_logos = list.files("./my_logos") |> length()
d = data.table(name = 1:n_logos)
d[, path_black_logo := "black_logo.png"]
d[, path := paste0("./mask/", name, ".png")]

# empty folder
do.call(file.remove, list(list.files("./mask", full.names = TRUE)))

# copy and rename logos
file.copy(d$path_black_logo, d$path)

# black hexwall
mask <- hexwall("mask", sticker_row_size = 10, sticker_width = 200, 
                 sort_mode = "filename", background_color = "white")

# trim
mask <- image_trim(mask)

# negate
mask <- image_negate(mask)

# preview
mask

# mask hexwall
image_transparent <- image_composite(image, mask, operator = "CopyOpacity")

# save
image_write(image_transparent, path = "my_hexwall.png", format = "png")

