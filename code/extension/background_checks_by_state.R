library(dplyr)
library(foreign)
library(ggplot2)
setwd("C:/Users/David/Google Drive/Senior Spring/SOC/firearms-replication")

background_checks_raw <- read.csv("data/raw/bckcheck-state-public-buzzfeed.csv") %>%
  select(month, state, totals)

# Clean the data by creating month and year columns
background_checks_raw$year <- as.numeric(sapply(background_checks_raw$month,
                                     substr, start = 1, stop = 4))
background_checks_raw$m <- as.numeric(sapply(background_checks_raw$month,
                                  substr, start = 6, stop = 7))
background_checks_raw <- select(background_checks_raw, -month)


pop_07_16 <- read.dta("data/analytic/pop-07-16.dta")

normalized_background <- background_checks_raw %>%
  inner_join(pop_07_16,
             by = c("year", "state")) %>%
  mutate(totalpc = 100000*(totals / pop)) %>%
  mutate(year_month = year + ((m - 1) / 12))

#remove states with missing data
normalized_background <- normalized_background %>%
  filter(state != "North Carolina") %>%
  filter(state != "Kentucky") %>%
  filter(state != "Utah")

normalized_background <- normalized_background %>%
  mutate(month = m) %>%
  select(-m)
save(normalized_background, file = "data/analytic/noramlized-background.RData")

# summary statistics 
state_averages <- normalized_background %>%
  group_by(state) %>%
  summarize(checks_per_month = mean(totalpc))

normalized_background %>%
  filter(state == "New Jersey" | state == "Alabama" | state == "Texas") %>%
  ggplot() +
    geom_boxplot(aes(x=state, y = totalpc)) +
    coord_flip() + 
    ylab("Background Checks (per 100,000)") +
    ggtitle("Range of Background Checks by State")
