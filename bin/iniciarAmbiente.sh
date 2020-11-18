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

CONFIG_PATH="${PARENT_PATH}/instalarTP.conf";
LOG_PATH="${PARENT_PATH}/iniciarambiente.log";
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

function logError(){
	read IN;
	DATE=$(date "+%D %T");
	type=${TYPES[2]};
	message="$IN";
	source="$0";

	#Mensaje a stderr
	echo -e "$message" >&2;

	addRegister "$LOG_PATH" "$DATE" "$type" "$message" "$source" "$USER" 
}


###Verificar Instalacion
function readIdentificationRegister(){
	#TODO: faltan verificar los subdirectorios
	identifier=$(echo "$1" | sed 's;\(.*\)-\(.*\);\1;');
	value=$(echo "$1" | sed 's;\(.*\)-\(.*\);\2;');
	
	if [[ $2 -gt 1 ]]; then
		local_index=$(( $2-2 ));
		#Obtener el nombre del directorio a partir de value, reemplazo los nombres por default
		dir_name=$(echo "$value" | sed 's;\(.*\)/\(.*$\);\2;');
		installation_directories[$local_index]=$dir_name;
	fi

	#Verifica que el valor leido exista, sea un directorio, 
	#que el identificador coincida en orden
	if [[ -e "$value" && (-d "$value") && ("${IDENTIFIERS[$2]}" == "$identifier") ]]; then
		log "${TYPES[0]}" "${GREEN}OK: ${identifier}${NC}" "$0";
		log "${TYPES[0]}" " - Path: ${value}\n" "$0";
	else
		log "${TYPES[2]}" "${RED}ERROR:\tEl directorio $identifier no se encuentra${NC}" "$0";
		log "${TYPES[2]}" "${ORANGE} - Path: $value${NC}\n" "$0";
		g_files_ok=0;
	fi
}

function verifyConfigFiles(){
	#Verifica files de so7508 (no se si importa que esten, podria ser un warning)
	#.conf debe existir porque es lo primero que se verifica
	echo -e "${GREEN}${TITLE} VERIFICANDO ARCHIVOS EN so7508 ${TITLE}${NC}"
	so7508_path="${GRUPO}/so7508/";
	files=("instalarTP.sh" "instalarTP.log" "instalarTP.conf" "iniciarambiente.log" "pprincipal.log");
	for i in ${!files[@]}; do
		if [[ -e "${so7508_path}${files[i]}" ]]; then
			log "${TYPES[0]}" "${GREEN}OK: ${files[i]}${NC}" "$0"
		else
			log "${TYPES[1]}" "${YELLOW}WARNING: ${files[i]} no existe${NC}\n - Path:${so7508_path}${files[i]}" "$0";
		fi
	done
}

function readConfigFile(){
	index=0;
	log "${TYPES[0]}" "\n${GREEN}${TITLE} VERIFICANDO ARCHIVO DE CONFIGURACION $TITLE${NC}\n" "$0";
	while read -r LINE; do
		#Lee solo los primeros 8 registros
		if [[ index -lt ${#IDENTIFIERS[@]} ]]; then
			readIdentificationRegister "$LINE" $index;
			echo $index;
			((index++));
		else
			log "${TYPES[0]}" "${LINE}\n" "$0";
		fi
	done < "$CONFIG_PATH"
	if [[ g_files_ok -ne $OK ]]; then
		log "${TYPES[1]}" "${RED}RESULTADO VERIFICACION:\tHay uno o varios directorios faltantes${NC}" "$0";
	fi
	verifyConfigFiles
		
}

function isInstalled(){
	#Existe el instalarTP.conf?
	if [ -e "$CONFIG_PATH" ]
	then 
		log "${TYPES[0]}" "${GREEN}$CONFIG_PATH existe${NC}" "$0";
		isInstalled_return=$OK;
	else 
		log "${TYPES[1]}" "${YELLOW}$CONFIG_PATH no existe${NC}" "$0";
	fi
}


###Instalacion

function inputDirectoryName(){
	if [[ $# -ne 3 ]]; then
		echo "Exception: deben pasarse 2 args; directorio default y mensaje a stdout";
		exit 1;
	fi
	
	default_dir_name=$1;
	input_dir_name=$1;
	valid_input=0;
	
	non_permitted_names=(${RESERVED_NAMES[@]} ${installation_directories[@]});			
	while [[ "${valid_input}" -eq 0 ]]; do
		log "${TYPES[0]}" "$2: ${GREEN}$default_dir_name${NC}" "$0";
		read -r input_dir_name;
		log "${TYPES[0]}" "${input_dir_name}" "$0"
		if [[ "$input_dir_name" == "" ]]; then
			input_dir_name=$1
			valid_input=1;
		elif [[ ${#input_dir_name} -lt 1 ]]; then
			log "${TYPES[0]}" "Debe tener mas de un caracter" "$0";
		else
			valid_input=1;
			for i in "${!non_permitted_names[@]}"; do
					if [ "${non_permitted_names[i]}" == "$input_dir_name" ]; then
						log "${TYPES[0]}" "${YELLOW}No puede utilizar un nombre reservado${NC}" "$0";
						#La lista de nombres se toman como parametros, rompiendo con el diseño
						echo -e "Nombres reservados: ${non_permitted_names[@]}";
						valid_input=0;
					fi
			done
		fi
	done

	echo -e "${DEBUG}Directorio Valido :) guardando en indice $3${NC}"

	#Lo agrego a la lista de usados
	installation_directories[$3]="${input_dir_name}";
}

function finishInstallation(){
	#En este momento estoy en $GRUPO
	for i in ${!installation_directories[@]}; do
		mkdir "${installation_directories[i]}" 2>&1 | logError
	done

	#Subdirectorio /ok
	PATH_NOVEDADES_ACEPTADAS="${installation_directories[2]}/ok"
	mkdir "$PATH_NOVEDADES_ACEPTADAS"; 

	#subdirectorio /comisiones
	PATH_COMISIONES="${installation_directories[5]}/comisiones"
	mkdir "$PATH_COMISIONES";
	
	msg="REPARADA"
	if [[ "$1" == "instalacion" ]]; then
		msg="COMPLETADA";
	fi

	log "${TYPES[0]}" "Estado de la instalacion:\t${msg}" "$0";

	#return
	echo $OK;
}

function handleUserConfirmation(){
	log "${TYPES[0]}" "¿Confirma la $1? (SI-NO)";
	read -r ANSWER;
	case "${ANSWER}" in
		[sS] | [sS][iI])
			finishInstallation "$1"
		;;
		[nN] | [nN][oO])
			echo 0
		;;
	*)
		log "${TYPES[0]}" "Favor de ingresar s/si o n/no" "$0";
		;;
	esac
}

function installationConfirmation(){
	echo "TP1 SO7508 2° Cuatrimestre 2020 Curso Martes Copyright @ Grupo N" "$0"; 
	log "${TYPES[0]}" "Tipo de proceso:\t$1" "$0";
	log "${TYPES[0]}" "Directorio Padre:\t$GRUPO" "$0";
	log "${TYPES[0]}" "Ubicación script de instalación:\t$GRUPO/so7508/instalarTP.sh" "$0";
	log "${TYPES[0]}" "Log de la instalacion:	$GRUPO/so7508/instalarTP.log" "$0";
	log "${TYPES[0]}" "Archivo de configuracion:\t$GRUPO/so7508/instalarTP.conf" "$0";
	log "${TYPES[0]}" "Log de la inicializacion:\t$GRUPO/so7508/inicarmbiente.log" "$0";
	log "${TYPES[0]}" "Log del proceso principal:\t$GRUPO/so7508/pprincipal.log" "$0";
	for i in ${!DIRECTORIES_INFO[@]}; do		
		log "${TYPES[0]}" "${DIRECTORIES_INFO[i]}:\t${GRUPO}/${installation_directories[i]}" "$0";
	done
	log "${TYPES[0]}" "Estado de la $1:\tLISTA" "$0";
	
}

#Camino de instalacion
function installation(){
	log "${TYPES[0]}" "${GREEN}${TITLE} Proceso de instalacion ${TITLE}${NC}" "$0";
	log "${TYPES[0]}" "Escriba el nombre del directorio, para aceptar el por defecto presione ENTER" "$0";
	#El argumento default debe actualizarse en el caso de que el user cancele la isntalacion con el ultimo valor que puso
	for (( j = 0; j < 6; j++ )); do
		inputDirectoryName "${installation_directories[j]}" "${DIRECTORIES_INFO[j]}" $j; #Al pasar i se que elemento sobrescribir
	done
}

function repair(){
	echo -e "${DEBUG}TODO: Intentar reparar caso contrario avisar que deberia hacer el usuario${NC}"
	installationConfirmation "REPARACION"
	installation_ok=0;
	installation_ok=$(handleUserConfirmation "reparacion");		
	if [[ installation_ok -eq $OK ]]; then
		createConfigFile "REPARACION"
	fi
}

#Como todos son archivos, el echo funciona como un return si lo redirigo de la stdin
function handleUserInput(){
	log "${TYPES[0]}" "Instalar o Salir? I/S" "$0";
	read -r ANSWER;
	case "${ANSWER}" in
		[iI] | [iI][nN][sS][tT][aA][lL][lL])
			echo "${INSTALL}";
		;;
		[sS] | [sS][aA][lL][iI][rR])
			exit 0;
		;;
	*)
		log "${TYPES[0]}" "Favor de ingresar I/Install or S/Salir" "$0"
		;;
	esac
}

######Funciones para .conf#########

function createConfigFile(){
	#Crea nuevo, > es un overwrite
	> "$CONFIG_PATH";
	addRegister "$CONFIG_PATH" "${IDENTIFIERS[0]}" "${GRUPO}";
	addRegister "$CONFIG_PATH" "${IDENTIFIERS[1]}" "${GRUPO}/so7508";	
	for i in "${!installation_directories[@]}";do
		identifier_index=$((i + 2));
		addRegister "$CONFIG_PATH" "${IDENTIFIERS[identifier_index]}" "${GRUPO}/${installation_directories[i]}";
	done
	appendAdditionalInfo "$1"
}

function appendAdditionalInfo(){
	DATE=$(date "+%D %T");
	addRegister "$CONFIG_PATH" "$1" "$DATE" "$USER";
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
    # echo "$GRUPO/$folder"
    if [ ! -d "$GRUPO/$folder" ]; then
      #echo "$folder incorrecto"
      return $ERROR
    #else
      #echo "$folder correcto"  
    fi
  done
  
  return $OK
}



verificarScrips(){
  PPRAL="pprincipal.sh"
  ARRAPROC="arrancarProceso.sh"
  FRENPROC="frenarProceso.sh"
  
  scripts=("$PPRAL" "$ARRAPROC" "$FRENPROC")

  for file in ${scripts[*]}
  do
    if [ ! -f "$PARENT_PATH/$file" ]; then
        log "${TYPES[1]}" "${ORANGE}Falta el archivo $file ${NC}" "$0";
        return $ERROR
    fi
  done

  return $OK

}



function loadConfig {
    line=()
    let a=0
    while read -r -a nombre      
    do
        line[a]=$nombre

        #echo ${line[a]}
        let a+=1    
    done < "$PARENT_PATH/instalarTP.conf"

    export GRUPO="${line[0]}"
    export DIRINST="${line[1]}"
    export DIRBIN="${line[2]}"
    export DIRMAE="${line[3]}"
    export DIRIN="${line[4]}"
    export DIRRECH="${line[5]}"
    export DIRPROC="${line[6]}"
    export DIROUT="${line[7]}"

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
    if [ "$GRUPO" = "" ]||[ "$DIRINST" = "" ] || [ "$DIRBIN" = "" ] || [ "$DIRMAE" = "" ] || [ "$DIRIN" = "" ] || [ "$DIRRECH" = "" ] || [ "$DIRPROC" = "" ] || [ "$DIROUT" = "" ];
    then 
        return $ERROR
     fi    
    return $OK             
}
##############main#####################
#Estoy en so7508
cd "${PARENT_PATH}";

#Subo a $GRUPO
cd "../"
GRUPO=$(pwd);

log "${TYPES[0]}" "${GREEN}${TITLE} Inicializando el sistema ${TITLE}${NC}" "$0";



ambienteInicializado
if [ $? -eq $OK ]
then 
    estaEnEjecucion "principal"
    if [ $? -eq $OK ]
    then	
        log "${TYPES[0]}" "${GREEN}El ambiente ya esta inicializado, debe ejecutar [frenarproceso.sh] para reiniciar ${NC}" "$0";        
        exit
    else
        log "${TYPES[1]}" "${ORANGE}Ambiente ya incializado ..... lanzando proceso $procesoObjetivo ${NC}" "$0";
        $PARENT_PATH/pprincipal.sh > /dev/null &
        exit
    fi
fi

# modo de invocacion
if [ "$0" != "/bin/bash" ];
then
    log "${TYPES[1]}" "${ORANGE}debe ejecutarlo con permisos [. ./IniciarAmbiente.sh]${NC}" "$0";    
    exit
fi



# primero chequeamos el archivo conf
verificarArchivo "$PARENT_PATH/instalarTP.conf"
if [ $? -eq $OK ]
then
    log "${TYPES[0]}" "${GREEN}Archivo de configuracion ...... correcto${NC}" "$0";
else
    log "${TYPES[1]}" "${ORANGE}no existe el archivo de configuracion [instalarTP.conf]${NC}" "$0";
fi


# verificamos la carpeta de instalacion
verificarCarpetas 
if [ $? -eq $OK ]
then
    log "${TYPES[0]}" "${GREEN}carpetas de instalacion ...... correcto${NC}" "$0";
else
    log "${TYPES[1]}" "${ORANGE}carpetas de instalacion ...... incorrecto${NC}" "$0";
fi


#verificar los scritps 
verificarScrips
if [ $? -eq $OK ]
then
    log "${TYPES[0]}" "${GREEN}scripts ...... correcto${NC}" "$0";
else
    log "${TYPES[1]}" "${ORANGE}scripts ...... incorrecto${NC}" "$0";
fi

loadConfig

log "${TYPES[1]}" "${ORANGE}Primera ejecución....... lanzando proceso  ${NC}" "$0";
$PARENT_PATH/pprincipal.sh > /dev/null &




# #Esta instalado?
# isInstalled_return=0;
# isInstalled;
# #Si esta instalado verificado que este correcto
# if [[ $isInstalled_return -eq $OK ]]; then
# 	g_files_ok=$OK;	
# 	readConfigFile;
# 	if [[ g_files_ok -eq $OK ]]; then
# 		log "${TYPES[0]}" "${GREEN}Sistema se encuentra instalado correctamente, saliendo${NC}" "$0";
# 	else
		
# 		repair;
# 	fi
# else
# 	#No esta instalado
# 	response="$(handleUserInput)";               
# 	#SC2091 $(..) is for capturing and not for executing.
# 	if [[ "${response}" == "${INSTALL}" ]]; then
# 		installation_ok=0;
# 		while [[ installation_ok -eq 0 ]]; do
# 			installation;
# 			installationConfirmation "INSTALACION";
# 			installation_ok=$(handleUserConfirmation "instalacion");
# 		done
# 		#Creo archivo de configuracion
# 		createConfigFile "INSTALACION"
# 	else
# 		log "${TYPES[0]}" "Saliendo del instalador" "$0";
# 		exit 1;
# 	fi
# fi

