head(fitbit_inventory)

activity_inventory <- fitbit_inventory %>%
  filter(grepl("Physical Activity", x = folder))

activity_inventory <- activity_inventory %>%
  separate(file, into = c("category", "date"), 
           sep = "[ _-]+(?=\\d{3,4})", 
           extra = "merge",
           fill = "right",
           remove = FALSE) %>%
  mutate(#date = sub(x = date, pattern = "\\.[a-z]{3,4}$", replacement = ""), #No longer needed
         category = sub(x = category, pattern = "(?i)([ _]*readme)?\\.[a-z]{3,4}$", replacement = ""), #Clean up the extensions and reduce the categories
         date = as.Date(x = date, format = "%Y-%m-%d"), #ensure this can read column as date
         file_type = if_else(grepl("csv|json", tolower(ext)), true = "data", false = "readme/other")) 

# Checking what else needs to be extracted and if the above code can be universal for the whole fitbit inventory

activity_inventory |> 
  filter(category == "exercise") |> 
  select(file:ext)

xyz <- activity_inventory |> 
  filter(is.na(date)) |> 
  group_by(category) |> 
  count()

sleep_inventory |> 
  filter(file_type == "readme/other") |> 
  select(file:ext)
