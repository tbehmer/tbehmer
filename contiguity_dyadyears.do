clear all
set more off 
cd "C:\Users\Torben\Documents\Uni\data\"
capture mkdir contigfiles

insheet using "states2016_cow.csv" // the state membership csv file for 2016 by COW

rename ccode ccode1
*** Taking care of duplicate entries: states that entered and exited, then later re-entered the international system of states.
duplicates tag ccode, gen(tag)
tab ccode1 if tag != 0

bysort ccode1: gen dup = _n
qui sum dup
local t = r(max)

reshape wide styear endyear stday endday stmonth endmonth, i(ccode) j(dup)
***
keep ccode1 stateabb styear* endyear*
local n = _N

renvars stateabb styear* endyear*, postfix("_1")

expandcl `n', generate(newcl) cluster(ccode1)
bysort ccode1: replace newcl = _n

levelsof ccode1, local(c)
gen ccode2 = .
local k = 1
foreach i of local c {
	bysort ccode1: replace ccode2 = `i' if _n == `k'
	local k = `k'+1
}
drop if ccode1 == ccode2

local years = 2017-1816 
expandcl `years', cluster(ccode1 ccode2) generate(year)
bysort ccode1 ccode2: replace year = _n + 1815


drop newcl

preserve
insheet using "states2016_cow.csv" , clear

rename ccode ccode2
* Taking care of duplicate entries: states that entered and exited, then later re-entered the international system of states.
duplicates tag ccode2, gen(tag)
tab ccode2 if tag != 0
bysort ccode2: gen dup = _n

reshape wide styear endyear stday endday stmonth endmonth, i(ccode2) j(dup)
***
keep ccode2 stateabb styear* endyear*
local n = _N

renvars stateabb styear* endyear*, postfix("_2")

tempfile startyear

sort ccode2
save `startyear'
restore

merge m:1 ccode2 using `startyear', nogenerate	
	
preserve
use "contdird_cow.dta", clear // The V.3.2.0 Contiguity file from COW.

rename state1no ccode1
rename state2no ccode2

* The contiguity data contains ccode1/ccode2/year duplicates. Removing them by the following rule: keep the observation with minimal value on contiguity (1), dropping whichever other.
collapse (min) conttype, by(ccode1 ccode2 year)

bysort ccode2 year: gen num_contigs_ccode2 = _N
qui sum num_contigs_ccode2
local maxcontigs = r(max)

tempfile contiguity
sort ccode1 ccode2 year
save `contiguity'

restore

sort ccode1 ccode2 year
merge 1:m ccode1 ccode2 year using `contiguity'
drop _m // 1's indicate there's no contiguity between states: no COW data on those dyads in contiguity dataset.

* Removing dyads where one of the countries in the dyad "didn't exist" in that year (as according the state membership csv file for 2016 by COW).
keep if ((year >= styear1_1 & year <= endyear1_1) | (year >= styear2_1 & year <= endyear2_1)) ///
	& ((year >= styear1_2 & year <= endyear1_2) | (year >= styear2_2 & year <= endyear2_2))

* Just for making the dataset smaller... set this to whatever value you want so as to accelerate the compiling of the file. Here: 1945.
keep if year >= 1945
	
*save contiguity_dyadyears.dta, replace

***********************************
	
*use contiguity_dyadyears.dta, clear

set more off
* Filling in non-contiguous states.
qui replace conttype = 0 if conttype == .

* This is where the year-contiguity thing breaks down, bc I'm taking a list of countries in any year, not a specific year. Loop over all years to fix.
* Now building a contiguity vector for each recipient-year.
levelsof year, local(yr)
local years: word count `yr'
local year1: word 1 of `yr'
local year2: word 2 of `yr'
local yeark: word `years' of `yr'

macro dir
qui {
	foreach y of local yr {
		preserve
			keep if year == `y'
			tempfile year`y'
			sort ccode1 ccode2 year
			save `year`y''
		restore
	}
}

qui {
	levelsof ccode2, local(recipients)

	foreach y of local yr {
		use `year`y'', clear

		nois di "Now running contiguity year: `y'"
		
		foreach r of local recipients {
		preserve
			keep if ccode2 == `r' 
			keep if conttype != 0
			
			capture levelsof ccode1, local(contig_`r')
			
			tempfile c_`r'
			sort ccode2 year
			save `c_`r''
			
		restore
		}

		forval k = 1/`maxcontigs' {
			capture gen v`k' = .
			capture gen aid`k' = .
		}
		levelsof ccode2, local(recipients)
		levelsof ccode1, local(donors)
			
		foreach r of local recipients {
			local z: word count `contig_`r''
			capture {
				forval x = 1/`z' {
					local neighbor: word `x' of `contig_`r''
					
					replace v`x' = `neighbor' if ccode2 == `r'
				}
			}
		}	
		save "contigfiles\year`y'.dta", replace
	}	
}


use "contigfiles\year`year1'.dta", clear

forval i = `year2'/`yeark' {
	append using "contigfiles\year`i'.dta"
}

* Check if all years are there. Should be 1945-2016.
sum year

* Fixing some first-year-in-the-system errors in contiguity:
* Note: technically, this can create contiguities with states that didn't exist yet. This does not affect your data though, because those states that didn't exist will not have received any aid. 
* Meanwhile, it fixes the problem that states that were contiguous in year one of their independence didn't have this contiguity accounted for. This affects about 18k dyad years.
sort ccode1 ccode2 year
by ccode1 ccode2: gen probs = v1 == . & v1[_n+1] != . & (year == styear1_2 | year == styear2_2)

forval k = 1/`maxcontigs' {
	replace v`k' = v`k'[_n+1] if probs == 1 & probs[_n+1] == 0
}
drop probs

* Filling in missing counts of contiguities by recipient for non-contiguous dyads.
bysort ccode2 year: egen all_contigs_ccode2 = max(num_contigs_ccode2 // generates several missing values... all of those are checked. Those remaining did not have any independent neighbors at the time.
drop num_contigs_ccode2


* Convenience save.
save "contigfiles\contiguity_allyears.dta", replace
*
use "contigfiles\contiguity_allyears.dta", clear

*********************************
/* This is where you'll swap in your true directed dyad per year aid data! 
Make sure to name your aid variable 'aid'... or change stuff below at your own peril. */

* Simulating fake aid data: 
gen aid = abs(rnormal(1000, 500))
*********************************	

* Capturing aid given to states contiguous to recipient:
*keep if year == 1991 // uncancel this for debugging (massively speeds up compiling).
levelsof year, local(yr)
levelsof ccode2, local(recipients)
levelsof ccode1, local(donors)

local dons: word count `donors'
local don1: word 1 of `donors'
local donk: word `dons' of `donors'


foreach d of local donors {
	preserve
		keep if ccode1 == `d'
			
		foreach r of local recipients {
			qui sum all_contigs_ccode2
			if r(N) == 0 {
				local contigs = 1
			}
			else {
				local contigs = r(max)
			}
			
			foreach y of local yr {
			di "Now running: CCODE1 `d', CCODE2 `r', YEAR `y'"
				forval k = 1/`contigs' {
					qui sum v`k' if ccode2 == `r' & year == `y'
					
					if r(N) == 0 {
						continue
					}
					else {
						local n`k' = r(mean)
						qui sum aid if ccode2== `n`k'' & year == `y'
						qui replace aid`k' = r(mean) if ccode2 == `r' & year == `y'
					}
				}
			}
		}
		
		sort ccode1 ccode2 year
		save "contigfiles\matrix`d'.dta", replace
	restore
}


use "contigfiles\matrix`don1'.dta", clear


forval k = 2 / `dons' {
	local j: word `k' of `donors'
	append using "contigfiles\matrix`j'.dta"
}
set trace off
dropmiss, force

order stateabb* ccode* year conttype aid v* aid*

* Calculating global aid given
bysort ccode1 year: egen totaidperyear = sum(aid)
* Calculating global aid given to everyone but ccode2
gen otheraidperyear = totaidperyear - aid
* Calculating aid given to ccode2 and its neighbors
egen neighborhoodaidperyear = rowtotal(aid1-aid`maxcontigs')
* Calculating global aid given to everyone but ccode2 or ccode2's neighbors
gen noneighborsaidperyear = totaidperyear - neighborhoodaidperyear


save contiguity_matrix.dta, replace




