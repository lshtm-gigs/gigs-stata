/*
Convert z-scores/percentiles to values (and vice versa) in the INTERGROWTH 
Newborn Size Standards + Very Preterm Size Standards.
*/
*! Author: Simon Parker
*! version 0.0.0.12	09/02/2023
capture program drop ig_nbs_getMSNT pST3 qST3
capture program drop ig_nbs_value2percentile 
capture program drop ig_nbs_percentile2value
capture program drop ig_nbs_zscore2value 
capture program drop ig_nbs_value2zscore
capture program drop ig_vpns_eqns

program define ig_nbs_getMSNT
	args gest_age sex acronym
	if (missing(`gest_age') | missing(`sex')  | missing(`acronym')) {
		di "Error - You must specify 3 arguments: "
		di "	gest_age sex acronym"
		exit
	}
	
	// Merge in_nbs_coeffs to get mu/sigma/nu/tau
	tempvar coeffs_dir 
	generate `coeffs_dir' = "datasets_ref"
	local nbs_coeffs_str "xxx\ig_nbs_coeffs.dta" 
	local i = `coeffs_dir'
	global wazfile: subinstr local nbs_coeffs_str "xxx" "`i'"
	
	gen n = _n
	merge 1:1 gest_age sex acronym using "$wazfile", nogenerate keep(1 3)
	sort n
	drop n
end

// pST3 does value2percentile for GAMLSS skew t distribution, type 3
// R equivalent at https://rdrr.io/cran/gamlss.dist/src/R/ST3.R
program define pST3
	args mu sigma nu tau q 
	qui {
		tempvar cdf
		generate `cdf' = 2 * t(`tau', `nu' * (`q' - `mu')/`sigma') if `q' < `mu' 
		replace `cdf' = 1 + 2 * `nu' * `nu' * (t(`tau', (`q' - `mu') / (`sigma' * `nu')) - 0.5) if `q' >= `mu' 
		capture drop p_temp
		generate p_pST3 = `cdf' / (1 + `nu' * `nu')	
	}
	drop mu sigma nu tau
end

// qST3 does percentile2value for GAMLSS skew t distribution, type 3
// R equivalent at https://rdrr.io/cran/gamlss.dist/src/R/ST3.R
program define qST3
	args mu sigma nu tau p
// 	qui {
		capture drop q_qST3
		generate q_qST3 = `mu' + (`sigma' / `nu') * invt(`tau', `p' * (1 + `nu'^2 ) / 2) if `p' < (1 / (1 + `nu'^2))
		replace q_qST3 = `mu' + (`sigma' * `nu') * invt(`tau', (`p' * (1 + `nu'^2) - 1) / (2 * `nu'^2) + 0.5) if `p' >= (1 / (1 + `nu'^2))
// 	}
end

program define ig_vpns_eqns
	args measurement gest_age sex acronym
	tempvar median gest_age_weeks sex_as_numeric
	
	// Generate temporary numeric variables for getting VPNS medians + standards
	// deviations
	generate `sex_as_numeric' = 1 if `sex' == "M"
	replace `sex_as_numeric' = 0 if `sex' == "F"
	generate `gest_age_weeks' = .
	replace `gest_age_weeks' = `gest_age' if `gest_age' < 168
	replace `gest_age_weeks' = `gest_age' / 7  if `gest_age' >= 168
	
	generate vpns_median = .
	replace vpns_median = -7.00303 + (1.325911 * (`gest_age_weeks' ^ 0.5)) +  (0.0571937 * `sex_as_numeric') ///
		if `acronym' == "wfga"
	replace vpns_median =  1.307633 + 1.270022 * `gest_age_weeks' +  0.4263885 * `sex_as_numeric' ///
		if `acronym' == "lfga"
	replace vpns_median = 0.7866522 + 0.887638 * `gest_age_weeks' + 0.2513385 * `sex_as_numeric' ///
		if `acronym' == "hcfga"

	generate vpns_stddev = .
	replace vpns_stddev = sqrt(0.0373218) if `acronym' == "wfga"
	replace vpns_stddev = sqrt(6.7575430) if `acronym' == "lfga"
	replace vpns_stddev = sqrt(2.4334810) if `acronym' == "hcfga"
end

program define ig_nbs_value2percentile
	args measurement gest_age sex acronym

	qui ig_nbs_getMSNT gest_age sex acronym // Retrieve M/S/N/T
	pST3 mu sigma nu tau `measurement' // Then generate p for values with M/S/N/T
	ig_vpns_eqns `measurement' `gest_age' `sex' `acronym'
	
	// Use VPNS medians + standard deviations to get z-scores
	// The z-scores are converted by normal() to percentiles
	tempvar p_vpns 
	generate `p_vpns' = normal((`measurement' - vpns_median) / vpns_stddev)
	replace `p_vpns' = normal((log(`measurement') - vpns_median) / vpns_stddev) if acronym == "wfga"
	
	generate p_out = p_pST3 if p_pST3 != .
	replace p_out = `p_vpns' if p_pST3 == .
	drop vpns_median vpns_stddev p_pST3
end

program define ig_nbs_percentile2value
	args p gest_age sex acronym

	qui ig_nbs_getMSNT gest_age sex acronym // Retrieve MSNT
	qST3 mu sigma nu tau `p' // Then generate p_out for these values
	drop mu sigma nu tau
	ig_vpns_eqns `p' `gest_age' `sex' `acronym'
	
	// Use VPNS medians + standard deviations to get z-scores
	// The z-scores are converted by normal() to percentiles
	tempvar q_vpns 
	generate `q_vpns' = vpns_median + invnormal(`p') * vpns_stddev
	replace `q_vpns' = exp(vpns_median + (invnormal(`p') * vpns_stddev)) if acronym == "wfga"
	
	list
 	generate q_out = q_qST3 if q_qST3 != .
	replace q_out = `q_vpns' if q_qST3 == .
	
	drop vpns_median vpns_stddev q_qST3
end

program define ig_nbs_value2zscore
	args measurement gest_age sex acronym
	ig_nbs_value2percentile `measurement' `gest_age' `sex' `acronym'
	generate z_out = invnormal(p_out)
	drop p_out
end

program define ig_nbs_zscore2value
	args z gest_age sex acronym
	tempvar p_temp
	generate `p_temp' = normal(`z') // Covert z-scores to percentiles
	ig_nbs_percentile2value `p_temp' `gest_age' `sex' `acronym'
end