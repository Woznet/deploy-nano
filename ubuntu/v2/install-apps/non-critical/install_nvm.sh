#!/bin/bash

install_nvm() {
    echo "Starting installation of NVM..."
    if [[ ! $(command -v nvm) && ! $(type -t nvm) == function ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash || { log_error "install_nvm - curl"; error_exit; }
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
        echo "NVM installation completed successfully."
    else
        echo "NVM is already installed."
    fi
}

install_nvm
