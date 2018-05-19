library(dplyr)
library(foreign)
library(ggplot2)
setwd("C:/Users/David/Google Drive/Senior Spring/SOC/firearms-replication")

trends <- read.csv("data/analytic/google_trends_gun_control.csv") 
trends$year <- as.numeric(sapply(trends$date, substr, start = 1, stop = 4))
trends$month <- as.numeric(sapply(trends$date, substr, start = 6, stop = 7))
trends <- trends %>%
  select(-date) %>%
  mutate(year_month = year + ((month - 1) / 12))

ggplot(trends) +
  geom_line(aes(x = year_month, y = searches), size = 1.5) + 
  xlab("Date") +
  ylab("Number of Searches (Relative to Maximum)") +
  ggtitle("Google Search Quantity for \"Gun Control Bill\"")
