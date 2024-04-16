capture program drop gigs_classify_growth
*! version 0.0.1 (SJxx-x: dmxxxx)
program define gigs_classify_growth
	version 16
	preserve
	syntax anything(name=analyses id="analyses") [if] [in] , /*
		*/ GEST_days(varname numeric) age_days(varname numeric) /*
 		*/ sex(varname) SEXCode(string) /*
 		*/ [weight_kg(varname numeric) lenht_cm(varname numeric) /*
 		*/  headcirc_cm(varname numeric) replace]
	
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
	
	// 1. Get `analyses' sorted 
	di "Requested analyses:"
	foreach analysis in "`analyses'" {
		capture assert inlist("`analysis'", "sfga", "svn", "stunting", ///
		                      "wasting", "wfa", "headsize") {
		if !_rc {	
			di as text "`analysis'" as error " is an invalid analysis. The " /*
			*/ as error "only valid analyses are " as text "sfga, svn, " /*
			*/ as text "stunting, wasting, wfa " as error "or" /*
			*/ as text " headsize" as error "."
			exit 198
		} 
		di "	`analysis'"
	}
	
	// 2. Get gigs logicals
	tempvar pma_days pma_weeks 
	gen double `pma_days' = `age_days' + `gest_days'
	gen double `pma_weeks' = `pma_days' / 7
	qui replace `pma_weeks' = . if `pma_weeks' < 27 | `pma_weeks' > 64
	
	tempvar is_term is_birth_measurement is_inrange_nbs is_inrange_png
	local term_cutoff_days = 37 * 7
	gen byte `is_term' = `gest_days' >= `term_cutoff_days'
	gen byte `is_birth_measurement' = `age_days' < 0.5
	gen byte `is_inrange_nbs' = `gest_days' >= 168 & `gest_days' <= 300
	gen byte `is_inrange_png' = `pma_weeks' >= 27 & `pma_weeks' <= 64
	
	tempvar use_ig_nbs use_ig_png use_who_gs
	gen byte `use_ig_nbs' = !`is_birth_measurement' & `is_inrange_nbs'
	gen byte `use_ig_png' = !`is_birth_measurement' & !`is_term' & /*
		*/ `is_inrange_png'
	gen byte `use_who_gs' = !`is_birth_measurement' & `is_term' | /*
		*/ (!`is_term' & `pma_weeks' > 64)
	
	tempvar is_missing
	gen byte `is_missing' = missing(`age_days') | missing(`gest_days')
	qui {
		replace `use_ig_nbs' = 0 if `is_missing'
		replace `use_ig_png' = 0 if `is_missing'
		replace `use_who_gs' = 0 if `is_missing'
	}

	// 3. Check if data provided, print if so
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
	
	// 4. Run analyses in `analyses' based on
	local bw_centile_done "0"
	foreach analysis in `analyses' {
		if inlist("`analysis'", "sfga", "svn") {
			capture confirm new var birthweight_centile, exact
			if !_rc  {
				qui egen double birthweight_centile = ///
					ig_nbs(`weight_kg', "wfga", "v2c") ///
					if `is_birth_measurement', ///
					gest_days(`gest_days') ///
					sex(`sex') sexcode(m="`male'", f="`female'")
				local bw_centile_done "1"
			}
			else {
				if "`bw_centile_done'" == "0" {
					if "`replace'" == "replace" {
						di as text "{bf:birthweight_centile} already " /* 
							*/ "exists. Replacing..."
						tempvar birthweight_centile
						qui egen double `birthweight_centile' = ///
							ig_nbs(`weight_kg', "wfga", "v2c") ///
							if `is_birth_measurement', ///
							gest_days(`gest_days') ///
							sex(`sex') sexcode(m="`male'", f="`female'")
						qui replace birthweight_centile = `birthweight_centile'
						local bw_centile_done "1"
					}					
				
					else {
						di as error "{bf:birthweight_centile} already " /*
							*/ "exists. Either specify the {bf:replace} " /*
							*/ "option or rename the existing variable."
						exit 110
					}
				}
			}

			if "`analysis'" == "sfga" {
				// Check if sfga cols already exist
				if "`replace'" != "replace" {
					foreach var in sfga sfga_severe {
						capture confirm new var `var'
						if !_rc {
							di as error "{bf:`var'} is used by " /* 
								*/ "gigs_classify_growth. Either specify the " /*
								*/ "{bf:replace} option or rename the existing " /*
								*/ "variable."
							exit 110
						}
					}
				}
				qui {
					egen sfga = classify_sfga(`weight_kg') /*
						*/ if `is_birth_measurement', /*
						*/ gest_days(`gest_days') /*
						*/ sex(`sex') sexcode(m="`male'", f="`female'")
					egen sfga_severe = classify_sfga(`weight_kg') /*
						*/ if `is_birth_measurement', /*
						*/ gest_days(`gest_days') /*
						*/ sex(`sex') sexcode(m="`male'", f="`female'") severe				
				}
			}
			if "`analysis'" == "svn" {
				// Check if svn col already exists
				capture confirm new var svn
				if !_rc {
					qui egen svn = classify_svn(`weight_kg') /*
					*/ if `is_birth_measurement', /*
					*/ gest_days(`gest_days') /*
					*/ sex(`sex') sexcode(m="`male'", f="`female'")
				}				
				else {
					if "`replace'" != "replace" {
						di as error "{bf:svn} is used by " /* 
							*/ "gigs_classify_growth. Either specify the " /*
							*/ "{bf:replace} option or rename the existing " /*
							*/ "variable."
						exit 110
					}
					else {
						tempvar svn
						qui egen `svn' = classify_svn(`weight_kg') /*
							*/ if `is_birth_measurement', /*
							*/ gest_days(`gest_days') /*
							*/ sex(`sex') sexcode(m="`male'", f="`female'")
						qui replace svn = `svn'
					}
				}
			}	
		}
	}
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