/*
Classify size for gestational age, stunting, wasting and weight for age using 
WHO Growth Standards and the INTERGROWTH-21st standards as appropriate.
*/
*! Author: Simon Parker
*! version 0.0.0.1	17/02/2023
capture program drop classify_sga
capture program drop classify_stunting
capture program drop classify_wasting
capture program drop classify_wfa

// program define classify_sga
// 	args lenht_cm age_days ga_at_birth sex lenht_method
// end