capture program drop _gclassify_wasting
*! version 0.5.1 (SJxx-x: dmxxxx)
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
	
	if !inlist("`type'", "", "int") {
		Stunting_BadVarType "`type'"
	}
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
	
	tempvar wlz
	qui gigs_zscore `wlz' if `touse', ///
		z_type(wlz) yvar(`weight_kg') ///
		lenht_cm(`lenht_cm') age_days(`age_days') gest_days(`gest_days') ///
		sex(`sex') sexc(m="`male'", f="`female'") ///
		outvartype("double")
		
	if "`outliers'" == "" {
		local outliers "0"
	}
	else {
		local outliers "1"
	}
	qui gigs_categorise `return' if `touse', ///
		outcome(wasting) measure(`wlz') outliers("`outliers'")
		
	restore, not
end

capture prog drop WastingSex_Badsyntax
program WastingSex_Badsyntax
	di as err "sexcode() option invalid: see {help ig_nbs}"
	exit 198
end

capture prog drop Wasting_BadVarType
program Wasting_BadVarType
	args newvar vartype 
	di as text "Warning in {bf:classify_sfga()}:"
	di as text "	You requested a {helpb datatypes:`vartype'} variable, " ///
		"but {bf:classify_sfga()} only generates {helpb datatypes:int} " ///
		"variables. Your new variable '{bf:`newvar'}' will be an " ///
		"{helpb datatypes:int}."
end