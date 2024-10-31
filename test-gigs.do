// -- Testing gigs package --

// 0. Load in all scripts as most recent version --> i.e. NOT a version of gigs 
// from `GitHub'.

// Make sure pwd is gigs-stata directory on machine
local gigs_stata_dir "`c(pwd)'"
net install gigs, replace from(`gigs_stata_dir')
clear all
clear rngstream
// Start logging
log using test-gigs.log, replace text name("GIGS Testing")

//  1. Generate .dta files with standards using "z2v/c2v" conversions,
//     and with .dta files to be tested against R dataframes
local outputs "tests/outputs"
cap mkdir "`outputs'"
foreach aspect in "who_gs" "ig_nbs" "ig_png" "ig_fet" "interpolation" ///
    "z_lgls" "classification" {
	cap mkdir "`outputs'/`aspect'"
	noi di "Running .dta file generation for `aspect'"
	frames reset
	run "tests/test-`aspect'.do"
}

//  2. Compare to standards in gigs R package
// 		a. n.b. Install rsource (R from Stata) if not already installed:
//		   . cap ssc install rsource, replace
local test_rscript "tests/test_stata_outputs.R"
if "`c(os)'"=="MacOSX" | "`c(os)'"=="UNIX" {
    noi rsource using "`test_rscript'", ///
		noloutput ///
		rpath("/usr/local/bin/R") ///
		roptions(`"--vanilla"')
}
else if "`c(os)'"=="Windows" { 
	// Windows
	// n.b. Set `rversion' to that of own system - n.b. gigs needs R >=4.1.0
	local rversion "4.3.3" 
	noi rsource using "`test_rscript'", ///
		noloutput ///
		rpath("C:\Program Files\R\R-`rversion'\bin\x64\Rterm.exe") ///
		roptions("--vanilla")
}

// Stop logging
log close