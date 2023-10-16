// TODO: Add code to run who_gs for inputs from 1 to 10 to 100 to 1000

use benchmarking/benchmark_insobs.dta, clear

qui gen int interp = 0
qui replace interp = 1 if 0 != mod(test, 1) & test >= 1  & test <= 10
qui levelsof interp, clean local(interp_local)
while inlist(`interp_local', 1) == 1 {
		forval i=1/`=_N' {
			if interp[`i'] == 1 {
				qui replace interp = 0 if _n == `i'
				qui insobs 1, before(`i')
				qui insobs 1, after(`i' + 1)
				continue, break
			}
		}
		macro drop interp_local
		qui levelsof interp, clean local(interp_local)
	}
qui replace interp = 1 if 0 != mod(test, 1) & test >= 1  & test <= 10

qui replace test = floor(test[_n+1]) /*
		*/ if 0 != mod(test[_n+1],1) /*
		*/ & test == .
qui replace test = test[_n+1] /*
		*/ if 0 != mod(test[_n+1],1) /*
		*/ & test == . 
	
	// Replace xvar + sex if PREVIOUS ROW contains missing LMS
qui replace test = ceil(test[_n-1]) /*
		*/ if 0 != mod(test[_n-1],1) /*
		*/ & test == .
qui replace test = test[_n-1] /*
		*/ if 0 != mod(whoLMS_xvar[_n-1],1) /*
		*/ & whoLMS_sex == .