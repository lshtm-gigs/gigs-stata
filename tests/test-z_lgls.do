//  Test whether GIGS zscoring logicals are the same across a large sample of
//  randomly generated observations

local test_gigs_z_outputs = "tests/outputs/gigs_zscoring"
cap mkdir "`test_gigs_z_outputs'"

// Generate random variables
set seed 28199812
set obs 10000
generate int id = 0 + 1000*runiform()
sort id
tostring id, replace
generate int gest_days = int(154 + 161 * runiform())
generate double age_days = 0 + 1856 * runiform()

gigs_zscoring_lgls ig_nbs ig_png who_gs, ///
  age_days(age_days) gest_days(gest_days) id(id)

local outpath = "`test_gigs_z_outputs'/gigs_z.dta"
save `outpath', replace
