#! /bin/bash

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
# función que detecta si el proceso pasado como parámetro se esta ejecutando
# en principio funciona para cualquier proceso de ususario.
# devuleve 0 si ya se esta ejecutando y 1 si el proceso no esta corriendo

estaEnEjecucion (){

	procesoObjetivo="${1}"
    if [ "$procesoObjetivo" = "" ];
    then
        log "${TYPES[1]}" "${ORANGE} no paso nombre del proceso.. ${NC}" "$0";    
        #echo 'no paso nombre del proceso..'
        exit
    fi

    result=`ps -e | grep "$procesoObjetivo"`
    if [ $? -eq 0 ]; then
        ProcessID=$(pgrep "$procesoObjetivo")
        log "${TYPES[0]}" "${GREEN} [$procesoObjetivo] ya esta en ejecución... proceso Nº $ProcessID ${NC}" "$0";    
        #echo "[$procesoObjetivo] ya esta en ejecución... proceso Nº $ProcessID"
        return 0
    else
        log "${TYPES[1]}" "${ORANGE} [$procesoObjetivo] NO esta en ejecución... ${NC}" "$0";    
		#echo "[$procesoObjetivo] NO esta en ejecución..."
		return 1
	fi
}

estaEnEjecucion $1
