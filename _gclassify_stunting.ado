capture program drop _gclassify_stunting
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gclassify_stunting
	args lenht_cm age_days ga_at_birth sex lenht_method
	tempvar lenht_cm2
	generate `lenht_cm2' = `lenht_cm'
	replace `lenht_cm2' = `lenht_cm' - 0.7 if `age_days' >= 731 & `lenht_method' == "L"
	replace `lenht_cm2' = `lenht_cm' + 0.7 if `age_days' < 731 & `lenht_method' == "H"
	list `lenht_cm' `lenht_cm2'
	tempvar z_scores pma_weeks acroynm_png acronym_who
		
	generate `pma_weeks' = `age_days' / 7
	generate `acroynm_png' = "lfa"	
	ig_png_value2zscore `lenht_cm2' `pma_weeks' `sex' `acroynm_png'
	rename z_out z_PNG
	
	generate xvar = `age_days'
	capture generate sex = `sex'
	generate acronym = "lhfa"
	who_gs_value2zscore `lenht_cm2' xvar sex acronym
	drop xvar sex acronym
	rename z_out z_WHO
	
	generate `z_scores' = z_WHO
	replace `z_scores' = z_PNG if `ga_at_birth' >= 26 & `ga_at_birth' < 37 & `age_days' / 7 > 64
	generate str8 stunting = "."
	replace stunting = "implausible" if `z_scores' < -6
	replace stunting = "stunting" if `z_scores' <= -2
	replace stunting = "stunting_severe" if `z_scores' <= -3
	replace stunting = "normal" if `z_scores' > -2
	replace stunting = "implausible" if `z_scores' > 6
	replace stunting = "." if `z_scores' == .
	drop z_PNG z_WHO
end