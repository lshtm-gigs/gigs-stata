// Keep here whilst iterating
capture frame change default
// FOR SUBMISSION: 
//	http://fmwww.bc.edu/repec/bocode/s/sscsubmit.html
capture frame drop nbs_data
frame create nbs_data
frame change nbs_data
use "datasets_dummy/ig_nbs_vpns_tester.dta", clear
do "ig_nbs.ado"
qui drop if acronym != "wfga"
egen test_v2p = ig_nbs(measurement, "wfga", "v2p"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)
egen test_v2z = ig_nbs(measurement, "wfga", "v2z"), gest_age(gest_age) sex(sex) sexcode(m=M, f=F)