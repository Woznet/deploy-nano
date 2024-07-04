#!/bin/bash

install_gh() {
    echo "Starting installation of GitHub CLI..."
    if [[ ! $(command -v gh) ]]; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg || { log_error "install_gh - curl githubcli-archive-keyring.gpg"; error_exit; }
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg || { log_error "install_gh - chmod"; error_exit; }
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list || { log_error "install_gh - echo repo"; error_exit; }
        sudo apt update || { log_error "install_gh - sudo apt update"; error_exit; }
        sudo DEBIAN_FRONTEND=noninteractive apt install gh -y || { log_error "install_gh - sudo apt install gh"; error_exit; }
        echo "GitHub CLI installation completed successfully."
    else
        echo "GitHub CLI is already installed."
    fi
}

install_gh
