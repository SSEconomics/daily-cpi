// -----------------------------	
// Time Series - High-Frequency Data
// Topic: Upload daily data from CSV and merge (allows for different dates)
// -----------------------------	
// Author: Stephen Snudden, PhD
// Website: https://stephensnudden.com/
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics
// -----------------------------

args var 
local var = "`var'"

clear all

//*********
// Load Daily Data
//*********

//Load  data
clear all
import excel using "CDataD", sheet("`var'") firstrow
tostring date, gen(data)
gen month = substr(data,5,2)
gen day = substr(data,7,2)
gen year = substr(data,1,4)
destring month day year, replace
gen time= date(data, "YMD")
format time %td 
sort time
drop data
// Combine if exists
capture {
	merge 1:1 time using "DataD.dta", nogenerate
}
//End-of-Monthly
save "DataD.dta", replace 


