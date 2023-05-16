capture program drop _gig_png
capture program drop Badsyntax_png
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gig_png
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

	capture assert inlist("`acronym'", "wfa", "lfa", "hcfa")
	if _rc {
		di as text "`acronym'" as error " is an invalid acronym. The only " /*
		*/ as error "valid choices are " as text "wfa, lfa, " as error "or" /*
		*/ as text " hcfa" as error "."
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
		_egennoby ig_png() `"`by'"'
		/* NOTREACHED */
	}
	
	syntax [if] [in], pma_weeks(varname numeric) sex(varname) SEXCode(string)
	
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

		qui generate `type' `return' = .
	tempvar sex_as_numeric median stddev 
	qui {
		gen `sex_as_numeric' = 1 if `sex' == "`male'"
		replace `sex_as_numeric' = 0 if `sex' == "`female'"
		gen `median' = 2.591277 - 0.01155 * (`pma_weeks' ^ 0.5) - ///
			2201.705 * (`pma_weeks' ^ -2) + 0.0911639 * `sex_as_numeric' ///
			if "`acronym'" == "wfa"
		replace `median' = 4.136244 - 547.0018 * (`pma_weeks' ^ -2) + ///
			0.0026066 * `pma_weeks' + 0.0314961 * `sex_as_numeric' ///
			if "`acronym'" == "lfa"
		replace `median' = 55.53617 - 852.0059 * (`pma_weeks' ^ -1) + ///
			0.7957903 * `sex_as_numeric' ///
			if "`acronym'" == "hcfa"
		gen `stddev' = 0.1470258 + 505.92394 / `pma_weeks' ^ 2 - ///
			140.0576 / (`pma_weeks' ^ 2) * log(`pma_weeks') ///
			if "`acronym'" == "wfa" 
		replace `stddev' = 0.050489 + (310.44761 * (`pma_weeks' ^ -2)) - ///
			(90.0742 * (`pma_weeks' ^ -2)) * log(`pma_weeks') ///
			if "`acronym'" == "lfa"
		replace `stddev' = 3.0582292 + (3910.05 * (`pma_weeks' ^ -2)) - ///
			180.5625 * `pma_weeks' ^ -1 ///
			if "`acronym'" == "hcfa"
			
		tempvar q p z
		if "`conversion'" == "v2z" | "`conversion'" == "v2p" {
			gen double `q' = `input'
			gen double `z' = (log(`q') - `median') / `stddev' 
			replace `z' = (`q' - `median') / `stddev' if "`acronym'" == "hcfa"
			replace `return' = `z'
			if "`conversion'" == "v2p" {
				qui replace `return' = normal(`z')  
			}
		}
		else if "`conversion'" == "z2v" | "`conversion'" == "p2v" {
			gen double `z' = `input'
			if "`conversion'" == "p2v" {
				replace `z' = invnormal(`input')  
			}
			gen `q' = exp(`median' + `z' * `stddev')
			replace `q' = `median' + `z' * `stddev' if "`acronym'" == "hcfa"
			replace `return' = `q'
		} 
	}

	qui replace `return' = . if !(`pma_weeks' >= 27 & `pma_weeks' <= 64)
	qui replace `return' = . if !(`sex' == "`male'" | `sex' == "`female'")
	
	restore, not 
end

program Badsyntax_png
	di as err "sexcode() option invalid: see {help ig_png}"
	exit 198
end
