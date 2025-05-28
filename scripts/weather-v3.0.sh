#!/bin/bash

# v3.0 Closebox73
# This script is to get weather data from openweathermap.com in the form of a json file
# so that conky will still display the weather when offline even though it doesn't up to date

# Variables
# get your city id at https://openweathermap.org/find and replace
city_id=3472234

# you can use this or replace with yours
api_key=e46d6b1c945f2e9983f0735f8928ea2f

# choose between metric for Celcius or imperial for fahrenheit
unit=metric

# i'm not sure it will support all languange, 
lang=pt

url="api.openweathermap.org/data/2.5/weather?id=${city_id}&appid=${api_key}&cnt=5&units=${unit}&lang=${lang}"
url_open_meteo="https://api.open-meteo.com/v1/forecast?latitude=-23.510147&longitude=-48.406406&current=temperature_2m&daily=temperature_2m_max,temperature_2m_min&timezone=America/Sao_Paulo"

get_data () {
	curl ${url} -s -o ~/.cache/weather.json
	curl ${url_open_meteo} -s -o ~/.cache/weather-open-meteo.json
}

# All Flags
case $1 in
	-g)
	get_data
	;;
	-n) 
	cat ~/.cache/weather.json | jq -r '.name'
	;;
	-c) 
	cat ~/.cache/weather.json | jq -r '.sys.country'
	;;
	-m)
	cat ~/.cache/weather.json | jq -r '.weather[0].main' | sed "s|\<.|\U&|g"
	;;
	-d)
	cat ~/.cache/weather.json | jq -r '.weather[0].description' | sed "s|\<.|\U&|g"
	;;
	-t)
	cat ~/.cache/weather.json | jq '.main.temp' | awk '{print int($1+0.5)}'
	;;
	-tx)
	cat ~/.cache/weather-open-meteo.json | jq '.daily.temperature_2m_max[0]' | awk '{print int($1+0.5)}'
	;;
	-tn)
	cat ~/.cache/weather-open-meteo.json | jq '.daily.temperature_2m_min[0]'| awk '{print int($1+0.5)}'
	;;
	-p)
	cat ~/.cache/weather.json | jq '.main.pressure'
	;;
	-ws)
	cat ~/.cache/weather.json | jq '.wind.speed'
	;;
	-wd)
	cat ~/.cache/weather.json | jq '.wind.deg'
	;;
	-h)
	cat ~/.cache/weather.json | jq '.main.humidity'
	;;
	-v)
	cat ~/.cache/weather.json | jq '.visibility' | sed 's/...$//'
	;;
esac
