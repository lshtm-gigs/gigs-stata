capture program drop _gig_nbs
capture program drop _gtemplate
capture program drop Badsyntax
*! version 0.0.1 (SJxx-x: dmxxxx)
program define _gig_nbs
 	version 16
	preserve

	gettoken type 0 : 0
	gettoken return    0 : 0
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
	
	capture assert inlist("`acronym'", "wfga", "lfga", "hcfga", "ffmfga", /*
	*/ "bfpfga", "fmfga")
	if _rc {
		di as text "`acronym'" as error " is an invalid acronym. The only valid choices are " /*
		*/as text "wfga, lfga, hcfga, ffmfga, bfpfga," as error " or " as text "fmfga" as error"."
		exit 198
	}
	capture assert inlist("`conversion'", "v2p", "v2z", "p2v", "z2v")
	if _rc {
		di as text "`conversion'" as error " is an invalid chart code. The only valid choices are " /*
		*/ as text "v2p, v2z, p2v," as error " or " as text "z2v" as error "."
		exit 198
	}
	
	if `"`by'"' != "" {
		_egennoby zanthro() `"`by'"'
		/* NOTREACHED */
	}
	
	syntax [if] [in], gest_age(varname numeric) sex(varname) SEXCode(string)
	
	local 1 `sexcode'
	*zap commas to spaces (i.e. commas indulged)
	local 1 : subinstr local 1 "," " ", all
	tokenize `"`1'"', parse("= ")
	
 	if "`1'" == substr("male", 1, length("`1'")) {
		if "`2'" ~= "=" | "`5'" ~= "=" | /*
		*/ "`4'" ~= substr("female", 1, length("`4'")) | /*
		*/ "`7'" ~= "" {
 			Badsyntax
 		}
 		local male "`3'"
  		local female "`6'"
	} 
	else if "`1'" == substr("female",1,length("`1'")) {
	    if "`2'" ~= "=" | "`5'" ~= "=" | /*
 		*/ "`4'" ~= substr("male", 1, length("`4'") | /*
 		*/ "`7'" ~= "" {
 			Badsyntax
 		}
 		local male "`6'"
 		local female "`3'"
 	} 
	else Badsyntax	

	tempvar check_sex
    generate `check_sex' = `sex' == "`male'" | sex == "`female'"
			
	tempvar check_ga 
	generate `check_ga' = `gest_age' >= 24 * 7 & `gest_age' < 43 * 7	
	if "`acronym'" == "ffmfga" | "`acronym'" == "bfpfga" | "`acronym'" == "fmfga" {
	    replace `check_ga' = `gest_age' >= 38 * 7 & `gest_age' =< 42
	} 
		
	// TODO: Do not bother with GAMLSS code if no obs have ga > 33
	// if gamlss_required:
	
    tempvar n
	gen `n' = _n
	qui merge 1:1 gest_age sex acronym using "ig_nbs_coeffs.dta", nogenerate keep(1 3)
 	sort `n'
 	drop `n'
	
	if "`conversion'" == "v2p" | "`conversion'" == "v2z" {
		tempvar q cdf p_pST3
		qui {
		    gen `q' = `input'
			gen `cdf' = 2 * t(tau, nu * (`q' - mu) / sigma) if `q' < mu		
			replace `cdf' = 1 + 2 * nu * nu * (t(tau, (`q' - mu) / (sigma * nu)) - 0.5) if `q' >= mu 
			generate `p_pST3' = `cdf' / (1 + nu * nu)
		}
		drop mu sigma nu tau
		
		tempvar sex_as_numeric median gest_age_weeks vpns_median vpns_stddev
		qui {
	 		generate `sex_as_numeric' = 1 if `sex' == "`male'"
			replace `sex_as_numeric' = 0 if `sex' == "`female'"
			generate `gest_age_weeks' = .
			replace `gest_age_weeks' = `gest_age' if `gest_age' < 168
			replace `gest_age_weeks' = `gest_age' / 7  if `gest_age' >= 168
				
			generate `vpns_median' = .
			replace `vpns_median' = ///
			-7.00303 + (1.325911 * (`gest_age_weeks' ^ 0.5)) +  (0.0571937 * `sex_as_numeric') ///
			if "`acronym'" == "wfga"
			replace `vpns_median' = ///
			1.307633 + 1.270022 * `gest_age_weeks' +  0.4263885 * `sex_as_numeric' ///
			if "`acronym'" == "lfga"
			replace `vpns_median' = ///
			0.7866522 + 0.887638 * `gest_age_weeks' + 0.2513385 * `sex_as_numeric' ///
			if "`acronym'" == "hcfga"

			generate `vpns_stddev' = .
			replace `vpns_stddev' = sqrt(0.0373218) if "`acronym'" == "wfga"
			replace `vpns_stddev' = sqrt(6.7575430) if "`acronym'" == "lfga"
			replace `vpns_stddev' = sqrt(2.4334810) if "`acronym'" == "hcfga"
		
			tempvar p_vpns 
			generate `p_vpns' = normal((`q' - `vpns_median') / `vpns_stddev')
			replace `p_vpns' = normal((log(`q') - `vpns_median') / `vpns_stddev') ///
			if "`acronym'" == "wfga"
		}
		
		tempvar p_out
		li `p_pST3' `p_vpns'
		qui generate `p_out' = `p_pST3' if `p_pST3' != .
		qui replace `p_out' = `p_vpns' if `p_vpns' != . & `p_pST3' == .
		qui generate `type' `return' = `p_out'
		if "`conversion'" == "v2z" {
			qui replace `return' = invnormal(`p_out')
		}
	}
 	else {
 	    tempvar percentiles 
 		if "`conversion'" == "p2v" {
 		    generate `percentiles' = normal(`input')
 		}
 		else if "`conversion'" == "z2v" {
 		    generate `percentiles' = normal(`input')
 		}
 	}
	
	// TODO: Do not bother with body composition code if ! 38 =< ga =< 42 
	
	restore, not 
end

*! version 0.0.1 (SJxx-x: dmxxxx)
program define _gtemplate

	if "`chart'"=="lla" {
		local lmsfile zllageuk.dta
	}
	else if "`chart'"=="sha" {
		local lmsfile zshtageuk.dta
	}
	else if "`chart'"=="wsa" {
		local lmsfile zwsageuk.dta
	}
	else if "`chart'"=="bfa" {
		local lmsfile zbfageuk.dta
	}
	else if "`chart'"=="aca" {
		local lmsfile zacagewho.dta
	}
	else if "`chart'"=="ssa" {
		local lmsfile zssagewho.dta
	}
	else if "`chart'"=="tsa" {
		local lmsfile ztsagewho.dta
	}
	else if "`chart'"=="la" {
		local lmsfile zlenageius.dta
	}
	else if "`chart'"=="hca" & "`version'"=="UK" {
		local lmsfile zhcageuk.dta
	}
	else if "`chart'"=="hca" & "`version'"=="US" {
		local lmsfile zhcageius.dta
	}
	else if "`chart'"=="hca" & "`version'"=="WHO" {
		local lmsfile zhcagewho.dta
	}
	else if "`chart'"=="hca" & "`version'"=="UKWHOpreterm" {
		local lmsfile zhcageukwhopreterm.dta
	}
	else if "`chart'"=="hca" & "`version'"=="UKWHOterm" {
		local lmsfile zhcageukwhoterm.dta
	}
	else if "`chart'"=="ba" & "`version'"=="UK" {
		local lmsfile zbmiageuk.dta
	}	
	else if "`chart'"=="ba" & "`version'"=="US" {
		local lmsfile zbmiageus.dta
	}	
	else if "`chart'"=="ba" & "`version'"=="WHO" {
		local lmsfile zbmiagewho.dta
	}
	else if "`chart'"=="ba" & "`version'"=="UKWHOpreterm" {
		local lmsfile zbmiageukwhopreterm.dta
	}
	else if "`chart'"=="ba" & "`version'"=="UKWHOterm" {
		local lmsfile zbmiageukwhoterm.dta
	}
	else if "`chart'"=="wa" & "`version'"=="UK" {
		local lmsfile zwtageuk.dta
	}
	else if "`chart'"=="wa" & "`version'"=="US" {
		local lmsfile zwtagecomus.dta
	}
	else if "`chart'"=="wa" & "`version'"=="WHO" {
		local lmsfile zwtagewho.dta
	}
	else if "`chart'"=="wa" & "`version'"=="UKWHOpreterm" {
		local lmsfile zwtageukwhopreterm.dta
	}
	else if "`chart'"=="wa" & "`version'"=="UKWHOterm" {
		local lmsfile zwtageukwhoterm.dta
	}
	else if "`chart'"=="ha" & "`version'"=="UK" {
		local lmsfile zhtageuk.dta
	}
	else if "`chart'"=="ha" & "`version'"=="US" {
		local lmsfile zhtageus.dta
	}
	else if "`chart'"=="ha" & "`version'"=="WHO" {
		local lmsfile zlhagewho.dta
	}
	else if "`chart'"=="ha" & "`version'"=="UKWHOpreterm" {
		local lmsfile zlhtageukwhopreterm.dta
	}
	else if "`chart'"=="ha" & "`version'"=="UKWHOterm" {
		local lmsfile zlhtageukwhoterm.dta
	}
	else if "`chart'"=="wh" & "`version'"=="US" {
		local lmsfile zwthtus.dta
	}
	else if "`chart'"=="wh" & "`version'"=="WHO" {
		local lmsfile zwthtwho.dta
	}
	else if "`chart'"=="wl" & "`version'"=="US" {
		local lmsfile zwtlenius.dta
	}
	else if "`chart'"=="wl" & "`version'"=="WHO" {
		local lmsfile zwtlenwho.dta
	}

	qui findfile `lmsfile'
	local fn "`r(fn)'"
	use "`fn'",clear
	qui levelsof __SVJCKHxmrg, local(levels)
	restore, preserve

	tempvar t tday xvarfrac l m s y0 y1 y2 y3 t0 t1 t2 t3

	foreach x in sex agegp xmrg xvar_pre l_pre m_pre s_pre xvar l m s xvar_nx l_nx m_nx s_nx /*
	*/xvar_nx2 l_nx2 m_nx2 s_nx2 merge {
		capture confirm new var __SVJCKH`x'
		if _rc {
			di as error "__SVJCKH`x' is used by zanthro - rename your variable"
			exit 110
		}
	}

	marksample touse

	quietly { 
		if "`y'" == "str" {
			gen byte __SVJCKHsex=1 if `gender'=="`male'"
			replace __SVJCKHsex=2 if `gender'=="`female'"
		}
		else {
			gen byte __SVJCKHsex=1 if `gender'==`male'
			replace __SVJCKHsex=2 if `gender'==`female'
		}
		
		if "`ageunit'"=="month" {
			gen float `t'=`xvar'/12
			gen float `tday'=`xvar'*(365.25/12)*10000
		}
		else if "`ageunit'"=="week" {
			gen float `t'=`xvar'/(365.25/7)
			gen float `tday'=`xvar'*7*10000
		}
		else if "`ageunit'"=="day" {
			gen float `t'=`xvar'/365.25
			gen float `tday'=`xvar'*10000
		}
		else {
			gen float `t'=`xvar'
			gen float `tday'=`xvar'*365.25*10000
		}

		if "`gestage'"~="" {
			su `gestage'
			local gestmax=r(max)
			if `gestmax'>42 {
				noi di as err "WARNING: Maximum value in your gestational age variable is `gestmax' weeks."
			}
			replace `t'=`t'+(`gestage'-40)*7/365.25
			replace `tday'=`tday'+(`gestage'-40)*7*10000
		}

		gen float __SVJCKHxmrg=.
		local levs : word count `levels'
		local levsminus1 = `levs' - 1
		forvalues i = 1/`levsminus1' {
			local j = `i' + 1
			local current : word `i' of `levels'
			local next : word `j' of `levels'
			replace __SVJCKHxmrg=`current' if `tday'>=`current' & `tday'<`next'
			*Separate command required for the maximum value in growth chart.
			replace __SVJCKHxmrg=`next' if `tday'==`next'
		}

		*The length/height-for-age and BMI-for-age WHO charts have parameters for age 2 from 
		*the 0-2 and 2-5 year charts. Where age=2 years, using the parameters from the 2-5 year 
		*chart. 
		if ("`chart'"=="ha" | "`chart'"=="ba") & "`version'"=="WHO" {
		    gen byte __SVJCKHagegp=1 if `t'<2
			replace __SVJCKHagegp=2 if `t'>=2
			sort __SVJCKHsex __SVJCKHagegp __SVJCKHxmrg
			merge __SVJCKHsex __SVJCKHagegp __SVJCKHxmrg using "`fn'", _merge(__SVJCKHmerge)
		}
		*The UK-WHO charts have duplicated parameters for ages 2 weeks, 2 years and 4 years. 
		*These were copied from LMSgrowth. When sorted by __SVJCKHsex, __SVJCKHagegp and __SVJCKHage,
		*the chart is sorted in the LMSgrowth order. For the duplicated ages, when a child is exactly
		*that age, the parameters of the older age group are used.
		else if "`version'"=="UKWHOpreterm" | "`version'"=="UKWHOterm" {
		    gen byte __SVJCKHagegp=1 if `tday'<140000
			replace __SVJCKHagegp=2 if `tday'>=140000 & `t'<2
			replace __SVJCKHagegp=3 if `t'>=2 & `t'<4
			replace __SVJCKHagegp=4 if `t'>=4	
			sort __SVJCKHsex __SVJCKHagegp __SVJCKHxmrg		
			merge __SVJCKHsex __SVJCKHagegp __SVJCKHxmrg using "`fn'", _merge(__SVJCKHmerge)
		}
		else  {
			sort __SVJCKHsex __SVJCKHxmrg
			merge __SVJCKHsex __SVJCKHxmrg using "`fn'", _merge(__SVJCKHmerge)
		}

		su __SVJCKHxvar if __SVJCKHmerge~=1, meanonly
		local minyr=r(min)
		local maxyr=r(max)
		su __SVJCKHxmrg if __SVJCKHmerge~=1, meanonly
		local min=r(min)
		local max=r(max)
		su __SVJCKHxmrg if __SVJCKHmerge~=1 & __SVJCKHxmrg>`min' & __SVJCKHxmrg<`max', meanonly
		local min2=r(min)
		local max2=r(max)
		drop if __SVJCKHmerge==2

		gen `xvarfrac' = (`t'-__SVJCKHxvar)/(__SVJCKHxvar_nx-__SVJCKHxvar) if `touse' & __SVJCKHmerge==3 & /*
				*/`tday'>`min' & `tday'<`max'

		*Generating variables with short names to condense the interpolation formulae.
		gen `t0'=__SVJCKHxvar_pre
		gen `t1'=__SVJCKHxvar
		gen `t2'=__SVJCKHxvar_nx
		gen `t3'=__SVJCKHxvar_nx2
		forval i=0/3 {
			gen `y`i''=.
		}

		foreach y in l m s {
			gen ``y''=.

			*Cubic interpolation
			replace `y0'=__SVJCKH`y'_pre if `tday'>`min2' & `tday'<`max2' & `touse' & __SVJCKHmerge==3
			replace `y1'=__SVJCKH`y' if `tday'>`min2' & `tday'<`max2' & `touse' & __SVJCKHmerge==3
			replace `y2'=__SVJCKH`y'_nx if `tday'>`min2' & `tday'<`max2' & `touse' & __SVJCKHmerge==3
			replace `y3'=__SVJCKH`y'_nx2 if `tday'>`min2' & `tday'<`max2' & `touse' & __SVJCKHmerge==3
			replace ``y'' = (`y0'*(`t'-`t1')*(`t'-`t2')*(`t'-`t3'))/((`t0'-`t1')*(`t0'-`t2')*(`t0'-`t3')) + /*
					    */(`y1'*(`t'-`t0')*(`t'-`t2')*(`t'-`t3'))/((`t1'-`t0')*(`t1'-`t2')*(`t1'-`t3')) + /*
					    */(`y2'*(`t'-`t0')*(`t'-`t1')*(`t'-`t3'))/((`t2'-`t0')*(`t2'-`t1')*(`t2'-`t3')) + /*
					    */(`y3'*(`t'-`t0')*(`t'-`t1')*(`t'-`t2'))/((`t3'-`t0')*(`t3'-`t1')*(`t3'-`t2')) /*
					    */if `tday'>`min2' & `tday'<`max2' & `touse' & __SVJCKHmerge==3

			*Linear interpolation for first segment and last segment.
			replace ``y'' = __SVJCKH`y'+`xvarfrac'*(__SVJCKH`y'_nx-__SVJCKH`y') if `touse' & __SVJCKHmerge==3 & /*
					*/((`tday'>`min' & `tday'<`min2') | (`tday'>`max2' & `tday'<`max'))
			
			*Some head circumference charts end at 18 years for males and 17 years for females. For these
			*charts extra code is required so that a linear rather than cubic interpolation is done on the
			*last segment for females: 16 years, 11 months to 17 years.
			if "`chart'"=="hca" & ("`version'"=="UK" | "`version'"=="UKWHOpreterm" | "`version'"=="UKWHOterm") {
				su __SVJCKHxmrg if __SVJCKHxvar==17
				assert r(min)==r(max)
				local age17y=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar<17
				local age16y11m=r(max)
				replace ``y'' = __SVJCKH`y'+`xvarfrac'*(__SVJCKH`y'_nx-__SVJCKH`y') if `touse' & __SVJCKHmerge==3 & /*
				*/`tday'>`age16y11m' & `tday'<`age17y' & __SVJCKHsex==2
			}
			
			*Linear interpolation for the length/height-for-age and BMI-for-age WHO charts at the segments
			*around age=2. There are parameters for age=2 from the 0-2 and 2-5 year charts, which need to be
			*split. Using linear interpolation because these are the last segment of the 0-2 year chart and 
			*the first segment of the 2-5 year chart.
			if ("`chart'"=="ha" | "`chart'"=="ba") & "`version'"=="WHO" {
				su __SVJCKHxmrg if __SVJCKHxvar==2
				assert r(min)==r(max)
				local age2y=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar<2
				local age1y11m=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar>2
				local age2y1m=r(min)		
				replace ``y'' = __SVJCKH`y'+`xvarfrac'*(__SVJCKH`y'_nx-__SVJCKH`y') if `touse' & __SVJCKHmerge==3 & /*
				*/`tday'>`age1y11m' & `tday'<`age2y1m' & `tday'!=`age2y'
			}
			
			*Linear interpolation for the UK-WHO charts at the segments around ages 2 weeks, 2 years and
			*4 years. Using linear interpolation because the last segment of one chart and the first segment
			*of another occur at these ages.
			if "`version'"=="UKWHOpreterm" | "`version'"=="UKWHOterm" {
				*Around 2 weeks:
				su __SVJCKHxmrg if __SVJCKHxvar>0.03 & __SVJCKHxvar<0.04
				assert r(min)==r(max)
				local age2w=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar<0.03
				local age1w=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar>0.04
				local age3w=r(min)
				*Around 2 years:
				su __SVJCKHxmrg if __SVJCKHxvar==2
				assert r(min)==r(max)
				local age2y=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar<2
				local age1y11m=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar>2
				local age2y1m=r(min)		
				*Around 4 years:
				su __SVJCKHxmrg if __SVJCKHxvar==4
				assert r(min)==r(max)
				local age4y=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar<4
				local age3y11m=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar>4
				local age4y1m=r(min)
				replace ``y'' = __SVJCKH`y'+`xvarfrac'*(__SVJCKH`y'_nx-__SVJCKH`y') if `touse' & __SVJCKHmerge==3 & /*
				*/((`tday'>`age1w' & `tday'<`age3w' & `tday'!=`age2w') | /*
				*/(`tday'>`age1y11m' & `tday'<`age2y1m' & `tday'!=`age2y') | /*
				*/(`tday'>`age3y11m' & `tday'<`age4y1m'& `tday'!=`age4y'))
			}
			
			*No interpolation required if age equals the age on the growth chart.
			replace ``y'' = __SVJCKH`y' if `tday'==__SVJCKHxmrg & `touse' & __SVJCKHmerge==3
		}

		gen `type' `g' = (((`measure'/`m')^`l')-1)/(`l'*`s') if `t'>=`minyr'-0.00000001 & `t'<=`maxyr'+0.00000001 & `touse'
		replace `g'=. if `measure'<=0
		if "`nocutoff'"=="" {
			replace `g'=. if abs(`g')>=5 & `g'<.
		}

		drop __SVJCKHsex __SVJCKHxmrg __SVJCKHxvar_pre __SVJCKHxvar  __SVJCKHxvar_nx __SVJCKHxvar_nx2 __SVJCKHl_pre /*
		*/__SVJCKHl __SVJCKHl_nx __SVJCKHl_nx2 __SVJCKHm_pre __SVJCKHm __SVJCKHm_nx __SVJCKHm_nx2 /*
		*/__SVJCKHs_pre  __SVJCKHs __SVJCKHs_nx __SVJCKHs_nx2 __SVJCKHmerge
		if (("`chart'"=="ha" | "`chart'"=="ba") & "`version'"=="WHO") | "`version'"=="UKWHOpreterm" | /*
		*/"`version'"=="UKWHOterm" {
		    drop __SVJCKHagegp
		}
	}

	quietly count if `g'<. & `touse'
	if r(N) { 
		local s = cond(r(N)>1,"s","")
		di as text "(Z value`s' generated for " r(N) " case`s') " 
		di as text "(gender was assumed to be coded male=`male', female=`female')"
		if "`forage'"=="1" {
			di as text "(age was assumed to be in `ageunit's)"
		}
	}

	quietly count if `g'==. & `touse'
	if r(N) { 
		if "`gestage'"~="" {
			if "`nocutoff'"=="" {
				di as text "(Z values can be missing because age is nonpositive or otherwise" 
				di as text " out of range for the chart code, the gender variable is missing,"
				di as text " gestation age is missing or places corrected age out of range"
				di as text " for the chart code, or the Z value has an absolute value >=5)"
			}
			else {
				di as text "(Z values can be missing because age is nonpositive or otherwise"
				di as text " out of range for the chart code, the gender variable is missing," 
				di as text " or gestation age is missing or places corrected age out of range"
				di as text " for the chart code)"
			}
		}
		else {
			if "`nocutoff'"=="" {
				di as text "(Z values can be missing because xvar is nonpositive or otherwise" 
				di as text " out of range for the chart code, the gender variable is missing,"
				di as text " or the Z value has an absolute value >=5)"
			}
			else {
				di as text "(Z values can be missing because xvar is nonpositive or otherwise"
				di as text " out of range for the chart code, or the gender variable is missing)" 
			}
		}
	}

	restore,not

end

program Badsyntax
	di as err "sexcode() option invalid: see {help ig_nbs}"
	exit 198
end
