capture program drop _gclassify_wasting
*! version 0.4.0 (SJxx-x: dmxxxx)
program define _gclassify_wasting
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

	syntax [if] [in], LENHT_cm(varname numeric) /*
		*/ GEST_days(varname numeric) age_days(varname numeric) /*
		*/ sex(varname) SEXCode(string) [OUTliers BY(string)]

	if `"`by'"' != "" {
		_egennoby classify_wasting() `"`by'"'
		/* NOTREACHED */
	}
	
	local 1 `sexcode'
	local 1 : subinstr local 1 "," " ", all
	tokenize `"`1'"', parse("= ")
	
 	if "`1'" == substr("male", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("female", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			WastingSex_Badsyntax
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			WastingSex_Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else WastingSex_Badsyntax

	marksample touse

	tempvar z z_WHO_wfh z_WHO_wfl z_png
	qui {
		egen double `z_png' = ig_png(`weight_kg', "wfl", "v2z"), ///
			xvar(`lenht_cm') sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `z_WHO_wfl' = who_gs(`weight_kg', "wfl", "v2z"), ///
			xvar(`lenht_cm') sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `z_WHO_wfh' = who_gs(`weight_kg', "wfh", "v2z"), ///
			xvar(`lenht_cm') sex(`sex') sexcode(m="`male'", f="`female'")
		
		tempvar pma_weeks use_png use_who
		gen double `pma_weeks' = (`age_days' + `gest_days') / 7
		gen byte `use_png' = 1 if `gest_days' < 259 & ///
			`pma_weeks' >= 27 & `pma_weeks' <= 64
		
		gen double `z' = .
		replace `z' = `z_png' if `use_png' == 1
		replace `z' = `z_WHO_wfl' if `use_png' != 1 & `age_days' < 731
		replace `z' = `z_WHO_wfh' if `use_png' != 1 & `age_days' >= 731
		
		gen `type' `return' = .
		replace `return' = -1 if float(`z') <= -2
		replace `return' = -2 if float(`z') <= -3
		replace `return' = 0 if abs(float(`z')) < 2
		replace `return' = 1 if float(`z') >= 2
		replace `return' = . if missing(`z') | `touse' == 0 | /*
			*/ missing(`gest_days') 
	}	
	cap la def wasting_labs -2 "severe wasting"  -1 "wasting" ///
	    0 "not wasting" 1 "overweight"
	cap la def wasting_labs_out -2 "severe wasting"  -1 "wasting" ///
	    0 "not wasting" 1 "overweight" 999 "outlier"
	
	if "`outliers'"=="" {
		la val `return' wasting_labs
	}
	else {
		qui replace `return' = 999 if abs(float(`z')) > 5 & !missing(`return')
		la val `return' wasting_labs_out
	}
	restore, not
end

capture prog drop WastingSex_Badsyntax
program WastingSex_Badsyntax
	di as err "sexcode() option invalid: see {help ig_nbs}"
	exit 198
end

capture prog drop WastingLenht_Badsyntax
program WastingLenht_Badsyntax
	di as err "lenhtcode() option invalid: see {help classify_wasting}"
	exit 198
end