/*
Convert z-scores/percentiles to values (and vice versa) in the INTERGROWTH-21st 
Standards for Post-natal Growth of Preterm Infants.
*/
*! Author: Simon Parker
*! version 0.0.0.27	10/02/2023
capture program drop ig_png_eqns
capture program drop ig_png_value2percentile
capture program drop ig_png_percentile2value
capture program drop ig_png_zscore2value
capture program drop ig_png_value2zscore

program define ig_png_eqns
	args pma_weeks sex acronym
	tempvar sex_as_numeric
	
	// Generate temporary numeric variables for getting PNG medians + standards
	// deviations
	generate `sex_as_numeric' = 1 if `sex' == "M"
	replace `sex_as_numeric' = 0 if `sex' == "F"
	replace `sex_as_numeric' = 0.5 if `sex' == "U"
	
	generate png_median = .
	replace png_median = 2.591277 - (0.01155 * (`pma_weeks' ^ 0.5)) - (2201.705 * (`pma_weeks' ^ -2)) + (0.0911639 * `sex_as_numeric') ///
		if `acronym' == "wfa"
	replace png_median = 4.136244 - (547.0018 * (`pma_weeks' ^ -2)) + 0.0026066 * `pma_weeks' + 0.0314961 * `sex_as_numeric' ///
		if `acronym' == "lfa"
	replace png_median = 55.53617 - (852.0059 * (`pma_weeks' ^ -1)) + 0.7957903 * `sex_as_numeric' ///
		if `acronym' == "hcfa"

	generate png_stddev = .
	replace png_stddev = 0.1470258 + 505.92394 / `pma_weeks' ^ 2 - 140.0576 / (`pma_weeks' ^ 2) * log(`pma_weeks') if ///
		`acronym' == "wfa"
	replace png_stddev = 0.050489 + (310.44761 * (`pma_weeks' ^ -2)) - (90.0742 * (`pma_weeks' ^ -2)) * log(`pma_weeks') if ///
		`acronym' == "lfa"
	replace png_stddev = 3.0582292 + (3910.05 * (`pma_weeks' ^ -2)) - 180.5625 * `pma_weeks' ^ -1 ///
		if `acronym' == "hcfa"
end

program define ig_png_value2percentile, rclass
	args measurement pma_weeks sex acronym
	ig_png_eqns `pma_weeks' `sex' `acronym'
	
	// Use VPNS medians + standard deviations to get z-scores
	// The z-scores are converted by normal() to percentiles
	tempvar p_logarithmic p_linear p_out
	generate `p_logarithmic' = normal((log(`measurement') - png_median) / png_stddev)
	generate `p_linear' = normal((`measurement' - png_median) / png_stddev) if `acronym' == "hcfa"
	
	generate p_out = .
	replace p_out = `p_logarithmic' if `acronym' != "hcfa" & `pma_weeks' >= 27 & `pma_weeks' <= 64
	replace p_out = `p_linear' if `acronym' == "hcfa" & `pma_weeks' >= 27 & `pma_weeks' <= 64
	drop png_median png_stddev
end

program define ig_png_value2zscore
	args measurement pma_weeks sex acronym
	ig_png_value2percentile `measurement' `pma_weeks' `sex' `acronym'
	generate z_out = invnormal(p_out)
	drop p_out
end

program define ig_png_percentile2value
	args p pma_weeks sex acronym
	ig_png_eqns `pma_weeks' `sex' `acronym'
	
	display `p' invnormal(`p')
	// Use VPNS medians + standard deviations to get z-scores
	// The z-scores are converted by normal() to percentiles
	generate q_out = exp(png_median + (invnormal(`p') * png_stddev)) if acronym != "hcfa" ///
		& `pma_weeks' >= 27 & `pma_weeks' <= 64
	replace q_out = png_median + invnormal(`p') * png_stddev if acronym == "hcfa" ///
		& `pma_weeks' >= 27 & `pma_weeks' <= 64
	drop png_median png_stddev
end

program define ig_png_zscore2value
	args z pma_weeks sex acronym
	tempvar p_temp
	generate `p_temp' = normal(`z') // Covert z-scores to percentiles
	ig_png_percentile2value `p_temp' `pma_weeks' `sex' `acronym'
end

