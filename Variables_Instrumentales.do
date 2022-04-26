
*Llamamos al dataset a trabajar
clear all
use "C:\Users\USER\Downloads\card.dta", clear
br

/*----------------------------------------------------------------------------
4.-Estime una ecuación para la variable educ de forma reducida, respecto a todas las variables explicatorias usadas en la parte b, incluyendo además la variable nearc4. ¿Qué podría decir respecto de la correlación parcial existente entre educ y nearc4?
----------------------------------------------------------------------------*/

*Obtenemos la regresión para la variable indicada
reg educ nearc4 exper expersq black south smsa reg661 reg662 ///
	reg663 reg664 reg665 reg666 reg667 reg668 smsa66

/*Si ahora incluimos la variable nearc4, que hace referencia a si la persona encuestada vive ceca a una universidad (four-year college), además de todas las revisadas en el ejercicio previo, vemos que esta resulta significativa (p-value = 0) y que tiene un coeficiente de 0.3198989, y se puede interpretar indicando que se espera que alguien que vive cerca de una universidad con carreras de 4 años incremente su tiempo de estudios en 0.32, lo que se aproxima a 4 meses.*/

/*----------------------------------------------------------------------------
5.-Estime lwage por Variables Instrumentales, usando nearc4 como un instrumento para la variable educ. Comente sus resultados y compárelos con los obtenidos en 2.
----------------------------------------------------------------------------*/

*Estimamos lwage con lo indicado
ivreg lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4)  
	
/* Usando la variable de nearc4 nuevamente, pero ahora haciendo la estimación por variables instrumentales obtenemos los resultados del cuadro anterior. En este podemos ver que el coeficiente de educación, si bien es significativo en ambos casos, es más grande que el obtenido en el ejercicio 2, indicándonos así que un año mas de educación conlleva a un incremento esperado del 13% de los salarios por hora, en centavos, mientras que con el ejercicio anterior se mostraba un incremento del 7%. Referente al resto de variables, hay una diferencia no tan fuerte en los resultados encontrados previamente y las significancias se mantienen.*/

/*----------------------------------------------------------------------------
6.- Compare el intervalo de confianza a un 95 % del retorno de la educación del inciso 5 con el obtenido en 2.
----------------------------------------------------------------------------*/

/*7.En presencia de Instrumentos Debiles, el estimador por variables instrumentales esta sesgado en la misma direccion que el estimador por OLS e incluso puede no ser consistente. Para saber si estamos o no ante la presencia de Intrumentos debiles, se pide que testee esto usando el estadıstico de Cragg y Donald (1993) y las tablas de Stock y Yogo (2005) con respecto a la medida del test de Wald . (Hint: Utilice ivreg2 en Stata. Realiza el test automaticamente. */


ivreg2 lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66  (educ = nearc4), first 

/*En este ejercicios evaluamos si la variable nearc 4 (vivir cerca de una universidad con 4 años de acreditación en 1966) es un instrumento débil, es decir, si los instrumentos no están suficientemente correlacionados con la variable endógena. Para evitar la inconsistencia o la posibilidad de tener intervalos de confianza con coverage probabilities incorrectas, procedemos a evaluar empleando el estadístico de Cragg y Donald (1993). Se observa que el manor valor propio de la matriz de concentración es de 13.2558. Al respecto, se sabe que mientras mayor es el tamaño del Gmin más fuerte será el instrumento. No obstante, un límite de este estadístico es que los autores no establecieron un valor crítico. Además, para este caso en específico, se observa que no tenemos sobreidentificación, es decir, que no tenemos más intrumentos que regresores endógenos, de hecho, se observa que los coeficientes están exactamente identificados con un regresor endógeno y un instrumento.
 */

*Tablas de Stock y Yogo (2005): 
ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66  (educ = nearc4), first 
estat firststage

/*Con este segundo estadístico, si podremos identificar valores críticos. Se observa que a nivel teórico se tiene una significancia del 5% pero la significancia empírica será del 10%. Se podrá tolerar un 15% de significancia empírica porque el menor valor propio de la matriz de concentración se encuentra entre los valores críticos del 8.96 (15%) y 16.38 (10%). De esta forma, se concluye que estamos ante un nivel de inferencia aceptable de acuerdo a lo revisado por Stock y Yogo (2005), por lo que se rechaza la hipótesis de que nearc 4 sea un instrumento débil.*/

/*8. En este ejercicio, incluimos la variable nearc2 (vivir cerca de una universidad con 2 años de acreditación en 1966) además de nearc 4 (vivir cerca de una universidad con 4 años de acreditación en 1966) como instrumentos para educación*/

/*Primero analizamos cual de las dos variables esta mas fuertemente relacionada con educ.*/

reg educ nearc2 nearc4 exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66

/*Se encuentra que el vivir cerca de una Universidad con 2 años de acreditación no es estadisticamente significativa para evaluar los años de escolaridad, a diferencia de la variable que evalua vivir cerca de una Universidad con 4 años de acreditación. Así, se evidencia que la variable nerac 4 incrementa los años de educación en 0.3205. Vemos un pequeño incremento en el coeficiente con respecto a los resultados evaluados en el ejercicio 4, cuando se estimó que nearc4 es estadísticamente significativa para explicar la educación generando un incremento en los años de educación de 0.3198, sin considerar el efecto de nearc2.*/
	
/*Ahora encontramos el estimador de VI que usa nearc2 y nearc4 como instrumento para educ.*/

ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66  (educ = nearc4 nearc2), first  

/* En este caso será fundamental establecer una comparación con los resultados del ejercicio 5 donde solo empleamos un instrumento. Así, se encuentra que estimador de coeficiente de educación mucho más alto: aumentó de 0.13 a 0. 15. Esto implica que un año más de educación genera un aumento de salarios en un 15% por hora, permitiendonos pensar que en regresiones anteriores (ejercicio 2), el OLS subestimó el efecto de los años de educación sobre el salario.  El error estandar, por su parte, se redujo (de un 0.054 a un 0.052) al igual que el p value que alcanza un 0.003 de 0.017.También, al emplear dos instrumentos se observa una disminución del p value. Ahora bien, parece ser que si es necesario trabajar con variables instrumentales y que si se presentó endogeneidad al trabajar con la variable educ para medir la correlación entre años de educación y salario.*/

/*No obstante, antes de confirmar la idoneidad del instrumento, será importante conocer si estamos ante instrumentos débiles porque a veces la solución "puede ser peor que la enfermedad"*/

ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66  (educ = nearc4 nearc2), first 
estat firststage

/*De esta forma, se observa que el menor valor propio de la matriz de concentración es de 7.89, un valor reducido considerando los resultados de Rothenberg(1984) de 10 y los valores críticos de Stock y Yogo (2005). En primer lugar, observamos que al tener 1 regresor endógeno y 2 instrumentos excluidos no estamos ante un caso de sobreidentificación.*/ 

/*A su vez los resultados permiten identificar los valores críticos entre 7.25 (25%) y 8.75 (20%). Así, se observa que al tener un test con significancia teórica de 5% y el gmin menor a 8.75, se podrá tener como máximo un 20% de significancia. Ahora bien, con estos resultados no podemos afirmar que se pruebe la hipótesis nula de un instrumento debil pero si podemos afirmar que al emplear estos instrumentos (nearc 2 y 4) obtenemos un nivel de significancia empírico mucho mayor al que obtendríamos si solo empleamos una variable instrumental (nearc4). Por tanto, se recomenda emplear el modelo desarrollado en el ejercicio 7. */

/*----------------------------------------------------------------------------
9.-¿Cuándo las estimaciones por VI y 2SLS son equivalentes? Analice si son equivalentes ambos métodos según la muestra en estudio.
----------------------------------------------------------------------------*/

*Regresión por VI
ivreg lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4)
	
*Regresión por 2sls
ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4)
	
/*----------------------------------------------------------------------------
10.-Sabemos que cuando hay más instrumentos que variables endógenas tenemos sobreidentificación,  pues bien, considerando el caso del inciso 8, en el que se tienen dos instrumentos, realice el test de Sargan (1959) para restricciones de sobre-identificación.
----------------------------------------------------------------------------*/

*Test de sobre-identificación
ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4 nearc2)
estat overid

/**/

