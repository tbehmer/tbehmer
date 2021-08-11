clear all
set more off
cd "C:\Users\Torben\Dropbox\Torben-Nate Projects\Political Risk"

insheet using "JensenBehmer_ConjointData.csv", comma clear

replace v5 = "Duration" if v5 == "Duration (in seconds)" & _n == 1


unab vars: v*
foreach i of local vars {
	replace `i' = subinstr(`i', "-", "_", .) if _n == 1 | _n == 2

	local a = `i'[1]
	local b = `i'[2]
	rename `i' `a'
	la var `a' "`b'"
}
drop in 1/3

destring _all, replace
gen id = _n // V1 is the ID var, but it's not easily read.

keep if welcome == 1 // drops 1 respondent that refused to participate upon reading the introductory screen.

gen arm = .
	replace arm = 1 if A_cj1 != .
	replace arm = 2 if B_cj1 != .
	
forval i = 1/12 {
	gen cj`i' = .
	replace cj`i' = A_cj`i' if arm == 1
	replace cj`i' = B_cj`i' if arm == 2
}


forval i = 1/12 {
	forval j = 1/6 {
		replace F_`i'_`j' = "bits" if F_`i'_`j' == "Bilateral Investment Treaties"
		replace F_`i'_`j' = "origin" if F_`i'_`j' == "Country of origin"
		replace F_`i'_`j' = "industry" if F_`i'_`j' == "Industry of investor"
		replace F_`i'_`j' = "risk" if F_`i'_`j' == "Level of country risk"
		replace F_`i'_`j' = "aid" if F_`i'_`j' == "Major source of foreign aid"
		replace F_`i'_`j' = "size" if F_`i'_`j' == "Size of investor parent company"
	forval k = 1/2 {				
		replace F_`i'_`k'_`j' = "Treaties: none" if regexm(F_`i'_`k'_`j', "None")
		replace F_`i'_`k'_`j' = "Treaties: with" if regexm(F_`i'_`k'_`j', "Treaties with countries including")
		replace F_`i'_`k'_`j' = "Treaties: without" if regexm(F_`i'_`k'_`j', "Treaties with countries other than")
				
		replace F_`i'_`k'_`j' = "Investor: China" if regexm(F_`i'_`k'_`j', "Investor is from China")
		replace F_`i'_`k'_`j' = "Investor: Canada" if regexm(F_`i'_`k'_`j', "Investor is from Canada")
		replace F_`i'_`k'_`j' = "Investor: U.S." if regexm(F_`i'_`k'_`j', "Investor is from the U.S.")
		replace F_`i'_`k'_`j' = "Investor: U.K." if regexm(F_`i'_`k'_`j', "Investor is from the U.K.")

		replace F_`i'_`k'_`j' = "Industry: Export" if regexm(F_`i'_`k'_`j', "Manufacturing for export")
		replace F_`i'_`k'_`j' = "Industry: Domestic" if regexm(F_`i'_`k'_`j', "Manufacturing for sale to host market")
		replace F_`i'_`k'_`j' = "Industry: Oil and gas" if regexm(F_`i'_`k'_`j', "Oil and gas extraction")
		
		replace F_`i'_`k'_`j' = "Risk: Low" if regexm(F_`i'_`k'_`j', "OECD Country risk rating of 4")
		replace F_`i'_`k'_`j' = "Risk: High" if regexm(F_`i'_`k'_`j', "OECD Country risk rating of 5")
		
		replace F_`i'_`k'_`j' = "Aid: China" if F_`i'_`k'_`j' == "China"
		replace F_`i'_`k'_`j' = "Aid: Canada" if F_`i'_`k'_`j' == "Canada"
		replace F_`i'_`k'_`j' = "Aid: U.S." if F_`i'_`k'_`j' == "U.S."
		replace F_`i'_`k'_`j' = "Aid: U.K." if F_`i'_`k'_`j' == "U.K."
					
		replace F_`i'_`k'_`j' = "Size: Small" if F_`i'_`k'_`j' == "Small (Less than 100 employees)"
		replace F_`i'_`k'_`j' = "Size: Medium" if F_`i'_`k'_`j' == "Medium (Between 100-1000 employees)"
		replace F_`i'_`k'_`j' = "Size: Large" if F_`i'_`k'_`j' == "Large (Greater than 1000 employees)"
	}
	}
}
compress		



*set trace on
local attributes "Size Investor Treaties Aid Risk Industry"

forval b = 1/12 { // number of iterations
	forval c = 1/2 { // number of profiles
		forval a = 1/6 { // number of variables/attributes
			local attr: word `a' of `attributes'
				gen `attr'_`b'_`c' = ""
		}
	}
}			
foreach a of local attributes {
	forval i = 1/6 {
		forval k = 1/2 {
			forval j = 1/12 {
				replace `a'_`j'_`k' = F_`j'_`k'_`i' if regexm(F_`j'_`k'_`i', "`a'")
			}
		}
	}
}

*** Setting up flags for timer and unrelated jobs:
foreach var of varlist time_intro-time_comments {
	gen double dub_`var' = clock(`var', "hms")
	format dub_`var' %tc
}

* Fixing time for individual who continued the next day:
foreach var of varlist dub_time_cj11-dub_time_comments {
	replace `var' = `var' + 86000000 if id == 56 // 60*60*24*1000 (adding 86m milliseconds [one day], as respondent continued the next day.)
}

local times_a "intro cj1 cj2 cj3 cj4 cj5 cj6 cj7 cj8 cj9 cj10 cj11 cj12 job empl region orgs"
local times_b "cj1 cj2 cj3 cj4 cj5 cj6 cj7 cj8 cj9 cj10 cj11 cj12 job empl region orgs comments"

forval i = 1/`: word count `times_a'' {
	local a: word `i' of `times_a'
	local b: word `i' of `times_b'
	gen int_`a' = (dub_time_`b' - dub_time_`a') / 1000 // milliseconds converted to seconds.
}

gen flag_time1 = 0
	foreach var of varlist int_cj1 - int_cj12 {
		replace flag_time1 = 1 if `var' < 10
	}
egen mean_int = rowmean(int_cj1-int_cj12)
gen flag_time2 = 0
	replace flag_time2 = 1 if mean_int<10

drop time* dub*
	
	
*keep id cj1-cj12 Size* Investor* Treaties* Aid* Risk* Industry*

reshape long Size_1_@	Size_2_@	Size_3_@	Size_4_@	Size_5_@	Size_6_@	Size_7_@	Size_8_@	Size_9_@	Size_10_@	Size_11_@	Size_12_@  /*
 */  Investor_1_@	Investor_2_@	Investor_3_@	Investor_4_@	Investor_5_@	Investor_6_@	Investor_7_@	Investor_8_@	Investor_9_@	Investor_10_@	Investor_11_@	Investor_12_@ /*
 */ Industry_1_@	Industry_2_@	Industry_3_@	Industry_4_@	Industry_5_@	Industry_6_@	Industry_7_@	Industry_8_@	Industry_9_@	Industry_10_@	Industry_11_@	Industry_12_@ /*
 */ Treaties_1_@	Treaties_2_@	Treaties_3_@	Treaties_4_@	Treaties_5_@	Treaties_6_@	Treaties_7_@	Treaties_8_@	Treaties_9_@	Treaties_10_@	Treaties_11_@	Treaties_12_@ /*
 */ Aid_1_@	Aid_2_@	Aid_3_@	Aid_4_@	Aid_5_@	Aid_6_@	Aid_7_@	Aid_8_@	Aid_9_@	Aid_10_@	Aid_11_@	Aid_12_@ /*
 */ Risk_1_@	Risk_2_@	Risk_3_@	Risk_4_@	Risk_5_@	Risk_6_@	Risk_7_@	Risk_8_@	Risk_9_@	Risk_10_@	Risk_11_@	Risk_12_@ /* 
 */ , i(id) j(profile)
 
renvars Size* Investor* Treaties* Aid* Risk* Industry*, postdrop(1)
reshape long cj@ Size_@ Investor_@ Treaties_@ Aid_@ Risk_@ Industry_@ int_@, i(id profile) j(task)
renvars Size_ Investor_ Treaties_ Aid_ Risk_ Industry_, postdrop(1) 

gen choice = .
	replace choice = cj == profile
	replace choice = . if cj == 3 | cj == .

order id task profile cj choice Size Investor Treaties Aid Risk Industry jobdesc* employer* region* number_orgs comments int_*
	
sort id task profile

		replace Treaties = "None" if Treaties == "Treaties: none"
		replace Treaties = "Treaties with countries including" if Treaties == "Treaties: with"
		replace Treaties = "Treaties with countries other than" if Treaties == "Treaties: without"
				
		replace Investor = "Investor is from China" if Investor == "Investor: China"
		replace Investor = "Investor is from Canada" if Investor == "Investor: Canada"
		replace Investor = "Investor is from the U.S." if Investor == "Investor: U.S."
		replace Investor = "Investor is from the U.K." if Investor == "Investor: U.K."
		
		replace Industry = "Manufacturing for export" if Industry == "Industry: Export"
		replace Industry = "Manufacturing for sale to host market" if Industry == "Industry: Domestic"
		replace Industry = "Oil and gas extraction" if Industry == "Industry: Oil and gas"
		
		replace Risk = "OECD Country risk rating of 4" if Risk == "Risk: Low"
		replace Risk = "OECD Country risk rating of 5" if Risk == "Risk: High"
		
		replace Aid = "Aid from investor country" if (Aid == "Aid: China" & Investor == "Investor is from China") | /*
			*/	(Aid == "Aid: Canada" & Investor == "Investor is from Canada") | /*
			*/	(Aid == "Aid: U.S." & Investor == "Investor is from the U.S.") | /*
			*/	(Aid == "Aid: U.K." & Investor == "Investor is from the U.K.")
			
		replace Aid = "Aid from country other than investor country" if (Aid == "Aid: China" & Investor != "Investor is from China") | /*
			*/	(Aid == "Aid: Canada" & Investor != "Investor is from Canada") | /*
			*/	(Aid == "Aid: U.S." & Investor != "Investor is from the U.S.") | /*
			*/	(Aid == "Aid: U.K." & Investor != "Investor is from the U.K.")	
							
		replace Size = "Small (Less than 100 employees)" if Size ==  "Size: Small"
		replace Size = "Medium (Between 100-1000 employees)" if Size == "Size: Medium"
		replace Size = "Large (Greater than 1000 employees)" if Size == "Size: Large"
		
*** Setting up post-experiment subject characteristics.	
	foreach var of varlist jobdesc_5_TEXT region_7_TEXT {
		replace `var' = lower(`var')
	}

	* Job title/position
	local jobs "underwriter analyst broker manager otherjob"
	forval i = 1/`: word count `jobs'' {
		local j: word `i' of `jobs'
		gen `j' = .
			replace `j' = 1 if regexm(jobdesc, "`i'")
			replace `j' = 0 if ~regexm(jobdesc, "`i'") & ~regexm(jobdesc, "6") & jobdesc!=""
	}
	** Fixing a couple of misselected "other" entries:
		replace otherjob = 0 if otherjob == 1 & jobdesc_5_TEXT == "country risk analyst" & id == 1 // "Analyst" was already selected correctly.
		replace manager = 1 if otherjob == 1 & jobdesc_5_TEXT == "risk manager" & id == 67 // Manager was not selected.
		replace otherjob = 0 if otherjob == 1 & jobdesc_5_TEXT == "risk manager" & id == 67 // see above.

	la var underwriter "Job held in last 10 years: Underwriter"
	la var analyst "Job held in last 10 years: Analyst"
	la var broker "Job held in last 10 years: Broker"
	la var manager "Job held in last 10 years: Manager"
	la var otherjob "Job held in last 10 years: Other"	
		
	gen flag_job = 0
		replace flag_job = 1 if underwriter == 0 & analyst == 0 // these respondents are neither analysts, nor underwriters.
		replace flag_job = 1 if jobdesc == "" // these respondents didn't provide job information.
		
	* Employer	
	local empl "private natlio quasi otherempl"
	forval i = 1/`: word count `empl'' {
		local j: word `i' of `empl'
		gen `j' = .
			replace `j' = 1 if employer==`i'
			replace `j' = 0 if employer!=`i' & employer!=5 & employer!=.
	}
	la var private "Current employer: Private sector"
	la var natlio "Current employer: National government agency or multilateral"
	la var quasi "Current employer: Quasi-government agency"
	la var otherempl "Current employer: Private sector"

	* Regional focus
	local regions "africa eap eurca lacarib mena sa otherreg"
	forval i = 1/`: word count `regions'' {
		local j: word `i' of `regions'
		gen `j' = .
			replace `j' = 1 if regexm(region, "`i'")
			replace `j' = 0 if ~regexm(region, "`i'") & ~regexm(region, "8") & region!=""
	}
	** Fixing a couple of misselected "other" entries:
	foreach var of varlist africa eap eurca lacarib mena sa otherreg { // general options selected, no regional focus: assigning 1s to all categories.
		replace `var' = 1 if regexm(region_7_TEXT, "worldwide") | regexm(region_7_TEXT, "global") | regexm(region_7_TEXT, "none") | region_7_TEXT == "no specific focus" | region_7_TEXT == "no regional specialization"
	}
	replace lacarib = 1 if region_7_TEXT == "south america" & id == 77 // wrong option selected.
	replace otherreg = 0 if region_7_TEXT == "south america" & id == 77 // wrong option selected.
	
	la var africa "Regional Specialization: Africa"
	la var eap "Regional Specialization: East Asia & Pacific"
	la var eurca "Regional Specialization: Europe & Central Asia"
	la var lacarib "Regional Specialization: Latin America & Caribbean"
	la var mena "Regional Specialization: Middle East & North Africa"
	la var sa "Regional Specialization: South Asia"
	la var otherreg "Regional Specialization: Other Regions"

	* Number of past employers
	recode number_orgs (1 = 0 "None") (2 = 1 "One organization") (3=2 "Two organizations") (4=3 "Three or more organizations") (5=.), gen(employercount)
	la var employercount "Number of different political risk insurers for which respondent has worked"
	
	
	* Summary stats on post-experiment subject characteristics
	tabstat underwriter analyst broker manager otherjob private natlio quasi otherempl /*
		*/	africa eap eurca lacarib mena sa otherreg if profile == 1 & task == 1, statistics(N mean sd min max) columns(statistics) format(%9.3f)

preserve
	keep if flag_time1 == 0
	save JensenBehmer_Cj_short.dta, replace
restore
preserve
	keep if flag_job == 0
	save JensenBehmer_Cj_job.dta, replace
restore
		
		
save JensenBehmer_Conjoint.dta, replace
