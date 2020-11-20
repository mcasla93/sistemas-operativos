#! /bin/bash

# check list
# 1- verivicar si el ambiente esta inicializado
# 2- verificar si el proceso ya esta corriendo
# 3- si todo esta bien arrancar el proceso y ponerlo en background


### Verifica la cantidad de parámetros ############################
if [ $# -ne 1 ]; then
    echo "modo de invocación [./arrancarPeroceso.sh] [nombreProceso]"
    exit
fi

proceso=${1}
# verificamos si se desea correr el proceso principal   
	
# echo $proceso
# if [ $proceso != "principal.sh" ] || [ $proceso != "principal" ]; then
# 	echo "se lanza $proceso"
#     #"./$PATH/$proceso > /dev/null &"
#     exit
# else
#     echo son distintos
# fi


### verificar el ambiente #######################################

echo "verificando el ambiente......"
./ambienteInicializado.sh
if [ $? -ne 0 ]; then
	echo "ejecute [ . ./incializarSistema.sh ]"
    exit
fi

################################################################

### verificar si el proceso ya esta corriendo ######º###########
echo "verificando si el proceso ya esta corriendo....."

./estaEnEjecucion.sh "$proceso"

if [ $? -eq 0 ]; then
	echo '[principal.sh] esta en ejecución, si se quiere iniciar de nuevo, antes debe detener el proceso con frenarproceso'
    exit
fi
################################################################
# lanzamos el proceso principal
# si usamos top vemos que el proceso se empezo a ejecutar en background

./$proceso > /dev/null &

