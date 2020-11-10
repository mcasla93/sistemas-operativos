#! /bin/bash

# El procedimiento de frenar proceso es

# 1- debe verificar si el proceso esta corriendo
# 2- detener el proceso

### Verificar que el proceso esta corriendo ############################


echo "Verificamos que el proceso este corriendo!!!!!"

./estaEnEjecucion.sh "principal.sh"

if [ $? -eq 0 ]; then
	
    # tomo el numero de proceso
    ProcessID=$(pgrep "principal.sh")
    echo numero de proceso $ProcessID

    kill $ProcessID
    echo "proceso detenido.."
else
    echo "el proceso no esta en ejecucion..."
fi


########################################################################
