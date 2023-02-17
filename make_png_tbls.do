// Keep here whilst iterating
capture frame change default


capture program drop make_ig_png_zscore_tbl
program define make_ig_png_zscore_tbl 
	foreach i in -3 -2 -1 0 1 2 3 {
		replace z = `i'
		qui ig_png_zscore2value z pma_weeks sex acronym
		display `i' == -3
		if `i' == -3 { 
			rename q_out SD3neg 
		} 
		if `i' == -2 { 
			rename q_out SD2neg 
		}
		if `i' == -1 { 
			rename q_out SD1neg 
		}
		if `i' == 0 { 
			rename q_out SD0
		}
		if `i' == 1 { 
			rename q_out SD1
		}	
		if `i' == 2 { 
			rename q_out SD2
		}
		if `i' == 3 { 	
			rename q_out SD3
		}
	}
	drop z
end

// Using INTERGROWTH PNG dummy data
capture frame drop png_data
frame create png_data
frame change png_data
use "datasets_dummy/ig_png_tester.dta", clear

// ig_png_percentile2value p pma_weeks sex acronym
// rename q_out q_p2v
//
// ig_png_zscore2value z pma_weeks sex acronym
// rename q_out q_z2v
//
// ig_png_value2percentile measurement pma_weeks sex acronym
// rename p_out v2p
//
// ig_png_value2zscore measurement pma_weeks sex acronym
// rename z_out v2z

// Remake INTERGROWTH PNG charts
qui {
	capture frame drop png_tbl_wfa_zscores_m
	frame create png_tbl_wfa_zscores_m
	frame change png_tbl_wfa_zscores_m
	set obs 38
	generate sex = "M"
	range pma_weeks 27 64
	generate acronym = "wfa"
	generate z = .
	make_ig_png_zscore_tbl
	saveold "outputs/ig_png_wfa_zscores_male.dta", replace version(12)

	capture frame drop png_tbl_wfa_zscores_f
	frame create png_tbl_wfa_zscores_f
	frame change png_tbl_wfa_zscores_f
	set obs 38
	generate sex = "F"
	range pma_weeks 27 64
	generate acronym = "wfa"
	generate z = .
	make_ig_png_zscore_tbl
	saveold "outputs/ig_png_wfa_zscores_female.dta", replace version(12)
	
	capture frame drop png_tbl_lfa_zscores_m
	frame create png_tbl_lfa_zscores_m
	frame change png_tbl_lfa_zscores_m
	set obs 38
	generate sex = "M"
	range pma_weeks 27 64
	generate acronym = "lfa"
	generate z = .
	make_ig_png_zscore_tbl
	saveold "outputs/ig_png_lfa_zscores_male.dta", replace version(12)
	
	capture frame drop png_tbl_lfa_zscores_f
	frame create png_tbl_lfa_zscores_f
	frame change png_tbl_lfa_zscores_f
	set obs 38
	generate sex = "F"
	range pma_weeks 27 64
	generate acronym = "lfa"
	generate z = .
	make_ig_png_zscore_tbl
	saveold "outputs/ig_png_lfa_zscores_female.dta", replace version(12)
	
	capture frame drop png_tbl_hcfa_zscores_m
	frame create png_tbl_hcfa_zscores_m
	frame change png_tbl_hcfa_zscores_m
	set obs 38
	generate sex = "M"
	range pma_weeks 27 64
	generate acronym = "hcfa"
	generate z = .
	make_ig_png_zscore_tbl
	saveold "outputs/ig_png_hcfa_zscores_male.dta", replace version(12)
	
	capture frame drop png_tbl_hcfa_zscores_f
	frame create png_tbl_hcfa_zscores_f
	frame change png_tbl_hcfa_zscores_f
	set obs 38
	generate sex = "F"
	range pma_weeks 27 64
	generate acronym = "hcfa"
	generate z = .
	make_ig_png_zscore_tbl
	saveold "outputs/ig_png_hcfa_zscores_female.dta", replace version(12)
}

// Percentiles
// 	capture frame drop png_tbl_percentiles_m
// 	frame create png_tbl_percentiles_m
// 	frame change png_tbl_percentiles_m
// 	set obs 37
// 	generate sex = "M"
// 	range pma_weeks 28 64
// 	generate acronym = "wfa"
// 	generate p = .
// 	replace p = .03
// 	ig_png_percentile2value p pma_weeks sex acronym
// 	rename q_out P03
//	
// 	saveold "ig_png_wfa_percentiles_male.dta", replace version(12)