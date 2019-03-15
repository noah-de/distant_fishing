#########################################
#   download_monthly_foreign_fishing    #
#########################################


#########################################
# This script collects the data from GBQ.
#########################################

# Load packages
library(startR)
library(lubridate)
library(here)
library(tidyverse)

# Get the table
monthly_foreign_fishing <- get_table(project = "ucsb-gfw",
                                     dataset = "foreign_fishing_ren",
                                     table = "monthly_foreign_fishing") %>% 
  mutate(date = date(paste(year, month, 1, sep = "-"))) %>% # Create a column with date
  drop_na(eez_iso3) %>% 
  select(year,
         month,
         date,
         eez_iso3,
         country,
         hours_by_self,
         hours_by_foreign,
         total_hours)

# Export the data
write.csv(x = monthly_foreign_fishing,
          file = here("raw_data", "monthly_foreign_fishing.csv"),
          row.names = F) 


# END OF SCRIPT