// the 'make.do' file is automatically created by 'github' package.
// execute the code below to generate the package installation files.
// DO NOT FORGET to update the version of the package, if changed!
// for more information visit http://github.com/haghish/github

make gigs, replace toc pkg version(1.1.3)                                    ///
     license("GNU General Public License v3.0")                              ///
     author("S. R. Parker")                                                  ///
     affiliation("London School of Hygiene & Tropical Medicine")             ///
     email("simon.parker1471@outlook.com")                                   ///
     url("https://github.com/lshtm-gigs/gigs-stata")                         ///
     title("Assess Fetal, Newborn, and Child Growth with International Standards") ///
     description("gigs provides a single, simple interface for working with outputs from the INTERGROWTH-21st project and the WHO Child Growth standards. You will find functions for converting anthropometric measures (e.g. weight or length) to z-scores and centiles, and the inverse. Also included are functions for classifying newborn and infant growth according to published cut-offs.") ///
     install("_gig_fet.ado;_gig_nbs.ado;_gig_png.ado;_gwho_gs.ado;gigs_classify_growth.ado;gigs_zscore.ado;gigs_zscoring_lgls.ado;gigs_categorise.ado;gigs_ipolate_coeffs.mo;gigs_classify_growth.sthlp;gigs.sthlp;ig_fet.sthlp;ig_nbs.sthlp;ig_nbs_extGAMLSS_hcfga.dta;ig_nbs_extGAMLSS_lfga.dta;ig_nbs_extGAMLSS_wfga.dta;ig_nbsGAMLSS_lfga.dta;ig_nbsGAMLSS_wfga.dta;ig_png.sthlp;who_gs.sthlp;whoLMS_acfa.dta;whoLMS_bfa.dta;whoLMS_hcfa.dta;whoLMS_lhfa.dta;whoLMS_ssfa.dta;whoLMS_tsfa.dta;whoLMS_wfa.dta;whoLMS_wfh.dta;whoLMS_wfl.dta") ///
     iancillary("gigs_examples.do;life6mo.dta;life6mo.sthlp")                             
