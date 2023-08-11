capture program drop _gig_png
capture program drop Badsexvar_png
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

	capture assert inlist("`acronym'", "wfa", "lfa", "hcfa", "wfl")
	if _rc {
		di as text "`acronym'" as error " is an invalid acronym. The only " /*
		*/ as error "valid choices are " as text "wfa, lfa, hcfa " as error /*
		*/ "or" as text " wfl" as error "."
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
	
	syntax [if] [in], Xvar(varname numeric) sex(varname) SEXCode(string)
	
	local 1 `sexcode'
	*zap commas to spaces (i.e. commas indulged)
	local 1 : subinstr local 1 "," " ", all
	tokenize `"`1'"', parse("= ")
	
 	if "`1'" == substr("male", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("female", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			Badsyntax_png
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			Badsyntax_png
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else Badsyntax_who	
	
	local sex_type = "`:type `sex''"
	if !regexm("`sex_type'", "byte|str|int") {
		Badsexvar_png
	} 
	else {
		local sex_was_str = .
		if regexm("`sex_type'", "byte|int") {
			local sex_was_str = 0
			tostring(`sex'), replace
		}
	}
	
	marksample touse
	
	qui generate `type' `return' = .
	tempvar sex_as_numeric median stddev 
	qui {
		gen `sex_as_numeric' = 1 if `sex' == "`male'"
		replace `sex_as_numeric' = 0 if `sex' == "`female'"
		gen `median' = 2.591277 - 0.01155 * (`xvar' ^ 0.5) - ///
			2201.705 * (`xvar' ^ -2) + 0.0911639 * `sex_as_numeric' ///
			if "`acronym'" == "wfa"
		replace `median' = 4.136244 - 547.0018 * (`xvar' ^ -2) + ///
			0.0026066 * `xvar' + 0.0314961 * `sex_as_numeric' ///
			if "`acronym'" == "lfa"
		replace `median' = 55.53617 - 852.0059 * (`xvar' ^ -1) + ///
			0.7957903 * `sex_as_numeric' ///
			if "`acronym'" == "hcfa"
		replace `median' = 13.98383 + 203.5677 * (`xvar' / 10) ^ -2 - ///
		    291.114 * ((`xvar' / 10)^ -2 * log(`xvar' / 10)) ///
			if "`acronym'" == "wfl" & `sex' == "`male'"
		replace `median' = 50.32492 + 140.8019 * (`xvar' / 10) ^ -1 - ///
		    167.906 * (`xvar' / 10) ^ -0.5 ///
			if "`acronym'" == "wfl" & `sex' == "`female'"

		gen `stddev' = 0.1470258 + 505.92394 / `xvar' ^ 2 - ///
			140.0576 / (`xvar' ^ 2) * log(`xvar') ///
			if "`acronym'" == "wfa" 
		replace `stddev' = 0.050489 + (310.44761 * (`xvar' ^ -2)) - ///
			(90.0742 * (`xvar' ^ -2)) * log(`xvar') ///
			if "`acronym'" == "lfa"
		replace `stddev' = 3.0582292 + (3910.05 * (`xvar' ^ -2)) - ///
			180.5625 * `xvar' ^ -1 ///
			if "`acronym'" == "hcfa"
		replace `stddev' = exp(-1.830098 + 0.0049708 * (`xvar' / 10) ^ 3) ///
			if "`acronym'" == "wfl" & `sex' == "`male'"
		replace `stddev' = 0.2195888 - 0.0046046 * (`xvar' / 10) ^ 3 + ///
			0.0033017 * (`xvar' / 10) ^ 3 * log(`xvar' / 10) ///
			if "`acronym'" == "wfl" & `sex' == "`female'"
			
		tempvar q p z
		if "`conversion'" == "v2z" | "`conversion'" == "v2p" {
			gen double `q' = `input'
			gen double `z' = (log(`q') - `median') / `stddev' 
			replace `z' = (`q' - `median') / `stddev' ///
				if inlist("`acronym'", "hcfa", "wfl")
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
			replace `q' = `median' + `z' * `stddev' ///
				if inlist("`acronym'", "hcfa", "wfl")
			replace `return' = `q'
		} 
	}
	
	tempvar check_pma check_sex
	qui {
		gen `check_pma' = `xvar' >= 27 & `xvar' <= 64 ///
			if "`acronym'" != "wfl"
		replace `check_pma' = `xvar' >= 35 & `xvar' <= 65 ///
			if "`acronym'" == "wfl"
		gen `check_sex' = `sex' == "`male'" | `sex' == "`female'"
		if "`sex_was_str'" == "0" destring(`sex'), replace
		replace `return' = . ///
			if `check_pma' == 0 | `check_sex' == 0 | `touse' == 0
	}
	restore, not 
end

program Badsexvar_png
	di as err "sex() option should be a byte, int or str variable: see " /*
	       */ "{help ig_png}"
	exit 109
end

program Badsyntax_png
	di as err "sexcode() option invalid: see {help ig_png}"
	exit 198
end
