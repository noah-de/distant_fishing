#######################
# foreign_fishing_gdp #
#######################


# Load libraries
library(startR)
library(lubridate)
library(here)
library(WDI)
library(sf)
library(tidyverse)

# Get WDI data
wdi_dat <- WDI(indicator = c("NY.GDP.PCAP.KD"),
               start = 2012,
               end = 2018,
               extra = TRUE) %>% 
  select(year, eez_iso3 = iso3c, per_cap_gdp = NY.GDP.PCAP.KD, region) %>% 
  filter(!region == "Aggregates")

# Get EEZ shapefiles
eez <- read_sf(dsn = here("raw_data", "spatial", "EEZ"),
               layer = "eez_v10") %>% 
  lwgeom::st_make_valid() %>% 
  group_by(ISO_Ter3) %>%
  summarise(a = 1) %>% 
  st_simplify(dTolerance = 0.01)

# Get foreign fishing data
monthly_foreign_fishing <- read.csv(here("raw_data", "monthly_foreign_fishing.csv"),
                                    stringsAsFactors = F) %>% 
  filter(year > 2012)


# Group foreign fishing at the country-level
yearly_foreign_fishing <- monthly_foreign_fishing %>%
  group_by(year, eez_iso3, country) %>% 
  summarize(hours_by_self = sum(hours_by_self, na.rm = T),
            hours_by_foreign = sum(hours_by_foreign, na.rm = T),
            total_hours = sum(total_hours, na.rm = T)) %>% 
  ungroup()


country_cats <- read.csv(here("raw_data", "country_categorizations.csv")) %>% 
  mutate(group = ifelse(!is.na(small), "Small / Developing / Least developed", "Developed"))

# Merge all data
foreign_fishing_and_gdp <- yearly_foreign_fishing %>% 
  left_join(wdi_dat, by = c("eez_iso3", "year")) %>% 
  left_join(country_cats, by = "country") %>% 
  drop_na(group)

foreign_fishing_and_gdp %>% 
  group_by(group, eez_iso3) %>% 
  summarize(per_cap_gdp = mean(per_cap_gdp, na.rm = T)) %>% 
  ggplot(mapping = aes(x = group, y = per_cap_gdp / 1e3)) +
  geom_jitter(height = 0, size = 1) +
  geom_boxplot(fill = "transparent", size = 1) +
  scale_y_continuous(trans = "log10") +
  labs(x = "Group", y = quo(log[10]~"(Per-capita GDP (1,000 2010 USD))")) +
  ggtheme_plot()

ggplot(data = foreign_fishing_and_gdp,
       mapping = aes(x = per_cap_gdp,
                     y = hours_by_foreign)) +
  geom_point() +
  ggtheme_plot() +
  geom_smooth(method = "loess")


monthly_foreign_fishing %>% 
  group_by(eez_iso3) %>% 
  mutate(max_foreign = max(hours_by_foreign, na.rm = T)) %>% 
  ungroup() %>% 
  mutate(hours_by_foreign_norm = hours_by_foreign / max_foreign,
         date = date(date))  %>% 
  left_join(country_cats, by = "country") %>% 
  drop_na(group) %>% 
  ggplot(mapping = aes(x = date,
                       y = hours_by_foreign_norm)) +
  geom_line(aes(group = eez_iso3),
            color = "gray") +
  facet_wrap(~group, scales = "free_y", ncol = 1) +
  ggtheme_plot() +
  geom_smooth(method = "loess")


monthly_foreign_fishing %>%
  mutate(date = date(date)) %>% 
  left_join(country_cats, by = "country") %>% 
  drop_na(group) %>% 
  group_by(date, group) %>% 
  summarize(hours_by_foreign = sum(hours_by_foreign, na.rm = T)) %>% 
  ungroup() %>% 
  spread(group, hours_by_foreign) %>% 
  magrittr::set_colnames(value = c("date", "Developed", "Small")) %>% 
  mutate(ratio = Small / Developed) %>% 
  ggplot(mapping = aes(x = date,
                       y = ratio)) +
  geom_line() +
  ggtheme_plot() +
  geom_smooth(method = "loess") +
  labs(y = "Ratio (Developing / Developed)")



















