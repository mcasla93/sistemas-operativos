#! /bin/bash

# funcion que devuelve 0 si el ambiente esta iniciado o uno sino 
#IDENTIFIERS=("GRUPO" "DIRINST" "DIRBIN" "DIRMAE" "DIRIN" "DIRRECH" "DIRPROC" "DIROUT");

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

function ambienteInicializado {

    if [[ -z ${DIRMAE+x} || -z ${DIRIN+x} || -z ${DIRRECH+x} || -z ${DIRPROC+x} || -z ${DIROUT+x} || -z ${LOGPPRINCIPAL+x} || -z ${DIRCOMISIONES+x} ]]
    then 
        log "${TYPES[1]}" "${ORANGE} EL ambiente no esta inicializado ${NC}" "$0";    
        #echo "EL ambiente no esta inicializado"
        return "1"
    else 
        log "${TYPES[0]}" "${GREEN} El ambiente esta inicializado ${NC}" "$0";
        #echo "El ambiente esta inicializado"
        return "0"
    fi
}
#llamamos a la funcion
ambienteInicializado
