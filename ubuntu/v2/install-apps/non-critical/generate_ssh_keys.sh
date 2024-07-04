#!/bin/bash

generate_ssh_keys() {
    echo "Checking for existing SSH keys..."
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo -e "\e[4m\e[38;2;233;125;60mCreating ssh key ~/.ssh/id_rsa\e[0m"
        ssh-keygen -t rsa -b 4096 -C "$(id --name --user)@$(hostname --fqdn)" -N "" -f ~/.ssh/id_rsa || { log_error "generate_ssh_keys - ssh-keygen"; error_exit; }
        echo "SSH key generated successfully."
    else
        echo "SSH key already exists."
    fi
}

generate_ssh_keys
