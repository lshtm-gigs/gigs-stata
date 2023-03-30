capture program drop _gclassify_wasting
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gclassify_wasting
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