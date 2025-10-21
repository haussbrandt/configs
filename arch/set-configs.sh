cp -f ./hypr/* ~/.config/hypr/
rm -rf ~/.config/waybar
cp -fr ./waybar/ ~/.config/
sudo cp -f ./mirrorlist /etc/pacman.d/mirrorlist
sudo cp -f ./pacman.conf /etc/pacman.conf
sudo cp -f ./autologin.conf /etc/sddm.conf.d/autologin.conf
cp ./.bashrc ~/.bashrc
cp ./.inputrc ~/.inputrc
rm -rf ~/.config/mako
mkdir ~/.config/mako
cp -rf ./mako/* ~/.config/mako
rm -rf ~/.config/walker
mkdir ~/.config/walker
cp -rf ./walker/* ~/.config/walker
sudo cp -rf ./f1_layout_script.sh /usr/local/bin/f1_layout_script.sh 
