capture program drop _gwho_gs
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

	tempvar check_sex
    qui generate `check_sex' = `sex' == "`male'" | `sex' == "`female'"
 
	// Find reference LMS coeffecients
	local basename = "whoLMS_" + "`acronym'" + ".dta"
	qui findfile "`basename'"
	local filepath = "`r(fn)'"
	
	// Initialise new variables for merging
	foreach var in xvar sex L M S {
		capture confirm new var whoLMS_`var'
		if _rc {
			di as error "whoLMS_`var' is used by who_gs - rename your variable"
			exit 110
		}
	}
	qui {
		if ("`acronym'" != "wfl" & "`acronym'" != "wfh") {
			gen double whoLMS_xvar = `xvar'
		}
		if ("`acronym'" == "wfl" | "`acronym'" == "wfh") {
			gen float whoLMS_xvar = `xvar'
			replace whoLMS_xvar = round(whoLMS_xvar * 10, 1)
		}
		gen byte whoLMS_sex = 1 if `sex' == "`male'"
		replace whoLMS_sex = 0 if `sex' == "`female'"
	}

	tempvar n
	gen `n' = _n
	qui merge m:1 whoLMS_xvar whoLMS_sex using "`filepath'", nogenerate keep(1 3)
	sort `xvar'
	drop whoLMS_sex   
	qui {
		tempvar L M S
		ipolate whoLMS_L whoLMS_xvar, gen(`L') epolate
		ipolate whoLMS_M whoLMS_xvar, gen(`M') epolate
		ipolate whoLMS_S whoLMS_xvar, gen(`S') epolate
 		drop whoLMS_xvar whoLMS_L whoLMS_M whoLMS_S
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
			if `_z' < -3 & ("`acronym'" != "hcfa" & "`acronym'" != "lhfa") {
				replace `_z' = /*
				*/ 3 + (`input' - `_sd3pos')/(`_sd3pos' - `_sd2pos') /*
				*/ if `_z' > 3
			}
			
			gen double `_sd3neg' = `M' * (1 + `L' * `S' * -3) ^ (1 / `L')
			gen double `_sd2neg' = `M' * (1 + `L' * `S' * -2) ^ (1 / `L')
			if ("`acronym'" != "hcfa" & "`acronym'" != "lhfa") {
				replace `_z' = /*
				*/ -3 + (`input' - `_sd3neg')/(`_sd2neg' - `_sd3neg') /*
				*/ if `_z' > 3
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
			if ("`acronym'" != "hcfa" & "`acronym'" != "lhfa") {
				replace `_q' = /*
				*/ (`z' - 3) * (`_sd3pos' - `_sd2pos') + `_sd3pos' /*
				*/ if `z' > 3
			}

			gen `_sd3neg' = `M' * (1 + `L' * `S' * -3) ^ (1 / `L')
			gen `_sd2neg' = `M' * (1 + `L' * `S' * -2) ^ (1 / `L')
			if ("`acronym'" != "hcfa" & "`acronym'" != "lhfa") {
				replace `_q' = /*
				*/ (`z' + 3) * (`_sd2neg' - `_sd3neg') + `_sd3neg' /*
				*/ if `z' < -3
			}
			replace `return' = `_q'
		}
	}
	restore, not 
end

program Badsyntax_who
	di as err "sexcode() option invalid: see {help who_gs}"
	exit 198
end
