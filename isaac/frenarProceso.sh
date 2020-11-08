#! /bin/bash

# El procedimiento de frenar proceso es

# 1- debe verificar si el proceso esta corriendo
# 2- detener el proceso

### Verificar que el proceso esta corriendo ############################


echo "Verificamos que el proceso este corriendo!!!!!"
# tomo el numero de proceso
ProcessID=$(pgrep "procesoPral.sh")
echo numero de proceso $ProcessID

kill $ProcessID


########################################################################
