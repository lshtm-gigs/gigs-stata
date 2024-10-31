use life6mo, clear
keep id gestage sex visitweek pma age_days weight_g
local 37weeks 7 * 37
list in f/9, noobs abbreviate(10) sep(9)

egen double waz_nbs = ig_nbs(weight_g/1000, "wfga", "v2z") ///
    if age_days < 3, ///
    gest_days(gestage) sex(sex) sexcode(m=1, f=2)

egen double waz_who = who_gs(weight_g/1000, "wfa", "v2z") ///
    if missing(waz_nbs) & gestage >= `37weeks', ///
    xvar(age_days) sex(sex) sexcode(m=1, f=2)

gen pma_weeks = pma / 7
egen double waz_png = ig_png(weight_g/1000, "wfa", "v2z") ///
    if missing(waz_nbs) & gestage < `37weeks', ///
    xvar(pma_weeks) sex(sex) sexcode(m=1, f=2)
drop pma_weeks

generate double wt_kg = weight_g/1000
gigs_classify_growth wfa, ///
    gest_days(gestage) age_days(age_days) sex(sex) sexcode(m=1, f=2) ///
    weight_kg(wt_kg) id(id)

list id visitweek wt_kg waz_* waz in f/9, noobs sep(9) abbreviate(5)
drop waz_*

gen preterm = gestage < `37weeks'
collapse waz, by(visitweek preterm)
line waz visitweek if preterm == 0 || line waz visitweek if preterm == 1 ||, ///
    xtitle("Visit week") ///
    ytitle("Weight-for-age z-score (WAZ)") ///
    xlabel(0 1 2 4 6 10 14 18 26) ///
    legend(label(1 "Term") label(2 "Preterm")) ///
    scheme(sj)
graph export "gigs_fig1.pdf"

use life6mo, clear
generate wt_kg = weight_g/1000
gigs_classify_growth sfga, ///
    gest_days(gestage) age_days(age_days) sex(sex) sexcode(m=1, f=2) ///
    weight_kg(wt_kg) id(id)

list id *age* wt_kg birthweight_centile sfga* if visitweek == 0 in f/40
graph bar, over(sfga) ///
    note("") ///
    ytitle("Percentage") ///
    scheme(sj)
graph export "gigs_fig2.pdf"

gigs_classify_growth svn, ///
    gest_days(gestage) age_days(age_days) sex(sex) sexcode(m=1, f=2) ///
    weight_kg(wt_kg) id(id) replace
list id *age* wt_kg birthweight_centile sfga svn if visitweek == 0 in f/40
graph bar, over(svn) ///
    note("") ///
    ytitle("Percentage") ///
    scheme(sj)
graph export "gigs_fig3.pdf"