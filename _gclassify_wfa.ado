capture program drop _gclassify_wfa
*! version 0.3.1 (SJxx-x: dmxxxx)
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
	
	syntax [if] [in], GEST_days(varname numeric) age_days(varname numeric) /*
		*/ sex(varname) SEXCode(string) [OUTliers BY(string)]
	
	if `"`by'"' != "" {
		_egennoby classify_wfa() `"`by'"'
		/* NOTREACHED */
	}

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

	tempvar pma_weeks pma_wks_floored z_NBS z_PNG z_WHO z
	qui {
		gen double `pma_weeks' = (`age_days' + `gest_days') / 7
		gen double `pma_wks_floored' = floor(`pma_weeks')

		egen double `z_NBS' = ig_nbs(`weight_kg', "wfga", "v2z"), ///
			gest_days(`gest_days') sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `z_PNG' = ig_png(`weight_kg', "wfa", "v2z"), ///
			xvar(`pma_wks_floored') sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `z_WHO' = who_gs(`weight_kg', "wfa", "v2z"), ///
		  xvar(`age_days') sex(`sex') sexcode(m="`male'", f="`female'")

		gen double `z' = `z_NBS' if `age_days' == 0
		replace `z' = `z_PNG' if `age_days' > 0 & `gest_days' < 259 & ///
			`pma_weeks' >= 27 & `pma_weeks' <= 64
		replace `z' = `z_WHO' if `age_days' > 0 & `gest_days' >= 259 | ///
			(`gest_days' < 259 & `pma_weeks' > 64)
		
		generate `type' `return' = .
		replace `return' = -1 if float(`z') <= -2
		replace `return' = -2 if float(`z') <= -3
		replace `return' = 0 if float(abs(`z')) < 2
		replace `return' = 1 if float(`z') >= 2
		replace `return' = . if `z' == . | `touse' == 0
	}
	cap la def wfa_labs -2 "severely underweight" -1 "underweight" ///
	    0 "normal" 1 "overweight"
	cap la def wfa_labs_out -2 "severely underweight" -1 "underweight" ///
	    0 "normal" 1 "overweight" 999 "outlier"

	if "`outliers'"=="" {
		la val `return' wfa_labs
	}
	else  {
		qui replace `return' = 999 if float(`z') < -6 | float(`z') > 5 & ///
			`return' != .
		lab val `return' wfa_labs_out
	}
	restore, not
end

capture prog drop WFASex_Badsyntax
program WFASex_Badsyntax
	di as err "sexcode() option invalid: see {help classify_wfa}"
	exit 198
end