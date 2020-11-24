#! /bin/bash

# El procedimiento de frenar proceso es

# 1- debe verificar si el proceso esta corriendo
# 2- detener el proceso


### Verifica la cantidad de parámetros ############################
if [ $# -ne 1 ]; then
    echo "modo de invocación [./frenarPeroceso.sh] [nombreProceso]"
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
    echo "proceso detenido.. $ProcessID"
else
    echo "el proceso no esta en ejecucion..."
fi


########################################################################
