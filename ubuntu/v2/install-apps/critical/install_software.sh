#!/bin/bash

install_software() {
    echo "Starting installation of required software packages..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y apt-transport-https curl software-properties-common git-all \
        autopoint build-essential devhelp devhelp-common freetype2-doc g++-multilib gcc-multilib wget xdg-utils \
        glibc-doc glibc-doc-reference glibc-source groff groff-base language-pack-en language-pack-en-base clang \
        libasprintf-dev libbsd-dev libc++-dev libc6 libc6-dev libcairo2-dev libcairo2-doc libc-ares-dev python3-pip \
        libc-dev libev-dev libgettextpo-dev libgirepository1.0-dev libglib2.0-doc libice-doc libmagic1 ca-certificates \
        libmagic-dev libmagick++-dev libmagics++-dev libncurses5-dev libncurses-dev libncursesw5-dev python-is-python3 \
        libsm-doc libx11-doc libxcb-doc libxext-doc libxml2-utils ncurses-doc pkg-config zlib1g-dev net-tools gpg \
        ffmpeg ffmpeg-doc most openssh-client openssh-known-hosts openssh-tests python3 python3-doc p7zip-full p7zip-rar \
        || { log_error "install_software - sudo apt install"; exit 1; }
    echo "Software installation completed successfully."
}

install_software
