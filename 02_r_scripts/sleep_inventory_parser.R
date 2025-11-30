# Compile the relevant Sleep data into tables

# Sleep inventory & its overview ------------------------------------------

sleep_inventory <- fitbit_inventory %>%
  filter(grepl("Sleep", x = folder))

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

# Function - Merge json files into one ----------------------------------

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

# Function - unnest json file ---------------------------------------------

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

# Function - Merge csv files into one ----------------------------

merge_csv <- function(category_name) {
  files_to_merge <- sleep_inventory |>
    filter(category == category_name,
           ext == "csv") |>
    pull(path)
  
  output_df <- read_csv(as.character(files_to_merge))
  return(output_df)
}

# Run Functions -----------------------------------------------------------

# CSV - Pull sleep categories and merge into single list
sleep_categories <- sleep_inventory_overview |> 
  filter(ext == "csv",
         !str_detect(category, "Histogram")) |> 
  pull(category)

sleep_csv <- map(sleep_categories, merge_csv)

# CSV - Changing names to make them more readable and code-friendly
sleep_categories_name <- sleep_categories |> 
  str_replace_all("\\s", "_") |> 
  str_to_lower()

sleep_csv <- set_names(sleep_csv, sleep_categories_name)

# json - Run function and merge with CSV output
sleep_json <- merge_json2()
sleep_json <- unnest_sleep_json(sleep_json)
sleep_data <- c(sleep_csv, sleep_json)
