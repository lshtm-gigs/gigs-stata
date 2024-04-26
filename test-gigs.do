// -- Testing gigs package --

// 0. Load in all scripts as most recent version --> i.e. NOT a version of gigs 
// from `GitHub'.

// Make sure pwd is gigs-stata directory on machine
local gigs_stata_dir "`c(pwd)'"
net uninstall gigs
net install gigs, from(`gigs_stata_dir')

// Install rsource (R from Stata) if not already installed
// cap ssc install rsource, replace

//  1. Generate .dta files with standards using "z2v/c2v" conversions
local outputs "tests/outputs"
cap mkdir "`outputs'"
foreach standard in "who_gs" "ig_nbs" "ig_png" "ig_fet" "interpolation" {
	cap mkdir "`outputs'/`standard'"
	noi di "Running .dta file generation for `standard'"
	run "tests/test-`standard'.do"
}

//  2. Compare to standards in gigs R package
local test_rscript "tests/test_stata_outputs.R"
if "`c(os)'"=="MacOSX" | "`c(os)'"=="UNIX" {
    noi rsource using "`test_rscript'", ///
		noloutput ///
		rpath("/usr/local/bin/R") ///
		roptions(`"--vanilla"')
}
else if "`c(os)'"=="Windows" { 
	// Windows
	local rversion "4.3.3" // Set to version on own system
	noi rsource using "`test_rscript'", ///
		noloutput ///
		rpath("C:\Program Files\R\R-`rversion'\bin\x64\Rterm.exe") ///
		roptions("--vanilla")
}

//	3. Test classification functions
clear frames
frames reset
run "tests/test-classification.do"