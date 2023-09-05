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
	
	if `"`by'"' != "" {
		_egennoby classify_wfa() `"`by'"'
		/* NOTREACHED */
	}

	syntax [if] [in], GA_at_birth(varname numeric) age_days(varname) ///
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

	marksample touse

	tempvar pma_weeks acronym z_WHO z_PNG z standard 
	qui {
		gen double `pma_weeks' = round((`age_days' + `ga_at_birth') / 7)
		egen double `z_PNG' = ig_png(`weight_kg', "wfa", "v2z"), ///
			xvar(`pma_weeks') sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `z_WHO' = who_gs(`weight_kg', "wfa", "v2z"), xvar(`age_days') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
	
		gen double `z' = `z_PNG' if ///
		    `ga_at_birth' >= 182 & `ga_at_birth' < 259 & ///
			`pma_weeks' >= 27 & `pma_weeks' < 64 
		replace `z' = `z_WHO' if ///
			`ga_at_birth' < 182 | `ga_at_birth' >= 259 | `pma_weeks' < 27 | ///
			`pma_weeks' >= 64

		generate `type' `return' = .
		replace `return' = -1 if float(`z') <= -2
		replace `return' = -2 if float(`z') <= -3
		replace `return' = 0 if float(abs(`z')) < 2
		replace `return' = 1 if float(`z') >= 2
		replace `return' = -10 if float(abs(`z')) > 5
		replace `return' = . if `z' == . | `touse' == 0
	}
	capture label define wfa_labels -10 "implausible" ///
		-2 "severely underweight" -1 "underweight" 0 "normal" 1 "overweight"
	label values `return' wfa_labels
	restore, not
end

capture prog drop WFASex_Badsyntax
program WFASex_Badsyntax
	di as err "sexcode() option invalid: see {help classify_wfa}"
	exit 198
end