// Keep here whilst iterating
capture frame change default
// FOR SUBMISSION: 
//	http://fmwww.bc.edu/repec/bocode/s/sscsubmit.html

// Using NBS/VPNS dummy data
capture frame drop nbs_data
frame create nbs_data
frame change nbs_data
do "ig_nbs.ado"
use "datasets_dummy/ig_nbs_vpns_tester.dta", clear

ig_nbs_percentile2value p gest_age sex acronym
rename q_out q_p2v

ig_nbs_zscore2value z gest_age sex acronym
rename q_out q_z2v

ig_nbs_value2percentile measurement gest_age sex acronym
rename p_out v2p

ig_nbs_value2zscore measurement gest_age sex acronym
rename z_out v2z

// Using INTERGROWTH PNG dummy data
capture frame drop png_data
frame create png_data
frame change png_data
do "ig_png.ado"
use "datasets_dummy/ig_png_tester.dta", clear

ig_png_percentile2value p pma_weeks sex acronym
rename q_out q_p2v

ig_png_zscore2value z pma_weeks sex acronym
rename q_out q_z2v

ig_png_value2percentile measurement pma_weeks sex acronym
rename p_out v2p

ig_png_value2zscore measurement pma_weeks sex acronym
rename z_out v2z

// Using WHO dummy data
capture frame drop who_data
frame create who_data
frame change who_data
do "who_gs.ado"
use "datasets_dummy/who_gs_tester.dta", clear

who_gs_percentile2value p xvar sex acronym
rename q_out q_p2v

who_gs_zscore2value z xvar sex acronym
rename q_out q_z2v

who_gs_value2percentile measurement xvar sex acronym
rename p_out v2p

who_gs_value2zscore measurement xvar sex acronym
rename z_out v2z