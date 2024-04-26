capture prog drop gigs_categorise
*! version 0.1.0 (SJxx-x: dmxxxx)
program gigs_categorise
	version 16
	preserve
	syntax newvarname(numeric) [if] [in] , /// 
		analysis(string) measure(varname numeric) outvartype(string) ///
		[gest_days(varname numeric) outliers(string) severe(string)]
	marksample touse, novarlist
	
	local newvar "`varlist'"
	
	cap assert inlist("`analysis'", "sfga", "svn", "stunting", "wasting", ///
		"wfa", "headsize")
	if _rc == 9 {
		di as error "INTERNAL ERROR in gigs_categorise: " /*
			*/ "{bf:analysis} arg must be a valid growth analysis string. " /*
			*/ "This is an internal error, so please contact the " /*
			*/ "maintainers of this package if you are an end-user. You can " /*
			*/ "find our details at {help gigs}."
		exit 499
	}
	if "`analysis'" == "sfga" {
		SfGA_categorise `newvar' if `touse', ///
			bweight_centile(`measure') outvartype("`outvartype'") ///
			severe("`severe'")
	}
	else if "`analysis'" == "svn" {
		SVN_categorise `newvar' if `touse', ///
			bweight_centile(`measure') gest_days(`gest_days') ///
			outvartype("`outvartype'")
			noi li `newvar'
	}
	else if "`analysis'" == "stunting" {
		Stunting_categorise `newvar' if `touse', ///
			lhaz(`measure') outvartype("`outvartype'") outliers("`outliers'")
	}
	else if "`analysis'" == "wasting" {
		Wasting_categorise `newvar' if `touse', ///
			wlz(`measure') outvartype("`outvartype'") outliers("`outliers'")
	}
	else if "`analysis'" == "wfa" {
		WFA_categorise `newvar' if `touse', ///
			waz(`measure') outvartype("`outvartype'") outliers("`outliers'")
	}
	else if "`analysis'" == "headsize" {
		Headsize_categorise `newvar' if `touse', ///
			hcaz(`measure') outvartype("`outvartype'")
	}
	restore, not
end

capture prog drop SfGA_categorise
program SfGA_categorise
	version 16
	preserve
	syntax newvarname(numeric) [if] [in] , /// 
		bweight_centile(varname numeric) outvartype(string) severe(string)
	marksample touse, novarlist
	
	local sfga "`varlist'"
	qui gen `outvartype' `sfga' = 0
	replace `sfga' = -1 if float(`bweight_centile') < 0.1
	replace `sfga' =  1 if float(`bweight_centile') > 0.9
	replace `sfga' =  . if missing(`bweight_centile') | `touse' == 0
	
	cap la de gigs_labs_sfga -1 "SGA" 0 "AGA" 1 "LGA"
	cap la de gigs_labs_sfga_sev -2 "severely SGA" -1 "SGA" 0 "AGA" 1 "LGA"
	
 	if "`severe'" == "0" {
		la val `sfga' gigs_labs_sfga
	}
	 else if "`severe'" == "1" {
		replace `sfga' = -2 if float(`bweight_centile') < 0.03
		replace `sfga' = . if missing(`bweight_centile') | `touse' == 0
		la val `sfga' gigs_labs_sfga_sev
	}
	else {
		di as error "INTERNAL ERROR in SfGA_categorise: {bf:severe()} " /*
			*/ "option must be either 0 (don't flag outliers) or 1 (flag " /*
			*/ "outliers). This is an internal error, so please contact the " /*
			*/ "maintainers of this package if you are an end-user. You can " /*
			*/ "find our details at {help gigs}."
		exit 498
	}
	restore, not
end

capture prog drop SVN_categorise
program SVN_categorise
	version 16
	preserve
	syntax newvarname(numeric) [if] [in] , /// 
		bweight_centile(varname numeric) gest_days(varname numeric) ///
		outvartype(string)
	marksample touse, novarlist
	
	tempvar sfga is_term
	SfGA_categorise `sfga' if `touse', ///
		bweight_centile(`bweight_centile') outvartype(int) ///
		severe("0")
	gen byte `is_term' = `gest_days' >= 259 & /// 259 days = 37 weeks
		 !missing(`gest_days')
	
	local svn "`varlist'"
	gen `outvartype' `svn' = .
	replace `svn' = -4 if `is_term' == 0 & `sfga' == -1
	replace `svn' = -3 if `is_term' == 0 & `sfga' == 0
    replace `svn' = -2 if `is_term' == 0 & `sfga' == 1
    replace `svn' = -1 if `is_term' == 1 & `sfga' == -1
    replace `svn' =  0 if `is_term' == 1 & `sfga' == 0
    replace `svn' =  1 if `is_term' == 1 & `sfga' == 1
    replace `svn' =  . if missing(`sga') | `touse' == 0
		
	cap la de gigs_labs_svn -4 "Preterm SGA" -3 "Preterm AGA" ///
	    -2 "Preterm LGA" -1 "Term SGA" 0 "Term AGA" 1 "Term LGA"
	la val `svn' gigs_labs_svn
	restore, not
end

capture prog drop Stunting_categorise
program Stunting_categorise
	version 16
	preserve
	syntax newvarname(numeric) [if] [in] , /// 
		lhaz(varname numeric) outvartype(string) outliers(string)
	marksample touse, novarlist
	
	local stunting "`varlist'"
	qui gen `outvartype' `stunting' = .
	replace `stunting' = -1 if float(`lhaz') <= -2
	replace `stunting' = -2 if float(`lhaz') <= -3
	replace `stunting' = 0 if float(`lhaz') > -2
	replace `stunting' = . if missing(`lhaz') | `touse' == 0
	
 	cap la de gigs_labs_stunting -2 "severe stunting" -1 "stunting" ///
		0 "not stunting"
	cap la de gigs_labs_stunting_out -2 "severe stunting" -1 "stunting" 0 ///
		"not stunting" 999 "outlier"
	
 	if "`outliers'" == "0" {
		la val `stunting' gigs_labs_stunting
	}
	 else if "`outliers'" == "1" {
		qui replace `stunting' = 999 if abs(float(`lhaz')) > 6 & ///
			missing(`stunting') == 0
		la val `stunting' gigs_labs_stunting_out
	}
	else {
		di as error "INTERNAL ERROR in Stunting_categorise: {bf:outliers()} " /*
			*/ "option must be either 0 (don't flag outliers) or 1 (flag " /*
			*/ "outliers). This is an internal error, so please contact the " /*
			*/ "maintainers of this package if you are an end-user. You can " /*
			*/ "find our details at {help gigs}."
		exit 498
	}
	restore, not
end

capture prog drop Wasting_categorise
program Wasting_categorise
	version 16
	preserve
	syntax newvarname(numeric) [if] [in] , /// 
		wlz(varname numeric) outvartype(string) outliers(string)
	marksample touse, novarlist
	
	local wasting "`varlist'"
	qui gen `outvartype' `wasting' = .
	replace `wasting' = -1 if float(`wlz') <= -2
	replace `wasting' = -2 if float(`wlz') <= -3
	replace `wasting' = 0 if abs(float(`wlz')) < 2
	replace `wasting' = 1 if float(`wlz') >= 2
	replace `wasting' = . if missing(`wlz') | `touse' == 0
	
 	cap la def gigs_labs_wasting -2 "severe wasting"  -1 "wasting" ///
 	    0 "not wasting" 1 "overweight"
 	cap la def gigs_labs_wasting_out -2 "severe wasting"  -1 "wasting" ///
 	    0 "not wasting" 1 "overweight" 999 "outlier"
	
 	if "`outliers'" == "0" {
 		la val `wasting' gigs_labs_wasting
 	}
 	else if "`outliers'" == "1" {
 		qui replace `wasting' = 999 if abs(float(`wlz')) > 5 & ///
			missing(`wasting') == 0
 		la val `wasting' gigs_labs_wasting_out
 	}
	else {
		di as error "INTERNAL ERROR in Wasting_categorise: {bf:outliers()} " /*
			*/ "option must be either 0 (don't flag outliers) or 1 (flag " /*
			*/ "outliers). This is an internal error, so please contact the " /*
			*/ "maintainers of this package if you are an end-user. You can " /*
			*/ "find our details at {help gigs}."
		exit 498
	}
	restore, not
end

capture prog drop WFA_categorise
program WFA_categorise
	version 16
	preserve
	syntax newvarname(numeric) [if] [in] , /// 
		waz(varname numeric) outvartype(string) outliers(string)
	marksample touse, novarlist
	
	local wfa "`varlist'"
	qui gen `outvartype' `wfa' = .
	replace `wfa' = -1 if float(`waz') <= -2
	replace `wfa' = -2 if float(`waz') <= -3
	replace `wfa' = 0 if float(abs(`waz')) < 2
	replace `wfa' = 1 if float(`waz') >= 2
	replace `wfa' = . if missing(`waz') | `touse' == 0
	
 	cap la def gigs_labs_wfa -2 "severely underweight" -1 "underweight" ///
	    0 "normal weight" 1 "overweight"
	cap la def gigs_labs_wfa_out -2 "severely underweight" -1 "underweight" ///
	    0 "normal weight" 1 "overweight" 999 "outlier"
	
 	if "`outliers'" == "0" {
		la val `wfa' gigs_labs_wfa
	}
	 else if "`outliers'" == "1" {
		qui replace `wfa' = 999 if float(`waz') < -6 | float(`waz') > 5 & ///
			missing(`wfa') == 0
		la val `wfa' gigs_labs_wfa_out
	}
	else {
		di as error "INTERNAL ERROR in WFA_categorise: {bf:outliers()} " /*
			*/ "option must be either 0 (don't flag outliers) or 1 (flag " /*
			*/ "outliers). This is an internal error, so please contact the " /*
			*/ "maintainers of this package if you are an end-user. You can " /*
			*/ "find our details at {help gigs}."
		exit 498
	}
	restore, not
end

capture prog drop Headsize_categorise
program Headsize_categorise
	version 16
	preserve
	syntax newvarname(numeric) [if] [in] , /// 
		hcaz(varname numeric) outvartype(string)
	marksample touse, novarlist
	
	local headsize "`varlist'"
	qui gen `outvartype' `headsize' = .
	replace `headsize' = -1 if float(`hcaz') <= -2
	replace `headsize' = -2 if float(`hcaz') <= -3
	replace `headsize' = 0 if float(abs(`hcaz')) < 2
	replace `headsize' = 1 if float(`hcaz') >= 2
	replace `headsize' = 2 if float(`hcaz') >= 3
	replace `headsize' = . if missing(`hcaz') | `touse' == 0
	
	cap la def gigs_labs_headsize -2 "severe microcephaly" -1 "microcephaly" ///
	    0 "normal head size" 1 "macrocephaly" 2 "severe macrocephaly"
	lab val `headsize' gigs_labs_headsize
	
	restore, not
end