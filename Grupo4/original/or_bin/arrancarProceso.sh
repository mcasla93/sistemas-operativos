#! /bin/bash

# check list
# 1- verivicar si el ambiente esta inicializado
# 2- verificar si el proceso ya esta corriendo
# 3- si todo esta bien arrancar el proceso y ponerlo en background

TITLE="##################";
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'
GREEN='\033[0;32m'
DEBUG='\033[1;36m'
YELLOW='\033[1;33m'

#Booleans
OK=0;
ERROR=1
INSTALL="install"
QUIT="quit"

TYPES=("INF" "WAR" "ERR");

SEPARATOR="-"


#Esta funcion agrega un registro con cualquier formato modular
function addRegister(){
	register="";
	fields=("$@");
	
	for i in ${!fields[@]}; do
		if [[ i -gt 0 ]]; then
			register+="${fields[i]}$SEPARATOR"
		fi
	done

	#Quito el ultimo char
	end=$((${#register}-1));
	echo "${register:0:${end}}" >> "${fields[0]}";	
}

function log(){
	DATE=$(date "+%D %T");
	type=$1;
	message=$2;
	source=$3;
	#Mensaje a stdout
	#Redirigo a stderr para que no me lo capturen 
	echo -e "$message" >&2;
	#Mensaje a log
    #echo    " el arvchivo es $DIRINST"
	addRegister "$DIRINST/arrancarFrenar.log" "$DATE" "$type" "$message" "$source" "$USER" 
}
### Verifica la cantidad de parámetros ############################
if [ $# -ne 1 ]; then
	log "${TYPES[1]}" "${ORANGE} modo de invocación [./arrancarPeroceso.sh] [nombreProceso] ${NC}" "$0";
    #echo "modo de invocación [./arrancarPeroceso.sh] [nombreProceso]"
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
log "${TYPES[0]}" "${GREEN} verificando el ambiente...... ${NC}" "$0";
#echo "verificando el ambiente......"
./ambienteInicializado.sh
if [ $? -ne 0 ]; then
    log "${TYPES[1]}" "${ORANGE} No inicializado, ejecute [ . ./iniciarAmbiente.sh ${NC}" "$0";
	#echo "ejecute [ . ./iniciarAmbiente.sh ]"
    exit
fi

################################################################

### verificar si el proceso ya esta corriendo ######º###########
#echo "verificando si el proceso ya esta corriendo....."
log "${TYPES[0]}" "${GREEN} verificando si el proceso ya esta corriendo..... ${NC}" "$0";
./estaEnEjecucion.sh "$proceso"

if [ $? -eq 0 ]; then
    log "${TYPES[1]}" "${ORANGE} [principal.sh] esta en ejecución, si se quiere iniciar de nuevo, antes debe detener el proceso con frenarproceso ${NC}" "$0";
	#echo '[principal.sh] esta en ejecución, si se quiere iniciar de nuevo, antes debe detener el proceso con frenarproceso'
    exit
fi
################################################################
# lanzamos el proceso principal
# si usamos top vemos que el proceso se empezo a ejecutar en background


./$proceso > /dev/null &
ProcessID=$(pgrep "$proceso")
log "${TYPES[0]}" "${GREEN} Iniciando $proceso .......... id Nº $ProcessID ${NC}" "$0";
#echo "$proceso en ejecucion id $ProcessID"