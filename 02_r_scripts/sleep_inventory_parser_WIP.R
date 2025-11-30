# Compile the relevant Sleep data into tables

# Sleep inventory & its overview ------------------------------------------

sleep_inventory <- fitbit_inventory %>%
  filter(grepl("Sleep", x = folder))

# NOTE: Can this be turned into a script that will build this detailed categorisation for the whole fitbit_inventory, rather than going by category?

sleep_inventory <- sleep_inventory %>%
  separate(file, into = c("category", "date"), 
           sep = "(\\s-\\s)|(-)", 
           extra = "merge",
           fill = "right",
           remove = FALSE) %>%
  mutate(date = sub(x = date, pattern = "\\.[a-z]{3,4}$", replacement = ""),
         category = sub(x = category, pattern = "\\.[a-z]{3,4}$", replacement = ""),
         date = as.Date(x = date, format = "%Y-%m-%d"), #ensure this can read column as date
         file_type = if_else(grepl("csv|json", tolower(ext)), true = "data", false = "readme/other")) 
  
sleep_inventory_overview <- sleep_inventory %>%
  group_by(category, ext) %>%
  summarize(n_files = n(), total_size = sum(size_kb), .groups = "drop") %>%
  arrange(desc(total_size))

# NOTE: make the above script about invetorization of sleep files, last step only to pull the summary
#Start parsing multiple files of each category into one bulk file. Ideally this can go through a function and feed to purr?


sleep_inventory |> 
  filter(category == "sleep")


# Decommissioned -----------------------------------------------------------
# Read sample json file V1

# sleep_sample_json <- jsonlite::fromJSON("00_raw_data/MyFitbitData/Username/Sleep/sleep-2021-02-05.json", flatten = TRUE)
# 
# sleep_sample_details_x <- sleep_sample_json |> 
#   select(logId, levels.data) |> 
#   unnest_longer(everything())
# 
# sleep_sample_details_y <- sleep_sample_json |> 
#   select(logId, levels.shortData) |> 
#   rename(levels.data = levels.shortData) |> 
#   unnest_longer(everything())
# 
# sleep_sample_details <- sleep_sample_details_x |> 
#   bind_rows(sleep_sample_details_y)
# 
# # Check if the total agree for Wake etc.
# sleep_sample_check <- sleep_sample_details |> 
#   group_by(logId, levels.data$level) |>
#   # summarize(level_total = sum(levels.data$seconds)) |> 
#   # mutate(level_total = level_total / 60)
#   count(levels.data$level)

# Read sample sleep json file V2 ------------------------------------------

sleep_file_path <- "00_raw_data/MyFitbitData/Username/Sleep/sleep-2021-02-05.json" 
sleep_sample_json <- tibble(json = read_json(sleep_file_path))

sleep_sample_json_unn <- sleep_sample_json |> 
  unnest_wider(json) |>
  unnest_wider(levels) |> 
  unnest_longer(summary) |> #changed from unnest_wider(summary)
  unnest_wider(summary, names_sep = "_") #|> #changed from unnest_wider(deep:rem, names_sep = "_")
  # Here this  script should stop - the data columns and shortData coulmns contain details - should not be in the same table as summarize.
  # rowwise() |> 
  # mutate(all_level_details = list(bind_rows(data, shortData))) |> 
  # ungroup() |> 
  # select(-data, -shortData) |> 
  # unnest_longer(all_level_details)

# NOTE: - found some inconsistencies in the raw data - between "summary" vs "data" & "shortData" - as an example see "31216003223",
# where summary counted 15 occurrences of REM vs data showing 6 occurrences for the same sleep. 
# What is the magnitude of the discrepancies?

# Turn sample json file V2 into function ----------------------------------

merge_json <- function() {
  files_to_merge <- sleep_inventory |>
    filter(ext == "json") |>
    pull(path)

  output_df <- tibble()
  for (file in files_to_merge) {
    json <- read_json(as.character(file))
    output_df <- bind_rows(output_df, json)
  }
   return(output_df)
}

merge_json2 <- function() {
  files_to_merge <- sleep_inventory |> 
    filter(ext == "json") |> 
    pull(path)
  
  output_tibble <- map(files_to_merge, function(x) {
    tibble(json = read_json(x))
  }) |> 
    bind_rows()
  return(output_tibble)
}

sleep_json <- merge_json2()


# Sleep json unnesting function -------------------------------------------

unnest_sleep_json <- function(sleep_data_json) {
  output_df_1 <- sleep_data_json |> 
    unnest_wider(json) |>
    unnest_wider(levels) |> 
    unnest_longer(summary) |>
    unnest_wider(summary, names_sep = "_") |> 
    select(-data, -shortData)
  
  output_df_2 <- sleep_data_json |> 
    unnest_wider(json) |> 
    unnest_wider(levels) |> 
    select(logId:dateOfSleep, data:shortData) |> 
    rowwise() |> 
    mutate(all_levels_data = list(bind_rows(data, shortData))) |> 
    ungroup() |> 
    select(-data, -shortData) |> 
    unnest_longer(all_levels_data)
  
  output_df <- list(sleep_summary = output_df_1, sleep_details = output_df_2)
  return(output_df)
}

sleep_json <- unnest_sleep_json(sleep_json)
  
### test & test2 works only with the first iteration of merge_json, which uses for loop
# test <- sleep_data_json |> 
#   unnest_longer(levels) |> 
#   filter(levels_id != "") |> 
#   unnest_wider(levels, names_sep = "_") #|> 
 # This can be ignored -> using test2 instead
 # left_join(
  #   sleep_data_json |> 
  #     unnest_longer(levels) |> 
  #     filter(levels_id == "") |> 
  #     select(logId, levels),
  #   by = "logId"
#  ) JOIN OR KEEP THESE TWO THINGS SEPARATE? 

# test2 <- sleep_data_json |> 
#   unnest_longer(levels) |> 
#   filter(levels_id == "") |> 
#   unnest_wider(levels)
#Which Structure is better? The Sample json or split into two seperate tibbles sleep_data_summary & sleep_data_details?

# Read sample Device Temperature csv file ---------------------------------

device_temp_file_path <- "00_raw_data/MyFitbitData/Username/Sleep/Device Temperature - 2025-03-23.csv"
device_temp_sample <- read_csv(device_temp_file_path)

# Turn sample Device Temperature into function ----------------------------

merge_csv <- function(category_name) {
  files_to_merge <- sleep_inventory |>
    filter(category == category_name,
           ext == "csv") |>
    pull(path)
  
  #this part is not needed: 
  #output_df <- tibble()
  # for (file in files_to_merge) {
  #   single_file <- read_csv(as.character(file))
  #   output_df <- bind_rows(output_df, single_file)
  # }
  output_df <- read_csv(as.character(files_to_merge))
  return(output_df)
}

# Read sample Minute SpO2 file --------------------------------------------

sleep_inventory |> 
  filter(category == "Minute SpO2")

minute_spo2_file_path <- "00_raw_data/MyFitbitData/Username/Sleep/Minute SpO2 - 2023-06-21.csv"
minute_spo2_sample <- read_csv(minute_spo2_file_path)

# File has the same simple structure as the Device temperature file, meaning same function can be used to glue the different csv files

# Merging csv by relevant sleep category ----------------------------------

sleep_categories <- sleep_inventory_overview |> 
  filter(ext == "csv",
         !str_detect(category, "Histogram")) |> 
  pull(category)

sleep_csv <- map(sleep_categories, merge_csv)

# Changing names to make them more readable and code-friendly
sleep_categories_name <- sleep_categories |> 
  str_replace_all("\\s", "_") |> 
  str_to_lower()

sleep_csv <- set_names(sleep_csv, sleep_categories_name)

sleep_data <- c(sleep_data_csv, test_json)
