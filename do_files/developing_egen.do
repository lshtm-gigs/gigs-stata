// Keep here whilst iterating
capture frame change default
// FOR SUBMISSION: 
//	http://fmwww.bc.edu/repec/bocode/s/sscsubmit.html

// Using INTERGROWTH-21st NBS dummy data
capture frame drop nbs_data
frame create nbs_data
frame change nbs_data
use "datasets_dummy/ig_nbs_vpns_tester.dta", clear
do "_gig_nbs.ado"
local acro = "wfga"
qui drop if acronym != "`acro'"
egen test_v2p = ig_nbs(measurement, "`acro'", "v2p"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)
egen test_v2z = ig_nbs(measurement, "`acro'", "v2z"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)
egen test_p2v = ig_nbs(p, "`acro'", "p2v"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)
egen test_z2v = ig_nbs(z, "`acro'", "z2v"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)

// Using INTERGROWTH-21st PNG dummy data
capture frame drop png_data
frame create png_data
frame change png_data
use "datasets_dummy/ig_png_tester.dta", clear
do "_gig_png.ado"
local acro = "lfa"
qui drop if acronym != "`acro'"
egen test_v2p = ig_png(measurement, "`acro'", "v2p"), pma_weeks(pma_weeks) sex(sex) sexcode(m=M, f=F)
egen test_v2z = ig_png(measurement, "`acro'", "v2z"), pma_weeks(pma_weeks) sex(sex) sexcode(m=M, f=F)
egen test_p2v = ig_png(p, "`acro'", "p2v"), pma_weeks(pma_weeks) sex(sex) sexcode(m=M, f=F)
egen test_z2v = ig_png(z, "`acro'", "z2v"), pma_weeks(pma_weeks) sex(sex) sexcode(m=M, f=F)

// Using WHO GS dummy data
capture frame drop who_data
frame create who_data
frame change who_data
use "datasets_dummy/who_gs_tester.dta", clear
do "_gwho_gs.ado"
local acro = "lhfa"
qui drop if acronym != "`acro'"
qui drop acronym
egen double test_v2p = who_gs(measurement, "`acro'", "v2p"), xvar(x_var) sex(sex) sexcode(m=M, f=F)
egen double test_v2z = who_gs(measurement, "`acro'", "v2z"), xvar(x_var) sex(sex) sexcode(m=M, f=F)
egen test_p2v = who_gs(p, "`acro'", "p2v"), xvar(x_var) sex(sex) sexcode(m=M, f=F)
egen test_z2v = who_gs(z, "`acro'", "z2v"), xvar(x_var) sex(sex) sexcode(m=M, f=F)

// Using SGA dummy data
capture frame drop classify_sga
frame create classify_sga
frame change classify_sga
use "datasets_dummy/ig_nbs_vpns_tester.dta", clear
do "_gclassify_sga.ado"
local acro = "wfga"
qui drop if acronym != "`acro'"
qui drop acronym
egen sga = classify_sga(measurement, "`acro'"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)

// Using dummy stunting data
capture frame drop classify_stunting
frame create classify_stunting
frame change classify_stunting
use "datasets_dummy/classify_stunting_tester.dta", clear
do "_gclassify_stunting.ado"
egen stunted = classify_stunting(lenht), ///
    ga_at_birth(ga_at_birth) age_days(age_days) ///
	sex(sex) sexc(m=M, f=F) ///
	lenht_method(len_method) lenhtcode(length=L, height=H)

// Using dummy wasting data
capture frame drop classify_wasting
frame create classify_wasting
frame change classify_wasting
use "datasets_dummy/classify_wasting_tester.dta", clear
do "_gclassify_wasting.ado"
egen wasting = classify_wasting(weight_kg), ///
	lenht(lenht) lenht_method(lenht_method) lenhtc(length=L, height=H) ///
	sex(sex) sexc(m=M, f=F)

// Using dummy wfa data
capture frame drop classify_wfa
frame create classify_wfa
frame change classify_wfa
use "datasets_dummy/classify_wfa_tester.dta", clear
do "_gclassify_wfa.ado"
egen weight_for_age = classify_wfa(weight_kg), ///
	ga_at_birth(ga_at_birth) age_days(age_days) ///
	sex(sex) sexc(m=M, f=F)