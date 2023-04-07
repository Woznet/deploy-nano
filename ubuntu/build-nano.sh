#!/bin/bash


if [[ $(which nano) ]] ; then
  sudo apt remove -y nano > /dev/null
fi


cd ~/git
git clone https://github.com/galenguyer/nano-syntax-highlighting.git
readlink -f ./nano-syntax-highlighting > /tmp/nanosyntaxpath.tmp

cd ~/temp

# wget https://www.nano-editor.org/dist/v7/nano-7.2.tar.xz
# tar -xf nano-7.2.tar.xz
# cd nano-7.2

git clone https://git.savannah.gnu.org/git/nano.git
cd nano
tag=$(git describe --tags `git rev-list --tags --max-count=1`)
git checkout $tag -b latest


readlink -f . > /tmp/nanobuildpath.tmp

./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --enable-utf8        \
            --enable-color       \
            --enable-extra       \
            --enable-nanorc      \
            --enable-multibuffer \
            --docdir=/usr/share/doc/nano-7.2 > /tmp/nano-config.log &&
make > /tmp/nano-make.log

sudo -i
cd $(cat /tmp/nanobuildpath.tmp)

make install > /tmp/nano-makeinstall.log &&
    install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-7.2

cp /etc/nanorc /etc/nanorc.bak > /dev/null
curl https://raw.githubusercontent.com/Woznet/deploy-nano-win/main/ubuntu/config/nanorc | tee /etc/nanorc > /dev/null

mv --force $(cat /tmp/nanosyntaxpath.tmp)/*.nanorc /usr/share/nano/ > /dev/null
chmod --changes =644 /usr/share/nano/*.nanorc
chown --changes --recursive root:root /usr/share/nano/

rm -v /tmp/*.tmp
