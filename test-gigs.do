// -- Testing gigs package --

// 0. Load in all scripts as most recent version --> i.e. NOT a version of gigs 
// from `net install'.
clear all
foreach file in "_gclassify_sga.ado" "_gclassify_svn.ado" ///
				"_gclassify_stunting.ado" "_gclassify_wasting.ado" ///
				"_gclassify_wfa.ado" ///
				"_gig_nbs.ado" "_gig_png.ado" "_gwho_gs.ado" ///
				"gigs_ipolate_coeffs.ado" {
	run "`file'"
}

// Install rsource (R from Stata) if not already installed
// cap ssc install rsource, replace

//   1. Generate .dta files with standards using "z2v/p2v" conversions
local outputs "tests/outputs"
cap mkdir "`outputs'"
foreach standard in "who_gs" "ig_nbs" "ig_png" "interpolation" {
	cap mkdir "`outputs'/`standard'"
	noi di "Running .dta file generation for `standard'"
	run "tests/test-`standard'.do"
}

//   2. Compare to standards in gigs R package
local test_rscript "tests/test_stata_outputs.R"
if "`c(os)'"=="MacOSX" | "`c(os)'"=="UNIX" {
    noi rsource using "`test_rscript'", ///
		noloutput ///
		rpath("/usr/local/bin/R") ///
		roptions(`"--vanilla"')
}
else if "`c(os)'"=="Windows" { 
	// Windows
	local rversion "4.3.1" // Set to version on own system
	noi rsource using "`test_rscript'", ///
		noloutput ///
		rpath("C:\Program Files\R\R-`rversion'\bin\x64\Rterm.exe") ///
		roptions("--vanilla")
}

//	3. Test classification functions
run "tests/test-classification.do"
clear all