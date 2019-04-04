##############
# GMB_tracks #
##############

# Packages
library(here)

# Load the data

GMB_tracks <- readRDS(file = here("raw_data",
                                  "download_fishing_events_vessels_ever_fished_GMB.rds"))

# Analysis here