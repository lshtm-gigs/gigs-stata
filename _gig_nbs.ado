capture program drop _gig_nbs
capture program drop Badsexvar_nbs
capture program drop Badsyntax_nbs
*! version 0.3.0 (SJxx-x: dmxxxx)
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
	capture assert inlist("`conversion'", "v2c", "v2z", "c2v", "z2v")
	if _rc {
		di as text "`conversion'" as error " is an invalid chart code. The " /*
		*/ as error "only valid choices are " as text "v2c, v2z, c2v," as /*
		*/ error " or " as text "z2v" as error "."
		exit 198
	}
	
	syntax [if] [in], GEST_days(varname numeric) sex(varname) SEXCode(string) /*
		*/ [BY(string)]
	
	if `"`by'"' != "" {
		_egennoby ig_nbs() `"`by'"'
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
 			Badsyntax_nbs
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			Badsyntax_nbs
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else Badsyntax_nbs

    marksample touse

	local sex_type = "`:type `sex''"
	if !regexm("`sex_type'", "byte|str|int") {
		Badsexvar_nbs
	}
	else {
		local sex_was_str = .
		if regexm("`sex_type'", "byte|int") {
			local sex_was_str = 0
			qui tostring(`sex'), replace
		}
	}

	qui generate `type' `return' = .
	tempvar check_ga check_sex
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
		qui gen double nbsMSNT_gest_age = `gest_days'
		qui gen byte nbsMSNT_sex = 1 if `sex' == "`male'"
		qui replace nbsMSNT_sex = 0 if `sex' == "`female'"
		
		// Append, then interpolate in Mata (see gigs_ipolate_coeffs.ado)
		qui {
			tempvar n appended need_interp
			qui append using "`filepath'", gen(`appended')
			gen `n' = _n
			gen `need_interp' = 0
			replace `need_interp' = `appended' == 0
			mata gigs_ipolate_coeffs(
				"nbsMSNT_gest_age", ///
				"nbsMSNT_sex", ///
				"nbsMSNT_mu nbsMSNT_sigma nbsMSNT_nu nbsMSNT_tau", ///
				"`n'", ///
				"`need_interp'", ///
				"`appended'" ///
			)
			drop if `appended' == 1
			tempvar mu sigma nu tau
			gen double `mu' = nbsMSNT_mu
			gen double `sigma' = nbsMSNT_sigma
			gen double `nu' = nbsMSNT_nu
			gen double `tau' = nbsMSNT_tau
			drop nbsMSNT_gest_age nbsMSNT_sex nbsMSNT_mu nbsMSNT_sigma ///
				nbsMSNT_nu nbsMSNT_tau `interp'	
		}
		
		tempvar sex_as_numeric median gest_age_weeks vpns_median vpns_stddev
		qui {
			generate `sex_as_numeric' = 1 if `sex' == "`male'"
			replace `sex_as_numeric' = 0 if `sex' == "`female'"
			generate `gest_age_weeks' = .
			replace `gest_age_weeks' = `gest_days' / 7  if `gest_days' >= 168
				
			gen double `vpns_median' = .
			replace `vpns_median' = ///
				-7.00303 + (1.325911 * (`gest_age_weeks' ^ 0.5)) + ///
				(0.0571937 * `sex_as_numeric') if "`acronym'" == "wfga"
			replace `vpns_median' = ///
				1.307633 + 1.270022 * `gest_age_weeks' + ///
				0.4263885 * `sex_as_numeric' if "`acronym'" == "lfga"
			replace `vpns_median' = 0.7866522 + 0.887638 * `gest_age_weeks' ///
				+ 0.2513385 * `sex_as_numeric' if "`acronym'" == "hcfga"
			gen double `vpns_stddev' = .
			replace `vpns_stddev' = sqrt(0.0373218) if "`acronym'" == "wfga"
			replace `vpns_stddev' = sqrt(6.7575430) if "`acronym'" == "lfga"
			replace `vpns_stddev' = sqrt(2.4334810) if "`acronym'" == "hcfga"
		}

		if "`conversion'" == "v2c" | "`conversion'" == "v2z" {
			tempvar q cdf p_pST3 p_out
			qui {
				gen double `q' = `input'
				gen double `cdf' = ///
					2 * t(`tau', `nu' * (`q' - `mu') / `sigma') ///
					if `q' < `mu'		
				replace `cdf' = 1 + 2 * `nu' ^ 2 * ///
					(t(`tau', (`q' - `mu') / (`sigma' * `nu')) - 0.5) ///
					if `q' >= `mu' 
				generate double `p_pST3' = `cdf' / (1 + `nu' ^ 2)
			
				tempvar p_vpns 
				generate double `p_vpns' = ///
					normal((`q' - `vpns_median') / `vpns_stddev')
				replace `p_vpns' = ///
					normal((log(`q') - `vpns_median') / `vpns_stddev') ///
						if "`acronym'" == "wfga"
				
				gen double `p_out' = `p_pST3' if `p_pST3' != .
				replace `p_out' = `p_vpns' if `p_vpns' != . & `p_pST3' == .
				replace `return' = `p_out'
			}
			if "`conversion'" == "v2z" {
				qui replace `return' = invnormal(`p_out')
			}
		}
		else {
			tempvar p
			if "`conversion'" == "c2v" {
				qui gen double `p' = `input'
			}
			else if "`conversion'" == "z2v" {
				qui gen double `p' = normal(`input')
			}
					
			tempvar q_qST3
			qui {
				gen double `q_qST3' = `mu' + (`sigma' / `nu') * ///
					invt(`tau', `p' * (1 + `nu' ^ 2) / 2) ///
					if `p' < (1 / (1 + `nu' ^ 2))
				replace `q_qST3' = `mu' + (`sigma' * `nu') * ///
					invt(`tau', (`p' * (1 + `nu'^2) - 1) / (2 * `nu'^2) + 0.5) ///
					if `p' >= (1 / (1 + `nu'^2))
			}
			
			tempvar z q_vpns
			qui {
				gen double `z' = invnormal(`p')
				gen double `q_vpns' = ///
					`vpns_median' + invnormal(`p') * `vpns_stddev'
				replace `q_vpns' = exp(`vpns_median' + ///
					(invnormal(`p') * `vpns_stddev')) if "`acronym'" == "wfga"
			} 		
			tempvar q_out
			qui gen double `q_out' = `q_qST3'
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
			gen double `ga' = `gest_days' / 7
			
			gen double `mu' = .
			replace `mu' = ///
				3.400617 + (-0.0103163 * `ga' ^ 2) + ///
				(0.0003407 * `ga' ^ 3) + (0.1382809 * `sex_as_numeric') ///
				if `gest_days' < 231
			replace `mu' = ///
				-17.84615 + (-3778.768 * (`ga' ^ -1)) + ///
				(1291.477 * ((`ga' ^ -1) * log(`ga'))) /// 
				if `gest_days' >= 231 & `sex' == "`male'"
			replace `mu' = ///
				-5.542927 + (0.0018926 * (`ga' ^ 3)) + ///
				(-0.0004614 * ((`ga' ^ 3)* log(`ga'))) ///
				if `gest_days' >= 231 & `sex' == "`female'"
			
			gen double `sigma' = .
			replace `sigma' = sqrt(0.3570057) if `gest_days' < 231
			replace `sigma' = 1.01047 + (-0.0080948 * `ga') ///
				if `gest_days' >= 231 & `sex' == "`male'"
			replace `sigma' = 0.6806229 ///
				if `gest_days' >= 231 & `sex' == "`female'"
		}
		tempvar q p z
		if "`conversion'" == "v2z" | "`conversion'" == "v2c" {
			qui {
				gen double `q' = `input'
				gen double `z' = (`q' - `mu') / `sigma'
				replace `return' = `z'
			}
			if "`conversion'" == "v2c" {
				qui replace `return' = normal(`z')  
			}
		}
		else if "`conversion'" == "z2v" | "`conversion'" == "c2v" {
			qui {
				gen double `z' = `input'
				if "`conversion'" == "c2v" {
					qui replace `z' = invnormal(`input')  
				}
				gen double `q' = `z' * `sigma' + `mu'
				replace `return' = `q'
			}
		}
	}
	else if inlist("`acronym'", "ffmfga", "bfpfga", "fmfga") {
		tempvar mu sigma
		qui generate `check_ga' = 0 if `gest_days' < 266 | `gest_days' > 294
		
		// Find reference GAMLSS coeffecients
		local basename = "ig_nbsNORMBODYCOMP.dta"
		qui findfile "`basename'"
		local filepath = "`r(fn)'"
		tempvar n
		gen `n' = _n
		
		// Initialise new variables for merging
		foreach var in sexacronym intercept x x2 x3 sigma {
			capture confirm new var nbsBC_`var'
			if _rc {
				di as error "{bf:nbsMSNT_`var'} is used by ig_nbs() - rename" /* 
				*/ as error " your variable."
				exit 110
			}
		}
		
		qui {
		    gen nbsBC_sexacronym = "`acronym'_M" if `sex' == "`male'"
            replace nbsBC_sexacronym = "`acronym'_F" if `sex' == "`female'"
			merge m:1 nbsBC_sexacronym using "`filepath'", ///
				nogenerate keep(1 3)
			sort `n'
			gen double `mu' = ///
				nbsBC_intercept + ///
				nbsBC_x * `gest_days' + ///
				nbsBC_x2 * (`gest_days' ^ 2) + ///
				nbsBC_x3 * (`gest_days' ^ 3)
			gen double `sigma' = nbsBC_sigma
			drop nbsBC_* `n'
		}
		tempvar q p z
		if "`conversion'" == "v2z" | "`conversion'" == "v2c" {
			qui {
				gen double `q' = `input'
				gen double `z' = (`q' - `mu') / `sigma'
				replace `return' = `z'
			}
			if "`conversion'" == "v2c" {
				qui replace `return' = normal(`z')  
			}
		}
		else if "`conversion'" == "z2v" | "`conversion'" == "c2v" {
			qui {
				gen double `z' = `input'
				if "`conversion'" == "c2v" {
					qui replace `z' = invnormal(`input')  
				}
				gen double `q' = `mu' + (`z' * `sigma')
				replace `q' = . if `q' < 0
				replace `return' = `q'
			}
		}
	}
	qui {
		cap gen `check_ga' = `gest_days' >= 168 & `gest_days' <= 300
        	gen `check_sex' = `sex' == "`male'" | `sex' == "`female'"
		if "`sex_was_str'" == "0" destring(`sex'), replace
		replace `return' = . ///
  	        if  `check_ga' == 0 | `check_sex' == 0 | `touse' == 0
    }
 	restore, not 
end

program Badsexvar_nbs
	di as err "sex() option should be a byte, int or str variable: see " /*
	       */ "{help ig_nbs}"
	exit 109
end

program Badsyntax_nbs
	di as err "sexcode() option invalid: see {help ig_nbs}"
	exit 198
end
