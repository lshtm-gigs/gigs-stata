*! version 0.3.1 (SJxx-x: dmxxxx)
version 16
mata:
	mata set matastrict on
	
	// Get interpolated coefficients for coefficient-based growth standards
	// 
	// @param colname_xvar Name of a column with x values
	// @param needs_interp Name of a column
	// @param colname_sex Name of a column with sex values
	// @param colname_row Name of a column with row indices
	// @param colnames_coeff Names of columns with coefficients
	// @param colnames_interp Name of a byte variable which shows which
	// observations require interpolation
	// @param colnames_interp Name of a byte variable which shows which
	// observations were appended (so contain coefficients for interpolation)
	// @returns Void. Instead, edits growth standard coefficients in memory, 
	//   replacing missing values with interpolated coefficients where 
	//   appropriate.
	void function gigs_ipolate_coeffs(string scalar colname_xvar,   /*
							       */ string scalar colname_sex,    /*
							       */ string scalar colnames_coeff, /*
							       */ string scalar colname_row,    /*
								   */ string scalar colname_interp, /*
								   */ string scalar colname_append) {
		// Initialise tokenised column names for coeffs + interpolated coeffs
		string rowvector tokens_coeffs
		tokens_coeffs = tokens(colnames_coeff)
		
		// Get x variables and sexes of APPENDED rows
		real rowvector x_appended; real rowvector sex_appended
		real rowvector rows_appended; 
		x_appended = st_data(., colname_xvar, colname_append)
		sex_appended = st_data(., colname_sex, colname_append)
		rows_appended = st_data(., colname_row, colname_append)
		
		// Get x variables, sexes and row indices of rows TO BE INTERPOLATED
		real rowvector x_interp; real rowvector sex_interp;
		real rowvector rows_interp; 
		x_interp = st_data(., colname_xvar, colname_interp)
		sex_interp = st_data(., colname_sex, colname_interp)
		rows_interp = st_data(., colname_row, colname_interp)
		
		// Cut x_appended down to one sex to use in mm_ipolate() --> make sure 
		// to only keep rows where sex = 1 or 0
		real rowvector present_sexes; real rowvector valid_sexes
		present_sexes = uniqrows(sex_interp)
		valid_sexes = present_sexes[mm_which(present_sexes:!=.)]
		real rowvector xvars
		xvars = x_appended[mm_which(sex_appended:==valid_sexes[1])]
		
		// Iterate through the sexes --> 0 for female; 1 for male
		real scalar i; real scalar currsex;
		for (i=0; i<=length(valid_sexes)-1; i++) {
			// Store current sex as integer
			currsex = valid_sexes[i+1]
			
			// Store x vars and row indices for rows which NEED INTERP and have 
			// the current sex
			real rowvector lgl_curr_sex_interp; real rowvector x_curr_interp
			lgl_curr_sex_interp = mm_which(sex_interp:==currsex)
			x_curr_interp = x_interp[lgl_curr_sex_interp]
			real rowvector rows_curr_interp
			rows_curr_interp = rows_interp[lgl_curr_sex_interp]
			
			// Store row indices for APPENDED rows which have current sex
			real rowvector rows_curr_sex_append
			rows_curr_sex_append = rows_appended[mm_which(sex_appended:==currsex)]
			
			// Retrieve coeffs; interpolate w/ mm_ipolate(); store in a view
			real matrix coeff_view; real rowvector coeff
			real scalar idx
			for (idx=1; idx<=length(tokens_coeffs); idx++) {
				coeff = st_data(rows_curr_sex_append, tokens_coeffs[idx])
				coeff = coeff[mm_which(coeff:!=.)]
				st_view(coeff_view, rows_curr_interp, ///
						st_varindex(tokens_coeffs[idx]))
				coeff_view[.,.] = mm_ipolate(xvars, coeff, x_curr_interp)
			}
		}
	}
	
	mata mosave gigs_ipolate_coeffs(), replace
end