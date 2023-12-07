clear
do "_gig_fet.ado"

capture program drop make_ig_fet_tbl
program define make_ig_fet_tbl
 	args _x_var acronym conversion
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
				ig_fet(`_SD', "`acronym'", "`conversion'"), gest(`_x_var')
			if "`acronym'" == "efwfga" {
				replace measure = round(measure, 1)
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
				local colname = "P95"
			} 
			if (`cent' == 0.97) { 
				local colname = "P97"
			}
			capture tempvar _cent
			capture drop `_cent'
			gen double `_cent' = `cent'
			egen double measure = ///
				ig_fet(`_cent', "`acronym'", "`conversion'"), gest(`_x_var')
			if "`acronym'" == "efwfga" {
				replace measure = round(measure, 1)
			}
			else {
				replace measure = round(measure, 0.1)
			}
			rename measure `colname'
		}
	}
end

foreach acronym in "hcfga" "bpdfga" "acfga" "flfga" "ofdfga" "efwfga" {
	foreach conversion in "z2v" "c2v" {
		local _frame = "ig_fet_`acronym'_`conversion'"
		cap frame drop `_frame'
		cap frame create `_frame'
		cap frame change `_frame'
		capture clear
		if "`acronym'" != "efwfga" {
			qui set obs 27 // 14 to 40 weeks
			capture drop gest_days
			range gest_days 98 280
			recast int gest_days
			local xname = "gest_days"
			qui make_ig_fet_tbl gest_days "`acronym'" "`conversion'"
		}
		else {
			qui set obs 19 // 22 to 40 weeks 
			capture drop gest_days
			range gest_days 154 280
			recast int gest_days
			local xname = "gest_days"
			qui make_ig_fet_tbl gest_days "`acronym'" "`conversion'"
		}
		
		local path = "tests/outputs/ig_fet/`acronym'_`conversion'_`_sex'.dta"
		if "`conversion'" == "z2v" {
			local colnames SD3neg SD2neg SD1neg SD0 SD1 SD2 SD3
		}
		if "`conversion'" == "c2v" {
			local colnames P03 P05 P10 P50 P90 P95 P97
		}
		cap merge 1:1 `xname' `colnames' using "`path'"
		if _rc {
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

clear