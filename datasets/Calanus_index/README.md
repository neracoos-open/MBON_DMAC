# Overview of the Data:

There should be one spreadsheet for each station and metric:

### Stations
- WBTS
- CMTS

### Metrics
- Abundance (CI)
    - C3-adult Calanus abundance (square root transformed)
- CSI
    - Calanus Stage Index (index of developmental stage, no transformation)
- Biomass
    - Dry weight of the zooplankton sample (square root transformed)

## Dataset types
- Full Dataset
    - Contains predictions and standard errors for each day of the year and year
- Seasonal Dataset
    - Split by seasons, focused on interannual changes


## Notes for Display

When displaying the GAM predictions, we should use 2012 as the default year for the "full" climatology, but allow the user to change this to any year from 2005/2008 to 2024. 

Changing the year will simply shift the prediction up or down.
Predictions are presented in their transformed state (due to the associated standard errors). To show untransformed values:
Adjust the y-axis tick labels accordingly.
If possible, display the untransformed value when hovering over a data point.

Seasonal GAMs:

Some of the seasonal GAMs are not significant and should not be displayed.

Here are the dates for the seasonal GAMs, i.e. the day of year used in the prediction. These are the midpoints of the seasons - this is somewhat different from what we did in the paper. 


### WBTS
- Spring (Day 110.5): April 19th
- Summer (Day 197.5): July 16th
- Fall (Day 306.5): November 2nd
- Winter (Day 37.5): February 6th

### CMTS
- Spring (Day 110.5): April 19th
- Summer (Day 197.5): July 16th
- Winter (Day 344): December 10th

## Next Steps

The goal is to use these spreadsheets to generate trendlines with shaded error regions/confidence intervals for the plots, and overlay the actual data points.

R code for generating these GAMs and predictions is also included for reference.