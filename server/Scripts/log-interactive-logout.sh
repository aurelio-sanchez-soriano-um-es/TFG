#!/bin/bash

# Leer JSON desde stdin
read raw_input

# Extraemos eventID 

input=$(echo "$raw_input" | sed -E 's/"message":""[^"]*""/"message":""/g' ) # Limpiamos esta parte para evitar problemas de parseo

eventID=$(echo "$input" | jq -r '.parameters.alert.data.win.system.eventID')
targetUser=$(echo "$input" | jq -r '.parameters.alert.data.win.eventdata.targetUserName')
read login_timestamp login_targetUser < <(cut -f1,2 /var/ossec/tmp/saved_timestamp)


# Verificar condiciones. Tiene que tratarse del evento de cierre de sesión, que haya un timestamp guardado y que el usuario sea el mismo que el que inició sesión
if [[ "$eventID" == "4647" && "$login_timestamp" != "0" && "$login_targetUser" == "$targetUser" ]]
then
    # Extraemos la fecha en ISO 8601
    date=$(echo "$input" | jq -r '.parameters.alert.timestamp')
    
    # Extraer partes: fecha base y milisegundos
    date_b="${date:0:19}"        
    ms="${date:20:3}"      
    zone="${fecha:23}"                

    # Convertir fecha base a timestamp
    timestamp_in=$(date -d "$date_b $zone" +%s)

    # Calcular timestamp en milisegundos
    logout_timestamp=$((timestamp_in * 1000 + 10#$ms))

    let timestamp=$logout_timestamp-$login_timestamp

    echo "{\"session_time\": \"$timestamp\",\"login_timestamp\": \"$login_timestamp\",\"logout_timestamp\": \"$logout_timestamp\",\"targetUser\": \"$targetUser\"}" >> /var/ossec/logs/custom-events.log
    echo -e "0\tnull" > /var/ossec/tmp/saved_timestamp
fi


