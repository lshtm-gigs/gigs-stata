clear
do "_gig_png.ado"

capture program drop make_ig_png_tbl
program define make_ig_png_tbl
 	args _x_var sex acronym conversion
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
				ig_png(`_SD', "`acronym'", "`conversion'"), ///
				xvar(`_x_var') sex(`_sex') sexcode(m=male, f=female)
			if ("`acronym'" == "wfa" | "`acronym'" == "wfl") {
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
				ig_png(`_cent', "`acronym'", "`conversion'"), ///
				xvar(`_x_var') sex(`_sex') sexcode(m=male, f=female)
			if ("`acronym'" == "wfa" | "`acronym'" == "wfl") {
				replace measure = round(measure, 0.01)
			} 
			else {
				replace measure = round(measure, 0.1)
			}
			rename measure `colname'
		}
	}
end

foreach acronym in "wfa" "lfa" "hcfa" "wfl" {
	foreach sex in "male" "female" {
		foreach conversion in "z2v" "c2v" {
			local _frame = "ig_png_`acronym'_`conversion'_`sex'"
			cap frame drop `_frame'
			cap frame create `_frame'
			cap frame change `_frame'
			capture clear
			if "`acronym'" != "wfl" {
				qui set obs 38
				capture drop pma_weeks
				range pma_weeks 27 64
				recast int pma_weeks
				local _sex = "`sex'"
				local xname = "pma_weeks"
				qui make_ig_png_tbl pma_weeks "`sex'" "`acronym'" "`conversion'"
			}
			else {
				cap clear
				qui set obs 301
				range length_cm 35 65
				recast double length_cm
				qui replace length_cm = round(length_cm, 0.1)
				local _sex = "`sex'"
				local xname = "length_cm"
				qui make_ig_png_tbl length_cm "`sex'" "`acronym'" "`conversion'"
			}
			
			local path = "tests/outputs/ig_png/`acronym'_`conversion'_`_sex'.dta"
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
}

clear