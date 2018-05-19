# delimit ;

**********************************************************************************;
* read in publicly available Vital Statistics multiple cause of death mortality  *;
* file from NCHS and convert into collapsed dataset of month/year mortality      *;
* for accidental firearm deaths.  These data were download from the NCHS webside,*;

* and we renamed the downloaded files mort07.dat - mort15.dat                    *;                             
**********************************************************************************;

* read in microdata for all deaths;

clear;
infix month 65-66 year 102-105 ageunit 70 age 71-73 icd10r 154-156 
	 using ../../data/raw/mort07.dat;

keep if ageunit == 1;

save ../../data/analytic/temp1.dta, replace;

clear;
infix month 65-66 year 102-105 ageunit 70 age 71-73 icd10r 154-156 
	 using ../../data/raw/mort08.dat;

keep if ageunit == 1;

append using ../../data/analytic/temp1.dta;
save ../../data/analytic/temp1.dta, replace;

clear;
infix month 65-66 year 102-105 ageunit 70 age 71-73 icd10r 154-156 
	 using ../../data/raw/mort09.dat;

keep if ageunit == 1;

append using ../../data/analytic/temp1.dta;
save ../../data/analytic/temp1.dta, replace;


forvalues num = 10/15{;
     clear;
infix month 65-66 year 102-105 ageunit 70 age 71-73 icd10r 154-156 
	 using ../../data/raw/mort`num'.dat;

keep if ageunit == 1;

append using ../../data/analytic/temp1.dta;
save ../../data/analytic/temp1.dta, replace;
};

compress;
save ../../data/analytic/temp1.dta, replace;

drop if age > 110;

gen firearm = icd10r == 119;
gen causedeath = "acc_firearms" if firearm == 1;
keep if causedeath == "acc_firearms";
drop firearm;

gen agecat = "0_14" if age <= 14;
     replace agecat = "15p" if age >= 15;
drop age;
	 
drop ageunit icd10r;

compress;
save ../../data/analytic/alldeathsmicro-public.dta, replace;
erase ../../data/analytic/temp1.dta;

*************************************************************************;
* create a collapsed dataset of mortality rates by month, year, and age *;
*************************************************************************;

clear;
use ../../data/analytic/alldeathsmicro-public.dta;
gen index = [_n];

sort year month causedeath;
collapse (count) numdeaths=index, by(year month agecat causedeath);

fillin year month agecat causedeath;
tab _fillin;
replace numdeaths = 0 if _fillin == 1;
drop _fillin;

sort year agecat;
merge year agecat using ../../data/raw/population-age-public.dta;
tab _merge;
drop if _merge ~= 3;
drop _merge;

sort year month agecat;
save ../../data/analytic/deaths-age-public.dta, replace;

