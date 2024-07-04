#!/bin/bash

build_nano() {
    echo "Configuring and building nano..."
    cd $(cat /tmp/nanobuildpath.tmp)
    ./configure --prefix=/usr \
      --sysconfdir=/etc \
      --enable-utf8 \
      --enable-color \
      --enable-extra \
      --enable-nanorc \
      --enable-multibuffer \
      --docdir=/usr/share/doc/nano-8.0 >>/tmp/nano-config.log || { log_error "build_nano - configure"; error_exit; }
    make >>/tmp/nano-make.log || { log_error "build_nano - make"; error_exit; }
    echo "Configured and built nano successfully."
}

build_nano
