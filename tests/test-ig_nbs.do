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
				gest_age(`_ga_days') sex(`_sex') sexcode(m=male, f=female)
			if ("`acronym'" == "wfga" | "`acronym'" == "wlrfga") {
				replace measure = round(measure, 0.01)
			} 
			else {
				replace measure = round(measure, 0.1)
			}
			rename measure `colname'
		}
	}
	if ("`conversion'" == "p2v") {
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
				gest_age(`_ga_days') sex(`_sex') sexcode(m=male, f=female)
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

foreach acronym in "wfga" "lfga" "hcfga" "wlrfga" {
	foreach sex in "male" "female" {
		foreach conversion in "z2v" "p2v" {
			local _frame = "ig_nbs_`acronym'_`conversion'_`sex'"
			cap frame drop `_frame'
			cap frame create `_frame'
			cap frame change `_frame'
			capture clear
			qui set obs 133
			capture drop gest_age
			range gest_age 168 300
			recast int gest_age	
			local _sex = "`sex'"
			qui make_ig_nbs_tbl gest_age "`sex'" "`acronym'" "`conversion'"
			if ("`conversion'" == "v2z") {
				local _tabletype = "zscores"
			}
			if ("`conversion'" == "v2z") {
				local _tabletype = "centiles"
			}
			local path = "tests/outputs/ig_nbs/`acronym'_`conversion'_`_sex'.dta"
			di ""
			saveold "`path'", replace version(12)
		}
	}
}

foreach acronym in "bfpfga" "ffmfga" "fmfga" {
	foreach sex in "male" "female" {
		foreach conversion in "p2v" {
			local _frame = "ig_nbs_`acronym'_`conversion'_`sex'"
			cap frame drop `_frame'
			cap frame create `_frame'
			cap frame change `_frame'
			capture clear
			qui set obs 5
			capture drop gest_age
			range gest_age 266 294
			recast int gest_age	
			local _sex = "`sex'"
			qui make_ig_nbs_tbl gest_age "`sex'" "`acronym'" "`conversion'"
			if ("`conversion'" == "v2z") {
				local _tabletype = "zscores"
			}
			if ("`conversion'" == "v2z") {
				local _tabletype = "centiles"
			}
			local path = "tests/outputs/ig_nbs/`acronym'_`conversion'_`_sex'.dta"
			di ""
			saveold "`path'", replace version(12)
		}
	}
}