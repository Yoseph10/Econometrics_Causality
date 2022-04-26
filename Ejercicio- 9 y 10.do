
*Todos los resultados se interpretaron en el pdf entregado adjunto a este do-file.

*Limpiamos y establecemos el directorio de trabajo
clear all
cls
set more off 
cd "C:\Users\soyma\Documents\GitHub\Econometrics_Causality"

use "card.dta", clear

/*9.-¿Cuándo las estimaciones por VI y 2SLS son equivalentes? Analice si son equivalentes ambos
métodos según la muestra en estudio.
.*/

*Regresión por VI
ivreg lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4)
	
*Regresión por 2sls
ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4)

* Ambas estimaciones son equivalentes cuando la cantidad de variables endógenas es la misma que el número de instrumentos. Dicho de otro modo,
* el modelo debe estar exactamente identificado. Específicamente, en el modelo del estudio, hay una variable endógena y un instrumento. En 
* consecuencia, es posible afirmar que ambos métodos son equivalentes, según la muestra.

	
/*10.-Sabemos que cuando hay más instrumentos que variables endógenas tenemos sobreidentificación,  pues bien, considerando el caso del inciso 8, en el que se tienen dos instrumentos, realice el test de Sargan (1959) para restricciones de sobre-identificación.
.*/
*Test de sobre-identificación
ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4 nearc2)
estat overid

* De acuerdo a los resultados, es posible afirmar que los instrumentos son exógenos en la medida que no se rechaza la hipótesis nula que que sostiene su exogeneidad, y que, por tanto, los instrumentos son válidos. 
