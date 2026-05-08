# ============================================================
# Time Series - High-Frequency Data
# Topic: Construct Daily CPI and Real Commodity Prices
# -----------------------------	
# Author: Stephen Snudden, PhD
# Website: https://stephensnudden.com/
# YouTube: https://youtube.com/@ssnudden
# GitHub:  https://github.com/SSEconomics
# -----------------------------

# Benmoussa, et al. 2026. Carpe Diem: Can daily oil prices improve model-based forecasts of the real price of crude oil? International Journal of Forecasting, 42(1), 281–295.


# Clear data
rm(list = ls())

# Install required packages if you don't have them:
# install.packages(c("tidyverse", "readxl", "zoo", "writexl"))

library(tidyverse)
library(readxl)
library(zoo)
library(writexl)

# ==========================================
# 1. Load and Format Daily Nominal Data
# ==========================================
# The daily dates are formatted as YYYYMMDD (e.g., 19860102)
# We use lubridate::ymd() to safely convert these to Date objects.

# We start with CAD to ensure the daily timeline begins in 1973.
cad_raw <- read_excel("CDataD.xlsx", sheet = "cad") %>%
  mutate(date = ymd(as.character(date)))

wti_raw <- read_excel("CDataD.xlsx", sheet = "wti") %>%
  mutate(date = ymd(as.character(date)))

brent_raw <- read_excel("CDataD.xlsx", sheet = "brent") %>%
  mutate(date = ymd(as.character(date)))

# Combine into a single daily dataset and create the merging key
daily_data <- cad_raw %>%
  full_join(wti_raw, by = "date") %>%
  full_join(brent_raw, by = "date") %>%
  drop_na(date) %>% 
  mutate(year_month = format(date, "%Y-%m")) %>%
  arrange(date)


# ==========================================
# 2. Load and Format Monthly CPI Data
# ==========================================
# The monthly dates are formatted as "1973M1". 
# We replace "M" with "-", add "-01" for the day, and convert to a Date object 
# so we can easily extract a matching "YYYY-MM" key.

monthly_cpi <- read_csv("MasterFile_CDataM.csv") %>%
  mutate(
    # Convert "1973M1" -> "1973-1-01" -> Date Object -> "1973-01"
    clean_date = ymd(paste0(gsub("M", "-", Date), "-01")),
    year_month = format(clean_date, "%Y-%m"),
    cpi_us = as.numeric(cpi_us)
  ) %>%
  # We also grab the lastday variables since they are conveniently already here
  select(year_month, cpi_us, wti_lastday, brent_lastday)

# ==========================================
# 3. Merge, Assign to EOM, and Interpolate
# ==========================================
final_data <- daily_data %>%
  # Identify the last available trading day for each specific month in the data
  group_by(year_month) %>%
  mutate(is_eom = (date == max(date, na.rm = TRUE))) %>%
  ungroup() %>%
  
  # Merge the monthly CPI and lastday data
  left_join(monthly_cpi, by = "year_month") %>%
  
  # Assign CPI strictly to the end of the month; leave all other days as NA
  mutate(cpi_anchor = if_else(is_eom, cpi_us, NA_real_)) %>%
  
  # Interpolate the missing daily values between the EOM anchors
  mutate(
    # na.approx executes standard linear interpolation (equivalent to Stata 'ipolate')
    # na.rm = FALSE ensures we don't drop leading/trailing NAs outside our anchor range
    icpi_us = na.approx(cpi_anchor, na.rm = FALSE) 
  ) %>%
  
  # Calculate real prices
  mutate(
    rpwti = (wti / icpi_us) * 100,
    rpbrent = (brent / icpi_us) * 100
  ) %>%
  
  # Final clean up for export (matching the requested README structure)
  select(date, rpwti, rpbrent, cpi_us, icpi_us, wti, brent, wti_lastday, brent_lastday)

# ==========================================
# 4. Export to Excel
# ==========================================
write_xlsx(
  list("Daily CPI and Real Prices" = final_data), 
  path = "Daily CPI and Real Prices.xlsx"
)