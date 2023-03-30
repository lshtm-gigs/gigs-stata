capture program drop _gclassify_wfa
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gclassify_wfa
	args weight_kg age_days ga_at_birth sex
	
	tempvar pma_weeks acronym z_out
	generate `pma_weeks' = round(`age_days' / 7)
	generate `acronym' = "wfa"
	generate double `z_out' = .
    
	ig_png_value2zscore `weight_kg' `pma_weeks' `sex' `acronym'
	rename z_out z_PNG
	
	who_gs_value2zscore `weight_kg' `pma_weeks' `sex' `acronym'
	rename z_out z_WHO

 	tempvar z_scores
 	generate `z_scores' = z_PNG if (`pma_weeks' >= 27 & `pma_weeks' <= 64) & ///
		`ga_at_birth' >= 26 & `ga_at_birth' < 37 & age_days / 7 > 64,
	replace `z_scores' = z_WHO if `z_scores' == .
	generate str8 wasting = ""
	replace wasting = "underweight" if `z_scores' <= -2
	replace wasting = "underweight_severe" if `z_scores' <= -3
	replace wasting = "normal" if abs(`z_scores') < 2
	replace wasting = "overweight" if `z_scores' >= 2
	replace wasting = "implausible" if abs(`z_scores') > 5
	drop xvar acronym
end