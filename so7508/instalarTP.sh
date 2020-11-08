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
OK=1;
INSTALL="install"
QUIT="quit"


#Nombres reservados
RESERVED_NAMES=("GrupoN" "so7508" "original" "catedra" "propios" "testeos");
DIRECTORIES_INFO=("Directorio de ejecutables" "Directorio de tablas maestras" "Directorio de novedades" "Directorio de rechazados" "Directorio de lotes procesados" "Directorio de transacciones");

#NOTA: pide que recuerde los valores nuevos en el caso de cancelar la instalacion
installation_directories=("bin" "master" "input" "rechazos" "lotes" "output");
IDENTIFIERS=("GRUPO" "DIRINST" "DIRBIN" "DIRMAE" "DIRIN" "DIRRECH" "DIRPROC" "DIROUT");

#Siempre parent_path va a ser so7508, que es donde esta este Script
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit ; pwd -P );

CONFIG_PATH="so7508/instalarTP.conf";
SEPARATOR="-"


###Verificar Instalacion

function readIdentificationRegister(){
	#TODO: faltan verificar los subdirectorios
	g_files_ok=1;
	identifier=$(echo "$1" | sed 's;\(.*\)-\(.*\);\1;');
	value=$(echo "$1" | sed 's;\(.*\)-\(.*\);\2;');
	
	#Verifica que el valor leido exista, sea un directorio, 
	#que el identificador coincida en orden
	if [[ -e "$value" && (-d "$value") && ("${IDENTIFIERS[$2]}" == "$identifier") ]]; then
		echo -e "${GREEN}OK: ${identifier}\n${NC}";
	else
		echo -e "${RED}ERROR:\tEl directorio $identifier no se encuentra${NC}"
		echo -e "\t${ORANGE}Path: $value${NC}\n"
		g_files_ok=0;
	
	fi
}

function verifyConfigFiles(){
	#Verifica files de so7508 (no se si importa que esten, podria ser un warning)
	#.conf debe existir porque es lo primero que se verifica
	echo -e "${GREEN}${TITLE}VERIFICANDO ARCHIVOS EN so7508${TITLE}${NC}"
	so7508_path="${GRUPO}/so7508/";
	files=("instalarTP.sh" "instalarTP.log" "instalarTP.conf" "iniciarambiente.log" "pprincipal.log");
	for i in ${!files[@]}; do
		if [[ -e "${so7508_path}${files[i]}" ]]; then
			echo -e "${GREEN}OK: ${files[i]}${NC}"
		else
			echo -e "${YELLOW}WARNING: ${files[i]} no existe${NC}";
			echo -e "\t${YELLOW} - Path:${NC}${so7508_path}${files[i]}"
		fi
	done
}

function readConfigFile(){
	index=0;
	echo -e "\n${GREEN}${TITLE} VERIFICANDO ARCHIVO DE CONFIGURACION $TITLE${NC}\n"
	while read -r LINE; do
		#Lee solo los primeros 8 registros
		if [[ index -lt ${#IDENTIFIERS[@]} ]]; then
			readIdentificationRegister "$LINE" $index;
			((index++));
		else
			echo -e "${LINE}\n";
		fi
	done < "$CONFIG_PATH"
	if [[ g_files_ok -ne $OK ]]; then
		echo -e "${RED}ERROR:\tHay uno o varios directorios faltantes${NC}"
	fi
	verifyConfigFiles
		
}

function isInstalled(){
	#Existe el instalarTP.conf?
	if [ -e "$CONFIG_PATH" ]
	then 
		echo -e "${GREEN}$CONFIG_PATH existe${NC}"
		isInstalled_return=$OK;
	else 
		echo -e "${YELLOW}$CONFIG_PATH no existe${NC}"
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
		echo "$2: ${GREEN}$default_dir_name${NC}"
		read -r input_dir_name;	
		if [[ "$input_dir_name" == "" ]]; then
			input_dir_name=$1
			valid_input=1;
		elif [[ ${#input_dir_name} -lt 1 ]]; then
			echo "Debe tener mas de un caracter"
		else
			valid_input=1;
			for i in "${!non_permitted_names[@]}"; do
					if [ "${non_permitted_names[i]}" == "$input_dir_name" ]; then
						echo "No puede utilizar un nombre reservado"
						echo "Nombres reservados: ${non_permitted_names[@]}"
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
		mkdir "${installation_directories[i]}"
	done

	#Subdirectorio /ok
	PATH_NOVEDADES_ACEPTADAS="${installation_directories[2]}/ok"
	mkdir "$PATH_NOVEDADES_ACEPTADAS"; 

	#subdirectorio /comisiones
	PATH_COMISIONES="${installation_directories[5]}/comisiones"
	mkdir "$PATH_COMISIONES";

	echo $OK;
}

function handleUserConfirmation(){
	read -r -p "¿Confirma la instalacion? (SI-NO)" ANSWER;
	case "${ANSWER}" in
		[sS] | [sS][iI])
			finishInstallation
		;;
		[nN] | [nN][oO])
			echo 0
		;;
	*)
		echo "Favor de ingresar s/si o n/no"
		;;
	esac
}

function installationConfirmation(){
	echo "TP1 SO7508 2° Cuatrimestre 2020 Curso Martes Copyright @ Grupo N";
	echo -e "Tipo de proceso:\tINSTALACION"
	echo -e "Directorio Padre:\t$GRUPO"
	echo -e "Ubicación script de instalación:\t$GRUPO/so7508/instalarTP.sh";
	echo -e "Log de la instalacion:	$GRUPO/so7508/instalarTP.log";
	echo -e "Archivo de configuracion:\t$GRUPO/so7508/instalarTP.conf";
	echo -e "Log de la inicializacion:\t$GRUPO/so7508/inicarmbiente.log";
	echo -e "Log del proceso principal:\t$GRUPO/so7508/pprincipal.log";
	for i in ${!DIRECTORIES_INFO[@]}; do		
		echo -e "${DIRECTORIES_INFO[i]}:\t${installation_directories[i]}";
	done
	
}

#Camino de instalacion
function installation(){
	echo -e "${GREEN}${TITLE} Proceso de instalacion ${TITLE}${NC}"
	echo "Escriba el nombre del directorio, para aceptar el por defecto presione ENTER"
	#El argumento default debe actualizarse en el caso de que el user cancele la isntalacion con el ultimo valor que puso
	for (( j = 0; j < 6; j++ )); do
		inputDirectoryName "${installation_directories[j]}" "${DIRECTORIES_INFO[j]}" $j; #Al pasar i se que elemento sobrescribir
	done
}


#Como todos son archivos, el echo funciona como un return si lo redirigo de la stdin
function handleUserInput(){
	read -r -p "Instalar o Salir? I/S" ANSWER
	case "${ANSWER}" in
		[iI] | [iI][nN][sS][tT][aA][lL][lL])
			echo "${INSTALL}";
		;;
		[sS] | [sS][aA][lL][iI][rR])
			exit 0;
		;;
	*)
		echo "Favor de ingresar I/Install or S/Salir"
		;;
	esac
}

######Funciones para .conf#########

function addRegister(){
	#Esta funcion registro modular, deberia servir para cualquier caso
	register="";
	fields=("$@");
	
	for i in ${!fields[@]}; do
		register+="${fields[i]}$SEPARATOR"
	done

	#Quito el ultimo char
	end=$((${#register}-1));
	echo "${register:0:${end}}" >> "$CONFIG_PATH";	
}


function createConfigFile(){
	#Crea nuevo, > es un overwrite
	> "$CONFIG_PATH";
	addRegister "${IDENTIFIERS[0]}" "${GRUPO}";
	addRegister "${IDENTIFIERS[1]}" "${GRUPO}/so7508";	
	for i in "${!installation_directories[@]}";do
		identifier_index=$((i + 2));
		addRegister "${IDENTIFIERS[identifier_index]}" "${GRUPO}/${installation_directories[i]}";
	done
	appendAdditionalInfo "INSTALACION"
}

function appendAdditionalInfo(){
	#TODO: comando date, saber el nombre del user
	DATE=$(date "+%D %T");
	addRegister "$1" "$DATE" "$USER";
}

##############main#####################
#Estoy en so7508
cd "${PARENT_PATH}";

#Subo a $GRUPO
cd "../"
GRUPO=$(pwd);

#Aca empiezo a instalar los Directorio ejecutable, tablas etc.
echo -e "${GREEN}${TITLE} Bienvenido al instalador ${TITLE}${NC}";

isInstalled_return=0;
isInstalled;
#Si esta instalado verificado que este correcto
if [[ $isInstalled_return -eq $OK ]]; then
	g_files_ok=0;	
	readConfigFile;
	if [[ g_files_ok -eq $OK ]]; then
		echo -e "${GREEN}Sistema se encuentra instalado correctamente, saliendo${NC}"
		exit 0;
	else
		echo -e "${DEBUG}TODO: Verificar si se puede reparar${NC}"
	fi
fi

echo "Que desea hacer?"
response="$(handleUserInput)";

#SC2091 $(..) is for capturing and not for executing.
#TODO: Eliminar opcion de reparacion, solo aparece cuando
#ya esta instalado pero con errores.
if [[ "${response}" == "${INSTALL}" ]]; then
	installation_ok=0;
	while [[ installation_ok -eq 0 ]]; do
		installation;
		installationConfirmation;
		installation_ok=$(handleUserConfirmation);
	done
	#Creo archivo de configuracion
	createConfigFile
else
	echo "Saliendo"
	exit 1;
fi

