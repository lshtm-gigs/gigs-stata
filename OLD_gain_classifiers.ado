/*
Classify size for gestational age, stunting, wasting and weight for age using 
WHO Growth Standards and the INTERGROWTH-21st standards as appropriate.
*/
*! Author: Simon Parker
*! version 0.0.1	17/02/2023
capture program drop classify_sga
capture program drop classify_stunting
capture program drop classify_wasting
capture program drop classify_wfa

program define classify_sga
	args measurement gest_age sex acronym
	ig_nbs_value2percentile `measurement' `gest_age' `sex' `acronym'
	rename p_out p_SGAtemp
	generate sga = "AGA"
	replace sga = "SGA" if p_SGAtemp <= 0.1
	replace sga = "LGA" if p_SGAtemp >= 0.9
	replace sga = "SGA(<3)" if p_SGAtemp < 0.03
	drop p_SGAtemp
end

program define classify_stunting
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

program define classify_wasting
	args weight_kg lenht_cm sex lenht_method
	
	tempvar acronym xvar
	capture generate double `xvar' = `lenht_cm'
	capture generate `acronym' = ""
	capture replace `acronym' = "wfh" if `lenht_method' == "H"
	capture replace `acronym' = "wfl" if `lenht_method' == "L"
	who_gs_value2zscore `weight_kg' `xvar' `sex' `acronym'
	
 	tempvar z_scores
 	generate `z_scores' = z_out
	drop z_out
	generate str8 wasting = ""
	replace wasting = "wasting" if `z_scores' <= -2
	replace wasting = "wasting_severe" if `z_scores' <= -3
	replace wasting = "normal" if abs(`z_scores') < 2
	replace wasting = "overweight" if `z_scores' >= 2
	replace wasting = "implausible" if abs(`z_scores') > 5
	replace wasting = "" if `acronym' == ""
	drop xvar
end

program define classify_wfa
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
 	generate `z_scores' = z_PNG if (`pma_weeks' >= 27 & `pma_weeks' <= 64) & `ga_at_birth' >= 26 & `ga_at_birth' < 37 & age_days / 7 > 64,
	replace `z_scores' = z_WHO if `z_scores' == .
	generate str8 wasting = ""
	replace wasting = "underweight" if `z_scores' <= -2
	replace wasting = "underweight_severe" if `z_scores' <= -3
	replace wasting = "normal" if abs(`z_scores') < 2
	replace wasting = "overweight" if `z_scores' >= 2
	replace wasting = "implausible" if abs(`z_scores') > 5
	drop xvar acronym
end
