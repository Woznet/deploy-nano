#!/bin/bash

# Enable strict mode for error handling
set -e
set -o pipefail

# Directory where logs and temporary files will be stored
BASE_DIR="/tmp/install-apps"

# Log file for storing all outputs and errors
LOGFILE="$BASE_DIR/install-apps_$(date +%Y%m%d_%H%M%S).log"

# Ensure the base directory exists
mkdir -p "$BASE_DIR"

# Set the log file path and ensure permissions
touch "$LOGFILE"
chmod 0644 "$LOGFILE" # Restricting permissions to prevent potential security issues

# Enable trap after LOGFILE is defined
trap 'echo "An error occurred. Check $LOGFILE for details." >&2' ERR

# Utility functions
log() {
    local message="$1"
    local level="${2:-INFO}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOGFILE"
}

log_error() {
    log "$1" "ERROR"
}

error_exit() {
    log "Error occurred. Exiting." "ERROR"
    exit 1
}

run_command() {
    local cmd="$1"
    log "Running command: $cmd"
    eval "$cmd" || {
        log_error "Command failed: $cmd"
        error_exit
    }
}

download_file() {
    local url="$1"
    local dest="$2"
    log "Downloading $url to $dest"
    curl --silent --fail "$url" -o "$dest" || {
        log_error "Failed to download $url"
        error_exit
    }
    chmod 644 "$dest" || {
        log_error "Failed to set permissions for $dest"
        error_exit
    }
    log "Downloaded $url to $dest successfully."
}

# Function to safely source external scripts with error handling
source_external_script() {
    local url=$1
    local tmp_file="/tmp/temp_script.sh"

    # Download the script and check for errors
    if ! curl --silent --fail "$url" -o "$tmp_file"; then
        echo -e "${ORANGE_RED}Failed to download script from $url${NC}"
        log_error "Failed to download script from $url"
        exit 1
    fi

    # Source the script if download was successful
    source "$tmp_file"
    rm -f "$tmp_file"
}

# Configuration variables shared across all scripts
# URLs for downloading configuration files and scripts
DOTNET_CONFIG_URL="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-mspkgs"
DOTNET_PROFILE_URL="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-cli-config.sh"
BASHRC_URL="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bashrc"
BASH_ALIASES_URL="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bash_aliases"
SUDOERS_URL="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/sudoers.woz"
INPUTRC_URL="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/inputrc"
DISABLE_IPV6_URL="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/20-disable-ipv6.conf"

# Temporary paths for various processes
NANO_SYNTAX_TEMP_PATH="/tmp/nanosyntaxpath.tmp"
NANO_BUILD_TEMP_PATH="/tmp/nanobuildpath.tmp"

# URLs for downloading additional components
DOCKER_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/install-docker.sh"
NANO_SOURCE_URL="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/nano-8.2.tar.xz"
NANO_SYNTAX_REPO="https://github.com/galenguyer/nano-syntax-highlighting.git"

# Directory paths
NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

# Critical functions
update_software() {
    log "Starting software update..."
    run_command "sudo DEBIAN_FRONTEND=noninteractive apt update"
    log "Software update completed successfully."
}

install_software() {
    log "Starting installation of required software packages..."
    run_command "sudo DEBIAN_FRONTEND=noninteractive apt install -y apt-transport-https curl software-properties-common git-all \
    autopoint build-essential devhelp devhelp-common freetype2-doc g++-multilib gcc-multilib wget xdg-utils \
    glibc-doc glibc-doc-reference glibc-source groff groff-base language-pack-en language-pack-en-base clang \
    libasprintf-dev libbsd-dev libc++-dev libc6 libc6-dev libcairo2-dev libcairo2-doc libc-ares-dev python3-pip \
    libc-dev libev-dev libgettextpo-dev libgirepository1.0-dev libglib2.0-doc libice-doc libmagic1 ca-certificates \
    libmagic-dev libmagick++-dev libmagics++-dev libncurses5-dev libncurses-dev libncursesw5-dev python-is-python3 \
    libsm-doc libx11-doc libxcb-doc libxext-doc libxml2-utils ncurses-doc pkg-config zlib1g-dev net-tools gpg \
    ffmpeg ffmpeg-doc most openssh-client openssh-known-hosts openssh-tests python3 python3-doc p7zip-full p7zip-rar"
    log "Software installation completed successfully."
}

install_updates() {
    log "Starting full upgrade..."
    run_command "sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -y"
    log "Full upgrade completed successfully."
}

configure_userenv() {
    log "Starting user environment configuration setup..."

    # Generate SSH keys if not present
    generate_ssh_keys

    # Set clock to 12-hour format if possible
    if command -v gsettings &>/dev/null; then
        run_command "gsettings set org.gnome.desktop.interface clock-format 12h"
        log "Clock format set to 12-hour."
    fi

    # Configure .bashrc and .bash_aliases
    log "Configuring .bashrc and .bash_aliases..."
    download_file "$BASHRC_URL" "$HOME/.bashrc"
    download_file "$BASH_ALIASES_URL" "$HOME/.bash_aliases"

    # Link user bashrc and aliases to root
    run_command "sudo cp --force ~/.bashrc /root/.bashrc"
    run_command "sudo ln --force ~/.bash_aliases /root/.bash_aliases"

    # Configure sudoers and inputrc
    log "Configuring sudoers and inputrc..."
    download_file "$SUDOERS_URL" "/etc/sudoers.d/woz"
    download_file "$INPUTRC_URL" "/etc/inputrc"
    download_file "$DISABLE_IPV6_URL" "/etc/sysctl.d/20-disable-ipv6.conf"

    # Create user directories
    log "Creating user directories..."
    for dir in "$HOME/git" "$HOME/temp" "$HOME/dev"; do
        [ -d "$dir" ] || run_command "mkdir -v $dir"
    done

    log "User environment configuration setup completed successfully."
}

# Non-critical functions
remove_rhythmbox() {
    log "Starting removal of Rhythmbox and Aisleriot..."
    run_command "sudo DEBIAN_FRONTEND=noninteractive apt purge -y rhythmbox* aisleriot"
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
        run_command "sudo DEBIAN_FRONTEND=noninteractive apt update"
        run_command "sudo DEBIAN_FRONTEND=noninteractive apt install gh -y"
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
        run_command "npm install -g tldr"
        log "Node.js installation completed successfully."
    else
        log "Node.js is already installed."
    fi
}

install_pwsh() {
    log "Starting installation of PowerShell..."
    if [[ ! $(command -v pwsh) ]]; then
        run_command "sudo DEBIAN_FRONTEND=noninteractive apt update"
        run_command "wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
        run_command "sudo dpkg -i packages-microsoft-prod.deb"
        run_command "sudo DEBIAN_FRONTEND=noninteractive apt update"
        run_command "rm -v packages-microsoft-prod.deb"
        run_command "sudo DEBIAN_FRONTEND=noninteractive apt install -y powershell"
        log "PowerShell installation completed successfully."
    else
        log "PowerShell is already installed."
    fi
}

install_vscode() {
    log "Starting installation of Visual Studio Code..."
    if [[ ! $(command -v code) ]]; then
        run_command "sudo apt-get install -y wget gpg"
        run_command "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg"
        run_command "sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg"
        run_command "sudo sh -c 'echo \"deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main\" > /etc/apt/sources.list.d/vscode.list'"
        run_command "rm -f packages.microsoft.gpg"
        run_command "sudo DEBIAN_FRONTEND=noninteractive apt update"
        run_command "sudo DEBIAN_FRONTEND=noninteractive apt install -y code"
        log "Visual Studio Code installation completed successfully."
    else
        log "Visual Studio Code is already installed."
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
        run_command "sudo DEBIAN_FRONTEND=noninteractive apt remove -y nano"
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

# Set the DEBIAN_FRONTEND to noninteractive
export DEBIAN_FRONTEND=noninteractive
log "DEBIAN_FRONTEND set to noninteractive"

# Run critical functions
log "Starting critical function execution."
update_software || log_error "update_software"
install_software || log_error "install_software"
install_updates || log_error "install_updates"
configure_userenv || log_error "configure_userenv"

# Function to run non-critical functions and handle errors
run_non_critical() {
    local func=$1
    $func || log_error "$func"
}

# Run non-critical functions
log "Starting non-critical function execution."
run_non_critical "remove_rhythmbox"
run_non_critical "configure_dotnet"
run_non_critical "generate_ssh_keys"
run_non_critical "install_gh"
run_non_critical "install_nvm"
run_non_critical "install_pwsh"
run_non_critical "install_vscode"
run_non_critical "save_docker"

# Functions related to building and configuring nano
run_non_critical "remove_nano"
run_non_critical "clone_nano_syntax"
run_non_critical "download_nano"
run_non_critical "build_nano"
run_non_critical "install_nano"
run_non_critical "configure_nano"
run_non_critical "set_default_editor"

# Clean up .tmp files in /tmp
remove_tmpfiles || log_error "remove_tmpfiles"

log "All tasks completed successfully."
echo "All tasks completed successfully."

# Run completion builder script
declare -A completions=(
    [op]="op completion bash"
    [pip]="pip completion --bash"
    [docker]="docker completion bash"
    [npm]="npm completion bash"
    [rclone]="rclone completion bash"
    [helm]="helm completion bash"
    [kubectl]="kubectl completion bash"
    [minikube]="minikube completion bash"
    [supabase]="supabase completion bash"
    [ngrok]="ngrok completion bash"
    [gh]="gh completion --shell bash"
    [tldr]="cat $(realpath -e "$(dirname $(realpath -e $(which tldr)))/completion/bash/tldr")"
    [dotnet]="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/_completion/dotnet_completion.sh"
    [vscode]="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/_completion/vscode_completion.sh"
    [clang]="https://raw.githubusercontent.com/llvm-mirror/clang/master/utils/bash-autocomplete.sh"
    [az]="https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion"
)

# Target directory for the completions
target_dir="/etc/bash_completion.d"
timestamp=$(date +"%Y%m%d_%H%M%S")
error_log="error_log_${timestamp}.txt"

# ANSI color codes
ORANGE_RED='\033[38;2;255;69;0m'
NC='\033[0m' # No Color

# Ensure the target directory exists
if [[ ! -d "$target_dir" ]]; then
    error_msg="Target directory $target_dir does not exist."
    echo -e "${ORANGE_RED}${error_msg}${NC}"
    echo "[$(date)] $error_msg" >>"$error_log"
    exit 1
fi

# Iterate through the associative array
for key in "${!completions[@]}"; do
    value="${completions[$key]}"
    output_file="${target_dir}/${key}_completion"

    if [[ "$key" == "tldr" ]]; then
        # Special handling for `tldr` since it requires npm install and specific file checks
        if ! command -v tldr &>/dev/null; then
            error_msg="Command tldr not found. Skipping $key."
            echo -e "${ORANGE_RED}${error_msg}${NC}"
            echo "[$(date)] $error_msg" >>"$error_log"
            continue
        fi

        # Run the `cat` command specified in the value to extract the completion script
        echo "Generating completion script for $key..."
        completion_output=$(eval "$value" 2>/dev/null)
        if [[ -z "$completion_output" ]]; then
            error_msg="No completion script output for $key. Skipping creation."
            echo -e "${ORANGE_RED}${error_msg}${NC}"
            echo "[$(date)] $error_msg" >>"$error_log"
            continue
        fi

        # Write the output to the file only if there's actual content
        echo "$completion_output" | sudo tee "$output_file" >/dev/null
    elif [[ "$value" == https://* ]]; then
        # If the value starts with "https://", download it
        echo "Downloading completion script for $key..."
        sudo curl -s "$value" -o "$output_file"
        if [[ $? -ne 0 ]]; then
            error_msg="Failed to download completion script for $key."
            echo -e "${ORANGE_RED}${error_msg}${NC}"
            echo "[$(date)] $error_msg" >>"$error_log"
            continue
        fi
    else
        # Otherwise, check if the application exists before running the command
        command_name=$(echo "$value" | awk '{print $1}')
        if ! command -v "$command_name" &>/dev/null; then
            error_msg="Command $command_name not found. Skipping $key."
            echo -e "${ORANGE_RED}${error_msg}${NC}"
            echo "[$(date)] $error_msg" >>"$error_log"
            continue
        fi

        # Run the command and save the output if there is any
        echo "Generating completion script for $key..."
        completion_output=$(eval "$value" 2>/dev/null)
        if [[ -z "$completion_output" ]]; then
            error_msg="No completion script output for $key. Skipping creation."
            echo -e "${ORANGE_RED}${error_msg}${NC}"
            echo "[$(date)] $error_msg" >>"$error_log"
            continue
        fi

        # Write the output to the file only if there's actual content
        echo "$completion_output" | sudo tee "$output_file" >/dev/null
    fi

    # Ensure the file has the correct permissions for bash completion
    sudo chmod 644 "$output_file"
    if [[ $? -ne 0 ]]; then
        error_msg="Failed to set permissions for $output_file."
        echo -e "${ORANGE_RED}${error_msg}${NC}"
        echo "[$(date)] $error_msg" >>"$error_log"
        continue
    fi

    echo "Completion script for $key saved to $output_file."
done

echo "All completion scripts have been processed."

# Reset DEBIAN_FRONTEND to its default value (optional)
unset DEBIAN_FRONTEND
log "DEBIAN_FRONTEND reset to default"
