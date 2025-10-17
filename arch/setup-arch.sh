./set-configs.sh

sudo pacman -Syu --noconfirm
mapfile -t pacmanpackages < <(grep -v '^#' "./pacman.packages" | grep -v '^$')
sudo pacman -S --needed --noconfirm "${pacmanpackages[@]}"

mapfile -t yaypackages < <(grep -v '^#' "./yay.packages" | grep -v '^$')
yay -S --needed --noconfirm "${yaypackages[@]}"

sudo cp -R ./bin/* /bin/

mkdir -p ~/.local/share/alacritty
cp -f ./screensaver.toml ~/.local/share/alacritty
