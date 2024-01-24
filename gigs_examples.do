use life6mo
gen agedays = pma - gestage
local 37weeks 7 * 37
list in f/10, noobs abbreviate(10) sep(10)

egen double waz_nbs = ig_nbs(meaninfwgt/1000, "wfga", "v2z") ///
    if agedays == 0, ///
    gest_days(gestage) sex(sex) sexcode(m=1, f=2)

egen double waz_who = who_gs(meaninfwgt/1000, "wfa", "v2z") ///
    if agedays > 0 & gestage >= `37weeks', ///
    xvar(agedays) sex(sex) sexcode(m=1, f=2)

gen pma_weeks = pma / 7
gen pma_weeks_floored = floor(pma / 7)
egen double waz_png = ig_png(meaninfwgt/1000, "wfa", "v2z") ///
    if gestage < `37weeks' & agedays > 0, ///
    xvar(pma_weeks_floored) sex(sex) sexcode(m=1, f=2)
drop pma_weeks pma_weeks_floored

gen double waz = waz_who if gestage > `37weeks'
replace waz = waz_png if gestage < `37weeks'
replace waz = waz_nbs if agedays == 0

list visitweek gestage pma waz_* waz in f/10, noobs sep(10)
drop waz_*

gen preterm = gestage < `37weeks'
collapse waz, by(visitweek preterm)
line waz visitweek if preterm == 0 || line waz visitweek if preterm == 1 ||, ///
    title("WAZ in term/preterm infants in the LIFE study") ///
    xtitle("Visit week") ///
    ytitle("Weight-for-age z-score (WAZ)") ///
    xlabel(0 1 2 4 6 10 14 18 26) ///
    legend(label(1 "Term") label(2 "Preterm")) ///
    scheme(sj)
graph export "gigs_fig1.pdf"

use life6mo, clear
keep if (gestage - pma) == 0
egen sfga = classify_sfga(meaninfwgt/1000), ///
    gest_days(gestage) sex(sex) sexcode(m=1, f=2)
gen term_status = "Preterm" if gestage < `37weeks'
replace term_status = "Term" if gestage >= `37weeks'
graph bar, over(sfga) by(term_status, ///
    title("Percentage of each size-for-GA category by term status") ///
    note("")) ///
    ytitle("Percentage") ///
    scheme(sj)
graph export "gigs_fig2.pdf"