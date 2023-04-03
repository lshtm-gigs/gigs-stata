capture program drop _gclassify_wfa
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gclassify_wfa
	version 16
	preserve
	
	gettoken type 0 : 0
	gettoken return 0 : 0
	gettoken eqs  0 : 0
	
	gettoken paren 0 : 0, parse("(), ")
	
	gettoken weight_kg 0 : 0, parse("(), ")

	gettoken paren 0 : 0, parse("(), ")
	if `"`paren'"' != ")" {
		error 198
	}
	
	capture assert inlist("`type'", "str")
	if _rc {
	    di as error "classify_wasting() can only return a variable of type str."
		exit 198
	}
	
	if `"`by'"' != "" {
		_egennoby classify_wfa() `"`by'"'
		/* NOTREACHED */
	}
	
	syntax [if] [in], GA_at_birth(varname numeric) PMA_days(varname) ///
		sex(varname) SEXCode(string) 
	
	local 1 `sexcode'
	local 1 : subinstr local 1 "," " ", all
	tokenize `"`1'"', parse("= ")
	
 	if "`1'" == substr("male", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("female", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			WFASex_Badsyntax
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			WFASex_Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else WFASex_Badsyntax	
	
	tempvar pma_weeks acronym z_WHO z_PNG z
	generate `pma_weeks' = round(`pma_days' / 7)
	qui {
		egen `z_PNG' = ig_png(`weight_kg', "wfa", "v2z"), pma_weeks(`pma_weeks') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		egen `z_WHO' = who_gs(`weight_kg', "wfa", "v2z"), xvar(`pma_days') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
			
		tempvar z
 	
		gen double `z' = `z_PNG' if `ga_at_birth' >= 26 & `ga_at_birth' < 37 ///
			& `pma_days' / 7 < 64
		replace `z' = `z_WHO' if `z' == .

		generate `type' `return' = ""
		replace `return' = "underweight" if `z' <= -2
		replace `return' = "underweight_severe" if `z' <= -3
		replace `return' = "normal" if abs(`z') < 2
		replace `return' = "overweight" if `z' >= 2
		replace `return' = "implausible" if abs(`z') > 5
		replace `return' = "" if `z' == .
	}
	
	restore, not
end

capture prog drop WFASex_Badsyntax
program WFASex_Badsyntax
	di as err "sexcode() option invalid: see {help ig_nbs}"
	exit 198
end