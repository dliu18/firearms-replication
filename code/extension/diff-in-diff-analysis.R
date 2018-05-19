library(dplyr)
library(foreign)
library(ggplot2)
setwd("C:/Users/David/Google Drive/Senior Spring/SOC/firearms-replication")

load("data/analytic/demeaned-background.RData")

normalized_background %>%
  filter(state == "New Hampshire" | state == "California") %>%
  ggplot() +
  geom_line(aes(x = year_month, y = demeaned_totalpc, color = state), size = 1) +
  geom_vline(xintercept = 2012.917, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2015.917, linetype = "longdash", size = .5) +
  annotate("text", x = 2012.5, y = 300, label = "Sandy Hook", angle = 90) +
  annotate("text", x = 2015.5, y = 300, label = "San Bernardino", angle = 90) +
  xlab("Date") + 
  ylab("Detrended Background Check Counts") + 
  ggtitle("Sandy Hook and San Bernardino")

normalized_background %>%
  filter(state == "Colorado" | state == "Kansas" | state == "Nebraska" | state == "Wyoming") %>%
  ggplot() +
  geom_line(aes(x = year_month, y = demeaned_totalpc, color = state), size = 1) +
  geom_vline(xintercept = 2012.917, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2015.917, linetype = "longdash", size = .5) +
  xlab("Date") + 
  ylab("Detrended Background Check Counts") + 
  ggtitle("Aurora, Colorado")

normalized_background %>%
  filter(state== "Alabama" | state == "Georgia" | state == "Mississippi") %>%
  ggplot() +
  geom_line(aes(x = year_month, y = demeaned_totalpc, color = state), size = 1) +
  geom_vline(xintercept = 2009.1667, linetype = "longdash", size = .5) +
  annotate("text", x = 2009, y = 500, label = "Geneva County", angle = 90) + 
  geom_vline(xintercept = 2012.917, linetype = "longdash", size = .5) +
  annotate("text", x = 2012.5, y = 500, label = "Sandy Hook", angle = 90) +
  geom_vline(xintercept = 2015.917, linetype = "longdash", size = .5) +
  annotate("text", x = 2015.5, y = 500, label = "San Bernardino", angle = 90) +
  xlab("Date") + 
  ylab("Detrended Background Check Counts") + 
  ggtitle("Geneva County Massacre (March 10, 2009)")

normalized_background %>%
  filter(state == "Texas" | state == "Oklahoma") %>%
  ggplot() +
  geom_line(aes(x = year_month, y = demeaned_totalpc, color = state), size = 1) +
  geom_vline(xintercept = 2009.8333, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2012.917, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2015.917, linetype = "longdash", size = .5) +
  annotate("text", x = 2009.4, y = 300, label = "Fort Hood", angle = 90) + 
  annotate("text", x = 2012.5, y = 300, label = "Sandy Hook", angle = 90) +
  annotate("text", x = 2015.5, y = 300, label = "San Bernardino", angle = 90) +
  xlab("Date") + 
  ylab("Detrended Background Check Counts") + 
  ggtitle("Fort Hood Shooting (November 5, 2009)")

normalized_background %>%
  filter(state == "New York" | state == "New Jersey") %>%
  ggplot() +
  geom_line(aes(x = year_month, y = demeaned_totalpc, color = state), size = 1) +
  geom_vline(xintercept = 2009.25, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2012.917, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2015.917, linetype = "longdash", size = .5) +
  annotate("text", x = 2009, y = 50, label = "Binghamton", angle = 90) + 
  annotate("text", x = 2012.5, y = 50, label = "Sandy Hook", angle = 90) +
  annotate("text", x = 2015.5, y = 50, label = "San Bernardino", angle = 90) +
  xlab("Date") + 
  ylab("Detrended Background Check Counts") + 
  ggtitle("Binghamton Shootings (April 3, 2009)")

normalized_background %>%
  filter(state == "Virginia") %>%
  ggplot() +
  geom_line(aes(x = year_month, y = demeaned_totalpc, color = state), size = 1) +
  geom_vline(xintercept = 2007.25, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2012.917, linetype = "longdash", size = .5) +
  geom_vline(xintercept = 2015.917, linetype = "longdash", size = .5) +
  annotate("text", x = 2007, y = 100, label = "Virginia Tech", angle = 90) + 
  annotate("text", x = 2012.5, y = 100, label = "Sandy Hook", angle = 90) +
  annotate("text", x = 2015.5, y = 100, label = "San Bernardino", angle = 90) +
  xlab("Date") + 
  ylab("Detrended Background Check Counts") + 
  ggtitle("Virginia Tech Shooting (April 16, 2007)")
