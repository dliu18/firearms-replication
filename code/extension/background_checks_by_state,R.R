library(dplyr)
library(foreign)
library(ggplot2)
setwd("C:/Users/David/Google Drive/Senior Spring/SOC/firearms-replication")

background_checks_raw <- read.dta("data/raw/bckcheck-state-public.dta")
population_raw <- read.dta("data/raw/population-state-public.dta")

normalized_background <- background_checks_raw %>%
  inner_join(population_raw,
             by = c("year", "stfips")) %>%
  mutate(totalpc = 100000*(total / pop)) %>%
  mutate(year_month = year + ((month - 1) / 12))

#remove states with missing data
normalized_background <- normalized_background %>%
  filter(stname != "NC") %>%
  filter(stname != "KY") %>%
  filter(stname != "UT")

save(normalized_background, file = "data/analytic/noramlized-background.RData")

normalized_background %>%
  filter(stname == "NH" | stname == "VT") %>%
ggplot() +
  geom_line(aes(x = year_month, y = totalpc, color = stname))
