#!/bin/bash

## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## vpn_module: vpn scripts for a polybar, setup stock for Mullvad VPN
## 	by Shervin S. (shervin@tuta.io)

## 	vpn_module reports your VPN's status as [<ip_address> | connecting... | No VPN ].
##  With optional dependencies, <ip_address> will be replaced with <city> <country>.
##  You can also connect and disconnect via left-clicks, or with rofi, right-click to
##  access a menu and select between your favorite locations, set in VPN_LOCATIONS,
##  as well as 35 countries covered by Mullvad VPN.

##	dependencies (assuming use with Mullvad VPN):
##		mullvad-vpn (or mullvad-vpn-cli)

##	optional dependencies:
##		rofi 				  - allows menu-based control of mullvad
##		geoip, geoip-database - provide country instead of public ip address
## 		geoip-database-extra  - also provides city info
##      xclip                 - allows copying ip address to clipboard

## polybar setup:
## - Append contents of vpn_user_module file to user_modules.ini
## - Add "vpn" module to your config.ini under modules


## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## User Settings

## [Set VPN commands]. Setup for Mullvad is done below.
# The first three commands should have direct equivalents for most VPNs.
# The relay_set command assumes <country_code> <city_code> will follow as arguments. See below.
VPN_CONNECT="nordvpn c"
VPN_DISCONNECT="nordvpn d"
VPN_GET_STATUS="nordvpn status"

## [Set VPN status parsing]
# The first command cuts the status, which is compared to keywords below.
# TODO: Add community submissions for other VPNs to make this section robust!
VPN_STATUS="$($VPN_GET_STATUS | sed -n 1p | cut -c 21-29)"	# returns Connected/Connecting/<other>
CONNECTED=Connected

## [Set colors] (set each variable to nothing for default color)
# green=#00CC66
# red=#FF3300
# blue=#0066FF
# orange=#FF6600
# yellow=#FFFF00
# purple=#CC33FF
COLOR_CONNECTED=#00CC66
COLOR_DISCONNECTED=#FF3300

## [Set 8 favorite VPN locations]
# These are passed to your VPN as `$VPNCOMMAND_RELAY_SET_LOCATION <input>`.
VPN_LOCATIONS=("Finland" "Sweden" "Estonia" "Denmark" "Norway" "Germany" "Poland" "United States")

## [Set optional rofi menu style]. `man rofi` for help.
icon_connect=
icon_fav=
icon_country=
rofi_font="UbuntuMono Nerd Font 22"
rofi_theme="~/.config/rofi/colors-rofi-dark.rasi"
rofi_location="-location 5 -xoffset -1020 -yoffset -1723"
rofi_menu_name="NordVPN"


## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## Main Script

# They ought to connect to your VPN's choice of server in the region.
COUNTRIES=("Albania" "Argentina" "Australia" "Austria" "Belgium" "Bosnia" "Brazil" "Bulgaria" "Canada" "Chile" "Costa Rica" "Croatia" "Cyprus" "Czech Republic" "Denmark" "Estonia" "Finland" "France" "Georgia" "Germany" "Greece" "Hong Kong" "Hungary" "Iceland" "India" "Indonesia" "Ireland" "Israel" "Italy" "Japan" "Latvia" "Luxembourg" "Macedonia" "Malaysia" "Mexico" "Moldova" "Netherlands" "New Zealand" "Norway" "Poland" "Portugal" "Romania" "Serbia" "Singapore" "Slovakia" "Slovenia" "South Africa" "South Korea" "Spain" "Sweden" "Switzerland" "Taiwan" "Thailand" "Turkey" "Ukraine" "United Arab Emirates" "United Kingdom" "United States" "Vietnam")

# Concatenate favorite and country arrays
#VPN_LOCATIONS=("${VPN_LOCATIONS[@]}")
#VPN_LOCATIONS+=("${COUNTRIES[@]}")
VPN_LOCATIONS+=("${COUNTRIES[@]}")


vpn_report() {
# continually reports connection status
	if [ "$VPN_STATUS" = "$CONNECTED"  ]; then
		ip_address=$($VPN_GET_STATUS | sed -n 5p | cut -c 13-27)
# move this above the first if statement if something breaks

		if [ "$VPN_STATUS" = "$CONNECTED" ]; then
			country=$($VPN_GET_STATUS | sed -n 3p | cut -c 10-16)
			city=$($VPN_GET_STATUS | sed -n 4p | cut -c 7-14)
			echo "%{F$COLOR_CONNECTED}$city $country%{F-}"
		else
			echo "%{F$COLOR_CONNECTED}$ip_address%{F-}"
		fi
	else
		echo "%{F$COLOR_DISCONNECTED}No VPN%{F-}"
	fi
}


vpn_toggle_connection() {
# connects or disconnects vpn
    if [ "$VPN_STATUS" = "$CONNECTED" ]; then
        $VPN_DISCONNECT
    else
        $VPN_CONNECT
    fi
}


vpn_location_menu() {
# Allows control of VPN via rofi menu. Selects from VPN_LOCATIONS.

	if hash rofi 2>/dev/null; then

		MENU="$(rofi \
			-font "$rofi_font" -theme "$rofi_theme" $rofi_location \
			-columns 1 -width 10 -hide-scrollbar \
			-line-padding 4 -padding 10 -lines 9 \
			-sep "|" -dmenu -i -p "$rofi_menu_name" <<< \
			" $icon_connect (dis)connect| $icon_fav ${VPN_LOCATIONS[0]}| $icon_fav ${VPN_LOCATIONS[1]}| $icon_fav ${VPN_LOCATIONS[2]}| $icon_fav ${VPN_LOCATIONS[3]}| $icon_fav ${VPN_LOCATIONS[4]}| $icon_fav ${VPN_LOCATIONS[5]}| $icon_fav ${VPN_LOCATIONS[6]}| $icon_fav ${VPN_LOCATIONS[7]}| $icon_country ${VPN_LOCATIONS[8]}| $icon_country ${VPN_LOCATIONS[9]}| $icon_country ${VPN_LOCATIONS[10]}| $icon_country ${VPN_LOCATIONS[11]}| $icon_country ${VPN_LOCATIONS[12]}| $icon_country ${VPN_LOCATIONS[13]}| $icon_country ${VPN_LOCATIONS[14]}| $icon_country ${VPN_LOCATIONS[15]}| $icon_country ${VPN_LOCATIONS[16]}| $icon_country ${VPN_LOCATIONS[17]}| $icon_country ${VPN_LOCATIONS[18]}| $icon_country ${VPN_LOCATIONS[19]}| $icon_country ${VPN_LOCATIONS[20]}| $icon_country ${VPN_LOCATIONS[21]}| $icon_country ${VPN_LOCATIONS[22]}| $icon_country ${VPN_LOCATIONS[23]}| $icon_country ${VPN_LOCATIONS[24]}| $icon_country ${VPN_LOCATIONS[25]}| $icon_country ${VPN_LOCATIONS[26]}| $icon_country ${VPN_LOCATIONS[27]}| $icon_country ${VPN_LOCATIONS[28]}| $icon_country ${VPN_LOCATIONS[29]}| $icon_country ${VPN_LOCATIONS[30]}| $icon_country ${VPN_LOCATIONS[31]}| $icon_country ${VPN_LOCATIONS[32]}| $icon_country ${VPN_LOCATIONS[33]}| $icon_country ${VPN_LOCATIONS[34]}| $icon_country ${VPN_LOCATIONS[35]}| $icon_country ${VPN_LOCATIONS[36]}| $icon_country ${VPN_LOCATIONS[37]}| $icon_country ${VPN_LOCATIONS[38]}| $icon_country ${VPN_LOCATIONS[39]}| $icon_country ${VPN_LOCATIONS[40]}| $icon_country ${VPN_LOCATIONS[41]}| $icon_country ${VPN_LOCATIONS[42]}| $icon_country ${VPN_LOCATIONS[43]}")"

	    case "$MENU" in
			*connect) vpn_toggle_connection; return;;
			*"${VPN_LOCATIONS[0]}") $VPN_CONNECT ${VPN_LOCATIONS[0]};;
			*"${VPN_LOCATIONS[1]}") $VPN_CONNECT ${VPN_LOCATIONS[1]};;
			*"${VPN_LOCATIONS[2]}") $VPN_CONNECT ${VPN_LOCATIONS[2]};;
			*"${VPN_LOCATIONS[3]}") $VPN_CONNECT ${VPN_LOCATIONS[3]};;
			*"${VPN_LOCATIONS[4]}") $VPN_CONNECT ${VPN_LOCATIONS[4]};;
			*"${VPN_LOCATIONS[5]}") $VPN_CONNECT ${VPN_LOCATIONS[5]};;
			*"${VPN_LOCATIONS[6]}") $VPN_CONNECT ${VPN_LOCATIONS[6]};;
			*"${VPN_LOCATIONS[7]}") $VPN_CONNECT ${VPN_LOCATIONS[7]};;
			*"${VPN_LOCATIONS[8]}") $VPN_CONNECT ${VPN_LOCATIONS[8]};;
			*"${VPN_LOCATIONS[9]}") $VPN_CONNECT ${VPN_LOCATIONS[9]};;
			*"${VPN_LOCATIONS[10]}") $VPN_CONNECT "${VPN_LOCATIONS[10]}";;
			*"${VPN_LOCATIONS[11]}") $VPN_CONNECT "${VPN_LOCATIONS[11]}";;
			*"${VPN_LOCATIONS[12]}") $VPN_CONNECT "${VPN_LOCATIONS[12]}";;
			*"${VPN_LOCATIONS[13]}") $VPN_CONNECT "${VPN_LOCATIONS[13]}";;
			*"${VPN_LOCATIONS[14]}") $VPN_CONNECT "${VPN_LOCATIONS[14]}";;
			*"${VPN_LOCATIONS[15]}") $VPN_CONNECT "${VPN_LOCATIONS[15]}";;
			*"${VPN_LOCATIONS[16]}") $VPN_CONNECT "${VPN_LOCATIONS[16]}";;
			*"${VPN_LOCATIONS[17]}") $VPN_CONNECT "${VPN_LOCATIONS[17]}";;
			*"${VPN_LOCATIONS[18]}") $VPN_CONNECT "${VPN_LOCATIONS[18]}";;
			*"${VPN_LOCATIONS[19]}") $VPN_CONNECT "${VPN_LOCATIONS[19]}";;
			*"${VPN_LOCATIONS[20]}") $VPN_CONNECT "${VPN_LOCATIONS[20]}";;
			*"${VPN_LOCATIONS[21]}") $VPN_CONNECT "${VPN_LOCATIONS[21]}";;
			*"${VPN_LOCATIONS[22]}") $VPN_CONNECT "${VPN_LOCATIONS[22]}";;
			*"${VPN_LOCATIONS[23]}") $VPN_CONNECT "${VPN_LOCATIONS[23]}";;
			*"${VPN_LOCATIONS[24]}") $VPN_CONNECT "${VPN_LOCATIONS[24]}";;
			*"${VPN_LOCATIONS[25]}") $VPN_CONNECT "${VPN_LOCATIONS[25]}";;
			*"${VPN_LOCATIONS[26]}") $VPN_CONNECT "${VPN_LOCATIONS[26]}";;
			*"${VPN_LOCATIONS[27]}") $VPN_CONNECT "${VPN_LOCATIONS[27]}";;
			*"${VPN_LOCATIONS[28]}") $VPN_CONNECT "${VPN_LOCATIONS[28]}";;
			*"${VPN_LOCATIONS[29]}") $VPN_CONNECT "${VPN_LOCATIONS[29]}";;
			*"${VPN_LOCATIONS[30]}") $VPN_CONNECT "${VPN_LOCATIONS[30]}";;
			*"${VPN_LOCATIONS[31]}") $VPN_CONNECT "${VPN_LOCATIONS[31]}";;
			*"${VPN_LOCATIONS[32]}") $VPN_CONNECT "${VPN_LOCATIONS[32]}";;
			*"${VPN_LOCATIONS[33]}") $VPN_CONNECT "${VPN_LOCATIONS[33]}";;
			*"${VPN_LOCATIONS[34]}") $VPN_CONNECT "${VPN_LOCATIONS[34]}";;
			*"${VPN_LOCATIONS[35]}") $VPN_CONNECT "${VPN_LOCATIONS[35]}";;
			*"${VPN_LOCATIONS[36]}") $VPN_CONNECT "${VPN_LOCATIONS[36]}";;
			*"${VPN_LOCATIONS[37]}") $VPN_CONNECT "${VPN_LOCATIONS[37]}";;
			*"${VPN_LOCATIONS[38]}") $VPN_CONNECT "${VPN_LOCATIONS[38]}";;
			*"${VPN_LOCATIONS[39]}") $VPN_CONNECT "${VPN_LOCATIONS[39]}";;
			*"${VPN_LOCATIONS[40]}") $VPN_CONNECT "${VPN_LOCATIONS[40]}";;
			*"${VPN_LOCATIONS[41]}") $VPN_CONNECT "${VPN_LOCATIONS[41]}";;
			*"${VPN_LOCATIONS[42]}") $VPN_CONNECT "${VPN_LOCATIONS[42]}";;
			*"${VPN_LOCATIONS[43]}") $VPN_CONNECT "${VPN_LOCATIONS[43]}";;
			*"${VPN_LOCATIONS[44]}") $VPN_CONNECT "${VPN_LOCATIONS[44]}";;
			*"${VPN_LOCATIONS[45]}") $VPN_CONNECT "${VPN_LOCATIONS[45]}";;
			*"${VPN_LOCATIONS[46]}") $VPN_CONNECT "${VPN_LOCATIONS[46]}";;
			*"${VPN_LOCATIONS[47]}") $VPN_CONNECT "${VPN_LOCATIONS[47]}";;
			*"${VPN_LOCATIONS[48]}") $VPN_CONNECT "${VPN_LOCATIONS[48]}";;
			*"${VPN_LOCATIONS[49]}") $VPN_CONNECT "${VPN_LOCATIONS[49]}";;
			*"${VPN_LOCATIONS[50]}") $VPN_CONNECT "${VPN_LOCATIONS[50]}";;
			*"${VPN_LOCATIONS[51]}") $VPN_CONNECT "${VPN_LOCATIONS[51]}";;
			*"${VPN_LOCATIONS[52]}") $VPN_CONNECT "${VPN_LOCATIONS[52]}";;
			*"${VPN_LOCATIONS[53]}") $VPN_CONNECT "${VPN_LOCATIONS[53]}";;
			*"${VPN_LOCATIONS[54]}") $VPN_CONNECT "${VPN_LOCATIONS[54]}";;
			*"${VPN_LOCATIONS[55]}") $VPN_CONNECT "${VPN_LOCATIONS[55]}";;
			*"${VPN_LOCATIONS[56]}") $VPN_CONNECT "${VPN_LOCATIONS[56]}";;
			*"${VPN_LOCATIONS[57]}") $VPN_CONNECT "${VPN_LOCATIONS[57]}";;
			*"${VPN_LOCATIONS[58]}") $VPN_CONNECT "${VPN_LOCATIONS[58]}";;
			*"${VPN_LOCATIONS[59]}") $VPN_CONNECT "${VPN_LOCATIONS[59]}";;
	    esac

	    if [ "$VPN_STATUS" = "$CONNECTED" ]; then
	        true
	    else
	        $VPN_CONNECT
	    fi
	fi
}


ip_address_to_clipboard() {
# finds your IP and copies to clipboard
# could also use https://ifconfig.io, checkip.amazonaws.com
	ip_address=$(curl --silent https://ipaddr.pub)
	echo "$ip_address" | xclip -selection clipboard

# TODO: why doesn't this echo display in polybar?
	echo "$ip_address"
}


# cases for polybar user_module.ini
case "$1" in
	--toggle-connection) vpn_toggle_connection ;;
	--location-menu) vpn_location_menu ;;
	--ip-address) ip_address_to_clipboard;;
	*) vpn_report ;;
esac
