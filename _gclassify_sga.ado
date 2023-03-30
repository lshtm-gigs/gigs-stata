capture program drop _gclassify_sga
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gclassify_sga
	args measurement gest_age sex acronym
	ig_nbs_value2percentile `measurement' `gest_age' `sex' `acronym'
	rename p_out p_SGAtemp
	generate sga = "AGA"
	replace sga = "SGA" if p_SGAtemp <= 0.1
	replace sga = "LGA" if p_SGAtemp >= 0.9
	replace sga = "SGA(<3)" if p_SGAtemp < 0.03
	drop p_SGAtemp
end