#!/bin/bash

# install software
sudo apt install -y apt-transport-https curl software-properties-common wget xdg-utils git-all autopoint build-essential clang devhelp devhelp-common freetype2-doc g++-multilib gcc-multilib gettext gettext-doc glibc-doc glibc-doc-reference glibc-source groff groff-base language-pack-en language-pack-en-base libasprintf-dev libbsd-dev libc++-dev libc6 libc6-dev libcairo2-dev libcairo2-doc libc-ares-dev libc-dev libev-dev libgettextpo-dev libgirepository1.0-dev libglib2.0-doc libice-doc libmagic1 libmagic-dev libmagick++-dev libmagics++-dev libncurses5-dev libncurses-dev libncursesw5-dev libsm-doc libx11-doc libxcb-doc libxext-doc libxml2-utils ncurses-doc pkg-config zlib1g-dev ffmpeg ffmpeg-doc

# install powershell
if [[ ! $(which pwsh) ]] ; then
    sudo apt update && \
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    sudo apt update && \
    rm -v packages-microsoft-prod.deb && \
    sudo apt install -y powershell
fi

# install gh
if [[ ! $(which gh) ]] ; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    sudo apt update && \
    sudo apt install gh -y
fi

# install nvm
if [[ ! $(which nvm) ]] ; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash && \
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
fi

# install node
if [[ ! $(which node) ]] ; then
    nvm install node
fi

# install npm
if [[ ! $(which npm) ]] ; then
    nvm install-latest-npm
fi


# start build-nano.sh script
curl -o- https://raw.githubusercontent.com/Woznet/deploy-nano-win/main/ubuntu/build-nano.sh | bash

