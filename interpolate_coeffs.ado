*! version 0.2.4 (SJxx-x: dmxxxx)
version 16
mata:
	mata set matastrict on
	
	// Given the name of a Stata column in memory, return a column vector with
	// integers from rounding each value up and down to the nearest integer
	// description: floor_input_ceil
	// 
	// @param needs_interp Name of a column
	// @param colname_xvar Name of a column
	// @param colname_sex Name of a column
	// @param colname_row Name of a column
	// @param dta_filepath Name of a column
	// @param colnames_coeff Name of a column
	// @param colnames_interped Name of a column
	// @returns Void. Instead, edits growth standard coefficients in memory, 
	//   replacing missing values with interpolated coefficients where 
	//   appropriate.
	void function retrieve_coefficients(string scalar needs_interp, ///
						       string scalar colname_xvar, ///
							   string scalar colname_sex, ///
							   string scalar colname_row, ///
							   string scalar dta_filepath, ///
							   string scalar colnames_coeff, ///							
							   string scalar colnames_interped) {
		// Retrieve data from Stata and use floor/ceil to get surrounding
		// values --> then smush this into its own matrix
		real vector interp_xvar; real vector interp_sex; real vector interp_rows
		interp_xvar = floor_input_ceil(colname_xvar, needs_interp)
		interp_sex = floor_input_ceil(colname_sex, needs_interp)
		interp_rows = floor_input_ceil(colname_row, needs_interp)
		real matrix interp_xvar_sex
		interp_xvar_sex = sort((interp_rows, interp_xvar, interp_sex), (3, 2))
		
		// Make a new, empty frame. This will be used for interpolation.
		string scalar curr_frame 
		curr_frame = st_framecurrent()
		string scalar gigs_interp_frame 
		gigs_interp_frame = "gigs_Q4qRXX6DFCEOykgBFn7hjss75xc"
		st_framecreate(gigs_interp_frame)
		st_framecurrent(gigs_interp_frame)
        
		/* 
		   Within this frame, assign each column of interp_var_sex to columns 
		   named via the function args. Merge on these columns to get coeffs, 
		   then use ipolate to interpolate. Finally, pull these values back 
		   into Mata and remove the new frame.
		*/
		string scalar colname_rowIndex 
		colname_rowIndex = "rowIndex" 
		
		// Convert varlist args to vectors of strings, then test for equality of
		// length
		string rowvector tokens_coeffs
		tokens_coeffs = tokens(colnames_coeff)
		string rowvector tokens_interped
		tokens_interped = tokens(colnames_interped)
		if (length(tokens_coeffs) != length(tokens_interped)) {
			_error("colnames_coeff and colnames_interped should contain " + ///
			       "the same number of columns")
		}
		
		// Send rowIndex, xvar column, sex column into new frame
		real scalar i; string vector vec_colname
		vec_colname = (colname_rowIndex, colname_xvar, colname_sex)
		for (i=1; i<=length(vec_colname); i++) {
			send_to_stata(interp_xvar_sex[., i], vec_colname[i])
		}
			
		// Remove duplicated rows, merge, interpolate + keep only interped rows
		stata("qui duplicates drop")
		stata("qui merge m:1 " + colname_xvar + " " + colname_sex + ///
		      " using " + dta_filepath + ", keep(1 3) nogenerate")			  
		string scalar ipolate_str
		for (i=1; i<=length(tokens_coeffs); i++) {
 			ipolate_str = "ipolate " + tokens_coeffs[i] + " " + ///
				colname_xvar + ", gen(" + tokens_interped[i]  + ")"
			stata(ipolate_str)
		}
		stata("qui drop if " + tokens_coeffs[1] + " != .")
		
		// Store interpolated coefficients and which row each belongs to
		real rowvector interped_rows
		interped_rows = st_data(., colname_rowIndex)
		real matrix interped_coeffs
		interped_coeffs = st_data(., colnames_interped)
		
		// Interpolated coeffs are now in Mata - so return to original frame
		st_framecurrent(curr_frame)
		st_framedrop(gigs_interp_frame)
		
		// Get view of observations which needed interpolation; use for loops
		// to reassign these values
		real scalar nrow
		nrow = rows(interped_coeffs)
		real matrix needed_interp
		needed_interp = .
		st_view(needed_interp, interped_rows, st_varindex(tokens_coeffs))
		for (i=1; i<=nrow; i++) {
			needed_interp[i,.] = interped_coeffs[i,.]		
		}
	}
	
	// Given the name of a Stata column in memory, return a column vector with
	// results from floor(), the original values, then results from ceil()
	// 
	// @param col_name Name of a column
	// @param mask_col Column with `1`s and `0`s used to subset the column 
	//   specified by `col_name'
	// @returns Real vector with a length that is three times the number of 
	//     values in `col_name` allowed by `mask_col`.
	real vector floor_input_ceil(string scalar col_name, ///
								 string scalar mask_col) {
		real vector floor_ceil_vec
		floor_ceil_vec = st_data(., col_name, mask_col)
		floor_ceil_vec = (floor(floor_ceil_vec), ///
		                  floor_ceil_vec, ///
					      ceil(floor_ceil_vec))
		floor_ceil_vec = colshape(floor_ceil_vec, 1)
		return(floor_ceil_vec)
	}
	
	// Send a Mata vector to Stata
	// 
	// @param values Real vector to send to Stata.
	// @param colname Name of new Stata column. Function will fail if `colname`
	//   matches an existing column.
	// @returns Void. Instead, edits Stata dataset to include a column with the
	//   data in `values`.
	void send_to_stata(real vector values, ///
		               string scalar colname) {
		st_matrix(colname, values)
		stata("qui svmat double " + colname)
		stata("rename " + colname + "1 " + colname)			   	
	} 
end