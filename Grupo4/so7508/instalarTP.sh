#! /bin/bash

#Format
TITLE="##################"
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'
GREEN='\033[0;32m'
DEBUG='\033[1;36m'
YELLOW='\033[1;33m'

#Booleans
OK=1;
INSTALL="install"
QUIT="quit"


#Nombres reservados
RESERVED_NAMES=("Grupo4" "so7508" "original" "catedra" "propios" "testeos")
DIRECTORIES_INFO=("Directorio de ejecutables" "Directorio de tablas maestras" "Directorio de novedades" "Directorio de rechazados" "Directorio de lotes procesados" "Directorio de transacciones")
TYPES=("INF" "WAR" "ERR")

#NOTA: pide que recuerde los valores nuevos en el caso de cancelar la instalacion
installation_directories=("bin" "master" "input" "rechazos" "lotes" "output")
IDENTIFIERS=("GRUPO" "DIRINST" "DIRBIN" "DIRMAE" "DIRIN" "DIRRECH" "DIRPROC" "DIROUT")

#Siempre parent_path va a ser so7508, que es donde esta este Script
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit ; pwd -P )

CONFIG_PATH="${PARENT_PATH}/instalarTP.conf"
LOG_PATH="${PARENT_PATH}/instalarTP.log"

SEPARATOR="-"


#Esta funcion agrega un registro con cualquier formato modular
function addRegister(){
	register=""
	fields=("$@")
	
	for i in ${!fields[@]}; do
		if [[ i -gt 0 ]]; then
			register+="${fields[i]}$SEPARATOR"
		fi
	done

	#Quito el ultimo char
	end=$((${#register}-1))
	echo "${register:0:${end}}" >> "${fields[0]}"
}

function log(){
	DATE=$(date "+%D %T")
	type=$1
	message=$2
	source=$0
	#Mensaje a stdout
	#Redirigo a stderr para que no me lo capturen 
	echo -e "$message" >&2
	#Mensaje a log
	addRegister "$LOG_PATH" "$DATE" "$type" "$message" "$source" "$USER" 
}

#Solo por redireccionamiento
function logPipe(){
	while read LINE; do
		DATE=$(date "+%D %T")
		type=${TYPES[0]}
		message="$LINE"
		source="$0"

		#Mensaje a stderr
		echo -e "$message" >&2

		addRegister "$LOG_PATH" "$DATE" "$type" "$message" "$source" "$USER" 	
	done
}


#Este solo funciona cuando se hace un redireccionamiento de la stderr
#NO pasar por parametro
function logError(){
	read -d '' IN
	DATE=$(date "+%D %T")
	type=${TYPES[1]}
	message="$IN"
	source="$0"

	#Mensaje a stderr
	echo -e "$message" >&2

	addRegister "$LOG_PATH" "$DATE" "$type" "$message" "$source" "$USER" 
}

function compareFilesFromDirWithDir(){
	if [[ $(diff -r "$1" "$2" | grep "$1") ]]; then
		log "${TYPES[1]}" "${RED}ERROR:\tFaltan archivos en el directorio $2${NC}"
		g_files_ok=0
	fi
}


###Verificar Instalacion
function readConfigFileLine(){
	identifier=$(echo "$1" | sed 's;^\([^-]*\)-\(.*\);\1;');
	value=$(echo "$1" | sed 's;^\([^-]*\)-\(.*\);\2;');
	
	if [[ $2 -gt 1 ]]; then
		local_index=$(( $2-2 ));
		#Obtener el nombre del directorio a partir de value, reemplazo los nombres por default
		dir_name=$(echo "$value" | sed 's;\(.*\)/\(.*$\);\2;')
		installation_directories[$local_index]=$dir_name
	fi

	#Verifica que el valor leido exista, sea un directorio, 
	#que el identificador coincida en orden
	#Si es el /bin(installation_directoires[0]) o /master (installation_directoires[1]) 
	#ver que tengan los mismo archivos que la carpeta original 
	if [[ -e "$value" && (-d "$value") && ("${IDENTIFIERS[$2]}" == "$identifier") ]]; then
		log "${TYPES[0]}" "${GREEN}OK: ${identifier}${NC}\n - Path: ${value}\n"
		#Si es DIRBIN o DIRMAE
		if [[ "$identifier" == "${IDENTIFIERS[2]}" ]]; then
			compareFilesFromDirWithDir "${SOURCE_BIN_ORIGINAL}" "$value"
		elif [[ "$identifier" == "${IDENTIFIERS[3]}"   ]]; then
			compareFilesFromDirWithDir "${SOURCE_MASTER_ORIGINAL}" "$value"
			#Si es DIRIN o DIROUT veo que existan los sub
		elif [[ "$identifier" == "${IDENTIFIERS[4]}" && ! (-e "$value/ok") ]]; then
			log "${TYPES[1]}" "\t${RED}ERROR:\tEl directorio /ok no se encuentra${NC}\n \t- Path: ${value}/ok${NC}\n"
			g_files_ok=0			
		elif [[ "$identifier" == "${IDENTIFIERS[7]}" && ! (-e "$value/comisiones") ]]; then
			log "${TYPES[1]}" "\t${RED}ERROR:\tEl directorio /comisiones no se encuentra${NC}\n \t- Path: ${value}/comisiones${NC}\n"
			g_files_ok=0
		fi

		
	else
		log "${TYPES[1]}" "${RED}ERROR:\tEl directorio $identifier no se encuentra${NC}\n - Path: ${value}${NC}\n"		
		g_files_ok=0
	fi
}

function verifyInstallationDirFiles(){
	#Verifica files de so7508 (no se si importa que esten, podria ser un warning)
	#.conf debe existir porque es lo primero que se verifica
	log "${TYPES[0]}" "\n${GREEN}${TITLE} VERIFICANDO ARCHIVOS EN so7508 ${TITLE}${NC}\n"
	files=("instalarTP.sh" "instalarTP.log" "instalarTP.conf" "iniciarambiente.log" "pprincipal.log")
	for i in ${!files[@]}; do
		if [[ -e "${PARENT_PATH}/${files[i]}" ]]; then
			log "${TYPES[0]}" "${GREEN}OK: ${files[i]}${NC}\n" 
		else
			log "${TYPES[1]}" "${YELLOW}WARNING: ${files[i]} no existe${NC}\n - Path:${PARENT_PATH}/${files[i]}\n"
		fi
	done
}

function verifyInstallation(){
	index=0;
	log "${TYPES[0]}" "\n${GREEN}${TITLE} VERIFICANDO ARCHIVO DE CONFIGURACION $TITLE${NC}\n"
	while read -r LINE; do
		#Lee solo los primeros 8 registros
		if [[ index -lt ${#IDENTIFIERS[@]} ]]; then
			readConfigFileLine "$LINE" $index
			((index++))
		else
			log "${TYPES[0]}" "${LINE}\n"
		fi
	done < "$CONFIG_PATH"
	if [[ g_files_ok -ne $OK ]]; then
		log "${TYPES[1]}" "${RED}RESULTADO VERIFICACION:\tHay uno o varios directorios/archivos faltantes${NC}"
	fi
	verifyInstallationDirFiles
		
}

function isInstalled(){
	#Existe el instalarTP.conf?
	if [ -e "$CONFIG_PATH" ]
	then 
		log "${TYPES[0]}" "${GREEN}OK: $CONFIG_PATH${NC}"
		isInstalled_return=$OK
	else 
		log "${TYPES[1]}" "${YELLOW}$CONFIG_PATH no existe${NC}"
	fi
}


INVALID_CHARS='!"#$%&/()=?¡@{}[]\ '
###Instalacion
function isNameValid(){
	if [[ `expr index "$INVALID_CHARS" "$1"` -gt 0 ]]; then
		log "${TYPES[1]}" "No se permiten el uso de los siguientes caracteres especiales: $INVALID_CHARS "
		false
	else
		true
	fi
}

function inputDirectoryName(){
	if [[ $# -ne 3 ]]; then
		log "${TYPES[2]}" "Se pasaron menos de 3 argumentos, argumentos recibidos dir:$1, info:$2, indice:$3"
		exit 1
	fi
	
	default_dir_name=$1
	input_dir_name=$1
	valid_input=0
	
	non_permitted_names=(${RESERVED_NAMES[@]} ${installation_directories[@]})			
	while [[ "${valid_input}" -eq 0 ]]; do
		log "${TYPES[0]}" "$2: ${GREEN}$default_dir_name${NC}"
		read -r input_dir_name
		log "${TYPES[0]}" "${input_dir_name}"
		if isNameValid "${input_dir_name}"; then
			if [[ "$input_dir_name" == "" ]]; then
				input_dir_name=$1
				valid_input=1
			elif [[ ${#input_dir_name} -lt 1 ]]; then
				log "${TYPES[1]}" "Debe tener mas de un caracter"
			else
				valid_input=1
				for i in "${!non_permitted_names[@]}"; do
						if [ "${non_permitted_names[i]}" == "$input_dir_name" ]; then
							log "${TYPES[1]}" "${YELLOW}¡No puede utilizar un nombre reservado!${NC}"
							#La lista de nombres se toman como parametros, rompiendo con el diseño
							log "${TYPES[1]}" "${YELLOW}Nombres reservados: ${non_permitted_names[*]}${NC}"
							valid_input=0
						fi
				done
			fi
		else
			valid_input=0;
		fi
		
	done

	#Reemplazo el default por el dado por el usuario
	installation_directories[$3]="${input_dir_name}"
}

function copyAllFilesFromTo(){
	#TODO: Ojo que logError tambien captura el verbose ya que va a stdout
	from="$1"
	to="$2"
	cp -v "${from}"/* "${to}" 2>&1 | logPipe
}

function makeDirIfItDoesntExist(){
	if ! [[ (-e "$1") && (-d "$1") ]]; then
		mkdir -v "$1" 2>&1 | logPipe
	fi
}

function finishInstallation(){
	#En este momento estoy en $GRUPO
	for i in ${!installation_directories[@]}; do
		makeDirIfItDoesntExist "${installation_directories[i]}"
	done

	#Subdirectorio /ok
	PATH_NOVEDADES_ACEPTADAS="${installation_directories[2]}/ok"
	makeDirIfItDoesntExist "$PATH_NOVEDADES_ACEPTADAS" 

	#subdirectorio /comisiones
	PATH_COMISIONES="${installation_directories[5]}/comisiones"
	makeDirIfItDoesntExist "$PATH_COMISIONES"
	
	#Copio los archivos a /bin y a /master
	copyAllFilesFromTo "${SOURCE_BIN_ORIGINAL}" "${GRUPO}/${installation_directories[0]}"
	copyAllFilesFromTo "${SOURCE_MASTER_ORIGINAL}" "${GRUPO}/${installation_directories[1]}"

	msg="REPARADA"
	if [[ "$1" == "instalacion" ]]; then
		msg="COMPLETADA"
	fi

	log "${TYPES[0]}" "${GREEN}Estado de la instalacion:\t${msg}${NC}"

	#return
	echo $OK
}

function handleUserConfirmation(){
	log "${TYPES[0]}" "¿Confirma la $1? (SI-NO)"
	read -r ANSWER
	case "${ANSWER}" in
		[sS] | [sS][iI])
			finishInstallation "$1"
		;;
		[nN] | [nN][oO])
			log "${TYPES[0]}" "$1 cancelada"
		;;
	*)
		log "${TYPES[0]}" "Favor de ingresar s/si o n/no"
		;;
	esac
}

function installationConfirmation(){
	log "${TYPES[0]}" "TP1 SO7508 2° Cuatrimestre 2020 Curso Martes Copyright @ Grupo 4" 
	log "${TYPES[0]}" "Tipo de proceso:\t$1"
	log "${TYPES[0]}" "Directorio Padre:\t$GRUPO"
	log "${TYPES[0]}" "Ubicación script de instalación:\t$GRUPO/so7508/instalarTP.sh"
	log "${TYPES[0]}" "Log de la instalacion:	$GRUPO/so7508/instalarTP.log"
	log "${TYPES[0]}" "Archivo de configuracion:\t$GRUPO/so7508/instalarTP.conf"
	log "${TYPES[0]}" "Log de la inicializacion:\t$GRUPO/so7508/iniciarambiente.log"
	log "${TYPES[0]}" "Log del proceso principal:\t$GRUPO/so7508/pprincipal.log"
	for i in ${!DIRECTORIES_INFO[@]}; do		
		log "${TYPES[0]}" "${DIRECTORIES_INFO[i]}:\t${GRUPO}/${installation_directories[i]}"
	done
	log "${TYPES[0]}" "Estado de la $1:\tLISTA"
	
}

#Camino de instalacion
function installation(){
	log "${TYPES[0]}" "${GREEN}${TITLE} Proceso de instalacion ${TITLE}${NC}"
	log "${TYPES[0]}" "Escriba el nombre del directorio, para aceptar el por defecto presione ENTER"
	#El argumento default debe actualizarse en el caso de que el user cancele la instalacion con el ultimo valor que puso
	for (( j = 0; j < 6; j++ )); do
		inputDirectoryName "${installation_directories[j]}" "${DIRECTORIES_INFO[j]}" $j #Al pasar i se que elemento sobrescribir
	done
}

function repair(){
	installationConfirmation "REPARACION"
	installation_ok=0
	installation_ok=$(handleUserConfirmation "reparacion")
	if [[ installation_ok -eq $OK ]]; then
		createConfigFile "REPARACION"
	fi
}

function handleUserInput(){
	log "${TYPES[0]}" "Instalar o Salir? I/S"
	read -r ANSWER
	case "${ANSWER}" in
		[iI] | [iI][nN][sS][tT][aA][lL][lL][aA][rR])
			echo "${INSTALL}"
		;;
		[sS] | [sS][aA][lL][iI][rR])
			exit 0
		;;
	*)
		log "${TYPES[0]}" "Favor de ingresar I/Install or S/Salir"
		;;
	esac
}

######Funciones para .conf#########

function createConfigFile(){
	#Crea nuevo, > es un overwrite
	> "$CONFIG_PATH"
	addRegister "$CONFIG_PATH" "${IDENTIFIERS[0]}" "${GRUPO}"
	addRegister "$CONFIG_PATH" "${IDENTIFIERS[1]}" "${GRUPO}/so7508"
	for i in "${!installation_directories[@]}";do
		identifier_index=$((i + 2))
		addRegister "$CONFIG_PATH" "${IDENTIFIERS[identifier_index]}" "${GRUPO}/${installation_directories[i]}"
	done
	appendAdditionalInfo "$1"
}

function appendAdditionalInfo(){
	DATE=$(date "+%D %T")
	addRegister "$CONFIG_PATH" "$1" "$DATE" "$USER"
}

##############main#####################
#Estoy en so7508
cd "${PARENT_PATH}"

#Subo a $GRUPO
cd "../"
GRUPO=$(pwd)

SOURCE_BIN_ORIGINAL="${GRUPO}/original/or_bin"
SOURCE_MASTER_ORIGINAL="${GRUPO}/original/or_master"


log "${TYPES[0]}" "\n${GREEN}${TITLE} EJECUTANDO INSTALADOR instalarTP.sh ${TITLE}${NC}\n"

#Esta instalado?
isInstalled_return=0
isInstalled
#Si esta instalado verificado que este correcto
if [[ $isInstalled_return -eq $OK ]]; then
	g_files_ok=$OK
	verifyInstallation
	if [[ g_files_ok -eq $OK ]]; then
		log "${TYPES[0]}" "${GREEN}Sistema se encuentra instalado correctamente, saliendo...${NC}"
	else	
		repair
		#si otra vez salta un error, desisto y le informo al usuario
		g_files_ok=$OK
		if [[ installation_ok -eq $OK ]]; then
			verifyInstallation
		fi
		if [[ g_files_ok -ne $OK ]]; then
			log "${TYPES[1]}" "${RED}No se ha podido reparar el sistema, recomendamos hacer una instalacion limpia, para eso debe borrar el archivo ${CONFIG_PATH} y volver a ejecutar este script${NC}"
		fi
	fi
else
	#No esta instalado
	response="$(handleUserInput)"
	#SC2091 $(..) is for capturing and not for executing.
	if [[ "${response}" == "${INSTALL}" ]]; then
		installation_ok=0
		while [[ installation_ok -eq 0 ]]; do
			installation
			installationConfirmation "INSTALACION"
			installation_ok=$(handleUserConfirmation "instalacion")
		done
		#Creo archivo de configuracion
		createConfigFile "INSTALACION"
	else
		log "${TYPES[0]}" "Saliendo del instalador"
		exit 1
	fi
fi

