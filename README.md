# Daily CPI Interpolation

This repository provides Stata and R tools to interpolate monthly average Consumer Price Index (CPI) to the daily frequency. This allows for the construction of daily real series—such as real commodity prices.

## ⚠️ The Problem with Standard Monthly CPI
Consumer Price Index (CPI) measures are universally published as monthly observations. We do not want to simply deflate daily nominal prices directly by a monthly average CPI, as this would create artificial step-functions at the start of every month. To use real daily data, we need a measure of daily CPI.

## 📊 Dataset (Daily CPI and Real Prices.xlsx)

`Daily CPI and Real Prices.xlsx` provides the interpolated daily US CPI alongside deflated real daily crude oil prices (1973–Present). 

**Dataset Variables:**
* `mydate`: The daily date (aligned to business trading days).
* `icpi_us`: The daily interpolated US Consumer Price Index.
* `cpi_us`: The standard monthly average US CPI.
* `rpwti` & `rpbrent`: Real daily spot prices for WTI and Brent crude oil (deflated using the daily CPI).
* `wti` & `brent`: Nominal daily spot prices for WTI and Brent from EIA.
* `wti_lastday` & `brent_lastday`: The nominal price recorded on the last day of the respective month.

---

## 🧠 Core Methodology & Assumptions

The provided code generates a daily CPI series based on the following steps and assumptions:

1. **Upload & Format Daily Data:** Import daily nominal prices to establish a common daily dataset (accounting for missing days and observations).
2. **Merge & Assign CPI to the End-of-Month (EOM):** The monthly average CPI is merged with the daily dataset, and the monthly CPI value is assigned to the last day of each month.
    * **Why this makes sense:** Assigning the monthly average to the end of the month is consistent with the standard practice of deflating end-of-month real prices by that month's CPI. 
    * **End-of-Month vs. Mid-Month:** One could assign the monthly average to the middle of the month. However, CPI is drastically less volatile than daily asset or commodity prices, and doing so makes virtually no difference. As demonstrated in the appendix of the paper, assigning CPI to the EOM versus the middle of the month yields practically identical real price forecasts, making EOM the cleaner standard.
3. **Daily Interpolation:** The missing daily CPI values between the end-of-month anchor points are filled using interpolation (e.g., linear or cubic splines). This creates a smooth daily deflator that prevents artificial jumps at the start of each month.

---

## 📂 Files & Step-by-Step 

### Stata Implementation
The Stata code utilizes business calendars to handle missing trading days before merging and interpolating.

* **Run: `DailyCPI.do` (CPI Merge & Interpolation)**
  The primary execution script. This file executes the core methodology:
  1. Loads the monthly CPI dataset.
  2. Calls `Startagaind.do` to load the daily nominal prices.
  3. Creates a custom business calendar (`bcal`) to correctly sequence the trading days and allow for missing weekend/holiday dates.
  4. Identifies the exact end of each month and merges the monthly CPI data onto those specific days.
  5. Runs the daily interpolation (`ipolate` for linear by default, `csipolate` for cubic splines as an option).
  6. Calculates the daily real prices and exports the final dataset to an Excel sheet named `"Daily CPI and Real Prices"`.

* **`Startagaind.do` (Daily Data Import)** A subscript called by the main file. It imports tabs of daily nominal data from an Excel workbook containing daily WTI, Brent, and CAD. *(Note: The sheet tabs and variable names need to match exactly).* It formats the date strings into Stata time variables and merges them into a unified daily dataset.

### R Implementation
*(Include descriptions for your R scripts here if applicable, e.g., `interpolate_cpi.R` and `example_real_prices.R`, following the same logical steps of data prep, EOM assignment, interpolation, and real price calculation.)*

---

**📥 Required Monthly Data (`MasterFile_CDataM.csv`)** Before running the scripts, you must download the underlying monthly CPI dataset. Because this file is updated and maintained as part of a broader historical dataset, it is hosted in a separate repository.  
👉 **[Download it from the Backcasted Crude Oil Prices repo](https://github.com/SSEconomics/backcasted-crude-oil-prices)** and place it in your `stata/` folder.

---

## 📄 Reference
The code provided here replicates the data construction methodology utilized in:

> **Carpe Diem: Can daily oil prices improve model-based forecasts of the real price of crude oil?** > Amor Aniss Benmoussa, Reinhard Ellwanger, and Stephen Snudden.  
> *International Journal of Forecasting*, Volume 42, Issue 1, 2026.  
> DOI: [10.1016/j.ijforecast.2025.02.009](https://doi.org/10.1016/j.ijforecast.2025.02.009)
