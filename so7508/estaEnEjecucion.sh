#! /bin/bash

# función que detecta si el proceso pasado como parámetro se esta ejecutando
# en principio funciona para cualquier proceso de ususario.
# devuleve 0 si ya se esta ejecutando y 1 si el proceso no esta corriendo

estaEnEjecucion (){

	procesoObjetivo="${1}"
    if [ "$procesoObjetivo" = "" ];
    then
        echo 'no paso nombre del proceso..'
        exit
    fi

    result=`ps -e | grep "$procesoObjetivo"`
    if [ $? -eq 0 ]; then
        echo "[$procesoObjetivo] ya esta en ejecución..."
        return 0
    else
		echo "[$procesoObjetivo] NO esta en ejecución..."
		return 1
	fi
}

estaEnEjecucion $1
