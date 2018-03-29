#delimit ;
set more 1;
set matsize 800;
capture log close;
log using replication_science.log, replace;
clear;

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
regress totalpc sandyhook monthdv2-monthdv12 yrdv2009-yrdv2015 if stname=="`x'" & year <= 2015;
};
clear;
