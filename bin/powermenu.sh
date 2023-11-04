#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

# Available Styles
# >> Created and tested on : rofi 1.6.0-1
#
# column_circle     column_square     column_rounded     column_alt
# card_circle     card_square     card_rounded     card_alt
# dock_circle     dock_square     dock_rounded     dock_alt
# drop_circle     drop_square     drop_rounded     drop_alt
# full_circle     full_square     full_rounded     full_alt
# row_circle      row_square      row_rounded      row_alt

theme="card_circle"
dir="$HOME/.config/rofi/powermenu"

# random colors
#styles=($(ls -p --hide="colors.rasi" $dir/styles))
#color="${styles[$(( $RANDOM % 8 ))]}"

# comment this line to disable random colors
#sed -i -e "s/@import .*/@import \"$color\"/g" $dir/styles/colors.rasi

# comment these lines to disable random style
#themes=($(ls -p --hide="powermenu.sh" --hide="styles" --hide="confirm.rasi" --hide="message.rasi" $dir))
#theme="${themes[$(( $RANDOM % 24 ))]}"

uptime=$(uptime -p | sed -e 's/up //g')

rofi_command="rofi -theme $dir/$theme"

# Options
shutdown=""
reboot=""
lock=""
suspend=""
logout=""

# Confirmation
confirm_exit() {
    local prompt="$1"
    rofi -dmenu\
        -i\
        -no-fixed-num-lines\
        -p "$prompt" \
        -theme $dir/confirm.rasi
}


# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"
confirm_key=" (press  Space-Enter)"

chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 2)"
case $chosen in
    $shutdown)
        ans=$(confirm_exit "SHUTDOWN $shutdown $confirm_key" &)
		if [[ $ans == " " || $ans == "y" ]]; then
			systemctl poweroff
        else
			exit 0
        fi
        ;;
    $reboot)
        ans=$(confirm_exit "REBOOT $reboot $confirm_key" &)
		if [[ $ans == " " || $ans == "y" ]]; then
			# systemctl reboot
			alacritty
        else
			exit 0
        fi
        ;;
    $lock)
		betterlockscreen -l
        ;;
    $suspend)
        ans=$(confirm_exit "SUSPEND $suspend $confirm_key" &)
		if [[ $ans == " " || $ans == "y" ]]; then
			playerctl pause
			amixer set Master mute
			systemctl suspend
        else
			exit 0
        fi
        ;;
    $logout)
        ans=$(confirm_exit "LOGOUT $logout $confirm_key" &)
		if [[ $ans == " " || $ans == "y" ]]; then
			session=`loginctl session-status | head -n 1 | awk '{print $1}'`
			loginctl terminate-session $session
        else
			exit 0
        fi
        ;;
esac
