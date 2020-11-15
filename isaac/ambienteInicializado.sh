#! /bin/bash

# funcion que devuelve 0 si el ambiente esta iniciado o uno sino 
#IDENTIFIERS=("GRUPO" "DIRINST" "DIRBIN" "DIRMAE" "DIRIN" "DIRRECH" "DIRPROC" "DIROUT");

function ambienteInicializado {
    if [ "$GRUPO" = "" ]||[ "$DIRINST" = "" ] || [ "$DIRBIN" = "" ] || [ "$DIRMAE" = "" ] || [ "$DIRIN" = "" ] || [ "$DIRRECH" = "" ] || [ "$DIRPROC" = "" ] || [ "$DIROUT" = "" ];
    #if [ "$AMBIENTE" = "iniciado" ];
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
