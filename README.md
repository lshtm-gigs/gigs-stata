# stata-gain: Assess newborn and infant growth in Stata
<!-- badges: start -->
[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
<!-- badges: end -->

## **About**
This package provides a unified interface to WHO Growth Standards data as well as growth information from the 
INTERGROWTH-21st project. In this package you will find functions for converting between anthropometric measures (e.g. 
weight or length) to z-scores and percentiles, and the inverse. Also included are functions for classifying newborn 
growth according to DHS guidelines.

## Installation
You can install `stata-gain` from GitHub using the [`github`](https://github.com/haghish/github) module for Stata:
```stata
github install simpar1471/stata-gain
```

## Available standards

- `ig_nbs` - INTERGROWTH-21<sup>st</sup> standards for newborn size
  (including very preterm)
  <details>
  <summary>
  Component standards
  </summary>

  - `wfga` - Weight (kg) for gestational age
  - `lfga` - Length (cm) for gestational age
  - `hcfga` - Head circumference (cm) for gestational age
  - `wlrfga` - Weight-to-length ratio for gestational age
  - `fmfga` - Fat mass (g) for gestational age
  - `bfpfga` - Body fat percentage for gestational age
  - `ffmfga` - Fat-free mass (g) for gestational age

  </details>
- `ig_png` - INTERGROWTH-21<sup>st</sup> standards for post-natal growth
  in preterm infants
  <details>
  <summary>
  Component standards
  </summary>

  - `wfa` - Weight (kg) for age (weeks)
  - `lfa` - Length (cm) for age (weeks)
  - `hcfa` - Head circumference (cm) for age (weeks)

  </details>
- `who_gs` - WHO Child Growth Standards for term infants
  <details>
  <summary>
  Component standards
  </summary>

  - `wfa` Weight (kg) for age (days)
  - `bfa` Body mass index for age (days)
  - `lhfa` Length/height (cm) for age (days)
  - `wfl` Weight (kg) for recumbent length (cm)
  - `wfh` Weight (kg) for standing height (cm)
  - `hcfa` Head circumference (mm) for age (days)
  - `acfa` Arm circumference (mm) for age (days)
  - `ssfa` Subscapular skinfold (mm) for age (days)
  - `tsfa` Triceps skinfold (mm) for age (days)

  </details>

## Conversion functions
### INTERGROWTH-21st newborn size standards
Given a table with appropriate variables, such as the one below:

| **measurement** | **p** | **z** | **gest_age** | **sex** | **acronym** |
|-----------------|-------|-------|--------------|---------|-------------|
| 3.346           | 0.309 | -0.5  | 24           | M       | wfga        |
| 13.407          | 0.500 | 0     | 37           | F       | lfga        |
| 49.884          | 0.691 | 0.5   | 37           | M       | hcfga       |

The INTERGROWTH-21<sup>st</sup> Newborn Size standards conversion function can be used to convert between 
measurements and percentiles/z-scores:

```stata
. local acronym = "wfga"
. local conversion = "v2p"
. drop if acronym != "`acro'" 
. egen v2p = ig_nbs(measurement, "`acronym'", "`conversion'"), gest_age(gest_age) 
    sex(sex) sexcode(male=M, female=F)
```


### INTERGROWTH-21st post-natal growth standard (PNG)
| **measurement** | **p** | **z** | **pma_weeks** | **sex** | **acronym** |
|-----------------|-------|-------|---------------|---------|-------------|
| XXXX            | 0.309 | -0.5  | 30            | M       | wfa         |
| XXXX            | 0.500 | 0     | 45            | F       | lfa         |
| XXXX            | 0.691 | 0.5   | 64            | M       | hcfa        |

The INTERGROWTH-21<sup>st</sup> Post-natal Growth standards conversion function can be used to convert between 
measurements and percentiles/z-scores for these data:

```stata
. local acronym = "wfa"
. local conversion = "z2v"
. drop if acronym != "`acro'" 
. egen z2v = ig_png(measurement, "`acronym'", "`conversion'"), pma_days(gest_age) 
    sex(sex) sexcode(male=M, female=F)
```

### Classification functions
### INTERGROWTH-21st size for gestational age
| **measurement** | **p** | **z** | **x_var** | **sex** | **acronym** |
|-----------------|-------|-------|-----------|---------|-------------|
| XXXX            | 0.158 | -1    | 24        | M       | wfga        |
| XXXX            | 0.309 | -0.5  | 37        | F       | lfga        |
| XXXX            | 0.500 | 0     | 37        | M       | hcfga       |
| XXXX            | 0.691 | 0.5   | 37        | F       | hcfga       |
| XXXX            | 0.841 | 1     | 37        | M       | hcfga       |

```stata
. local acronym = "wfa"
. local conversion = "z2v"
. drop if acronym != "`acro'" 
. egen sga = classify_sga(measurement, "`acronym'"), gest_age(gest_age) 
    sex(sex) sexcode(male=M, female=F)
```
