library(tidyverse)
df <- read_csv("data/processed/combined_annotations/gold_standard.csv")

# Manual correction of duplicates

# Allianz, year = 2019, scope 2mb and scope 3
# delete rows with NA
allianz <- df %>% filter(grepl("Allianz", report_name) & 
                          year==2019 & (scope=="2mb" | scope=="3") & is.na(value))

# apollo commercial, year = 2019, scope 1
# delete row with NA
apollo <- df %>% filter(grepl("apollo commercial", report_name) & 
                          year==2019 & (scope=="1" | scope=="2lb") & is.na(value))

# allfunds year = 2019 and 2020 scope 1, year = 2019 and 2020 scope = 2lb
# delete rows with NA
allfunds <- df %>% filter(grepl("allfunds", report_name) & 
                          (year==2019 | year==2020) & (scope=="1" | scope=="2lb") & is.na(value))

# autoneum, year = 2018 and 2019, scope 1
# delete rows with NA
autoneum <- df %>% filter(grepl("autoneum", report_name) & 
                          (year==2018 | year==2019) & scope=="1" & is.na(value))

# cubesmart, year = 2020, scope 1
# delete row with NA
cubesmart <- df %>% filter(grepl("cubesmart", report_name) & 
                          (year==2020 | year==2021) & scope=="1" & is.na(value))

# sumitomo, year = 2020, scope 1
# delete row with NA
sumitomo <- df %>% filter(grepl("sumitomo", report_name) & 
                          year==2020 & scope=="1"  & is.na(value))

# delete from df
rows_delete <- bind_rows(allianz, apollo, allfunds, autoneum, cubesmart, sumitomo)
df <- anti_join(df, rows_delete)
write_csv(df, "data/processed/combined_annotations/gold_standard_revised.csv")


## Changes to cubesmart
# Missing annotation
df <- read_csv("data/processed/combined_annotations/gold_standard_revised.csv")

# Cubesmart 2021

# 1. Row for 2019 2lb should be replaced with row for 2019 2mb
# 2. Add new values from report for 2020 2lb (31111) and 2021 2lb (30354)

cubesmart_2020_2021_2lb <- df %>% filter(grepl("cubesmart", report_name) & (year==2019 | year==2020 | year==2021) & scope=="2lb")
cubesmart_2019_2mb <- df %>% filter(grepl("cubesmart", report_name) & year==2019 & scope=="2mb")

cubesmart_new_rows <- bind_rows(cubesmart_2019_2mb, cubesmart_2020_2021_2lb)
cubesmart_new_rows <- cubesmart_new_rows |> fill(c(page, value, unit, unit_normalized, metric_name, display_type, extracted_text_from_page), .direction = "down")
cubesmart_new_rows <- cubesmart_new_rows |> 
  mutate(value = case_when(
    year==2020 & scope=="2lb" ~ 31111,
    year==2021 & scope=="2lb" ~ 30354,
    TRUE ~ value
  ))

cubesmart_new_rows <- cubesmart_new_rows |> 
  mutate(page = ifelse(year==2019 & scope=="2mb", NA, page),
         value = ifelse(year==2019 & scope=="2mb", NA, value),
         unit = ifelse(year==2019 & scope=="2mb", NA, unit),
         unit_normalized = ifelse(year==2019 & scope=="2mb", NA, unit_normalized),
         metric_name = ifelse(year==2019 & scope=="2mb", NA, metric_name),
         display_type = ifelse(year==2019 & scope=="2mb", NA, display_type),
         extracted_text_from_page = ifelse(year==2019 & scope=="2mb", NA, extracted_text_from_page)
         )

# Remove old rows from df
df <- df |> anti_join(cubesmart_new_rows, by = c("report_name", "year", "scope"))

# Add new rows to df
df <- bind_rows(df, cubesmart_new_rows)

# Sort
df <- df |> arrange(report_name, scope, year)

# Save
write_csv(df, "data/processed/combined_annotations/gold_standard_revised.csv")



## Correction to cubesmart and lundin

# Issue cubesmart: wrong values were copied in last correction of cubesmart

# Report: cubesmart reit_2021_report.pdf
# Scope 2lb: 
# 2019: 27984 MTCO2e
# 2020: 25276 MTCO2e
# 2021: 23918 MTCO2e

df <- read_csv("data/processed/combined_annotations/gold_standard_with_ISINs_edited.csv")

cubesmart_new <- df |> filter(grepl("cubesmart", report_name_old) & (year==2019 | year==2020 | year==2021) & scope=="2lb") |> 
  mutate(value = case_when(
    year==2019 ~ 27984,
    year==2020 ~ 25276,
    year==2021 ~ 23918,
    TRUE ~ value
  ))

# Remove old rows from df
df <- df |> anti_join(cubesmart_new, by = c("report_name_old", "year", "scope"))

# Add new rows to df
df <- bind_rows(df, cubesmart_new) |> arrange(report_name_old, scope, year)

# Issue lundin: same value given for 2lb and 2mb, but should be only 2lb

# Report lundin gold inc_2021_report.pdf
# Scope 2lb: 
# 2021: 24170 tCO2e
# Scope 2mb:
# 2021: NA

lundin_new <- df |> filter(grepl("lundin", report_name_old) & report_year==2021 & year==2021 & (scope=="2lb" | scope=="2mb")) |> 
  mutate(value = case_when(
    scope=="2lb" ~ 24170,
    scope=="2mb" ~ NA_real_,
    TRUE ~ value
  ),
  unit = case_when(
    scope=="2mb" ~ NA_character_,
    TRUE ~ unit
  ),
  unit_normalized = case_when(
    scope=="2mb" ~ NA_character_,
    TRUE ~ unit_normalized
  ),
  page = case_when(
    scope=="2mb" ~ NA_character_,
    TRUE ~ page
  ),
  extracted_text_from_page = case_when(
    scope=="2mb" ~ NA_character_,
    TRUE ~ extracted_text_from_page
  ))

# Remove old rows from df
df <- df |> anti_join(lundin_new, by = c("report_name_old", "year", "scope"))

# Add new rows to df
df <- bind_rows(df, lundin_new) |> arrange(report_name_old, scope, year)

# Save
write_csv(df, "data/processed/combined_annotations/gold_standard_with_ISINs_edited_revised.csv")
