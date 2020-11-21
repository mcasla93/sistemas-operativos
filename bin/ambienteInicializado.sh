#! /bin/bash

# funcion que devuelve 0 si el ambiente esta iniciado o uno sino 
#IDENTIFIERS=("GRUPO" "DIRINST" "DIRBIN" "DIRMAE" "DIRIN" "DIRRECH" "DIRPROC" "DIROUT");

function ambienteInicializado {

    if [[ -z ${DIRMAE+x} || -z ${DIRIN+x} || -z ${DIRRECH+x} || -z ${DIRPROC+x} || -z ${DIROUT+x} || -z ${LOGPPRINCIPAL+x} || -z ${DIRCOMISIONES+x} ]]
    then 
        echo "EL ambiente no esta inicializado"
        return "1"
    else 
        echo "El ambiente esta inicializado"
        return "0"
    fi
}
#llamamos a la funcion
ambienteInicializado
