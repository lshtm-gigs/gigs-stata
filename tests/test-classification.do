local test_gigs_classification = "tests/outputs/gigs_classification"
cap mkdir "`test_gigs_classification'"

// Test gigs_classify_growth
cap frame drop classify_growth
cap frame create classify_growth
cap frame change classify_growth
use "life6mo", clear
tostring id, replace
gigs_classify_growth all, ///
	gest_days(gestage) age_days(age_days) sex(sex) sexc(m=1, f=2) ///
	weight_kg(wt_kg) lenht_cm(len_cm) headcirc_cm(headcirc_cm) id(id)

local outpath = "`test_gigs_classification'/gigs_classification.dta"
save `outpath', replace	