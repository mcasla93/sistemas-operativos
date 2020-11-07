#! /bin/bash

# check list
# 1- verivicar si el ambiente esta inicializado
# 2- verificar si el proceso ya esta corriendo
# 3- si todo esta bien arrancar el proceso y ponerlo en background


### verificar el ambiente #######################################

echo "verificando el ambiente......"
./ambienteInicializado.sh
if [ $? -ne 0 ]; then
	echo "ejecute [ . ./incializarSistema.sh ]"
    exit
fi

################################################################



### verificar si el proceso ya esrta corriendo #################
# echo "verificando si el proceso ya esta corriendo....."
# falta el chequeo

################################################################
# lanzamos el proceso principal
# si usamos top vemos que el proceso yes se empezo a ejecutar en background
./procesoPral.sh

