// Keep here whilst iterating
capture frame change default
// FOR SUBMISSION: 
//	http://fmwww.bc.edu/repec/bocode/s/sscsubmit.html
capture frame drop nbs_data
frame create nbs_data
frame change nbs_data
use "datasets_dummy/ig_nbs_vpns_tester.dta", clear
// do "_gig_nbs.ado"
local acro = "wlrfga"
qui drop if acronym != "`acro'"
egen test_v2p = ig_nbs(measurement, "`acro'", "v2p"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)
egen test_v2z = ig_nbs(measurement, "`acro'", "v2z"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)
egen test_p2v = ig_nbs(p, "`acro'", "p2v"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)
egen test_z2v = ig_nbs(z, "`acro'", "z2v"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)

// // Using INTERGROWTH PNG dummy data
capture frame drop png_data
frame create png_data
frame change png_data
use "datasets_dummy/ig_png_tester.dta", clear
// do "_gig_png.ado"
local acro = "lfa"
qui drop if acronym != "`acro'"
egen test_v2p = ig_png(measurement, "`acro'", "v2p"), pma_weeks(pma_weeks) sex(sex) sexcode(m=M, f=F)
egen test_v2z = ig_png(measurement, "`acro'", "v2z"), pma_weeks(pma_weeks) sex(sex) sexcode(m=M, f=F)
egen test_p2v = ig_png(p, "`acro'", "p2v"), pma_weeks(pma_weeks) sex(sex) sexcode(m=M, f=F)
egen test_z2v = ig_png(z, "`acro'", "z2v"), pma_weeks(pma_weeks) sex(sex) sexcode(m=M, f=F)
