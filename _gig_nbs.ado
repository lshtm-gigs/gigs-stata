capture program drop _gig_nbs
capture program drop Badsyntax_nbs
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gig_nbs
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
	gettoken conversion  0 : 0, parse("(), ")
 	if `"`conversion'"' == "," {
		gettoken conversion  0 : 0, parse("(), ")
	}
	gettoken paren 0 : 0, parse("(), ")
	if `"`paren'"' != ")" {
		error 198
	}
	capture assert inlist("`acronym'", "wfga", "lfga", "wlrfga", "hcfga", /*
	*/                    "ffmfga", "bfpfga", "fmfga")
	if _rc {
		di as text "`acronym'" as error " is an invalid acronym. The only " /*
		*/ as error "valid choices are " as text "wfga, lfga, hcfga, wlrfga," /*
		*/ as text " ffmfga, bfpfga, " as error "or" as text " fmfga" /*
		*/ as error "."
		exit 198
	}
	capture assert inlist("`conversion'", "v2p", "v2z", "p2v", "z2v")
	if _rc {
		di as text "`conversion'" as error " is an invalid chart code. The " /*
		*/ as error "only valid choices are " as text "v2p, v2z, p2v," as /*
		*/ error " or " as text "z2v" as error "."
		exit 198
	}
	
	if `"`by'"' != "" {
		_egennoby ig_nbs() `"`by'"'
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
 			Badsyntax_who
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			Badsyntax_who
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else Badsyntax_who	

	tempvar check_sex check_ga
    qui gen int `check_sex' = `sex' == "`male'" | `sex' == "`female'"
	qui gen int `check_ga' = `gest_age' >= 168 & `gest_age' <= 300
	
	qui generate `type' `return' = .
	if inlist("`acronym'", "wfga", "lfga", "hcfga") {
		// Find reference GAMLSS coeffecients
		local basename = "ig_nbsGAMLSS_" + "`acronym'" + ".dta"
		qui findfile "`basename'"
		local filepath = "`r(fn)'"
		tempvar n
		gen `n' = _n
		
		// Initialise new variables for merging
		foreach var in gest_age sex mu sigma nu tau {
			capture confirm new var nbsMSNT_`var'
			if _rc {
				di as error "{bf:nbsMSNT_`var'} is used by ig_nbs() - rename" /* 
				*/ as error " your variable."
				exit 110
			}
		}
		
		qui {
			gen double nbsMSNT_gest_age = `gest_age'
			gen byte nbsMSNT_sex = 1 if `sex' == "`male'"
			replace nbsMSNT_sex = 0 if `sex' == "`female'"
		}
		
		// Add empty rows (if needed) for interpolation
		tempvar interp
		qui gen int `interp' = 0
		qui replace `interp' = 1 if ///
			0 != mod(`gest_age', 1) & `gest_age' >= 231  & `gest_age' <= 300
		qui levelsof `interp', clean local(interp_local)
		while inlist(`interp_local', 1) == 1 {
			forval i=1/`=_N' {
				if `interp'[`i'] == 1 {
					qui replace `interp' = 0 if _n == `i'
					qui insobs 1, before(`i')
					qui insobs 1, after(`i' + 1)
					continue, break
				}
			}
			macro drop interp_local
			qui levelsof `interp', clean local(interp_local)
		}
		qui replace `interp' = 1 if ///
			0 != mod(`gest_age', 1) & `gest_age' >= 231  & `gest_age' <= 300
		
		// Replace GA + sex if NEXT ROW contains missing MSNT
		qui replace nbsMSNT_gest_age = floor(nbsMSNT_gest_age[_n+1]) /*
			*/ if 0 != mod(nbsMSNT_gest_age[_n+1],1) /*
			*/ & nbsMSNT_sex == .
		qui replace nbsMSNT_sex = nbsMSNT_sex[_n+1] /*
			*/ if 0 != mod(nbsMSNT_gest_age[_n+1],1) /*
			*/ & nbsMSNT_sex == . 
		
		// Replace GA + sex if PREVIOUS ROW contains missing MSNT
		qui replace nbsMSNT_gest_age = ceil(nbsMSNT_gest_age[_n-1]) /*
			*/ if 0 != mod(nbsMSNT_gest_age[_n-1],1) /*
			*/ & nbsMSNT_sex == .
		qui replace nbsMSNT_sex = nbsMSNT_sex[_n-1] /*
			*/ if 0 != mod(nbsMSNT_gest_age[_n-1],1) /*
			*/ & nbsMSNT_sex == . 
		
		tempvar n_long
		qui gen `n_long' = _n
		qui	merge m:1 nbsMSNT_gest_age nbsMSNT_sex using "`filepath'", ///
			nogenerate keep(1 3)
		sort `n_long'
		drop `n_long'

		qui {
			tempvar iMu iSigma iNu iTau mu sigma nu tau
			ipolate nbsMSNT_mu nbsMSNT_gest_age, gen(`iMu')
		    ipolate nbsMSNT_sigma nbsMSNT_gest_age, gen(`iSigma')
		    ipolate nbsMSNT_nu nbsMSNT_gest_age, gen(`iNu')
			ipolate nbsMSNT_tau nbsMSNT_gest_age, gen(`iTau')
			
			gen `mu'= `iMu' if `interp' == 1
			replace `mu' = nbsMSNT_mu if `interp' == 0
			gen `sigma'= `iSigma' if `interp' == 1
			replace `sigma' = nbsMSNT_sigma if `interp' == 0
			gen `nu'= `iNu' if `interp' == 1
			replace `nu' = nbsMSNT_nu if `interp' == 0
			gen `tau'= `iTau' if `interp' == 1
			replace `tau' = nbsMSNT_tau if `interp' == 0
				
			drop nbsMSNT_gest_age nbsMSNT_sex /// 
				nbsMSNT_mu nbsMSNT_sigma nbsMSNT_nu nbsMSNT_tau ///
				`iMu' `iSigma' `iNu' `iTau' 
			drop if `input' == . & `n' == .
			sort `n'
			drop `n'
		}
		
		tempvar sex_as_numeric median gest_age_weeks vpns_median vpns_stddev
		qui {
			generate `sex_as_numeric' = 1 if `sex' == "`male'"
			replace `sex_as_numeric' = 0 if `sex' == "`female'"
			generate `gest_age_weeks' = .
			replace `gest_age_weeks' = `gest_age' / 7  if `gest_age' >= 168
				
			generate `vpns_median' = .
			replace `vpns_median' = ///
				-7.00303 + (1.325911 * (`gest_age_weeks' ^ 0.5)) + ///
				(0.0571937 * `sex_as_numeric') if "`acronym'" == "wfga"
			replace `vpns_median' = ///
				1.307633 + 1.270022 * `gest_age_weeks' + ///
				0.4263885 * `sex_as_numeric' if "`acronym'" == "lfga"
			replace `vpns_median' = 0.7866522 + 0.887638 * `gest_age_weeks' ///
				+ 0.2513385 * `sex_as_numeric' if "`acronym'" == "hcfga"
			generate `vpns_stddev' = .
			replace `vpns_stddev' = sqrt(0.0373218) if "`acronym'" == "wfga"
			replace `vpns_stddev' = sqrt(6.7575430) if "`acronym'" == "lfga"
			replace `vpns_stddev' = sqrt(2.4334810) if "`acronym'" == "hcfga"
		}

		if "`conversion'" == "v2p" | "`conversion'" == "v2z" {
			tempvar q cdf p_pST3 p_out
			qui {
				gen `q' = `input'
				gen `cdf' = 2 * t(`tau', `nu' * (`q' - `mu') / `sigma') ///
					if `q' < `mu'		
				replace `cdf' = 1 + 2 * `nu' ^ 2 * ///
					(t(`tau', (`q' - `mu') / (`sigma' * `nu')) - 0.5) ///
					if `q' >= `mu' 
				generate `p_pST3' = `cdf' / (1 + `nu' ^ 2)
			
				tempvar p_vpns 
				generate `p_vpns' = ///
					normal((`q' - `vpns_median') / `vpns_stddev')
				replace `p_vpns' = ///
					normal((log(`q') - `vpns_median') / `vpns_stddev') ///
					if "`acronym'" == "wfga"
				
				generate `p_out' = `p_pST3' if `p_pST3' != .
				replace `p_out' = `p_vpns' if `p_vpns' != . & `p_pST3' == .
				replace `return' = `p_out'
			}
			if "`conversion'" == "v2z" {
				qui replace `return' = invnormal(`p_out')
			}
		}
		else {
			tempvar p
			if "`conversion'" == "p2v" {
				qui gen `p' = `input'
			}
			else if "`conversion'" == "z2v" {
				qui gen `p' = normal(`input')
			}
					
			tempvar q_qST3
			qui {
				generate `q_qST3' = `mu' + (`sigma' / `nu') * ///
					invt(`tau', `p' * (1 + `nu' ^ 2) / 2) ///
					if `p' < (1 / (1 + `nu' ^ 2))
				replace `q_qST3' = `mu' + (`sigma' * `nu') * ///
					invt(`tau', (`p' * (1 + `nu'^2) - 1) / (2 * `nu'^2) + 0.5) ///
					if `p' >= (1 / (1 + `nu'^2))
			}
			
			tempvar z q_vpns
			qui {
				gen `z' = invnormal(`p')
				gen `q_vpns' = `vpns_median' + invnormal(`p') * `vpns_stddev'
				replace `q_vpns' = exp(`vpns_median' + ///
					(invnormal(`p') * `vpns_stddev')) if "`acronym'" == "wfga"
			} 		
			tempvar q_out
			qui gen `q_out' = `q_qST3'
			qui replace `q_out' = `q_vpns' if `q_vpns' != . & `q_qST3' == .
			qui replace `return' = `q_out'
		}
	}
	else if "`acronym'" == "wlrfga" {
		tempvar sex_as_numeric mu sigma ga
		qui {
			gen byte `sex_as_numeric' = .
			replace `sex_as_numeric' = 1 if `sex' == "`male'"
			replace `sex_as_numeric' = 0 if `sex' == "`female'"
			gen `ga' = `gest_age' / 7
			
			gen `mu' = .
			replace `mu' = ///
				3.400617 + (-0.0103163 * `ga' ^ 2) + ///
				(0.0003407 * `ga' ^ 3) + (0.1382809 * `sex_as_numeric') ///
				if `gest_age' < 231
			replace `mu' = ///
				-17.84615 + (-3778.768 * (`ga' ^ -1)) + ///
				(1291.477 * ((`ga' ^ -1) * log(`ga'))) /// 
				if `gest_age' >= 231 & `sex' == "`male'"
			replace `mu' = ///
				-5.542927 + (0.0018926 * (`ga' ^ 3)) + ///
				(-0.0004614 * ((`ga' ^ 3)* log(`ga'))) ///
				if `gest_age' >= 231 & `sex' == "`female'"    
			
			gen `sigma' = .
			replace `sigma' = sqrt(0.3570057) if `gest_age' < 231
			replace `sigma' = 1.01047 + (-0.0080948 * `ga') ///
				if `gest_age' >= 231 & `sex' == "`male'"
			replace `sigma' = 0.6806229 ///
				if `gest_age' >= 231 & `sex' == "`female'"		
		}
		tempvar q p z
		if "`conversion'" == "v2z" | "`conversion'" == "v2p" {
			qui {
				gen double `q' = `input'
				gen double `z' = (`q' - `mu') / `sigma'
				replace `return' = `z'
			}
			if "`conversion'" == "v2p" {
				qui replace `return' = normal(`z')  
			}
		}
		else if "`conversion'" == "z2v" | "`conversion'" == "p2v" {
			qui {
				gen double `z' = `input'
				if "`conversion'" == "p2v" {
					qui replace `z' = invnormal(`input')  
				}
				gen `q' = `z' * `sigma' + `mu'
				replace `return' = `q'
			}
		}
	}
	else if inlist("`acronym'", "ffmfga", "bfpfga", "fmfga") {
		tempvar y_intercept ga_coeff std_dev
		qui {
			replace `check_ga' = 0 if `gest_age' < 38 * 7 | `gest_age' > 42 * 7
			gen `y_intercept' = ///
				cond(`sex' == "`male'" & "`acronym'" == "fmfga", -1134.2, ///
				cond(`sex' == "`male'" & "`acronym'" == "bfpfga", -17.68, ///
				cond(`sex' == "`male'" & "`acronym'" == "ffmfga", -2487.6, ///
				cond(`sex' == "`female'" & "`acronym'" == "fmfga", -840.2, ///
				cond(`sex' == "`female'" & "`acronym'" == "bfpfga", -9.02, ///
				cond(`sex' == "`female'" & "`acronym'" == "ffmfga", -1279, ///
				.z))))))
			gen `ga_coeff' = ///
				cond(`sex' == "`male'" & "`acronym'" == "fmfga", 37.2, ///
				cond(`sex' == "`male'" & "`acronym'" == "bfpfga", 0.69, ///
				cond(`sex' == "`male'" & "`acronym'" == "ffmfga", 139.9, ///
				cond(`sex' == "`female'" & "`acronym'" == "fmfga", 30.7, ///
				cond(`sex' == "`female'" & "`acronym'" == "bfpfga", 0.51, ///
				cond(`sex' == "`female'" & "`acronym'" == "ffmfga", 105.3, ///
				.z))))))
			gen `std_dev' = ///
				cond(`sex' == "`male'" & "`acronym'" == "fmfga", 152.1593, ///
				cond(`sex' == "`male'" & "`acronym'" == "bfpfga", 3.6674, ///
				cond(`sex' == "`male'" & "`acronym'" == "ffmfga", 276.2276, ///
				cond(`sex' == "`female'" & "`acronym'" == "fmfga", 156.8411, ///
				cond(`sex' == "`female'" & "`acronym'" == "bfpfga", 3.9405, ///
				cond(`sex' == "`female'" & "`acronym'" == "ffmfga", 260.621, ///
				.z))))))
		}
		tempvar q p z
		if "`conversion'" == "v2z" | "`conversion'" == "v2p" {
			qui {
				gen double `q' = `input'
				gen double `z' = ///
					(`q' - `y_intercept' - `ga_coeff'*`gest_age'/7) / `std_dev'
				replace `return' = `z'
			}
			if "`conversion'" == "v2p" {
				qui replace `return' = normal(`z')  
			}
		}
		else if "`conversion'" == "z2v" | "`conversion'" == "p2v" {
			qui {
				gen double `z' = `input'
				if "`conversion'" == "p2v" {
					qui replace `z' = invnormal(`input')  
				}
				gen `q' = ///
				  `y_intercept' + `ga_coeff' * `gest_age' / 7 + `z' * `std_dev'
				replace `q' = . if `q' < 0
				replace `return' = `q'
			}
		}
	}
  	qui replace `return' = . if `check_sex' == 0 | `check_ga' == 0
 	restore, not 
end

program Badsyntax_nbs
	di as err "sexcode() option invalid: see {help ig_nbs}"
	exit 198
end
