./set-configs.sh

sudo pacman -Syu --noconfirm
mapfile -t pacmanpackages < <(grep -v '^#' "./pacman.packages" | grep -v '^$')
sudo pacman -S --needed --noconfirm "${pacmanpackages[@]}"

mapfile -t yaypackages < <(grep -v '^#' "./yay.packages" | grep -v '^$')
yay -S --needed --noconfirm "${yaypackages[@]}"

sudo cp -R ./bin/* /bin/

mkdir -p ~/.local/share/alacritty
cp -f ./screensaver.toml ~/.local/share/alacritty
cp -f ./screensaver.txt ~/.config/screensaver.txt

# Give the user 10 instead of 3 tries to fat finger their password before lockout
echo "Defaults passwd_tries=10" | sudo tee /etc/sudoers.d/passwd-tries
sudo chmod 440 /etc/sudoers.d/passwd-tries

# Increase lockout limit to 10 and decrease timeout to 2 minutes
sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=120|' "/etc/pam.d/system-auth"
sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=120|' "/etc/pam.d/system-auth"

# Solve common flakiness with SSH
echo "net.ipv4.tcp_mtu_probing=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf

sudo usermod -aG docker $USER
newgrp docker
