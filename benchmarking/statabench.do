/* 
  The benchmarking code here is used to compare and contrast different versions
  of the Stata code with each other, and with R implementations. 

  The benchmarking tables used are the same used to benchmark the various R/SAS 
  implementations of these growth standards against each other. The generation
  process for these tables can be checked out on the R package website in the 
  benchmarking article 
  (https://docs.ropensci.org/gigs/articles/benchmarking.html), and you can go to
  GitHub and run the source code yourself.
  
  It is assumed that a user running this script has 'gigs' and 'zanthro' for
  installed in Stata, as stable releases or for 'gigs', the dev version from 
  GitHub.
*/

clear all

local bench_folder "D:\Users\tadeo\Documents\gigs-stata\benchmarking"
log using "`bench_folder'\statabench.log", replace text nomsg

// WHO Child Growth Standards
foreach i in 1 10 100 500 1000 5000 10000 25000 50000 75000 100000 {
	use "`bench_folder'/bench_ds_who_gs.dta", clear
	qui drop if _n > `i'
	di "For who_gs gigs_stata - Number of inputs: `i'"
	bench, reps(50) restore last: ///
		qui egen double z_gigs = who_gs(y, "wfa", "v2z"), ///
			xvar(x) sex(sex) sexcode(m=M, f=F)
}

foreach i in 1 10 100 500 1000 5000 10000 25000 50000 75000 100000 {
	use "`bench_folder'/bench_ds_who_gs.dta", clear
	qui drop if _n > `i'
	di "For who_gs zanthro - Number of inputs: `i'"
	bench, reps(50) restore last: ///
		qui egen z_anthro = zanthro(y, wa, WHO), xvar(x) gender(sex) ///
			gencode(male=M, female=F) ageunit(day)
}

// IG-21st Newborn Size Standards
foreach i in 1 10 100 500 1000 5000 10000 25000 50000 75000 100000 {
	use "`bench_folder'/bench_ds_ig_nbs.dta", clear
	qui drop if _n > `i'
	di "For ig_nbs gigs_stata - Number of inputs: `i'"
	bench, reps(50) restore last: ///
		qui egen double z_gigs = ig_nbs(y, "wfga", "v2z"), ///
			gest_days(x) sex(sex) sexcode(m=M, f=F)
}

// IG-21st Postnatal Growth Standards
foreach i in 1 10 100 500 1000 5000 10000 25000 50000 75000 100000 {
	use "`bench_folder'/bench_ds_ig_png.dta", clear
	qui drop if _n > `i'
	di "For ig_png gigs_stata - Number of inputs: `i'"
	bench, reps(50) restore last: ///
		qui egen double z_gigs = ig_png(y, "wfa", "v2z"), ///
			xvar(x) sex(sex) sexcode(m=M, f=F)
}

// IG-21st Fetal Standards
foreach i in 1 10 100 500 1000 5000 10000 25000 50000 75000 100000 {
	use "`bench_folder'/bench_ds_ig_fet.dta", clear
	qui drop if _n > `i'
	di "For ig_fet gigs_stata - Number of inputs: `i'"
	bench, reps(50) restore last: ///
		qui egen double z_gigs = ig_fet(y, "ofdfga", "v2z"), xvar(x)
}

log close

// Convert benchmarking log to a CSV file used in R benchmarking article
// n.b. Install rsource (R from Stata) if not already installed:
//		. cap ssc install rsource, replace
local bench_folder "D:\Users\tadeo\Documents\gigs-stata\benchmarking"
local benchmarking_rscript "`bench_folder'/statabench2csv.R"
if "`c(os)'"=="MacOSX" | "`c(os)'"=="UNIX" {
    noi rsource using "`benchmarking_rscript'", ///
		noloutput ///
		rpath("/usr/local/bin/R") ///
		roptions(`"--vanilla"')
}
else if "`c(os)'"=="Windows" { 
	// Windows
	// n.b. Set `rversion' to that of own system - n.b. gigs needs R >=4.1.0
	local rversion "4.3.3" 
	noi rsource using "`benchmarking_rscript'", ///
		noloutput ///
		rpath("C:\Program Files\R\R-`rversion'\bin\x64\Rterm.exe") ///
		roptions("--vanilla")
}

// OLD VERSIONS OF GIGS --------------------------------------------------------
// Kept to note how development is progressing

// All versions before 1.0.0 just benched on the WHO GS weight-for-age standard

// gigs 0.4.0
// Number of inputs: 1
// Average over 25 runs: 0.009 seconds
// Number of inputs: 10
// Average over 25 runs: 0.008 seconds
// Number of inputs: 100
// Average over 25 runs: 0.009 seconds
// Number of inputs: 500
// Average over 25 runs: 0.010 seconds
// Number of inputs: 1000
// Average over 25 runs: 0.012 seconds
// Number of inputs: 5000
// Average over 25 runs: 0.028 seconds
// Number of inputs: 10000
// Average over 25 runs: 0.047 seconds
// Number of inputs: 25000
// Average over 25 runs: 0.104 seconds
// Number of inputs: 50000
// Average over 25 runs: 0.198 seconds
// Number of inputs: 75000
// Average over 25 runs: 0.296 seconds
// Number of inputs: 100000
// Average over 25 runs: 0.405 seconds

// gigs 0.3.2:
// Number of inputs: 1
// Average over 25 runs: 0.008 seconds
// Number of inputs: 10
// Average over 25 runs: 0.009 seconds
// Number of inputs: 100
// Average over 25 runs: 0.009 seconds
// Number of inputs: 500
// Average over 25 runs: 0.010 seconds
// Number of inputs: 1000
// Average over 25 runs: 0.012 seconds
// Number of inputs: 5000
// Average over 25 runs: 0.027 seconds
// Number of inputs: 10000
// Average over 25 runs: 0.045 seconds
// Number of inputs: 25000
// Average over 25 runs: 0.101 seconds
// Number of inputs: 50000
// Average over 25 runs: 0.195 seconds
// Number of inputs: 75000
// Average over 25 runs: 0.294 seconds
// Number of inputs: 100000
// Average over 25 runs: 0.405 seconds

// gigs 0.3.1:
// Number of inputs: 1
// Average over 25 runs: 0.008 seconds
// Number of inputs: 10
// Average over 25 runs: 0.009 seconds
// Number of inputs: 100
// Average over 25 runs: 0.009 seconds
// Number of inputs: 500
// Average over 25 runs: 0.010 seconds
// Number of inputs: 1000
// Average over 25 runs: 0.012 seconds
// Number of inputs: 5000
// Average over 25 runs: 0.028 seconds
// Number of inputs: 10000
// Average over 25 runs: 0.047 seconds
// Number of inputs: 25000
// Average over 25 runs: 0.106 seconds
// Number of inputs: 50000
// Average over 25 runs: 0.204 seconds
// Number of inputs: 75000
// Average over 25 runs: 0.310 seconds
// Number of inputs: 100000
// Average over 25 runs: 0.410 seconds

// gigs 0.3.0:
// Number of inputs: 1
// Average over 25 runs: 0.008 seconds
// Number of inputs: 10
// Average over 25 runs: 0.010 seconds
// Number of inputs: 100
// Average over 25 runs: 0.010 seconds
// Number of inputs: 500
// Average over 25 runs: 0.011 seconds
// Number of inputs: 1000
// Average over 25 runs: 0.013 seconds
// Number of inputs: 5000
// Average over 25 runs: 0.028 seconds
// Number of inputs: 10000
// Average over 25 runs: 0.048 seconds
// Number of inputs: 25000
// Average over 25 runs: 0.107 seconds
// Number of inputs: 50000
// Average over 25 runs: 0.205 seconds
// Number of inputs: 75000
// Average over 25 runs: 0.313 seconds
// Number of inputs: 100000
// Average over 25 runs: 0.431 seconds

// gigs 0.2.4:
// Number of inputs: 1
// Average over 25 runs: 0.016 seconds
// Number of inputs: 10
// Average over 25 runs: 0.015 seconds
// Number of inputs: 100
// Average over 25 runs: 0.017 seconds
// Number of inputs: 500
// Average over 25 runs: 0.039 seconds
// Number of inputs: 1000
// Average over 25 runs: 0.079 seconds
// Number of inputs: 5000
// Average over 25 runs: 1.007 seconds
// --> Crashed on 10000 or more inputs