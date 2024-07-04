#!/bin/bash

if [[ $(which nano) ]]; then
    sudo apt remove -y nano >/dev/null
fi

cd ~/git
sudo rm --recursive --force ~/git/nano-syntax-highlighting
git clone https://github.com/galenguyer/nano-syntax-highlighting.git >/dev/null
readlink -f ./nano-syntax-highlighting >/tmp/nanosyntaxpath.tmp

cd ~/temp
sudo rm --recursive --force ./nano-*
wget https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/nano-8.0.tar.xz >/dev/null
tar -xf nano-8.0.tar.xz >/dev/null
cd nano-8.0
readlink -f . >/tmp/nanobuildpath.tmp

./configure --prefix=/usr \
    --sysconfdir=/etc \
    --enable-utf8 \
    --enable-color \
    --enable-extra \
    --enable-nanorc \
    --enable-multibuffer \
    --docdir=/usr/share/doc/nano-8.0 >>/tmp/nano-config.log &&
    make >>/tmp/nano-make.log

sudo -i
cd $(cat /tmp/nanobuildpath.tmp)

make install >>/tmp/nano-makeinstall.log &&
    install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-8.0 >>/tmp/nano-makeinstall.log

cp /etc/nanorc /etc/nanorc.bak >/dev/null
curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/nanorc | tee /etc/nanorc >/dev/null

mv --force $(cat /tmp/nanosyntaxpath.tmp)/*.nanorc /usr/share/nano/ >/dev/null
chmod --changes =644 /usr/share/nano/*.nanorc >/dev/null
chown --changes --recursive root:root /usr/share/nano/ >/dev/null

rm -v /tmp/*.tmp >/dev/null

# Set up the default editor to be nano
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nano 1 &&
    sudo update-alternatives --set editor /usr/bin/nano
