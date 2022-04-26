
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

