capture program drop _gclassify_headsize
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gclassify_headsize
	version 16
	preserve
	
	gettoken type 0 : 0
	gettoken return 0 : 0
	gettoken eqs  0 : 0
	
	gettoken paren 0 : 0, parse("(), ")
	
	gettoken headcirc_cm 0 : 0, parse("(), ")

	gettoken paren 0 : 0, parse("(), ")
	if `"`paren'"' != ")" {
		error 198
	}
	
	syntax [if] [in], GEST_days(varname numeric) age_days(varname numeric) /*
		*/ sex(varname) SEXCode(string) [OUTliers BY(string)]
	
	if `"`by'"' != "" {
		_egennoby classify_headsize() `"`by'"'
		/* NOTREACHED */
	}

	local 1 `sexcode'
	local 1 : subinstr local 1 "," " ", all
	tokenize `"`1'"', parse("= ")
	
 	if "`1'" == substr("male", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("female", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			HeadSizeSex_BadSyntax
 		}
 		local male "`3'"
  	local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			HeadSizeSex_BadSyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else HeadSizeSex_BadSyntax	

	marksample touse
		
	tempvar hcaz
	qui gigs_zscore `hcaz' if `touse', ///
		z_type(hcaz) yvar(`headcirc_cm') ///
		age_days(`age_days') gest_days(`gest_days') ///
		sex(`sex') sexc(m="`male'", f="`female'") ///
		outvartype("double")	
	qui gigs_categorise `return' if `touse', ///
		analysis(headsize) measure(`hcaz') ///
		outvartype(`type')
	
	restore, not
end

capture prog drop HeadSizeSex_BadSyntax
program HeadSizeSex_BadSyntax
	di as err "sexcode() option invalid: see {help classify_headsize}"
	exit 198
end
