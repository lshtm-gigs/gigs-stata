clear
do "_gig_nbs.ado"

capture program drop make_ig_nbs_tbl
program define make_ig_nbs_tbl
 	args _ga_days sex acronym conversion
	tempvar _sex round
	generate `_sex' = "`sex'" 
	if ("`conversion'" == "z2v") {
		foreach SD in -3 -2 -1 0 1 2 3 {
			if (`SD' == -3) { 
				local colname = "SD3neg"
			} 
			if (`SD' == -2) { 
				local colname = "SD2neg"
			} 
			if (`SD' == -1) { 
				local colname = "SD1neg"
			} 
			if (`SD' == 0) { 
				local colname = "SD0"
			} 
			if (`SD' == 1) { 
				local colname = "SD1"
			} 
			if (`SD' == 2) { 
				local colname = "SD2"
			} 
			if (`SD' == 3) { 
				local colname = "SD3"
			}
			capture tempvar _SD
			capture drop `_SD'
			qui gen `_SD' = `SD'
			egen double measure = ///
				ig_nbs(`_SD', "`acronym'", "`conversion'"), ///
				gest_days(`_ga_days') sex(`_sex') sexcode(m=male, f=female)
			if ("`acronym'" == "wfga" | "`acronym'" == "wlrfga") {
				replace measure = round(measure, 0.01)
			} 
			else {
				replace measure = round(measure, 0.1)
			}
			rename measure `colname'
		}
	}
	if ("`conversion'" == "c2v") {
		foreach cent in 0.03 0.05 0.1 0.5 0.9 0.95 0.97 {
			if (`cent' ==  0.03) { 
				local colname = "P03"
			} 
			if (`cent' == 0.05) {
				if ("`acronym'" == "fmfga" | "`acronym'" == "bfpfga" | /*
				*/ "`acronym'" == "ffmfga") {
					continue
				}
				local colname = "P05"
			} 
			if (`cent' == 0.1) { 
				local colname = "P10"
			} 
			if (`cent' == 0.5) { 
				local colname = "P50"
			} 
			if (`cent' == 0.9) { 
				local colname = "P90"
			} 
			if (`cent' == 0.95) { 
				if ("`acronym'" == "fmfga" | "`acronym'" == "bfpfga" | /*
				*/ "`acronym'" == "ffmfga") {
					continue
				}
				local colname = "P95"
			} 
			if (`cent' == 0.97) { 
				local colname = "P97"
			}
			capture tempvar _cent
			capture drop `_cent'
			gen double `_cent' = `cent'
			egen double measure = ///
				ig_nbs(`_cent', "`acronym'", "`conversion'"), ///
				gest_days(`_ga_days') sex(`_sex') sexcode(m=male, f=female)
			if ("`acronym'" == "wfga" | "`acronym'" == "wlrfga" | /*
			    */ "`acronym'" == "bfpfga") {
				replace measure = round(measure, 0.01)
			} 
			else {
				replace measure = round(measure, 0.1)
			}
			if ("`acronym'" == "fmfga" | "`acronym'" == "ffmfga") {
				replace measure = round(measure, 1)
				recast int measure
			}
			rename measure `colname'
		}
	}
end

foreach acronym in "wfga" "lfga" "hcfga" "wlrfga" "bfpfga" "ffmfga" "fmfga" {
	foreach sex in "male" "female" {
		foreach conversion in "z2v" "c2v" {
			local _frame = "ig_nbs_`acronym'_`conversion'_`sex'"
			cap frame drop `_frame'
			cap frame create `_frame'
			cap frame change `_frame'
			capture clear
			if inlist("`acronym'", "bfpfga", "ffmfga", "fmfga") {
				if "`conversion'" == "z2v" {
					continue
				}
				qui set obs 5
				range gest_age 266 294
			}
			else {
				qui set obs 133
				range gest_age 168 300
			}
			recast int gest_age	
			local _sex = "`sex'"
			qui make_ig_nbs_tbl gest_age "`sex'" "`acronym'" "`conversion'"
			
			if "`conversion'" == "z2v" {
				local colnames SD3neg SD2neg SD1neg SD0 SD1 SD2 SD3
			}
			if "`conversion'" == "c2v" {
				local colnames P03 P05 P10 P50 P90 P95 P97
				if inlist("`acronym'", "bfpfga", "ffmfga", "fmfga") {
					local colnames P03 P10 P50 P90 P97
				}
			}
			local path = "tests/outputs/ig_nbs/`acronym'_`conversion'_`_sex'.dta"
			cap merge 1:1 gest_age `colnames' using "`path'"
			if _rc == 9 {
				save "`path'", replace
				continue
			}
			qui {
				levelsof _merge, clean local(merge_local)
			}
			if "`merge_local'" != "3" {
				di as text "Disk file not same as memory; saving."
				keep if _merge != 2
				drop _merge
				noi save "`path'", replace
				continue
			}
			else {
				di as text "Disk file same as memory; not saving."
			}
		}
	}
}

// Test that conversions work in both directions
foreach acronym in "wfga" "lfga" "hcfga" "wlrfga" "ffmfga" "bfpfga" "fmfga" {
	cap frame change default
	cap clear
	// Set x variable
	cap drop ga_days
	if inlist("`acronym'", "wfga", "lfga", "hcfga", "wlrfga", "ofdfga", /*
		   */ "tcdfga", "gwgfga") {
		qui set obs 133 // 24 to 42 weeks
		range ga_days 168 300
	}
	else if inlist("`acronym'", "ffmfga", "bfpfga", "fmfga") {
		qui set obs 5 // 15 to 36 weeks
		range ga_days 266 294
	}
	recast int ga_days
	
	foreach sex in "M" "F" {
		// Start with z2v, then v2c, then c2v, then v2z
		cap drop sex z *from* *diffs *equal
		gen sex = "M"
		
		gen double z = -1
		egen double y_from_z = ig_nbs(z, "`acronym'", "z2v"), /* 
			*/ gest(ga_days) sex(sex) sexcode(m=M, f=F)
		egen double p_from_y = ig_nbs(y_from_z, "`acronym'", "v2c"), /* 
			*/ gest(ga_days) sex(sex) sexcode(m=M, f=F)
		egen double y_from_p = ig_nbs(p_from_y, "`acronym'", "c2v"), /* 
			*/ gest(ga_days) sex(sex) sexcode(m=M, f=F)
		egen double z_from_y = ig_nbs(y_from_p, "`acronym'", "v2z"), /* 
			*/ gest(ga_days) sex(sex) sexcode(m=M, f=F)
		
		gen double z_diffs  = z - z_from_y
		gen double y_diffs  = y_from_z - y_from_p
		gen byte z_equal = abs(z_diffs) < 10^-14
		gen byte y_equal = abs(y_diffs) < 10^-14
		
		assert z_equal == 1 & y_equal == 1
	}
}

qui frame change default
qui clear