#! /bin/bash

#CON ARRAYS

INSTALL="install"
REPAIR="repair"

#Nombres reservado
RESERVED_NAMES=("GrupoN" "so7508" "original" "catedra" "propios" "testeos");

DIRECTORIES_INFO=("Directorio de ejecutables" "Directorio de tablas maestras" "Directorio de novedades" "Directorio de rechazados" "Directorio de lotes procesados" "Directorio de transacciones");

#Aca pongo en orden, separados por espacio, los directorios
#Caso default: "/bin /master /input /rechazos /lotes /output"
#NOTA: pide que recuerde los valores nuevos en el caso de cancelar la instalacion
installation_directories=("bin" "master" "input" "rechazos" "lotes" "output");

#Siempre parent_path va a ser so7508, que es donde esta este Script
parenth_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit ; pwd -P );
echo "$parenth_path";


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
		echo "$2 $default_dir_name"
		read -r input_dir_name;
			
		#Primero valido el input
		SLASH='/';
		first_char=${input_dir_name:0:1}
		if [[ "$input_dir_name" == "" ]]; then
			echo "DEBUG: usando opcion default"
			input_dir_name=$1
			valid_input=1;
		elif [[ ${#input_dir_name} -lt 1 ]]; then
			echo "Debe tener mas de un caracter"
		#elif [[ ! ("$first_char" == $SLASH) ]]; then
		#	echo "Debe colocar $SLASH al principio"
		#Si decidio no usar el default, chequeo que no sea reservado
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

	echo "Directorio Valido :), DEBUG: guardando en indice $3"

	#Lo agrego a la lista de usados
	installation_directories[$3]="${input_dir_name}";
}

function finishInstallation(){
	echo "<<<<<<< Finishing installation >>>>>>>>>>";
	#En este momento estoy en $GRUPO
	#for i in ${installation_directories[@]}; do
	#	mkdir "${installation_directories[i]}"
	#done

	#Subdirectorio /ok
	#PATH_NOVEDADES_ACEPTADAS="${installation_directories[2]}/ok"
	#mkdir PATH_NOVEDADES_ACEPTADAS; 

	#PATH_COMISIONES="${installation_directories[6]}/comisiones"
	#mkdir PATH_NOVEDADES_ACEPTADAS; 
}

function handleUserConfirmation(){
	echo "¿Confirma la instalacion? (SI-NO)";
	read -r ANSWER;
	case "${ANSWER}" in
		[sS] | [sS][iI])
			finishInstallation
		;;
		[nN] | [nN][oO])
			echo "${REPAIR}"
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
	handleUserConfirmation
}

#Camino de instalacion
function installation(){
	echo "<<<<<<<<<<<< Proceso de instalacion >>>>>>>>>>>>"
	#El argumento default debe actualizarse en el caso de que el user cancele la isntalacion con el ultimo valor que puso
	for (( j = 0; j < 6; j++ )); do
		inputDirectoryName "${installation_directories[j]}" "${DIRECTORIES_INFO[j]}" $j; #Al pasar i se que elemento sobrescribir
	done
	installationConfirmation
}


#Como todos son archivos, el echo funciona como un return si lo redirigo de la stdin
function handleUserInput(){
	read -r -p "Instalacion o Reparacion? I/R" ANSWER
	case "${ANSWER}" in
		[iI] | [iI][nN][sS][tT][tT][aA][lL])
			echo "${INSTALL}"
		;;
		[rR] | [rR][eE][pP][aA][iI][rR])
			echo "${REPAIR}"
		;;
	*)
		echo "Favor de ingresar I/Install or R/Repair"
		;;
	esac
}

#el chiste de esto es que si yo lo invoco desed $HOME,
# no puedo hacer un cat de los archivos de ese directorio por que mi WD esta en $HOME
# y no donde se ejecuta el script

#Estoy en so7508
cd "${parenth_path}";

#Subo a $GRUPO
cd "../"

GRUPO=$(pwd);

#Aca empiezo a instalar los Directorio ejecutable, tablas etc.
echo "<<<<<<<<<< Ejecutando instalarTP.sh >>>>>>>>>"
echo "Que desea hacer?"

response="$(handleUserInput)";

#SC2091 $(..) is for capturing and not for executing.
#SC2092: Remove backticks to avoid executing output (or use eval if intentional).
if [[ $(expr index "${response}" "${INSTALL}") -eq 1 ]]; then
	installation;
elif [[ $(expr index "${response}" "${REPAIR}") -ne 1 ]]; then
	echo "repair"
else
	echo "Exception, nunca deberia llegar aca"
	exit 1;
fi

