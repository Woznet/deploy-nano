#!/bin/bash

# Utility functions
error_exit() {
    echo "Error occurred, check $LOGFILE for details." >&2
    exit 1
}

log_error() {
    echo "Error occurred in $1, check $LOGFILE for details." >&2
    echo "Error in $1" >>$LOGFILE
}

# Critical functions
update_software() {
    echo "Starting software update..."
    sudo DEBIAN_FRONTEND=noninteractive apt update || {
        log_error "update_software - sudo DEBIAN_FRONTEND=noninteractive apt update"
        error_exit
    }
    echo "Software update completed successfully."
}

install_software() {
    echo "Starting installation of required software packages..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y apt-transport-https curl software-properties-common git-all \
        autopoint build-essential devhelp devhelp-common freetype2-doc g++-multilib gcc-multilib wget xdg-utils \
        glibc-doc glibc-doc-reference glibc-source groff groff-base language-pack-en language-pack-en-base clang \
        libasprintf-dev libbsd-dev libc++-dev libc6 libc6-dev libcairo2-dev libcairo2-doc libc-ares-dev python3-pip \
        libc-dev libev-dev libgettextpo-dev libgirepository1.0-dev libglib2.0-doc libice-doc libmagic1 ca-certificates \
        libmagic-dev libmagick++-dev libmagics++-dev libncurses5-dev libncurses-dev libncursesw5-dev python-is-python3 \
        libsm-doc libx11-doc libxcb-doc libxext-doc libxml2-utils ncurses-doc pkg-config zlib1g-dev net-tools gpg \
        ffmpeg ffmpeg-doc most openssh-client openssh-known-hosts openssh-tests python3 python3-doc p7zip-full p7zip-rar ||
        {
            log_error "install_software - sudo DEBIAN_FRONTEND=noninteractive apt install"
            error_exit
        }
    echo "Software installation completed successfully."
}

install_updates() {
    echo "Starting full upgrade..."
    sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -y || {
        log_error "install_updates - sudo full-upgrade"
        error_exit
    }
    echo "Full upgrade completed successfully."
}

configure_userenv() {
    echo "Starting user environment configuration setup..."

    # Dotnet config
    echo "Configuring dotnet packages..."
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-mspkgs | sudo tee /etc/apt/preferences.d/dotnet-mspkgs || {
        log_error "configure_userenv - curl dotnet-mspkgs"
        error_exit
    }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-cli-config.sh | sudo tee /etc/profile.d/dotnet-cli-config.sh || {
        log_error "configure_userenv - curl dotnet-cli-config"
        error_exit
    }
    echo "Dotnet configuration completed successfully."

    # Generate SSH keys
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo -e "\e[4m\e[38;2;233;125;60mCreating ssh key ~/.ssh/id_rsa\e[0m"
        ssh-keygen -t rsa -b 4096 -C "$(id --name --user)@$(hostname --fqdn)" -N "" -f ~/.ssh/id_rsa || {
            log_error "configure_userenv - ssh-keygen"
            error_exit
        }
        echo "SSH key generated successfully."
    else
        echo "SSH key already exists."
    fi

    # Set clock to 12 hour format
    if [[ $(command -v gsettings) ]]; then
        gsettings set org.gnome.desktop.interface clock-format 12h || {
            log_error "configure_userenv - gsettings"
            error_exit
        }
        echo "Clock format set to 12 hour."
    fi

    # Config bashrc and aliases
    echo "Configuring .bashrc and .bash_aliases..."
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bashrc | tee ~/.bashrc >/dev/null || {
        log_error "configure_userenv - curl .bashrc"
        error_exit
    }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bash_aliases | tee ~/.bash_aliases >/dev/null || {
        log_error "configure_userenv - curl .bash_aliases"
        error_exit
    }

    # Link user bashrc and aliases to root
    sudo cp --force ~/.bashrc /root/.bashrc || {
        log_error "configure_userenv - cp .bashrc"
        error_exit
    }
    sudo ln --force ~/.bash_aliases /root/.bash_aliases || {
        log_error "configure_userenv - ln .bash_aliases"
        error_exit
    }

    # Config sudoers and inputrc
    echo "Configuring sudoers and inputrc..."
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/sudoers.woz | sudo tee /etc/sudoers.d/woz >/dev/null || {
        log_error "configure_userenv - curl sudoers.woz"
        error_exit
    }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/inputrc | sudo tee /etc/inputrc >/dev/null || {
        log_error "configure_userenv - curl inputrc"
        error_exit
    }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/20-disable-ipv6.conf | sudo tee /etc/sysctl.d/20-disable-ipv6.conf >/dev/null || {
        log_error "configure_userenv - curl 20-disable-ipv6.conf"
        error_exit
    }

    # Create user directories
    echo "Creating user directories..."
    for dir in ~/git ~/temp ~/dev; do
        [ -d "$dir" ] || mkdir -v "$dir" || {
            log_error "configure_userenv - mkdir $dir"
            error_exit
        }
    done

    echo "User environment configuration setup completed successfully."
}

# Non-critical functions
remove_rhythmbox() {
    echo "Starting removal of Rhythmbox and Aisleriot..."
    sudo DEBIAN_FRONTEND=noninteractive apt purge -y rhythmbox* aisleriot || {
        log_error "remove_rhythmbox - sudo DEBIAN_FRONTEND=noninteractive apt purge"
        error_exit
    }
    echo "Rhythmbox and Aisleriot removal completed successfully."
}

configure_dotnet() {
    echo "Starting configuration of Dotnet packages..."
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-mspkgs | sudo tee /etc/apt/preferences.d/dotnet-mspkgs || {
        log_error "configure_dotnet - curl dotnet-mspkgs"
        error_exit
    }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-cli-config.sh | sudo tee /etc/profile.d/dotnet-cli-config.sh || {
        log_error "configure_dotnet - curl dotnet-cli-config"
        error_exit
    }
    echo "Dotnet configuration completed successfully."
}

generate_ssh_keys() {
    echo "Checking for existing SSH keys..."
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo -e "\e[4m\e[38;2;233;125;60mCreating ssh key ~/.ssh/id_rsa\e[0m"
        ssh-keygen -t rsa -b 4096 -C "$(id --name --user)@$(hostname --fqdn)" -N "" -f ~/.ssh/id_rsa || {
            log_error "generate_ssh_keys - ssh-keygen"
            error_exit
        }
        echo "SSH key generated successfully."
    else
        echo "SSH key already exists."
    fi
}

install_gh() {
    echo "Starting installation of GitHub CLI..."
    if [[ ! $(command -v gh) ]]; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg || {
            log_error "install_gh - curl githubcli-archive-keyring.gpg"
            error_exit
        }
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg || {
            log_error "install_gh - chmod"
            error_exit
        }
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list || {
            log_error "install_gh - echo repo"
            error_exit
        }
        sudo DEBIAN_FRONTEND=noninteractive apt update || {
            log_error "install_gh - sudo DEBIAN_FRONTEND=noninteractive apt update"
            error_exit
        }
        sudo DEBIAN_FRONTEND=noninteractive apt install gh -y || {
            log_error "install_gh - sudo DEBIAN_FRONTEND=noninteractive apt install gh"
            error_exit
        }
        echo "GitHub CLI installation completed successfully."
    else
        echo "GitHub CLI is already installed."
    fi
}

install_nvm() {
    echo "Starting installation of NVM and Node.js..."

    # Install NVM
    if [[ ! $(command -v nvm) && ! $(type -t nvm) == function ]]; then
        echo "Installing NVM..."
        curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash || {
            log_error "install_nvm - curl"
            error_exit
        }
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
        echo "NVM installation completed successfully."
    else
        echo "NVM is already installed."
    fi

    # Install Node.js
    if [[ ! $(command -v node) ]]; then
        echo "Installing Node.js..."
        source ~/.bashrc || {
            log_error "install_nvm - source .bashrc"
            error_exit
        }
        nvm install --lts || {
            log_error "install_nvm - nvm install"
            error_exit
        }
        nvm use default || {
            log_error "install_nvm - nvm use"
            error_exit
        }
        npm install -g tldr || {
            log_error "install_nvm - npm install tldr"
            error_exit
        }
        echo "Node.js installation completed successfully."
    else
        echo "Node.js is already installed."
    fi
}

install_pwsh() {
    echo "Starting installation of PowerShell..."
    if [[ ! $(command -v pwsh) ]]; then
        sudo DEBIAN_FRONTEND=noninteractive apt update || {
            log_error "install_pwsh - sudo DEBIAN_FRONTEND=noninteractive apt update"
            error_exit
        }
        wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" || {
            log_error "install_pwsh - wget"
            error_exit
        }
        sudo dpkg -i packages-microsoft-prod.deb || {
            log_error "install_pwsh - sudo dpkg"
            error_exit
        }
        sudo DEBIAN_FRONTEND=noninteractive apt update || {
            log_error "install_pwsh - sudo DEBIAN_FRONTEND=noninteractive apt update"
            error_exit
        }
        rm -v packages-microsoft-prod.deb || {
            log_error "install_pwsh - rm"
            error_exit
        }
        sudo DEBIAN_FRONTEND=noninteractive apt install -y powershell || {
            log_error "install_pwsh - sudo DEBIAN_FRONTEND=noninteractive apt install powershell"
            error_exit
        }
        mkdir -p "$HOME/.config/powershell/" || {
            log_error "install_pwsh - mkdir"
            error_exit
        }
        curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/profile.ps1 | sudo tee /opt/microsoft/powershell/7/profile.ps1 || {
            log_error "install_pwsh - curl profile.ps1"
            error_exit
        }
        echo "PowerShell installation completed successfully."
    else
        echo "PowerShell is already installed."
    fi
}

install_vscode() {
    echo "Starting installation of Visual Studio Code..."
    if [[ ! $(command -v code) ]]; then
        sudo apt-get install -y wget gpg || {
            log_error "install_vscode - sudo apt-get install wget gpg"
            error_exit
        }
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg || {
            log_error "install_vscode - wget gpg key"
            error_exit
        }
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg || {
            log_error "install_vscode - sudo install gpg key"
            error_exit
        }
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' || {
            log_error "install_vscode - add vscode repo"
            error_exit
        }
        rm -f packages.microsoft.gpg || {
            log_error "install_vscode - rm gpg file"
            error_exit
        }
        sudo DEBIAN_FRONTEND=noninteractive apt update || {
            log_error "install_vscode - sudo DEBIAN_FRONTEND=noninteractive apt update"
            error_exit
        }
        sudo DEBIAN_FRONTEND=noninteractive apt install -y code || {
            log_error "install_vscode - sudo DEBIAN_FRONTEND=noninteractive apt install code"
            error_exit
        }
        echo "Visual Studio Code installation completed successfully."
    else
        echo "Visual Studio Code is already installed."
    fi
}

save_docker() {
    echo "Saving Docker install script..."
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/install-docker.sh | tee ~/temp/install-docker.sh || {
        log_error "save_docker - curl install-docker"
        error_exit
    }
    echo "Docker install script saved successfully."
}

remove_nano() {
    echo "Checking if nano is installed..."
    if [[ $(command -v nano) ]]; then
        echo "Nano is installed. Removing nano..."
        sudo DEBIAN_FRONTEND=noninteractive apt remove -y nano >/dev/null || {
            log_error "remove_nano - sudo DEBIAN_FRONTEND=noninteractive apt remove nano"
            error_exit
        }
        echo "Nano removed successfully."
    else
        echo "Nano is not installed."
    fi
}

clone_nano_syntax() {
    echo "Cloning nano syntax highlighting repository..."
    sudo rm --recursive --force ~/git/nano-syntax-highlighting || {
        log_error "clone_nano_syntax - rm -rf"
        error_exit
    }
    cd ~/git
    git clone https://github.com/galenguyer/nano-syntax-highlighting.git || {
        log_error "clone_nano_syntax - git clone"
        error_exit
    }
    readlink -f ./nano-syntax-highlighting >/tmp/nanosyntaxpath.tmp
    echo "Cloned nano syntax highlighting repository successfully."
}

download_nano() {
    echo "Downloading nano source..."
    cd ~/temp
    sudo rm --recursive --force ./nano-*
    wget https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/nano-8.2.tar.xz || {
        log_error "download_nano - wget"
        error_exit
    }
    tar -xf nano-8.2.tar.xz || {
        log_error "download_nano - tar -xf"
        error_exit
    }
    cd nano-8.2
    readlink -f . >/tmp/nanobuildpath.tmp
    echo "Downloaded and extracted nano source successfully."
}

build_nano() {
    echo "Configuring and building nano..."
    cd $(cat /tmp/nanobuildpath.tmp)
    sudo ./configure --prefix=/usr \
        --sysconfdir=/etc \
        --enable-utf8 \
        --enable-color \
        --enable-extra \
        --enable-nanorc \
        --enable-multibuffer \
        --docdir=/usr/share/doc/nano-8.2 >>/tmp/nano-config.log || {
        log_error "build_nano - configure"
        error_exit
    }
    sudo make >>/tmp/nano-make.log || {
        log_error "build_nano - make"
        error_exit
    }
    echo "Configured and built nano successfully."
}

install_nano() {
    echo "Installing nano..."
    sudo -i
    cd $(cat /tmp/nanobuildpath.tmp)
    sudo make install >>/tmp/nano-makeinstall.log || {
        log_error "install_nano - make install"
        error_exit
    }
    sudo install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-8.2 >>/tmp/nano-makeinstall.log || {
        log_error "install_nano - install docs"
        error_exit
    }
    echo "Nano installed successfully."
}

configure_nano() {
    echo "Configuring nano..."
    sudo cp /etc/nanorc /etc/nanorc.bak >/dev/null || {
        log_error "configure_nano - cp nanorc"
        error_exit
    }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/nanorc | sudo tee /etc/nanorc >/dev/null || {
        log_error "configure_nano - curl nanorc"
        error_exit
    }
    sudo mv --force $(cat /tmp/nanosyntaxpath.tmp)/*.nanorc /usr/share/nano/ >/dev/null || {
        log_error "configure_nano - mv syntax files"
        error_exit
    }
    sudo chmod --changes =644 /usr/share/nano/*.nanorc >/dev/null || {
        log_error "configure_nano - chmod syntax files"
        error_exit
    }
    sudo chown --changes --recursive root:root /usr/share/nano/ >/dev/null || {
        log_error "configure_nano - chown syntax files"
        error_exit
    }
    sudo rm -v /tmp/*.tmp >/dev/null || {
        log_error "configure_nano - rm tmp files"
        error_exit
    }
    echo "Nano configured successfully."
}

set_default_editor() {
    echo "Setting nano as the default editor..."
    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nano 1 || {
        log_error "set_default_editor - update-alternatives --install"
        error_exit
    }
    sudo update-alternatives --set editor /usr/bin/nano || {
        log_error "set_default_editor - update-alternatives --set"
        error_exit
    }
    echo "Nano set as the default editor successfully."
}

remove_tmpfiles() {
    echo "Deleting /tmp/nanosyntaxpath.tmp and /tmp/nanobuildpath.tmp"
    sudo rm /tmp/nanosyntaxpath.tmp
    sudo rm /tmp/nanobuildpath.tmp
}
