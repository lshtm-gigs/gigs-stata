capture program drop _gwho_gs
capture program drop Badsexvar_who
capture program drop Badsyntax_who
*! version 0.1.0 (SJxx-x: dmxxxx)
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
	capture assert inlist("`conversion'", "v2p", "v2z", "p2v", "z2v")
	if _rc {
		di as text "`conversion'" as error " is an invalid chart code. The " /*
		*/ as error "only valid choices are " as text "v2p, v2z, p2v," as /*
		*/ error " or " as text "z2v" as error "."
		exit 198
	}
	
	if `"`by'"' != "" {
		_egennoby who_gs() `"`by'"'
		/* NOTREACHED */
	}
	
	syntax [if] [in], Xvar(varname numeric) sex(varname) SEXCode(string)
	
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
		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
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
			tostring(`sex'), replace
		}
	}

	marksample touse

	// Find reference LMS coeffecients
	local basename = "whoLMS_" + "`acronym'" + ".dta"
	qui findfile "`basename'"
	local filepath = "`r(fn)'"
	tempvar n
	gen `n' = _n
	
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
		gen double whoLMS_xvar = `xvar'
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
		qui gen float whoLMS_xvar = `xvar'
		qui replace whoLMS_xvar = round(whoLMS_xvar * 10, 1)
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
	
	// Add empty rows (if needed) for interpolation
	tempvar interp
	qui gen int `interp' = 0
	qui replace `interp' = 1 if ///
		0 != mod(whoLMS_xvar, 1) & `xvar' >= `xlimlow'  & `xvar' <= `xlimhigh'
	qui levelsof `interp', clean local(interp_local)
	while inlist(`interp_local', 1) == 1 {
		forval i=1/`=_N' {
			if `interp'[`i'] == 1 {
				qui replace `interp' = 0 if _n == `i'
				qui insobs 1, before(`i')
				qui insobs 1, after(`i' + 1)
				continue, break
			}
		}
		macro drop interp_local
		qui levelsof `interp', clean local(interp_local)
	}
	qui replace `interp' = 1 if ///
		0 != mod(whoLMS_xvar, 1) & `xvar' >= `xlimlow'  & `xvar' <= `xlimhigh'
	
	// Replace xvar + sex if NEXT ROW contains missing LMS
	qui replace whoLMS_xvar = floor(whoLMS_xvar[_n+1]) /*
		*/ if 0 != mod(whoLMS_xvar[_n+1],1) /*
		*/ & whoLMS_sex == .
	qui replace whoLMS_sex = whoLMS_sex[_n+1] /*
		*/ if 0 != mod(whoLMS_xvar[_n+1],1) /*
		*/ & whoLMS_sex == . 
	
	// Replace xvar + sex if PREVIOUS ROW contains missing LMS
	qui replace whoLMS_xvar = ceil(whoLMS_xvar[_n-1]) /*
		*/ if 0 != mod(whoLMS_xvar[_n-1],1) /*
		*/ & whoLMS_sex == .
	qui replace whoLMS_sex = whoLMS_sex[_n-1] /*
		*/ if 0 != mod(whoLMS_xvar[_n-1],1) /*
		*/ & whoLMS_sex == .
	
	tempvar n_long
	qui gen `n_long' = _n
	qui merge m:1 whoLMS_xvar whoLMS_sex using "`filepath'", ///
		nogenerate keep(1 3)
	sort `n_long'
	drop `n_long' 
	 
	qui {
		tempvar iL iM iS L M S
		ipolate whoLMS_L whoLMS_xvar, gen(`iL')
		ipolate whoLMS_M whoLMS_xvar, gen(`iM')
		ipolate whoLMS_S whoLMS_xvar, gen(`iS')
		
		gen `L'= `iL' if `interp' == 1
		replace `L' = whoLMS_L if `interp' == 0
		gen `M'= `iM' if `interp' == 1
		replace `M' = whoLMS_M if `interp' == 0
		gen `S'= `iS' if `interp' == 1
		replace `S' = whoLMS_S if `interp' == 0

		drop whoLMS_xvar whoLMS_sex whoLMS_L whoLMS_M whoLMS_S ///
			`interp' `iL' `iM' `iS'
		drop if `input' == . & `n' == .
		sort `n'
		drop `n'
	}
	
	qui generate `type' `return' = .
	if "`conversion'" == "v2p" | "`conversion'" == "v2z" {
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
		if "`conversion'" == "v2p" {
			qui replace `return' = normal(`_z')
		}
	}
	else if "`conversion'" == "p2v" | "`conversion'" == "z2v" {
		tempvar z _q q_out
		qui gen `z' = `input'
		if "`conversion'" == "p2v" {
			qui replace `z' = invnormal(`z')
		}
		qui {
			gen `_q'  = ((`z' * `S' * `L' + 1) ^ (1 / `L')) * `M'
			replace `_q' = `M' * exp(`S' * `z') if `L' == 0
			
			tempvar _sd3neg _sd2neg _sd2pos _sd3pos
			gen `_sd2pos' = `M' * (1 + `L' * `S' * 2) ^ (1 / `L')
			gen `_sd3pos' = `M' * (1 + `L' * `S' * 3) ^ (1 / `L')
			if `z' > 3 & ("`acronym'" != "hcfa" & "`acronym'" != "lhfa") {
				replace `_q' = /*
				*/ (`z' - 3) * (`_sd3pos' - `_sd2pos') + `_sd3pos' /*
				*/ if `z' > 3
			}

			gen `_sd3neg' = `M' * (1 + `L' * `S' * -3) ^ (1 / `L')
			gen `_sd2neg' = `M' * (1 + `L' * `S' * -2) ^ (1 / `L')
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
