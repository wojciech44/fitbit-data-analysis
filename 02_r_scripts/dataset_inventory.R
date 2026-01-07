# Get the full structure of the folders in MyFitbitData
library(fs)
library(tidyverse)
library(jsonlite)
library(here)
library(hms)

#fitbit_structure_tree <- dir_tree(path = "00_raw_data/MyFitbitData", type = "directory")
fitbit_files <- dir_ls(path = "00_raw_data/MyFitbitData", recurse = TRUE)
fitbit_inventory <- tibble(path = fitbit_files,
                           folder = path_file(path_dir(fitbit_files)),#extract last element of the file's directory (i.e. folder)
                           file = path_file(fitbit_files),
                           ext = path_ext(fitbit_files),
                           size_kb = file_info(fitbit_files)$size
                           )

