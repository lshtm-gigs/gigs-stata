capture program drop _gig_png
capture program drop Badsexvar_png
capture program drop Badsyntax_png
*! version 0.3.1 (SJxx-x: dmxxxx)
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
	capture assert inlist("`conversion'", "v2c", "v2z", "c2v", "z2v")
	if _rc {
		di as text "`conversion'" as error " is an invalid chart code. The " /*
		*/ as error "only valid choices are " as text "v2c, v2z, c2v," as /*
		*/ error " or " as text "z2v" as error "."
		exit 198
	}
	
	syntax [if] [in], Xvar(varname numeric) sex(varname) SEXCode(string) /*
		*/ [BY(string)]
	
	if `"`by'"' != "" {
		_egennoby ig_png() `"`by'"'
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
			qui tostring(`sex'), replace
		}
	}
	
	marksample touse
	
	qui generate `type' `return' = .
	tempvar sex_as_numeric mu sigma 
	qui {
		gen `sex_as_numeric' = 1 if `sex' == "`male'"
		replace `sex_as_numeric' = 0 if `sex' == "`female'"
		gen double `mu' = 2.591277 - 0.01155 * (`xvar' ^ 0.5) - ///
			2201.705 * (`xvar' ^ -2) + 0.0911639 * `sex_as_numeric' ///
			if "`acronym'" == "wfa"
		replace `mu' = 4.136244 - 547.0018 * (`xvar' ^ -2) + ///
			0.0026066 * `xvar' + 0.0314961 * `sex_as_numeric' ///
			if "`acronym'" == "lfa"
		replace `mu' = 55.53617 - 852.0059 * (`xvar' ^ -1) + ///
			0.7957903 * `sex_as_numeric' ///
			if "`acronym'" == "hcfa"
		replace `mu' = 13.98383 + 203.5677 * (`xvar' / 10) ^ -2 - ///
		    291.114 * ((`xvar' / 10)^ -2 * log(`xvar' / 10)) ///
			if "`acronym'" == "wfl" & `sex' == "`male'"
		replace `mu' = 50.32492 + 140.8019 * (`xvar' / 10) ^ -1 - ///
		    167.906 * (`xvar' / 10) ^ -0.5 ///
			if "`acronym'" == "wfl" & `sex' == "`female'"

		gen `sigma' = 0.1470258 + 505.92394 / `xvar' ^ 2 - ///
			140.0576 / (`xvar' ^ 2) * log(`xvar') ///
			if "`acronym'" == "wfa" 
		replace `sigma' = 0.050489 + (310.44761 * (`xvar' ^ -2)) - ///
			(90.0742 * (`xvar' ^ -2)) * log(`xvar') ///
			if "`acronym'" == "lfa"
		replace `sigma' = 3.0582292 + (3910.05 * (`xvar' ^ -2)) - ///
			180.5625 * `xvar' ^ -1 ///
			if "`acronym'" == "hcfa"
		replace `sigma' = exp(-1.830098 + 0.0049708 * (`xvar' / 10) ^ 3) ///
			if "`acronym'" == "wfl" & `sex' == "`male'"
		replace `sigma' = 0.2195888 - 0.0046046 * (`xvar' / 10) ^ 3 + ///
			0.0033017 * (`xvar' / 10) ^ 3 * log(`xvar' / 10) ///
			if "`acronym'" == "wfl" & `sex' == "`female'"
			
		tempvar q p z
		if "`conversion'" == "v2z" | "`conversion'" == "v2c" {
			gen double `q' = `input'
			gen double `z' = (log(`q') - `mu') / `sigma' 
			replace `z' = (`q' - `mu') / `sigma' ///
				if inlist("`acronym'", "hcfa", "wfl")
			replace `return' = `z'
			if "`conversion'" == "v2c" {
				qui replace `return' = normal(`z')  
			}
		}
		else if "`conversion'" == "z2v" | "`conversion'" == "c2v" {
			gen double `z' = `input'
			if "`conversion'" == "c2v" {
				replace `z' = invnormal(`input')  
			}
			gen double `q' = exp(`mu' + `z' * `sigma')
			replace `q' = `mu' + `z' * `sigma' ///
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
