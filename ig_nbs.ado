capture program drop _gig_nbs
capture program drop _gtemplate
capture program drop Badsyntax
*! version 0.0.1 (SJxx-x: dmxxxx)
program define _gig_nbs
 	version 16
	preserve

	gettoken type 0 : 0
	gettoken return    0 : 0
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
	
	capture assert inlist("`acronym'", "wfga", "lfga", "hcfga", "ffmfga", /*
	*/ "bfpfga", "fmfga")
	if _rc {
		di as text "`acronym'" as error " is an invalid acronym. The only valid choices are " /*
		*/as text "wfga, lfga, hcfga, ffmfga, bfpfga," as error " or " as text "fmfga" as error"."
		exit 198
	}
	capture assert inlist("`conversion'", "v2p", "v2z", "p2v", "z2v")
	if _rc {
		di as text "`conversion'" as error " is an invalid chart code. The only valid choices are " /*
		*/ as text "v2p, v2z, p2v," as error " or " as text "z2v" as error "."
		exit 198
	}
	
	if `"`by'"' != "" {
		_egennoby zanthro() `"`by'"'
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
 			Badsyntax
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else Badsyntax	

	tempvar check_sex
    generate `check_sex' = `sex' == "`male'" | sex == "`female'"
			
	tempvar check_ga 
	generate `check_ga' = `gest_age' >= 24 * 7 & `gest_age' < 43 * 7	
	if "`acronym'" == "ffmfga" | "`acronym'" == "bfpfga" | "`acronym'" == "fmfga" {
	    replace `check_ga' = `gest_age' >= 38 * 7 & `gest_age' =< 42
	} 
		
	
    tempvar n
	gen `n' = _n
	qui merge 1:1 gest_age sex acronym using "ig_nbs_coeffs.dta", nogenerate keep(1 3)
 	sort `n'
 	drop `n'
	
	tempvar sex_as_numeric median gest_age_weeks vpns_median vpns_stddev
	qui {
		generate `sex_as_numeric' = 1 if `sex' == "`male'"
		replace `sex_as_numeric' = 0 if `sex' == "`female'"
		generate `gest_age_weeks' = .
		replace `gest_age_weeks' = `gest_age' if `gest_age' < 168
		replace `gest_age_weeks' = `gest_age' / 7  if `gest_age' >= 168
			
		generate `vpns_median' = .
		replace `vpns_median' = ///
		-7.00303 + (1.325911 * (`gest_age_weeks' ^ 0.5)) +  (0.0571937 * `sex_as_numeric') ///
		if "`acronym'" == "wfga"
		replace `vpns_median' = ///
		1.307633 + 1.270022 * `gest_age_weeks' +  0.4263885 * `sex_as_numeric' ///
		if "`acronym'" == "lfga"
		replace `vpns_median' = ///
		0.7866522 + 0.887638 * `gest_age_weeks' + 0.2513385 * `sex_as_numeric' ///
		if "`acronym'" == "hcfga"
		generate `vpns_stddev' = .
		replace `vpns_stddev' = sqrt(0.0373218) if "`acronym'" == "wfga"
		replace `vpns_stddev' = sqrt(6.7575430) if "`acronym'" == "lfga"
		replace `vpns_stddev' = sqrt(2.4334810) if "`acronym'" == "hcfga"
	}
	
	qui generate `type' `return' = .
	
	if "`acronym'" == "ffmfga" | "`acronym'" == "bfpfga" | ///
	   "`acronym'" == "fmfga" {
		rep `return' = .
	}
	
	if "`conversion'" == "v2p" | "`conversion'" == "v2z" {
		tempvar q cdf p_pST3
		qui {
		    gen `q' = `input'
			gen `cdf' = 2 * t(tau, nu * (`q' - mu) / sigma) if `q' < mu		
			replace `cdf' = 1 + 2 * nu * nu * (t(tau, (`q' - mu) / (sigma * nu)) - 0.5) if `q' >= mu 
			generate `p_pST3' = `cdf' / (1 + nu * nu)
		}
		drop mu sigma nu tau
		
		qui {
			tempvar p_vpns 
			generate `p_vpns' = normal((`q' - `vpns_median') / `vpns_stddev')
			replace `p_vpns' = normal((log(`q') - `vpns_median') / `vpns_stddev') ///
			if "`acronym'" == "wfga"
		}
		
		tempvar p_out
		qui generate `p_out' = `p_pST3' if `p_pST3' != .
		qui replace `p_out' = `p_vpns' if `p_vpns' != . & `p_pST3' == .
		qui replace `return' = `p_out'
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
			generate `q_qST3' = mu + (sigma / nu) * invt(tau, `p' * (1 + nu^2 ) / 2) if `p' < (1 / (1 + nu^2))
			replace `q_qST3' = mu + (sigma * nu) * invt(tau, (p * (1 + nu^2) - 1) / (2 * nu^2) + 0.5) if `p' >= (1 / (1 + nu^2))
			drop mu sigma nu tau
		}
		
		tempvar z q_vpns
		qui {
			gen `z' = invnormal(`p')
			gen `q_vpns' = `vpns_median' + invnormal(`p') * `vpns_stddev'
			replace `q_vpns' = exp(`vpns_median' + (invnormal(`p') * `vpns_stddev')) if acronym == "wfga"
		} 		
		tempvar q_out
		qui gen `q_out' = `q_qST3'
		qui replace `q_out' = `q_vpns' if `q_vpns' != . & `q_qST3' == .
		qui replace `return' = `q_out'
 	}
	
 	restore, not 
end

program Badsyntax
	di as err "sexcode() option invalid: see {help ig_nbs}"
	exit 198
end
