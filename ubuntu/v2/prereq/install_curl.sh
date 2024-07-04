#!/bin/bash

install_curl() {
    echo "Checking if curl is installed..."
    if [[ ! $(command -v curl) ]]; then
        echo "Curl not found. Installing curl..."
        sudo apt install -y curl || { log_error "install_curl - sudo apt install curl"; error_exit; }
        echo "Curl installation completed successfully."
    else
        echo "Curl is already installed."
    fi
}

install_curl
