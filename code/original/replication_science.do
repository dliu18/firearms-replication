 delimit ;
set more 1;
set matsize 800;
capture log close;
log using replication_science.log, replace;
clear;

**********************;
* Replicate Figure 1 *;
**********************;
* The data are in an Excel spreadsheet that is provided in dataverse;

**********************;
* Replicate Figure 2 *;
**********************;

*First, create sales figures *;
******************************;
use bckcheck-state-public.dta;

keep if year>=2008;

collapse (sum) total, by(year month);

gen sandyhookp1 = year == 2012 & month == 12;
gen sandyhookp2 = year == 2013 & month == 1;
gen sandyhookp3 = year == 2013 & month == 2;
gen sandyhookp4 = year == 2013 & month == 3;
gen sandyhookp5 = year == 2013 & month == 4;

tab month, gen(monthdv);
forvalues y = 2009/2015 {;
  gen yrdv`y' = year == `y';
};

*Estimate de-seasonalized and de-trended gun sales;
regress total sandyhookp1-sandyhookp5 monthdv2-monthdv12 yrdv2009-yrdv2015;
predict resid, resid;

format total %10.0f;
*These residuals are the points for the times series in Figure 2.;
*The points for the Sandy Hook time period are the residuals + the coefficients on sandyhookp1-sandyhookp5.;
list year month total resid, clean;
clear;

* Next, create mortality bars *;
*******************************;
use deaths-age-public.dta;
keep if agecat=="0_14";

keep if month==12 | month<=4;

gen mortrate = (numdeaths/pop_byage)*100000;

* We use five-month December-April windows, with the year for each window defined as the later of the two years;
replace year = year+1 if month==12;
tab year;
drop if year<2008 | year>2015;

gen trend = year-2007;
gen trend2 = trend^2;

*We exclude the Sandy Hook window from our estimation of the trend;
regress mortrate trend trend2 if year ~= 2013;
predict resid, resid;

sort year;
collapse (sum) numdeaths mortrate resid, by(year);

list, clean;
clear;

**********************;
* Replicate Figure 3 *;
**********************;

use bckcheck-state-public.dta;

sort year stfips;
merge year stfips using population-state-public.dta;
tab _merge;

keep if year>=2008;

*Calculate sales per 100,000;
gen totalpc = (total/pop)*100000;

gen sandyhook = (year == 2012 & month == 12)|(year==2013 & month<=4);

tab month, gen(monthdv);
forvalues y = 2009/2015 {;
  gen yrdv`y' = year == `y';
};

foreach x in AK AL AR AZ CA CO CT DE FL GA HI IA ID IL IN KS LA MA MD ME MI MN MO MS MT ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX  VA VT WA WI WV WY {;

*Estimate de-seasonalized and de-trended gun sales;
*Multiply coefficients from these regressions by 5 to obtain values reported in Figure 3;
di "`x'";
regress totalpc sandyhook monthdv2-monthdv12 yrdv2009-yrdv2015 if stname=="`x'";
};
clear;

************************;
* Replication Figure 4 *;
************************;

use deaths-age-state-NOTPUBLIC.dta;
sort stfips year month;

sort stfips year month;
merge m:1 stfips year month using bckcheck-state-public.dta;
tab _merge;
drop if _merge ~= 3;
drop _merge;

sort stfips year agecat;
merge stfips year agecat using population-state-age-public;
tab _merge;
drop if _merge~=3;

keep if agecat == "0_14";
keep if month <= 4 | month == 12;
     replace year = year + 1 if month == 12;
drop if year < 2008 | year > 2015;

* drop states with clearly flawed gun sales data (DC, KY, NC, and UT);
drop if stfips == 11 | stfips == 21 | stfips == 37 | stfips == 49;

sort stfips year;

gen mortrate = (numdeaths/pop_byage)*100000;

collapse (mean) mortrate pop_byage, by(stfips year);

gen largeinc = stfips == 33 | stfips == 2 | stfips == 30 | stfips == 46 |	
    stfips == 56 | stfips == 54 | stfips == 40 | stfips == 29 |
	stfips == 38 | stfips == 16 | stfips == 27 | stfips == 47 | 
	stfips == 53 | stfips == 20 | stfips == 55 | stfips == 42 |
	stfips ==  5 | stfips == 31 | stfips == 28 | stfips == 22 |
	stfips == 41 | stfips ==  8	| stfips == 23 | stfips == 17 |
	stfips == 39 | stfips == 51 | stfips == 50 | stfips == 35 |
	stfips == 48 | stfips == 32 | stfips == 45;

tab largeinc;
sort stfips year;

sort largeinc year;
collapse (mean) mortrate [weight=pop_byage], by(largeinc year);

gen trend = year - 2007;
gen trend2 = trend^2;

regress mortrate trend trend2 if year ~= 2013 & largeinc == 1;
predict residbig, residual;
regress mortrate trend trend2 if year ~= 2013 & largeinc == 0;
predict residsml, residual;

sort largeinc year;
list year mortrate residbig largeinc if largeinc == 1, clean;
list year mortrate residsml largeinc if largeinc == 0, clean;
clear;

*********************************************************;
* Replication Table 1, Panel 1 (Descriptive Statistics) *;
*********************************************************;
use deaths-age-public.dta;
keep if year==2013;
keep if causedeath=="acc_firearms";

format pop_byage %10.0f;

*Multiply number of deaths by 5 to obtain average number of deaths in a 5-month window;
bysort agecat: summ numdeaths pop_byage;
clear;

*****************************;
*Replicate Table 1, panel 2 *;
*****************************;

use deaths-age-public.dta;

keep if year>=2008;

gen sandyhook=(year==2012 & month==12)|(year==2013 & month<=4);

collapse (sum) numdeaths pop_byage, by(year month agecat sandyhook);

gen mortrate=(numdeaths/pop_byage)*100000;

foreach x in 0_14 15p {;
di "`x'";
xi: regress mortrate i.month i.year sandyhook if agecat=="`x'";
};

collapse (sum) numdeaths pop_byage, by(year month sandyhook);

gen mortrate=(numdeaths/pop_byage)*100000;
summ mortrate;
xi: regress mortrate i.month i.year sandyhook;
clear;

*****************************;
*Replicate Table 1, panel 3 *;
*****************************;

use deaths-age-public.dta;

keep if year>=2008;

*Create total population variable that varies by year, but not by age;
egen pop=sum(pop_byage), by(year month);

sort year month;
merge year month using bckcheck-public.dta;
tab _merge;

*Calculate background checks per 100 population (which is the same as 1000s of background checks per 100,000);
gen totalpc=(total/pop)*100;

*Create sandyhook instruments;
gen sandyhook=(year==2012 & month==12)|(year==2013 & month<=4);

*Calculate mortality rate per 100,000;
gen mortrate=(numdeaths/pop_byage)*100000;

foreach x in 0_14 15p {;
di "`x'";
xi: ivregress 2sls mortrate i.month i.year (totalpc = sandyhook) if agecat=="`x'";
};

*Collapse to full population;
collapse (sum) numdeaths pop_byage, by(year month totalpc sandyhook);

*Calculate mortality rate for full population;
gen mortrate=(numdeaths/pop_byage)*100000;

xi: ivregress 2sls mortrate i.month i.year (totalpc=sandyhook);
clear;

************************************************************;
*Replicate Table 1, Panel 4                                *;
*The data for these regressions are not publicly available *;
************************************************************;

use deaths-age-state-NOTPUBLIC.dta;

keep if year>=2008;

sort stfips year agecat;
merge stfips year agecat using population-state-age-public.dta;
tab _merge;
keep if _merge==3; 
capture drop _merge;

sort stfips year month;
merge stfips year month using bckcheck-state-public.dta;
tab _merge;
keep if _merge==3;

*Exclude states with clearly flawed gun sales data (DC, KY NC, and UT);
drop if stfips==11|stfips==21|stfips==37|stfips==49;

*Create sandyhook instruments;
gen sandyhook=(year==2012 & month==12)|(year==2013 & month<=4);
gen shook_obama=sandyhook*pctobama;

gen stmonth=(stfips*100)+month;

*Create total population variable that varies by year, but not by age;
egen pop=sum(pop_byage), by(stfips year month);

*Calculate background checks per 100 population (which is the same as 1000s of background checks per 100,000);
gen totalpc=(total/pop)*100;

*Calculate mortality rate per 100,000;
gen mortrate=(numdeaths/pop_byage)*100000;

foreach x in 0_14 15p {;
xi: ivreg2 mortrate i.month i.stname*i.year i.stname*i.month (totalpc = sandyhook shook_obama) if agecat=="`x'" [weight=pop_byage], cluster(stname);
};

*Collapse to full-population;
collapse (sum) numdeaths, by(stfips stname year month total pop totalpc sandyhook shook_obama);

*Calculate mortality rate for full population;
gen mortrate=(numdeaths/pop)*100000;

xi: ivreg2 mortrate i.month i.stname*i.year i.stname*i.month (totalpc = sandyhook shook_obama) [weight=pop], cluster(stname);
clear;
