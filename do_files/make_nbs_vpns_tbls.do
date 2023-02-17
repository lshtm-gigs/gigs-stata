// Load in ig_nbs programs
clear
qui do "ado_files/ig_nbs.ado"

capture program drop make_ig_nbs_zscore_tbl
qui {
	program define make_ig_nbs_zscore_tbl 
		foreach i in -3 -2 -1 0 1 2 3 {
			replace z = `i'
			qui ig_nbs_zscore2value z gest_age sex acronym
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
}

// Remake INTERGROWTH NBS charts
qui {
	// Weight for gestational age
	capture frame drop ig_nbs_tbl_wfga_zscores_m
	frame create ig_nbs_tbl_wfga_zscores_m
	frame change ig_nbs_tbl_wfga_zscores_m
	set obs 133
	generate sex = "M"
	range gest_age 168 300
	generate acronym = "wfga"
	generate z = .
	make_ig_nbs_zscore_tbl z gest_age sex acronym
	replace gest_age = gest_age / 7 
	saveold "outputs/ig_vpns_nbs_wfga_zscores_male.dta", replace version(12)
	
	capture frame drop ig_nbs_tbl_wfga_zscores_f
	frame create ig_nbs_tbl_wfga_zscores_f
	frame change ig_nbs_tbl_wfga_zscores_f
	set obs 133
	generate sex = "F"
	range gest_age 168 300
	generate acronym = "wfga"
	generate z = .
	make_ig_nbs_zscore_tbl z gest_age sex acronym
	replace gest_age = gest_age / 7 
	saveold "outputs/ig_vpns_nbs_wfga_zscores_female.dta", replace version(12)
	
	// Length for gestational age
	capture frame drop ig_nbs_tbl_lfga_zscores_m
	frame create ig_nbs_tbl_lfga_zscores_m
	frame change ig_nbs_tbl_lfga_zscores_m
	set obs 133
	generate sex = "M"
	range gest_age 168 300
	generate acronym = "lfga"
	generate z = .
	make_ig_nbs_zscore_tbl z gest_age sex acronym
	replace gest_age = gest_age / 7 
	saveold "outputs/ig_vpns_nbs_lfga_zscores_male.dta", replace version(12)
	
	capture frame drop ig_nbs_tbl_lfga_zscores_f
	frame create ig_nbs_tbl_lfga_zscores_f
	frame change ig_nbs_tbl_lfga_zscores_f
	set obs 133
	generate sex = "F"
	range gest_age 168 300
	generate acronym = "wfga"
	generate z = .
	make_ig_nbs_zscore_tbl z gest_age sex acronym
	replace gest_age = gest_age / 7 
	saveold "outputs/ig_vpns_nbs_lfga_zscores_female.dta", replace version(12)
	
	// Head circumference for gestational age
	capture frame drop ig_nbs_tbl_hcfga_zscores_m
	frame create ig_nbs_tbl_hcfga_zscores_m
	frame change ig_nbs_tbl_hcfga_zscores_m
	set obs 133
	generate sex = "M"
	range gest_age 168 300
	generate acronym = "hcfga"
	generate z = .
	make_ig_nbs_zscore_tbl z gest_age sex acronym
	replace gest_age = gest_age / 7 
	saveold "outputs/ig_vpns_nbs_hcfga_zscores_male.dta", replace version(12)
	
	capture frame drop ig_nbs_tbl_hcfga_zscores_f
	frame create ig_nbs_tbl_hcfga_zscores_f
	frame change ig_nbs_tbl_hcfga_zscores_f
	set obs 133
	generate sex = "F"
	range gest_age 168 300
	generate acronym = "hcfga"
	generate z = .
	make_ig_nbs_zscore_tbl z gest_age sex acronym
	replace gest_age = gest_age / 7 
	saveold "outputs/ig_vpns_nbs_hcfga_zscores_female.dta", replace version(12)
	
}