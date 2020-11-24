#! /bin/bash

# El procedimiento de frenar proceso es

# 1- debe verificar si el proceso esta corriendo
# 2- detener el proceso
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
	log "${TYPES[1]}" "${ORANGE} modo de invocación [./frenarPeroceso.sh] [nombreProceso] ${NC}" "$0";
    #echo "modo de invocación [./frenarPeroceso.sh] [nombreProceso]"
    exit
fi

proceso=${1}
### Verificar que el proceso esta corriendo ############################

#echo "Verificamos que el proceso este corriendo!!!!!"

./estaEnEjecucion.sh ${proceso}

if [ $? -eq 0 ]; then
	
    # tomo el numero de proceso
    ProcessID=$(pgrep "$proceso")

    kill $ProcessID > /dev/null &
    log "${TYPES[0]}" "${GREEN} proceso Nº $ProcessID \t \t...... detenido ${NC}" "$0";
    #echo "proceso detenido.. $ProcessID"
else
    log "${TYPES[0]}" "${GREEN} el proceso $proceso  \t \t...... no esta en ejecucion ${NC}" "$0";
    #echo "el proceso no esta en ejecucion..."
fi


########################################################################
