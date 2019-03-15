########################
#  identify_patterns   #
########################

################################################################
# This script loads the monthly fishing data and creates
# a series of plots (one for each country) of foreign fishing
# through time. It also fits a third degree polynomial
# to each timeseries to try and find a pattern
################################################################

# Load libraries
library(startR)
library(lubridate)
library(here)
library(trelliscopejs)
library(tidyverse)

# Read data
monthly_foreign_fishing <- read.csv(here("raw_data", "monthly_foreign_fishing.csv"),
                                    stringsAsFactors = F) %>%
  mutate(date = date(date)) %>% 
  drop_na(eez_iso3)

# Generate facet_trelliscope plot
ggplot(data = monthly_foreign_fishing,
       mapping = aes(x = date, y = hours_by_foreign)) +
  geom_smooth(method = "lm", formula = y ~ x + I(x^2) + I(x^3)) +
  geom_point() +
  ggtheme_plot() +
  facet_trelliscope(~eez_iso3,
                    scales = "free_y",
                    ncol = 4,
                    nrow = 4)

# END OF SCRIPT