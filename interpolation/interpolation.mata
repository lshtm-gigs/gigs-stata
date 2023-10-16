cap frame change default
cap frame drop gigs_Q4qRXX6DFCEOykgBFn7hjss75xc
use interpolation/interpolation_tester.dta, clear

local basename = "whoLMS_" + "wfa" + ".dta"
qui findfile "`basename'"
local filepath = "`r(fn)'"
//tempvar n
//gen `n' = _n
gen n = _n
qui merge 1:m whoLMS_xvar whoLMS_sex using "`filepath'", keep(1 3) nogenerate

// Step 0: Set `xlimlow' and `xlimhigh'
local xlimlow = 0
local xlimhigh = 1856

// Step 1: Identify rows needing interpolation
tempvar xvar row_index
qui gen `xvar' = whoLMS_xvar
qui gen int interp = 0
qui replace interp = 1 if ///
	0 != mod(whoLMS_xvar, 1) & `xvar' >= `xlimlow'  & `xvar' <= `xlimhigh'
qui gen `row_index' = _n 

mata:
	mata set matastrict on
	mata clear
	real matrix interpolate_coeffs(string scalar interp_col, ///
								   string scalar xvar_col, ///
								   string scalar sex_col, ///
								   string scalar row_col, ///
								   string scalar dta_filepath, 
								   string scalar coeff_cols)
	{
		real matrix xvar_to_interp 
        real matrix sex_to_interp
		real matrix rows_to_interp
		
		xvar_to_interp = st_data(., xvar_col, interp_col)
		sex_to_interp = st_data(., sex_col, interp_col)
		rows_to_interp = st_data(., row_col, interp_col)
		
		real matrix interp_xvar
		interp_xvar = (floor(xvar_to_interp), ///
		               xvar_to_interp, ///
					   ceil(xvar_to_interp))
		interp_xvar = colshape(interp_xvar, 1)
		
		real matrix interp_sex
		interp_sex = (sex_to_interp , sex_to_interp , sex_to_interp)
		interp_sex = colshape(interp_sex, 1)
		
		real matrix interp_rows
		interp_rows = (rows_to_interp , rows_to_interp, rows_to_interp)
		interp_rows = colshape(interp_rows, 1)
		
		real matrix interp_xvar_sex
		interp_xvar_sex = sort((interp_rows, interp_xvar, interp_sex), (3, 2))
		
		// Make a new frame for interpolation
		string scalar curr_frame 
		curr_frame = st_framecurrent()
		string scalar gigs_interp_frame 
		gigs_interp_frame = "gigs_Q4qRXX6DFCEOykgBFn7hjss75xc"
		st_framecreate(gigs_interp_frame)
		st_framecurrent(gigs_interp_frame)
        
		/* 
		   Within this frame, assign each column of interp_var_sex to a 
		   column named with the function args. Merge on these columns to
		   get your coeffs, then use ipolate to interpolate. Finally,
		   pull these values back into Mata before destroying it with
		   st_framedrop().		
		*/
		
		string scalar row_colname 
		row_colname = "rowIndex" 
		st_matrix(row_colname, interp_xvar_sex[., 1])
		stata("qui svmat double " + row_colname)
		stata("rename " + row_colname + "1 " + row_colname)
				
		st_matrix(xvar_col, interp_xvar_sex[., 2])
		stata("qui svmat double " + xvar_col)
		stata("rename " + xvar_col + "1 " + xvar_col)

		st_matrix(sex_col, interp_xvar_sex[., 3])
		stata("qui svmat double " + sex_col)
		stata("rename " + sex_col + "1 " + sex_col)
				
		// Remove duplicated rows
		stata("qui duplicates drop")
		stata("qui merge m:1 whoLMS_xvar whoLMS_sex using " /// 
			  + dta_filepath + ", keep(1 3) nogenerate")
		stata("ipolate whoLMS_L whoLMS_xvar, generate(iL)")
		stata("ipolate whoLMS_M whoLMS_xvar, gen(iM)")
		stata("ipolate whoLMS_S whoLMS_xvar, gen(iS)")
		stata("drop if whoLMS_L != .")
		
		
// 		st_framecurrent(curr_frame)
// 		st_framedrop(gigs_interp_frame)
		return(interp_xvar_sex)
	}
end

mata interpolate_coeffs("interp", ///
                        "whoLMS_xvar", ///
						"whoLMS_sex", ///
                        "`row_index'", ///
						"`filepath'", ///
						"whoLMS_L whoLMS_M whoLMS_S")