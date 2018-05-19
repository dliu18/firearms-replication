library(dplyr)
library(foreign)
library(ggplot2)
library(stargazer)
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

florida_population <- lm(pop ~ year, data = filter(pop_07_16, stfips == 12))
stargazer(florida_population)
newdata <- data.frame(year = c(2017, 2018))
newdata$pop <- predict(florida_population, newdata)
newdata$stfips <- c(12, 12)
pop_07_16 %>%
  filter(stfips == 12) %>%
  union(newdata) %>%
  ggplot(aes(x = year, y = pop)) + 
    geom_point() +
    geom_smooth(method = "lm") +
    geom_point(data = newdata, aes(x = year, y = pop), shape = 1, size = 5) +
    ylab("Population") +
    ggtitle("Linear Model of Florida's Population (2007 - 16)")

pop_07_17 <- pop_07_16 %>%
  union(data.frame(year = 2017, stfips = 12, pop = newdata$pop[1]))

pop_07_18 <- pop_07_17 %>%
  union(data.frame(year = 2018, stfips = 12, pop = newdata$pop[2]))

pop_07_18 <- pop_07_18 %>%
  mutate(state = NA)
pop_07_18[pop_07_18$stfips == 12, "state"] <- "Florida"

background_checks_raw <- read.csv("data/raw/bckcheck-state-public-buzzfeed.csv") %>%
  select(month, state, totals)

# Clean the data by creating month and year columns
background_checks_raw$year <- as.numeric(sapply(background_checks_raw$month,
                                                substr, start = 1, stop = 4))
background_checks_raw$m <- as.numeric(sapply(background_checks_raw$month,
                                             substr, start = 6, stop = 7))
background_checks_raw <- select(background_checks_raw, -month)

normalized_background <- background_checks_raw %>%
  inner_join(pop_07_18,
             by = c("year", "state")) %>%
  mutate(totalpc = 100000*(totals / pop)) %>%
  mutate(year_month = year + ((m - 1) / 12))

normalized_background <- normalized_background %>%
  mutate(month = m) %>%
  select(-m)

normalized_background <- normalized_background %>%
  mutate(i.jan = (month == 1)) %>%
  mutate(i.feb = (month == 2)) %>%
  mutate(i.mar = (month == 3)) %>%
  mutate(i.apr = (month == 4)) %>%
  mutate(i.may = (month == 5)) %>%
  mutate(i.jun = (month == 6)) %>%
  mutate(i.jul = (month == 7)) %>%
  mutate(i.aug = (month == 8)) %>%
  mutate(i.sep = (month == 9)) %>%
  mutate(i.oct = (month == 10)) %>%
  mutate(i.nov = (month == 11)) %>%
  mutate(i.dec = (month == 12)) 

normalized_background <- normalized_background %>%
  mutate(i.2008 = (year == 2008)) %>%
  mutate(i.2009 = (year == 2009)) %>%
  mutate(i.2010 = (year == 2010)) %>%
  mutate(i.2011 = (year == 2011)) %>%
  mutate(i.2012 = (year == 2012)) %>%
  mutate(i.2013 = (year == 2013)) %>%
  mutate(i.2014 = (year == 2014)) %>%
  mutate(i.2015 = (year == 2015)) %>%
  mutate(i.2016 = (year == 2016)) %>%
  mutate(i.2017 = (year == 2017)) %>%
  mutate(i.2018 = (year == 2018)) 

normalized_background <- normalized_background %>%
  mutate(demeaned_totalpc = NA)

states <- unique(normalized_background$state)
for (i in 1:length(states)) {
  state_name <- states[i]
  subset <- filter(normalized_background, state == state_name)
  fixed_effects_model <- lm(totalpc ~ 
                              i.feb + i.mar + i.apr + i.may + i.jun + i.jul +
                              i.aug + i.sep + i.oct + i.nov + i.dec + 
                              i.2008 + i.2009 + i.2010 + i.2011 + i.2012 +
                              i.2013 + i.2014 + i.2015 + i.2016 + i.2017 + i.2018, 
                            data = subset)
  normalized_background[normalized_background$state == state_name, "demeaned_totalpc"] <-
    fixed_effects_model$residuals
}

normalized_background %>%
  filter(state == "Florida") %>%
  ggplot() +
  geom_line(aes(x = year_month, y = demeaned_totalpc), color = "red", size = 1.5) +
  geom_vline(xintercept = 2018.083, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2012.917, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2015.917, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2016.417, linetype = "longdash", size = .5) +
  annotate("text", x = 2012.5, y = 150, label = "Sandy Hook", angle = 90) +
  annotate("text", x = 2015.5, y = 150, label = "San Bernardino", angle = 90) +
  annotate("text", x = 2017.85, y = 150, label = "Parkland", angle = 90) +
  annotate("text", x = 2016.6, y = 150, label = "Orlando", angle = 90) +
  xlab("Date") + 
  ylab("Detrended Background Check Counts") + 
  ggtitle("Background Checks in Florida Under Obama vs. Trump")
