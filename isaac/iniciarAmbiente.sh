#! /bin/bash

# Respecto de la inicialización
# 11. ¿El README brinda las instrucciones correctas para ejecutar el inicializador?
# 12. ¿El README brinda las instrucciones correctas para detener o arrancar?
# 13. ¿Fue suficiente la explicación del README?


function setVariables {

export GRUPO="GRUPO"
export DIRINST="DIRINST"
export DIRBIN="DIRBIN"
export DIRMAE="DIRMAE"
export DIRIN="DIRIN"
export DIRRECH="DIRRECH"
export DIRPROC="DIRPROC"
export DIROUT="DIROUT"
}


# modo de invocacion
if [ "$0" != "/bin/bash" ];
then
    echo 'debe ejecutarlo con permisos [. ./Iniciar_B.sh] '
    exit
fi

#chequeo si el ambiente ya esta init
./ambienteInicializado.sh >> /dev/null
if [ $? -eq 0 ]
then	
	echo 'Ambiente ya inicializado...'
    ./estaEnEjecucion.sh "principal"
    if [ $? -eq 0 ]
    then	
        echo "el proceso ya esta corriendo use [frenarProceso] y vuelva a ejecutar"
        return 1
    fi
fi  

setVariables
echo el ambiente fue inicializado......

./principal.sh > /dev/null &


