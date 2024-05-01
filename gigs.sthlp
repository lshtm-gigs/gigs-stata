{smcl}
{* *! version 0.4.2 01 May 2024}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "gigs: Conversion functions" "help ig_nbs"}{...}
{vieweralsosee "gigs: Classification functions" "help classify_sfga"}{...}
{vieweralsosee "gigs: Growth classification command" "help gigs_classify_growth"}{...}

{hi: help gigs}{right: ({browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":SJXX-X: st0001})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:gigs} {hline 2} Fetal, neonatal, and infant growth assessment using international growth standards}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd} The Guidance for International Growth Standards (GIGS) project is
 intended to make child growth assessment more accessible and repeatable,
 through statistical software and published guidance on which standards to use,
 where to use them, and when. As part of GIGS, we have implemented international
 growth standards from the World Health Organisation and INTERGROWTH-21st
 project in Stata. Our approach is applicable where gestational ages are known,
 such that the best available international standards are used to assess 
 infants' sizes from birth to 5 years of age.
 
{p 4 4 2}We have developed multiple functions for {cmd:egen}, which are 
 described in the documentation pages linked to from the 'Also see' dropdown on 
 this page. These functions either convert between anthropometric measures and 
 z-scores/centiles, or classify growth according to literature-based
 cut-offs. We have also written the {helpb gigs_classify_growth} command, which
 takes multiple anthropometric indices and applies the most suitable growth
 standards at each time point to classify common growth indicators such as
 size-for-gestational age, stunting, and wasting.

{marker authors}{...}
{title:Authors}

{pstd}Simon R. Parker {bf:(Maintainer, Author)}{p_end}
{pstd}Maternal, Adolescent, Reproductive, and Child Health (MARCH) Center{p_end}
{pstd}London School of Hygiene & Tropical Medicine{p_end}
{pstd}London, U.K.{p_end}
{pstd}simon.parker@lshtm.ac.uk{p_end}

{pstd}Linda Vesel {bf:(Author, Data Contributor)}{p_end}
{pstd}Brigham and Women’s Hospital, Boston{p_end}
{pstd}Massachusetts, U.S.A.{p_end}
{pstd}lvesel@ariadnelabs.org{p_end}

{pstd}Eric O. Ohuma {bf:(Author, Data Contributor)}{p_end}
{pstd}Maternal, Adolescent, Reproductive, and Child Health (MARCH) Center{p_end}
{pstd}London School of Hygiene & Tropical Medicine{p_end}
{pstd}London, U.K.{p_end}
{pstd}eric.ohuma@lshtm.ac.uk{p_end}

{title:Also see}

{p 4 14 2}GIGS conversion functions: {help ig_nbs:documentation}

{p 4 14 2}GIGS classification functions: {help classify_sfga:documentation}

{p 4 14 2}GIGS growth classification command: {help gigs_classify_growth:documentation}

{p 4 14 2}Article: {it:Stata Journal}, volume XX, number X: {browse "https://www.overleaf.com/project/641db63564edd62fb54c963b":st0001}


