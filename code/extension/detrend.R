library(dplyr)
library(foreign)
library(ggplot2)
setwd("C:/Users/David/Google Drive/Senior Spring/SOC/firearms-replication")

load("data/analytic/noramlized-background.RData")

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
  mutate(i.2016 = (year == 2016))

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
                              i.2013 + i.2014 + i.2015 + i.2016, 
                            data = subset)
  normalized_background[normalized_background$state == state_name, "demeaned_totalpc"] <-
    fixed_effects_model$residuals
}

save(normalized_background, file = "data/analytic/demeaned-background.RData")

national_fixed_effects_model <- lm(totalpc ~ 
                                     i.feb + i.mar + i.apr + i.may + i.jun + i.jul +
                                     i.aug + i.sep + i.oct + i.nov + i.dec + 
                                     i.2008 + i.2009 + i.2010 + i.2011 + i.2012 +
                                     i.2013 + i.2014 + i.2015, 
                                   data = normalized_background)
fixed_coefficients <- coef(national_fixed_effects_model)
monthly_coefficients_df <- data.frame(Month = c(2, 3, 4, 5, 
                                             6, 7, 8, 9,
                                             10, 11, 12), 
                                   Coefficients = fixed_coefficients[2:12])
yearly_coefficients_df <- data.frame(Year = c(2008, 2009, 2010, 2011, 
                                                2012, 2013, 2014, 2015), 
                                      Coefficients = fixed_coefficients[13:20])
ggplot(monthly_coefficients_df) +
  geom_bar(aes(x = Month, y = Coefficients),
           stat = "identity") + 
  xlim("", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", 
                              "Sep", "Oct", "Nov", "Dec") +
  ggtitle("Monthly Trends in U.S. Background Checks") + 
  ylab("Coefficients (Checks per 100,000)") 

ggplot(yearly_coefficients_df) +
  geom_bar(aes(x = Year, y = Coefficients),
           stat = "identity") + 
  ggtitle("Yearly Trends in U.S. Background Checks") + 
  ylab("Coefficients (Checks per 100,000)") 
