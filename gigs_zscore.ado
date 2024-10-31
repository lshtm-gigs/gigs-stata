capture prog drop gigs_zscore
*! version 0.2.0 (SJxx-x: dmxxxx)
program gigs_zscore
	version 16
	preserve
	syntax newvarname(numeric) [if] [in] , /// 
		z_type(string) Yvar(varname numeric)  ///
		age_days(varname numeric) gest_days(varname numeric) ///
		sex(varname) SEXCode(string) ///
		outvartype(string) ///
		[lenht_cm(varname numeric) id(varname string) ///
		gigs_lgls(varlist numeric min=3 max=3)]
	
	// 0a. Sanity checks --> is z-score type a permitted variable?
	cap assert inlist("`z_type'", "waz", "wlz", "lhaz", "hcaz")
	if _rc == 9 {
		di as error "Error in gigs_zscore: " /*
			*/ "{bf:z_type} arg must be a valid z-score type, one of " /*
			*/ as text "waz, wlz, lhaz" as error " or " as text "hcaz" /*
			*/ as error ". This is an internal error, so please contact the " /*
			*/ "maintainers of this package if you are an end-user. You can " /*
			*/ "find our details at {help gigs}."
		exit 498
	}
	
	// 0b. Sanity checks --> are sex/sexcode valid?
	local 1 `sexcode'
	local 1 : subinstr local 1 "," " ", all
	tokenize `"`1'"', parse("= ")
	
 	if "`1'" == substr("male", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("female", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			GigsZscore_Badsyntax
 		}
 		local male "`3'"
  	local female "`6'"
	} 
	else if "`1'" == substr("female", 1, length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			GigsZscore_Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else GigsZscore_Badsyntax	
	
	local sex_type = "`:type `sex''"
	if !regexm("`sex_type'", "byte|str|int") {
		Badsexvar_gigsz
	}
	else {
		local sex_was_str = .
		if regexm("`sex_type'", "byte|int") {
			local sex_was_str = 0
			qui tostring(`sex'), replace
		}
	}
	
	marksample touse, novarlist
	
	// 1. Set up GIGS logical variables (i.e. which standards to use)
	if "`gigs_lgls'" == "" {
		tempvar use_ig_nbs use_ig_png use_who_gs
		gigs_zscoring_lgls `use_ig_nbs' `use_ig_png' `use_who_gs' ///
			if `touse', age_days(`age_days') gest_days(`gest_days') id(`id')
		noi di "`use_ig_nbs' `use_ig_png' `use_who_gs'"
	}
	else {	
		local use_ig_nbs : word 1 of `gigs_lgls'
		local use_ig_png : word 2 of `gigs_lgls'
		local use_who_gs : word 3 of `gigs_lgls'
	}
	
	// 2. Make pma_weeks variable for all 'Yvar-for-age' z-scores
	if inlist("`z_type'", "waz", "lhaz", "hcaz") {
		tempvar pma_weeks
		gen double `pma_weeks' = (`age_days' + `gest_days') / 7
	}
	
	// 3. Z-scoring for each type
	if "`z_type'" == "lhaz" {
		tempvar lhaz_nbs lhaz_png lhaz_who
		egen double `lhaz_nbs' = ig_nbs(`yvar', "lfga", "v2z") ///
			if `use_ig_nbs' & `touse', ///
			gest_days(`gest_days') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `lhaz_png' = ig_png(`yvar', "lfa", "v2z") ///
			if `use_ig_png' & `touse', ///
			xvar(`pma_weeks') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `lhaz_who' = who_gs(`yvar', "lhfa", "v2z") ///
			if `use_who_gs' & `touse', ///
			xvar(`age_days') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
			
		local lhaz "`varlist'"
		gen `outvartype' `lhaz' = .
		replace `lhaz' = `lhaz_nbs' if `use_ig_nbs'
		replace `lhaz' = `lhaz_png' if `use_ig_png'
		replace `lhaz' = `lhaz_who' if `use_who_gs'
	}
	if "`z_type'" == "wlz" {
		tempvar use_who_gs_wfl use_who_gs_wfh
		gen byte `use_who_gs_wfl' = `use_who_gs' & `age_days' < 731
		gen byte `use_who_gs_wfh' = `use_who_gs' & `age_days' >= 731
		
		tempvar wlz_who_wfl wlz_who_wfh wlz_png
		egen double `wlz_png' = ig_png(`yvar', "wfl", "v2z") ///
			if `use_ig_png' & `touse', ///
			xvar(`lenht_cm') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `wlz_who_wfl' = who_gs(`yvar', "wfl", "v2z") ///
			if `use_who_gs_wfl' & `touse', ///
			xvar(`lenht_cm') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `wlz_who_wfh' = who_gs(`yvar', "wfh", "v2z") ///
			if `use_who_gs_wfh' & `touse', ///
			xvar(`lenht_cm') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		
		local wlz "`varlist'"
		gen `outvartype' `wlz' = .
		replace `wlz' = `wlz_png' if `use_ig_png'
		replace `wlz' = `wlz_who_wfl' if `use_who_gs_wfl'
		replace `wlz' = `wlz_who_wfh' if `use_who_gs_wfh'
	}
	if "`z_type'" == "waz" {
		tempvar waz_nbs waz_png waz_who
		egen double `waz_nbs' = ig_nbs(`yvar', "wfga", "v2z") ///
			if `use_ig_nbs' & `touse', ///
			gest_days(`gest_days') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `waz_png' = ig_png(`yvar', "wfa", "v2z") ///
			if `use_ig_png' & `touse', ///
			xvar(`pma_weeks') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `waz_who' = who_gs(`yvar', "wfa", "v2z") ///
			if `use_who_gs' & `touse', ///
			xvar(`age_days') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		
		local waz "`varlist'"
		gen `outvartype' `waz' = .
		replace `waz' = `waz_nbs' if `use_ig_nbs'
		replace `waz' = `waz_png' if `use_ig_png'
		replace `waz' = `waz_who' if `use_who_gs'
	}
	if "`z_type'" == "hcaz" {
		tempvar hcaz_nbs hcaz_png hcaz_who
		egen double `hcaz_nbs' = ig_nbs(`yvar', "hcfga", "v2z") ///
			if `use_ig_nbs' & `touse', ///
			gest_days(`gest_days') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `hcaz_png' = ig_png(`yvar', "hcfa", "v2z") ///
			if `use_ig_png' & `touse', ///
			xvar(`pma_weeks') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		egen double `hcaz_who' = who_gs(`yvar', "hcfa", "v2z") ///
			if `use_who_gs' & `touse', ///
			xvar(`age_days') ///
			sex(`sex') sexcode(m="`male'", f="`female'")
		
		local hcaz "`varlist'"
		gen `outvartype' `hcaz' = .
		replace `hcaz' = `hcaz_nbs' if `use_ig_nbs'
		replace `hcaz' = `hcaz_png' if `use_ig_png'
		replace `hcaz' = `hcaz_who' if `use_who_gs'
	}
	
	qui if "`sex_was_str'" == "0" destring(`sex'), replace
	restore, not
end

capture prog drop GigsZscore_Badsyntax
program GigsZscore_Badsyntax
	di as err "sexcode() option invalid in gigs_zscore"
	exit 198
end

capture prog drop Badsexvar_gigsz
program Badsexvar_gigsz
	di as err "sex() option should be a byte, int or str variable in " ///
		"gigs_zscore"
	exit 109
end

capture prog drop Badidvar_gigsz
program Badidvar_gigsz
	di as err "id() option should be a str variable in gigs_zscore"
	exit 109
end
