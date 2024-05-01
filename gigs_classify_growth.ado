capture program drop gigs_classify_growth
*! version 0.1.1 (SJxx-x: dmxxxx)
program define gigs_classify_growth
	version 16
	preserve
	syntax anything(name=outcomes id="outcomes") [if] [in] , /*
		*/ GEST_days(varname numeric) AGE_days(varname numeric) /*
 		*/ sex(varname) SEXCode(string) /*
 		*/ [WEIGHT_kg(varname numeric) LENHT_cm(varname numeric) /*
 		*/  HEADCIRC_cm(varname numeric) replace]
	
	if `"`by'"' != "" {
		_egennoby gigs_classify_growth `"`by'"'
		/* NOTREACHED */
	}

	local 1 `sexcode'
	local 1 : subinstr local 1 "," " ", all
	tokenize `"`1'"', parse("= ")
	
 	if "`1'" == substr("male", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("female", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			GrowthSex_Badsyntax
 		}
 		local male "`3'"
  	local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			GrowthSex_Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else GrowthSex_Badsyntax	
	
	local sex_type = "`:type `sex''"
	if !regexm("`sex_type'", "byte|str|int") {
		Badsexvar_growth
	}
	else {
		local sex_was_str = .
		if regexm("`sex_type'", "byte|int") {
			local sex_was_str = 0
			qui tostring(`sex'), replace
		}
	}
	
	marksample touse
	
	// 1. Check each word in `outcomes'
	
	di "Requested outcomes:"
	if "`outcomes'" == "all" {
		local outcomes sfga svn stunting wasting wfa headsize
	}
	foreach outcome in `outcomes' {
		cap assert inlist("`outcome'", "sfga", "svn", "stunting", /*
			*/ "wasting", "wfa", "headsize")
		if _rc == 9 {	
			di as text "`outcome'" as error " is an invalid outcome. " /*
			*/ "The only valid outcomes are " as text "sfga, svn, " /*
			*/ as text "stunting, wasting, wfa " as error "or" /*
			*/ as text " headsize" as error "."
			exit 198
		}
		if "`outcome'" == "sfga" local outcome_str "Size-for-gestational age"
		if "`outcome'" == "svn" local outcome_str "Small vulnerable newborn"
		if "`outcome'" == "stunting" local outcome_str "Stunting"
		if "`outcome'" == "wasting" local outcome_str "Wasting"
		if "`outcome'" == "wfa" local outcome_str "Weight-for-age"
		if "`outcome'" == "headsize" local outcome_str "Head size"
		di "	`outcome_str' (`outcome')"
	}
	
	// 2. Get vars for later + gigs logicals 
	tempvar pma_days pma_weeks 
	gen double `pma_days' = `age_days' + `gest_days'
	gen double `pma_weeks' = `pma_days' / 7
	
	tempvar use_ig_nbs use_ig_png use_who_gs
	gigs_zscoring_lgls `use_ig_nbs' `use_ig_png' `use_who_gs' if `touse', ///
		gest_days(`gest_days') age_days(`age_days')

	// 3. Check if data provided, print if so
	if `"`weight_kg'"' == "" & `"`lenht_cm'"' == "" & `"`headcirc_cm'"' == "" {
		di as error "You must supply data using at least one of the " /*
			*/ "{bf:weight_kg()}, {bf:lenht_cm()}, or {bf:headcirc_cm()} " /*
			*/ "options."
		exit 498
	}
	di "Supplied data:"
	if `"`weight_kg'"' == "" {
		local missing_weight 1
	}
	else {
		di "	Weight in kg"
		local missing_weight 0
	}
	if `"`lenht_cm'"' == "" {
		local missing_lenht 1
	}
	else {
		di "	Length/height in cm"
		local missing_lenht 0
	}
	if `"`headcirc_cm'"' == "" {
		local missing_headcirc 1
	}
	else {
		di "	Head circumference in cm"
		local missing_headcirc 0
	}	
	
	// 4. Run analses for `outcomes'
	local bw_centile_done "0"
	foreach outcome in `outcomes' {
		if inlist("`outcome'", "sfga", "svn") {
			if "`missing_weight'" == "1" {
				MissingRequiredData_growth "`outcome'" weight_kg
			}
			capture confirm new var birthweight_centile
			if !_rc {
				qui egen double birthweight_centile = ///
					ig_nbs(`weight_kg', "wfga", "v2c") ///
					if `use_ig_nbs' & `touse', ///
					gest_days(`gest_days') ///
					sex(`sex') sexcode(m="`male'", f="`female'")
				local bw_centile_done "1"
			}
			else {
				if "`bw_centile_done'" == "0" {
					if "`replace'" == "replace" {
						ReplaceExistingVar_growth birthweight_centile
						tempvar birthweight_centile
						qui egen double `birthweight_centile' = ///
							ig_nbs(`weight_kg', "wfga", "v2c") ///
							if `use_ig_nbs' & `touse', ///
							gest_days(`gest_days') ///
							sex(`sex') sexcode(m="`male'", f="`female'")
						qui replace birthweight_centile = `birthweight_centile'
						local bw_centile_done "1"
					}					
					else {
						BadExistingVar_growth birthweight_centile
					}
				}
			}

			if "`outcome'" == "sfga" {
				tempvar sfga_temp sfga_severe_temp
				qui gigs_categorise `sfga_temp' if `touse', ///
					outcome("`outcome'") measure(birthweight_centile) ///
					severe("0")
				qui gigs_categorise `sfga_severe_temp' if `touse', ///
					outcome("`outcome'") measure(birthweight_centile) ///
					severe("1")
				
				// Check if sfga cols already exist
				capture confirm new var sfga
				if !_rc {
					qui gen int sfga = `sfga_temp'
				}
				else {
					if "`replace'" != "replace" { 
						BadExistingVar_growth sfga
					}
					else {
						ReplaceExistingVar_growth sfga
						qui replace sfga = `sfga_temp'
					}
				}
				la val sfga gigs_labs_sfga
				
				capture confirm new var sfga_severe
				if !_rc {
					qui gen int sfga_severe = `sfga_severe_temp'
				}
				else {
					if "`replace'" != "replace" { 
						BadExistingVar_growth sfga_severe
					}
					else {
						ReplaceExistingVar_growth sfga_severe
						qui replace sfga_severe = `sfga_severe_temp'
					}
				}
				la val sfga_severe gigs_labs_sfga_sev		
			}
				
			if "`outcome'" == "svn" {
				tempvar svn_temp
				qui gigs_categorise `svn_temp' if `touse', ///
					outcome("`outcome'") measure(birthweight_centile) ///
					gest_days(`gest_days')
				capture confirm new var svn
				if !_rc {
					qui gen int svn = `svn_temp'
				}				
				else {
					if "`replace'" != "replace" {
						BadExistingVar_growth svn
					}
					else {
						ReplaceExistingVar_growth svn
						qui replace svn = `svn_temp'
					}
				}
				la val svn gigs_labs_svn
			}
		}
			
		if "`outcome'" == "stunting" {
			if "`missing_lenht'" == "1" {
				MissingRequiredData_growth "`outcome'" lenht_cm
			}
			
			tempvar lhaz_temp 
			qui gigs_zscore `lhaz_temp' if `touse', ///
				z_type(lhaz) yvar(`lenht_cm') ///
				age_days(`age_days') gest_days(`gest_days') ///
				sex(`sex') sexc(m="`male'", f="`female'") ///
				outvartype("double") ///
				gigs_lgls(`use_ig_nbs' `use_ig_png' `use_who_gs')
			
			capture confirm new var lhaz
			if !_rc {
				qui gen double lhaz = `lhaz_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth lhaz
				}
				else {
					ReplaceExistingVar_growth lhaz
					qui replace lhaz = `lhaz_temp'
				}
			}
			
			tempvar stunting_temp
			qui gigs_categorise `stunting_temp' if `touse', ///
				outcome("`outcome'") measure(lhaz) outliers("0")
			capture confirm new var stunting
			if !_rc {
				qui gen int stunting = `stunting_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth stunting
				}
				else {
					ReplaceExistingVar_growth stunting
					qui replace stunting = `stunting_temp'
				}
			}
			la val stunting gigs_labs_stunting
			
			tempvar stunting_out_temp
			qui gigs_categorise `stunting_out_temp' if `touse', ///
				outcome("`outcome'") measure(lhaz) outliers("1")
			capture confirm new var stunting_outliers
			if !_rc {
				qui gen int stunting_outliers = `stunting_out_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth stunting_outliers
				}
				else {
					ReplaceExistingVar_growth stunting_outliers
					qui replace stunting_outliers = `stunting_out_temp'
				}
			}
			la val stunting_outliers gigs_labs_stunting_out
		}

		if "`outcome'" == "wasting" {
			if "`missing_weight'" == "1" {
				MissingRequiredData_growth "`outcome'" weight_kg
			}
			if "`missing_lenht'" == "1" {
				MissingRequiredData_growth "`outcome'" lenht_cm
			}
			
			tempvar wlz_temp
			qui gigs_zscore `wlz_temp' if `touse', ///
				z_type(wlz) yvar(`weight_kg') ///
				age_days(`age_days') gest_days(`gest_days') ///
				sex(`sex') sexc(m="`male'", f="`female'") ///
				lenht_cm(`lenht_cm') ///
				gigs_lgls(`use_ig_nbs' `use_ig_png' `use_who_gs')
			
			capture confirm new var wlz
			if !_rc {
				qui gen double wlz = `wlz_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth wlz
				}
				else {
					ReplaceExistingVar_growth wlz
					qui replace wlz = `wlz_temp'
				}
			}
			
			tempvar wasting_temp
			qui gigs_categorise `wasting_temp' if `touse', ///
				outcome("`outcome'") measure(wlz) ///
				outliers("0")
			capture confirm new var wasting
			if !_rc {
				qui gen int wasting = `wasting_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth wasting
				}
				else {
					ReplaceExistingVar_growth wasting
					qui replace wasting = `wasting_temp'
				}
			}
			la val wasting gigs_labs_wasting
			
			tempvar wasting_out_temp
			qui gigs_categorise `wasting_out_temp' if `touse', ///
				outcome("`outcome'") measure(wlz) ///
				outliers("1")
			capture confirm new var wasting_outliers
			if !_rc {
				qui gen int wasting_outliers = `wasting_out_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth wasting_outliers
				}
				else {
					ReplaceExistingVar_growth wasting_outliers
					qui replace wasting_outliers = `wasting_out_temp'
				}
			}
			la val wasting_outliers gigs_labs_wasting_out
		}
		
		if "`outcome'" == "wfa" {
			if "`missing_weight'" == "1" {
				MissingRequiredData_growth "`outcome'" weight_kg
			}
			
			tempvar waz_temp 
			qui gigs_zscore `waz_temp' if `touse', ///
				z_type(waz) yvar(`weight_kg') ///
				age_days(`age_days') gest_days(`gest_days') ///
				sex(`sex') sexc(m="`male'", f="`female'") ///
				outvartype("double") ///
				gigs_lgls(`use_ig_nbs' `use_ig_png' `use_who_gs')
						
			capture confirm new var waz
			if !_rc {
				qui gen double waz = `waz_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth waz
				}
				else {
					ReplaceExistingVar_growth waz
					qui replace waz = `waz_temp'
				}
			}
			
			tempvar wfa_temp
			qui gigs_categorise `wfa_temp' if `touse', ///
				outcome("`outcome'") measure(waz) ///
				outliers("0")
			capture confirm new var wfa
			if !_rc {
				qui gen int wfa = `wfa_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth wfa
				}
				else {
					ReplaceExistingVar_growth wfa
					qui replace wfa = `wfa_temp'
				}
			}
			la val wfa gigs_labs_wfa
			
			tempvar wfa_out_temp
			qui gigs_categorise `wfa_out_temp' if `touse', ///
				outcome("`outcome'") measure(waz) ///
				outliers("1")
			capture confirm new var wfa_outliers
			if !_rc {
				qui gen int wfa_outliers = `wfa_out_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth wfa_outliers
				}
				else {
					ReplaceExistingVar_growth wfa_outliers
					qui replace wfa_outliers = `wfa_out_temp'
				}
			}
			la val wfa_outliers gigs_labs_wfa_out
		}
		
		if "`outcome'" == "headsize" {
			if "`missing_headcirc'" == "1" {
				MissingRequiredData_growth "`outcome'" headcirc_cm
			}
			
			tempvar hcaz_temp
			qui gigs_zscore `hcaz_temp' if `touse', ///
				z_type(hcaz) yvar(`headcirc_cm') ///
				age_days(`age_days') gest_days(`gest_days') ///
				sex(`sex') sexc(m="`male'", f="`female'") ///
				outvartype("double") ///
				gigs_lgls(`use_ig_nbs' `use_ig_png' `use_who_gs')
			
			capture confirm new var hcaz
			if !_rc {
				qui gen double hcaz = `hcaz_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth hcaz
				}
				else {
					ReplaceExistingVar_growth hcaz
					qui replace hcaz = `hcaz_temp'
				}
			}
			
			tempvar headsize_temp
			qui gigs_categorise `headsize_temp' if `touse', ///
				outcome("`outcome'") measure(hcaz)
			capture confirm new var headsize
			if !_rc {
				qui gen int headsize = `headsize_temp'
			}				
			else {
				if "`replace'" != "replace" {
					BadExistingVar_growth headsize
				}
				else {
					ReplaceExistingVar_growth headsize
					qui replace headsize = `headsize_temp'
				}
			}
			la val headsize gigs_labs_headsize
		}
	}	
	qui if "`sex_was_str'" == "0" destring(`sex'), replace
	restore, not
end

capture prog drop GrowthSex_Badsyntax
program GrowthSex_Badsyntax
	di as err "sexcode() option invalid: see {help gigs_classify_growth}"
	exit 198
end

capture prog drop Badsexvar_growth
program Badsexvar_growth
	di as err "sex() option should be a byte, int or str variable: see " /*
	       */ "{help gigs_classify_growth}"
	exit 109
end

capture prog drop BadExistingVar_growth
program BadExistingVar_growth
	args var
	di as error "Variable {bf:`var'} is generated by gigs_classify_growth " /* 
	    */ "but already exists. Either specify the {bf:replace} option or " /*
		*/ "rename the existing variable."
	exit 110
end

capture prog drop ReplaceExistingVar_growth
program ReplaceExistingVar_growth
	args var
	di as text "Variable {bf:`var'} already exists. Replacing..."
end

capture prog drop MissingRequiredData_growth
program MissingRequiredData_growth
	args outcome missing_data
	
	cap assert inlist("`outcome'", "sfga", "svn", "stunting", "wasting", ///
		"wfa", "headsize")
	if _rc == 9 {
		di as error "INTERNAL ERROR in MissingRequiredData_growth: " /*
			*/ "{bf:outcome} arg must be a valid growth outcome string. " /*
			*/ "This is an internal error, so please contact the " /*
			*/ "maintainers of this package if you are an end-user. You can " /*
			*/ "find our details at {help gigs}."
		exit 499
	}
	if "`outcome'" == "sfga" local outcome_str "Size-for-gestational age"
	if "`outcome'" == "svn" local outcome_str "Small vulnerable newborn"
	if "`outcome'" == "wasting" local outcome_str "Wasting"
	if "`outcome'" == "stunting" local outcome_str "Stunting"
	if "`outcome'" == "wfa" local outcome_str "Weight-for-age"
	if "`outcome'" == "headsize" local outcome_str "Head size"
	
	di as error "`outcome_str' outcome requires {bf:`missing_data'}, " /* 
		*/ "which you have not provided."
	exit 498
end
