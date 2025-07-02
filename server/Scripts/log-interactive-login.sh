#!/bin/bash

# Leer JSON desde stdin
read raw_input

# Extraemos eventID y logonType

input=$(echo "$raw_input" | sed 's/"message":""[^"]*""/"message":""/g') # Limpiamos esta parte para evitar problemas de parseo

eventID=$(echo "$input" | jq -r '.parameters.alert.data.win.system.eventID')
logonType=$(echo "$input" | jq -r '.parameters.alert.data.win.eventdata.logonType')
targetUser=$(echo "$input" | jq -r '.parameters.alert.data.win.eventdata.targetUserName')
read login_timestamp < <(cut -f1 /var/ossec/tmp/saved_timestamp)

# Verificar condiciones. Se comprueba que el evento es correcto y que no hay ningún timestamp guardado
if [[ "$eventID" == "4624" && "$logonType" == "2" && ( ! -f /var/ossec/tmp/saved_timestamp || "$login_timestamp" == "0" ) ]]
then
    # Extraemos la fecha en ISO 8601
    date=$(echo "$input" | jq -r '.parameters.alert.timestamp')
    echo "Timestamp válido: $date. EvenID: $eventID, logon: $logonType" >> /var/ossec/tmp/logs_recibidos_login
    
    # Extraer partes: fecha base y milisegundos
    date_b="${date:0:19}"        
    ms="${date:20:3}"      
    zone="${fecha:23}"                

    # Convertir fecha base a timestamp
    timestamp_in=$(date -d "$date_b $zone" +%s)

    # Calcular timestamp en milisegundos
    timestamp=$((timestamp_in * 1000 + 10#$ms))

    # Se guarda preparado para ser parseado por el script de logout
    echo -e "$timestamp\t$targetUser" > /var/ossec/tmp/saved_timestamp
fi


