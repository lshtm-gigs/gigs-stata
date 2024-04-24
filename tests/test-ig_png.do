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
foreach acronym in "wfa" "lfa" "hcfa" "wfl" {
	cap frame change default
	cap clear
	// Set x variable
	cap drop xvar
	if inlist("`acronym'", "wfa", "lfa", "hcfa") {
		qui set obs 38 // 27 to 64 weeks (by 1 week PMA)
		range xvar 27 64
		recast int xvar
	}
	else if "`acronym'" == "wfl" {
		qui set obs 301 // 35.0 to 65.0 cm (by 0.1 cm)
		range xvar 35 65
		recast double xvar
		qui replace xvar = round(xvar, 0.1)
	}
		
	foreach sex in "M" "F" {
		// Start with z2v, then v2c, then c2v, then v2z
		cap drop sex z *from* *diffs *equal
		gen sex = "M"
		
		gen double z = -1
		egen double y_from_z = ig_png(z, "`acronym'", "z2v"), /* 
			*/ x(xvar) sex(sex) sexcode(m=M, f=F)
		egen double p_from_y = ig_png(y_from_z, "`acronym'", "v2c"), /* 
			*/ x(xvar) sex(sex) sexcode(m=M, f=F)
		egen double y_from_p = ig_png(p_from_y, "`acronym'", "c2v"), /* 
			*/ x(xvar) sex(sex) sexcode(m=M, f=F)
		egen double z_from_y = ig_png(y_from_p, "`acronym'", "v2z"), /* 
			*/ x(xvar) sex(sex) sexcode(m=M, f=F)
		
		gen double z_diffs  = z - z_from_y
		gen double y_diffs  = y_from_z - y_from_p
		gen byte z_equal = abs(z_diffs) < 10^-14
		gen byte y_equal = abs(y_diffs) < 10^-14
		
		assert z_equal == 1 & y_equal == 1
	}
}

clear