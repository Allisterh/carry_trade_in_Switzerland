* IMPORTANT - WINDOWS USERS
* FIRST - CREATE A NEW DIRECTORY IN "C:\TOMIOVALLET" 
* SECOND - PLACE ALL FILES IN THE NEW DIRECTORY "C:\TOMIOVALLET"

clear all

log using "resultats_`c(current_date)'.log", replace

capture log

set more off

global data "C:\TOMIOVALLET\"

cd "$data\"

import excel "C:\TOMIOVALLET\bttomio - CHF.xls", firstrow

format Obs %tw

tsset Obs

*Generate new variables

g CT = Short/Long

mvencode CT, mv(0)

g IRD = IR - USIR /// Ref. Brunnermeier et al. (2008, p. 8)

*Group of variables

global levelvar CT ER IRD VIX SM SMUS

*Generate time dummy, following changes in IR (Switzerland, SNB)

*PI dummy is equal to one in the period of positive interest rates

gen PI=(Obs<=378)

*NI dummy is equal to one in the period of negative interest rates (23 December 
*> 2014, onwards).

gen NI=(Obs>=379)

*ME2 dummy is equal to one to the recent monetary easing in the U.S.

gen ME2=(Obs>=620)

***Unit root tests

** CLEMIO*****

ssc install clemao_io

*PI

putexcel set results.xls, sheet("CLEMIO") modify

clemio1 CT if PI==1
putexcel B2=rscalars

clemio1 ER if PI==1
putexcel C2=rscalars

clemio1 IRD if PI==1
putexcel D2=rscalars

clemio1 VIX if PI==1
putexcel E2=rscalars

clemio1 SM if PI==1
putexcel F2=rscalars

clemio1 SMUS if PI==1
putexcel G2=rscalars

*NI

clemio1 CT if NI==1
putexcel B10=rscalars

clemio1 ER if NI==1
putexcel C10=rscalars

clemio1 IRD if NI==1
putexcel D10=rscalars

clemio1 VIX if NI==1
putexcel E10=rscalars

clemio1 SM if NI==1
putexcel F10=rscalars

clemio1 SMUS if NI==1
putexcel G10=rscalars

*Descriptive statistics

set more off

putexcel set results.xls, sheet("DESC STATS") modify

su CT if PI==1, detail 
putexcel H3=rscalars

su ER if PI==1, detail 
putexcel I3=rscalars

su IRD if PI==1, detail 
putexcel J3=rscalars

su VIX if PI==1, detail 
putexcel K3=rscalars

su SM if PI==1, detail 
putexcel L3=rscalars

su SMUS if PI==1, detail 
putexcel M3=rscalars

su CT if NI==1, detail 
putexcel N3=rscalars

su ER if NI==1, detail 
putexcel O3=rscalars

su IRD if NI==1, detail 
putexcel P3=rscalars

su VIX if NI==1, detail 
putexcel Q3=rscalars

su SM if NI==1, detail 
putexcel R3=rscalars

su SMUS if NI==1, detail 
putexcel S3=rscalars

****************************************************
*PI
****************************************************

set more off

matrix A1 = (1, 0, 0, 0, 0, 0 \ ., 1, 0, 0, 0, 0 \ ., ., 1, 0, 0, 0 \ ., ., ., 1, 0, 0 \ ., ., ., ., 1, 0 \ ., ., ., ., ., 1)

matrix B1 = (., 0, 0, 0, 0, 0 \ 0, ., 0, 0, 0, 0 \ 0, 0, ., 0, 0, 0 \ 0, 0, 0, ., 0, 0 \ 0, 0, 0, 0, ., 0 \ 0, 0, 0, 0, 0, .)

foreach i of varlist $levelvar {
   forvalues j=1/13 {
    gen `i'_`j'PI=l`j'.`i' if PI==1
  }
}
quietly: svar IRD VIX CT ER SMUS SM if PI==1, lags(1/12) small aeq(A1) beq(B1) lutstats

quietly: varlmar, mlag(12)

putexcel set results.xls, sheet("ROBUST") modify

putexcel B3=matrix(r(lm))

quietly: varsoc
putexcel set results.xls, sheet("LAG-LENGTH") modify
putexcel B3=matrix(r(stats))

quietly: svar IRD VIX CT ER SMUS SM if PI==1, exog(CT_2PI VIX_2PI SM_2PI SMUS_2PI) lags(1) small aeq(A1) beq(B1) lutstats

set more off

vargranger
putexcel set results.xls, sheet("GRANGER_PI") modify
putexcel C3=matrix(r(gstats))

varstable, graph
graph save Graph "$data\CHF - PI - Stability.gph", replace
graph export "$data\CHF - PI - Stability.pdf", as(pdf) replace

irf create PI, set(varpi.irf) replace step(20) bs

irf graph sirf, xlabel(0(4)20) irf(PI) yline(0,lcolor(black)) byopts(yrescale) response(CT)
graph save Graph "$data\CHF - PI - SIRF - Response CT.gph", replace
graph export "$data\CHF - PI - SIRF - Response CT.pdf", as(pdf) replace

irf graph sirf, xlabel(0(4)20) irf(PI) yline(0,lcolor(black)) byopts(yrescale) impulse(CT)
graph save Graph "$data\CHF - PI - SIRF - Impulse CT.gph", replace
graph export "$data\CHF - PI - SIRF - Impulse CT.pdf", as(pdf) replace

set more off

irf table sfevd, irf(PI) impulse(IRD VIX CT ER SMUS SM) response(IRD VIX CT ER SMUS SM) noci std

****************************************************
*NI
****************************************************

set more off

matrix A1 = (1, 0, 0, 0, 0, 0 \ ., 1, 0, 0, 0, 0 \ ., ., 1, 0, 0, 0 \ ., ., ., 1, 0, 0 \ ., ., ., ., 1, 0 \ ., ., ., ., ., 1)

matrix B1 = (., 0, 0, 0, 0, 0 \ 0, ., 0, 0, 0, 0 \ 0, 0, ., 0, 0, 0 \ 0, 0, 0, ., 0, 0 \ 0, 0, 0, 0, ., 0 \ 0, 0, 0, 0, 0, .)

foreach i of varlist $levelvar {
   forvalues j=1/13 {
    gen `i'_`j'NI=l`j'.`i' if NI==1
  }
}
quietly: svar IRD VIX CT ER SMUS SM if NI==1, exog(ME2) lags(1/12) small aeq(A1) beq(B1) lutstats

quietly: varlmar, mlag(12)
putexcel set results.xls, sheet("ROBUST") modify
putexcel G3=matrix(r(lm))

quietly: varsoc
putexcel set results.xls, sheet("LAG-LENGTH") modify
putexcel L3=matrix(r(stats))

quietly: svar IRD VIX CT ER SMUS SM if NI==1, exog(ME2 ER_3NI IRD_3NI SM_3NI SMUS_3NI) lags(1/2) small aeq(A1) beq(B1) lutstats

vargranger
putexcel set results.xls, sheet("GRANGER_NI") modify
putexcel C3=matrix(r(gstats))

varstable, graph
graph save Graph "$data\CHF - NI - Stability.gph", replace
graph export "$data\CHF - NI - Stability.pdf", as(pdf) replace

irf create NI, set(varni.irf) replace step(20) bs

irf graph sirf, xlabel(0(4)20) irf(NI) yline(0,lcolor(black)) byopts(yrescale) response(CT)
graph save Graph "$data\CHF - NI - SIRF - Response CT.gph", replace
graph export "$data\CHF - NI - SIRF - Response CT.pdf", as(pdf) replace

irf graph sirf, xlabel(0(4)20) irf(NI) yline(0,lcolor(black)) byopts(yrescale) impulse(CT)
graph save Graph "$data\CHF - NI - SIRF - Impulse CT.gph", replace
graph export "$data\CHF - NI - SIRF - Impulse CT.pdf", as(pdf) replace

irf table sfevd, irf(NI) impulse(IRD VIX CT ER SMUS SM) response(IRD VIX CT ER SMUS SM) noci std

********************************************************************************
*******************************************************************************

save SVAR-CTF.dta, replace

saveold SVAR-CTF_Stata13.dta, replace

save "$data\SVAR-CTF.dta", replace

log close
