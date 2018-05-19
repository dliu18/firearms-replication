library(dplyr)
library(foreign)
library(ggplot2)
setwd("C:/Users/David/Google Drive/Senior Spring/SOC/firearms-replication")

seer_raw <- read.fwf("data/raw/seer-raw.txt", width = c(4, 2, 2, 3, 2, 1, 1, 1, 2, 8),
                     col.names = c("Year", "Postal", "stfips", "county", "registry", 
                                   "race", "origin", "sex", "age", "population"),
                     buffer = 500000)
seer_aggregated <- seer_raw %>%
  filter(Year >= 2016) %>%
  group_by(Year, stfips) %>%
  summarize(total_pop = sum(population))
colnames(seer_aggregated) <- c("year", "stfips", "pop")

population_raw <- read.dta("data/raw/population-state-public.dta")

pop_07_16 <- population_raw %>%
  union(seer_aggregated)
 
pop_07_16 <- pop_07_16 %>%
  mutate(state = NA)
pop_07_16[pop_07_16$stfips == 33, "state"] <- "New Hampshire"
pop_07_16[pop_07_16$stfips == 50, "state"] <- "Vermont"
pop_07_16[pop_07_16$stfips == 20, "state"] <- "Kansas"
pop_07_16[pop_07_16$stfips == 31, "state"] <- "Nebraska"
pop_07_16[pop_07_16$stfips == 1, "state"] <- "Alabama"
pop_07_16[pop_07_16$stfips == 28, "state"] <- "Mississippi"
pop_07_16[pop_07_16$stfips == 13, "state"] <- "Georgia"
pop_07_16[pop_07_16$stfips == 48, "state"] <- "Texas"
pop_07_16[pop_07_16$stfips == 40, "state"] <- "Oklahoma"
pop_07_16[pop_07_16$stfips == 36, "state"] <- "New York"
pop_07_16[pop_07_16$stfips == 34, "state"] <- "New Jersey"
pop_07_16[pop_07_16$stfips == 6, "state"] <- "California"
pop_07_16[pop_07_16$stfips == 9, "state"] <- "Connecticut"
pop_07_16[pop_07_16$stfips == 51, "state"] <- "Virginia"

write.dta(pop_07_16, "data/analytic/pop-07-16.dta")
