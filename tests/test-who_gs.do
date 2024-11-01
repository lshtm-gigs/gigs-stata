capture program drop make_who_gs_tbl
program define make_who_gs_tbl
 	args _xvar sex acronym conversion
	tempvar _sex round
	generate `_sex' = "`sex'" 
	if ("`conversion'" == "z2v") {
		foreach SD in -4 -3 -2 -1 0 1 2 3 4 {
			if (`SD' == -4) { 
				local colname = "SD4neg"
			} 
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
			if (`SD' == 4) { 
				local colname = "SD4"
			}
			capture tempvar _SD
			capture drop `_SD'
			qui gen `_SD' = `SD'
			egen double measure = ///
				who_gs(`_SD', "`acronym'", "`conversion'"), ///
				xvar(`_xvar') sex(`_sex') sexcode(m=male, f=female)
			replace measure = round(measure, 0.001)
			rename measure `colname'
		}
	}
	if ("`conversion'" == "c2v") {
		foreach cent in 0.001 0.01 0.03 0.05 0.10 0.15 0.25 0.50 0.75 0.85 0.90 0.95 0.97 0.99 0.999 {
			if (`cent' ==  0.001) { 
				local colname = "P01"
			}
			if (`cent' ==  0.01) { 
				local colname = "P1"
			} 
			if (`cent' ==  0.03) { 
				local colname = "P3"
			} 
			if (`cent' == 0.05) { 
				local colname = "P5"
			} 
			if (`cent' == 0.1) { 
				local colname = "P10"
			} 
			if (`cent' == 0.15) { 
				local colname = "P15"
			} 
			if (`cent' == 0.25) { 
				local colname = "P25"
			} 
			if (`cent' == 0.5) { 
				local colname = "P50"
			} 
			if (`cent' == 0.75) { 
				local colname = "P75"
			} 
			if (`cent' == 0.85) { 
				local colname = "P85"
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
			if (`cent' == 0.99) { 
				local colname = "P99"
			} 
			if (`cent' == 0.999) { 
				local colname = "P999"
			}
			capture tempvar _cent
			capture drop `_cent'
			gen double `_cent' = `cent'
			egen double measure = ///
				who_gs(`_cent', "`acronym'", "`conversion'"), ///
				xvar(`_xvar') sex(`_sex') sexc(m=male, f=female)
			replace measure = round(measure, 0.001)
			rename measure `colname'
		}
	}
end

foreach acronym in "wfa" "bfa" "lhfa" "hcfa" "wfh" "wfl" "acfa" "ssfa" "tsfa" {
	foreach sex in "male" "female" {
		foreach conversion in "c2v" "z2v" {
			local _frame = "who_gs_`acronym'_`conversion'_`sex'"
			cap frame drop `_frame'
			cap frame create `_frame'
			cap frame change `_frame'
 			capture drop _all
			local _sex = "`sex'"
			if ("`acronym'" == "wfa" | "`acronym'" == "bfa" | ///
			    "`acronym'" == "lhfa" | "`acronym'" == "hcfa") {
				qui set obs 1857
				capture drop age_days
				range age_days 0 1856
				recast int age_days
				qui make_who_gs_tbl age_days "`sex'" "`acronym'" "`conversion'"
			}
			if ("`acronym'" == "wfl") {
				qui set obs 651
				capture drop length_cm
				range temp 45 110
				qui gen length_cm = round(temp, 0.1)
				drop temp
				qui make_who_gs_tbl length_cm "`sex'" "`acronym'" "`conversion'"
			}
			if ("`acronym'" == "wfh") {
				qui set obs 551
				capture drop height_cm
				range temp 65 120 
				qui gen double height_cm = round(temp, 0.1)
				qui drop temp
				qui make_who_gs_tbl height_cm "`sex'" "`acronym'" "`conversion'"
			} 
			if ("`acronym'" == "acfa" | "`acronym'" == "ssfa" | ///
			    "`acronym'" == "tsfa") {
				qui set obs 1766
				capture drop age_days
				range age_days 91 1856
				recast int age_days
				qui make_who_gs_tbl age_days "`sex'" "`acronym'" "`conversion'"
			}
			
			local path = ///
				"tests/outputs/who_gs/`acronym'_`conversion'_`_sex'.dta"
			cap confirm file `path'
			if _rc == 601 { // i.e. file does not exist
				qui save "`path'", replace
				di as text "WHO GS: `acronym'; `sex': Disk file not found; " ///
					"saving."
				continue
			}
			
			// Set up colnames
			if "`conversion'" == "z2v" {
				qui ds SD*, not
				local colnames `r(varlist)' SD3neg SD2neg SD1neg SD0 SD1 SD2 SD3
			}
			if "`conversion'" == "c2v" {
				qui ds P*, not
				local colnames `r(varlist)' P3 P5 P10 P50 P90 P95 P97
			}
			cap qui merge 1:1 `colnames' using "`path'"
			qui levelsof _merge, clean local(merge_local)
			if "`merge_local'" != "3" {
				di as text "WHO GS: `acronym'; `sex': Disk file not same " ///
					"as memory; saving."
				keep if _merge != 2
				drop _merge
				noi save "`path'", replace
				continue
			}
			else {
				di as text "WHO GS: `acronym'; `sex': Disk file same as " ///
					"memory; not saving."
			}
		}
	}
}

// Test that conversions work in both directions
foreach acronym in "wfa" "bfa" "lhfa" "hcfa" "wfh" "wfl" "acfa" "ssfa" "tsfa" {
	cap frame change default
	cap clear
	// Set x variable
	cap drop xvar
	if inlist("`acronym'", "wfa", "bfa", "lhfa", "hcfa") {
		qui set obs 1857 // 0 to 1856 days (by 1 day)
		range xvar 0 1856
		recast int xvar
	}
	else if "`acronym'" == "wfl" {
		qui set obs 651 // 35.0 to 65.0 cm (by 0.1 cm)
		range xvar 45 110
		recast double xvar
		qui replace xvar = round(xvar, 0.1)
	}
	else if "`acronym'" == "wfh" {
		qui set obs 551 // 45.0 to 65.0 cm (by 0.1 cm)
		range xvar 65 120
		recast double xvar
		qui replace xvar = round(xvar, 0.1)
	}
	else if inlist("`acronym'", "acfa", "tsfa", "ssfa") {
		qui set obs 1766 // 91 to 1856 days (by 1 day)
		range xvar 91 1856
		recast int xvar
	}
		
	foreach sex in "M" "F" {
		// Start with z2v, then v2c, then c2v, then v2z
		cap drop sex z *from* *diffs *equal
		gen sex = "M"
		
		gen double z = -1
		egen double y_from_z = who_gs(z, "`acronym'", "z2v"), /* 
			*/ x(xvar) sex(sex) sexcode(m=M, f=F)
		egen double p_from_y = who_gs(y_from_z, "`acronym'", "v2c"), /* 
			*/ x(xvar) sex(sex) sexcode(m=M, f=F)
		egen double y_from_p = who_gs(p_from_y, "`acronym'", "c2v"), /* 
			*/ x(xvar) sex(sex) sexcode(m=M, f=F)
		egen double z_from_y = who_gs(y_from_p, "`acronym'", "v2z"), /* 
			*/ x(xvar) sex(sex) sexcode(m=M, f=F)
		
		gen double z_diffs  = z - z_from_y
		gen double y_diffs  = y_from_z - y_from_p
		gen byte z_equal = abs(z_diffs) < 8 * 10^-12
		gen byte y_equal = abs(y_diffs) < 8 * 10^-12
		
		assert z_equal == 1 & y_equal == 1
	}
}

clear
