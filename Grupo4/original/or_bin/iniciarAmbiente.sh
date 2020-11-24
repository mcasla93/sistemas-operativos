#! /bin/bash

#Format
TITLE="##################";
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'
GREEN='\033[0;32m'
DEBUG='\033[1;36m'
YELLOW='\033[1;33m'

#Booleans
OK=0;
ERROR=1
INSTALL="install"
QUIT="quit"


#Nombres reservados
RESERVED_NAMES=("GrupoN" "so7508" "original" "catedra" "propios" "testeos");
DIRECTORIES_INFO=("Directorio de ejecutables" "Directorio de tablas maestras" "Directorio de novedades" "Directorio de rechazados" "Directorio de lotes procesados" "Directorio de transacciones");
TYPES=("INF" "WAR" "ERR");

#NOTA: pide que recuerde los valores nuevos en el caso de cancelar la instalacion
installation_directories=("bin" "master" "input" "rechazos" "lotes" "output");
IDENTIFIERS=("GRUPO" "DIRINST" "DIRBIN" "DIRMAE" "DIRIN" "DIRRECH" "DIRPROC" "DIROUT");

#Siempre parent_path va a ser so7508, que es donde esta este Script
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit ; pwd -P );

#CONFIG_PATH="${PARENT_PATH}/instalarTP.conf";
#LOG_PATH="${GRUPO}/so7508/iniciarambiente.log";
SEPARATOR="-"


#Esta funcion agrega un registro con cualquier formato modular
function addRegister(){
	register="";
	fields=("$@");
	
	for i in ${!fields[@]}; do
		if [[ i -gt 0 ]]; then
			register+="${fields[i]}$SEPARATOR"
		fi
	done

	#Quito el ultimo char
	end=$((${#register}-1));
	echo "${register:0:${end}}" >> "${fields[0]}";	
}

function log(){
	DATE=$(date "+%D %T");
	type=$1;
	message=$2;
	source=$3;
	#Mensaje a stdout
	#Redirigo a stderr para que no me lo capturen 
	echo -e "$message" >&2;
	#Mensaje a log
	addRegister "$LOG_PATH" "$DATE" "$type" "$message" "$source" "$USER" 
}


function isInstalled(){
	#Existe el instalarTP.conf?
	if [ -e "$CONFIG_PATH" ]
	then 
		#log "${TYPES[0]}" "${GREEN}$CONFIG_PATH existe${NC}" "$0";
		isInstalled_return=$OK;
	else 
		log "${TYPES[1]}" "${YELLOW}$CONFIG_PATH no existe${NC}" "$0";
		isInstalled_return=$ERROR;
	fi
}


#Verificamos la existencia del archivo de configuración
verificarArchivo() {
	if [ -f "$1" ]; then
        return $OK
    else
	    return $ERROR
    fi
}


verificarCarpetas(){

  for folder in ${installation_directories[*]}
  do
    if [ ! -d "$GRUPO/$folder" ]; then
      echo "$GRUPO/$folder incorrecto"
      return $ERROR
    fi
  done
  
  return $OK
}



verificarScrips(){

  scripts=("arrancarProceso.sh" "frenarProceso.sh" "pprincipal.sh" "ambienteInicializado.sh" "estaEnEjecucion.sh");

  for file in ${scripts[*]}
  do
    if [ ! -f "$PARENT_PATH/$file" ]; then
        log "${TYPES[1]}" "${ORANGE}Falta el archivo $file ${NC}" "$0";
        return $ERROR
	else	
		if [ ! -x "$PARENT_PATH/$file" ]; then
			log "${TYPES[1]}" "${ORANGE}Cambiando permisos ..... $file ${NC}" "$0";
			chmod +x "$PARENT_PATH/$file"
		fi		
		#log "${TYPES[0]}" "${GREEN}$file ..... CORRECTO ${NC}" "$0";
    fi
  done

  return $OK

}

function loadConfig(){
	linea=()
	index=0;
	#log "${TYPES[0]}" "\n${GREEN}${TITLE} VERIFICANDO ARCHIVO DE CONFIGURACION $TITLE${NC}\n" "$0";
	while read -r LINE; do
			#result=$(echo "$LINE" | sed 's;\(.*\)-\(.*\);\2;');
			result=$(echo "$LINE" | sed 's;^\([^-]*\)-\(.*\);\2;');
        	linea[index]=$result
			((index++));
	done < "$CONFIG_PATH"

	export GRUPO="${linea[0]}"
    export DIRINST="${linea[1]}"
    export DIRBIN="${linea[2]}"
    export DIRMAE="${linea[3]}"
    export DIRIN="${linea[4]}"
    export DIRRECH="${linea[5]}"
    export DIRPROC="${linea[6]}"
    export DIROUT="${linea[7]}"
	export DIRCOMISIONES="$DIROUT/comisiones/"
	export LOGPPRINCIPAL="$GRUPO/so7508/pprincipal.log"


	log "${TYPES[0]}" "${GREEN}Exportando variable de entorno \t \t...... correcto ${NC}" "$0";

}




estaEnEjecucion (){

	procesoObjetivo="${1}"
    if [ "$procesoObjetivo" = "" ];
    then
        log "${TYPES[1]}" "${ORANGE}Falta nombre del proceso $procesoObjetivo ${NC}" "$0";
        return $ERROR
    fi

    result=`ps -e | grep "$procesoObjetivo"`
    if [ $? -eq 0 ]; then
        return $OK
    else
		return $ERROR
	fi
}


function ambienteInicializado {

if [[ -z ${DIRMAE+x} || -z ${DIRIN+x} || -z ${DIRRECH+x} || -z ${DIRPROC+x} || -z ${DIROUT+x} || -z ${LOGPPRINCIPAL+x} || -z ${DIRCOMISIONES+x} ]]; then
    return $ERROR
else    
    return $OK             
fi
}

######################################################################
#  			main
######################################################################

cd "${PARENT_PATH}";
#echo "parent path  ${PARENT_PATH}";
#Subo a $GRUPO
cd "../"
GRUPO=$(pwd);
#echo "GRUPO $GRUPO"
CONFIG_PATH="$GRUPO/so7508/instalarTP.conf"
#echo "CONFIG_PATH $CONFIG_PATH"
LOG_PATH="${GRUPO}/so7508/iniciarambiente.log";

log "${TYPES[0]}" "${GREEN}${TITLE} Inicializando el entorno de ejecición ${TITLE}${NC}" "$0";


# #Esta instalado?
isInstalled_return=0;
isInstalled;
#Si esta instalado verificado que este correcto
if [[ $isInstalled_return -eq $OK ]]; then

	ambienteInicializado

	if [ $? -eq $OK ]
	then 
		estaEnEjecucion "principal"

		if [ $? -eq $OK ]
		then	
			log "${TYPES[1]}" "${ORANGE} Ambiente inicializado y proceso principal en ejecuión, debe ejecutar [frenarproceso.sh pprincipal] para reiniciar ${NC}" "$0";        
		else
			log "${TYPES[1]}" "${ORANGE}El ambiente está inicializado, pero pprincipal no esta en ejecución usar [arrancarProceso.sh pprincipal.sh] para reiniciar ${NC}" "$0";        		
		fi


	else
		# el ambiente no esta inicializado veo el modo de invocacion
		if [ "$0" != "/bin/bash" ] && [ "$0" != "/bash" ];
		then
			log "${TYPES[1]}" "${ORANGE} La primera vez debe iniciar con permisos [. ./IniciarAmbiente.sh]${NC}" "$0";    
		else
			g_files_ok=$OK;	
			loadConfig;

			# # verificamos la carpeta de instalacion
			carpetas=$OK;	
			verificarCarpetas 
			if [ $? -eq $OK ]
			then
			    log "${TYPES[0]}" "${GREEN}carpetas de instalacion \t \t...... correcto${NC}" "$0";
				carpetas=$OK;	
			else
			    log "${TYPES[1]}" "${ORANGE}carpetas de instalacion \t \t ...... incorrecto${NC}" "$0";
				carpetas=$ERROR;	
			fi


########################################################################################################


			# #verificar los scritps y los permisos
			scritps=$OK
			verificarScrips
			if [ $? -eq $OK ]
			then
				log "${TYPES[0]}" "${GREEN}scripts de ejecución \t \t \t...... correcto${NC}" "$0";
				scritps=$OK;	
			else
				log "${TYPES[1]}" "${ORANGE}scripts de ejecución \t \t \t...... incorrecto${NC}" "$0";
				scritps=$ERROR;	
			fi


			if [ $scritps -eq $OK ] && [ $carpetas -eq $OK ] #&& [ $permisos -eq $OK ]
			then 			
				# LANZO EL PROCESO PINCIPAL
				$DIRBIN/pprincipal.sh > /dev/null &		
				ProcessID=$(pgrep pprincipal)
				log "${TYPES[0]}" "${GREEN}Proceso principal en ejecución Nº $ProcessID \t ..........correcto ${NC}" "$0";
				log "${TYPES[0]}" "${GREEN}Para finalizar el proceso principal debe ejecutar [frenarproceso.sh pprincipal] ${NC}" "$0";				

			else
				log "${TYPES[1]}" "${ORANGE}El sistema no se encuentra instalado correctamente, saliendo${NC}" "$0";		
			fi
		fi
	fi
else
	# #No esta instalado
	log "${TYPES[1]}" "${ORANGE}El archivo de configuracion no existe, Debe ejecutar [instalarTP.sh]${NC}" "$0";
fi

cd ./bin