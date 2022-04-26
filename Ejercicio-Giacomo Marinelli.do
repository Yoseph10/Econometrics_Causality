*-----------------------------------------------------
*---------Ejercicios Calificados---------------------------------
*-----------------------------------------------------
*--Alumno: Giacomo Marinelli Tagliavento
*--Código: 20180462
*-----------------------------------------------------

*Todos los resultados se interpretaron en el pdf entregado adjunto a este do-file.

*Limpiamos y establecemos el directorio de trabajo
clear all
cls
set more off 
cd "C:\Users\Advance\Documents\Giacomo\2022-1\QLAB\Variables_instrumentales\Ejercicio"

/*1. Realice una descripción de las características de los individuos de la muestra.*/
use "card.dta", clear

*Primero verificamos las variables que tenemos
describe

*Observamos los promedios de toda la muestra de las variables relevantes
summarize id nearc2 nearc4 educ age fatheduc motheduc weight momdad14 sinmom14 step14 ///
	south66 black smsa south smsa66 wage enroll kww iq married libcrd14 exper lwage expersq


/*Comparando promedios entre las personas que vivieron en cualquier año en las regiones Sur y las personas que vivieron en cualquier año en áreas metropolitanas*/

*Estadísticos de las personas que vivieron en el Sur en cualquier año
summarize id nearc2 nearc4 educ age fatheduc motheduc weight momdad14 sinmom14 step14 ///
	south66 black smsa south smsa66 wage enroll kww iq married libcrd14 ///
	exper lwage expersq if south==1 | south66==1

*Estadísticas de las personas que vivieron en SMSA en cualquier año
summarize id nearc2 nearc4 educ age fatheduc motheduc weight momdad14 sinmom14 step14 ///
	south66 black smsa south smsa66 wage enroll kww iq married libcrd14 ///
	exper lwage expersq if smsa==1 | smsa66==1

/*Comparando los promedios entre las personas que vivieron cerca a solo universidades acreditadas de 4 años y aquellas que vivieron solo cerca a unas de 2 años, en el año 1966*/

*Estadisticos de las personas que vivieron cerca a universidades acreditadas de 2 años
summarize id nearc2 nearc4 educ age fatheduc motheduc weight momdad14 sinmom14 step14 ///
	south66 black smsa south smsa66 wage enroll kww iq married libcrd14 ///
	exper lwage expersq if nearc2==1 & nearc4==0

*Estadisticos de las personas que vivieron cerca a universidades acreditadas de 4 años
summarize id nearc2 nearc4 educ age fatheduc motheduc weight momdad14 sinmom14 step14 ///
	south66 black smsa south smsa66 wage enroll kww iq married libcrd14 ///
	exper lwage expersq if nearc4==1 & nearc2==0


/*2.-Regresione mediante OLS, la variable lwage, respecto educ, exper, exper2, black, south, smsa,
reg661-reg668, y smsa66. Comente los resultados obtenidos, y compárelos con la Tabla 2, Columna
2, del paper de Card (1993)*/

*Realizamos la regresión OLS
reg lwage educ exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66

	
/*4.-Estime una ecuación para la variable educ de forma reducida, respecto a todas las variables explicatorias usadas en la parte b, incluyendo además la variable nearc4.*/

*Estimamos la regresión
reg educ nearc4 exper expersq black south smsa reg661 reg662 ///
	reg663 reg664 reg665 reg666 reg667 reg668 smsa66

/*5.-Estime lwage por Variables Instrumentales, usando nearc4 como un instrumento para la variable educ*/

*Estimamos la regresión
ivreg lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4)  

/*7.-Para saber si estamos o no ante la presencia de Intrumentos débiles, se le pide que testee esto usando el estadístico de Cragg y Donald (1993) y las tablas de Stock y Yogo (2005) con respecto a la medida del test de Wald */

*Un primer método
ivreg2 lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4), first 

*Un segundo método que incluye los valores críticos para evaluar la significancia
ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4), first 
estat firststage


/*8.-Use nearc2 con nearc4 como instrumentos para educ. Primero estime la forma reducida para educ, y analice cuál de las dos variables está más fuertemente relacionada con educ. Después encuentre el estimador de VI que usa nearc2 y nearc4 como instrumento para educ.*/

*Regresión de la forma reducida
reg educ nearc2 nearc4 exper expersq black south smsa reg661 reg662 ///
	reg663 reg664 reg665 reg666 reg667 reg668 smsa66

*Regresión por VI
ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4 nearc2), first  

*Evaluar instrumentos débiles
ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4 nearc2), first 
estat firststage

/*9.-¿Cuándo las estimaciones por VI y 2SLS son equivalentes? Analice si son equivalentes ambos
métodos según la muestra en estudio.
.*/

*Regresión por VI
ivreg lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4)
	
*Regresión por 2sls
ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4)

/*10.-Sabemos que cuando hay más instrumentos que variables endógenas tenemos sobreidentificación,  pues bien, considerando el caso del inciso 8, en el que se tienen dos instrumentos, realice el test de Sargan (1959) para restricciones de sobre-identificación.
.*/
*Test de sobre-identificación
ivregress 2sls lwage exper expersq black south smsa reg661 reg662 reg663 reg664 reg665 ///
	reg666 reg667 reg668 smsa66  (educ = nearc4 nearc2)
estat overid