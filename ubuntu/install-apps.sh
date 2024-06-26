#!/bin/bash

set -e
set -x

# Log file for errors
LOGFILE="error.log"
exec 2>$LOGFILE

# remove rhythmbox
sudo apt purge -y rhythmbox* aisleriot

# update software
sudo apt update

# install updates
sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -y

# install software
sudo DEBIAN_FRONTEND=noninteractive apt install -y apt-transport-https curl software-properties-common git-all \
    autopoint build-essential devhelp devhelp-common freetype2-doc g++-multilib gcc-multilib wget xdg-utils \
    glibc-doc glibc-doc-reference glibc-source groff groff-base language-pack-en language-pack-en-base clang \
    libasprintf-dev libbsd-dev libc++-dev libc6 libc6-dev libcairo2-dev libcairo2-doc libc-ares-dev python3-pip \
    libc-dev libev-dev libgettextpo-dev libgirepository1.0-dev libglib2.0-doc libice-doc libmagic1 ca-certificates \
    libmagic-dev libmagick++-dev libmagics++-dev libncurses5-dev libncurses-dev libncursesw5-dev python-is-python3 \
    libsm-doc libx11-doc libxcb-doc libxext-doc libxml2-utils ncurses-doc pkg-config zlib1g-dev net-tools gpg \
    ffmpeg ffmpeg-doc most openssh-client openssh-known-hosts openssh-tests python3 python3-doc p7zip-full p7zip-rar

# dotnet config
## dotnet packages from only packages.microsoft.com
curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-mspkgs | sudo tee /etc/apt/preferences.d/dotnet-mspkgs >/dev/null
## dotnet set variables
curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-cli-config.sh | sudo tee /etc/profile.d/dotnet-cli-config.sh >/dev/null

# generate ssh keys
if [ ! -f ~/.ssh/id_rsa ]; then
    echo -e "\e[4m\e[38;2;233;125;60mCreating ssh key ~/.ssh/id_rsa\e[0m"
    ssh-keygen -t rsa -b 4096 -C "$(id --name --user)@$(hostname --fqdn)" -N "" -f ~/.ssh/id_rsa
fi

# install powershell
if [[ ! $(which pwsh) ]]; then
    sudo apt update
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt update
    rm -v packages-microsoft-prod.deb
    sudo DEBIAN_FRONTEND=noninteractive apt install -y powershell
    mkdir -p $HOME/.config/powershell/
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/profile.ps1 | sudo tee /opt/microsoft/powershell/7/profile.ps1 >/dev/null
fi

# install gh
if [[ ! $(which gh) ]]; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install gh -y
fi

# install nvm
if [[ ! -d "$HOME/.nvm" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
fi

# install node
if [[ ! $(which node) ]]; then
    source ~/.bashrc
    nvm install --lts
    nvm use default
    npm install -g tldr
fi

# install vscode
if [[ ! $(which code) ]]; then
    sudo apt-get install -y wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y code
fi

# Set clock to 12 hour format
if [[ $(which gsettings) ]]; then
    gsettings set org.gnome.desktop.interface clock-format 12h
fi

# Save Docker Install script
curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/install-docker.sh | tee ~/temp/install-docker.sh >/dev/null

# start build-nano.sh script
curl -o- https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/build-nano.sh | bash
