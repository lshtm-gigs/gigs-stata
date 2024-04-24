capture prog drop _gclassify_sfga
*! version 0.5.0 (SJxx-x: dmxxxx)
program define _gclassify_sfga
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
	
	syntax [if] [in], GEST_days(varname numeric) sex(varname) SEXCode(string) /*
		*/ [SEVere by(string)]
	
	if `"`by'"' != "" {
		_egennoby classify_sfga() `"`by'"'
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
 			SfGA_Badsyntax
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			SfGA_Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else SfGA_Badsyntax	

    marksample touse
	
 	tempvar bweight_centile
 	qui egen double `bweight_centile' = ///
		ig_nbs(`weight_kg', "wfga", "v2c") if `touse', ///
		gest_days(`gest_days') sex(`sex') sexcode(m="`male'", f="`female'")
		
	if "`severe'" == "" {
		local severe "0"
	}
	else {
		local severe "1"
	}
	qui gigs_categorise `return' if `touse', ///
		analysis(sfga) measure(`bweight_centile') ///
		outvartype(`type') severe(`severe')
	
	restore, not
end

capture prog drop SfGA_Badsyntax
program SfGA_Badsyntax
	di as err "sexcode() option invalid: see {help classify_sfga}"
	exit 198
end

