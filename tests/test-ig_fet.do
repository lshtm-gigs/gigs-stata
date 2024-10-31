capture program drop make_ig_fet_tbl
program define make_ig_fet_tbl
 	args _xvar acronym conversion
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
			qui gen double `_SD' = `SD'
			qui egen double measure = ///
				ig_fet(`_SD', "`acronym'", "`conversion'"), x(`_xvar')
			rename measure `colname'
			if inlist("`acronym'", "efwfga", "hefwfga" "gafcrl") {
				qui replace `colname' = round(`colname', 1)
			}
			else if inlist("`acronym'", "hcfga", "bpdfga", "acfga", "flfga", /*
						*/ "ofdfga", "sfhfga", "crlfga", "tcdfga") {
				qui replace `colname' = round(`colname', 0.1)
			}
			else {
				qui replace `colname' = round(`colname', 0.01)
			}
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
			qui gen double `_cent' = `cent'
			qui egen double measure = ///
				ig_fet(`_cent', "`acronym'", "`conversion'"), x(`_xvar')
			rename measure `colname'
			if inlist("`acronym'", "efwfga", "hefwfga", "gafcrl") {
				qui replace `colname' = round(`colname', 1)
			}
			else if inlist("`acronym'", "hcfga", "bpdfga", "acfga", "flfga", /*
						*/ "ofdfga", "sfhfga", "crlfga", "tcdfga") {
				qui replace `colname' = round(`colname', 0.1)
			}
			else {
				qui replace `colname' = round(`colname', 0.01)
			}
		}
	}
end
foreach acronym in "hcfga" "bpdfga" "acfga" "flfga" "ofdfga" "efwfga" /*
                  */ "sfhfga" "crlfga" "gafcrl" "gwgfga" "pifga" "rifga" /*
 				  */ "sdrfga" "tcdfga" "gaftcd" "poffga" "sffga" "avfga" /*
  				  */ "pvfga" "cmfga" "hefwfga" {
	foreach conversion in "z2v" "c2v" {
		local _frame = "ig_fet_`acronym'_`conversion'"
		cap frame drop `_frame'
		cap frame create `_frame'
		cap frame change `_frame'
		capture clear
		capture drop xvar
		if inlist("`acronym'", "hcfga", "bpdfga", "acfga", "flfga", "ofdfga", /*
			   */ "tcdfga", "gwgfga") {
			qui set obs 27 // 14 to 40 weeks
			range xvar 98 280
		}
		else if inlist("`acronym'", "poffga", "sffga", "avfga", "pvfga", /*
					*/ "cmfga") {
			qui set obs 22 // 15 to 36 weeks
			capture drop xvar
			range xvar 105 252
		}
		else if inlist("`acronym'", "pifga", "rifga", "sdrfga") {
			qui set obs 17 // 24 to 40 weeks
			capture drop xvar
			range xvar 168 280
		}
		else if "`acronym'" == "efwfga" {
			qui set obs 19 // 22 to 40 weeks
			capture drop xvar
			range xvar 154 280
		}
		else if "`acronym'" == "sfhfga" {
			qui set obs 27
			capture drop xvar
			range xvar 112 294
		}
		else if "`acronym'" == "crlfga" {
			qui set obs 48 // 22 to 40 weeks
			capture drop xvar
			range xvar 58 105
		}
		else if "`acronym'" == "gafcrl" {
			qui set obs 81
			capture drop xvar
			range xvar 15 95
		}
		else if "`acronym'" == "gwgfga" {
			qui set obs 27
			capture drop xvar
			range xvar 98 280
		}
		else if "`acronym'" == "gaftcd" {
			qui set obs 44
			capture drop xvar
			range xvar 12 55
		}
		else if "`acronym'" == "hefwfga" {
			qui set obs 24
			capture drop xvar
			range xvar 126 287
		}
		recast int xvar
		local xname = "xvar"
		make_ig_fet_tbl xvar "`acronym'" `conversion'

		local path = "tests/outputs/ig_fet/`acronym'_`conversion'.dta"
		// Overwrites existing files each time
		save "`path'", replace
	}
}

// Test that conversions work in both directions
foreach acronym in "hcfga" "bpdfga" "acfga" "flfga" "ofdfga" "efwfga" /*
                  */ "sfhfga" "crlfga" "gafcrl" "gwgfga" "pifga" "rifga" /*
 				  */ "sdrfga" "tcdfga" "gaftcd" "poffga" "sffga" "avfga" /*
  				  */ "pvfga" "cmfga" {
	cap clear
	
	// Set x variable
	cap drop xvar
	if inlist("`acronym'", "hcfga", "bpdfga", "acfga", "flfga", "ofdfga", /*
		   */ "tcdfga", "gwgfga") {
		qui set obs 27 // 14 to 40 weeks
		range xvar 98 280
	}
	else if inlist("`acronym'", "poffga", "sffga", "avfga", "pvfga", /*
				*/ "cmfga") {
		qui set obs 22 // 15 to 36 weeks
		range xvar 105 252
	}
	else if inlist("`acronym'", "pifga", "rifga", "sdrfga") {
		qui set obs 17 // 24 to 40 weeks
		range xvar 168 280
	}
	else if "`acronym'" == "efwfga" {			
		qui set obs 19 // 22 to 40 weeks 
		range xvar 154 280
	}
	else if "`acronym'" == "sfhfga" {			
		qui set obs 27
		range xvar 112 294
	}
	else if "`acronym'" == "crlfga" {			
		qui set obs 48 // 22 to 40 weeks 
		range xvar 58 105
	}
	else if "`acronym'" == "gafcrl" {			
		qui set obs 81 // 15 to 95 mm
		capture drop xvar
		range xvar 15 95
	}
	else if "`acronym'" == "gwgfga" {			
		qui set obs 27 // 14 to 40 weeks
		range xvar 98 280
	}
	else if "`acronym'" == "gaftcd" {
		qui set obs 44 // 12 to 55 mm TCD
		range xvar 12 55
	}
	
	recast int xvar

	// Start with z2v, then v2c, then c2v, then v2z
	gen double z = -1
	egen double y_from_z = ig_fet(z, "`acronym'", "z2v"), x(xvar)
	egen double p_from_y = ig_fet(y_from_z, "`acronym'", "v2c"), x(xvar)
	egen double y_from_p = ig_fet(p_from_y, "`acronym'", "c2v"), x(xvar)
	egen double z_from_y = ig_fet(y_from_p, "`acronym'", "v2z"), x(xvar)
	
	gen double z_diffs  = z - z_from_y
	gen double y_diffs  = y_from_z - y_from_p
	gen byte z_equal = abs(z_diffs) < 10^-14
	gen byte y_equal = abs(y_diffs) < 10^-14
	
	assert z_equal == 1 & y_equal == 1
}

clear