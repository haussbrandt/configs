cp .tmux.conf ~

if grep -q 'Ubuntu' /etc/os-release; then
	sudo add-apt-repository ppa:neovim-ppa/unstable -y
	sudo apt update
	sudo apt install -y make gcc ripgrep unzip git xclip neovim fd-find
	ln -s $(which fdfind) ~/.local/bin/fd
fi

cp -r nvim "${XDG_CONFIG_HOME:-$HOME/.config}"/
