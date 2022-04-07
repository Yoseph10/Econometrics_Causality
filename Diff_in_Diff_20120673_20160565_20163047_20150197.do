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

global main	"C:\Diplomado QLAB\Econometria\diff_in_diff\problem_set"

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
gen post_china=0
replace post_china=1 if year>=2001


/*----------------------
3) Construct 1 dummy variable called “manuf” where manuf=1 for all the 
observations that start with naics code “3” – which is manufacturing - 
and 0 otherwise.
-----------------------*/

gen manuf=1 if substr(naics,1,1)=="3"
replace manuf=0 if missing(manuf)


/*------------------------
4) Construct the values necessary to generate the difference-in-difference 
estimate (i.e. 2x2 Matrix) of the effect of China entering the WTO on employment (emp). 
Hint: Define clearly what is your treatment group vs control group and the intervention 
time. Interpret the results. 
/*-----------------------*/







