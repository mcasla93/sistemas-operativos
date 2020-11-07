#! /bin/bash

# funcion que devuelve 0 si el ambiente esta iniciado o uno sino 

function ambienteInicializado {
    if [ "$AMBIENTE" = "iniciado" ];
    then 
        echo "El ambiente esta inicializado"
        return "0"
    else 
        echo "EL ambiente no esta inicializado"
        return "1"
    fi
}
#llamamos a la funcion
ambienteInicializado
