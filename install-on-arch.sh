#!/bin/env bash
set -e

# echo "Welcome!" && sleep 2

#Default vars
HELPER="paru"
if ! command -v $HELPER &> /dev/null
then
    echo "It seems that you don't have $HELPER installed, make sure to install it!"
fi

# Available Resolutions:
#1)1366 x 768, 2)1920 x 1080, 3)2560 x 1440
EWW_DIR='config/eww-1920'
echo "Resolution is 1920 x 1080!"

# does full system update
echo "Doing a system update, cause stuff may break if it's not the latest version..."
sudo pacman --noconfirm -Syu

echo "###########################################################################"
echo "Will do stuff, get ready"
echo "###########################################################################"

# install necessary packages
sudo pacman -S --noconfirm --needed base-devel wget git
sudo pacman -S --noconfirm --needed rofi feh xorg xorg-xinit xorg-xinput xmonad

# install fonts
mkdir -p ~/.local/share/fonts
mkdir -p ~/.srcs
cp -r ./fonts/* ~/.local/share/fonts/
fc-cache -f
clear 

git clone https://github.com/jonaburg/picom ~/.srcs/picom
(cd ~/.srcs/picom/ && makepkg -si )

$HELPER -S \
	   acpi              \
	   candy-icons-git   \
	   wmctrl            \
	   alacritty         \
	   playerctl         \
	   dunst             \
	   xmonad-contrib    \
	   jq                \
	   xclip             \
	   maim              \
	   rofi-greenclip    \
	   xautolock         \
	   betterlockscreen




# Hack to make tint2 work for now.
if ! [ -f /usr/lib/libasan.so.6 ]; then
    sudo ln -s /usr/lib/libasan.so.8 /usr/lib/libasan.so.6 
fi


#install custom picom config file 
mkdir -p ~/.config/
# cd .config/
# git clone https://gist.github.com/f70dea1449cfae856d42b771912985f9.git ./picom 
    if [ -d ~/.config/rofi ]; then
        echo "Rofi configs detected, backing up..."
        mkdir ~/.config/rofi.old && mv ~/.config/rofi/* ~/.config/rofi.old/
        cp -r ./config/rofi/* ~/.config/rofi;
    else
        echo "Installing rofi configs..."
        mkdir ~/.config/rofi && cp -r ./config/rofi/* ~/.config/rofi;
    fi
    sleep 2

    if [ -d ~/.config/eww ]; then
        echo "Eww configs detected, backing up..."
        mkdir ~/.config/eww.old && mv ~/.config/eww/* ~/.config/eww.old/
        cp -r ./$EWW_DIR/* ~/.config/eww;
    else
        echo "Installing eww configs..."
        mkdir ~/.config/eww && cp -r ./$EWW_DIR/* ~/.config/eww;
    fi
    if [ -f ~/.config/picom.conf ]; then
        echo "Picom configs detected, backing up..."
        cp ~/.config/picom.conf ~/.config/picom.conf.old;
        cp ./config/picom.conf ~/.config/picom.conf;
    else
        echo "Installing picom configs..."
         cp ./config/picom.conf ~/.config/picom.conf;
    fi
    if [ -d ~/.config/dunst ]; then
        echo "Dunst configs detected, backing up..."
        mkdir ~/.config/dunst.old && mv ~/.config/dunst/* ~/.config/dunst.old/
        cp -r ./config/dunst/* ~/.config/dunst;
    else
        echo "Installing dunst configs..."
        mkdir ~/.config/dunst && cp -r ./config/dunst/* ~/.config/dunst;
    fi
    if [ -d ~/wallpapers ]; then
        echo "Adding wallpaper to ~/wallpapers..."
        cp ./wallpapers/yosemite-lowpoly.jpg ~/wallpapers/;
    else
        echo "Installing wallpaper..."
        mkdir ~/wallpapers && cp -r ./wallpapers/* ~/wallpapers/;
    fi
    if [ -d ~/.config/tint2 ]; then
        echo "Tint2 configs detected, backing up..."
        mkdir ~/.config/tint2.old && mv ~/.config/tint2/* ~/.config/tint2.old/
        cp -r ./config/tint2/* ~/.config/tint2;
    else
        echo "Installing tint2 configs..."
        mkdir ~/.config/tint2 && cp -r ./config/tint2/* ~/.config/tint2;
    fi
    if [ -d ~/.xmonad ]; then
        echo "XMonad configs detected, backing up..."
        mkdir ~/.xmonad.old && mv ~/.xmonad/* ~/.xmonad.old/
        cp -r ./xmonad/* ~/.xmonad/;
        # ln -s ./xmonad/ $HOME/.xmonad
    else
        echo "Installing xmonad configs..."
        # ln -s ./xmonad/ $HOME/.xmonad
        mkdir ~/.xmonad && cp -r ./xmonad/* ~/.xmonad;
    fi
    if [ -d ~/bin ]; then
        echo "~/bin detected, backing up..."
        mkdir ~/bin.old && mv ~/bin/* ~/bin.old/
        cp -r ./bin/* ~/bin;
	clear
    else
        echo "Installing bin scripts..."
        mkdir ~/bin && cp -r ./bin/* ~/bin/;
    

# done 
echo "PLEASE MAKE .xinitrc TO LAUNCH, or just use your Display Manager (ie. lightdm or sddm, etc.)" | tee ~/Note.txt
sleep 3
xmonad --recompile
