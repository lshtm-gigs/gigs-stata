capture program drop _gclassify_sga
capture program drop SGA_Badsyntax
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gclassify_sga
	version 16
	preserve

	gettoken type 0 : 0
	gettoken return 0 : 0
	gettoken eqs  0 : 0

	gettoken paren 0 : 0, parse("(), ")

	gettoken input 0 : 0, parse("(), ")
	gettoken acronym  0 : 0, parse("(), ")
	if `"`acronym'"' == "," {
		gettoken acronym  0 : 0, parse("(), ")
	}
		
	gettoken paren 0 : 0, parse("(), ")
	if `"`paren'"' != ")" {
		error 198
	}
	
	di "`type'"
	capture assert inlist("`type'", "str")
	if _rc {
	    di as error "classify_sga() can only return a variable of type str."
		exit 198
	}
	capture assert inlist("`acronym'", "wfga", "lfga", "hcfga")
	if _rc {
		di as text "`acronym'" as error " is an invalid acronym. The only " /*
		*/ as error "valid choices are " as text "wfga, lfga, " as error "or" /*
		*/ as text "hcfga" as error "."
		exit 198
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
	
 	tempvar p_temp
	egen `p_temp' = ig_nbs(`input', "`acronym'", "v2p"), ///
		gest_age(`gest_age') sex(`sex') sexcode(m="`male'", f="`female'")
	qui {
	  generate `type' `return' = "AGA"
	  replace `return' = "SGA" if `p_temp' <= 0.1
	  replace `return' = "LGA" if `p_temp' >= 0.9
	  replace `return' = "SGA(<3)" if `p_temp' < 0.03
	} 
	restore, not
end

program SGA_Badsyntax
	di as err "sexcode() option invalid: see {help ig_nbs}"
	exit 198
end