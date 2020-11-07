#!/bin/bash

############################
### Variables ambiente (vienen definidas)
############################
# Directorio padre: $GRUPO
# Ubicación script de instalación: $GRUPO/so7508/instalarTP.sh
# Log de la instalación: $GRUPO/so7508/instalarTP.log
# Archivo de configuración: $GRUPO/so7508/instalarTP.conf
# Log de la inicialización: $GRUPO/so7508/inicarambiente.log
# Log del proceso principal: $GRUPO/so7508/pprincipal.log
# Directorio de ejecutables: $GRUPO/bin
# Directorio de tablas maestras: $GRUPO/master
DIRMAESTRO="../master"
# Directorio de novedades: $GRUPO/input
DIRINPUT="../input"
# *Directorio novedades aceptadas: $GRUPO/input/ok
DIRINPUTOK="../input/ok"
# Directorio de rechazados: $GRUPO/rechazos
DIRRECHAZO="../rechazos"
# Directorio de lotes procesados: $GRUPO/lotes
# Directorio de transacciones: $GRUPO/output
# **Directorio de comisiones: $GRUPO/output/comisiones

#VERIFICO QUE ESTE INICIALIZADO
#Valido que las variables de entorno hayan sido inicializadas
# if [[ -z ${vaAmbiente+x} ]]; then
# 	echo "vaAmbiente no inicializadas"
# 	exit
# fi

############################

#Definir variables de la rutina
#TIEMPODORMIDO=unminuto
ARCHIVOCOMERCIOS="$DIRMAESTRO/comercios.txt"
#Definir constantes (mensajes, log..)

#Contar ciclos
#  Inicializar el ciclo del proceso en 1. Ir sumando uno cada vez que se repite un ciclo.
#  Grabar en log “voy por el ciclo xx”

############################

# Demonio (2do plano. arrancar y frenar proceso)

# Acepta archivos(novedades aceptadas). filtro archivos duplicados
# Cuando se clasificaron las novedades en aceptadas y rechazadas,
# Se inicia la apertura y lectura de las novedades aceptadas (otro paso)
#   Control del registro TFH
#   Control de Registros TFD
#   Registros TFC - compensación
# 	    Salida 1 – Grabar el archivo de liquidaciones
# 	    Salida 2 – Grabar el archivo de comisiones (Calcular el service charge)
#           Diseño del archivo de Comisiones
# Contadores
# Cuando se termina el ciclo, el proceso principal duerme un minuto y se reinicia.


############################
#### Acepta archivos(novedades aceptadas)
############################

# *Lectura de novedades
# Leer los nombres de los archivos que están en el directorio de input (variable de ambiente) y si hay algún archivo ver si el archivo es aceptable
# Si no hay nada dormir un tiempo x= un minuto y volver a empezar

# *Condiciones de aceptabilidad
# Que el nombre del archivo este correcto, si no es correcto no es aceptable
# Que el archivo no este duplicado, si vino duplicado no es aceptable
# Que el archivo no este vacío, si está vacío no es aceptable
# Que sea un archivo regular, de texto, legible (si es otra cosa por ejemplo una imagen, no es aceptable)

# *¿Qué se hace cuando un archivo no es aceptable?
# Por regla general del TP nada se borra.
# Los archivos inaceptables se mueven tal como vienen al repositorio de rechazados
# Siempre grabar en el log el nombre del archivo rechazado y bien en claro el motivo del rechazo

# *¿Cuándo el nombre del archivo es correcto?
# El formato correcto para los nombres de los archivos de novedades es:
# • C<MerchantCode>_Lote<BatchNumber>
# 	o Ejemplo: C34567902_Lote0023
# • El MerchantCode debe existir en la tabla maestra de comercios
# • Para simplificar las pruebas solo se requiere que el número de lote sea un numero de 4 dígitos

# ****Diseño del registro de comercios
# Tabla maestra de comercios: $DIRMAE/comercios.txt
# Separador de campos: , (coma)

# -¿Cómo se determina que un archivo está duplicado?
# Si en el directorio de procesados tenemos un archivo con nombre igual al recién llegado, este ultimo se lo considera duplicado.
# -¿Qué se hace cuando un archivo es aceptable?
# Los archivos aceptables se mueven tal como vienen al repositorio de novedades aceptadas.
# Siempre grabar en el log el nombre del archivo aceptado.

#cumple mando a $DIRINPUTOK, sino a $DIRRECHAZO
OK=1

for novedades in `ls -p $DIRINPUT | grep -v /`; do
    # Que el nombre del archivo este correcto, si no es correcto no es aceptable
        # • C<MerchantCode>_Lote<BatchNumber> o Ejemplo: C34567902_Lote0023
        # • El MerchantCode debe existir en la tabla maestra de comercios
        # • Para simplificar las pruebas solo se requiere que el número de lote sea un numero de 4 dígitos
    # Que el archivo no este duplicado, si vino duplicado no es aceptable
        # Si en el directorio de procesados tenemos un archivo con nombre igual al recién llegado, este ultimo se lo considera duplicado.
    # Que el archivo no este vacío, si está vacío no es aceptable
    # Que sea un archivo regular, de texto, legible (si es otra cosa por ejemplo una imagen, no es aceptable)

    batchNumber=`echo $novedades | cut -d '_' -f2 | sed 's/Lote//' | sed 's/\.[a-z]*//'` 
    #echo $batchNumber
    batchNumberCumple=`echo $batchNumber | grep "\<[0-9][0-9][0-9][0-9]\>"`
    if [ -z $batchNumberCumple ]; then
 		echo "batchNumber INCORRECTO, $batchNumber"
        mv "$DIRINPUT/$novedades" $DIRRECHAZO
        continue
 	fi

    merchantCode=`echo $novedades | cut -d '_' -f1 | sed 's/.\{1\}//'`
    #echo $merchantCode

    #el merchantCode tiene que estar en la tabla maestra de comercios, ARCHIVOCOMERCIOS...
    reg_comercio=`grep "^$merchantCode;[^;]*;[^;]*;[^;]*$" $ARCHIVOCOMERCIOS`
    echo $reg_comercio
    if [ -z "$reg_comercio" ]; then
        #el if me pide comillas para tratar como una sola cadena..
        echo "EL MerchantCode, $merchantCode; no corresponde a un Comercio"
        mv "$DIRINPUT/$novedades" $DIRRECHAZO
        continue
    fi

    #reg_comercio devuelve registro de ARCHIVOCOMERCIOS donde ocurre merchantCode
    # if [ $OK -eq 1 ]; then
    # mv "$DIRINPUT/$novedades" $DIRINPUTOK
    # fi
    #OK=1
done

# for archivo in `ls $LLEGADA_D`; do

# 	filial=`echo $archivo | cut -d '.' -f1`
# 	fecha=`echo $archivo | cut -d '.' -f2` #aaaamm > 201710

# 	if [ $fecha -lt "201710" ]; then
# 		mv "$LLEGADA_D/$archivo" $ERROR_D
# 		continue
# 	fi

# 	#FILIAL_F: codFilial;descrFilial;direccion
# 	reg_filial=`grep "^$filial;[^;]*;[^;]*$" $FILIAL_F`

# 	if [ -z $reg_filial ]; then
# 		mv "$LLEGADA_D/$archivo" $ERROR_D	
# 		continue
# 	fi

# 	while read registro; do
# 		#leo archivo llegada
# 		#codProducto;cantidad;valor;fecha
# 		codProducto=`echo $registro | cut -d ';' -f1`

# 		reg_productos=`grep "^$codProducto;[^;]*;[^;]*$" $PRODUCTOS_F`
# 		#codigoProducto;descr;prodMinima

# 		if [ -z $reg_productos ]; then
# 			#echo $registro >> $ERROR_F
# 			mv "$LLEGADA_D/$archivo" $ERROR_D
# 			OK=0
# 			break
# 		fi

# 		if [ $1 = "-m" ]; then
# 			#chequeo produccion minima
# 			cantidad=`echo $registro | cut -d ';' -f2`
# 			prodMinima=`echo $reg_productos | cut -d ';' -f3`

# 			if [ $cantidad -le $prodMinima ]; then
# 				mv "$LLEGADA_D/$archivo" $ERROR_D
# 				OK=0
# 				break
# 			fi
# 		fi

# 	done < "$LLEGADA_D/$archivo"

# 	if [ $OK -eq 1 ]; then
# 		mv "$LLEGADA_D/$archivo" $VALIDADOS_D
# 	fi

# 	OK=1

# done


############################
#### Apertura y lectura de las novedades aceptadas
############################

# -Lectura de novedades aceptadas
# Cuando se clasificaron las novedades en aceptadas y rechazadas, se inicia la apertura y lectura de las novedades aceptadas
# -Tipos de Registros del Archivo de novedades aceptadas
# El archivo de novedades contiene dos tipos de registros
# • Un registro cabecera
# • N Registros de transacciones

# for archivo in `ls $DIRINPUTOK | grep "^[^_].*_[0-9]\{6,6\}\.dat$"`; do
#   magia
# done


############################
####    Diseño del registro cabecera (TFH)
############################
# Archivo de Novedades, Registro Cabecera
# Separador de campos: , (coma)

# -Control del registro TFH
# Si el registro de cabecera no existe, se rechaza todo el archivo
# Si el registro de cabecera indica un MERCHANT_CODE distinto al que viene en el nombre externo del archivo, se rechaza todo el archivo
# Si el registro de cabecera indica NUMBER_OF_TRX_RECORDS = 00000, se rechaza todo el archivo.
# NUMBER_OF_TRX_RECORDS nos indica cuantos registros de transacciones vienen a continuación, si esto no coincide con lo que realmente viene, se rechaza todo el archivo
# No se piden mas validaciones para el TFH pero si quiere agregarlas, indique en la autoevaluacion que incorpora.

# -Para rechazar el archivo se lo mueve tal como vino al repositorio de rechazados
# • Siempre grabar en el log el nombre del archivo rechazado y bien en claro el motivo del rechazo

############################
####    Diseño del registro de transacciones (TFD)
############################
# Archivo de Novedades, Registro de Transacciones
# Separador de campos: , (coma)

# -Control de Registros TFD
# Si el RECORD_TYPE de algún registro TFD no indica el valor TFD, se rechaza todo el archivo
# Si el RECORD_NUMBER de algún registro TFD no se corresponde con el numero de registro correcto, se rechaza todo el archivo
# Si el ID_PAYMENT_METHOD de algún registro TFD no indica un valor que existe en la tabla de tarjetas homologadas, se rechaza todo el archivo
# Si el PROCESSING_CODE de algún registro TFD no indica un valor permitido (000000 o 111111), se rechaza todo el archivo
# No se piden mas validaciones para el TFD pero si quiere agregarlas, indique en la autoevaluacion que incorpora.
# Para rechazar el archivo se lo mueve tal como vino al repositorio de rechazados
# Siempre grabar en el log el nombre del archivo rechazado y bien en claro el motivo del rechazo y en que registro se presenta la anomalía

############################
####    Registros TFC - compensación
############################
# Hay dos tipos de transacciones
# • Los débitos se identifican por el PROCESSING_CODE = 000000
# • Los créditos se identifican por el PROCESSING_CODE = 111111
# Si dentro del mismo archivo tenemos un registro de débito (compras) y un registro de crédito (anulación de la compra) con el mismo ID_TRANSACTION, y ambos tienen el mismo TRX_AMOUNT entonces esos registros se compensan

# ****Diseño del registro de tarjetas homologadas
# Tabla de Tarjetas Homologadas: $DIRMAE/tarjetashomologadas.txt
# Separador de campos: , (coma)

############################
####        Salida 1 – Grabar el archivo de liquidaciones
############################
# Grabar las transacciones que no han sido compensadas en el archivo de liquidación (SETTLEMENT FILE) correspondiente.
# Si el archivo no existe, se crea
# Si el archivo existe, se agregan los nuevos registros
# El nombre de archivo de liquidación es SETTLEMENT_FILE-año-mes.txt, dónde
# • SETTLEMENT_FILE: este prefijo se obtiene de la tabla maestra tarjetashomologadas.txt, a partir del ID_PAYMENT_METHOD
# • Año del FILE_CREATION_DATE
# • Mes del FILE_CREATION_DATE

# ****Diseño del Archivo de liquidación
# Archivo de Liquidación:
# 	$DIROUT/VISA-aaaaa-mm.txt
# 	$DIROUT/MASTER-aaaaa-mm.txt
# 	$DIROUT/AMEX-aaaaa-mm.txt
# 	$DIROUT/SP-aaaaa-mm.txt
# Separador de campos: , (coma)
# *EJEMPLO EN EL PDF

############################
####        Salida 2 – Grabar el archivo de comisiones
############################

# Calcular el service charge de cada transacción y grabar el archivo de comisiones correspondiente.
# Si el archivo no existe, se crea
# Si el archivo existe, se agregan los nuevos registros
# El nombre de archivo de comisiones es MERCHANT_CODE_GROUP-año-mes.txt, dónde
# • MERCHANT_CODE_GROUP: este prefijo se obtiene de la tabla maestra comercios.txt, a partir del MERCHANT_CODE
# • Año del FILE_CREATION_DATE
# • Mes del FILE_CREATION_DATE

# ****Cálculo del Service charge
# 1) Determinar el monto base para el calculo
# 	El monto base para el cálculo es el TRX_AMOUNT del registro TFD
# 	En este campo, los primeros diez dígitos representan la parte entera, los siguientes 2 dígitos representan la parte decimal.
# 	Por ejemplo
# 	TRX_AMOUNT = 000000534050, el monto es $5.340,50
# 	TRX_AMOUNT = 000000007300, el monto es $73,00
# 2) Determinar la tasa aplicable a la transacción
# 	Ir a la tabla de tarjetas homologadas y obtener el registro correspondiente al ID_PAYMENT_METHOD del registro TFD
# 	Si el PROCESSING_CODE del registro TFD es 000000 obtenemos el DEBIT_RATE (Tasa de comisión para los débitos)
# 	Si el PROCESSING_CODE del registro TFD es 111111 obtenemos el CREDIT_RATE (Tasa de comisión para los créditos)
# 	En este campo, los primeros dos dígitos representan la parte entera, los siguientes 4 dígitos representan la parte decimal.
# 	Por ejemplo
# 	DEBIT_RATE = 010000, la tasa es del 1,0000 %
# 	CREDIT_RATE = 005000, la tasa es del 0,5000 %
# 3) Calcular el service charge
# 	A = TRX_AMOUNT / 100: para obtener el monto con 2 dígitos decimales
# 	B = RATE / 10000: para obtener el rate con 4 dígitos decimales
# 	C = B / 100: para obtener el coeficiente de calculo
# 	D = A * C: para obtener el monto del service charge
# 	E = D * 10000 y rellenar hasta completar 12 posiciones con ceros a la izquierda: para obtener el monto del service charge a grabar*
# 	* service charge a grabar: En ese campo los primeros ocho dígitos representan la parte entera, los siguientes 4 dígitos representan la parte decimal. Siempre llenar con ceros a la izquierda
# 	Por lo tanto, puede EVITAR dividir por 10000 en el paso B y multiplicar por 10000 en el paso E

# *Varios ejemplos de Service charge para operaciones de Débito y Credito (PDF)

# ****Diseño del archivo de Comisiones
# Archivo de Comisiones
# 	$DIROUT/comisiones/merchant_code_group-aaaaa-mm.txt
# Separador de campos: , (coma)
# *EJEMPLO PDF PAG 23

############################
#### Contadores
############################
# Cuando se logra procesar un archivo aceptado se debe grabar en el log
# INPUT
# Nombre del archivo procesado; Cantidad de transacciones de input
# OUTPUT
# Nombre del archivo de liquidación de output; Cantidad de transacciones de output
# Nombre del archivo de liquidación de output; Cantidad de transacciones de output
# Nombre del archivo de comisiones de output

# Ejemplo:
# 	INPUT
# 	C12345681_Lote1234; 9 registros
# 	OUTPUT
# 	VISA_Lote1234; 5 registros
# 	12345678-2020-07.txt

# ****Evitar Reprocesos
# Cuando se logra procesar un archivo aceptado se lo mueve a DIRPROC para evitar su reproceso

# ****Fin de ciclo
# Cuando se termina el ciclo, el proceso principal duerme un minuto y se reinicia.

