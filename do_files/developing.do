// Keep here whilst iterating
capture frame change default
// FOR SUBMISSION: 
//	http://fmwww.bc.edu/repec/bocode/s/sscsubmit.html

// Using INTERGROWTH-21st NBS/VPNS dummy data
// capture frame drop nbs_data
// frame create nbs_data
// frame change nbs_data
do "ig_nbs.ado"
// use "datasets_dummy/ig_nbs_vpns_tester.dta", clear
//
// ig_nbs_percentile2value p gest_age sex acronym
// rename q_out q_p2v
// replace q_p2v = round(q_p2v, .01)
//
// ig_nbs_zscore2value z gest_age sex acronym
// rename q_out q_z2v
// replace q_z2v = round(q_z2v, .01)
//
// ig_nbs_value2percentile measurement gest_age sex acronym
// rename p_out v2p
// replace v2p = round(v2p, .01)
//
// ig_nbs_value2zscore measurement gest_age sex acronym
// rename z_out v2z
// replace v2z = round(v2z, .01)

// classify_sga measurement gest_age sex acronym
//
// // Using INTERGROWTH PNG dummy data
// capture frame drop png_data
// frame create png_data
// frame change png_data
do "ig_png.ado"
// use "datasets_dummy/ig_png_tester.dta", clear
//
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
//
// // Using WHO dummy data
// capture frame drop who_data
// frame create who_data
// frame change who_data
do "who_gs.ado"
// use "datasets_dummy/who_gs_tester.dta", clear

// who_gs_percentile2value p xvar sex acronym
// rename q_out q_p2v
//
// who_gs_zscore2value z xvar sex acronym
// rename q_out q_z2v
//
// who_gs_value2percentile measurement xvar sex acronym
// rename p_out v2p
//
// who_gs_value2zscore measurement xvar sex acronym
// rename z_out v2z

do "gain_classifiers.ado"

// Using dummy stunting data
// capture frame drop stunting_data
// frame create stunting_data
// frame change stunting_data
// use "datasets_dummy/classify_stunting_tester.dta", clear
//
// classify_stunting lenht pma_days ga_at_birth sex len_method

// Using dummy wasting data
// capture frame drop wasting_data
// frame create wasting_data
// frame change wasting_data
// use "datasets_dummy/classify_wasting_tester.dta", clear
//
// classify_wasting weight_kg lenht sex lenht_method

// Using dummy weight-for-age data
capture frame drop wfa_data
frame create wfa_data
frame change wfa_data
use "datasets_dummy/classify_wfa_tester.dta", clear

classify_wfa wght_kg agedays ga_at_birth psex