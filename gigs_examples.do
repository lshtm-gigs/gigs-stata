use life6mo
list in f/10, noobs abbreviate(10) sep(10)

local 37weeks 7 * 37

gen agedays = pma - gestage
egen double waz_who = who_gs(meaninfwgt/1000, "wfa", "v2z") ///
    if gestage >= `37weeks' & agedays > 0, ///
	xvar(agedays) sex(sex) sexcode(m=1, f=2)
drop agedays
list  in f/100 if gestage > 259, noobs sep(10)

egen double waz_nbs = ig_nbs(meaninfwgt/1000, "wfga", "v2z") ///
	if agedays == 0, ///
	gest_days(gestage) sex(sex) sexcode(m=1, f=2)

gen pma_weeks = pma / 7
gen pma_weeks_floored = floor(pma / 7)
egen double waz_png = ig_png(meaninfwgt/1000, "wfa", "v2z") ///
	if gestage < `37weeks' & agedays > 0, ///
	xvar(pma_weeks_floored) sex(sex) sexcode(m=1, f=2)
drop pma_weeks pma_weeks_floored

gen double waz = waz_who if gestage > `37weeks'
replace waz = waz_png if gestage < `37weeks'
replace waz = waz_nbs if agedays == 0

list gestage pma visitweek waz_* waz in f/10, noobs sep(10)
drop waz_*

gen preterm = gestage < `37weeks'
collapse waz, by(visitweek preterm)
line waz visitweek if preterm == 0 || line waz visitweek if preterm == 1 ||, ///
	title("WAZ in term/preterm infants in the LIFE study") ///
	xtitle("Visit week") ///
	ytitle("WAZ") ///
	xlabel(0 1 2 4 6 10 14 18 26) ///
	legend(label(1 "Term") label(2 "Preterm")) ///
	scheme(sj)
graph export "gigs_fig1.pdf"

use life6mo, clear
drop if visitweek != 0
egen sga = classify_sga(meaninfwgt/1000), ///
	gest_age(gestage) sex(sex) sexcode(m=1, f=2)
gen preterm = "Preterm" if gestage < `37weeks'
replace preterm = "Term" if gestage >= `37weeks'
graph bar (count), over(sga) by(preterm, ///
    title("Size-for-GA category counts by term status")) ///
	ytitle("Frequency") ///
	scheme(sj)
graph export "gigs_fig2.pdf"