********************************************************************************************
#FIUBA - Sistemas Operativos ( 75.08 ) - Segundo Cuatrimestre 2020
   GRUPO N° 4

********************************************************************************************
   Descarga del paquete
********************************************************************************************

### Guia para la descarga del sistema

1. Ir al [repositorio](https://github.com/mcasla93/sistemas-operativos).
 de GitHub

2. Ir a la sección Releases y descargar el source.zip de la ultima versión

3. Una vez descargado descomprimir el .zip.

El .zip consta de una carpeta Grupo4( que es el paquete de instalación), este README.md y el informe (informe.md)

********************************************************************************************
   Requisitos de instalación
********************************************************************************************

#Documentacion

*********************************************************************************************
   Instalación
*********************************************************************************************
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

	`$ ./instalarTP.sh`

4. Siga las instrucciones que apareceran en la terminal para proceder con la instalación del sistema.

Cuando el instalador le indique debera escribir el nombre que quiera que tengan los directorios del programa

![instalacionComienzo](/assets/images/instalacionComienzoE.png)


5. Como ultimo paso aparece en la terminal un listado de los directorios a ser creados y aqui podra elegir terminar con la instalacion o volver atras para elegir nuevamente por si quiere realizar un cambio.


![instalacionConfirmar](/assets/images/instalacionConfirmarE.png)


6. Una vez finalizada la instalación puede comprobar la correcta instalación al ver que se ha creado (entre otros archivos) uno llamado **instalarTP.conf** en este encontrara 8 registros con identificadores (DIRBIN, DIRMAE, etc) que indican la dirección de cada carpeta qeu se ha creado y un noveno registro con información adicional sobre la instalación.

Nota: Tambien puede volver a ejecutar el script **instaladorTP.sh** que hará una verificación de los archivos e indicará si el sistema se encuentra instalado correctamente (ver sección "Guia para la reparación del sistema")

![instalacionFinaliza](/assets/images/instalacionFinalizaE.png)



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


Nota: al borrar el archivo .conf el script detecta como que el programa nunca ha sido instalado, por lo tanto hara una instalación limpia.


	
*********************************************************************************************
### Guia para la Ejecución
*********************************************************************************************
1. #### inicializacion del ambiente

	Para poder poner en funcionamiento el sistema, deberá tener inicializado el ambiente de trabajo. 
	Ubíquese en el directorio donde han guardado los scripts, por defecto [./bin] y ejecute el script iniciarAmbiente.sh 
	del siguiente modo:

	$ . ./iniciarAmbiente.sh  (punto espacio punto barra)
	
	La forma de invocación de este script es utilizada, para asegurar que cuando se invoque al
	proceso principal no se generen sub-shells, ya que si eso ocurre el valor de las variables de ambiente
	pierden visibilidad en el proceso principal.

	En caso de invocar el proceso sin el punto inicial, no dejara continuar ya que las variables de ambiente no serán visibles.

	![InicializacionAmbiente](/assets/images/ejecucionPrimeraVez.png)

	Ejecutando el script de la manéra indicada, si no hay errores, el ambiente se inícia y seguidamente el proceso principal es lanzado, 
	se informa en pantalla y en el archivo iniciarAmbiente.log los resultados de cada etápa.

	![InicializacionAmbiente](/assets/images/inicializacionDosPuntos.png)

	#### TRATAMIENTO DE ERRORES
	Durante el proceso de inicialización se pueden dar varios errores
	1. #### Archivo InstalarTP.conf
		Si hay algun tipo de error en el archivo de confiuración, no tenga permisos de lectúra o no exista se informará que debe ejecutar
		el script de instalacion nuevamente y terminará la ejecición.

		
		![InicializacionAmbiente](/assets/images/ArchivoConfNoExiste.png)


2. #### Frenar Proceso
	El inicializador de ambiente, informará si hay algún error, y en caso de querer terminar el proceso 
	de utilizar frenarProceso.sh

3. #### Arrancar proceso

#Documentacion
