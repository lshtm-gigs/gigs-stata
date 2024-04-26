// /* 
//  Test whether interpolated coeffs give out same values as in R package
// */

local test_interp_outputs = "tests/outputs/interpolation"
cap mkdir "`interp_outputs'"

// WHO standards:
foreach acronym in "wfa"  "bfa"  "lhfa" "wfl"  "wfh"  "hcfa" "acfa" "ssfa" "tsfa" {
	foreach sex in "M" "F" {
		clear
		if inlist("`acronym'", "wfa", "bfa", "lhfa", "hcfa") {
			qui set obs 1856
			range xvar 0 1855
		}
		if ("`acronym'" == "wfl") {
			qui set obs 650
			range temp 45 110
			qui gen xvar = round(temp, 0.1)
			qui drop temp
		}
		if ("`acronym'" == "wfh") {
			qui set obs 550
			range temp 65 120
			qui gen xvar = round(temp, 0.1)
			qui drop temp
		} 
		if inlist("`acronym'", "acfa", "ssfa", "tsfa") {
			qui set obs 1766
			range xvar 91 1855
		}
		qui recast double xvar
		if inlist("`acronym'", "wfl", "wfh") {
			qui replace xvar = xvar + 0.05
		}
		else {
			qui replace xvar = xvar + 0.25
		}
		
		// Initialise other vars, run GIGS
		gen sex = "`sex'"
		qui gen double z = 1
		qui egen double stata_col = who_gs(z, "`acronym'", "z2v"), ///
			xvar(xvar) sex(sex) sexcode(m=M, f=F)
		qui drop if missing(stata_col) // Remove OOBs
		// Save for testing against R outputs
		local path = "`test_interp_outputs'/who_gs_`acronym'_`sex'_interped.dta"
		save `path', replace
	}
}


// INTERGROWTH Newborn Size standards: 

foreach acronym in "wfga" "lfga" "hcfga" {
	foreach sex in "M" "F" {
		cap clear
		qui set obs 69
		range age_days 231 299 
		qui recast double age_days
		qui replace age_days = age_days + 0.45
		gen sex = "`sex'"
		gen z = 1
 		qui egen double stata_col = ig_nbs(z, "`acronym'", "z2v"), ///
		  gest_days(age_days) sex(sex) sexcode(m=M, f=F)
		local path = "`test_interp_outputs'/ig_nbs_`acronym'_`sex'_interped.dta"
		save `path', replace
	}
}