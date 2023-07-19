local test_data "tests/inputs"

// Test SGA
cap frame drop classify_sga
cap frame create classify_sga
cap frame change classify_sga
use "`test_data'/tester_sga.dta", clear
qui do "_gclassify_sga.ado"
egen sga = classify_sga(weight), gest_age(gestage) sex(psex) sexcode(m=M, f=F)
if inlist(sga == sga_expected, 0) {
	local SGA "0"
}
else {
	local SGA "1"
}

// Test stunting
capture frame drop classify_stunting
frame create classify_stunting
frame change classify_stunting
use "`test_data'/tester_stunting.dta", clear
qui do "_gclassify_stunting.ado"
egen stunted = classify_stunting(lenht), ///
    ga_at_birth(ga_at_birth) age_days(age_days) ///
	sex(psex) sexc(m=M, f=F) ///
	lenht_method(len_method) lenhtcode(length=L, height=H)
if inlist(stunted == stunted_expected, 0) {
	local Stunting "0"
}
else {
	local Stunting "1"
}

// Test wasting
capture frame drop classify_wasting
frame create classify_wasting
frame change classify_wasting
use "`test_data'/tester_wasting.dta", clear
qui do "_gclassify_wasting.ado"
egen wasting = classify_wasting(wght_kg), ///
	lenht(lenht) lenht_method(lenht_meth) lenhtc(length=L, height=H) ///
	sex(psex) sexc(m=M, f=F)
if inlist(wasting == wasting_expected, 0) {
	local Wasting "0"
}
else {
	local Wasting "1"
}

// Test weight-for-age
capture frame drop classify_wfa
frame create classify_wfa
frame change classify_wfa
use "`test_data'/tester_wfa.dta", clear
qui do "_gclassify_wfa.ado"
egen wfa = classify_wfa(wght_kg), ///
	ga_at_birth(ga_at_birth) age_days(days_old) ///
	sex(psex) sexc(m=M, f=F)
if inlist(wfa == wfa_expected, 0) {
	local WFA "0"
}
else {
	local WFA "1"
}

cap frame change default 
cap frame drop classify_*
foreach classification in "SGA" "Stunting" "Wasting" "WFA" {
	if "`classification'" == "SGA" local name "_gclassify_sga.ado"
	if "`classification'" == "Stunting" local name "_gclassify_stunting.ado"
	if "`classification'" == "Wasting" local name "_gclassify_wasting.ado"
	if "`classification'" == "WFA" local name "_gclassify_wfa.ado"
	if ``classification'' != 1 {
		di as err "{bf: `classification' failed.} Refactor `name'"
	}
	else {
		noi di as text "{bf: `classification' passed.}"
	}
}