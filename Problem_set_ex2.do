use "C:\Users\soyma\Downloads\eitc.dta"

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

/* La tabla da cuenta de los resultados de la regresión. En ese sentido, se encuentra que es significativo el término de interacción introducido. De ese modo, es posible afirmar que el programa EITC contribuyó en un incremento del 16% de las ganancias anuales de las mujeres con hijos.*/

