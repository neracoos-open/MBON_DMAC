
########## code for fitting GAMs to data sets from both time series stations 
########## and predicting values based on the fitted model.



# load necessary packages

library(ggplot2)
library(dplyr)
library(lubridate)
library(mgcv)
library(RColorBrewer)
library(tidyr)
library(gridExtra)
library(readxl)

rm(list = ls())


# loading data from local directory

filepath <- "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/WBTS_CI.xlsx"

# naming dataframe
data <- read_excel(filepath, sheet = "data")


data$DATE<-data$DATE...4 #rename a column

data <- data %>%
  filter(is.na(Flag) | Flag != 1) # certain data points are flagged as unusable due to low quality

data$CI<-data$`Calanus Index Sum CIII-CVI` # an easier name

# a simpler dataframe to manipulate
selected_data <- data %>%
  select(CI, Total,DATE)%>%
  filter(!is.na(CI)) 

# remove obviously erroneous data, usually due to an empty excel cell
selected_data <- selected_data %>%
  filter(CI != -Inf)
selected_data <- selected_data %>%
  filter(!is.na(CI))
selected_data <- selected_data %>%
  filter(!is.na(DATE))
# Convert Excel date to R date
selected_data$DAY <- as.Date(selected_data$DATE, origin = "1899-12-30")

# Extract day of the year and year
selected_data$day_of_year <- yday(selected_data$DAY)
selected_data$year <- year(selected_data$DAY)

# Convert year to factor
selected_data$year <- as.numeric(selected_data$year)


# Square root transform
selected_data$CI <- sqrt(selected_data$CI)

# fitting the GAM
# cc is for a cyclic spline, meaning day 1 follows day 365 etc
mod3 <- mgcv::gam(CI ~ s(day_of_year, bs = "cc") + s(year), 
                  data = selected_data,
                  correlation = corAR1(form = ~ 1 | year),  # correction for autocorrelation
                  method = "REML")



# 1. Create a grid of day_of_year and year
day_range <-1:365;
year_range <- 2005:2024;
pred_data <- expand.grid(day_of_year = day_range, year = year_range)

# 2. Predict values over grid of days and years using mod3 GAM
preds <- predict(mod3, newdata = pred_data, type = "response", se.fit = TRUE)
pred_data$prediction <- preds$fit
pred_data$standard_error <- preds$se

# Save the reshaped data to a specific directory
write.csv(pred_data, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/WBTS_CI_GAM_prediction.csv", row.names = FALSE)

# divide up dataset into seasons
selected_data <- selected_data %>%
  mutate(season = case_when(
    day_of_year >= 74 & day_of_year <= 147 ~ "spring", # march 16th - may 28th
    day_of_year >= 148 & day_of_year <= 247 ~ "summer", # may 29th - aug 31st
    day_of_year >= 248 & day_of_year <= 365 ~ "fall",  # sep 1st - Dec
    day_of_year >= 1 | day_of_year <= 75 ~ "winter",  # jan - march 16th
    TRUE ~ NA_character_  # This line handles any days that don't fit the above categories, if any
  ))

spring_data <- selected_data %>%
  filter(season == "spring") 

summer_data <- selected_data %>%
  filter(season == "summer") 

fall_data <- selected_data %>%
  filter(season == "fall") 

winter_data <- selected_data %>%
  filter(season == "winter") 

# fit season specific GAMs

spring_mod <- mgcv::gam(CI ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = spring_data,
                        method = "REML")

summer_mod <- mgcv::gam(CI ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = summer_data,
                        method = "REML")

fall_mod <- mgcv::gam(CI ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                      data = fall_data,
                      method = "REML")

winter_mod <- mgcv::gam(CI ~ s(day_of_year, bs = "cr")+ s(year, k =4), 
                        data = winter_data,
                        method = "REML")


# Generate a prediction grid for each season
year_range <- seq(from = 2005, to = 2024, by = 1)

# mid point of seasons 
spring_pred_data <- expand.grid(year = year_range, day_of_year = 110.5)  # April 19th
summer_pred_data <- expand.grid(year = year_range, day_of_year = 197.5)  # July 16th
fall_pred_data   <- expand.grid(year = year_range, day_of_year = 306.5)  # November 2nd
winter_pred_data <- expand.grid(year = year_range, day_of_year = 37.5)   # February 6th



# Generate predictions and standard error for Spring
spring_preds <- predict(spring_mod, newdata = spring_pred_data, type = "response", se.fit = TRUE)
spring_pred_data$pred <- spring_preds$fit
spring_pred_data$se <- spring_preds$se.fit


# Generate predictions and standard error for Summer
summer_preds <- predict(summer_mod, newdata = summer_pred_data, type = "response", se.fit = TRUE)
summer_pred_data$pred <- summer_preds$fit
summer_pred_data$se <- summer_preds$se.fit

# Generate predictions and standard error for fall
fall_preds <- predict(fall_mod, newdata = fall_pred_data, type = "response", se.fit = TRUE)
fall_pred_data$pred <- fall_preds$fit
fall_pred_data$se <- fall_preds$se.fit

# Generate predictions and standard error for Winter
winter_preds <- predict(winter_mod, newdata = winter_pred_data, type = "response", se.fit = TRUE)
winter_pred_data$pred <- winter_preds$fit
winter_pred_data$se <- winter_preds$se.fit

# Add a 'season' column to each data frame
spring_pred_data$season <- "Spring"
summer_pred_data$season <- "Summer"
fall_pred_data$season <- "Fall"
winter_pred_data$season <- "Winter"

# Combine the data frames into a single data frame
combined_CI_seasonal_predictions <- rbind(spring_pred_data, summer_pred_data, fall_pred_data, winter_pred_data)

# save dataframe
write.csv(combined_CI_seasonal_predictions, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/WBTS_CI_seasonal_predictions.csv", row.names = FALSE)



##################################
##########      CMTS 
#################################


rm(list = ls())


# loading data from local directory

filepath <- "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/CMTS_CI.xlsx"

# naming dataframe
data <- read_excel(filepath, sheet = "data")

data$DATE<-data$DATE...4 #rename a column

data <- data %>%
  filter(is.na(flag) | flag != 1) # certain data points are flagged as unusable due to low quality

data$CI<-data$`Calanus Index     CIII-CVI` # an easier name

# a simpler dataframe to manipulate
selected_data <- data %>%
  select(CI, Total,DATE)%>%
  filter(!is.na(CI)) 

# remove obviously erroneous data, usually due to an empty excel cell
selected_data <- selected_data %>%
  filter(CI != -Inf)
selected_data <- selected_data %>%
  filter(!is.na(CI))
selected_data <- selected_data %>%
  filter(!is.na(DATE))
# Convert Excel date to R date
selected_data$DAY <- as.Date(selected_data$DATE, origin = "1899-12-30")

# Extract day of the year and year
selected_data$day_of_year <- yday(selected_data$DAY)
selected_data$year <- year(selected_data$DAY)

# Convert year to factor
selected_data$year <- as.numeric(selected_data$year)


# Square root transform
selected_data$CI <- sqrt(selected_data$CI)

# fitting the GAM
# cc is for a cyclic spline, meaning day 1 follows day 365 etc
mod3 <- mgcv::gam(CI ~ s(day_of_year, bs = "cc") + s(year), 
                  data = selected_data,
                  correlation = corAR1(form = ~ 1 | year),  # correction for autocorrelation
                  method = "REML")

# 1. Create a grid of day_of_year and year
day_range <-1:365;
year_range <- 2008:2024;
pred_data <- expand.grid(day_of_year = day_range, year = year_range)

# 2. Predict values over grid of days and years using mod3 GAM
preds <- predict(mod3, newdata = pred_data, type = "response", se.fit = TRUE)
pred_data$prediction <- preds$fit
pred_data$standard_error <- preds$se

# Save the reshaped data to a specific directory
write.csv(pred_data, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/CMTS_CI_GAM_prediction.csv", row.names = FALSE)



#######
# Seasons


selected_data <- selected_data %>%
  mutate(season = case_when(
    day_of_year >= 74 & day_of_year <= 147 ~ "spring",
    day_of_year >= 148 & day_of_year <= 247 ~ "summer",
    day_of_year >= 248 | day_of_year <= 75 ~ "winter", #includes fall dates 
    TRUE ~ NA_character_  # This line handles any days that don't fit the above categories, if any
  ))


# Need to adjust day of year for 'winter' to fit GAMs so that day of year increases from earliest 'winter' day to latest
indices <- which(selected_data$season == "winter" & selected_data$day_of_year < 100)

# Step 2: Modify 'day_of_year' for those indices
selected_data$day_of_year[indices] <- selected_data$day_of_year[indices] + 365

spring_data <- selected_data %>%
  filter(season == "spring") 

summer_data <- selected_data %>%
  filter(season == "summer") 

winter_data <- selected_data %>%
  filter(season == "winter") 



spring_mod <- mgcv::gam(CI ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = spring_data,
                        method = "REML")

summer_mod <- mgcv::gam(CI ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = summer_data,
                        method = "REML")

winter_mod <- mgcv::gam(CI ~ s(day_of_year, bs = "cr")+ s(year, k =4), 
                        data = winter_data,
                        method = "REML")


# season predictions
# 
# Winter2 <-344
# Spring2  <-110.5
# Summer2 <- 197.5

# Generate a prediction grid for each season
year_range <- seq(from = 2008, to = 2024, by = 1)

spring_pred_data <- expand.grid(year = year_range, day_of_year = 110.5)  # April 19th
summer_pred_data <- expand.grid(year = year_range, day_of_year = 197.5)  # July 16th
winter_pred_data <- expand.grid(year = year_range, day_of_year = 344)    # December 10th


# Generate predictions and standard error for Spring
spring_preds <- predict(spring_mod, newdata = spring_pred_data, type = "response", se.fit = TRUE)
spring_pred_data$pred <- spring_preds$fit
spring_pred_data$se <- spring_preds$se.fit

# Generate predictions and standard error for Summer
summer_preds <- predict(summer_mod, newdata = summer_pred_data, type = "response", se.fit = TRUE)
summer_pred_data$pred <- summer_preds$fit
summer_pred_data$se <- summer_preds$se.fit

# Generate predictions and standard error for Winter
winter_preds <- predict(winter_mod, newdata = winter_pred_data, type = "response", se.fit = TRUE)
winter_pred_data$pred <- winter_preds$fit
winter_pred_data$se <- winter_preds$se.fit

# Add a 'season' column to each data frame
spring_pred_data$season <- "Spring"
summer_pred_data$season <- "Summer"
winter_pred_data$season <- "Winter"

# Combine the data frames into a single data frame
combined_CI_seasonal_predictions <- rbind(spring_pred_data, summer_pred_data, winter_pred_data)

# save dataframe
write.csv(combined_CI_seasonal_predictions, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/CMTS_CI_seasonal_predictions.csv", row.names = FALSE)






#######################

#######   Calanus Stage Index

###########################



rm(list = ls())


# loading data from local directory

filepath <- "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/WBTS_CI.xlsx"

# naming dataframe
data <- read_excel(filepath, sheet = "data")


data$DATE<-data$DATE...4 #rename a column

data <- data %>%
  filter(is.na(Flag) | Flag != 1) # certain data points are flagged as unusable due to low quality

# a simpler dataframe to manipulate
selected_data <- data %>%
  select(CSI, DATE)%>%
  filter(!is.na(CSI)) 

# remove obviously erroneous data, usually due to an empty excel cell
selected_data <- selected_data %>%
  filter(CSI != -Inf)
selected_data <- selected_data %>%
  filter(!is.na(CSI))
selected_data <- selected_data %>%
  filter(!is.na(DATE))
# Convert Excel date to R date
selected_data$DAY <- as.Date(selected_data$DATE, origin = "1899-12-30")

# Extract day of the year and year
selected_data$day_of_year <- yday(selected_data$DAY)
selected_data$year <- year(selected_data$DAY)

# Convert year to factor
selected_data$year <- as.numeric(selected_data$year)


# fitting the GAM
# cc is for a cyclic spline, meaning day 1 follows day 365 etc
mod3 <- mgcv::gam(CSI ~ s(day_of_year, bs = "cc") + s(year), 
                  data = selected_data,
                  correlation = corAR1(form = ~ 1 | year),  # correction for autocorrelation
                  method = "REML")



# 1. Create a grid of day_of_year and year
day_range <-1:365;
year_range <- 2005:2024;
pred_data <- expand.grid(day_of_year = day_range, year = year_range)

# 2. Predict values over grid of days and years using mod3 GAM
preds <- predict(mod3, newdata = pred_data, type = "response", se.fit = TRUE)
pred_data$prediction <- preds$fit
pred_data$standard_error <- preds$se

# Save the reshaped data to a specific directory
write.csv(pred_data, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/WBTS_CSI_GAM_prediction.csv", row.names = FALSE)

# divide up dataset into seasons
selected_data <- selected_data %>%
  mutate(season = case_when(
    day_of_year >= 74 & day_of_year <= 147 ~ "spring", # march 16th - may 28th
    day_of_year >= 148 & day_of_year <= 247 ~ "summer", # may 29th - aug 31st
    day_of_year >= 248 & day_of_year <= 365 ~ "fall",  # sep 1st - Dec
    day_of_year >= 1 | day_of_year <= 75 ~ "winter",  # jan - march 16th
    TRUE ~ NA_character_  # This line handles any days that don't fit the above categories, if any
  ))

spring_data <- selected_data %>%
  filter(season == "spring") 

summer_data <- selected_data %>%
  filter(season == "summer") 

fall_data <- selected_data %>%
  filter(season == "fall") 

winter_data <- selected_data %>%
  filter(season == "winter") 

# fit season specific GAMs

spring_mod <- mgcv::gam(CSI ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = spring_data,
                        method = "REML")

summer_mod <- mgcv::gam(CSI ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = summer_data,
                        method = "REML")

fall_mod <- mgcv::gam(CSI ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                      data = fall_data,
                      method = "REML")

winter_mod <- mgcv::gam(CSI ~ s(day_of_year, bs = "cr")+ s(year, k =4), 
                        data = winter_data,
                        method = "REML")


# Generate a prediction grid for each season
year_range <- seq(from = 2005, to = 2024, by = 1)

# mid point of seasons 
spring_pred_data <- expand.grid(year = year_range, day_of_year = 110.5)
summer_pred_data <- expand.grid(year = year_range, day_of_year = 197.5)
fall_pred_data <- expand.grid(year = year_range, day_of_year = 306.5 )
winter_pred_data <- expand.grid(year = year_range, day_of_year = 37.5)


# Generate predictions and standard error for Spring
spring_preds <- predict(spring_mod, newdata = spring_pred_data, type = "response", se.fit = TRUE)
spring_pred_data$pred <- spring_preds$fit
spring_pred_data$se <- spring_preds$se.fit


# Generate predictions and standard error for Summer
summer_preds <- predict(summer_mod, newdata = summer_pred_data, type = "response", se.fit = TRUE)
summer_pred_data$pred <- summer_preds$fit
summer_pred_data$se <- summer_preds$se.fit

# Generate predictions and standard error for fall
fall_preds <- predict(fall_mod, newdata = fall_pred_data, type = "response", se.fit = TRUE)
fall_pred_data$pred <- fall_preds$fit
fall_pred_data$se <- fall_preds$se.fit

# Generate predictions and standard error for Winter
winter_preds <- predict(winter_mod, newdata = winter_pred_data, type = "response", se.fit = TRUE)
winter_pred_data$pred <- winter_preds$fit
winter_pred_data$se <- winter_preds$se.fit

# Add a 'season' column to each data frame
spring_pred_data$season <- "Spring"
summer_pred_data$season <- "Summer"
fall_pred_data$season <- "Fall"
winter_pred_data$season <- "Winter"

# Combine the data frames into a single data frame
combined_CSI_seasonal_predictions <- rbind(spring_pred_data, summer_pred_data, fall_pred_data, winter_pred_data)

# save dataframe
write.csv(combined_CSI_seasonal_predictions, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/WBTS_CSI_seasonal_predictions.csv", row.names = FALSE)



##################################
##########      CMTS 
#################################


rm(list = ls())


# loading data from local directory

filepath <- "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/CMTS_CI.xlsx"

# naming dataframe
data <- read_excel(filepath, sheet = "data")

data$DATE<-data$DATE...4 #rename a column

data <- data %>%
  filter(is.na(flag) | flag != 1) # certain data points are flagged as unusable due to low quality

# a simpler dataframe to manipulate
selected_data <- data %>%
  select(CSI, DATE)%>%
  filter(!is.na(CSI)) 

# remove obviously erroneous data, usually due to an empty excel cell
selected_data <- selected_data %>%
  filter(CSI != -Inf)
selected_data <- selected_data %>%
  filter(!is.na(CSI))
selected_data <- selected_data %>%
  filter(!is.na(DATE))
# Convert Excel date to R date
selected_data$DAY <- as.Date(selected_data$DATE, origin = "1899-12-30")

# Extract day of the year and year
selected_data$day_of_year <- yday(selected_data$DAY)
selected_data$year <- year(selected_data$DAY)

# Convert year to factor
selected_data$year <- as.numeric(selected_data$year)


# fitting the GAM
# cc is for a cyclic spline, meaning day 1 follows day 365 etc
mod3 <- mgcv::gam(CSI ~ s(day_of_year, bs = "cc") + s(year), 
                  data = selected_data,
                  correlation = corAR1(form = ~ 1 | year),  # correction for autocorrelation
                  method = "REML")

# 1. Create a grid of day_of_year and year
day_range <-1:365;
year_range <- 2008:2024;
pred_data <- expand.grid(day_of_year = day_range, year = year_range)

# 2. Predict values over grid of days and years using mod3 GAM
preds <- predict(mod3, newdata = pred_data, type = "response", se.fit = TRUE)
pred_data$prediction <- preds$fit
pred_data$standard_error <- preds$se

# Save the reshaped data to a specific directory
write.csv(pred_data, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/CMTS_CSI_GAM_prediction.csv", row.names = FALSE)



#######
# Seasons


selected_data <- selected_data %>%
  mutate(season = case_when(
    day_of_year >= 74 & day_of_year <= 147 ~ "spring",
    day_of_year >= 148 & day_of_year <= 247 ~ "summer",
    day_of_year >= 248 | day_of_year <= 75 ~ "winter", #includes fall dates 
    TRUE ~ NA_character_  # This line handles any days that don't fit the above categories, if any
  ))


# Need to adjust day of year for 'winter' to fit GAMs so that day of year increases from earliest 'winter' day to latest
indices <- which(selected_data$season == "winter" & selected_data$day_of_year < 100)

# Step 2: Modify 'day_of_year' for those indices
selected_data$day_of_year[indices] <- selected_data$day_of_year[indices] + 365

spring_data <- selected_data %>%
  filter(season == "spring") 

summer_data <- selected_data %>%
  filter(season == "summer") 

winter_data <- selected_data %>%
  filter(season == "winter") 



spring_mod <- mgcv::gam(CSI ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = spring_data,
                        method = "REML")

summer_mod <- mgcv::gam(CSI ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = summer_data,
                        method = "REML")

winter_mod <- mgcv::gam(CSI ~ s(day_of_year, bs = "cr")+ s(year, k =4), 
                        data = winter_data,
                        method = "REML")


# Generate a prediction grid for each season
year_range <- seq(from = 2008, to = 2024, by = 1)

spring_pred_data <- expand.grid(year = year_range, day_of_year = 110.5)
summer_pred_data <- expand.grid(year = year_range, day_of_year = 197.5)
winter_pred_data <- expand.grid(year = year_range, day_of_year = 344)


# Generate predictions and standard error for Spring
spring_preds <- predict(spring_mod, newdata = spring_pred_data, type = "response", se.fit = TRUE)
spring_pred_data$pred <- spring_preds$fit
spring_pred_data$se <- spring_preds$se.fit

# Generate predictions and standard error for Summer
summer_preds <- predict(summer_mod, newdata = summer_pred_data, type = "response", se.fit = TRUE)
summer_pred_data$pred <- summer_preds$fit
summer_pred_data$se <- summer_preds$se.fit

# Generate predictions and standard error for Winter
winter_preds <- predict(winter_mod, newdata = winter_pred_data, type = "response", se.fit = TRUE)
winter_pred_data$pred <- winter_preds$fit
winter_pred_data$se <- winter_preds$se.fit

# Add a 'season' column to each data frame
spring_pred_data$season <- "Spring"
summer_pred_data$season <- "Summer"
winter_pred_data$season <- "Winter"

# Combine the data frames into a single data frame
combined_CSI_seasonal_predictions <- rbind(spring_pred_data, summer_pred_data, winter_pred_data)

# save dataframe
write.csv(combined_CSI_seasonal_predictions, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/CMTS_CSI_seasonal_predictions.csv", row.names = FALSE)






########################
######## Biomass / Dry Weight
#####################


rm(list = ls())


# loading data from local directory

filepath <- "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/WBTS_CI.xlsx"

# naming dataframe
data <- read_excel(filepath, sheet = "data")


data$DATE<-data$DATE...4 #rename a column

data <- data %>%
  filter(is.na(Flag) | Flag != 1) # certain data points are flagged as unusable due to low quality

  # an easier name
data$DW<-data$`DW          (G M-2)`
  


# a simpler dataframe to manipulate
selected_data <- data %>%
  select(DW, Total,DATE)%>%
  filter(!is.na(DW)) 

# remove obviously erroneous data, usually due to an empty excel cell
selected_data <- selected_data %>%
  filter(DW != -Inf)
selected_data <- selected_data %>%
  filter(!is.na(DW))
selected_data <- selected_data %>%
  filter(!is.na(DATE))
# Convert Excel date to R date
selected_data$DAY <- as.Date(selected_data$DATE, origin = "1899-12-30")

# Extract day of the year and year
selected_data$day_of_year <- yday(selected_data$DAY)
selected_data$year <- year(selected_data$DAY)

# Convert year to factor
selected_data$year <- as.numeric(selected_data$year)


# Square root transform
selected_data$DW <- sqrt(selected_data$DW)

# fitting the GAM
# cc is for a cyclic spline, meaning day 1 follows day 365 etc
mod3 <- mgcv::gam(DW ~ s(day_of_year, bs = "cc") + s(year), 
                  data = selected_data,
                  correlation = corAR1(form = ~ 1 | year),  # correction for autocorrelation
                  method = "REML")



# 1. Create a grid of day_of_year and year
day_range <-1:365;
year_range <- 2005:2024;
pred_data <- expand.grid(day_of_year = day_range, year = year_range)

# 2. Predict values over grid of days and years using mod3 GAM
preds <- predict(mod3, newdata = pred_data, type = "response", se.fit = TRUE)
pred_data$prediction <- preds$fit
pred_data$standard_error <- preds$se

# Save the reshaped data to a specific directory
write.csv(pred_data, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/WBTS_DW_GAM_prediction.csv", row.names = FALSE)

# divide up dataset into seasons
selected_data <- selected_data %>%
  mutate(season = case_when(
    day_of_year >= 74 & day_of_year <= 147 ~ "spring", # march 16th - may 28th
    day_of_year >= 148 & day_of_year <= 247 ~ "summer", # may 29th - aug 31st
    day_of_year >= 248 & day_of_year <= 365 ~ "fall",  # sep 1st - Dec
    day_of_year >= 1 | day_of_year <= 75 ~ "winter",  # jan - march 16th
    TRUE ~ NA_character_  # This line handles any days that don't fit the above categories, if any
  ))

spring_data <- selected_data %>%
  filter(season == "spring") 

summer_data <- selected_data %>%
  filter(season == "summer") 

fall_data <- selected_data %>%
  filter(season == "fall") 

winter_data <- selected_data %>%
  filter(season == "winter") 

# fit season specific GAMs

spring_mod <- mgcv::gam(DW ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = spring_data,
                        method = "REML")

summer_mod <- mgcv::gam(DW ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = summer_data,
                        method = "REML")

fall_mod <- mgcv::gam(DW ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                      data = fall_data,
                      method = "REML")

winter_mod <- mgcv::gam(DW ~ s(day_of_year, bs = "cr")+ s(year, k =4), 
                        data = winter_data,
                        method = "REML")


# Generate a prediction grid for each season
year_range <- seq(from = 2005, to = 2024, by = 1)

# mid point of seasons 
spring_pred_data <- expand.grid(year = year_range, day_of_year = 110.5)  # April 19th
summer_pred_data <- expand.grid(year = year_range, day_of_year = 197.5)  # July 16th
fall_pred_data   <- expand.grid(year = year_range, day_of_year = 306.5)  # November 2nd
winter_pred_data <- expand.grid(year = year_range, day_of_year = 37.5)   # February 6th



# Generate predictions and standard error for Spring
spring_preds <- predict(spring_mod, newdata = spring_pred_data, type = "response", se.fit = TRUE)
spring_pred_data$pred <- spring_preds$fit
spring_pred_data$se <- spring_preds$se.fit


# Generate predictions and standard error for Summer
summer_preds <- predict(summer_mod, newdata = summer_pred_data, type = "response", se.fit = TRUE)
summer_pred_data$pred <- summer_preds$fit
summer_pred_data$se <- summer_preds$se.fit

# Generate predictions and standard error for fall
fall_preds <- predict(fall_mod, newdata = fall_pred_data, type = "response", se.fit = TRUE)
fall_pred_data$pred <- fall_preds$fit
fall_pred_data$se <- fall_preds$se.fit

# Generate predictions and standard error for Winter
winter_preds <- predict(winter_mod, newdata = winter_pred_data, type = "response", se.fit = TRUE)
winter_pred_data$pred <- winter_preds$fit
winter_pred_data$se <- winter_preds$se.fit

# Add a 'season' column to each data frame
spring_pred_data$season <- "Spring"
summer_pred_data$season <- "Summer"
fall_pred_data$season <- "Fall"
winter_pred_data$season <- "Winter"

# Combine the data frames into a single data frame
combined_DW_seasonal_predictions <- rbind(spring_pred_data, summer_pred_data, fall_pred_data, winter_pred_data)

# save dataframe
write.csv(combined_DW_seasonal_predictions, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/WBTS_DW_seasonal_predictions.csv", row.names = FALSE)





##################################
##########      CMTS 
#################################


rm(list = ls())


# loading data from local directory

filepath <- "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/CMTS_CI.xlsx"

# naming dataframe
data <- read_excel(filepath, sheet = "data")

data$DATE<-data$DATE...4 #rename a column

data <- data %>%
  filter(is.na(flag) | flag != 1) # certain data points are flagged as unusable due to low quality

data$DW<-data$`DW          (G M-2)`

# a simpler dataframe to manipulate
selected_data <- data %>%
  select(DW, DATE)%>%
  filter(!is.na(DW)) 

# remove obviously erroneous data, usually due to an empty excel cell
selected_data <- selected_data %>%
  filter(DW != -Inf)
selected_data <- selected_data %>%
  filter(!is.na(DW))
selected_data <- selected_data %>%
  filter(!is.na(DATE))
# Convert Excel date to R date
selected_data$DAY <- as.Date(selected_data$DATE, origin = "1899-12-30")

# Extract day of the year and year
selected_data$day_of_year <- yday(selected_data$DAY)
selected_data$year <- year(selected_data$DAY)

# Convert year to factor
selected_data$year <- as.numeric(selected_data$year)

# ### replace values below 0
selected_data$DW <- ifelse(selected_data$DW <= 0, 0.1, selected_data$DW)

# Square root transform
selected_data$DW <- sqrt(selected_data$DW)

# fitting the GAM
# cc is for a cyclic spline, meaning day 1 follows day 365 etc
mod3 <- mgcv::gam(DW ~ s(day_of_year, bs = "cc") + s(year), 
                  data = selected_data,
                  correlation = corAR1(form = ~ 1 | year),  # correction for autocorrelation
                  method = "REML")

# 1. Create a grid of day_of_year and year
day_range <-1:365;
year_range <- 2008:2024;
pred_data <- expand.grid(day_of_year = day_range, year = year_range)

# 2. Predict values over grid of days and years using mod3 GAM
preds <- predict(mod3, newdata = pred_data, type = "response", se.fit = TRUE)
pred_data$prediction <- preds$fit
pred_data$standard_error <- preds$se

# Save the reshaped data to a specific directory
write.csv(pred_data, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/CMTS_DW_GAM_prediction.csv", row.names = FALSE)



#######
# Seasons


selected_data <- selected_data %>%
  mutate(season = case_when(
    day_of_year >= 74 & day_of_year <= 147 ~ "spring",
    day_of_year >= 148 & day_of_year <= 247 ~ "summer",
    day_of_year >= 248 | day_of_year <= 75 ~ "winter", #includes fall dates 
    TRUE ~ NA_character_  # This line handles any days that don't fit the above categories, if any
  ))


# Need to adjust day of year for 'winter' to fit GAMs so that day of year increases from earliest 'winter' day to latest
indices <- which(selected_data$season == "winter" & selected_data$day_of_year < 100)

# Step 2: Modify 'day_of_year' for those indices
selected_data$day_of_year[indices] <- selected_data$day_of_year[indices] + 365

spring_data <- selected_data %>%
  filter(season == "spring") 

summer_data <- selected_data %>%
  filter(season == "summer") 

winter_data <- selected_data %>%
  filter(season == "winter") 



spring_mod <- mgcv::gam(DW ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = spring_data,
                        method = "REML")

summer_mod <- mgcv::gam(DW ~ s(day_of_year, bs = "cr") + s(year, k =4), 
                        data = summer_data,
                        method = "REML")

winter_mod <- mgcv::gam(DW ~ s(day_of_year, bs = "cr")+ s(year, k =4), 
                        data = winter_data,
                        method = "REML")


# season predictions
# 
# Winter2 <-344
# Spring2  <-110.5
# Summer2 <- 197.5

# Generate a prediction grid for each season
year_range <- seq(from = 2008, to = 2024, by = 1)

spring_pred_data <- expand.grid(year = year_range, day_of_year = 110.5)  # April 19th
summer_pred_data <- expand.grid(year = year_range, day_of_year = 197.5)  # July 16th
winter_pred_data <- expand.grid(year = year_range, day_of_year = 344)    # December 10th


# Generate predictions and standard error for Spring
spring_preds <- predict(spring_mod, newdata = spring_pred_data, type = "response", se.fit = TRUE)
spring_pred_data$pred <- spring_preds$fit
spring_pred_data$se <- spring_preds$se.fit

# Generate predictions and standard error for Summer
summer_preds <- predict(summer_mod, newdata = summer_pred_data, type = "response", se.fit = TRUE)
summer_pred_data$pred <- summer_preds$fit
summer_pred_data$se <- summer_preds$se.fit

# Generate predictions and standard error for Winter
winter_preds <- predict(winter_mod, newdata = winter_pred_data, type = "response", se.fit = TRUE)
winter_pred_data$pred <- winter_preds$fit
winter_pred_data$se <- winter_preds$se.fit

# Add a 'season' column to each data frame
spring_pred_data$season <- "Spring"
summer_pred_data$season <- "Summer"
winter_pred_data$season <- "Winter"

# Combine the data frames into a single data frame
combined_DW_seasonal_predictions <- rbind(spring_pred_data, summer_pred_data, winter_pred_data)

# save dataframe
write.csv(combined_DW_seasonal_predictions, "C:/Users/camer/NERACOOS Dropbox/Cameron Thompson/MBON/GAM_Results/Calanus index results/CMTS_DW_seasonal_predictions.csv", row.names = FALSE)














