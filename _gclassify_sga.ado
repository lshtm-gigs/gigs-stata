capture program drop _gclassify_sga
capture program drop SGA_Badsyntax
*! version 0.2.4 (SJxx-x: dmxxxx)
program define _gclassify_sga
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
		_egennoby classify_sga() `"`by'"'
		/* NOTREACHED */
	}
	
	syntax [if] [in], gest_age(varname numeric) sex(varname) SEXCode(string)
	
	local 1 `sexcode'
	*zap commas to spaces (i.e. commas indulged)
	local 1 : subinstr local 1 "," " ", all
	tokenize `"`1'"', parse("= ")
	
 	if "`1'" == substr("male", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("female", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			SGA_Badsyntax
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			SGA_Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else SGA_Badsyntax	

    marksample touse

 	tempvar p_temp
	egen double `p_temp' = ig_nbs(`input', "wfga", "v2p"), ///
		gest_age(`gest_age') sex(`sex') sexcode(m="`male'", f="`female'")
	qui {
	    generate `type' `return' = 0
	    replace `return' = -1 if float(`p_temp') < 0.1
	    replace `return' = 1 if float(`p_temp') > 0.9
	    replace `return' = -2 if float(`p_temp') < 0.03
	    replace `return' = . if `p_temp' == . | `touse' == 0
	} 
	capture label define sga_labels -2 "severely SGA" -1 "SGA" 0 "AGA" 1 "LGA"
	label values `return' sga_labels
	restore, not
end

program SGA_Badsyntax
	di as err "sexcode() option invalid: see {help classify_sga}"
	exit 198
end