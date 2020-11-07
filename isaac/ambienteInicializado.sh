#! /bin/bash



if [ $MIVAR=='var' ];
then 
    echo "EL ambiente esta inicializado"
	return "0"	
else 
    echo "No esta inicializado"
	return "1"
fi
