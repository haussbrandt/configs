cp .tmux.conf ~

sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install -y make gcc ripgrep unzip git xclip neovim fd-find
ln -s $(which fdfind) ~/.local/bin/fd

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
cp init.lua "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
cp -r lua "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/lua

