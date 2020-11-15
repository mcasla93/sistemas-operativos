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

#begin

if [ "$0" != "/bin/bash" ];
then
    echo 'debe ejecutarlo con permisos [. ./Iniciar_B.sh] '
    exit
fi

setVariables
echo el ambiente fue inicializado......


