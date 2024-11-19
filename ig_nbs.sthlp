{smcl}
{* *! version 0.6.0 31 Oct 2024}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "gigs: Classification functions" "help classify_sfga"}{...}
{viewerjumpto "Syntax" "ig_nbs##syntax"}{...}
{viewerjumpto "Description" "ig_nbs##description"}{...}
{viewerjumpto "Functions" "ig_nbs##functions"}{...}
{viewerjumpto "Options" "ig_nbs##options"}{...}
{viewerjumpto "Available Standards" "ig_nbs##standards"}{...}
{viewerjumpto "Remarks" "ig_nbs##remarks"}{...}
{viewerjumpto "Examples" "ig_nbs##examples"}{...}

{hi:help gigs, help ig_nbs, help ig_png, help ig_fet, help who_gs}{right: ({browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":SJXX-X: st0001})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:gigs} {hline 2} Fetal, neonatal, and infant growth assessment using international growth standards}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:ig_fet}{cmd:(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
{ifin}{cmd:,} 
{cmdab:x:var}{cmd:(}{varname}{cmd:)}

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:ig_nbs}{cmd:(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
{ifin}{cmd:,} 
{cmdab:gest:_days}{cmd:(}{varname}{cmd:)} {cmdab:sex}{cmd:(}{varname}{cmd:)}
{cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} {cmdab:f:emale=}{it:code}{cmd:)}
[{cmd:extend}]

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:ig_png}{cmd:(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
{ifin}{cmd:,} 
{cmdab:x:var}{cmd:(}{varname}{cmd:)} {cmdab:sex}{cmd:(}{varname}{cmd:)}
{cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} {cmdab:f:emale=}{it:code}{cmd:)}

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:who_gs}{cmd:(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
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
 functions converts between anthropometric measures and z-scores/centiles,
 for a range of different growth standards.

{marker functions}{...}
{title:Functions for egen}

{p 4 4 2}{hi:ig_fet(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
 converts between newborn anthropometric data and z-scores/centiles in
 the INTERGROWTH-21st Fetal Growth standards. It has three arguments:

{pmore}{varname} is the variable name in your dataset which you want to convert
 to a z-score, centile or anthropometric measure (for example,
 {cmd:headcirc_mm}, {cmd:weight_g}).

{pmore}{it:acronym} defines the INTERGROWTH-21st Fetal Growth standard by
 which to convert the values in {varname}, and should be one of the acronyms
 listed in the {help ig_nbs##standards:Available Standards} section below.

{pmore}{it:conversion} defines the type of conversion to be performed on
 {varname}, and must be one of {cmd:"v2z"} (value-to-z-score), {cmd:"v2c"}
 (value-to-centile), {cmd:"c2v"} (centile-to-value), or {cmd:"z2v"}
 (z-score-to-value).

{p 4 4 2}{hi:ig_nbs(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
 converts between newborn anthropometric data and z-scores/centiles in
 the INTERGROWTH-21st Newborn Size Standards. It has three arguments:

{pmore}{varname} is the variable name in your dataset which you want to convert
 to a z-score, centile or anthropometric measure (for example,
 {cmd:weight_kg}, {cmd:fat_mass_kg}).

{pmore}{it:acronym} defines the INTERGROWTH-21st Newborn Size standard by which
 to convert the values in {varname}, and should be one of the acronyms listed in
 the {help ig_nbs##standards:Available Standards} section below.

{pmore}{it:conversion} defines the type of conversion to be performed on
 {varname}, and must be one of {cmd:"v2z"} (value-to-z-score), {cmd:"v2c"}
 (value-to-centile), {cmd:"c2v"} (centile-to-value), or {cmd:"z2v"}
 (z-score-to-value).

{p 4 4 2}{hi:ig_png(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
 converts between newborn anthropometric data and z-scores/centiles in
 the INTERGROWTH-21st Newborn Size Standards. It has three arguments:

{pmore}{varname} is the variable name in your dataset which you want to convert
 to a z-score, centile or anthropometric measure (for example,
 {cmd:weight_kg}, {cmd:headcirc_cm}).

{pmore}{it:acronym} defines the INTERGROWTH-21st Postnatal Growth standard by
 which to convert the values in {varname}, and should be one of the acronyms
 listed in the {help ig_nbs##standards:Available Standards} section below.

{pmore}{it:conversion} defines the type of conversion to be performed on
 {varname}, and must be one of {cmd:"v2z"} (value-to-z-score), {cmd:"v2c"}
 (value-to-centile), {cmd:"c2v"} (centile-to-value), or {cmd:"z2v"}
 (z-score-to-value).

{p 4 4 2}{hi:who_gs(}{varname}{cmd:,}{it: acronym}{cmd:,}{it: conversion}{cmd:)}
 converts between newborn anthropometric data and z-scores/centiles in
 the WHO Child Growth Standards. It has three arguments:

{pmore}{varname} is the variable name in your dataset which you want to convert
 to a z-score, centile or anthropometric measure (for example,
 {cmd:armcirc_cm}, {cmd:BMI}).

{pmore}{it:acronym} defines the WHO Child Growth Standard by which to convert
 the values in {varname}, and should be one of the acronyms listed in the
 {help ig_nbs##standards:Available Standards} section below.

{pmore}{it:conversion} defines the type of conversion to be performed on
 {varname}, and must be one of {cmd:"v2z"} (value-to-z-score), {cmd:"v2c"}
 (value-to-centile), {cmd:"c2v"} (centile-to-value), or {cmd:"z2v"}
 (z-score-to-value).

{marker options}{...}
{title:Options}
{dlgtab:Non-specific}

{phang}{opt sex(varname)} specifies the sex variable. It must be an int, byte,
 or string variable. The codes for {cmd:male} and {cmd:female} must be specified
 by the {hi:sexcode()} option.

{phang}{cmd:sexcode(male=}{it:code}{cmd:, female=}{it:code}{cmd:)}
 specifies the codes for {cmd:male} and {cmd:female}. The codes can be specified
 in either  order, and the comma is optional. Quotes around the codes are not
 allowed, even if your sex variable is a string. 

{phang}{opt x:var(varname numeric)} specifies the variable used with supplied
 sex values to standardise the measure of interest. In the INTERGROWTH-21st
 Postnatal Growth standards ({cmd:ig_png()}) this is usually post-menstrual age
 in weeks, but may also be length in cm if using the {cmd:wfl} standard. In the
 INTERGROWTH-21st Fetal standards ({cmd:ig_fet()}), this is usually gestational 
 age in days but can also be crown-rump length in mm or transcerebellar diameter
 in mm, if using either the {cmd:gafcrl} or {cmd:gaftcd} standards, 
 respectively. In the WHO Child Growth standards, {cmd:xvar()} is usually age in
 days, but may also be length or height (in cm) if using either the {cmd:wfl} or
 {cmd:wfh} standards. See Tables {help ig_nbs##tab2:2}, {help ig_nbs##tab3:3}, 
 or {help ig_nbs##tab4:4} for appropriate {cmd:{it:x}} values and units for each
 valid acronym. Any observations with {cmd:{it:x}} variable values outside the 
 ranges described in these tables will have a missing value in the generated 
 variable.

{dlgtab:INTERGROWTH-21st Newborn Size standards}

{phang}{opt gest:_days(varname numeric)} specifies gestational age in days for
 newborns. Any value outside the range of valid gestational ages as specified by
 the acronym argument (see Table {help ig_nbs##tab1:1}) will return a missing
 value.
 
{phang}{opt extend} should be specified if you want to use an extrapolated
 version of the INTERGROWTH-21st Newborn Size standards which accepts 
 gestational ages from 154 to 314 days (22+0 to 44+6 wks). This option can only 
 be used when {it:acronym} is one of {bf:wfga}, {bf:lfga}, or {bf:hcfga}.

{marker standards}{...}
{title:Available Standards}

{marker tab1}{...}
{col 5}{ul:INTERGROWTH-21st Newborn Size Standards}

{col 5}{it:acronym}{col 20}Description{col 43}Measurement{col 57}{cmd:gest_days()} range
{col 5}{col 46}unit
{col 5}{hline 77}
{col 6}{cmd:wfga}{col 21}weight-for-GA{col 47}kg{col 57}168-300 days
{col 6}{cmd:lfga}{col 21}length-for-GA{col 47}cm{col 57}168-300 days
{col 6}{cmd:hcfga}{col 15}head circumference-for-GA{col 47}cm{col 57}168-300 days
{col 6}{cmd:wlrfga}{col 23}BMI-for-GA{col 45}kg/cm{col 57}168-300 days
{col 6}{cmd:ffmfga}{col 17}fat-free mass-for-GA{col 47}kg{col 57}266-294 days
{col 6}{cmd:bfpfga}{col 15}body fat percentage-for-GA{col 47}%{col 57}266-294 days
{col 6}{cmd:fmfga}{col 18}fat-free mass-for-GA{col 47}kg{col 57}266-294 days
{col 5}{hline 77} 

{marker tab2}{...}
{col 5}{ul:INTERGROWTH-21st Postnatal Growth Standards for Preterm Infants}

{col 5}{it:acronym}{col 19}Description{col 42}Measurement{col 57}{cmd:xvar()} range
{col 5}{col 45}unit
{col 5}{hline 77}
{col 6}{cmd:wfa}{col 18}weight-for-age{col 46}kg{col 57}27 to 64 weeks
{col 6}{cmd:lfa}{col 18}length-for-age{col 46}cm{col 57}27 to 64 weeks
{col 6}{cmd:hcfa}{col 14}head circumference-for-age{col 46}cm{col 57}27 to 64 weeks
{col 6}{cmd:wfl}{col 17}weight-for-length{col 46}kg{col 57}35-65 cm
{col 5}{hline 77}

{marker tab3}{...}
{col 5}{ul:INTERGROWTH-21st Fetal Growth standards}

{col 5}{it:acronym}{col 15}Description{col 71}Measurement{col 86}{cmd:xvar()}
{col 5}{col 75}unit{col 86}range
{col 5}{hline 90}
{col 6}{cmd:hcfga}{col 14}head circumference-for-GA{col 76}mm{col 82}98-280 days
{col 6}{cmd:bpdfga}{col 14}biparietal diameter-for-GA{col 76}mm{col 82}98-280 days
{col 6}{cmd:acfga}{col 14}abdominal circumference-for-GA{col 76}mm{col 82}98-280 days
{col 6}{cmd:flfga}{col 14}femur length-for-GA{col 76}mm{col 82}98-280 days
{col 6}{cmd:ofdfga}{col 14}occipito-frontal diameter for-GA{col 76}mm{col 82}98-280 days
{col 6}{cmd:efwfga}{col 14}estimated fetal weight-for-GA{col 76}g{col 82}154-280 days
{col 6}{cmd:hefwfga}{col 14}Hadlock estimated fetal weight-for-GA{col 76}g{col 82}126-287 days
{col 6}{cmd:sfhfga}{col 14}symphisis-fundal height-for-GA{col 76}mm{col 82}112-294 days
{col 6}{cmd:crlfga}{col 14}crown-rump length-for-GA{col 76}mm{col 82}58-105 days
{col 6}{cmd:gafcrl}{col 14}GA-for-crown-rump length{col 75}days{col 82}15-95 mm
{col 6}{cmd:gwgfga}{col 14}weight gain-for-GA{col 76}kg{col 82}98-280 days
{col 6}{cmd:pifga}{col 14}pulsatility index-for-GA{col 76}NA{col 82}168-280 days
{col 6}{cmd:rifga}{col 14}resistance index-for-GA{col 76}NA{col 82}168-280 days
{col 6}{cmd:sdrfga}{col 14}systolic/diastolic ratio-for-GA{col 76}NA{col 82}168-280 days
{col 6}{cmd:tcdfga}{col 14}transcerebellar diameter-for-GA{col 76}mm{col 82}98-280 days
{col 6}{cmd:gaftcd}{col 14}GA-for-transcerebellar diameter{col 75}days{col 82}12-55 mm
{col 6}{cmd:poffga}{col 14}parietal-occipital fissure-for-GA{col 76}mm{col 82}105-252 days
{col 6}{cmd:sffga}{col 14}Sylvian fissue-for-GA{col 76}mm{col 82}105-252 days
{col 6}{cmd:avfga}{col 14}anterior horn of the lateral ventricle-for-GA{col 76}mm{col 82}105-252 days
{col 6}{cmd:pvfga}{col 14}atrium of the posterior horn of the lateral ventricle-for-GA{col 76}mm{col 82}105-252 days
{col 6}{cmd:cmfga}{col 14}cisterna magna-for-GA{col 76}mm{col 82}105-252 days
{col 5}{hline 90}

{marker tab4}{...}
{col 5}{ul:WHO Child Growth Standards}

{col 5}{it:acronym}{col 20}Description{col 42}Measurement{col 57}{cmd:xvar()} range
{col 5}{col 45}unit
{col 5}{hline 77}
{col 6}{cmd:hfa}{col 16}length/height-for-age{col 46}cm{col 57}0-1856 days
{col 6}{cmd:wfa}{col 20}weight-for-age{col 46}kg{col 57}0-1856 days
{col 6}{cmd:bfa}{col 21}BMI-for-age{col 44}kg/m^2{col 57}0-1856 days
{col 6}{cmd:hcfa}{col 14}head circumference-for-age{col 46}cm{col 57}0-1856 days
{col 6}{cmd:wfl}{col 18}weight-for-length{col 46}kg{col 57}45-110 cm
{col 6}{cmd:wfh}{col 18}weight-for-height{col 46}kg{col 57}65-120 cm
{col 6}{cmd:acfa}{col 15}arm circumference-for-age{col 46}cm{col 57}91-1856 days
{col 6}{cmd:ssfa}{col 13}subscapular skinfold-for-age{col 46}mm{col 57}91-1856 days
{col 6}{cmd:tsfa}{col 16}triceps skinfold-for-age{col 46}mm{col 57}91-1856 days
{col 5}{hline 77}

{marker remarks}{...}
{title:Remarks}

{pstd}These functions will return missing values where values are outside the
 ranges given in the above tables, but otherwise will not automatically detect 
 data errors. Ensure you check your data before using these functions or you may
 receive incorrect results, especially to make sure you have the correct units. 
 Additionally, when providing centiles to these functions with {cmd: "c2v"}, 
 ensure your inputs are between 0 and 1, or the function will return missing 
 values (e.g. for 25th centile, use 0.25; for 95th centile, use 0.95).

{marker examples}{...}
{title:Examples}

{pstd}Getting centiles from values ({cmd: "v2c"}) in the INTERGROWTH-21st
 Newborn Size Standard for weight-for-gestational age ({cmd:"wfga"}), where 
 {cmd:sex} contains the codes {cmd:1} and {cmd:2}:{p_end}
{phang2}{cmd:. egen z_wfga = ig_nbs(weight, "wfga", "v2c"), gest_days(ga_weeks * 7) sex(sex) sexcode(male=1, female=2)}

{pstd}Getting z-scores from values ({cmd: "v2z"}) in the INTERGROWTH-21st
 Newborn Size Standard for weight-for-gestational age ({cmd:"wfga"}), where 
 {cmd:sex} contains the codes {cmd:M} and {cmd:F}:{p_end}
{phang2}{cmd:. egen z_lfa = ig_png(len_cm, "lfa" , "v2z"), xvar(pma) sex(sex) sexcode(male=M, female=F)}

{pstd}Getting values for specific centiles ({cmd: "v2c"}) in the
 INTERGROWTH-21st Fetal Standard for abdominal circumference-for-gestational age
 ({cmd:"acfga"}):{p_end}
{phang2}{cmd:. egen abdocirc_mm = ig_fet(centile, "acfga", "v2c"), xvar(ga_days)}

{pstd}Getting values for z-scores ({cmd: "v2c"}) in the WHO Child Growth
 Standard for arm circumference-for-age ({cmd:"acfa"}), where 
 {cmd:sex} contains the codes {cmd:Male} and {cmd:Female}:{p_end}
{phang2}{cmd:. egen z_acfa = who_gs(zscores, "acfa", "z2v"), xvar(age_days) sex(sex) sexcode(male=Male, female=Female)}

{pstd}You can use just the first letter of the {cmd:sexcode()} arguments{p_end}
{phang2}{cmd:. egen z_acfa = who_gs(zscores, "acfa", "z2v"), xvar(age_days) sex(sex) sexcode(m=Male, f=Female)}

{pstd}Codes given to {cmd: sexcode()} cannot be abbreviated. They must be 
 typed exactly as they appear in your dataset. You can, however, swap the order
 and/or omit the comma in the {hi:sexcode()} option:{p_end}
{phang2}{cmd:. egen z_acfa = who_gs(zscores, "acfa", "z2v"), xvar(age_days) sex(sex) sexcode(f=Female m=Male)}{p_end}

{marker authors}{...}
{title:Authors}

{pstd}Simon R. Parker{p_end}
{pstd}Maternal, Adolescent, Reproductive, and Child Health (MARCH) Center{p_end}
{pstd}London School of Hygiene & Tropical Medicine{p_end}
{pstd}London, U.K.{p_end}
{pstd}simon.parker@lshtm.ac.uk{p_end}

{pstd}Linda Vesel}{p_end}
{pstd}Brigham and Women's Hospital, Boston{p_end}
{pstd}Massachusetts, U.S.A.{p_end}
{pstd}lvesel@ariadnelabs.org{p_end}

{pstd}Eric O. Ohuma{p_end}
{pstd}Maternal, Adolescent, Reproductive, and Child Health (MARCH) Center{p_end}
{pstd}London School of Hygiene & Tropical Medicine{p_end}
{pstd}London, U.K.{p_end}
{pstd}eric.ohuma@lshtm.ac.uk{p_end}

{title:Also see}

{p 4 14 2}Classification functions: {help classify_sfga:documentation}

{p 4 14 2}Article: {it:Stata Journal}, volume XX, number X: {browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":st0001}

{p 5 14 2}Manual: {manlink R egen}{p_end}

{p 7 14 2}Help: {manhelp egen R}, {manhelp functions D}, {manhelp generate D}{p_end}


