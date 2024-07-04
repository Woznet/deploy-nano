#!/bin/bash

install_pwsh() {
    echo "Starting installation of PowerShell..."
    if [[ ! $(command -v pwsh) ]]; then
        sudo apt update || { log_error "install_pwsh - sudo apt update"; error_exit; }
        wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" || { log_error "install_pwsh - wget"; error_exit; }
        sudo dpkg -i packages-microsoft-prod.deb || { log_error "install_pwsh - sudo dpkg"; error_exit; }
        sudo apt update || { log_error "install_pwsh - sudo apt update"; error_exit; }
        rm -v packages-microsoft-prod.deb || { log_error "install_pwsh - rm"; error_exit; }
        sudo DEBIAN_FRONTEND=noninteractive apt install -y powershell || { log_error "install_pwsh - sudo apt install powershell"; error_exit; }
        mkdir -p "$HOME/.config/powershell/" || { log_error "install_pwsh - mkdir"; error_exit; }
        curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/profile.ps1 | sudo tee /opt/microsoft/powershell/7/profile.ps1 || { log_error "install_pwsh - curl profile.ps1"; error_exit; }
        echo "PowerShell installation completed successfully."
    else
        echo "PowerShell is already installed."
    fi
}

install_pwsh
