{smcl}
{* *! version 1.0 28 Apr 2023}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "gigs: Classification functions" "help classify_sga"}{...}
{viewerjumpto "Syntax" "ig_nbs##syntax"}{...}
{viewerjumpto "Description" "ig_nbs##description"}{...}
{viewerjumpto "Functions" "ig_nbs##functions"}{...}
{viewerjumpto "Options" "ig_nbs##options"}{...}
{viewerjumpto "Available Standards" "ig_nbs##standards"}{...}
{viewerjumpto "Remarks" "ig_nbs##remarks"}{...}
{viewerjumpto "Examples" "ig_nbs##examples"}{...}

{hi:help gigs, help ig_nbs, help ig_png, help who_gs}{right: ({browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":SJXX-X: st0001})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:gigs} {hline 2} Standardising child growth assessment with extensions to egen}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:ig_nbs}{cmd:(}{{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
{ifin}{cmd:,} 
{cmdab:gest:_age}{cmd:(}{varname}{cmd:)} {cmdab:sex}{cmd:(}{varname}{cmd:)}
{cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} {cmdab:f:emale=}{it:code}{cmd:)}

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:ig_png}{cmd:(}{{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
{ifin}{cmd:,} 
{cmdab:pma:_weeks}{cmd:(}{varname}{cmd:)} {cmdab:sex}{cmd:(}{varname}{cmd:)}
{cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} {cmdab:f:emale=}{it:code}{cmd:)}

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:who_gs}{cmd:(}{{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
{ifin}{cmd:,} 
{cmdab:x:var}{cmd:(}{varname}{cmd:)} 
{cmdab:sex}{cmd:(}{varname}{cmd:)}
{cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} {cmdab:f:emale=}{it:code}{cmd:)}

{pstd}{cmd:by} cannot be used with these functions.

{marker description}{...}
{title:Description}

{pstd}(This is the general specification copied from the help for
{helpb egen}.)

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{it:fcn}{cmd:(}{it:arguments}{cmd:)} {ifin} [{cmd:,} {it:options}]

{pstd}where depending on the {it:fcn}, {it:arguments} refers to an
expression, {varlist}, or {it:{help numlist}}, and the {it:options} are
also {it:fcn} dependent.

{p 4 4 2}We have developed multiple functions for {cmd:egen} as part of the
 Guidance for International Growth Standards (GIGS) project. Each of these
 functions converts between anthropometric measures and z-scores/centiles, for
 a range of different growth standards.

{marker functions}{...}
{title:Functions for egen}

{p 4 4 2}{hi:ig_nbs(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
 converts between newborn anthropometric data and centiles/z-scores in
 the INTERGROWTH-21st Newborn Size Standards. It has three arguments:

{pmore}{varname} is the variable name in your dataset which you want to convert
 to a z-score, centile or anthropometric measure (for example, {cmd:weight_kg},
 {cmd:fat_mass_kg}).

{pmore}{it:acronym} defines the INTERGROWTH-21st Newborn Size standard by which
 to convert the values in {varname}, and should be one of the acronyms listed in
 the {help ig_nbs##standards:Available Standards} section below.

{pmore}{it:conversion} defines the type of conversion to be performed on
 {varname}, and must be one of {cmd:"v2z"} (value-to-z-score), {cmd:"v2p"} 
 (value-to-centile), {cmd:"p2v"} (centile-to-value), or {cmd:"z2v"}
 (z-score-to-value).

{p 4 4 2}{hi:ig_png(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
 converts between newborn anthropometric data and centiles/z-scores in
 the INTERGROWTH-21st Newborn Size Standards. It has three arguments:

{pmore}{varname} is the variable name in your dataset which you want to convert
 to a z-score, centile or anthropometric measure (for example, {cmd:weight_kg},
 {cmd:headcirc_cm}).

{pmore}{it:acronym} defines the INTERGROWTH-21st Post-natal Growth standard by 
 which to convert the values in {varname}, and should be one of the acronyms
 listed in the {help ig_nbs##standards:Available Standards} section below.

{pmore}{it:conversion} defines the type of conversion to be performed on
 {varname}, and must be one of {cmd:"v2z"} (value-to-z-score), {cmd:"v2p"} 
 (value-to-centile), {cmd:"p2v"} (centile-to-value), or {cmd:"z2v"}
 (z-score-to-value).

{p 4 4 2}{hi:who_gs(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
 converts between newborn anthropometric data and centiles/z-scores in
 the WHO Child Growth Standards. It has three arguments:

{pmore}{varname} is the variable name in your dataset which you want to convert
 to a z-score, centile or anthropometric measure (for example, {cmd:armcirc_cm},
 {cmd:BMI}).

{pmore}{it:acronym} defines the WHO Child Growth Standard by which to convert
 the values in {varname}, and should be one of the acronyms listed in the {help
 ig_nbs##standards:Available Standards} section below.

{pmore}{it:conversion} defines the type of conversion to be performed on
 {varname}, and must be one of {cmd:"v2z"} (value-to-z-score), {cmd:"v2p"} 
 (value-to-centile), {cmd:"p2v"} (centile-to-value), or {cmd:"z2v"}
 (z-score-to-value).

{marker options}{...}
{title:Options}
{dlgtab:Non-specific}

{phang}{opt sex(varname)} specifies the sex variable.  It
can be string or numeric. The codes for {cmd:male} and {cmd:female}
must be specified by the {hi:sexcode()} option.

{phang}{cmd:sexcode(male=}{it:code}{cmd:, female=}{it:code}{cmd:)}
 specifies the codes for {cmd:male} and {cmd:female}. The codes can be specified
 in either  order, and the comma is optional. Quotes around the codes are not
 allowed, even if your sex variable is a string. 

{dlgtab:INTERGROWTH-21st Newborn Size Standards}

{phang}{opt gest:_age(varname numeric)} specifies gestational age in days for
 newborns. Any value outside the range of valid gestational ages as specified by
 the acronym argument (see Table 1) will return a missing value.

{dlgtab:INTERGROWTH-21st Post-natal Growth of Preterm Infants Standards}

{phang}{opt pma:_weeks(varname numeric)} specifies post-menstrual age in whole
 weeks for infants. Any value outside the range of valid post-menstrual ages as
 specified in Table 2 will return a missing value.

{dlgtab:WHO Child Growth Standards}

{phang}{opt x:var(varname numeric)} specifies the variable used with supplied
 sex values to standardise the measure of interest. This is usually age (in days)
 but may also be length or height (in cm) if using the wfl or wfh standard. See
 Table 3 for appropriate {cmd:{it:x}} variables for each possible acronym value. Any
 {cmd:{it:x}} variable values outside the ranges described below.

 
{marker standards}{...}
{title:Available Standards}

{col 5}{ul:INTERGROWTH-21st Newborn Size Standards}

{col 5}{it:acronym}{col 20}Description{col 40}Measurement{col 57}{cmd:gest_age()} range
{col 5}{col 43}unit
{col 5}{hline 77}
{col 6}{cmd:wfga}{col 20}weight-for-GA{col 45}kg{col 57}168-300 days
{col 6}{cmd:lfga}{col 20}length-for-GA{col 45}cm{col 57}168-300 days
{col 6}{cmd:hcfga}{col 14}head circumference-for-GA{col 45}cm{col 57}168-300 days
{col 6}{cmd:wlrfga}{col 22}BMI-for-GA{col 43}kg/cm{col 57}168-300 days
{col 6}{cmd:ffmfga}{col 16}fat-free mass-for-GA{col 45}kg{col 57}266-294 days
{col 6}{cmd:bfpfga}{col 14}body fat percentage-for-GA{col 45}%{col 57}266-294 days
{col 6}{cmd:fmfga}{col 17}fat-free mass-for-GA{col 45}kg{col 57}266-294 days
{col 5}{hline 77} 

{col 5}{ul:INTERGROWTH-21st Post-natal Growth Standards for Preterm Infants}

{col 5}{it:acronym}{col 18}Description{col 42}Measurement{col 57}{cmd:pma_weeks()} range
{col 5}{col 45}unit
{col 5}{hline 77}
{col 6}{cmd:wfa}{col 17}weight-for-age{col 45}kg{col 57}27 to <64 exact weeks
{col 6}{cmd:lfa}{col 17}length-for-age{col 45}cm{col 57}27 to <64 exact weeks
{col 6}{cmd:hcfa}{col 13}head circumference-for-age{col 45}cm{col 57}27 to <64 exact weeks
{col 5}{hline 77}

{col 5}{ul:WHO Child Growth Standards}

{col 5}{it:acronym}{col 20}Description{col 42}Measurement{col 57}{cmd:xvar()} range
{col 5}{col 45}unit
{col 5}{hline 77}
{col 6}{cmd:hfa}{col 15}length/height-for-age{col 46}cm{col 57}0-1856 days
{col 6}{cmd:wfa}{col 19}weight-for-age{col 46}kg{col 57}0-1856 days
{col 6}{cmd:bfa}{col 20}BMI-for-age{col 44}kg/m^2{col 57}0-1856 days
{col 6}{cmd:hcfa}{col 13}head circumference-for-age{col 46}cm{col 57}0-1856 days
{col 6}{cmd:wfl}{col 17}weight-for-length{col 46}kg{col 57}45-110 cm
{col 6}{cmd:wfh}{col 17}weight-for-height{col 46}kg{col 57}65-120 cm
{col 6}{cmd:acfa}{col 14}arm circumference-for-age{col 46}cm{col 57}91-1856 days
{col 6}{cmd:ssfa}{col 12}subscapular skinfold-for-age{col 46}mm{col 57}91-1856 days
{col 6}{cmd:tsfa}{col 15}triceps skinfold-for-age{col 46}mm{col 57}91-1856 days
{col 5}{hline 77}

{marker remarks}{...}
{title:Remarks}

{pstd}These functions will return missing values where values are outside the
 ranges given above, but otherwise will not automatically detect data errors. 
 Ensure you check your data before using these functions or you may receive
 incorrect results.

{marker examples}{...}
{title:Examples}

{pstd}Getting centiles from values ({cmd: "v2p"}) in the INTERGROWTH-21st
 Newborn Size Standard for weight-for-gestational age ({cmd:"wfga"}), where 
 {cmd:sex} contains the codes {cmd:1} and {cmd:2}:{p_end}
{phang2}{cmd:. egen z_wfga = ig_nbs(weight,"wfga","v2p"), gest_age(ga_weeks * 7) sex(sex) sexcode(male=1, female=2)}

{pstd}Getting z-scores from values ({cmd: "v2p"}) in the INTERGROWTH-21st
 Newborn Size Standard for weight-for-gestational age ({cmd:"wfga"}), where 
 {cmd:sex} contains the codes {cmd:M} and {cmd:F}:{p_end}
{phang2}{cmd:. egen z_lfa = ig_png(len_cm,"lfa","v2z"), pma_weeks(pma) sex(sex) sexcode(male=M, female=F)}

{pstd}Getting values for z-scores ({cmd: "v2p"}) in the WHO Child Growth
 Standard for arm circumference-for-age ({cmd:"acfa"}), where 
 {cmd:sex} contains the codes {cmd:Male} and {cmd:Female}:{p_end}
{phang2}{cmd:. egen z_acfa = who_gs(zscores,"acfa","z2v"), xvar(age_days) sex(sex) sexcode(male=Male, female=Female)}

{pstd}You can use just the first letter of the {cmd:sexcode()} arguments{p_end}
{phang2}{cmd:. egen z_acfa = who_gs(zscores,"acfa","z2v"), xvar(age_days) sex(sex) sexcode(m=Male, f=Female)}

{pstd}Codes given to {cmd: sexcode()} cannot be abbreviated. They must be 
 typed exactly as they appear in your dataset. You can, however, swap the order
 and/or omit the comma in the {hi:sexcode()} option:{p_end}
{phang2}{cmd:. egen z_acfa = who_gs(zscores,"acfa","z2v"), xvar(age_days) sex(sex) sexcode(f=Female, m=Male)}

{phang2}{cmd:. egen z_acfa = who_gs(zscores,"acfa","z2v"), xvar(age_days) sex(sex) sexcode(f=Female m=Male)}{p_end}


{marker authors}{...}
{title:Authors}

{pstd}Simon R. Parker{p_end}
{pstd}Maternal and Newborn Health Group{p_end}
{pstd}London School of Hygiene and Tropical Medicine{p_end}
{pstd}London, U.K.{p_end}
{pstd}simon.parker@lshtm.ac.uk{p_end}

{pstd}Eric O. Ohuma{p_end}
{pstd}Maternal and Newborn Health Group{p_end}
{pstd}London School of Hygiene and Tropical Medicine{p_end}
{pstd}London, U.K.{p_end}
{pstd}eric.ohuma@lshtm.ac.uk{p_end}


{title:Also see}

{p 4 14 2}Classifcation functions: {help classify_sga:documentation}

{p 4 14 2}Article:  {it:Stata Journal}, volume XX, number X: {browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":st0001}

{p 5 14 2}Manual:  {manlink R egen}{p_end}

{p 7 14 2}Help:  {manhelp egen R}, {manhelp functions D}, {manhelp generate D}{p_end}


