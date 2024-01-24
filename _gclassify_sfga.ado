capture program drop _gclassify_sfga
capture program drop SGA_Badsyntax
*! version 0.4.0 (SJxx-x: dmxxxx)
program define _gclassify_sfga
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
 	qui {
	    egen double `p_temp' = ig_nbs(`input', "wfga", "v2c"), ///
            gest_days(`gest_days') sex(`sex') sexcode(m="`male'", f="`female'")
	    generate `type' `return' = 0
	    replace `return' = -1 if float(`p_temp') < 0.1
	    replace `return' = 1 if float(`p_temp') > 0.9
	    replace `return' = . if missing(`p_temp') | `touse' == 0
	}
	cap la de sfga_labels -1 "SGA" 0 "AGA" 1 "LGA"
	cap la de sev_sfga_labels -2 "severely SGA" -1 "SGA" 0 "AGA" 1 "LGA"
	if "`severe'"=="" {
		la val `return' sfga_labels
	}
	else {
		replace `return' = -2 if float(`p_temp') < 0.03
	    la val `return' sev_sfga_labels
	}
	restore, not
end

program SGA_Badsyntax
	di as err "sexcode() option invalid: see {help classify_sfga}"
	exit 198
end