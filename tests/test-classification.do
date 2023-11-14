local test_data "tests/inputs"

// Test SGA
cap frame drop classify_sga
cap frame create classify_sga
cap frame change classify_sga
use "`test_data'/tester_sga.dta", clear
egen sga = classify_sga(weight), gest_days(gestage) sex(psex) sexcode(m=M, f=F)
egen sga_sev = classify_sga(weight), gest_days(gestage) ///
	sex(psex) sexcode(m=M, f=F) severe
local SGA = 1
gen equal = sum(sga == sga_exp)
if equal[_N] != _N local SVN = 0
replace equal = sum(sga_sev == sga_sev_exp)
if equal[_N] != _N local SVN = 0

// Test SVN
cap frame drop classify_svn
cap frame create classify_svn
cap frame change classify_svn
use "`test_data'/tester_svn.dta", clear
egen svn = classify_svn(weight_kg), gest_days(gest_age) sex(sex) ///
    sexcode(m=M, f=F)
local SVN = 1
gen equal = sum(svn == svn_exp)
if equal[_N] != _N local SVN = 0

// Test stunting
capture frame drop classify_stunting
frame create classify_stunting
frame change classify_stunting
use "`test_data'/tester_stunting.dta", clear
egen stunting = classify_stunting(lenht), ///
    gest_days(ga_at_birth) age_days(age_days) ///
	sex(psex) sexc(m=M, f=F)
egen stunting_out = classify_stunting(lenht), ///
    gest_days(ga_at_birth) age_days(age_days) ///
	sex(psex) sexc(m=M, f=F) outliers
local Stunting = 1
gen equal = sum(stunting == stunting_exp)
if equal[_N] != _N local Stunting = 0
replace equal = sum(stunting_out == stunting_out_exp)
if equal[_N] != _N local Stunting = 0

// Test wasting
capture frame drop classify_wasting
frame create classify_wasting
frame change classify_wasting
use "`test_data'/tester_wasting.dta", clear
egen wasting = classify_wasting(wght_kg), lenht(lenht) gest(ga_days) ///
	age_days(chron_age) sex(psex) sexc(m=M, f=F)
egen wasting_out = classify_wasting(wght_kg), lenht(lenht) gest(ga_days) ///
	age_days(chron_age) sex(psex) sexc(m=M, f=F) outliers
local Wasting = 1
gen equal = sum(wasting == wasting_exp)
if equal[_N] != _N local Wasting = 0
replace equal = sum(wasting_out == wasting_out_exp)
if equal[_N] != _N local Wasting = 0

// Test weight-for-age
capture frame drop classify_wfa
frame create classify_wfa
frame change classify_wfa
use "`test_data'/tester_wfa.dta", clear
egen wfa = classify_wfa(wght_kg), ///
	gest_days(ga_at_birth) age_days(days_old) ///
	sex(psex) sexc(m=M, f=F)
egen wfa_out = classify_wfa(wght_kg), ///
	gest_days(ga_at_birth) age_days(days_old) ///
	sex(psex) sexc(m=M, f=F) outliers
local WFA = 1
gen equal = sum(wfa == wfa_exp)
if equal[_N] != _N local WFA = 0
replace equal = sum(wfa_out == wfa_out_exp)
if equal[_N] != _N local WFA = 0

cap frame change default 
cap frame drop classify_*
foreach classification in "SGA" "SVN" "Stunting" "Wasting" "WFA" {
	if "`classification'" == "SGA" local name "_gclassify_sga.ado"
	if "`classification'" == "SVN" local name "_gclassify_svn.ado"
	if "`classification'" == "Stunting" local name "_gclassify_stunting.ado"
	if "`classification'" == "Wasting" local name "_gclassify_wasting.ado"
	if "`classification'" == "WFA" local name "_gclassify_wfa.ado"
	if ``classification'' != 1 {
		noi di as err "{bf: `classification' failed.} Refactor `name'".
	}
	else {
		noi di as text "{bf: `classification' passed.}"
	}
}