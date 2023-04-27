capture program drop _gclassify_stunting
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gclassify_stunting
	version 16
	preserve
	
	gettoken type 0 : 0
	gettoken return 0 : 0
	gettoken eqs  0 : 0
	
	gettoken paren 0 : 0, parse("(), ")
	
	gettoken input 0 : 0, parse("(), ")

	gettoken paren 0 : 0, parse("(), ")
	if `"`paren'"' != ")" {
		error 198
	}
	
	if `"`by'"' != "" {
		_egennoby classify_stunting() `"`by'"'
		/* NOTREACHED */
	}

	syntax [if] [in], GA_at_birth(varname numeric) age_days(varname numeric) /*
		*/ sex(varname) SEXCode(string) lenht_method(varname) LENHTCode(string)

	local 1 `sexcode'
	local 1 : subinstr local 1 "," " ", all
	tokenize `"`1'"', parse("= ")

 	if "`1'" == substr("male", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("female", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			StuntingSex_Badsyntax
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			StuntingSex_Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else StuntingSex_Badsyntax	
	
	local 2 `lenhtcode'
	local 2 : subinstr local 2 "," " ", all
	tokenize `"`2'"', parse("= ")
	
 	if "`1'" == substr("length", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("height", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			StuntingLenht_Badsyntax
 		}
 		local length "`3'"
  		local height "`6'"
	} 
	else if "`1'" == substr("height", 1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("length", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			StuntingLenht_Badsyntax
 		}
 		local length "`6'"
 		local height "`3'"
 	} 
	else StuntingLenht_Badsyntax	
	
	tempvar lenht_cm
	qui {
		generate `lenht_cm' = `input'
		replace `lenht_cm' = `lenht_cm' - 0.7 ///
			if `age_days' >= 731 & `lenht_method' == "`length'"
		replace `lenht_cm' = `lenht_cm' + 0.7 ///
			if `age_days' < 731 & `lenht_method' == "`height'"
	}
	
	tempvar pma_weeks z_PNG z_WHO z
	qui {
		generate `pma_weeks' = round((`age_days' + 7 * `ga_at_birth') / 7)
		egen `z_PNG' = ig_png(`lenht_cm', "lfa", "v2z"), ///
			pma_weeks(`pma_weeks') sex(`sex') sexcode(m="`male'", f="`female'")
		egen `z_WHO' = who_gs(`lenht_cm', "lhfa", "v2z"), xvar(`age_days') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		
		gen double `z' = `z_PNG' if `ga_at_birth' >= 26 & `ga_at_birth' < 37 ///
			& `pma_weeks' >= 27 & `pma_weeks' < 64 
		replace `z' = `z_WHO' if ///
			`ga_at_birth' < 26 | `ga_at_birth' >= 37 | `pma_weeks' < 27 | ///
			`pma_weeks' >= 64
		
		generate `type' `return' = .
		replace `return' = -1 if `z' <= -2
		replace `return' = -2 if `z' <= -3
		replace `return' = -10 if `z' < -6
		replace `return' = 0 if `z' > -2
		replace `return' = -10 if `z' > 6
		replace `return' = . if `z' == .
	}
	capture label define stunting_labels -10 "implausible" ///
	   -2 "severe stunting"  -1 "stunting" 0 "normal"
	label values `return' stunting_labels
	restore, not
end

capture prog drop StuntingSex_Badsyntax
program StuntingSex_Badsyntax
	di as err "sexcode() option invalid: see {help ig_nbs}"
	exit 198
end

capture prog drop StuntingLenht_Badsyntax
program StuntingLenht_Badsyntax
	di as err "lenhtcode() option invalid: see {help ig_nbs}"
	exit 198
end