// -----------------------------	
// Time Series - High-Frequency Data
// Topic: Construct Daily CPI and Real Commodity Prices
// -----------------------------	
// Author: Stephen Snudden, PhD
// Website: https://stephensnudden.com/
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics
// -----------------------------

// Benmoussa, et al. 2026. Carpe Diem: Can daily oil prices improve model-based forecasts of the real price of crude oil? International Journal of Forecasting, 42(1), 281–295.

//*********
//Intro formalities

clear all
capture drop _all
// Turn off pausing during output
set more off

// ***************************
// Load Monthly CPI Data
// ***************************

insheet using "MasterFile_CDataM.csv", clear // From https://github.com/SSEconomics/backcasted-crude-oil-prices
drop date
gen time=tm(1973m1)+ _n-1
format time %tm
gen chk=_n
tsset time
save "Mdata.dta", replace

// ***************************
// Upload and Combine Daily Data
// ***************************

// Load daily data
do "Startagaind.do" cad 	// Note: added to get the data to start in 1973
do "Startagaind.do" wti
do "Startagaind.do" brent

// Set unique dates to allow for missing days
bcal create eia, from(time) replace
gen mydate = bofd("eia", time)      
format mydate %tbeia
assert mydate!=. if time!=.
cap drop t
sort mydate
tsset mydate

// Create End-of-Month Indicator
gen dm=f.month-month
replace dm=1 if dm==-11
gen chk=1
replace chk=L.chk+L.dm if _n>1
replace chk =. if dm!=1

// Merge and set CPI value to last day of month
merge m:1 chk using "Mdata.dta", nogenerate
sort mydate
tsset mydate

//*********
// Load Data
//*********
gen t=_n

// Interpolate CPI to daily
*qui csipolate cpi_us t, generate(icpi_us)  // Cubic
qui ipolate cpi_us t, generate(icpi_us) 	// Linear
qui gen rpbrent= brent/icpi_us*100 
qui gen rpwti= wti/icpi_us*100 

keep mydate rpbrent rpwti cpi_us icpi_us brent_lastday wti_lastday brent wti
export excel using "Daily CPI and Real Prices.xlsx", sheet("daily") firstrow(variables) replace
