#!/bin/bash

# install curl if needed
if [[ ! $(which curl) ]]; then
    sudo apt install -y curl
fi

# config bashrc and aliases
curl https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bashrc | tee ~/.bashrc >/dev/null
curl https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bash_aliases | tee ~/.bash_aliases >/dev/null

# link user bashrc and aliases to root
sudo ln ~/.bashrc /root/.bashrc
sudo ln ~/.bash_aliases /root/.bash_aliases

# config sudoers and inputrc
curl https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/sudoers.woz | sudo tee /etc/sudoers.d/woz >/dev/null
curl https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/inputrc | sudo tee /etc/inputrc >/dev/null

# create user directories
mkdir -v ~/{git,temp}

# start install-apps.sh script
# curl -o- https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/install-apps.sh | bash

# install software
sudo apt install -y apt-transport-https curl software-properties-common wget xdg-utils git-all autopoint build-essential clang devhelp devhelp-common freetype2-doc g++-multilib gcc-multilib gettext gettext-doc glibc-doc glibc-doc-reference glibc-source groff groff-base language-pack-en language-pack-en-base libasprintf-dev libbsd-dev libc++-dev libc6 libc6-dev libcairo2-dev libcairo2-doc libc-ares-dev libc-dev libev-dev libgettextpo-dev libgirepository1.0-dev libglib2.0-doc libice-doc libmagic1 libmagic-dev libmagick++-dev libmagics++-dev libncurses5-dev libncurses-dev libncursesw5-dev libsm-doc libx11-doc libxcb-doc libxext-doc libxml2-utils ncurses-doc pkg-config zlib1g-dev ffmpeg ffmpeg-doc

# install powershell
if [[ ! $(which pwsh) ]]; then
    sudo apt update &&
        wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" &&
        sudo dpkg -i packages-microsoft-prod.deb &&
        sudo apt update &&
        rm -v packages-microsoft-prod.deb &&
        sudo apt install -y powershell
fi

# install gh
if [[ ! $(which gh) ]]; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
        sudo apt update &&
        sudo apt install gh -y
fi

# install nvm
if [[ ! -d "$HOME/.nvm" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash &&
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" &&
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
fi

# install node
if [[ ! $(which node) ]]; then
    nvm install node
fi

# install npm
if [[ ! $(which npm) ]]; then
    nvm install-latest-npm
fi

# start build-nano.sh script
# curl -o- https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/build-nano.sh | bash

if [[ $(which nano) ]]; then
    sudo apt remove -y nano >/dev/null
fi

cd ~/git
git clone https://github.com/galenguyer/nano-syntax-highlighting.git
readlink -f ./nano-syntax-highlighting >/tmp/nanosyntaxpath.tmp

cd ~/temp

# wget https://www.nano-editor.org/dist/v7/nano-7.2.tar.xz
# tar -xf nano-7.2.tar.xz
# cd nano-7.2

git clone https://git.savannah.gnu.org/git/nano.git
cd nano
tag=$(git describe --tags $(git rev-list --tags --max-count=1))
git checkout $tag -b latest

readlink -f . >/tmp/nanobuildpath.tmp

./configure --prefix=/usr \
    --sysconfdir=/etc \
    --enable-utf8 \
    --enable-color \
    --enable-extra \
    --enable-nanorc \
    --enable-multibuffer \
    --docdir=/usr/share/doc/nano-7.2 >/tmp/nano-config.log &&
    make >/tmp/nano-make.log

sudo -i
cd $(cat /tmp/nanobuildpath.tmp)

make install >/tmp/nano-makeinstall.log &&
    install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-7.2

cp /etc/nanorc /etc/nanorc.bak >/dev/null
curl https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/nanorc | tee /etc/nanorc >/dev/null

mv --force $(cat /tmp/nanosyntaxpath.tmp)/*.nanorc /usr/share/nano/ >/dev/null
chmod --changes =644 /usr/share/nano/*.nanorc
chown --changes --recursive root:root /usr/share/nano/

rm -v /tmp/*.tmp

