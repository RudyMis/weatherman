#!/bin/bash

# Some variables for neat output
GREEN="\e[1;32m"
RED="\e[1;31m"
DEFAULT="\e[0m"

# Read configs
echo "Reading config..." >&2
source /etc/weatherman.cfg 
if [ -r ~/.config/weatherman/init ]; then
	echo "Found user config" >&2
	source ~/.config/weatherman/init
fi
echo "Loaded config for city: ${city}" >&2

# Get location
echo -n "Getting coordinates... " >&2
loc=`curl "https://api.openweathermap.org/geo/1.0/direct?q=${city}&appid=${api_key}" -s`
if [ -z "$loc" ]; then # If empty exit
	echo -e "${RED}FAIL${DEFAULT}" >&2
	echo "exiting" >&2
	exit -1
fi
lat=`echo $loc | jq '.[].lat'`
lon=`echo $loc | jq '.[].lon'`
echo -e "${GREEN}Done${DEFAULT}" >&2

# Get weather
echo -n "Getting weather... " >&2
weather_data=`curl "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${api_key}" -s`
weather=`echo $weather_data | jq '.weather[].main'`
temperature=`echo $weather_data | jq '.main.temp'`
# Trim strings (they come surrounded by ")
weather=${weather:1:-1}
temperature=${temperature:1:-1}
echo -e "${GREEN}Done${DEFAULT}" >&2

# Set background color
function set_color {
	color=`xrdb -get $1`
}

echo -n "Setting background color... " >&2
case "$weather" in
	"Thunderstorm")
		set_color color8
		;;
	"Drizzle")
		set_color color12
		;;
	"Rain")
		set_color color4
		;;
	"Snow")
		set_color color15
		;;
	"Clear")
		set_color color11
		;;
	"Clouds")
		set_color color7
		;;
	*)
		set_color color2
		;;
esac
# Create background image
convert ${wallpaper} -fuzz ${fuzz_factor} -fill "${color}" -opaque ${base_color} new_${wallpaper}
nitrogen --set-auto new_${wallpaper}
rm new_${wallpaper}

echo -e "${GREEN}Done${DEFAULT}" >&2











