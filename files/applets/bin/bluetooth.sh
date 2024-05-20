#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Favorite Applications

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
prompt='Bluetooth'
mesg="Disconnected"

# list paired devices
declare -a devices_paired;
declare -a devices_paired_names;
declare -a devices_connected;
declare -a devices_connected_names;
if [ "$(systemctl is-active "bluetooth.service")" = "active" ]; then
	paired=$(bluetoothctl devices Paired | grep Device | cut -d ' ' -f 2)

	for device in $paired; do
		devices_paired+=("$device")
		device_info=$(bluetoothctl info "$device")
		device_name=$(echo "$device_info" | grep "Alias" | cut -d ' ' -f 2-)

		devices_paired_names+=("$device_name")
		if echo "$device_info" | grep -q "Connected: yes"; then
			devices_connected+=("$device")
			devices_connected_names+=("$device_name")
		fi

	done
fi;

# display connected devices
if [ ${#devices_connected_names[@]} -gt 0 ]; then
	mesg="Connected: ${devices_connected_names[@]}"
fi

if [[ ( "$theme" == *'type-1'* ) || ( "$theme" == *'type-3'* ) || ( "$theme" == *'type-5'* ) ]]; then
	list_col='1'
	list_row='6'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
	list_col='6'
	list_row='1'
fi

# Options
declare -a options;
for device_name in "${devices_connected_names[@]}"; do
	options+=("󰂲 <span weight='light' size='small'><i>disconnect</i></span> $device_name")
done
for device_name in "${devices_paired_names[@]}"; do
	if [[ " ${devices_connected_names[@]} " =~ " ${device_name} " ]]; then
		continue
	fi
	options+=("󰂯 <span weight='light' size='small'><i>connect   </i></span> $device_name")
done

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	# join options with newlines '\n'
	printf "%s\n" "${options[@]}" | rofi_cmd
}

# Execute Command
run_cmd() {
	command="$1"
	device="$2"

	if [[ "$command" == "󰂲" ]]; then
		bluetoothctl disconnect "$device"
	elif [[ "$command" == "󰂯" ]]; then
		bluetoothctl connect "$device"
	fi
}

# Actions
chosen="$(run_rofi)"

# if choice is empty, exit
if [ -z "$chosen" ]; then
	exit 0
fi

# get command and device name
command=$(echo "$chosen" | awk '{print $1}')
device_name=$(echo "$chosen" | cut -d '>' -f 5- | cut -d ' ' -f 2-)

# get device mac address
device_mac=""
for i in "${!devices_paired_names[@]}"; do
	if [[ "${devices_paired_names[$i]}" == "$device_name" ]]; then
		device_mac="${devices_paired[$i]}"
		break
	fi
done

if [[ "$command" == "󰂲" ]]; then
	printf "disconnecting from $device_name ($device_mac)\n"
	bluetoothctl disconnect "$device_mac"
	exit 0
elif [[ "$command" == "󰂯" ]]; then
	printf "connecting to $device_name ($device_mac)\n"
	bluetoothctl connect "$device_mac"
	exit 0
fi