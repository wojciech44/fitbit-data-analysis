README
================
2026-01-14

# **R** you **fit** enough? Fitbit Data analysis with R.

## 🚧 – WORK IN PROGRESS – 🚧

This project is currently under construction.

**Milestones**:

- [x] Compile files inventory - `dataset_inventory.R` ✅
- [x] Read and merge sleep data (json and csv) -
  `sleep_inventory_parser.R` ✅
- [x] Sleep EDA - `sleep_analysis.Rmd` [Click here to view the full
  Sleep Analysis Report 📊](04_reports/sleep_analysis.md)
- [ ] Read and merge activity data (json and csv) 🚧
- [ ] Activities EDA 🔰
- [ ] Read and merge all other data categories (Heart Rate, Estimated
  Oxygen) 🔰
- [ ] Global setting to produce plots 🔰
- [ ] Data compiler - produce single csv per category 🔰
- [ ] Conclusions 🔰

**Wishlist**:

- Shiny App for Sleep / Exercises
- Live data dashboard (API?)

------------------------------------------------------------------------

## Overview

**Purpose of this project** is to wrangle and analyse years of data
collected by the `Fitbit` wearables (`Versa 2` & `Versa 4`). It is a
learning project entirely written in **R**, utilizing packages from
`tidyverse`, `ggplot2` and related. It is meant to be a
beginner-friendly, functional project as I welcome new technology.

It is segmented into sections which by design should be executable
independently. Along the way we unpack and manipulate the data from
various categories, changing its shape to a rectangular one before we
proceed with the analysis. However these steps will be optional as you
could just use the `TBD script` to quickly merge your own files into one
digestible form (*this section is not completed yet*!). Output will be a
clean dataset and whether to use the visualizations to help you
jumpstart your own analysis is entirely up to you.

**Precise goals** of the analysis are yet to be determined. Though main
idea is to answer a few questions which came to mind and which may arise
during the EDA:

- How does sleep affect my training performance over time?
- Has my “fitness” improved, based on personal metrics like weight and
  perceived exhaustion?
- Do I sleep better because of the exercises?
- Do I have any `weird` sleep patterns which I am unaware of?
- Which Fitbit features actually matter for long-term tracking and
  improvement?

### Reports and visualizations

Check the detailed analysis below:

- [Sleep Analysis](04_reports/sleep_analysis.md)

------------------------------------------------------------------------

## Key considerations and prerequisites:

### R Packages used in the project

- [fs](https://fs.r-lib.org/)
- [tidyverse](https://tidyverse.org/)
- [jsonlite](https://jeroen.r-universe.dev/jsonlite)
- [here](https://here.r-lib.org/)
- [hms](https://hms.tidyverse.org/)

### Additional remarks

- Data was collected using `Fitbit` devices: `Versa 2` & `Versa 4`- not
  sure if this is compatible with other wearables from the brand
  (i.e. data collected by other devices might come in a different
  structure); see data structure for more details
- Written for data spanning across multiple years (2020-2025 in this
  case)
- Any input for testing or output is anonymised, given it is a sensitive
  and personal data
- Exported from Fitbit account (not Google account) - [see more
  details](https://accounts.fitbit.com/login)
- See Google support article on how to export your own data - [see more
  details](https://support.google.com/fitbit/answer/14236615?hl=en#zippy=%2Chow-do-i-export-my-fitbit-data)
- This is a learning project. The author is not a programmer and only
  has foundational knowledge of other programming languages. There can
  be tools and techniques better suited for this projects - any
  constructive feedback is welcome.

### Data Structure:

- Main challenge in phase 1 - import & data wrangling
- Consists of `folders` - `JSON` - `CSV` - `txt`
- Some metrics (for example `Stress Score`) have their `README.txt`
  files explaining variables. This will be available in the metrics
  explanation section/file
- Exported data structure as follows:

<!-- -->

    00_raw_data/MyFitbitData
    └── Username
        ├── Application
        ├── Biometrics
        ├── Google Data
        │   ├── Health Fitness Data
        │   └── Physical Activity
        ├── Heart
        ├── Menstrual Health
        ├── Other
        ├── Personal & Account
        │   └── Media
        ├── Physical Activity
        ├── Programs
        ├── Sleep
        ├── Social
        └── Stress

- As an example: There are roughly 4.8k files in a Sleep folder produced
  over the period of 5 years. This includes:
  - 1.7k Device Temperature output files of 44MB
  - 0.8k Minute SpO2 files of 9MB
  - 0.8k Heart Rate Variability Details of 3MB
  - 7 README files

------------------------------------------------------------------------

## Project structure

    ├── 00_raw_data
    │   └── MyFitbitData
    │       └── Username
    |           ...
    ├── 01_tidy_data
    ├── 02_r_scripts
    ├── 03_plots
    └── 04_reports

1.  Place your Fitbit export in `00_raw_data` folder.
2.  `01_tidy_data` is where your temporary files will be created when
    running analysis files.
3.  `02_r_scripts` stores the script files.
4.  `03_plots` this is where your plots will be stored if you enable the
    relevant setting.
5.  `04_reports` contains EDA files which produce the relevant plots.

## How to run the analysis

### 1. `dataset_inventory.R`

This will load the required libraries and create inventory object, which
is required in the next steps. You want to have a full list of items
exported from Fitbit/Google to get a proper overview of what you are
dealing with.

In case of missing libraries feel free to use the following code to
check and install missing components:

``` r
libs <- c("fs", "tidyverse", "jsonlite", "here", "hms")

installed_libs <- libs %in% rownames(installed.packages())
if (any(installed_libs == FALSE)) {
    install.packages(libs[!installed_libs])
}
```

### 2. `sleep_inventory_parser.R`

Build a sub-inventory focused on sleep and define functions which are
used for merging relevant sleep json and csv files.

### 3. `04_reports/sleep_analysis.Rmd`

[Run EDA for the sleep data](04_reports/sleep_analysis.md)

EDA of the sleep, trying to answer some of the questions based on
initial data observations.

### 4. `activity_parser.R`

Currently under construction - investigating a possibility of elevating
some of the parser features to the main inventory object -
`fitbit_inventory`. This would enrich it with additional info such as
relevant categories, splitting dates into separate fields etc. Benefit:
no need to have category-specific inventories - those can be derived
from the main one. Main challenge here - the data (esp. file names) do
not follow the same format across categories (sleep, activities, heart
rate etc.).

### Data compiler - 🚧 WORK IN PROGRESS 🚧

1.  Run the helper function, which:

- checks for libraries (if not found, there will a relevant notification
  displayed) - `dataset_inventory.R`
- creates inventory data frame that holds information on all of the raw
  files

2.  In case you are interested only in particular aspect of your data
    (sleep, exercise etc.) you can run parsers relevant to that part:
