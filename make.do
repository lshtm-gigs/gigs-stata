// the 'make.do' file is automatically created by 'github' package.
// execute the code below to generate the package installation files.
// DO NOT FORGET to update the version of the package, if changed!
// for more information visit http://github.com/haghish/github

make gigs, replace toc pkg version(0.4.0)                                    ///
     license("GNU General Public License v3.0")                              ///
     author("S. R. Parker")                                                  ///
     affiliation("London School of Hygiene and Tropical Medicine")           ///
     email("simon.parker@lshtm.ac.uk")                                       ///
     url("https://github.com/lshtm-gigs/gigs-stata")                         ///
     title("Newborn and infant growth assessment using international growth standards") ///
     description("gigs provides a single, simple interface for working with outputs from the INTERGROWTH-21st project and the WHO Child Growth standards. You will find functions for converting between anthropometric measures (e.g. weight or length) to z-scores and centiles, and the inverse. Also included are functions for classifying newborn and infant growth according to DHS guidelines.") ///
     install("_gclassify_sfga.ado;_gclassify_stunting.ado;_gclassify_svn.ado;_gclassify_wasting.ado;_gclassify_wfa.ado;_gig_fet.ado;_gig_nbs.ado;_gig_png.ado;_gwho_gs.ado;gigs_ipolate_coeffs.mo;classify_sga.sthlp;classify_stunting.sthlp;classify_svn.sthlp;classify_wasting.sthlp;classify_wfa.sthlp;gigs.sthlp;ig_fet.sthlp;ig_nbs.sthlp;ig_nbsGAMLSS_hcfga.dta;ig_nbsGAMLSS_lfga.dta;ig_nbsGAMLSS_wfga.dta;ig_png.sthlp;who_gs.sthlp;whoLMS_acfa.dta;whoLMS_bfa.dta;whoLMS_hcfa.dta;whoLMS_lhfa.dta;whoLMS_ssfa.dta;whoLMS_tsfa.dta;whoLMS_wfa.dta;whoLMS_wfh.dta;whoLMS_wfl.dta") ///
     iancillary("gigs_examples.do;life6mo.dta;life6mo.sthlp")                             
