#!/bin/bash

sudo apt install -y git-all clang groff groff-base ffmpeg xdg-utils ffmpeg-doc ffmpeg ncurses-doc libncurses-dev g++-multilib libc6 libc6-dev gcc-multilib libc++-dev build-essential libbsd-dev libc-dev pkg-config libncurses5-dev libncursesw5-dev zlib1g-dev libc-ares-dev libev-dev libcairo2-dev libcairo2-doc freetype2-doc libgirepository1.0-dev libglib2.0-doc libxml2-utils libice-doc libsm-doc libx11-doc libxcb-doc libxext-doc devhelp devhelp-common libmagic1 libmagic-dev libmagick++-dev libmagics++-dev

if [[ $(which nano) ]] ; then
  sudo apt remove -y nano
fi

mkdir -v ~/{git,temp}
cd ~/git
git clone https://github.com/galenguyer/nano-syntax-highlighting.git
readlink -f ./nano-syntax-highlighting > /tmp/nanosyntaxpath.tmp
cd ~/temp
wget https://www.nano-editor.org/dist/v7/nano-7.2.tar.xz
tar -xf nano-7.2.tar.xz
cd nano-7.2

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-utf8     \
            --docdir=/usr/share/doc/nano-7.2 &&
make

readlink -f . > /tmp/nanobuildpath.tmp

sudo -i
cd $(cat /tmp/nanobuildpath.tmp)

make install &&
    install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-7.2

cp /etc/nanorc /etc/nanorc.bak
curl https://raw.githubusercontent.com/Woznet/deploy-nano-win/main/ubuntu/nanorc | tee /etc/nanorc

exit

sudo mv --verbose --force $(cat /tmp/nanosyntaxpath.tmp)/*.nanorc /usr/share/nano/

rm -v /tmp/*.tmp

