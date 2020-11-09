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
DIRLOTES="../lotes"
# Directorio de transacciones: $GRUPO/output
DIROUT="../output"
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
ARCHIVOTJTHOMOLOGADAS="$DIRMAESTRO/tarjetashomologadas.txt"
DEBITO="000000"
CREDITO="111111"
#                                       DOCUMENTAR CARPETA TMP
DIRLIQUIDACIONTEMPORAL="$DIRINPUT/tmp/liquidaciones/"
DIRCOMISIONES="$DIROUT/comisiones/"
DIRCOMISIONESTEMPORAL="$DIRINPUT/tmp/comisiones/"
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

borrarTmp() {
    #limpio carpeta TMP de liquidaciones. Borro y creo
    rm -r $DIRLIQUIDACIONTEMPORAL
    mkdir $DIRLIQUIDACIONTEMPORAL
    rm -r $DIRCOMISIONESTEMPORAL
    mkdir $DIRCOMISIONESTEMPORAL
}
 
for novedades in `ls -p $DIRINPUT | grep -v /`; do
    #Verifico que el archivo a procesar no este vacio
    if [ ! -s "$DIRINPUT/$novedades" ]; then
        echo "El archivo $novedades esta vacio, NO ES ACEPTABLE"
        mv "$DIRINPUT/$novedades" $DIRRECHAZO
        continue
    fi

    #Validar que es un archivo regular, de texto, legible
    # if [ ! -f "$DIRINPUT/$novedades" ]; then
    #     echo "El archivo $novedades , NO ES UN ARCHIVO REGULAR"
    #     #mv "$DIRINPUT/$novedades" $DIRRECHAZO
    #     continue
    # fi

    # if [ ! -r "$DIRINPUT/$novedades" ]; then
    #     echo "El archivo $novedades , NO SE PUEDE LEER"
    #     #mv "$DIRINPUT/$novedades" $DIRRECHAZO
    #     continue
    # fi
    #ESTO CUMPLE EL PUNTO DE LEGIBLE. -f es si existe, -r es si es readable (no corta con ese)
    if [ ! "$(file $DIRINPUT/$novedades)" = "$DIRINPUT/$novedades: ASCII text" ]; then
        echo "El archivo $novedades es ilegible, NO ES ACEPTABLE"
        mv "$DIRINPUT/$novedades" $DIRRECHAZO
        continue
    fi
    #igual que arriba pero con regex.. ???
    #if [[ ! "$(file "$DIRINPUT/$novedades")" =~ ': ASCII text'$ ]]; then
    #    echo $DIRINPUT/$novedades no es legible
    #fi

    # Si en el directorio de procesados tenemos un archivo con nombre igual al recién llegado, este ultimo
    # se lo considera duplicado.
    if [ -f "$DIRLOTES/$novedades" ]; then
        echo "El lote $novedades ya fue procesado"
        mv "$DIRINPUT/$novedades" $DIRRECHAZO
        continue
    fi

    # El número de lote sea un numero de 4 dígitos
    batchNumber=`echo $novedades | cut -d '_' -f2 | sed 's/Lote//' | sed 's/\.[a-z]*//'` 
    batchNumberCumple=`echo $batchNumber | grep "\<[0-9][0-9][0-9][0-9]\>"`
    if [ -z $batchNumberCumple ]; then
 		echo "batchNumber $batchNumber, INCORRECTO"
        mv "$DIRINPUT/$novedades" $DIRRECHAZO
        continue
 	fi

    # El MerchantCode debe existir en la tabla maestra de comercios
    merchantCode=`echo $novedades | cut -d '_' -f1 | sed 's/.\{1\}//'`
    reg_comercio=`grep "^$merchantCode;[^;]*;[^;]*;[^;]*$" $ARCHIVOCOMERCIOS`
    if [ -z "$reg_comercio" ]; then
        #el if me pide comillas para tratar como una sola cadena..
        echo "EL MerchantCode, $merchantCode; no corresponde a un Comercio"
        mv "$DIRINPUT/$novedades" $DIRRECHAZO
        continue
    fi

    ############################
    #### Apertura y lectura de las novedades aceptadas
    ############################

    # -Lectura de novedades aceptadas
    # Cuando se clasificaron las novedades en aceptadas y rechazadas, se inicia la apertura y lectura de las novedades aceptadas
    # -Tipos de Registros del Archivo de novedades aceptadas
    # El archivo de novedades contiene dos tipos de registros
    # • Un registro cabecera (TFH)
    # • N Registros de transacciones (TFD)

    esCabecera=1
    lineaLeida=0
    #########para agregar una validacion nuestra..
    ##chequeo que el RECORD_NUMBER de TFH coincida con el numero 1 (lectura inicial)
    ##como pasa con la validacion de TFD
    ##no pude meterlo en la regex del grep

    while read registroNovedad; do
        #EMPIEZO A LEER LAS NOVEDADES
        lineaLeida=`expr $lineaLeida + 1`
        
        if [ $esCabecera -eq 1 ]; then
     		#leo registro 1 -> TFH (dice cuantos tfd vienen)
            ############################
            ####    Diseño del registro cabecera (TFH)
            ############################
            # • Siempre grabar en el log el nombre del archivo rechazado y bien en claro el motivo del rechazo
            #RECORD_TYPE;RECORD_NUMBER;MERCHANT_CODE_;BATCH_NUMBER;FILE_CREATION_DATE;FILE_CREATION_TIME;NUMBER_OF_TRX_RECORDS

            # Si el registro de cabecera no existe, se rechaza todo el archivo
            # Si el registro de cabecera indica un MERCHANT_CODE distinto al que viene en el nombre externo del archivo, se rechaza todo el archivo
            cabecera=`echo $registroNovedad | grep "^TFH;[^;]*;$merchantCode;[^;]*;[^;]*;[^;]*;[^;]*;;;;;;;$"`
            if [ -z "$cabecera" ]; then
                echo "Error en registro de cabecera. El archivo $novedades NO ES ACEPTABLE"
                borrarTmp
                mv "$DIRINPUT/$novedades" $DIRRECHAZO
                break
            fi

            # Si el registro de cabecera indica NUMBER_OF_TRX_RECORDS = 00000, se rechaza todo el archivo.
            numberTrxRecords=`echo $registroNovedad | cut -d ';' -f7`
            if [ $numberTrxRecords -eq 0 ]; then
                echo "NUMBER_OF_TRX_RECORDS = 0. El archivo $novedades NO ES ACEPTABLE"
                borrarTmp
                mv "$DIRINPUT/$novedades" $DIRRECHAZO
                break
            fi

            # NUMBER_OF_TRX_RECORDS nos indica cuantos registros de transacciones vienen a continuación, si esto no coincide con lo que realmente viene, se rechaza todo el archivo
            cantRegNovedades=`wc -l < "$DIRINPUT/$novedades"`
            cantRegTFDNovedades=`expr $cantRegNovedades - 1`
            if [ $cantRegTFDNovedades -ne $numberTrxRecords ]; then
                echo "NUMBER_OF_TRX_RECORDS inconsistente. El archivo $novedades NO ES ACEPTABLE"
                borrarTmp
                mv "$DIRINPUT/$novedades" $DIRRECHAZO
                break
            fi
            
            esCabecera=0
            #chequear que se setee bien este flag de cabeceras cuando rompe
        else
            ############################
            ####    Diseño del registro de transacciones (TFD)
            ############################
            # RECORD_TYPE;RECORD_NUMBER;ID_TRANSACTION;APPROVAL_CODE;ID_PAYMENT_METHOD:PAN_FIRST_SIX;PAN_LAST_FOUR;CARD_EXP_DATE;TRX_CREATION_DATE;TRX_CREATION_TIME;TRX_AMOUNT;PROCESSING_CODE;TRX_CURRENCY_CODE;TICKET_NUMBER
            # Para rechazar el archivo se lo mueve tal como vino al repositorio de rechazados
            # Siempre grabar en el log el nombre del archivo rechazado y bien en claro el motivo del rechazo y en que registro se presenta la anomalía

            # Si el RECORD_TYPE de algún registro TFD no indica el valor TFD, se rechaza todo el archivo
            transaccionOk=`echo $registroNovedad | grep -c "^TFD;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$"`
            if [ $transaccionOk -ne 1 ]; then
                echo $registroNovedad
                echo "Error RECORD_TYPE en registro de transaccion. El archivo $novedades NO ES ACEPTABLE"
                borrarTmp
                mv "$DIRINPUT/$novedades" $DIRRECHAZO
                break
            fi

            # Si el RECORD_NUMBER de algún registro TFD no se corresponde con el numero de registro correcto, se rechaza todo el archivo
            recordNumerTransaccion=`echo $registroNovedad | cut -d ';' -f2`
            if [ `expr $recordNumerTransaccion - $lineaLeida` -ne 0 ]; then
                echo "RECORD_NUMBER inconsistente. El archivo $novedades NO ES ACEPTABLE"
                borrarTmp
                mv "$DIRINPUT/$novedades" $DIRRECHAZO
                break
            fi

            # Si el PROCESSING_CODE de algún registro TFD no indica un valor permitido (000000 o 111111), se rechaza todo el archivo
            processingCode=`echo $registroNovedad | cut -d ';' -f12`

            if [ "$processingCode" != "$DEBITO" -a "$processingCode" != "$CREDITO" ]; then
                echo "El ProcessingCode $processingCode, no indica un valor permitido"
                borrarTmp
                mv "$DIRINPUT/$novedades" $DIRRECHAZO
                break
            fi

            # Si el ID_PAYMENT_METHOD de algún registro TFD no indica un valor que existe en la tabla de tarjetas homologadas, se rechaza todo el archivo
            idPaymentMethod=`echo $registroNovedad | cut -d ';' -f5`
            reg_tjtHomologada=`grep "^$idPaymentMethod;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$" $ARCHIVOTJTHOMOLOGADAS`
            if [ -z "$reg_tjtHomologada" ]; then
                #el if me pide comillas para tratar como una sola cadena..
                echo "EL idPaymentMethod, $idPaymentMethod; no corresponde a una Tarjeta Homologada"
                borrarTmp
                mv "$DIRINPUT/$novedades" $DIRRECHAZO
                break
            fi

            #GUARDO EN ARCHIVOS TEMPORALES. SI NO ES VALIDA LA ENTRADA DESCARTO. SINO LOGUEO DEFINITIVO CUANDO TERMINA DE PROCESAR EL ARCHIVO.
            #EVITO ASI LEER DOS VECES TODOS LOS ARCHIVOS..

            ############################
            ####    Registros TFC - compensación
            ############################
            # Si dentro del mismo archivo tenemos un registro de débito (compras) y un registro de crédito (anulación de la compra) con el mismo ID_TRANSACTION, y ambos tienen el mismo TRX_AMOUNT entonces esos registros se compensan

            ##EMPIEZO AQUI CICLO COMPENSACION
            ##CHEQUEAR QUE EL NUEVO CICLO SEA CORRECTO ??? como es el match ???.

            ##compenso las de igual ID_TRANSACTION. El archivo esta desordenado.
            ##las de != ID_TRANSACTION se graban en el archivo liquidacion SETTLEMENT FILE correspondiente

            idTransaction=`echo $registroNovedad | cut -d ';' -f3`
            transactionMount=`echo $registroNovedad | cut -d ';' -f11`
            
            rate=0
            processingCodeACompensar=0
            if [ "$processingCode" = "$DEBITO" ]; then
                processingCodeACompensar=$CREDITO
                rate=`echo $reg_tjtHomologada | cut -d ';' -f4`
            else
                processingCodeACompensar=$DEBITO
                rate=`echo $reg_tjtHomologada | cut -d ';' -f5`
            fi

            #Busco en el archivo coincidencias
            #si compensa no lo grabo. Si aparece en el archivo idTransaction y transactionMount con processingCode opuesto
            #si no compensa lo grabo.
            registroNovedadACompensar=`grep "^[^;]*;[^;]*;$idTransaction;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;$transactionMount;$processingCodeACompensar;[^;]*;[^;]*$" "$DIRINPUT/$novedades"`
            if [ -z "$registroNovedadACompensar" ]; then
                #si entra aca no compensa
                #grabo salidas de manera 'temporal' por si salta ERROR en el camino.

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

                #HAY UN ERROR EN LOS EJEMPLOS DEL EXCEL. LAS COL SETTLEMENT_FILE Y CARD_TYPE ESTAN INVERTIDOS
                #DOCUMENTAR

                #**HAY QUE USAR SEPARADOR DE CAMPOS , Y NO ; (CAMBIAR TODOS LOS ARCHIVOS, CUT Y GREP)
                
                settlementFile=`echo $reg_tjtHomologada | cut -d ';' -f6`
                #FILE_CREATION_DATE del TFH tiene formato aaaammdd
                fileCreationDateAAAAMM=`echo $cabecera |  cut -d ';' -f5 | sed 's/.\{2\}$//'`
                fileCreationDateAAAA=`echo $fileCreationDateAAAAMM | sed 's/.\{2\}$//'`
                fileCreationDateMM=`echo $fileCreationDateAAAAMM | sed 's/.\{4\}//'`
                nombreArchivoALiquidar="$settlementFile-$fileCreationDateAAAA-$fileCreationDateMM.txt"

                #FORMATO ARCHIVO LIQUIDACION
                #SE GUARDA TODO EL REGISTRO TFD, salvo col 1 que va SOURCE_FILE
                # SOURCE_FILE	Nombre del archivo de origen (sin extension)
                sourceFile=`echo $novedades | sed 's/\.[a-z]*//'`

                #SED REMPLAZO LA COL 1 de registro Novedad por SOURCE_FILE
                registroLiquidacion=`echo $registroNovedad | sed "s/^TFD/$sourceFile/"`

                #DOCUMENTAR CARPETA TMP
                echo $registroLiquidacion >> "$DIRLIQUIDACIONTEMPORAL/$nombreArchivoALiquidar"

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

                nombreArchivoComisiones="$merchantCode-$fileCreationDateAAAA-$fileCreationDateMM.txt"

                # ****Cálculo del Service charge
                # 1) Determinar el monto base para el calculo
                # 	El monto base para el cálculo es el TRX_AMOUNT del registro TFD
                # 	En este campo, los primeros diez dígitos representan la parte entera, los siguientes 2 dígitos representan la parte decimal.                

                #caracteres: primeros 10 entera, 2 decimal
                monto=`echo "scale=2; ($transactionMount/100)" | bc`

                # 2) Determinar la tasa aplicable a la transacción
                # 	Ir a la tabla de tarjetas homologadas y obtener el registro correspondiente al ID_PAYMENT_METHOD del registro TFD
                # 	Si el PROCESSING_CODE del registro TFD es 000000 obtenemos el DEBIT_RATE (Tasa de comisión para los débitos)
                # 	Si el PROCESSING_CODE del registro TFD es 111111 obtenemos el CREDIT_RATE (Tasa de comisión para los créditos)
                # 	En este campo, los primeros dos dígitos representan la parte entera, los siguientes 4 dígitos representan la parte decimal.
                # 	Por ejemplo
                # 	DEBIT_RATE = 010000, la tasa es del 1,0000 %
                # 	CREDIT_RATE = 005000, la tasa es del 0,5000 %

                #tasa de comision
                # 3) Calcular el service charge
                # 	A = TRX_AMOUNT / 100: para obtener el monto con 2 dígitos decimales
                # 	B = RATE / 10000: para obtener el rate con 4 dígitos decimales
                # 	C = B / 100: para obtener el coeficiente de calculo
                # 	D = A * C: para obtener el monto del service charge
                # 	E = D * 10000 y rellenar hasta completar 12 posiciones con ceros a la izquierda: para obtener el monto del service charge a grabar*
                # 	* service charge a grabar: En ese campo los primeros ocho dígitos representan la parte entera, los siguientes 4 dígitos representan la parte decimal. Siempre llenar con ceros a la izquierda
                # 	Por lo tanto, puede EVITAR dividir por 10000 en el paso B y multiplicar por 10000 en el paso E

                serviceCharge=`echo "scale=0; ($monto*$rate/100)" | bc`

                # ****Diseño del archivo de Comisiones
                # Archivo de Comisiones
                # 	$DIROUT/comisiones/merchant_code_group-aaaaa-mm.txt
                # SOURCE_FILE	Nombre del archivo de origen
                # SOURCE_RECORD_NUMBER	Numero de registro de origen
                # SOURCE_ID_TRANSACTION	Id de la transaccion de origen
                # SOURCE_APPROVAL_CODE	Código de Aprobación de origen
                aprobalCode=`echo $registroNovedad | cut -d ';' -f4`
                # SOURCE_ID_PAYMENT_METHOD	Id de Medio de Pago de origen                
                # tasa) RATE	Tasa de comision. Los primeros dos digitos representan la parte entera, los siguientes 4 digitos representan la parte decimal. Siempre llenar con ceros a la izquierda
                # calculo) SERVICE_CHARGE	Cargo por Servicio. Los primeros ocho digitos representan la parte entera, los siguientes 4 digitos representan la parte decimal. Siempre llenar con ceros a la izquierda                
                # tarjeta)BRAND	Marca de la Tarjeta. Siempre llenar con espacios a la derecha
                brand=`echo $reg_tjtHomologada | cut -d ';' -f2`
                # SOURCE_TRX_CREATION_DATE 	Local Transaction Date de origen
                creationTrxDate=`echo $registroNovedad |  cut -d ';' -f9`
                # SOURCE_TRX_CREATION_TIME	Local Transaction Time de origen
                creationTrxTime=`echo $registroNovedad | cut -d ';' -f10`
                # SOURCE_TRX_AMOUNT	Transaction Amount de origen
                # SOURCE_PROCESSING_CODE	Processing Code de origen
                # SOURCE_TRX_CURRENCY_CODE	Transaction Currency Code de origen
                currencyCode=`echo $registroNovedad | cut -d ';' -f13`

                #Formateo serviceCharge 12caracteres. Ceros a la izquierda
                pad=$(printf '%0.1s' "0"{1..12})
                relleno=$(printf '%*.*s' 0 $((12 - ${#serviceCharge})) "$pad")
                serviceChargeFormateado=$relleno$serviceCharge

                #documentar carpeta temporal
                echo "$sourceFile,$recordNumerTransaccion,$idTransaction,$aprobalCode,$idPaymentMethod,$rate,$serviceChargeFormateado,$brand,$creationTrxDate,$creationTrxTime,$transactionMount,$processingCode,$currencyCode" >> "$DIRCOMISIONESTEMPORAL/$nombreArchivoComisiones"
            fi
        fi
 	done < "$DIRINPUT/$novedades"
    
    esCabecera=1
    lineaLeida=0

    #CODIGO PARA PASAR LOS TEMPORALES A LAS SALIDAS DEFINITIVAS PARA ESTE ARCHIVO PROCESADO.
    #SI ESTA VACIO TMP, ES XQ HUVO ALGUN ERROR Y NO SE ACEPTO LA ENTRADA. SALE CON BREAK
    for temporal in `ls $DIRLIQUIDACIONTEMPORAL`; do
        cat $DIRLIQUIDACIONTEMPORAL/$temporal >> $DIROUT/$temporal
        rm $DIRLIQUIDACIONTEMPORAL/$temporal
    done
    for temporal in `ls $DIRCOMISIONESTEMPORAL`; do
        cat $DIRCOMISIONESTEMPORAL/$temporal >> $DIRCOMISIONES/$temporal
        rm $DIRCOMISIONESTEMPORAL/$temporal
    done

    #mover novedad a lotes procesados
    #nos salteamos dejarlos en OK... (partir el codigo)
    #De esta manera, a medida de que se leen las novedades se procesan.
    #Sino habria que armar:
        #input a OK Filtro externo
        #filtrar con sed las compensasiones
        #tratar al archivo para las salidas
    #Sino queda documentarlo.

    #mv "$DIRINPUT/$novedades" $DIRLOTES

done


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
