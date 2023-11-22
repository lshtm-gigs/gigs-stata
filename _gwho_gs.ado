capture program drop _gwho_gs
capture program drop Badsexvar_who
capture program drop Badsyntax_who
*! version 0.3.1 (SJxx-x: dmxxxx)
program define _gwho_gs
	version 16
	preserve

	gettoken type 0 : 0
	gettoken return 0 : 0
	gettoken eqs  0 : 0
	gettoken paren 0 : 0, parse("(), ")
	gettoken input 0 : 0, parse("(), ")
	gettoken acronym  0 : 0, parse("(), ")
	if `"`acronym'"' == "," {
		gettoken acronym  0 : 0, parse("(), ")
	}
	gettoken conversion  0 : 0, parse("(), ")
	if `"`conversion'"' == "," {
		gettoken conversion  0 : 0, parse("(), ")
	}
	gettoken paren 0 : 0, parse("(), ")
	if `"`paren'"' != ")" {
		error 198
	}

	capture assert inlist("`acronym'", "wfa", "bfa", "lhfa", "wfl", "wfh", ///
	                      "hcfa", "acfa", "ssfa", "tsfa")
	if _rc {
		di as text "`acronym'" as error " is an invalid acronym. The only " /*
		*/ as error "valid choices are " as text "wfa, bfa, lhfa, wfl, wfh, " /*
		*/ as text "hcfa, acfa, ssfa " as error "or" as text " tsfa" as error /*
		*/ "."
		exit 198
	}
	capture assert inlist("`conversion'", "v2c", "v2z", "c2v", "z2v")
	if _rc {
		di as text "`conversion'" as error " is an invalid chart code. The " /*
		*/ as error "only valid choices are " as text "v2c, v2z, c2v," as /*
		*/ error " or " as text "z2v" as error "."
		exit 198
	}
	
	syntax [if] [in], Xvar(varname numeric) sex(varname) SEXCode(string)  /*
		*/ [BY(string)]
	
	if `"`by'"' != "" {
		_egennoby who_gs() `"`by'"'
		/* NOTREACHED */
	}
	
	local 1 `sexcode'
	*zap commas to spaces (i.e. commas indulged)
	local 1 : subinstr local 1 "," " ", all
	tokenize `"`1'"', parse("= ")
	
	if "`1'" == substr("male", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("female", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
			Badsyntax_who
		}
		local male "`3'"
		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("male", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
			Badsyntax_who
		}
		local male "`6'"
		local female "`3'"
	} 
	else Badsyntax_who	

	local sex_type = "`:type `sex''"
	if !regexm("`sex_type'", "byte|str|int") {
		Badsexvar_who
	} 
	else {
		local sex_was_str = .
		if regexm("`sex_type'", "byte|int") {
			local sex_was_str = 0
			qui tostring(`sex'), replace
		}
	}

	marksample touse

	// Find reference LMS coeffecients
	local basename = "whoLMS_" + "`acronym'" + ".dta"
	qui findfile "`basename'"
	local filepath = "`r(fn)'"
	
	// Initialise new variables for merging
	foreach var in xvar sex L M S {
		capture confirm new var whoLMS_`var'
		if _rc {
			di as error "{bf:whoLMS_`var'} is used by who_gs() - rename "/*
				*/ "your variable."
			exit 110
		}
	}
	
	if ("`acronym'" != "wfl" & "`acronym'" != "wfh") {
		qui gen double whoLMS_xvar = `xvar'
		if inlist("`acronym'", "wfa", "bfa", "lhfa", "hcfa") {
			local xlimlow = 0
			local xlimhigh = 1856
		}
		if inlist("`acronym'", "acfa", "ssfa", "tsfa") {
			local xlimlow = 91
			local xlimhigh = 1856
		}
	}
	if ("`acronym'" == "wfl" | "`acronym'" == "wfh") {
		qui gen double whoLMS_xvar = `xvar'
		qui replace whoLMS_xvar = whoLMS_xvar * 10
		if inlist("`acronym'", "wfl") {
			local xlimlow = 45
			local xlimhigh = 110
		}
		else if inlist("`acronym'", "wfh") {
			local xlimlow = 65
			local xlimhigh = 120
		}
	}
	qui gen byte whoLMS_sex = 1 if `sex' == "`male'"
	qui replace whoLMS_sex = 0 if `sex' == "`female'"
	
	// Append, then interpolate in Mata (see gigs_ipolate_coeffs.ado)
 	qui {
		tempvar n appended need_interp
		append using "`filepath'", gen(`appended')
		gen `n' = _n
		gen `need_interp' = 0
		replace `need_interp' = `appended' == 0
		mata gigs_ipolate_coeffs("whoLMS_xvar", ///
								 "whoLMS_sex", ///
								 "whoLMS_L whoLMS_M whoLMS_S", ///
								 "`n'", ///
								 "`need_interp'", ///
								 "`appended'")
		drop if `appended' == 1
		tempvar L M S
		gen double `L' = whoLMS_L
		// Errors were creeping in from interpolated values being extremely close to
		// zero without being set as zero. This line replaces extremely small values
		// in `L' with zero to ensure a correction for skewness isn't performed when
		// unnecessary.
		replace `L' = 0 if abs(`L') < 1.414 * 10^-16 // aka Stata double precision
		gen double `M' = whoLMS_M
		gen double `S' = whoLMS_S
		drop whoLMS_xvar whoLMS_sex whoLMS_L whoLMS_M whoLMS_S ///
			`appended' `interp' `n_premerge' `n_postmerge'
 	}
	
	qui generate `type' `return' = .
	if "`conversion'" == "v2c" | "`conversion'" == "v2z" {
		tempvar _z z_out
		qui {
			gen double `_z' = (abs((`input'  / `M') ^ `L') - 1) / (`S' * `L')
			replace `_z' = log(`input' / `M') / `S' if `L' == 0
			
			tempvar _sd3neg _sd2neg _sd2pos _sd3pos
			gen double `_sd2pos' = `M' * (1 + `L' * `S' * 2) ^ (1/`L')
			gen double `_sd3pos' = `M' * (1 + `L' * `S' * 3) ^ (1/`L')
			if `_z' > 3 & ("`acronym'" != "hcfa" & "`acronym'" != "lhfa") {
				replace `_z' = /*
				*/ 3 + (`input' - `_sd3pos')/(`_sd3pos' - `_sd2pos') /*
				*/ if `_z' > 3
			}
			
			gen double `_sd3neg' = `M' * (1 + `L' * `S' * -3) ^ (1 / `L')
			gen double `_sd2neg' = `M' * (1 + `L' * `S' * -2) ^ (1 / `L')
			if `_z' < -3 & ("`acronym'" != "hcfa" & "`acronym'" != "lhfa") {
				replace `_z' = /*
				*/ -3 + (`input' - `_sd3neg')/(`_sd2neg' - `_sd3neg') /*
				*/ if `_z' < -3
			}
			replace `return' = `_z'		
		}
		if "`conversion'" == "v2c" {
			qui replace `return' = normal(`_z')
		}
	}
	else if "`conversion'" == "c2v" | "`conversion'" == "z2v" {
		tempvar z _q q_out
		qui gen `z' = `input'
		if "`conversion'" == "c2v" {
			qui replace `z' = invnormal(`z')
		}
		qui {
			gen double `_q'  = ((`z' * `S' * `L' + 1) ^ (1 / `L')) * `M'
			replace `_q' = `M' * exp(`S' * `z') if `L' == 0
			
			tempvar _sd3neg _sd2neg _sd2pos _sd3pos
			gen double `_sd2pos' = `M' * (1 + `L' * `S' * 2) ^ (1 / `L')
			gen double `_sd3pos' = `M' * (1 + `L' * `S' * 3) ^ (1 / `L')
			if `z' > 3 & ("`acronym'" != "hcfa" & "`acronym'" != "lhfa") {
				replace `_q' = /*
				*/ (`z' - 3) * (`_sd3pos' - `_sd2pos') + `_sd3pos' /*
				*/ if `z' > 3
			}

			gen double `_sd3neg' = `M' * (1 + `L' * `S' * -3) ^ (1 / `L')
			gen double `_sd2neg' = `M' * (1 + `L' * `S' * -2) ^ (1 / `L')
			if `z' < -3 & ("`acronym'" != "hcfa" & "`acronym'" != "lhfa") {
				replace `_q' = /*
				*/ (`z' + 3) * (`_sd2neg' - `_sd3neg') + `_sd3neg' /*
				*/ if `z' < -3
			}
			replace `return' = `_q'
		}
	}
	qui {
		tempvar check_xvar check_sex
		gen int `check_xvar' = `xvar' >= `xlimlow'  & `xvar' <= `xlimhigh'
		gen int `check_sex' = `sex' == "`male'" | `sex' == "`female'"
		if "`sex_was_str'" == "0" destring(`sex'), replace
		replace `return' = . ///
		    if `check_xvar' == 0 | `check_sex' == 0 | `touse' == 0
	}
	restore, not
end

program Badsexvar_who
	di as err "sex() option should be a byte, int or str variable: see " /*
	       */ "{help who_gs}"
	exit 109
end

program Badsyntax_who
	di as err "sexcode() option invalid: see {help who_gs}"
	exit 198
end
