capture program drop _gclassify_stunting
*! version 0.5.0 (SJxx-x: dmxxxx)
program define _gclassify_stunting
	version 16
	preserve
	
	gettoken type 0 : 0
	gettoken return 0 : 0
	gettoken eqs  0 : 0
	
	gettoken paren 0 : 0, parse("(), ")
	
	gettoken lenht_cm 0 : 0, parse("(), ")

	gettoken paren 0 : 0, parse("(), ")
	if `"`paren'"' != ")" {
		error 198
	}

	syntax [if] [in], GEST_days(varname numeric) age_days(varname numeric) /*
		*/ sex(varname) SEXCode(string) [OUTliers BY(string)]

	if `"`by'"' != "" {
		_egennoby classify_stunting() `"`by'"'
		/* NOTREACHED */
	}
	
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
	else if "`1'" == substr("female", 1, length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			StuntingSex_Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else StuntingSex_Badsyntax	

	marksample touse

	tempvar lhaz
	qui gigs_zscore `lhaz' if `touse', ///
		z_type(lhaz) yvar(`lenht_cm') ///
		age_days(`age_days') gest_days(`gest_days') ///
		sex(`sex') sexc(m="`male'", f="`female'") ///
		outvartype("double")
		
	if "`outliers'" == "" {
		local outliers "0"
	}
	else {
		local outliers "1"
	}
	qui gigs_categorise `return' if `touse', ///
		analysis(stunting) measure(`lhaz') ///
		outvartype(`type') outliers("`outliers'")
	
	restore, not
end

capture prog drop StuntingSex_Badsyntax
program StuntingSex_Badsyntax
	di as err "sexcode() option invalid: see {help classify_stunting}"
	exit 198
end