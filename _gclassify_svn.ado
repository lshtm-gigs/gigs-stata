capture program drop _gclassify_svn
capture program drop SVN_Badsyntax
*! version 0.3.1 (SJxx-x: dmxxxx)
program define _gclassify_svn
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
		*/ [by(string)]
	
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

 	tempvar sga is_term is_sga
	qui {
		egen double `sga' = classify_sga(`input'), ///
			gest_days(`gest_days') sex(`sex') sexcode(m="`male'", f="`female'")
		gen `is_term' = `gest_days' >= 259 // 259 days = 37 weeks
	    gen `type' `return' = .
	    replace `return' = -4 if `is_term' == 0 & `sga' == -1
	    replace `return' = -3 if `is_term' == 0 & `sga' == 0
        replace `return' = -2 if `is_term' == 0 & `sga' == 1
        replace `return' = -1 if `is_term' == 1 & `sga' == -1
        replace `return' =  0 if `is_term' == 1 & `sga' == 0
        replace `return' =  1 if `is_term' == 1 & `sga' == 1
        replace `return' =  . if `sga' == . | `touse' == 0
	}
	cap la de svn_labels -4 "Preterm SGA" -3 "Preterm AGA" -2 "Preterm LGA" ///
	    -1 "Term SGA" 0 "Term AGA" 1 "Term LGA"
	la val `return' svn_labels
	restore, not
end

program SVN_Badsyntax
	di as err "sexcode() option invalid: see {help classify_sga}"
	exit 198
end