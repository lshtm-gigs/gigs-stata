// -- Testing gigs package --

// Install rsource (R from Stata) if not already installed
// cap ssc install rsource, replace

// Test conversion functions
local outputs "tests/outputs"
cap mkdir "`outputs'"

//   1. Generate .dta files with standards using "z2v/p2v" conversions
foreach standard in "ig_nbs" "ig_png" "who_gs" {
	cap mkdir "`outputs'/`standard'"
	di ""
	run "tests/test-`standard'.do"
}

//   2. Compare to standards in gigs R package
local test_rscript "tests/test_stata_outputs.R"
if "`c(os)'"=="MacOSX" | "`c(os)'"=="UNIX" {
    rsource using "`test_rscript'", ///
		noloutput ///
		rpath("/usr/local/bin/R") ///
		roptions(`"--vanilla"')
}
else if "`c(os)'"=="Windows" { 
	// Windows
	local rversion "4.3.0"
	rsource using "`test_rscript'", ///
		noloutput ///
		rpath("C:\Program Files\R\R-`rversion'\bin\x64\Rterm.exe") ///
		roptions("--vanilla")
}

// Test classification functions
run "tests/test-classification.do"