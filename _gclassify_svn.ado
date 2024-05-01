capture prog drop _gclassify_svn
*! version 0.5.1 (SJxx-x: dmxxxx)
program define _gclassify_svn
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
		*/ [by(string)]
	
	if !inlist("`type'", "", "int") {
		SVN_BadVarType "`type'"
	}
	if `"`by'"' != "" {
		_egennoby classify_svn() `"`by'"'
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
 			SVN_Badsyntax
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			SVN_Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else SVN_Badsyntax	

    marksample touse

 	tempvar bweight_centile sfga is_term is_sfga
	qui egen double `bweight_centile' = ///
		ig_nbs(`weight_kg', "wfga", "v2c") if `touse', ///
		gest_days(`gest_days') sex(`sex') sexcode(m="`male'", f="`female'")
	qui gigs_categorise `return' if `touse', ///
		outcome(svn) measure(`bweight_centile') gest_days(`gest_days')
	restore, not
end

capture prog drop SVN_Badsyntax
program SVN_Badsyntax
	di as err "sexcode() option invalid: see {help classify_svn}"
	exit 198
end

capture prog drop SVN_BadVarType
program SVN_BadVarType
	args newvar vartype 
	di as text "Warning in {bf:classify_sfga()}:"
	di as text "	You requested a {helpb datatypes:`vartype'} variable, " ///
		"but {bf:classify_sfga()} only generates {helpb datatypes:int} " ///
		"variables. Your new variable '{bf:`newvar'}' will be an " ///
		"{helpb datatypes:int}."
end