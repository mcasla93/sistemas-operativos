#!/bin/bash
# Diseño del registro de log

# debo recibir 2 parametros

if [ $# -lt 2 ]; then
  echo "ejecute [./log.sh] [tipo] [mensaje] "
  exit 1
fi

FILE="./bitacora.log"

DATE=`date +%d-%m-%Y-%T`

echo -e "$DATE - $1 - $2 - $USER" >> "$FILE"
