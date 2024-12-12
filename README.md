### Samples

![Coding](./images/coding.png)
![Note-taking](./images/note-taking.png)

## Programs I use

- [rofi](https://github.com/davatorium/rofi) +config
- [dunst](https://github.com/dunst-project/dunst) +config
- [maim](https://github.com/naelstrof/maim)
- [feh](https://github.com/derf/feh)
- [betterlockscreen](https://github.com/betterlockscreen/betterlockscreen)
- [greenclip](https://github.com/erebe/greenclip)
- pactl
- [brightnessctl](https://github.com/Hummer12007/brightnessctl)
- xclip
- [alacritty](https://github.com/alacritty/alacritty)
- [firefox-developer-edition](https://www.mozilla.org/en-US/firefox/developer/)
- [qutebrowser](https://github.com/qutebrowser/qutebrowser/)
- [obsidian](https://obsidian.md/)

## some scripts I use (in `./scripts`)

- inhibit_activate
- inhibit_deactivate
- powermenu.sh
- toggle_alacritty_opacity
- toggle_xmobar


## Installation

Generally follow this [guide](https://brianbuccola.com/how-to-install-xmonad-and-xmobar-via-stack/) as installation with stack is preferred

make sure to copy all needed files and folders:
```bash
mkdir ~/.xmonad
cp ./xmonad/xmonad.hs ~/.xmonad
cp ./xmonad/xmobar.config ~/.xmonad
cp -r ./scripts ~
cp ./config/picom.conf ~/.config
cp -r ./config/rofi ~/.config
cp -r ./config/dunst ~/.config
```

now proceed with the actual installation
```bash
curl -sSL https://get.haskellstack.org/ | sh
stack setup

cd ~/.xmonad
git clone "https://github.com/xmonad/xmonad" xmonad-git
git clone "https://github.com/xmonad/xmonad-contrib" xmonad-contrib-git
git clone "https://codeberg.org/xmobar/xmobar" xmobar-git

stack init

ln -s ~/.local/bin/xmonad /usr/bin
ln -s ~/.local/bin/xmobar /usr/bin

cp ./installation/build.sh ~/.xmonad
chmod a+x ~/.xmonad/build.sh
xmonad --recompile && xmonad --restart
```

make xmonad it appear in display manager:
```bash
#note: change username accordingly in .desktop file
cp ./installation/xmonad.desktop /usr/share/xsessions
```
