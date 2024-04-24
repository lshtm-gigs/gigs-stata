capture prog drop gigs_zscoring_lgls
*! version 0.1.0 (SJxx-x: dmxxxx)
program gigs_zscoring_lgls
	version 16
	preserve
	syntax newvarlist(default=none min=3 max=3 numeric) [if] [in] , /// 
		age_days(varname numeric) gest_days(varname numeric)
	marksample touse, novarlist
	
	local use_ig_nbs "`1'"
	local use_ig_png "`2'"
	local use_who_gs : subinstr local 3 "," ""
	
	qui {
		tempvar pma_days pma_weeks 
		gen double `pma_days' = `age_days' + `gest_days'
		gen double `pma_weeks' = `pma_days' / 7
	
		tempvar is_term is_birth_measurement is_inrange_nbs is_inrange_png
		gen byte `is_term' = float(`gest_days') >= 259
		gen byte `is_birth_measurement' = float(`age_days') < 0.5
		gen byte `is_inrange_nbs' = ///
			float(`gest_days') >= 168 & float(`gest_days') <= 300
		gen byte `is_inrange_png' = ///
			float(`pma_weeks') >= 27 & float(`pma_weeks') <= 64
		
		gen byte `use_ig_nbs' = `touse' & ///
			`is_birth_measurement' & `is_inrange_nbs'
		gen byte `use_ig_png' = `touse' & ///
			!`is_birth_measurement' & !`is_term' & `is_inrange_png'
		gen byte `use_who_gs' = `touse' & ///
			!`is_birth_measurement' & ///
			(`is_term' | (!`is_term' & `pma_weeks' > 64))
		
		tempvar data_is_missing
		gen byte `data_is_missing' = missing(`age_days') | missing(`gest_days')
		replace `use_ig_nbs' = 0 if `data_is_missing'
		replace `use_ig_png' = 0 if `data_is_missing'
		replace `use_who_gs' = 0 if `data_is_missing'
	}
	restore, not
end

