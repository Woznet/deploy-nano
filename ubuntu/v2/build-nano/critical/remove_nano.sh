#!/bin/bash

remove_nano() {
    echo "Checking if nano is installed..."
    if [[ $(command -v nano) ]]; then
        echo "Nano is installed. Removing nano..."
        sudo apt remove -y nano >/dev/null || { log_error "remove_nano - sudo apt remove nano"; error_exit; }
        echo "Nano removed successfully."
    else
        echo "Nano is not installed."
    fi
}

remove_nano
