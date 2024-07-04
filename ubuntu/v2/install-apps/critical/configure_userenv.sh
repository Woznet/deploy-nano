#!/bin/bash

configure_userenv() {
    echo "Starting user environment configuration setup..."

    # Dotnet config
    echo "Configuring dotnet packages..."
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-mspkgs | sudo tee /etc/apt/preferences.d/dotnet-mspkgs || { log_error "configure_userenv - curl dotnet-mspkgs"; error_exit; }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-cli-config.sh | sudo tee /etc/profile.d/dotnet-cli-config.sh || { log_error "configure_userenv - curl dotnet-cli-config"; error_exit; }
    echo "Dotnet configuration completed successfully."

    # Generate SSH keys
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo -e "\e[4m\e[38;2;233;125;60mCreating ssh key ~/.ssh/id_rsa\e[0m"
        ssh-keygen -t rsa -b 4096 -C "$(id --name --user)@$(hostname --fqdn)" -N "" -f ~/.ssh/id_rsa || { log_error "configure_userenv - ssh-keygen"; error_exit; }
        echo "SSH key generated successfully."
    else
        echo "SSH key already exists."
    fi

    # Set clock to 12 hour format
    if [[ $(command -v gsettings) ]]; then
        gsettings set org.gnome.desktop.interface clock-format 12h || { log_error "configure_userenv - gsettings"; error_exit; }
        echo "Clock format set to 12 hour."
    fi

    # Config bashrc and aliases
    echo "Configuring .bashrc and .bash_aliases..."
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bashrc | tee ~/.bashrc >/dev/null || { log_error "configure_userenv - curl .bashrc"; error_exit; }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bash_aliases | tee ~/.bash_aliases >/dev/null || { log_error "configure_userenv - curl .bash_aliases"; error_exit; }

    # Link user bashrc and aliases to root
    sudo cp --force ~/.bashrc /root/.bashrc || { log_error "configure_userenv - cp .bashrc"; error_exit; }
    sudo ln --force ~/.bash_aliases /root/.bash_aliases || { log_error "configure_userenv - ln .bash_aliases"; error_exit; }

    # Config sudoers and inputrc
    echo "Configuring sudoers and inputrc..."
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/sudoers.woz | sudo tee /etc/sudoers.d/woz >/dev/null || { log_error "configure_userenv - curl sudoers.woz"; error_exit; }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/inputrc | sudo tee /etc/inputrc >/dev/null || { log_error "configure_userenv - curl inputrc"; error_exit; }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/20-disable-ipv6.conf | sudo tee /etc/sysctl.d/20-disable-ipv6.conf >/dev/null || { log_error "configure_userenv - curl 20-disable-ipv6.conf"; error_exit; }

    # Create user directories
    echo "Creating user directories..."
    mkdir -v ~/{git,temp,dev} || { log_error "configure_userenv - mkdir user directories"; error_exit; }

    echo "User environment configuration setup completed successfully."
}

configure_userenv
