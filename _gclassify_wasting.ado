capture program drop _gclassify_wasting
*! version 0.1.0 (SJxx-x: dmxxxx)
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
	
	if `"`by'"' != "" {
		_egennoby classify_wasting() `"`by'"'
		/* NOTREACHED */
	}
	
	syntax [if] [in], LENHT_cm(varname numeric) lenht_method(varname) ///
		LENHTCode(string) sex(varname) SEXCode(string) 
	
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
	
	local 2 `lenhtcode'
	local 2 : subinstr local 2 "," " ", all
	tokenize `"`2'"', parse("= ")
	
 	if "`1'" == substr("length", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("height", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			WastingLenht_Badsyntax
 		}
 		local length "`3'"
  		local height "`6'"
	} 
	else if "`1'" == substr("height", 1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("length", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			WastingLenht_Badsyntax
 		}
 		local length "`6'"
 		local height "`3'"
 	} 
	else WastingLenht_Badsyntax

	marksample touse

	tempvar z z_height z_length
	qui {
		egen `z_height' = who_gs(`weight_kg', "wfh", "v2z"), ///
			xvar(`lenht_cm') sex(`sex') sexcode(m="`male'", f="`female'") 
		egen `z_length' = who_gs(`weight_kg', "wfl", "v2z"), ///
			xvar(`lenht_cm') sex(`sex') sexcode(m="`male'", f="`female'")
	
		gen `z' = .
		replace `z' = `z_length' if `lenht_method' == "`length'"
		replace `z' = `z_height' if `lenht_method' == "`height'"
		
		gen `type' `return' = .
		replace `return' = -1 if `z' <= -2
		replace `return' = -2 if `z' <= -3
		replace `return' = 0 if abs(`z') < 2
		replace `return' = 1 if `z' >= 2
		replace `return' = -10 if abs(`z') > 5
		replace `return' = . if `z' == . | `touse' == 0
	}	
	capture label define wasting_labels -10 "implausible" ///
	    -2 "severe wasting"  -1 "wasting" 0 "normal" 1 "overweight"
	label values `return' wasting_labels
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