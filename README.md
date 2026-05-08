# Daily CPI Interpolation

This repository provides R and Stata code to accurately interpolate monthly average CPI to the daily frequency. It allows researchers to construct daily real series—such as real commodity prices—without introducing the severe methodological issues caused by standard deflation practices.

## ⚠️ The Problem with Standard Deflation
Consumer Price Index (CPI) measures are universally published as monthly averages. A common, yet flawed, practice in empirical macroeconomics is to deflate daily nominal prices directly by a static monthly average CPI. 

This approach introduces three critical errors:
1. **Temporal Aggregation Bias:** It creates artificial step-functions at the start of every month.
2. **Shock Mistiming:** It shifts the timing of economic innovations, violating the true underlying data generation process.
3. **Spurious Predictability:** It distorts the time-series properties of the data, frequently resulting in a failure to accurately test against the random walk null hypothesis.

## 💡 The Solution
This code implements a rigorous smoothing routine to distribute the monthly CPI average across the daily frequency. By applying this daily CPI measure to daily nominal series, researchers can extract true daily real prices that maintain the correct timing of shocks, ensuring structural models and forecasting evaluations remain robust.

## 📄 Reference & Application
The code provided here replicates the data construction methodology utilized in our recent paper, which demonstrates this approach using daily real crude oil prices:

> **Carpe Diem: Can daily oil prices improve model-based forecasts of the real price of crude oil?**  
> Amor Aniss Benmoussa, Reinhard Ellwanger, and Stephen Snudden.  
> *International Journal of Forecasting*, Volume 42, Issue 1, 2026.  
> DOI: [10.1016/j.ijforecast.2025.02.009](https://doi.org/10.1016/j.ijforecast.2025.02.009)

## 💻 Code Resources

The repository includes standalone scripts for both R and Stata users. Each contains the core interpolation function and a practical example of merging the resulting daily CPI with a nominal daily dataset.

### R Implementation
* `interpolate_cpi.R`: Core function to convert monthly average CPI to the daily frequency.
* `example_real_prices.R`: Script demonstrating how to merge the daily CPI output with a nominal daily commodity price series to generate real daily prices.

### Stata Implementation
* `interpolate_cpi.do`: Core Stata routine for daily CPI interpolation.
* `example_real_prices.do`: Implementation of the interpolation routine applied to a nominal daily dataset.

## ⚙️ Usage Notes
* **Calendar Days vs. Trading Days:** The interpolation routines distribute the monthly average across standard calendar days. When applying the resulting daily CPI to financial or commodity data, ensure your nominal series properly handles non-trading days (e.g., weekends and holidays) before executing the final merge.
