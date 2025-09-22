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