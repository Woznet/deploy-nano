#!/bin/bash

# Non-critical functions
remove_rhythmbox() {
    log "Starting removal of Rhythmbox and Aisleriot..."
    run_command "sudo apt purge -y rhythmbox* aisleriot"
    log "Rhythmbox and Aisleriot removal completed successfully."
}

configure_dotnet() {
    log "Starting configuration of Dotnet packages..."
    download_file "$DOTNET_CONFIG_URL" "/etc/apt/preferences.d/dotnet-mspkgs"
    download_file "$DOTNET_PROFILE_URL" "/etc/profile.d/dotnet-cli-config.sh"
    log "Dotnet configuration completed successfully."
}

generate_ssh_keys() {
    log "Checking for existing SSH keys..."
    if [ ! -f ~/.ssh/id_rsa ]; then
        log "Creating SSH key at ~/.ssh/id_rsa"
        run_command "ssh-keygen -t rsa -b 4096 -C \"$(id --name --user)@$(hostname --fqdn)\" -N \"\" -f ~/.ssh/id_rsa"
        log "SSH key generated successfully."
    else
        log "SSH key already exists."
    fi
}

install_gh() {
    log "Starting installation of GitHub CLI..."
    if [[ ! $(command -v gh) ]]; then
        run_command "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
        run_command "sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg"
        run_command "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list"
        run_command "sudo apt update"
        run_command "sudo apt install gh -y"
        log "GitHub CLI installation completed successfully."
    else
        log "GitHub CLI is already installed."
    fi
}

install_nvm() {
    log "Starting installation of NVM and Node.js..."

    # Install NVM
    if [[ ! $(command -v nvm) && ! $(type -t nvm) == function ]]; then
        log "Installing NVM..."
        run_command "curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash"
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        log "NVM installation completed successfully."
    else
        log "NVM is already installed."
    fi

    # Install Node.js
    if [[ ! $(command -v node) ]]; then
        log "Installing Node.js..."
        source ~/.bashrc
        run_command "nvm install --lts"
        run_command "nvm use default"
        log "Node.js installation completed successfully."
    else
        log "Node.js is already installed."
    fi

    # Install tldr
    if [[ ! $(command -v tldr) ]]; then
        log "Installing tldr..."
        source ~/.bashrc
        run_command "npm install -g tldr"
        log "tldr installation completed successfully."
    else
        log "tldr is already installed."
    fi
}

install_pwsh() {
    log "Starting installation of PowerShell..."
    if [[ ! $(command -v pwsh) ]]; then
        run_command "sudo apt update"
        run_command "wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
        run_command "sudo dpkg -i packages-microsoft-prod.deb"
        run_command "sudo apt update"
        run_command "rm -v packages-microsoft-prod.deb"
        run_command "sudo apt install -y powershell"
        log "PowerShell installation completed successfully."
    else
        log "PowerShell is already installed."
    fi
}

install_vscode() {
    log "Starting installation of Visual Studio Code..."
    if [[ ! $(command -v code) ]]; then
        run_command "sudo apt-get install -y wget gpg"
        run_command "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --yes --dearmor >packages.microsoft.gpg"
        run_command "sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg"
        run_command "sudo sh -c 'echo \"deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main\" > /etc/apt/sources.list.d/vscode.list'"
        run_command "rm -f packages.microsoft.gpg"
        run_command "sudo apt update"
        run_command "sudo apt install -y code"
        log "Visual Studio Code installation completed successfully."
    else
        log "Visual Studio Code is already installed."
    fi
}

install_az() {
    log "Starting installation of Azure Cli..."
    if [[ ! $(command -v /usr/bin/az) ]]; then
        run_command "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
        log "Azure Cli installation completed successfully."
    else
        log "Azure Cli is already installed."
    fi
}

install_1password() {
    log "Starting installation of 1Password..."
    if [[ ! $(command -v 1password) || ! $(command -v op) ]]; then
        run_command "curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --yes --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg"
        run_command "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/\$(dpkg --print-architecture) stable main\" | sudo tee /etc/apt/sources.list.d/1password.list"
        run_command "sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/"
        run_command "curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol"
        run_command "sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22"
        run_command "curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --yes --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg"
        run_command "sudo apt update"
        run_command "sudo apt install -y 1password"
        run_command "sudo apt install -y 1password-cli"
        log "1Password installation completed successfully."
    else
        log "1Password is already installed."
    fi
}

save_docker() {
    log "Saving Docker install script..."
    download_file "https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/install-docker.sh" "$HOME/temp/install-docker.sh"
    log "Docker install script saved successfully."
}

remove_nano() {
    log "Checking if nano is installed..."
    if [[ $(command -v nano) ]]; then
        log "Nano is installed. Removing nano..."
        run_command "sudo apt remove -y nano"
        log "Nano removed successfully."
    else
        log "Nano is not installed."
    fi
}

clone_nano_syntax() {
    log "Cloning nano syntax highlighting repository..."
    run_command "sudo rm --recursive --force $HOME/git/nano-syntax-highlighting"
    run_command "git clone https://github.com/galenguyer/nano-syntax-highlighting.git $HOME/git/nano-syntax-highlighting"
    readlink -f "$HOME/git/nano-syntax-highlighting" >/tmp/nanosyntaxpath.tmp
    log "Cloned nano syntax highlighting repository successfully."
}

download_nano() {
    log "Downloading nano source..."
    cd "$HOME/temp"
    run_command "sudo rm --recursive --force ./nano-*"
    run_command "wget https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/nano-8.2.tar.xz"
    run_command "tar -xf nano-8.2.tar.xz"
    readlink -f "nano-8.2" >/tmp/nanobuildpath.tmp
    log "Downloaded and extracted nano source successfully."
}

build_nano() {
    log "Configuring and building nano..."
    cd $(cat /tmp/nanobuildpath.tmp)
    run_command "sudo ./configure --prefix=/usr --sysconfdir=/etc --enable-utf8 --enable-color --enable-extra --enable-nanorc --enable-multibuffer --docdir=/usr/share/doc/nano-8.2"
    run_command "sudo make"
    log "Configured and built nano successfully."
}

install_nano() {
    log "Installing nano..."
    cd $(cat /tmp/nanobuildpath.tmp)
    run_command "sudo make install"
    run_command "sudo install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-8.2"
    log "Nano installed successfully."
}

configure_nano() {
    log "Configuring nano..."
    run_command "sudo cp /etc/nanorc /etc/nanorc.bak"
    run_command "curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/nanorc | sudo tee /etc/nanorc >/dev/null"
    run_command "sudo mv --force $(cat /tmp/nanosyntaxpath.tmp)/*.nanorc /usr/share/nano/"
    run_command "sudo chmod --changes =644 /usr/share/nano/*.nanorc"
    run_command "sudo chown --changes --recursive root:root /usr/share/nano/"
    log "Nano configured successfully."
}

set_default_editor() {
    log "Setting nano as the default editor..."
    run_command "sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nano 1"
    run_command "sudo update-alternatives --set editor /usr/bin/nano"
    log "Nano set as the default editor successfully."
}

remove_tmpfiles() {
    log "Deleting temporary files in /tmp directory..."
    run_command "sudo rm /tmp/nanosyntaxpath.tmp /tmp/nanobuildpath.tmp"
    log "Temporary files deleted successfully."
}
