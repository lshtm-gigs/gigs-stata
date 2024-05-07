{smcl}
{* *! version 0.1.1 01 May 2023}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "gigs: Conversion functions" "help ig_nbs"}{...}
{vieweralsosee "gigs: Classification functions" "help classify_sfga"}{...}
{viewerjumpto "Syntax" "gigs_classify_growth##syntax"}{...}
{viewerjumpto "Description" "gigs_classify_growth##description"}{...}
{viewerjumpto "Options" "gigs_classify_growth##options"}{...}
{viewerjumpto "Remarks" "gigs_classify_growth##remarks"}{...}
{viewerjumpto "Examples" "gigs_classify_growth##examples"}{...}

{hi:help gigs_classify_growth}{right: ({browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":SJXX-X: st0001})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:gigs} {hline 2} Fetal, neonatal, and infant growth assessment using international growth standards}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:gigs_classify_growth} {it:outcomes} {ifin}{cmd:,}
 {cmdab:gest:_days}{cmd:(}{varname}{cmd:)} {cmdab:age:_days}{cmd:(}{varname}{cmd:)} {cmdab:sex}{cmd:(}{varname}{cmd:)}
 {cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} 
 {cmdab:f:emale=}{it:code}{cmd:)} [{cmdab:weight:_kg}{cmd:(}{varname}{cmd:)}
 {cmdab:lenht:_cm}{cmd:(}{varname}{cmd:)} 
 {cmdab:headcirc:_cm}{cmd:(}{varname}{cmd:)} {cmd:replace}]

{p 4 4 2}{cmd:by} cannot be used with this command.

{marker description}{...}
{title:Description}

{p 4 4 2}{cmd:gigs_classify_growth} is used to classify multiple common growth 
 indicators using anthropometric data. When run, this command generates new 
 variables with categories for size-for-gestational age, small vulnerable 
 newborn (SVN) types, stunting, wasting, underweight/weight-for-age, and head 
 size. It also generates variables with centiles/z-scores, pertinent to each 
 categorisation it performs.

{p 4 4 2}{it:outcomes} is used to specify which growth outcomes you want to 
 assess. This should be a space-separated list of the abbreviations in the table
 below. Each requested outcome will generate new variables, or replace existing 
 variables if the {cmd:replace} option is specified and the variables in the 
 below table already exist.
 
{marker tab1}{...}
{col 5}{ul:Acceptable tokens for {it:outcomes}}

{col 5}{it:outcome}{col 20}Description{col 49}New continuous variable{col 76}New categorical variable(s)
{col 5}{hline 100}
{col 6}{bf:all}{col 20}All outcomes{col 49}
{col 6}{bf:sfga}{col 20}Size-for-gestational age{col 49}{bf:birthweight_centile}{col 76}{bf:sfga} {bf:sfga_severe}
{col 6}{bf:svn}{col 20}Small vulnerable newborns{col 49}{bf:birthweight_centile}{col 76}{bf:svn}
{col 6}{bf:stunting}{col 20}Stunting{col 49}{bf:lhaz}{col 76}{bf:stunting} {bf:stunting_outliers}
{col 6}{bf:wasting}{col 20}Wasting{col 49}{bf:wlz}{col 76}{bf:wasting} {bf:wasting_outliers}
{col 6}{bf:wfa}{col 20}Weight-for-age{col 49}{bf:waz}{col 76}{bf:wfa} {bf:wfa_outliers}
{col 6}{bf:headsize}{col 20}Head size{col 49}{bf:hcaz}{col 76}{bf:headsize}
{col 5}{hline 100}
 
{p 4 4 2}You can list several different {it:outcomes} at once, to specify which
 you'd like to perform. So for example, you could supply the command with
 '{bf:stunting wasting}' to run only stunting and wasting analyses; or 
 '{bf:headsize}' to only do a head size analysis. The continuous variables 
 generated by {bf:gigs_classify_growth} are {bf:double}s, whereas the 
 categorical variables are labelled {bf:int}s.

{marker options}{...}
{title:Options}
{dlgtab:Required}

{phang}{opt gest:_days(varname numeric)} specifies gestational age in days for
 each observation. This variable is used with {cmd:age_days()} to determine 
 which growth standard is applied for each observation.

{phang}{opt age:_days(varname numeric)} specifies chronological age in days for
 each observation. This variable is used with {cmd:gest_days()} to determine 
 which growth standard is applied for each observation.

{phang}{opt sex(varname)} specifies the sex variable. It can be int, byte, or
 string. The codes for {cmd:male} and {cmd:female} must be specified by the 
 {hi:sexcode()} option.

{phang}{cmdab:sexc:ode}{cmd:(}{cmdab:m:ale=}{it:code}{cmd:,} 
 {cmdab:f:emale=}{it:code}{cmd:)} specifies the codes for {cmd:male} and 
 {cmd:female}. The codes can be specified in either order, and the comma is 
 optional. Quotes around the codes are not allowed, even if your sex variable is
 a string.

{dlgtab:Optional}

{phang}{opt weight:_kg(varname numeric)} specifies the weight in kg for
 each observation. The command will issue an error if you request 
 size-for-gestational age ({bf:sfga}), small vulnerable newborn ({bf:svn}), 
 stunting ({bf:stunting}), or weight-for-age ({bf:wfa}) analyses but do not 
 supply this option.

{phang}{opt lenht:_cm(varname numeric)} specifies the length or height in cm for
 each observation. It is assumed that where {hi:age_days()} is less than 731,
 recumbent length measurements are provided, and that where {hi:age_days()} is
 more than or equal to 731, standing height measurements are provided. The 
 command will issue an error if you request stunting ({bf:stunting}) or wasting 
 ({bf:wasting}) analyses but do not supply this option.

{phang}{opt headcirc:_cm(varname numeric)} specifies the length or height in cm
 for each observation. The command will issue an error if you request a 
 head size ({bf:headsize}) analysis but do not supply this option.
 
{phang}{opt replace} specifies whether {cmd:gigs_classify_growth} should replace
 values in variables. If the command runs in replace mode, messages will be 
 issued to the console describing which variables have been replaced.

{marker remarks}{...}
{title:Remarks}

{pstd}This command applies z-scoring based on the gestational age and age in
 days of each observation. In general, observations with a value in
 {cmd:age_days} < 0.5 are analysed with the {help ig_nbs:{bf:ig_nbs()}} egen 
 function. Preterm infants with a post-menstrual age of 27 to 64 weeks 
 (inclusive) are analysed with the {help ig_nbs:{bf:ig_png()}} egen function. 
 Term infants and preterm infants over 64 weeks' post-menstrual age are analysed
 with the {help ig_nbs:{bf:who_gs()}} egen function. Check out the source code 
 on GitHub to see exactly when/where each growth standard is applied.

{pstd}These functions will return missing values where values are outside the
 ranges specified for the {help ig_nbs##tab1:gigs conversion functions},
 but otherwise will not automatically detect data errors (e.g. providing data in
 incorrect units). Ensure you check your data before using this command or 
 you may receive incorrect results.
 
{marker examples}{...}
{title:Examples}

{pstd}These examples assume you have loaded the {bf:life6mo} dataset into Stata.
 You can access this data by running:{p_end}
{phang2}{cmd:. net get gigs, from("https://raw.githubusercontent.com/lshtm-gigs/gigs-stata/master")}{p_end}
{phang2}{cmd:. use life6mo}{p_end}

{pstd}Running all available classifications, where {cmd:sex} contains the codes {cmd:1} and {cmd:2}:{p_end}
{phang2}{cmd:. gigs_classify_growth all, age_days(age_days) gest_days(gestage) sex(sex) sexcode(male=1, female=2) weight_kg(wt_kg) lenht_cm(len_cm) headcirc_cm(headcirc_cm)}

{pstd}Running all available classifications in {cmd:replace} mode, only for observations where infants weigh < 2kg :{p_end}
{phang2}{cmd:. gigs_classify_growth sfga svn if weight_kg < 2, age_days(age_days) gest_days(gestage) sex(sex) sexcode(male=1, female=2) weight_kg(wt_kg) replace}

{pstd}You can use also use shorter versions of certain options (see the {help gigs_classify_growth##syntax:syntax diagram} for more information):{p_end}
{phang2}{cmd:. gigs_classify_growth stunting, age(age_days) gest(gestage) sex(sex) sexc(male=1, female=2) weight(wt_kg) lenht(len_cm) replace}

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

{p 4 14 2}Classification functions: {help classify_sfga:documentation}

{p 4 14 2}Article: {it:Stata Journal}, volume XX, number X: {browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":st0001}
