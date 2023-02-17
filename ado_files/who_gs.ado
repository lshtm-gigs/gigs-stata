/*
Convert z-scores/percentiles to values (and vice versa) in the WHO Child Growth 
Standards.
*/
*! version 0.0.0.1	13/02/2023
capture program drop who_gs_getLMS
capture program drop who_gs_value2percentile who_gs_percentile2value
capture program drop who_gs_zscore2value 
capture program drop who_gs_value2zscore

program define who_gs_getLMS
	args xvar sex acronym
		
	// Merge who_gs_coeffs to get lambda/mu/sigma
	tempvar coeffs_dir 
	generate `coeffs_dir' = "datasets_ref"
	local who_coeffs_str "xxx\who_gs_coeffs.dta" 
	local i = `coeffs_dir'
	global wazfile: subinstr local who_coeffs_str "xxx" "`i'"
	
	gen n = _n
	merge 1:1 xvar sex acronym using "$wazfile", nogenerate keep(1 3)
	sort n
	drop n
end

program define who_gs_value2zscore
	args measurement xvar sex acronym

	qui who_gs_getLMS xvar sex acronym // Retrieve L/M/S
	
	// Use LMS to get z-scores
	tempvar _z 
	generate `_z'  = (abs((`measurement'  / M) ^ L) - 1) / (S * L)
	replace `_z' = log(`measurement' / M) / S if L == 0
		
	// Deal with z-scores outside -3 to 3 bounds
	tempvar _sd3neg _sd2neg _sd2pos _sd3pos
	generate `_sd2pos' = M * (1 + L * S * 2) ^ (1/L)
	generate `_sd3pos' = M * (1 + L * S * 3) ^ (1/L)
	replace `_z' = 3 + (`measurement' - `_sd3pos') / (`_sd3pos' - `_sd2pos') if `_z' > 3
	
	generate `_sd3neg' = M * (1 + L * S * -3) ^ (1/L)
	generate `_sd2neg' = M * (1 + L * S * -2) ^ (1/L)
 	replace `_z' = -3 + (`measurement' - `_sd3neg') / (`_sd2neg' - `_sd3neg') if `_z' < -3
	generate z_out = `_z'
	drop L M S
end

program define who_gs_zscore2value
	args z xvar sex acronym

	qui who_gs_getLMS xvar sex acronym // Retrieve L/M/S
	
	// Use LMS to get z-scores
	tempvar _q 
	generate `_q'  = ((`z' * S * L + 1) ^ (1 / L)) * M
	replace `_q' = M * exp(S * `z') if L == 0
		
	// Deal with z-scores outside -3 to 3 bounds
	tempvar _sd3neg _sd2neg _sd2pos _sd3pos
	generate `_sd2pos' = M * (1 + L * S * 2) ^ (1/L)
	generate `_sd3pos' = M * (1 + L * S * 3) ^ (1/L)
	replace `_q' = (`z' - 3) * (`_sd3pos' - `_sd2pos') + `_sd3pos' if `z' > 3
	
	generate `_sd3neg' = M * (1 + L * S * -3) ^ (1/L)
	generate `_sd2neg' = M * (1 + L * S * -2) ^ (1/L)
	replace `_q' = (`z' + 3) * (`_sd2neg' - `_sd3neg') + `_sd3neg' if `z' < -3
	generate q_out = `_q'
	drop L M S
end

program define who_gs_value2percentile
	args measurement gest_age sex acronym
  	who_gs_value2zscore `measurement' `xvar' `sex' `acronym'
 	generate p_out = normal(z_out)
 	drop z_out
end

program define who_gs_percentile2value
 	args p xvar sex acronym
 	tempvar z_temp
 	generate `z_temp' = invnormal(`p') // Covert z-scores to percentiles
 	who_gs_zscore2value `z_temp' `xvar' `sex' `acronym'
end