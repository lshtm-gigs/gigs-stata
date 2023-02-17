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
You can install `stata-gain` from GitHub using the [`github`](https://www) module for Stata:
```stata
github install simpar1471/stata-gain
```

## Available standards
- `ig_vpns` - INTERGROWTH-21st standards for very preterm newborn size
  <details>
  <summary>
  Component standards
  </summary>

  - `wfga` - Weight (kg) for gestational age
  - `lfga` - Length (cm) for gestational age
  - `hcfga` - Head circumference (cm) for gestational age

  </details>
- `ig_nbs` - INTERGROWTH-21st standards for newborn size
  <details>
  <summary>
  Component standards
  </summary>

  - `wfga` - Weight (kg) for gestational age
  - `lfga` - Length (cm) for gestational age
  - `hcfga` - Head circumference (cm) for gestational age

  </details>
- `ig_png` - INTERGROWTH-21st standards for post-natal growth in preterm
  infants
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

  </details>

## Conversion functions
### INTERGROWTH-21st newborn size standards, including very preterm (NBS/VPNS)
Given a table with appropriate variables, such as the one below:

| **measurement** | **p** | **z** | **gest_age** | **sex** | **acronym** |
|-----------------|-------|-------|--------------|---------|-------------|
| 3.346           | 0.309 | -0.5  | 24           | M       | wfga        |
| 13.407          | 0.500 | 0     | 37           | F       | lfga        |
| 49.884          | 0.691 | 0.5   | 37           | M       | hcfga       |

Four INTERGROWTH-21st conversion functions can be used:

```ig_nbs_value2percentile measurement gest_age sex acronym```

```ig_nbs_percentile2value p gest_age sex acronym```

```ig_nbs_value2zscore measurement gest_age sex acronym```

```ig_nbs_zscore2value z gest_age sex acronym```


### INTERGROWTH-21st post-natal growth standard (PNG)
| **measurement** | **p** | **z** | **pma_weeks** | **sex** | **acronym** |
|-----------------|-------|-------|---------------|---------|-------------|
| XXXX            | 0.309 | -0.5  | 30            | M       | wfa         |
| XXXX            | 0.500 | 0     | 45            | F       | lfa         |
| XXXX            | 0.691 | 0.5   | 64            | M       | hcfa        |

```ig_nbs_value2percentile measurement pma_weeks sex acronym```

```ig_nbs_percentile2value p pma_weeks sex acronym```

```ig_nbs_value2zscore measurement pma_weeks sex acronym```

```ig_nbs_zscore2value z pma_weeks sex acronym```

### INTERGROWTH-21st size for gestational age
| **measurement** | **p** | **z** | **x_var** | **sex** | **acronym** |
|-----------------|-------|-------|-----------|---------|-------------|
| XXXX            | 0.158 | -1    | 24        | M       | wfga        |
| XXXX            | 0.309 | -0.5  | 37        | F       | lfga        |
| XXXX            | 0.500 | 0     | 37        | M       | hcfga       |
| XXXX            | 0.691 | 0.5   | 37        | F       | hcfga       |
| XXXX            | 0.841 | 1     | 37        | M       | hcfga       |

```ig_nbs_value2percentile measurement x_var sex acronym```

```ig_nbs_percentile2value p x_var sex acronym```

```ig_nbs_value2zscore measurement x_var sex acronym```

```ig_nbs_zscore2value z x_var sex acronym```

### Classification functions
**WIP - see later**