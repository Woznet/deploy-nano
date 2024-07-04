#!/bin/bash

download_nano() {
    echo "Downloading nano source..."
    cd ~/temp
    wget https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/nano-8.0.tar.xz || { log_error "download_nano - wget"; error_exit; }
    tar -xf nano-8.0.tar.xz || { log_error "download_nano - tar -xf"; error_exit; }
    cd nano-8.0
    readlink -f . >>/tmp/nanobuildpath.tmp
    echo "Downloaded and extracted nano source successfully."
}

download_nano
