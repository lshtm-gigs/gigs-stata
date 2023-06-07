{smcl}
{* *! version 1.0 02 May 2023}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "gigs: Classification functions" "help classify_sga"}{...}
{viewerjumpto "Syntax" "ig_nbs##syntax"}{...}
{viewerjumpto "Description" "ig_nbs##description"}{...}
{viewerjumpto "Functions" "ig_nbs##functions"}{...}
{viewerjumpto "Options" "ig_nbs##options"}{...}
{viewerjumpto "Available Standards" "ig_nbs##standards"}{...}
{viewerjumpto "Remarks" "ig_nbs##remarks"}{...}
{viewerjumpto "Examples" "ig_nbs##examples"}{...}

{hi:help classify_sga, help classify_stunting, help classify_wasting, help classify_wfa}{right: ({browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":SJXX-X: st0001})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:gigs} {hline 2} Standardising child growth assessment with extensions to egen}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:classify_sga}{cmd:(}{varname}{cmd:)} 
{ifin}{cmd:,} 
{cmdab:gest:_age}{cmd:(}{varname}{cmd:)} {cmdab:sex}{cmd:(}{varname}{cmd:)}
{cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} {cmdab:f:emale=}{it:code}{cmd:)}

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:classify_stunting}{cmd:(}{varname}{cmd:)} 
{ifin}{cmd:,} 
{cmdab:ga:_at_birth}{cmd:(}{varname}{cmd:)} {cmdab:age_days}{cmd:(}{varname}{cmd:)}
{cmdab:sex}{cmd:(}{varname}{cmd:)} {cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} {cmdab:f:emale=}{it:code}{cmd:)}

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:classify_wasting}{cmd:(}{varname}{cmd:)} 
{ifin}{cmd:,} 
{cmdab:lenht:_cm}{cmd:(}{varname}{cmd:)} {cmd:lenht_method}{cmd:(}{varname}{cmd:)}
{cmdab:lenhtc:ode}{cmd:(}{cmdab:l:ength=}{it:code}{cmd:,} {cmdab:h:eight=}{it:code}{cmd:)}
{cmdab:sex}{cmd:(}{varname}{cmd:)}
{cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} {cmdab:f:emale=}{it:code}{cmd:)}

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{cmd:classify_wfa}{cmd:(}{varname}{cmd:)} 
{ifin}{cmd:,} 
{cmdab:ga:_at_birth}{cmd:(}{varname}{cmd:)} {cmd:age_days}{cmd:(}{varname}{cmd:)}
{cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} {cmdab:f:emale=}{it:code}{cmd:)}

{p 4 4 2}{cmd:by} cannot be used with these functions.

{marker description}{...}
{title:Description}

{p 4 4 2}(This is the general specification copied from the help for
{helpb egen}.)

{p 8 17 2}{cmd:egen} [{it:{help datatype:type}}] {newvar} {cmd:=}
{it:fcn}{cmd:(}{it:arguments}{cmd:)} {ifin} [{cmd:,} {it:options}]

{p 4 4 2}where depending on the {it:fcn}, {it:arguments} refers to an
 expression, {varlist}, or {it:{help numlist}}, and the {it:options} are
 also {it:fcn} dependent.

{p 4 4 2}We have developed multiple functions for {cmd:egen}, as part of the
 Guidance for International Growth Standards (GIGS) project. Each of the
 functions described in this help file are used to classify growth indicators
 from anthropometric data, namely size-for-gestational age, stunting, wasting,
 and underweight.

{marker functions}{...}
{title:Functions for egen}

{p 4 4 2}{hi:classify_sga(}{varname}{cmd:)} is used to classify size for 
 gestational age in newborns according to INTERGROWTH-21st 
 weight-for-gestational age standards. It producess a variable with the 
 following values and labels:
 
{col 9}Value{col 17}Label{col 56}Centile range
{col 9}{hline 68}
{col 10}{cmd:-2}{col 17}Severely small for gestational age  {col 56}<3rd centile
{col 10}{cmd:-1}{col 17}Small for gestational age (SGA)     {col 56}<10th centile
{col 11}{cmd:0}{col 17}Appropriate for gestational age (SGA){col 56}10th to 90th centile
{col 11}{cmd:1}{col 17}Large for gestational age (SGA)      {col 56}>90th centile
 
{pmore}This function takes one argument:

{pmore}{varname} is the variable name for newborn weight in your dataset (for
 example, {cmd:weight_kg}, {cmd:mean_wgt}).

{p 4 4 2}{hi:classify_stunting(}{varname}{cmd:)} is used to classify stunting in infants up to five
 years old using the INTERGROWTH-21st standards for post-natal growth or WHO
 Child Growth Standards as appropriate. It producess a variable with the 
 following values and labels:

{col 20}Value{col 27}Label{col 45}{it:Z}-score range
{col 20}{hline 38}
{col 22}{cmd:-2} {col 27}Severe stunting{col 45}-5 to -3
{col 22}{cmd:-1} {col 27}Stunting       {col 45}-3 to -2
{col 23}{cmd:0}  {col 27}Not stunting    {col 45}-2 to 5
{col 21}{cmd:-10}{col 27}Implausible     {col 45}<-5 or >5
 
{pmore}This function takes one argument:

{pmore}{varname} is the variable name of height/length in your dataset (for
 example, {cmd:meaninflen}, {cmd:lenht}).
 
{p 4 4 2}{hi:classify_wasting(}{varname}{cmd:)} is used to classify wasting in
 infants up to five years old using the WHO Child Growth Standards for
 weight-for-length and weight-for-height as appropriate. It producess a variable
 with the following values and labels:

{col 20}Value{col 27}Label{col 45}{it:Z}-score range
{col 20}{hline 38}
{col 22}{cmd:-2} {col 27}Severe wasting{col 45}-5 to -3
{col 22}{cmd:-1} {col 27}Wasting       {col 45}-3 to -2
{col 23}{cmd:0}  {col 27}Normal        {col 45}-2 to 2
{col 23}{cmd:1}  {col 27}Overweight    {col 45}2 to 5
{col 21}{cmd:-10}{col 27}Implausible   {col 45}<-5 or >5

{pmore}This function takes one argument:

{pmore}{varname} is the variable name for weight in kg in your dataset (for
 example, {cmd:weight_kg}, {cmd:mean_wgt}).

{p 4 4 2}{hi:classify_wfa(}{varname}{cmd:)} is used to classify weight-for-age
 in infants up to five years old using the INTERGROWTH-21st standards for
 post-natal growth or WHO Child Growth Standards as appropriate. It producess a
 variable with the following values and labels:

{col 20}Value{col 27}Label{col 50}{it:Z}-score range
{col 20}{hline 43}
{col 22}{cmd:-2} {col 27}Severely underweight{col 50}-6 to -3
{col 22}{cmd:-1} {col 27}Underweight         {col 50}-3 to -2
{col 23}{cmd:0}  {col 27}Normal weight       {col 50}-2 to 2
{col 23}{cmd:1}  {col 27}Overweight          {col 50} 2 to 5
{col 21}{cmd:-10}{col 27}Implausible         {col 50}<-6 or >5

{pmore}This function takes one argument:

{pmore}{varname}is the variable name for weight in kg in your dataset (for
 example, {cmd:weight_kg}, {cmd:mean_wgt}).
 
{marker options}{...}
{title:Options}
{dlgtab:Non-specific}

{phang}{opt sex(varname)} specifies the sex variable.  It
can be string or numeric. The codes for {cmd:male} and {cmd:female}
must be specified by the {hi:sexcode()} option.

{phang}{cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} {cmdab:f:emale=}{it:code}{cmd:)}
 specifies the codes for {cmd:male} and {cmd:female}. The codes can be specified
 in either  order, and the comma is optional. Quotes around the codes are not
 allowed, even if your sex variable is a string. 

{dlgtab:Size-for-GA classification}

{phang}{opt gest:_age(varname numeric)} specifies gestational age in days for
 newborns. Any value outside the range of valid gestational ages as specified in
 the {help ig_nbs:ig_nbs() documentation} will return a missing value.

{dlgtab:Wasting classification}

{phang}{opt ga:_at_birth(varname numeric)} specifies the gestational age at
 birth in days for each observation.

{phang}{opt age_days(varname numeric)} specifies age in days for each
 observation.

{dlgtab:Stunting classification}

{phang}{opt lenht:_cm(varname numeric)} specifies the length or height in cm for
 each observation. The method used to obtain these values should be recorded in
 {cmd:lenht method()}.

{phang}{opt lenht_method(varname numeric)} specifies whether recumbent length or
 standing height were used to measure infant size for each observation. The
 codes for {cmd:length} and {cmd:height} must be provided by the
 {cmd:lenht_code()} option.
 
{phang}{cmdab:lenhtc:ode}{cmd:(}{cmdab:l:ength=}{it:code}{cmd:,} {cmdab:h:eight=}{it:code}{cmd:)}
 specifies the codes for {cmd:length} and {cmd:height}. The codes can be specified
 in either  order, and the comma is optional. Quotes around the codes are not
 allowed, even if your {cmd:lenht_method()} variable is a string. 

{dlgtab:Weight-for-age classification}

{phang}{opt ga:_at_birth(varname numeric)} specifies the gestational age at
 birth in days for each observation.

{phang}{opt age_days(varname numeric)} specifies age in days for each
 observation.

{marker remarks}{...}
{title:Remarks}

{pstd}These functions will return missing values where values are outside the
 ranges specified for the {help ig_nbs##standards:gigs conversion functions},
 but otherwise will not automatically detect data errors. Ensure you check your 
 data before using these functions or you may receive incorrect results.
 
{marker examples}{...}
{title:Examples}

{pstd}Classifying SGA, where {cmd:sex} contains the codes {cmd:1} and {cmd:2}:{p_end}
{phang2}{cmd:. egen sga = classify_sga(weight_kg), gest_age(ga_days) sex(sex) sexcode(male=1, female=2)}

{pstd}Classifying stunting, where {cmd:sex} contains the codes {cmd:M} and {cmd:F}:{p_end}
{phang2}{cmd:. egen stunting = classify_stunting(weight_kg), ga_at_birth(ga_days) age_days(age) sex(sex) sexcode(male=M, female=F)}

{pstd}Classifying wasting, where {cmd:sex} contains the codes {cmd:M} and {cmd:F} and {cmd:lenht_method} contains the codes {cmd:Length} and {cmd:Height}:{p_end}
{phang2}{cmd:. egen wasting = classify_wasting(weight_kg), lenht(lenht_cm) lenht_method(method) lenhtcode(length=Length, height=Height) sex(sex) sexcode(male=M, female=F)}

{pstd}You can use just the first letters of the {cmd:sexcode()} and {cmd:lenhtcode()} arguments instead:{p_end}
{phang2}{cmd:. egen wasting = classify_wasting(weight_kg), lenht(lenht_cm) lenht_method(method) lenhtcode(l=Length, h=Height) sex(sex) sexcode(m=M, f=F)}

{pstd}Classifying weight-for-age, where {cmd:sex} contains the codes {cmd:Male} and {cmd:Female}:{p_end}
{phang2}{cmd:. egen wfa = classify_wfa(weight_kg), ga_at_birth(ga_days) age_days(age) sex(sex) sexcode(m=Male, f=Female)}

{marker authors}{...}
{title:Authors}

{pstd}Simon R. Parker{p_end}
{pstd}Maternal, Adolescent, Reproductive, and Child Health (MARCH) Center{p_end}
{pstd}London School of Hygiene and Tropical Medicine{p_end}
{pstd}London, U.K.{p_end}
{pstd}simon.parker@lshtm.ac.uk{p_end}

{pstd}Eric O. Ohuma{p_end}
{pstd}Maternal, Adolescent, Reproductive, and Child Health (MARCH) Center{p_end}
{pstd}London School of Hygiene and Tropical Medicine{p_end}
{pstd}London, U.K.{p_end}
{pstd}eric.ohuma@lshtm.ac.uk{p_end}

{title:Also see}

{p 4 14 2}Conversion functions: {help ig_nbs:documentation}

{p 4 14 2}Article:  {it:Stata Journal}, volume XX, number X: {browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":st0001}

{p 5 14 2}Manual:  {manlink R egen}{p_end}

{p 7 14 2}Help:  {manhelp egen R}, {manhelp functions D}, {manhelp generate D}{p_end}


