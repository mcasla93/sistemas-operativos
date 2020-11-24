# Informe Primer TP Sistemas operativos 75:08


# Punto 2. Documentación

## Hipótesis y Aclaraciones

### Hipotesis del punto 3

Para el script de instalación (instalarTP.sh) se tienen las siguientes hipótesis:

#### Reparacion:
El script tiene en cuenta los casos de que los archivos no se encuentren dentro de los directorios (e.g las tablas maestras no estan en el DIRMAE) por lo que se hace una copia de la carpeta "original" a la carpeta a reparar y tambien el caso de que el directorio DIRMAE ni siquiera exista. En este ultimo caso primero se crea el directorio ,utilizando el valor del archivo **instalarTP.conf** asignado al identificador del directorio faltante y luego se procede como antes a copiar del directorio **original** al directorio faltante.

#### Logs
Para los mensajes del tipo WAR lo interpretamos como aquellos errores que son predecibles y que estan dentro del alcance de resolucion del script, es decir por ejemplo el copiar archivos faltantes.

Los mensajes tipo ERR quedan reservado a errores mas graves que pueden llevar al tener que abortar la ejecucion dado que no se puede continuar con la instalación/reparación porque ha ocurrido una falla en el proceso que compromete la correcta instalación o reparación del sistema.

#### Restricciones en el nombre de los directorios

1. Al ingresar el nombre del directorio esta NO permitido el uso de espacios intermedios. Ejemplo "so 7508"

2. No esta permitido el uso de caracteres especiales, por ejemplo `!"#$%&//()="`

3. No se pueden utilizar subcarpetas, solo se ingresa el nombre del directorio sin posibilidad de anidar mas directorios e.g. (bin/sub_bin/sub_sub_bin), el script rechaza el caracter "/" dado que es considerado un tipo de caracter especial.



## Descripción de Problemas

### Descripción de Problemas - Punto 3

Una de las dificultades encontradas es el correcto registro de los mensajes de la terminal con respecto a aquellos que son de la stdout y los de la stderr.
Para los mensajes informativos se utilza una funcion **log** que se le pasa como parametro el mensaje, pero para el caso de comandos que se utilizan con la opcion **-verbose** se utiliza la funcion **logPipe** que no toma por parametro sino por redireccionamiento y luego el **logError** que funciona de la misma manera pero para los mensajes de la stderr.
El problema es qe no se encontro una manera de poder separar los mensajes de stderr de los de stdout de manera de procesarlos por separado por las funciones de **logPipe** y **logError**
e.g.
```
	function copyAllFilesFromTo(){
		from="$1"
		to="$2"
		cp -v "${from}"/* "${to}" 2>&1 | logPipe
	}
```
Todos los mensajes del comando cp -v son redireccionados a la entrada de la funcion **logPipe** para poder generar el log correspondiente, el problema es en el caso de ser un error tambien es redirigido al stdout (2>&1) entonces la funcion genera el log pero como si fuera del tipo INF y no del tipo ERR. El error queda registrado pero no como un error si no como un mensaje infomativo

Una solución planteda fue poner el comando dentro de un condicional y no redirigir la stderr a stdout, pero el problema es que al utilizar un pipe la condicion nunca se cumplia independientemente de si daba error el comando cp o no.
Por lo que el codigo del bloque `logError` queda inalcanzable

```
	if cp -v "${from}"/* "${to}" | logPipe; then
		logError 
	fi
```

Otro intento fue remover el pipe:
```
	if cp -v "${from}"/* "${to}" then
		logError 
	fi
```
De esta manera, en el caso de haber un error si se ejecutaba el bloquq del **logError** pero no se captura el -verbose.




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

![DownloadedDirs](/assets/images/downloadedDirs.png)


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


![installedDirs](/assets/images/installedDirs.png)







