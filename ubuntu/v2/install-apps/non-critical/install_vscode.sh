#!/bin/bash

install_vscode() {
    echo "Starting installation of Visual Studio Code..."
    if [[ ! $(command -v code) ]]; then
        sudo apt-get install -y wget gpg || { log_error "install_vscode - sudo apt-get install wget gpg"; error_exit; }
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg || { log_error "install_vscode - wget gpg key"; error_exit; }
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg || { log_error "install_vscode - sudo install gpg key"; error_exit; }
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' || { log_error "install_vscode - add vscode repo"; error_exit; }
        rm -f packages.microsoft.gpg || { log_error "install_vscode - rm gpg file"; error_exit; }
        sudo apt update || { log_error "install_vscode - sudo apt update"; error_exit; }
        sudo DEBIAN_FRONTEND=noninteractive apt install -y code || { log_error "install_vscode - sudo apt install code"; error_exit; }
        echo "Visual Studio Code installation completed successfully."
    else
        echo "Visual Studio Code is already installed."
    fi
}

install_vscode
