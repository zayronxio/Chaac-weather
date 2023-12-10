#!/bin/bash

# Obteniendo las coordenadas geográficas
cordeprev3=$(curl -s ipinfo.io)
cordeprev2=$(echo "$cordeprev3" | grep "loc")
textno=$(echo "$cordeprev3" | grep "textoquenoesta")

if [[ "$cordeprev2" = "$textno" ]]; then
    contenidoIpBase=$(curl -s https://api.ipbase.com/v1/json/)
    contenidoIpBaseAjs=$(echo "$contenidoIpBase" | sed 's/,/\n/g')

    findLatitude=$(echo "$contenidoIpBaseAjs" | grep "latitude")
    findLatitude01=$(echo "$findLatitude" | sed 's/"latitude"://g')
    if [[ "$findLatitude01" = "$textno" ]]; then
         contenidoIpBase02=$(curl -s http://ip-api.com/json/?fields=lat,lon)
         contenidoIpBase02Ajs=$(echo "$contenidoIpBase02" | sed 's/,/\n/g')
         findLatitude02=$(echo "$contenidoIpBase02Ajs" | grep "lat")
         findLatitude03=$(echo "$findLatitude02" | sed 's/"lat"://g')
         latitude=$(echo "$findLatitude01" | sed 's/,//g')

         findLongitud=$(echo "$contenidoIpBase02Ajs" | grep "lon")
         findLongitud01=$(echo "$findLongitud" | sed 's/"lon"://g')
         longitud=$(echo "$findLongitud01" | sed 's/,//g')
         else
         latitude=$(echo "$findLatitude01" | sed 's/,//g')
         findLongitud=$(echo "$contenidoIpBaseAjs" | grep "longitude")
         findLongitud01=$(echo "$findLongitud" | sed 's/"longitude"://g')
         longitud=$(echo "$findLongitud01" | sed 's/,//g')
     fi
else
    cordeprev1=$(echo "$cordeprev2" | sed 's/"loc": "//g')
    cordeprev0=$(echo "$cordeprev1" | sed 's/",//g')
    cordeprev=$(echo "$cordeprev1" | sed 's/,/\n/g')
    latitudeprev=$(echo "$cordeprev" | head -n 1)
    latitude=$(echo "$latitudeprev" | sed 's/ //g')

    longitudprev=$(echo "$cordeprev" | sed -n '2p')
    longitud=$(echo "$longitudprev" | sed 's/"//g')
fi

# Validación de entradas nulas
if [ $1 = "null" ]
  then latitudefinal=$latitude
  else latitudefinal=$1
  fi
if [ $2 = "null" ]
   then longitudfinal=$longitud
   else longitudfinal=$2
   fi

corde="latitude=$latitudefinal&longitude=$longitudfinal"

# URL de la API meteorológica
apiurl="https://api.open-meteo.com/v1/forecast?$corde&current=temperature_2m,weather_code&timezone=auto"

# Descargar datos JSON desde la API
full=$(curl -s "$apiurl")
fulfilt=$(echo "$full" | sed 's/,/,\n/g')
fullfinal=$(echo "$fulfilt" | sed 's/"temperature_2m":"°C",//g')
temprev=$(echo "$fullfinal" | grep "temperature_2m")
temprevfirst=$(echo "$temprev" | sed 's/"temperature_2m"://g')
tem=$(echo "$temprevfirst" | sed 's/,//g')

# Código de estado del tiempo
fulltamefinal=$(echo "$fulfilt" | sed 's/"weather_code":"wmo code"//g')
codetemprev=$(echo "$fulltamefinal" | grep "weather_code")
codetemprev1=$(echo "$codetemprev" | sed 's/"weather_code"://g')
codetem=$(echo "$codetemprev1" | sed 's/}}//g')

# Establecimiento de la ubicación
response=$(curl -s "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitudefinal&lon=$longitudfinal")
textoFinal=$(echo "$response" | sed 's/,/,\n/g')
# // cityprev25=$(echo "$cityprev3" | grep '"address":{')
# // textoFinal=$(echo "$response" | sed "s/$cityprev25//g")
cityprev1=$(echo "$textoFinal" | grep '"city"')
cityprev=$(echo "$cityprev1" | sed 's/"city":"//g')
city=$(echo "$cityprev" | sed 's/",//g')
citycond=$(echo "$textoFinal" | grep "textoquenoesta")
if [ "$city" = "$citycond" ]; then
        city_distri02=$(echo "$textoFinal" | grep '"city_district"')
        city_distri01=$(echo "$city_distri02" | sed 's/"city_district":"//g')
        city_distri=$(echo "$city_distri01" | sed 's/",//g')
        if [ "$city_distri" = "$citycond" ]; then
             cityprev01=$(echo "$textoFinal" | grep '"state"')
             cityprev0=$(echo "$cityprev01" | sed 's/"state":"//g')
             state=$(echo "$cityprev0" | sed 's/",//g')
             cityR=$state
       else
             cityR=$city_distri
       fi
    else
        cityR=$city
    fi

# Selección del resultado según el tercer argumento
if [ "$3" = "tem" ]; then
    result=$tem
elif [ "$3" = "codetem" ]; then
    result=$codetem
elif [ "$3" = "ubi" ]; then
    result=$cityR
else
    result="null"
fi

echo $result
