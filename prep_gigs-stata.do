// Moves and zips files into a shareable zipped version of the package. This
// is necessary whilst we wait to make the code fully open-source.
local version = "0.4.1"
local zipfolder = "stata-gigs_`version'"
cap rmdir `zipfolder'
mkdir `zipfolder'
local zip_filelist = "classify_sfga.sthlp classify_stunting.sthlp classify_svn.sthlp classify_wasting.sthlp classify_wfa.sthlp gigs.sthlp ig_fet.sthlp ig_nbs.sthlp ig_nbsGAMLSS_hcfga.dta ig_nbsGAMLSS_lfga.dta ig_nbsGAMLSS_wfga.dta ig_nbsNORMBODYCOMP.dta ig_png.sthlp life6mo.dta life6mo.sthlp whoLMS_acfa.dta whoLMS_bfa.dta whoLMS_hcfa.dta whoLMS_lhfa.dta whoLMS_ssfa.dta whoLMS_tsfa.dta whoLMS_wfa.dta whoLMS_wfh.dta whoLMS_wfl.dta who_gs.sthlp _gclassify_sga.ado _gclassify_stunting.ado _gclassify_svn.ado _gclassify_wasting.ado _gclassify_wfa.ado _gig_fet.ado _gig_nbs.ado _gig_png.ado _gwho_gs.ado gigs_ipolate_coeffs.mo"
foreach file in `zip_filelist' {
	if "`file'" != "" {
		 di "`file'"
		 local char1 = substr("`file'", 1, 1) 
		 di "`char1'"
		 cap mkdir `zipfolder'/`char1'
		 copy `file' `zipfolder'/`char1'/`file', replace
	}
}
