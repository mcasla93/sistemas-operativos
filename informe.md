# Informe Primer TP Sistemas operativos 75:08


# Punto 2. Documentación

## Hipótesis y Aclaraciones

### Hipotesis del punto 3

Para el script de instalación (instalarTP.sh) se tienen las siguientes hipótesis:

#### Reparacion:
El script tiene en cuenta los casos de que los archivos no se encuentren dentro de los directorios (e.g las tablas maestras no estan en el DIRMAE) por lo que se hace una copia de la carpeta "original" a la carpeta a reparar y tambien el caso de que el directorio DIRMAE ni siquiera exista. En este ultimo caso primero se crea el directorio ,utilizando el valor del archivo **instalarTP.conf** asignado al identificador del directorio faltante y luego se procede como antes a copiar del directorio **original** al directorio faltante.

#### logs:
Para los mensajes del tipo WAR lo interpretamos como aquellos errores que son predecibles y que estan dentro del alcance de resolucion del script, es decir por ejemplo el copiar archivos faltantes.

Los mensajes tipo ERR quedan reservado a errores mas graves que pueden llevar al tener que abortar la ejecucion dado que no se puede continuar con la instalación/reparación porque ha ocurrido una falla en el proceso que compromete la correcta instalación o reparación del sistema.

## Descripción de Problemas

### Descripción de Problemas - Punto 3

Una de las dificultades encontradas es el correcto registro de los mensajes de la terminal con respecto a aquellos que son de la stdout y los de la stderr.
Para los mensajes informativos se utilza una funcion **log** que se le pasa como parametro el mensaje, pero para el caso de comandos que se utilizan con la opcion **-verbose** se utiliza la funcion **logPipe** que no toma por parametro sino por redireccionamiento y luego el **logError** que funciona de la misma manera pero para los mensajes de la stderr.
El problema es qe no se encontro una manera de poder separar los mensajes de stderr de los de stdout de manera de procesarlos por separado por las funciones de **logPipe** y **logError**
e.g.




## Estructura de directorios - parte 1

#### Estructura de Directorios despues de la descarga

A continuación se muestra como quedan los directorios una vez descargado el repositorio y luego en el caso de una instalación 

Directorio padre: Grupo4
* Grupo4
	* s07508
	* original
		* or_bin
			* ambienteInicializado.sh
			* arrancarProceso.sh
			* frenarProceso.sh
			* estaEnEjecucion.sh
			* iniciarAmbiente.sh
			* pprincipal.sh
		* or_master
			* comercios.txt
			* tarjetashomologadas.txt
	* catedra
	* propios
	* testeos

#### Estructura de directorios despues de la instalación

Suponiendo el caso de que se usan los nombres de directorio dados por defecto

* Grupo4
	* s07508
		* instalarTP.sh
		* instalarTP.log
		* instalarTP.conf	
	* original
		* or_bin	
			* ambienteInicializado.sh
			* arrancarProceso.sh
			* frenarProceso.sh
			* estaEnEjecucion.sh
			* iniciarAmbiente.sh
			* pprincipal.sh
		* or_master
			* comercios.txt
			* tarjetashomologadas.txt	
	* catedra
	* propios
	* testeos
	* bin
	* master
	* input
	* rechazos
	* lotes
	* output






**ESTO VA EN EL README**
## Guia de instalación (README.md)

### Guia para la instalación del sistema

Primero debe realizar los pasos de la "Guía para la descarga del sistema" para poder continuar

Una vez descargado y descomprimido el .zip con la carpeta Grupo4 en uno de sus directorios.

1. Abra una terminal y navegue hasta el directorio Grupo4
	
2. Ingrese al directorio Grupo4
	`$ cd Grupo4`

3. Ejecute el script de instalacion instalar.TP.sh que se encuentra dentro del directorio so7508 (Grupo4/so7508)

Puede ejecutarlo directamente desde el directorio Grupo4, escribiendo en la terminal que tiene abierta.
	`$ ./so7508/instalarTP.sh`

O puede primero moverse al directorio so7508 y luego ejecutar el script
	`$ cd so7508`
	`$Tipee ./instalarTP.sh`

4. Siga las instrucciones que apareceran en la terminal para proceder con la instalación del sistema.

5. Como ultimo paso aparece en la terminal un listado de los directorios a ser creados y aqui podra elegir terminar con la instalacion o voler atras para elegir nuevamente.

6. Una vez finalizada la instalación puede comprobar la correcta instalación al ver que se ha creado (entre otros archivos) uno llamado **instalarTP.conf** en este encontrara 8 registros con identificadores (DIRBIN, DIRMAE, etc) que indican la dirección de cada carpeta qeu se ha creado y un noveno registro con información adicional sobre la instalación.

Tambien puede volver a ejecutar el script **instaladorTP.sh** que hara una verificación de los archivos e indicara si el sistema se encuentra instalador correctamente (ver sección "Guia para la reparación del sistema")




### Guia para la reparación del sistema

En el caso de detectarse un mal funcionamiento del sistema una vez instalado, el instalador tiene la capacidad de detectar archivos faltantes y tratar de repararlos.

1. Abra una terminal y navegue al directorio Grupo4 (paso 1 y 2 de la "Guia para la instalación del sistema")
	`$ cd Grupo4`

2. Dentro del directorio Grupo4 ejecutar el mismo script utilizado para la instalación **instalarTP.sh**
	`$ ./so7508/instalarTP.sh`

	o bien puede hacer

	`$ cd so7508`
	`$ ./instalarTP.sh`

El script revisara los directorios de la instalación y archivos en busca de errores e informara por la pantalla del terminal el estado de los mismo.
En el caso de que el instalador encuentre un archivo o directorio se le informará por pantalla.

3. Como en el paso 5 de la "Guia para la instalación del sistema" se mostrara el listado con la estructura del directorios del sistema y se le solicitara confirmar la reparación.
En caso de confirmar el instalador procedera a recuperar los archivos y directorios faltantes, al finalizar indicara si la reparación fue un exito.

En el caso de que el instalador indique que la reparación NO fue exitos, seguir con la sección ("Guia para la reparación manual del sistema")

### Guia para la reparación manual del sistema

Si a pesar de seguir los pasos de la "Guia para la reparación del sistema" el sistema no se ha reparado a continuación damos las instrucciones para una solución manual del sistema.

1. Abrir una terminal y navegar hasta la carpeta Grupo4 e ingrese al directorio.
	`$ cd Grupo4`

2. Ingrese al directorio so7508
	`$ cd so7508`

3. Borrar el archivo de configuración **instalarTP.conf**
	`$ rm instalarTP.conf`

4. Ejecutar el script de instalación y seguir los pasos ("Guia para la instalación del sistema") a partir del paso 4.
	`$ ./instalarTP.sh`


Nota: al borrar el archivo .conf el script detecta como que el programa nunca ha sido isntalado, por lo tanto hara una instalación limpia.


**FIN ESTO VA EN EL README**



