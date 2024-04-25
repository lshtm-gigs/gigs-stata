use life6mo, clear
keep id gestage sex visitweek pma age_days weight_g
local 37weeks 7 * 37
/* Show data from first visit for first 9 IDs */
list in f/80 if visitweek == 0, noobs abbreviate(10) sep(9)

egen double waz_nbs = ig_nbs(weight_g/1000, "wfga", "v2z") ///
    if age_days == 0, ///
    gest_days(gestage) sex(sex) sexcode(m=1, f=2)

egen double waz_who = who_gs(weight_g/1000, "wfa", "v2z") ///
    if age_days > 0 & gestage >= `37weeks', ///
    xvar(age_days) sex(sex) sexcode(m=1, f=2)

gen pma_weeks = pma / 7
egen double waz_png = ig_png(weight_g/1000, "wfa", "v2z") ///
    if age_days > 0 & gestage < `37weeks', ///
    xvar(pma_weeks) sex(sex) sexcode(m=1, f=2)
drop pma_weeks

gen double waz = waz_who if gestage > `37weeks'
replace waz = waz_png if gestage < `37weeks'
replace waz = waz_nbs if age_days == 0

/* Show data from first visits for the first 9 IDs*/
list id visitweek gestage pma waz_* waz in f/80 if visitweek == 0, noobs sep(9)
drop waz_*

gen preterm = gestage < `37weeks'
collapse waz, by(visitweek preterm)
line waz visitweek if preterm == 0 || line waz visitweek if preterm == 1 ||, ///
    title("WAZ in 300 infants from the LIFE data extract") ///
    xtitle("Visit week") ///
    ytitle("Weight-for-age z-score (WAZ)") ///
    xlabel(0 1 2 4 6 10 14 18 26) ///
    legend(label(1 "Term") label(2 "Preterm")) ///
    scheme(sj)
graph export "gigs_fig1.pdf"

use life6mo, clear
keep if age_days == 0
egen sfga = classify_sfga(weight_g/1000), ///
    gest_days(gestage) sex(sex) sexcode(m=1, f=2)
graph bar, over(sfga) ///
    title("Size-for-GA categorisations in the LIFE data extract") ///
    note("") ///
    ytitle("Percentage") ///
    scheme(sj)
graph export "gigs_fig2.pdf"


egen svn = classify_svn(weight_g/1000), ///
    gest_days(gestage) sex(sex) sexcode(m=1, f=2)
graph bar, over(svn) ///
    title("SVN categorisations in the LIFE data extract") ///
    note("") ///
    ytitle("Percentage") ///
    scheme(sj)
graph export "gigs_fig3.pdf"