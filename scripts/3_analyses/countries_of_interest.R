#############################
#   countries_of_interest   #
#############################

##########################################################
# This script generates graphic with a subset for countries
# of interest. The countries were identified visually
# using the other script (identify_patterns.R).
##########################################################

# Load libraries
library(startR)
library(lubridate)
library(here)
library(trelliscopejs)
library(tidyverse)

# List of countries identified after running identify_patterns.R
countries <- c("BEN", "BRA", "CMR", "CIV", "COG", "FJI", "GMB", "GNB", "IDN", "KAZ", "KIR", "KWT", "LBR", "MHL", "NGA", "NZL", "PLW", "PNG", "ROU", "SEN", "SGP", "SLE", "SUR", "SOM", "SYC", "THA", "TON", "UKR", "VCT", "VNM", "VUT", "WSM")

# Read data
monthly_foreign_fishing <- read.csv(here("raw_data", "monthly_foreign_fishing.csv"),
                                    stringsAsFactors = F) %>%
  mutate(date = date(date)) %>% 
  filter(eez_iso3 %in% countries)

# Generate facet_trelliscope plot
ggplot(data = monthly_foreign_fishing,
       mapping = aes(x = date, y = hours_by_foreign)) +
  geom_smooth(method = "lm", formula = y ~ x + I(x^2) + I(x^3)) +
  geom_smooth(method = "loess", color = "red") +
  geom_line() +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  ggtheme_plot() +
  facet_wrap(~country,
             scales = "free_y",
             ncol = 5)

my_fxn <- function(x){
  x$date_seq <- as.numeric(rownames(x))
  
  lm(hours_by_foreign ~ date_seq + I(date_seq ^ 2) + I(date_seq ^ 3), data = x)
}

monthly_foreign_fishing %>% 
  group_by(country) %>% 
  group_split() %>% 
  map(my_fxn) %>% 
  map_df(broom::tidy, .id = "model")

# END OF SCRIPT