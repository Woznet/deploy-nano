#!/bin/bash

install_node() {
    echo "Starting installation of Node.js..."
    if [[ ! $(command -v node) ]]; then
        source ~/.bashrc || { log_error "install_node - source .bashrc"; error_exit; }
        nvm install --lts || { log_error "install_node - nvm install"; error_exit; }
        nvm use default || { log_error "install_node - nvm use"; error_exit; }
        npm install -g tldr || { log_error "install_node - npm install tldr"; error_exit; }
        echo "Node.js installation completed successfully."
    else
        echo "Node.js is already installed."
    fi
}

install_node
