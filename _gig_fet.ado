capture program drop _gig_fet
*! version 0.1.0 (SJxx-x: dmxxxx)
program define _gig_fet
 	version 16
	preserve

	gettoken type 0 : 0
	gettoken return 0 : 0
	gettoken eqs  0 : 0
	gettoken paren 0 : 0, parse("(), ")
	gettoken input 0 : 0, parse("(), ")
	gettoken acronym  0 : 0, parse("(), ")
	if `"`acronym'"' == "," {
		gettoken acronym  0 : 0, parse("(), ")
	}
	gettoken conversion  0 : 0, parse("(), ")
 	if `"`conversion'"' == "," {
		gettoken conversion  0 : 0, parse("(), ")
	}
	gettoken paren 0 : 0, parse("(), ")
	if `"`paren'"' != ")" {
		error 198
	}
	capture assert inlist("`acronym'", "hcfga", "bpdfga", "acfga", "flfga", /*
	*/                    "ofdfga", "efwfga")
	if _rc {
		di as text "`acronym'" as error " is an invalid acronym. The only " /*
		*/ as error "valid choices are " as text "hcfga, bpdfga, acfga," /*
		*/ as text " flfga, ofdfga" as error "or" as text " efwfga" /*
		*/ as error "."
		exit 198
	}
	capture assert inlist("`conversion'", "v2c", "v2z", "c2v", "z2v")
	if _rc {
		di as text "`conversion'" as error " is an invalid chart code. The " /*
		*/ as error "only valid choices are " as text "v2c, v2z, c2v," as /*
		*/ error " or " as text "z2v" as error "."
		exit 198
	}
	
	syntax [if] [in], GEST_days(varname numeric) [BY(string)]
	
	if `"`by'"' != "" {
		_egennoby ig_fet() `"`by'"'
		/* NOTREACHED */
	}
	
    marksample touse
	qui generate `type' `return' = .
	tempvar check_ga GA q p z
	qui {
		gen double `GA' = `gest_days' / 7
		if "`acronym'" == "efwfga" {
			tempvar L M S
			gen double `L' = -4.257629 - 2162.234 * `GA'^-2 /*
				*/ + 0.0002301829 * `GA'^3
			replace `L' = 0 if abs(`L') < 1.414 * 10^-16
			gen double `M' = 4.956737 + 0.0005019687 * `GA'^3 /*
				*/ - 0.0001227065 * `GA'^3 * log(`GA') 
			gen double `S' = 10^-4 * (-6.997171 + 0.057559 * `GA'^3 - /*
				*/ 0.01493946 * `GA'^3 * log(`GA'))
			if "`conversion'" == "v2c" | "`conversion'" == "v2z" {
				tempvar log_efw
				gen double `log_efw' = log(`input')
				replace `return' = `S'^-1 * log(`log_efw'/`M') if `L' == 0
				replace `return' = (`S' * `L')^-1 * ((`log_efw'/`M')^`L' - 1) /* 
					*/ if `L' != 0
				if "`conversion'" == "v2c" {
					replace `return' = normal(`return')
				}
			}
			else if "`conversion'" == "c2v" | "`conversion'" == "z2v" {
				gen double `z' = `input'
				if "`conversion'" == "c2v" {
					replace `z' = invnormal(`input')
				}
				replace `return' = `M' * exp(`S' * `z') if `L' == 0
				replace `return' = `M' * (`z' * `S' * `L' + 1)^(1/`L') /*
					*/ if `L' != 0
				replace `return' = exp(`return')
			}
		}
		else {
			tempvar mu sigma
			gen double `mu' = .
			gen double `sigma' = .
			if "`acronym'" == "hcfga" {
				replace `mu' = -28.2849 + 1.69267 * `GA'^2 - /*
					*/ 0.397485 * `GA'^2 * log(`GA')
				replace `sigma' = 1.98735 + 0.0136772 * `GA'^3 - /*
					*/ 0.00726264 * `GA'^3 * log(`GA') +/*
					*/ 0.000976253 * `GA'^3 * log(`GA')^2
			}
			else if "`acronym'" == "bpdfga" {
				replace `mu' = 5.60878 + 0.158369 * `GA'^2 - 0.00256379 * `GA'^3
				replace `sigma' = exp(0.101242 + 0.00150557 * `GA'^3 - /*
					*/ 0.000771535 * `GA'^3 * log(`GA') + /*
					*/ 0.0000999638 * `GA'^3 * log(`GA')^2)
			}
			else if "`acronym'" == "acfga" {
				replace `mu' = -81.3243 + 11.6772 * `GA' - 0.000561865 * `GA'^3
				replace `sigma' = -4.36302 + 0.121445 * `GA'^2 - /*
					*/ 0.0130256 * `GA'^3 + 0.00282143 * `GA'^3 * log(`GA')
			}
			else if "`acronym'" == "flfga" {
				replace `mu' = -39.9616 + 4.32298 * `GA' - 0.0380156 * `GA'^2
				replace `sigma' = exp(0.605843 - 42.0014 * `GA'^-2 + /*
					*/ 0.00000917972 * `GA'^3)
			}
			else if "`acronym'" == "ofdfga" {
				replace `mu' = -12.4097 + 0.626342 * `GA'^2 - /*
					*/ 0.148075 * `GA'^2 * log(`GA')
				replace `sigma' = exp(-0.880034 + 0.0631165 * `GA'^2 - /*
					*/ 0.0317136 * `GA'^2 * log(`GA') /*
					*/ + 0.00408302 * `GA'^2 * log(`GA')^2)
			}
			if "`conversion'" == "v2c" | "`conversion'" == "v2z" {
				gen double `q' = `input'
				gen double `z' = (`q' - `mu') / `sigma'
				replace `return' = `z'
				if "`conversion'" == "v2c" {
					qui replace `return' = normal(`z')  
				}
			}
			else if "`conversion'" == "c2v" | "`conversion'" == "z2v" {
				gen double `z' = `input'
				if "`conversion'" == "c2v" {
					replace `z' = invnormal(`input')  
				}
				gen double `q' = `mu' + `z' * `sigma'
				replace `return' = `q'
			} 
		}
		gen `check_ga' = `gest_days' >= 98 & `gest_days' <= 280 /// 
			if "`acronym'" != "efwfga"
		replace `check_ga' = `gest_days' >= 154 & `gest_days' <= 280 /// 
			if "`acronym'" == "efwfga"
		replace `return' = . ///
  	        if  `check_ga' == 0 | `touse' == 0
    }
 	restore, not 
end
