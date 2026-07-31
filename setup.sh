#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Installer Script (called from ../../../../install.sh)

## Colors ----------------------------
Color_Off='\033[0m'
BRed='\033[1;31m'
BCyan='\033[1;36m'

## Directories ----------------------------
DIR=$(pwd)
FONT_DIR="$HOME/.local/share/fonts"
ROFI_DIR="$HOME/.config/rofi"

step() {
	# indented under "> install rofi"
	echo -e "  ${BCyan}→${Color_Off} $*"
}

fail() {
	echo -e "  ${BRed}✗${Color_Off} $*"
	exit 1
}

install_fonts() {
	step "fonts (~/.local/share/fonts)"
	mkdir -p "$FONT_DIR"
	cp -rf "$DIR"/fonts/* "$FONT_DIR"
	step "font cache (fc-cache)"
	fc-cache >/dev/null 2>&1
}

install_themes() {
	if [[ -d "$ROFI_DIR" ]]; then
		bak="${ROFI_DIR}.${USER}"
		step "backup (~/.config/rofi.${USER})"
		rm -rf "$bak"
		cp -a "$ROFI_DIR" "$bak"
	else
		step "backup (skipped)"
	fi
	step "configs (~/.config/rofi)"
	mkdir -p "$ROFI_DIR"
	cp -rf "$DIR"/files/* "$ROFI_DIR"

	if [[ ! -f "$ROFI_DIR/config.rasi" ]]; then
		fail "rofi config missing after install"
	fi
}

install_fonts
install_themes
