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

log using "$main/PS_diff_in_diff.log"


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


cd "$main"

use BD_Final, clear

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
destring year, replace

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
-----------------------*/

sort manuf post_china
by manuf post_china: sum emp

display ((13366.85-15619.13)-(30579.65-29539.34))

*El resultado es -3292.59. Esto indica que el hecho de que China haya entrado en el World Trade Organization provocó que se pierdan 3293 empleos en promedio.

/*------------------------
5) Estimate a diff-in-diff regression and make sure you get the same diff-in-diff
estimate as in part 4.
-----------------------*/
 
gen treated=post_china*manuf
reg emp post_china manuf treated

*El estimador diff-in-diff coincide con lo hallado en 4.

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
summarize year
* We work with the period: 1998- 2006

** First, generate the dummy per year. Example: 1998
gen year_98=0
replace year_98=1 if year==1998

** Then, construct the interaction between year and the treatment group:
gen t98= year_98*manuf

**Apply for the rest of years: 
gen year_99=0
replace year_99=1 if year==1999
gen t99= year_99*manuf

gen year_00=0
replace year_00=1 if year==2000
gen t00= year_00*manuf

gen year_01=0
replace year_01=1 if year==2001
gen t01= year_01*manuf

gen year_02=0
replace year_02=1 if year==2002
gen t02= year_02*manuf

gen year_03=0
replace year_03=1 if year==2003
gen t03= year_03*manuf

gen year_04=0
replace year_04=1 if year==2004
gen t04= year_04*manuf

gen year_05=0
replace year_05=1 if year==2005
gen t05= year_05*manuf

gen year_06=0
replace year_06=1 if year==2006
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

a. The effect of treatment on the employment is significant since one year before China's entry into the WTO. In 2000, is identified a recude of 0.099% in the Mid-March Employees of US. This is a result that must be analize with evidence of the consecuences of put in the public agenda the status of China in the WTO and the possibility of become a member.
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

*Ejercicio 2:

use "eitc.dta", clear

* 1. [3 points ] Create a table summarizing all the data provided in the data set.

describe

/*La base contiene 13 mil 746 observaciones y 11 variables. Comprende características demográficas de las mujeres (edad, número de hijos, raza), socioeconómicas (años de educación, ganancias anuales, si estuvo empleada el año anterior, ingreso no derivado del trabajo), así como de su hogar (ingreso familiar anual), del Estado en el que reside (proporción de desempleo en el Estado), y el año fiscal. */

summarize

/* Se presenta la tabla que resume todos los datos provistos en el set de datos. Sobre las características demográficas de las mujeres, se encontró que la edad promedio de las mujeres es de 35 años. En tanto, el número de hijos promedio es de 1.19 -el mínimo es ningún hijo; y, el máximo, 9. También se tiene que el 60.1% de mujeres no es blanca. Acerca de las características socioeconómicas, en promedio, las mujeres tienen 8.8 años de educación y su ingreso promedio asciende a 10 mil 432 dólares. El 51% estuvo empleada el año pasado. El ingreso familiar anual promedio es de 15 mil 255 dólares, y el rango de la variable inicia en 0 y concluye en 575 mil 616 dólares. Finalmente, se observa que la tasa de desempleo promedio de los Estados en los que residen las mujeres es del 6.7% (se asume que la unidad de medida es porcentaje) y que la variable del año fiscal comprende desde 1991 hasta 1996.*/

/*----------------------------------------------------------------------------
* 2. [5 points ] Calculate the sample means of all variables for (a) single women with no children, (b) single women with 1 child, and (c) single women with 2+ children
-------------------------------------------------------------------------*/

* (a) single women with no children
summarize if children == 0

* (b) single women with 1 child
summarize if children == 1

* (c) single women with 2+ children
summarize if children >= 2

/* El mayor número de observaciones corresponde al grupo de mujeres sin hijos (5 mil 927), seguido del de dos o más hijos (4 mil 761). 

Sobre sus características demográficas, se encontró que la edad promedio de las mujeres sin hijos (38.5) supera en 5 y 6 años la de las mujeres con uno (33.8) y con dos o más hijos (32), respectivamente. Acerca del componente étnico racial, en el primer grupo el 51.6% de las mujeres es no blanca; en el segundo, la cifra asciende a 59.6%, mientras que en el tercero, a 70.9%. 

En cuanto a las características socioeconómicas, los años de educación promedio en los tres grupos oscila entre los 8 y 9. El ingreso promedio es superior en el grupo sin hijos (13 mil 760 dólares); en el de un hijo cae a 9 mil 928; y, en el de dos o más, a 6 mil 613 (la mitad respecto al primer monto). En el primer grupo, la proporción de mujeres que trabajó el año pasado fue del 57.4%, cerca de cuatro puntos atrás, se ubicó el segundo grupo (53.8%). En el tercero la proporción caía a 42.1%.

El ingreso familiar anual promedio del grupo sin hijos también es el mayor (18 mil 559 dólares) y el menor es el del dos o más hijos (11 mil 985). Las diferencias en el promedio de ingreso no derivado del trabajo son mínimas entre grupos. Finalmente, se observa que la tasa de desempleo promedio de los Estados es bastante similar en los tres grupos.*/

/*----------------------------------------------------------------------------
* 3. [5 points ] Construct a variable for the “treatment” called anykids (indicator for 1 or more kids) and a variable for time being after the expansion (called post93—should be 1 for 1994 and later).
-------------------------------------------------------------------------*/

* Generar variable anykids
gen anykids = 0

* Si tiene uno o más hijos, consignar 1 en la variable anykids
replace anykids = 1 if children >= 1

* Generar variable post93
gen post93 = 0

* Si el año fiscal es igual o mayor a 1994, consignar 1 en la variable post93
replace post93 = 1 if year >= 1994

/*----------------------------------------------------------------------------
* 4. [10 points ] Using the “interaction term” diff-in-diff specification, run a regression to estimate the difference-in-differences estimate of the effect of the EITC program on earnings. Use all women with children as the treatment group.
-------------------------------------------------------------------------*/

* Creación de variable de interacción
gen treated = anykids * post93

* Log transformation a la variable de ingresos
gen earnLog = log(earn)

* Regresión
reg earnLog post93 anykids treated

/* La tabla da cuenta de los resultados de la regresión. En ese sentido, se encuentra que es significativo el término de interacción introducido. De ese modo, es posible afirmar que el programa EITC (la intervención) contribuyó en un incremento del 16% de las ganancias anuales de las mujeres con hijos respecto al grupo sin hijos.*/


/*----------------------------------------------------------------------------
* 5. [7 points ] Repeat (iv), but now include state and year fixed effects [Hint: state fixed effects, are included when we include a dummy variable for each state]. Do you get similar estimated treatment effects compared to (iv)? -----------------------------------------------------------------------*/

*Instalamos la libreria y función necesaria
*ssc install reghdfe
*ssc install ftools

*Realizamos la regresión con efectos fijos de años y estados
reghdfe earnLog post93 anykids treated, absorb(year state)

/*Si agregamos las variables que hacen referencia a los años y a cada Estado como variables de control, y replicamos el ejercicio anterior, nuestro término de interaccion sigue siendo significativo (p-value = 0), sin embargo cambia el valor del coeficiente que lo acompaña. Pasando de 0.1608 a 0.1423, esto quiere decir que el efecto del programa EITC en las ganancias anuales de las mujeres con hijos, respecto al grupo sin hijos, disminuye en un 2% al tomarse en cuenta condiciones de cada Estado y la variabilidad de la expansión del programa a lo largo del tiempo, por lo que podemos concluir que ahora el progama contribuye en un incremento del 14% de las ganancias previamente mencionadas.*/


/*----------------------------------------------------------------------------
* 6. [7 points] Using the specification from (v), re-estimate this model including urate nonwhite age ed unearn, as well as state and year FEs as controls. Do you get similar estimated treatment effects compared to (v)? 
-------------------------------------------------------------------------*/

*Agregamos las variables de control solicitadas y corremos la regresión nuevamente
reghdfe earnLog post93 anykids treated urate nonwhite age ///
	ed unearn, absorb(year state)

/*Si reestimamos el modelo agregando las variables de control solicitadas, los resultados obtenidos para la variable tratamiento siguen siendo significativos (p-value = 0.007), y el coeficiente que lo acompaña aumenta de 0.1423 a 0.1538, con lo que podemos decir que el programa EITC contribuye al incremento de las ganancias anuales de as mujeres con hijos, frente a las que no los tienen, en aproximadamente un 15%, a pesar de controlar los resultados por variables sociodemográficas como la edad, raza o si la mujer tiene "unearned incomes", que cabe resaltar que son variables que también han salido significativas en los resultados obtenidos.*/
	
	
/*----------------------------------------------------------------------------
* 7. [7 points ] Estimate a version of your model that allows the treatment effect to vary by those with 1 or 2+ children. Include all other variables as in (vi). Does the intervention seem to be more effective for one of these groups over the other? Why might this be the case in the real world? 
-------------------------------------------------------------------------*/

*Reemplazamos los valores de la variable anykids, para tomar en cuenta los grupos con al menos 2 hijos
replace anykids=2 if children>=2

*Obtenemos la regresión pero ahora usando  la variable de anykids por categorias y las variables de control usadas en el ejercicio anterior:
reghdfe earnLog post93##i.anykids urate nonwhite age ///
	ed unearn, absorb(year state)
	
/*En base a lo obtenido podemos decir que la interacción entre la variable post93 y las mujeres que tienen al menos 2 hijos no es significativa, a diferencia de la interacción con las que tienen sólo 1, para las cuales el efecto crece considerablemente y nos permite ver que el programa EITC genera un incremento del 24.66% aproximadamente sobre los ingresos anuales de las mujeres con un hijo. 
Podríamos decir que existe evidencia que nos permite suponer que al incluir a las mujeres con 2 o más hijos en el mismo grupo que las que tienen solo uno, estamos diluyendo el efecto real del programa. 
Estos resultados son explicables en el mundo real ya que las mujeres solteras con hijos tienen ingresos anuales considerablemente menores que las mujeres solteras que no los tienen y esta es diferencia es aún más notoria cuando la mujer tiene 2 o más, es por eso que cualquier impacto del programa será mas relevante para este grupo en específico, como hemos evidenciado en la regresión.*/


/*----------------------------------------------------------------------------
* 8. [6 points ] Estimate a “placebo” treatment model as follows: Take data from only the pre-reform period (up to and including 1993). Drop the rest, or restrict your model to run only if year <= 1993. Estimate the effect for all affected women together, just as in (vi). 
Introduce a placebo policy that begins in 1992 (so 1992 and 1993 are both “treated” with this fake policy). What do you find? Are your results “reassuring”? -------------------------------------------------------------------------*/

*Filtramos la información hasta el año 1993
keep if year<=1993

*Agrupamos a las mujeres con hijos vs las que no los tienen, como en el ejercicio 6
replace anykids=1 if children>=1

*Generamos la variable que separará los años afectados por la política placebo
gen post92=0
replace post92=1 if year>=1992

*Generamos la variable de interacción con las nuevas variables creadas
gen treated2 = anykids*post92

*Obtenemos la nueva regresión con las especificaciones requeridas
reghdfe earnLog post92 anykids treated2 urate nonwhite age ///
	ed unearn, absorb(year state)

/*Lo primero resaltante es que la variable de interacción en este caso no es significativa (p-value = 0.719), mientras que las variables de control que antes eran signicativas, lo siguen siendo. Lo que esto nos indica es que hasta el año 1993 no hay un cambio relevante entre los ingresos anuales de las mujeres con hijos. 
Esto nos reasegura lo hallado en las partes previas, dado a que el efecto de la variable interacción no depende de las variables de control, si no, dependerá la entrada del progama de EITC, es decir que este si tiene un efecto real en la contribución del aumento de los ingresos anuales de las mujeres solteras con hijos, respecto a las que no los tienen. 
 */

log close