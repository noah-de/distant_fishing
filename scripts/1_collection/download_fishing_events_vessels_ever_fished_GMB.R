###################################################
# download_fishing_events_vessels_ever_fished_GMB #
###################################################


#########################################
# This script collects the data from GBQ.
#########################################

# Load packages
library(startR)
library(lubridate)
library(here)
library(tidyverse)

# Get the table
fishing_events_vessels_ever_fished_GMB <-
  get_table(project = "ucsb-gfw",
            dataset = "foreign_fishing_ren",
            table = "fishing_events_vessels_ever_fished_GMB")

# Export the data
write.csv(x = fishing_events_vessels_ever_fished_GMB,
          file = here("raw_data", "fishing_events_vessels_ever_fished_GMB.csv"),
          row.names = F) 

# END OF SCRIPT