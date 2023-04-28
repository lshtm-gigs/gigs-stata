{smcl}
{* *! version 1.0 28 Apr 2023}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "gigs: Conversion Functions" "help gigs"}{...}
{viewerjumpto "Syntax" "classify_sga##syntax"}{...}
{viewerjumpto "Description" "classify_sga##description"}{...}
{viewerjumpto "Options" "classify_sga##options"}{...}
{viewerjumpto "Remarks" "classify_sga##remarks"}{...}
{viewerjumpto "Examples" "classify_sga##examples"}{...}

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

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt gest_age(varname numeric)}  

{phang}
{opt sex(varname)}  

{phang}
{opt sexc:ode(string)}  



{marker examples}{...}
{title:Examples}


{title:Author}
{p}

{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume XX, number X: {browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":st0001}

{p 5 14 2}Manual:  {manlink R egen}{p_end}

{p 7 14 2}Help:  {manhelp egen R}, {manhelp functions D}, {manhelp generate D}{p_end}


