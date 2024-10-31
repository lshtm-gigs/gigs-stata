capture prog drop gigs_zscoring_lgls
*! version 0.2.0 (SJxx-x: dmxxxx)
program gigs_zscoring_lgls
	version 16
	preserve
	syntax newvarlist(default=none min=3 max=3 numeric) [if] [in] , /// 
		age_days(varname numeric) gest_days(varname numeric) ///
		[id(varname string)]
	marksample touse, novarlist
	
	local use_ig_nbs "`1'"
	local use_ig_png "`2'"
	local use_who_gs : subinstr local 3 "," ""
	
	qui {
		tempvar pma_days pma_weeks 
		gen double `pma_days' = `age_days' + `gest_days'
		gen double `pma_weeks' = `pma_days' / 7
		
		// if ID is provided, run with `by'
		tempvar min_age_days is_first_measure
		if "`id'" == "" {
			egen double `min_age_days' = min(`age_days')
		}
		else {
			tempvar sortvar
			gen double  `sortvar' = _n
			by `id', sort: ///
				egen double `min_age_days' = min(`age_days')
			sort `sortvar'
		}
		gen byte `is_first_measure' = 1 if `min_age_days' == `age_days'
			
		tempvar is_term is_birth_measurement is_inrange_nbs is_inrange_png
		gen byte `is_birth_measurement' = ///
		  `is_first_measure' == 1 & float(`age_days') < 3
		gen byte `is_inrange_nbs' = ///
			float(`gest_days') >= 168 & float(`gest_days') <= 300
		gen byte `is_inrange_png' = ///
			float(`pma_weeks') >= 27 & float(`pma_weeks') <= 64
		
		gen byte `is_term' = float(`gest_days') >= 259

		gen byte `use_ig_nbs' = `touse' & ///
			`is_birth_measurement' & `is_inrange_nbs'
		gen byte `use_ig_png' = `touse' & ///
			!`is_birth_measurement' & !`is_term' & `is_inrange_png'
		// Using 'use_ig_nbs' here means that birth measures in infants w/ 
		// GA >42+6 wks still get a zscore, just from the WHO standards.
		gen byte `use_who_gs' = `touse' & ///
			!`use_ig_nbs' & ///  NOT USING `!is_birth_measurement'
			(`is_term' | (!`is_term' & `pma_weeks' > 64))
		replace `use_who_gs' = 1 if `is_birth_measurement' & `gest_days' > 300
		
		tempvar data_is_missing
		gen byte `data_is_missing' = missing(`age_days') | missing(`gest_days')
		replace `use_ig_nbs' = 0 if `data_is_missing'
		replace `use_ig_png' = 0 if `data_is_missing'
		replace `use_who_gs' = 0 if `data_is_missing'
	}
	
	// Issue warnings about:
	// 1. No. of `at birth' measures taken >0.5 days
	qui count if `is_birth_measurement' == 1 & `age_days' > 0.5
	if (r(N) > 0) {
		di as result "NOTE: " as text "There were {bf:`r(N)'} birth " ///
			as text "observations where {bf:\`age_days' > 0.5}."
	}
	
	// 2. No. of birth measures requiring WHO GS
	qui count if `is_birth_measurement' == 1 & `gest_days' > 300
	if (r(N) > 0) {
		if (r(N) == 1) {
			local waswere "was"
			local measure_s "measure"
			local thisinfantwill "This infant will"
		} 
		else {
			local waswere "were"
			local measure_s "measures"
			local thisinfantwill "These infants will"
		}
		di as result "NOTE: " as text "There `waswere' {bf:`r(N)'} birth " ///
			as text "`measure_s' where an infant was too old for the "
		di as text "      INTERGROWTH-21st Newborn Size standards " ///
			as text "{bf:(\`gest_age' > 300)}."
		di as text "      `thisinfantwill' be assessed with the WHO " ///
			as text "Growth Standards instead."
	}
	
	restore, not
end
