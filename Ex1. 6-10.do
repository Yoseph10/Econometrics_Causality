/********************
Problem set: Diff in Diff
***

Authors
---------------------
Luciana Figueroa Valdivia (20120673),
Chiara Zamora Mendoza (20160565),
Yoseph Ayala Valencia (20163047),
Claudia Villena Tagle (20150197)
*********************/


/*----------------------
Initial script configuration
-----------------------*/

cls
clear all

*global main "C:\Users\Claudia\Documents\GitHub\Econometrics_Causality"

use "C:\Users\Claudia\Documents\GitHub\Econometrics_Causality\BD_Final.dta"

*log using "${path}/PS_diff_in_diff.log"


/*----------------------
Exercise 1 
-----------------------*/

	local years "98 99 00 01 02 03 04 05 06"
	foreach x of local years {
		
		* 1998-1999
		if `x'>=90 {
			
			copy "https://www2.census.gov/programs-surveys/cbp/datasets/19`x'//cbp`x'st.zip" "${main}/cbp`x'st.zip", replace
			unzipfile "${main}/cbp`x'st.zip", replace
			
			import delimited "cbp`x'st.txt", encoding("utf-8") clear
			gen year = "19`x'"
			keep if substr(naics,4,3)=="///"
			keep fipstate year naics emp qp1 ap est
			
			tempfile bd_`x'
			save "`bd_`x''", replace
		}
		
		* 2000-2006
		else if `x'<=6 {
			
			copy "https://www2.census.gov/programs-surveys/cbp/datasets/20`x'//cbp`x'st.zip" "${main}/cbp`x'st.zip", replace
			unzipfile "${main}/cbp`x'st.zip", replace
			
			import delimited "cbp`x'st.txt", encoding("utf-8") clear
			gen year = "20`x'"
			keep if substr(naics,4,3)=="///"
			keep fipstate year naics emp qp1 ap est
			
			tempfile bd_`x'
			save "`bd_`x''", replace		
		}
	}

	** Append Data
	use `bd_98', clear
	local y_aux "99 00 01 02 03 04 05 06"
	foreach z of local y_aux {
		append using `bd_`z''
	}
	compress
	saveold "${main}/exercise_1_data.dta", replace

	
/*----------------------
1) What is the level of observation?
-----------------------*/
	
/* La unidad de análisis son las industrias. En específico, cada observación 
refleja un tipo de subsector dentro de un determinada industria.
*/


/*----------------------
2) Construct 1 dummy variable called “post_china” where post_china=1 for 
year>=2001 and 0 otherwise.
-----------------------*/ 

*Creating treatment dummy
describe post_china
describe year //is a string
gen post_china=0
*encode year, gen(year1)
replace post_china=1 if year_n >= 2001


/*----------------------
3) Construct 1 dummy variable called “manuf” where manuf=1 for all the 
observations that start with naics code “3” – which is manufacturing - 
and 0 otherwise.
-----------------------*/

gen manuf=1 if substr(naics,1,1)=="3"
replace manuf=0 if missing(manuf)

/*---------------------------------------------------------------*/
/* 6.- Estimate a diff-in-diff regression for the effect of China entering the WTO in 2001 on the number of establishment (est), an average pay (qp1/emp). Interpret the results. */
/*---------------------------------------------------------------*/

**From 5:
gen treated=post_china*manuf

** Regresion considering the number of establishment (est)
eststo reg_6: reg est post_china manuf treated

/*Interpretation: We identified that the effect of China's entry into the WTO in 2001 on the number of establishments generate a a decrease of 52 establishments. However, we cannot say that this effect is significantly different from 0 because the p-value is high: 0.621*/

** Regresion by average pay. First, we created average pay

gen average_pay= qp1/emp
*** qp1: Total First Quarter Payroll ($1,000)
*** emp: Total Mid-March Employees
eststo reg_2: reg average_pay post_china manuf treated

/*Interpretation: Is observed a decrease of 0.21 thousand dollars in the average pay por manufacture workers as a result of the influence of China's entry into the WTO in 2001. However, as in the previous exercise, this decrease is not significant as the p value is 0.111. Therefore, an influence between treatment and average payment cannot be proven.  */


/*---------------------------------------------------------------*/
/* 7.- Estimate same regression as in (5) but now take logs of the dependent variable 
(i,e, log(emp)). Interpret your results. Is it necessary to take logs?  */
/*---------------------------------------------------------------*/

** create log(emp):
gen log_emp = log(emp)

** Estimate the regression:
eststo reg_7: reg log_emp post_china manuf treated

/*Interpretación: We identified that the influence of the China's entry into the WTO on employment is negative as it generated a reduce of 16.7% in the total Mid-March Employees of US. This influence is significantly different of 0 as de p value is 0.000. 


Is it necessary to use emp log? It is important to note that using log allows us to narrow the range of the employment variable to a smaller amount, reducing the sensitivity of the estimates to outliers that may be present in the sample. To find out if we have outliers, we can plot the histogram of emp:*/

histogram emp
summarize emp

/*We observe that the data range from 0 to 1 390 439 and that the data are skewed to the right. Applying the logarithm, we see that an improvement in the distribution of data it normalized.*/

histogram log_emp

/*The importance of working with logarithms, therefore, is to avoid
that the standard errors of the variables increase and non-significant results are obtained. */


/*---------------------------------------------------------------*/
/*Now you will proceed to run an event study. You will analyze the trajectory of the effect of 
the China shock on different outcomes, employment, number of establishments, and average 
pay.*/ 
/*---------------------------------------------------------------*/


/*---------------------------------------------------------------*/
/* 8.- Generate one dummy per year. Construct the interaction between each year dummies and your treatment group (manuf). You should have 9 interaction terms. */
/*---------------------------------------------------------------*/

**About period of time: 
summarize year_n
* We work with the period: 1998- 2006

** First, generate the dummy per year. Example: 1998
gen year_98=0
replace year_98=1 if year_n==1998

** Then, construct the interaction between year and the treatment group:
gen t98= year_98*manuf

**Apply for the rest of years: 
gen year_99=0
replace year_99=1 if year_n==1999
gen t99= year_99*manuf

gen year_00=0
replace year_00=1 if year_n==2000
gen t00= year_00*manuf

gen year_01=0
replace year_01=1 if year_n==2001
gen t01= year_01*manuf

gen year_02=0
replace year_02=1 if year_n==2002
gen t02= year_02*manuf

gen year_03=0
replace year_03=1 if year_n==2003
gen t03= year_03*manuf

gen year_04=0
replace year_04=1 if year_n==2004
gen t04= year_04*manuf

gen year_05=0
replace year_05=1 if year_n==2005
gen t05= year_05*manuf

gen year_06=0
replace year_06=1 if year_n==2006
gen t06= year_06*manuf


/*---------------------------------------------------------------*/
/* 9.- Estimate an event study, i.e. run the following specification: log(emp) vs year
dummies, manuf*year dummies (omit the interaction between manuf  * year 1998) and control for NAICS-3 digit dummies and state dummies. Hint: when controlling for naics3 and state dummies, you need to use the command “reghdfe y x, absorb(naics3 state).” 
This will include naics3 dummies and state dummies in your regression. Interpret your results.

Should you expect to see any effect for the interaction term manuf*year 1999 or manuf * year 2000? Did the China shock have a significant effect on employment? Was it a shortrun or long-run effect?*/
/*---------------------------------------------------------------*/
ssc install ftools
ssc install reghdfe

reghdfe log_emp year_98 year_99 year_00 year_01 year_02 year_03 year_04 year_05 year_06 t99 t00 t01 t02 t03 t04 t05 t06, absorb(naics fipstate)

/*Of the results, is possible identified: 

a. The effect of treatment on the employment is significant since one year before China's entry into the WTO. In 2000, is identified a recude of 0.09% in the Mid-March Employees of US. This is a result that must be analize with evidence of the consecuences of put in the public agenda the status of China in the WTO and the possibility of become a member.
b. This effect has constant growth since 2000 to 2006 with negative effect to the variable studied. In fact, for 2006, is identified a reduce of 41.8% of the Mid-March Employees of US.    */
	


/*---------------------------------------------------------------*/
/* 10.- Estimate a similar event study on the log(est) and average pay. Interpret your results. */
/*---------------------------------------------------------------*/

** Create log(est)
gen log_lest = log(est)

reghdfe log_lest year_98 year_99 year_00 year_01 year_02 year_03 year_04 year_05 year_06 t99 t00 t01 t02 t03 t04 t05 t06, absorb(naics fipstate)

/*Of the results, is possible identified: 

a. The effect of treatment on the number of manufacturing establisments is significant since 2002, one year after China's entry into the WTO. In 2002, is identified a recude of 1% in the total number of establishments in US. 
b. This effect has constantly growth until 2006, when is identified a reduce of 16% of the  number of establishments in US.*/


reghdfe average_pay year_98 year_99 year_00 year_01 year_02 year_03 year_04 year_05 year_06 t99 t00 t01 t02 t03 t04 t05 t06, absorb(naics fipstate)

/*Of the results, is possible identified: 

a. The effect of treatment on the averaye pay of employers in US is not significantly different to 0 in all the period analize in this report. 
b. Considering the effect of China's entry into the WTO to the number of establishments and the Mid-March Employees of US, it shows that althought is a significant reduce of establishments and number of jobs in the sector of manufacturing in the US, since 2001- 2006, the treatment doesn´t affect the average pay of employers.    */
