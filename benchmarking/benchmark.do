/* 
  The benchmarking code here is used to compare and contrast different versions
  of the Stata code with each other, and with R implementations. 

  It focuses on conversions in the WHO Growth Standards for two reasons:
    1. These functions involve the slowest bits of code - loading in data and 
       performing interpolation on the LMS coefficients. 
    2. The WHO functions are common to all the tested Stata/R implementations, 
	   so can be directly compared.  

  The benchmarking table used is the same used to compare the different R 
  implementations against each other. The generation process for this table can
  be checked out on the R package website in the benchmarking article
  (https://lshtm-gigs.github.io/gigs/)
*/

foreach i in 1 10 100 500 1000 5000 10000 25000 50000 75000 100000 {
	use "benchmarking/bench_dataset.dta", clear
	qui drop if _n > `i'
	di "Number of inputs: `i'"
	bench, reps(25) restore last: ///
		qui egen double z_gigs = who_gs(y, "wfa", "v2z"), ///
		xvar(x) sex(sex) sexcode(m=M, f=F)
}

// gigs 0.3.2:
// Number of inputs: 1
// Average over 25 runs: 0.007 seconds
// Number of inputs: 10
// Average over 25 runs: 0.009 seconds
// Number of inputs: 100
// Average over 25 runs: 0.009 seconds
// Number of inputs: 500
// Average over 25 runs: 0.011 seconds
// Number of inputs: 1000
// Average over 25 runs: 0.012 seconds
// Number of inputs: 5000
// Average over 25 runs: 0.027 seconds
// Number of inputs: 10000
// Average over 25 runs: 0.046 seconds
// Number of inputs: 25000
// Average over 25 runs: 0.101 seconds
// Number of inputs: 50000
// Average over 25 runs: 0.199 seconds
// Number of inputs: 75000
// Average over 25 runs: 0.300 seconds
// Number of inputs: 100000
// Average over 25 runs: 0.411 seconds

// zanthro 1.0.2:
// foreach i in 1 10 100 500 1000 5000 10000 25000 50000 75000 100000 {
// 	use "benchmarking/bench_dataset.dta", clear
// 	qui drop if _n > `i'
// 	di "Number of inputs: `i'"
// 	bench, reps(25) restore last: ///
// 		qui egen z_anthro = zanthro(y, wa, WHO), xvar(x) gender(sex) ///
//                 gencode(male=M, female=F)  ageunit(day)
// }

// Number of inputs: 1
// Average over 25 runs: 0.007 seconds
// Number of inputs: 10
// Average over 25 runs: 0.008 seconds
// Number of inputs: 100
// Average over 25 runs: 0.009 seconds
// Number of inputs: 500
// Average over 25 runs: 0.017 seconds
// Number of inputs: 1000
// Average over 25 runs: 0.027 seconds
// Number of inputs: 5000
// Average over 25 runs: 0.105 seconds
// Number of inputs: 10000
// Average over 25 runs: 0.203 seconds
// Number of inputs: 25000
// Average over 25 runs: 0.479 seconds
// Number of inputs: 50000
// Average over 25 runs: 0.951 seconds
// Number of inputs: 75000
// Average over 25 runs: 1.445 seconds
// Number of inputs: 100000
// Average over 25 runs: 2.046 seconds

// Compare gigs outputs with zanthro outputs:
use "benchmarking/bench_dataset.dta", clear
egen double z_gigs = who_gs(y, "wfa", "v2z"), ///
		xvar(x) sex(sex) sexcode(m=M, f=F)
egen z_anthro = zanthro(y, wa, WHO), xvar(x) gender(sex) ///
		gencode(male=M, female=F)  ageunit(day)

// OLD VERSIONS OF GIGS --------------------------------------------------------
// Kept to note how development is progressing

stop
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