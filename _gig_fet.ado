capture program drop _gig_fet
*! version 0.2.2 (SJxx-x: dmxxxx)
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
	
	// inlist() only takes 10 args when using strings, so need to do this chain
	capture assert inlist("`acronym'", "hcfga", "bpdfga", "acfga", "flfga", /*
	            */        "ofdfga", "efwfga", "sfhfga", "crlfga", "gafcrl") | /*
				*/ inlist("`acronym'", "gwgfga", "pifga", "rifga", "sdrfga", /*
				*/ 		  "tcdfga", "gaftcd", "poffga", "sffga", "avfga") | /*
	            */ inlist("`acronym'", "pvfga", "cmfga", "hefwfga")
	if _rc == 9 {
		di as text "`acronym'" as error " is an invalid acronym. The only " /*
		*/ as error "valid choices are " as text "hcfga, bpdfga, acfga," /*
		*/ as text " flfga, ofdfga, efwfga, sfhfga, crlfga, gafcrl, gwgfga" /*
		*/ as text " pifga, rifga, sdrfga, tcdfga, gaftcd, poffga, sffga" /*
		*/ as text " avfga, pvfga, cmfga" as error " or " as text " hefwfga" /*
		*/ as error "."
		exit 198
	}
	capture assert inlist("`conversion'", "v2c", "v2z", "c2v", "z2v")
	if _rc == 9 {
		di as text "`conversion'" as error " is an invalid conversion code. " /*
		*/ as error "The only valid choices are " as text "v2c, v2z, c2v," as /*
		*/ error " or " as text "z2v" as error "."
		exit 198
	}
	
	syntax [if] [in], Xvar(varname numeric) [BY(string)]
	
	if `"`by'"' != "" {
		_egennoby ig_fet() `"`by'"'
		/* NOTREACHED */
	}
	
    marksample touse
	qui generate `type' `return' = .
	tempvar check_x GA TCD CRL q p z // GA, CRL, TCD all used as x variables
	qui {
		gen double `GA' = `xvar' / 7
		if inlist("`acronym'", "efwfga", "hefwfga") {
			tempvar L M S GA_cubed
			gen double `GA_cubed' = `GA'^3
			if "`acronym'" == "efwfga" {
				tempvar efwfga_coeff
				gen double `efwfga_coeff' = log(`GA') * `GA_cubed'
				gen double `L' = -4.257629 - 2162.234 * `GA'^-2 /*
					*/ + 0.0002301829 * `GA_cubed'
				gen double `M' = 4.956737 + 0.0005019687 * `GA_cubed' /*
					*/ - 0.0001227065 * `efwfga_coeff'
				gen double `S' = 1e-04 * (-6.997171 + 0.057559 * `GA_cubed' - /*
					*/ 0.01493946 * `efwfga_coeff')
			}
			else {
				tempvar GA_10 hefwfga_coeff
				gen double `GA_10' = `GA' / 10
				gen double `hefwfga_coeff' = log(`GA_10') * (`GA_10')^(-2)
				gen double `L' = 9.43643 + 9.41579 * (`GA_10')^(-2) - /*
					*/ 83.54220 * `hefwfga_coeff'
				gen double `M' = -2.42272 + 1.86478 * `GA'^0.5 - /*
					*/ 1.93299e-5 * `GA_cubed'
				gen double `S' = 0.0193557  + 0.0310716 * (`GA_10')^(-2) - /*
					*/ 0.0657587 * `hefwfga_coeff'
			}
			replace `L' = 0 if abs(`L') < 1.414 * 10^-16
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
		else if inlist("`acronym'", "pifga", "rifga", "sdrfga") {
			tempvar L M S
			gen double `L' = .
			gen double `M' = .
			gen double `S' = .
			if "`acronym'" == "pifga" {
				replace `L' = -0.0768617
				replace `M' = 1.02944 + 77.7456 * `GA'^-2 - /*
					*/ 0.000004455 * `GA'^3
				replace `S' = -0.00645693 + 254.885 * log(`GA') * `GA'^-2 - /*
					*/ 715.949 * `GA'^-2
			}
			else if "`acronym'" == "rifga" {
				replace `L' = 0.0172944
				replace `M' = 0.674914 + 25.3909 * `GA'^-2 - /*
					*/ 0.0000022523 * `GA'^3
				replace `S' = 0.0375921 + 60.7614 * log(`GA') * `GA'^-2 - /*
					*/ 183.336 * `GA'^-2
			}
			else if "`acronym'" == "sdrfga" {
				replace `L' = -0.2752483
				replace `M' = 2.60358 + 445.991 * `GA'^-2 - /*
					*/ 0.0000108754 * `GA'^3
				replace `S' = -0.503202 + 1268.37 * log(`GA') * `GA'^-2 - /*
					*/ 3417.37 * `GA'^-2
			}
			if "`conversion'" == "v2c" | "`conversion'" == "v2z" {
				gen double `q' = `input'
				gen double `z' = (exp((`q' - `M') * `L' * `S'^-1) - 1) / `L'
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
				gen double `q' = `M' + `S' * log(1 + `L' * `z') / `L'
				replace `return' = `q'
			} 
		}
		else if "`acronym'" == "gwgfga" {
			tempvar mu sigma
			gen double `mu' = 1.382972 - 56.14743 * `GA'^-2 + /*
				*/ 0.2787683 * `GA'^0.5
			gen double `sigma' = 0.2501993731 + 142.4297879 * `GA'^-2 - /*
				*/ 61.45345 * `GA'^-2 * log(`GA')
			if "`conversion'" == "v2c" | "`conversion'" == "v2z" {
				gen double `q' = `input'
				gen double `z' = (log(`q'+ 8.75) - `mu') / `sigma'
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
				gen double `q' = exp(`mu' + `z' * `sigma') - 8.75
				replace `return' = `q'
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
			else if "`acronym'" == "sfhfga" {
				replace `mu' = 5.133374 + 0.1058353119 * `GA'^2 -  /*
					*/ 0.0231295 * `GA'^2 * log(`GA')
				replace `sigma' = 0.9922667 + 0.0258087 * `GA'
			}
			else if "`acronym'" == "crlfga" {
				replace `mu' = -50.6562 + (0.815118 * `GA' * 7) + /*
					*/ (0.00535302 * (`GA' * 7)^2)
				replace `sigma' = -2.21626 + 0.0984894 * `GA' * 7
			}
			else if "`acronym'" == "gafcrl" {
				gen double `CRL' = `xvar'
				replace `mu' = 40.9041 + 3.21585 * `CRL'^0.5 + 0.348956 * `CRL'
				replace `sigma' = 2.39102 + 0.0193474 * `CRL'
			}
			else if "`acronym'" == "tcdfga" {
				replace `mu' = -13.10907 + 20.8941 * (`GA'/10)^0.5 + /*
					*/ 0.5035914 * (`GA'/10)^3
				replace `sigma' = 0.4719837 + 0.0500382 * (`GA'/10)^3
			}
			else if "`acronym'" == "gaftcd" {
				gen double `TCD' = `xvar'
				replace `mu' = 7 * (3.957113 + 8.154074 * `TCD'/10 - /*
					*/ 0.076187 * (`TCD'/10)^3)
				replace `sigma' = 7 * (1.577198 -1.30374 * (`TCD'/10)^-0.5)
			}
			else if "`acronym'" == "poffga" {
				replace `mu' = 10.29428 - (122.8447 * `GA'^-1) + /*
					*/ (0.00001038 * `GA'^3)
				replace `sigma' = 1.596042 - (257.2297 * `GA'^-2)
			}
			else if "`acronym'" == "sffga" {
				replace `mu' = 80.27012 - (32.7877 * `GA'^-0.5) - /*
					*/ (100.1593 * `GA'^-0.5 * log(`GA'))
				replace `sigma' = 2.304501 - (353.814 * `GA'^-2)
			}
			else if "`acronym'" == "avfga" {
				replace `mu' = 6.396214 + (0.00006205 * `GA'^3)
				replace `sigma' = 1.204454
			}
			else if "`acronym'" == "pvfga" {
				replace `mu' = 4.389214 + (38.10015 * `GA'^-1) + /*
					*/ (0.0000020063 * `GA'^3)
				replace `sigma' = 0.6707227 + (0.034258 * `GA')
			}
			else if "`acronym'" == "cmfga" {
				// n.b. is logarithmic, hence specific conversion below
				replace `mu' = 2.098095 - (239.0659 * `GA'^-2) - /*
					*/ 0.0000001547 * `GA'^3
				replace `sigma' = 0.2297936 + (8.1872 * `GA'^-2)
			}
			if "`conversion'" == "v2c" | "`conversion'" == "v2z" {
				gen double `q' = `input'
				replace `q' = log(`q') if "`acronym'" == "cmfga"
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
				replace `return' = exp(`q') if "`acronym'" == "cmfga"
			}
		}
		
		// Check if x variable within appropriate bounds
		if inlist("`acronym'", "poffga", "sffga", "avfga", "pvfga", "cmfga") {
			gen `check_x' = `xvar' >= 105 & `xvar' <= 252
		}
		else if inlist("`acronym'", "pifga", "rifga", "sdrfga") {
			gen `check_x' = `xvar' >= 168 & `xvar' <= 280
		}
		else if "`acronym'" == "efwfga" {
			gen `check_x' = `xvar' >= 154 & `xvar' <= 280
		}
		else if "`acronym'" == "sfhfga" {
			gen `check_x' = `xvar' >= 112 & `xvar' <= 294
		}
		else if "`acronym'" == "crlfga" {
			gen `check_x' = `xvar' >= 58 & `xvar' <= 105
		}
		else if "`acronym'" == "gafcrl" {
			gen `check_x' = `xvar' >= 15 & `xvar' <= 95
		}
		else if "`acronym'" == "gaftcd" {
			gen `check_x' = `xvar' >= 12 & `xvar' <= 55
		}
		else if "`acronym'" == "hefwfga" {
			gen `check_x' = `xvar' >= 126 & `xvar' <= 287
		}
		else {	// for hcfga, bpdfga, acfga, flfga, ofdfga, tcdfga, gwgfga
			gen `check_x' = `xvar' >= 98 & `xvar' <= 280
		}
		
		// Set new var to missing if necessary
		replace `return' = . if `check_x' == 0 | `touse' == 0
    }
 	restore, not 
end
