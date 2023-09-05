# gigs: Newborn and infant growth assessment in Stata
<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

## About
Produced as part of the Guidance for International Growth Standards project, 
`gigs` provides a single, simple interface for working with the WHO Child Growth
Standards and outputs from the INTERGROWTH-21<sup>st</sup> project. You will 
find functions for converting between anthropometric measures (e.g. weight or 
length) to z-scores and percentiles, and the inverse. Also included are 
functions for classifying newborn and infant growth according to 
literature-based cut-offs.

## Installation
You can install the latest stable release of `gigs` from GitHub using the 
[`github` module](https://haghish.github.io/github/) for Stata:
```stata
. github install lshtm-gigs/gigs-stata, stable
```

## Available standards
- `ig_nbs` - INTERGROWTH-21<sup>st</sup> standards for newborn size
  <details>
  <summary>
  Component standards
  </summary>

  | Acronym  | Description                                | Unit  | `gest_age()` range |
  |----------|--------------------------------------------|-------|--------------------|
  | `wfga`   | Weight-or-gestational age                  | kg    | 168 to 300 days    |
  | `lfga`   | Length-for-gestational age                 | cm    | 168 to 300 days    |
  | `hcfga`  | Head circumference-for-gestational age     | cm    | 168 to 300 days    |
  | `wlrfga` | Weight-to-length ratio-for-gestational age | kg/cm | 168 to 300 days    |
  | `ffmfga` | Fat-free mass-for-gestational age          | kg    | 266 to 294 days    |
  | `bfpfga` | Body fat percentage-for-gestational age    | %     | 266 to 294 days    |
  | `fmfga`  | Fat mass-for-gestational age               | kg    | 266 to 294 days    |

  </details>
- `ig_png` - INTERGROWTH-21<sup>st</sup> standards for postnatal growth in
  preterm infants
  <details>
  <summary>
  Component standards
  </summary>
  
  | Acronym | Description                | Unit | `xvar()` range        |
  |---------|----------------------------|------|-----------------------|
  | `wfa`   | weight-for-age             | kg   | 27 to <64 exact weeks |
  | `lfa`   | length-for-age             | cm   | 27 to <64 exact weeks |
  | `hcfa`  | head circumference-for-age | cm   | 27 to <64 exact weeks |
  | `wfl`   | weight-for-length          | kg   | 35 to 65 cm           |

  </details>
- `who_gs` - WHO Child Growth Standards for term infants
  <details>
  <summary>
  Component standards
  </summary>
  
  | Acronym | Description                  | Unit             | `xvar()` range  |
  |---------|------------------------------|------------------|-----------------|
  | `wfa`   | weight-for-age               | kg               | 0 to 1856 days  |
  | `bfa`   | BMI-for-age                  | kg/m<sup>2</sup> | 0 to 1856 days  |
  | `lhfa`  | length/height-for-age        | cm               | 0 to 1856 days  |
  | `hcfa`  | head circumference-for-age   | cm               | 0 to 1856 days  |
  | `wfl`   | weight-for-height            | kg               | 45 to 110 cm    |
  | `wfh`   | weight-for-length            | kg               | 65 to 120 cm    |
  | `acfa`  | arm circumference-for-age    | cm               | 91 to 1856 days |
  | `ssfa`  | subscapular skinfold-for-age | mm               | 91 to 1856 days |
  | `tsfa`  | triceps skinfold-for-age     | mm               | 91 to 1856 days |

  </details>

## Conversion functions
Each conversion function has similar syntax. The main function call determines
the set of standards in use, the `acronym` parameter specifies which component 
standard is being used, and the `conversion` parameter specifies the type of 
conversion you wish to perform. The `sex()` and `sexcode()` options are used to 
give the function sex data - as the growth standards are sex-specific, the
standards cannot be applied correctly without this information.

### INTERGROWTH-21<sup>st</sup> Newborn Size standards, including very preterm
This function can be used to convert between measurements and 
z-scores/percentiles in each of the INTERGROWTH-21<sup>st</sup> Newborn Size
Standards. 

![](./readme/readme_ignbs.png)

### INTERGROWTH-21<sup>st</sup> Postnatal Growth standards
This function can be used to convert between measurements and 
z-scores/percentiles in each of the INTERGROWTH-21<sup>st</sup> Postnatal 
Growth of Preterm Infants Standards.

![](./readme/readme_igpng.png)

### WHO Child Growth Standards
This function can be used to convert between measurements and 
z-scores/percentiles in each of the WHO Child Growth Standards.

![](./readme/readme_whogs.png)

### Classification functions
These functions are used to classify infant growth according to published 
cut-offs. These publications are discussed in the attached [paper](). 

#### Size for gestational age
![](./readme/readme_csga.png)

This function outputs a variable with the following values and labels:

| Value | Meaning                               | Centile range                      |
|-------|---------------------------------------|------------------------------------|
| -2    | Severely small for gestational age    | <3<sup>rd</sup>                    |
| -1    | Small for gestational age (SGA)       | <10<sup>th</sup>                   |
| 0     | Appropriate for gestational age (AGA) | 10<sup>th</sup> to 90<sup>th</sup> |
| 1     | Large for gestational age (LGA)       | \>90<sup>th</sup>                  |

#### Stunting
![](./readme/readme_cstunting.png)

The function outputs a variable with the following values and labels:

| Value | Meaning         | Z-score range |
|-------|-----------------|---------------|
| -2    | Severe stunting | -5 to -3      |
| -1    | Stunting        | -3 to -2      |
| 0     | Normal          | -2 to 5       |
| -10   | Implausible     | \<-5 or \>5   |

#### Wasting
![](./readme/readme_cwasting.png)

The function outputs a variable with the following values and labels:

| Value | Meaning        | Z-score range |
|-------|----------------|---------------|
| -2    | Severe wasting | -5 to -3      |
| -1    | Wasting        | -3 to -2      |
| 0     | Normal         | -2 to 2       |
| 1     | Overweight     | 2 to 5        |
| -10   | Implausible    | \<-5 or \>5   |

#### Weight-for-age
![](./readme/readme_cwfa.png)

The function outputs a variable with the following values and labels:

| Value | Meaning              | Z-score range |
|-------|----------------------|---------------|
| -2    | Severely underweight | -6 to -3      |
| -1    | Underweight          | -3 to -2      |
| 0     | Normal weight        | -2 to 2       |
| 1     | Overweight           | 2 to 5        |
| -10   | Implausible          | \<-6 or \>5   |

## Examples
This section illustrates a possible use case using `life6mo.dta`, an extract of
data from the Low birthweight Infant Feeding Exploration (LIFE) Study. It 
contains weight measurements for term and preterm infants from birth 
(`visitweek == 0`) to around six months of age (`visitweek == 26`).

```stata
. use life6mo
. local 40weeks 7 * 40
. local 37weeks 7 * 37
. list in f/10, noobs abbreviate(10) sep(10)
 ___________________________________________________________
| infantid     gestage   pma   sex   visitweek   meaninfwgt |
|-----------------------------------------------------------|
| 101-1002-1   132       133   2     0           2300       |
| 101-1002-1   132       139   2     1           2270       |
| 101-1002-1   132       146   2     2           2465       |
| 101-1002-1   132       162   2     4           2700       |
| 101-1002-1   132       174   2     6           3160       |
| 101-1002-1   132       203   2     10          4004       |
| 101-1002-1   132       230   2     14          4893.333   |
| 101-1002-1   132       258   2     18          5690       |
| 101-1002-1   132       317   2     26          6950       |
| 101-1003-1   237       238   1     0           1900       |
|-----------------------------------------------------------|
```



### Conversion
We can use the conversion functions listed above to generate weight-for-age 
z-scores (WAZs) in the different study populations (i.e. term vs preterm) and 
measurement  timings (i.e. z-scores for newborns with 
INTERGROWTH-21<sup>st</sup> Newborn Size Standards, WHO/INTERGROWTH Postnatal 
standards after birth).

```stata
. egen waz_nbs = ig_nbs(meaninfwgt/1000, "wfga", "v2z") ///
>     if visitweek == 0, ///
>     gest_age(gestage) sex(sex) sexcode(m=1, f=2)
(7,308 missing values generated)

. gen agedays = pma - gestage
. egen waz_who = who_gs(meaninfwgt/1000, "wfa", "v2z") ///
>     if gestage > `37weeks´ & visitweek > 0, ///
>     xvar(agedays) sex(sex) sexcode(m=1, f=2)
(4,657 missing values generated)
. drop agedays

. gen pma_weeks = round(pma/7, 1)
. egen waz_png = ig_png(meaninfwgt/1000, "wfa", "v2z") ///
>     if gestage < `37weeks´ & visitweek > 0 & visitweek <= 18, ///
>     pma_weeks(pma_weeks) sex(sex) sexcode(m=1, f=2)
(5,391 missing values generated)
. drop pma_weeks

. gen age_corrected = pma - `40weeks´
. egen waz_whocorr = who_gs(meaninfwgt/1000, "wfa", "v2z") ///
>     if gestage < `37weeks´ & visitweek == 26, ///
>     xvar(age_corrected) sex(sex) sexcode(m=1, f=2)
(7,996 missing values generated)
. drop age_corrected
```

We can then combine these WAZs into one overall `waz` variable:

```stata
. gen waz = waz_who if gestage > `37weeks´
(4,657 missing values generated)

. replace waz = waz_nbs if visitweek == 0
(1,112 real changes made, 4 to missing)

. replace waz = waz_png if gestage < `37weeks´ & visitweek > 0 & visitweek <= 18
(3,025 real changes made)

. replace waz = waz_whocorr if gestage < `37weeks´ & visitweek == 26
(420 real changes made)

. list gestage pma visitweek waz_* waz in f/10, noobs
 __________________________________________________________________________
| gestage   pma   week   waz_who   waz_nbs   waz_png   waz_whocorr   waz   |
|--------------------------------------------------------------------------|
| 132       133   0      .         .         .         .             .     |
| 132       139   1      .         .         .         .             .     |
| 132       146   2      .         .         .         .             .     |
| 132       162   4      .         .         .         .             .     |
| 132       174   6      .         .         .         .             .     |
| 132       203   10     .         .         7.859     .             7.859 |
| 132       230   14     .         .         6.699     .             6.699 |
| 132       258   18     .         .         5.612     .             5.612 |
| 132       317   26     .         .         .         3.512         3.512 |
| 237       238   0      .         -.712     .         .             -.712 |
|--------------------------------------------------------------------------|
```



This `waz` variable can then be used to determine whether infants are 
underweight at different age points, or to track the growth trajectory of
individual children.

### Classification
This dataset contains information on weight at birth, so could be used to 
calculate size-for-gestational age classifications. We can reload the data, then
remove any observations which were not made at birth. We then use the 
`classify_sga()` command to give us our classifications:
```stata
. use life6mo, clear
. drop if visitweek != 0
(7,303 observations deleted)
```
```
. egen sga = classify_sga(meaninfwgt/1000), ///
>     gest_age(gestage) sex(sex) sexcode(m=1, f=2)
(5 missing values generated)
```

Authors
------
  **S. R. Parker**  
  Maternal, Adolescent, Reproductive, and Child Health Centre  
  London School of Hygiene and Tropical Medicine
  
  **Dr E. O. Ohuma**  
  Maternal, Adolescent, Reproductive, and Child Health Centre  
  London School of Hygiene and Tropical Medicine