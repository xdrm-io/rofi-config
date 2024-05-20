## Current Theme

typeid="$1"; if [ -z "$typeid" ]; then typeid="type-1"; fi
export type="$HOME/.config/rofi/applets/$typeid"

styleid="$2"; if [ -z "$styleid" ]; then styleid="style-1"; fi
export style="$styleid.rasi";
