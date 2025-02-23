#!/bin/bash
set -e
set -o pipefail

ORANGE_RED='\033[38;2;255;69;0m'
NC='\033[0m'

# Configuration variables shared across all scripts
DOTNET_CONFIG_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-mspkgs'
DOTNET_PROFILE_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-cli-config.sh'
PWSH_PROFILE_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/profile.ps1'
PWSH_CONFIG_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/Invoke-ConfigPwsh.ps1'
BASHRC_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bashrc'
BASH_ALIASES_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bash_aliases'
SUDOERS_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/sudoers.woz'
INPUTRC_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/inputrc'
NANORC_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/nanorc'
DISABLE_IPV6_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/20-disable-ipv6.conf'

NANO_SYNTAX_TEMP_PATH='/tmp/nanosyntaxpath.tmp'
NANO_BUILD_TEMP_PATH='/tmp/nanobuildpath.tmp'

DOCKER_INSTALL_SCRIPT_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/install-docker.sh'
NANO_SYNTAX_REPO='https://github.com/galenguyer/nano-syntax-highlighting.git'

NVM_DIR="$([ -z '${XDG_CONFIG_HOME-}' ] && printf %s '${HOME}/.nvm' || printf %s '${XDG_CONFIG_HOME}/nvm')"

# Check for required commands
check_dependency() {
  command -v "$1" >/dev/null 2>&1 || {
    echo -e "${ORANGE_RED}Error: Required command '$1' not found.${NC}\n" >&2
    exit 1
  }
}
for cmd in curl tee chmod mkdir date sudo; do
  check_dependency "$cmd"
done

BASE_DIR="$HOME/temp"
LOGFILE="$BASE_DIR/install-apps_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$BASE_DIR"
touch "$LOGFILE"
chmod 0644 "$LOGFILE"

error_handler() {
  local exit_status=$?
  local line_no=$1
  echo -e "${ORANGE_RED}An error occurred at or near line ${line_no}. Exit status: ${exit_status}${NC}\n"
  log_error "Error occurred at or near line ${line_no}. Exit status: ${exit_status}"
  exit $exit_status
}
trap 'error_handler $LINENO' ERR

log() {
  local message="$1"
  local level="${2:-INFO}"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOGFILE"
}
log_error() {
  log "$1" "ERROR"
}
error_exit() {
  echo -e "${ORANGE_RED}Error occurred. Exiting.${NC}\n"
  log_error 'Error occurred. Exiting.'
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
  # Determine if sudo is needed (check write permission)
  if [[ ! -w "$(dirname "$dest")" ]]; then
    use_sudo="sudo"
  else
    use_sudo=""
  fi
  # Download file and handle errors
  if ! curl --silent --fail "$url" | $use_sudo tee "$dest" >/dev/null; then
    echo -e "${ORANGE_RED}Failed to download $url to $dest${NC}\n"
    log_error "Failed to download $url"
    error_exit
  fi
  # Set permissions
  if ! $use_sudo chmod 644 "$dest"; then
    echo -e "${ORANGE_RED}Failed to set permissions for $dest${NC}\n"
    log_error "Failed to set permissions for $dest"
    error_exit
  fi
  # Check if file is empty
  if [ ! -s "$dest" ]; then
    echo -e "${ORANGE_RED}Downloaded file $dest is empty.${NC}\n"
    log_error "Downloaded file $dest is empty."
    error_exit
  fi
  log "Downloaded $url to $dest successfully."
}

source_external_script() {
  local url="$1"
  local tmp_file="/tmp/temp_script.sh"
  if ! curl --silent --fail "$url" -o "$tmp_file"; then
    echo -e "${ORANGE_RED}Failed to download script from $url${NC}\n"
    log_error "Failed to download script from $url"
    exit 1
  fi
  if [ ! -s "$tmp_file" ]; then
    echo -e "${ORANGE_RED}Downloaded script from $url is empty.${NC}\n"
    log_error "Downloaded script from $url is empty."
    rm -f "$tmp_file"
    exit 1
  fi
  source "$tmp_file"
  rm -f "$tmp_file"
}

# Load functions
check_updates() {
  log 'Starting software update...'
  run_command 'sudo apt update'
  log 'Software update completed successfully.'
}

install_updates() {
  log 'Starting full upgrade...'
  run_command 'sudo apt full-upgrade -y'
  log 'Full upgrade completed successfully.'
}

install_software() {
  log 'Starting installation of required software packages...'
  run_command 'sudo apt install -y apt-transport-https curl software-properties-common git-all autopoint build-essential devhelp devhelp-common freetype2-doc g++-multilib gcc-multilib wget xdg-utils glibc-doc glibc-doc-reference glibc-source groff groff-base language-pack-en language-pack-en-base clang libasprintf-dev libbsd-dev libc++-dev libc6 libc6-dev libcairo2-dev libcairo2-doc libc-ares-dev python3-pip libc-dev libev-dev libgettextpo-dev libgirepository1.0-dev libglib2.0-doc libice-doc libmagic1 ca-certificates libmagic-dev libmagick++-dev libmagics++-dev libncurses5-dev libncurses-dev libncursesw5-dev python-is-python3 libsm-doc libx11-doc libxcb-doc libxext-doc libxml2-utils ncurses-doc pkg-config zlib1g-dev net-tools gpg ffmpeg ffmpeg-doc most openssh-client openssh-known-hosts openssh-tests python3 python3-doc p7zip p7zip-full p7zip-rar policykit-1 policykit-1-doc policykit-1-gnome policykit-desktop-privileges rclone unzip zip unrar-free'
  log 'Software installation completed successfully.'
}

configure_userenv() {
  log 'Starting user environment configuration setup...'

  generate_ssh_keys

  if command -v gsettings &>/dev/null; then
    run_command 'gsettings set org.gnome.desktop.interface clock-format 12h'
    log 'Clock format set to 12-hour.'
  else
    echo -e "${ORANGE_RED}Warning: gsettings not found. Skipping clock format configuration.${NC}\n"
    log_error 'gsettings not found. Skipping clock format configuration.'
  fi

  log 'Configuring .bashrc and .bash_aliases...'
  download_file "$BASHRC_URL" "$HOME/.bashrc"
  download_file "$BASH_ALIASES_URL" "$HOME/.bash_aliases"

  run_command 'sudo cp --force ~/.bashrc /root/.bashrc'
  run_command 'sudo ln --force ~/.bash_aliases /root/.bash_aliases'

  log 'Configuring sudoers and inputrc...'
  download_file "$SUDOERS_URL" '/etc/sudoers.d/woz'
  download_file "$INPUTRC_URL" '/etc/inputrc'
  download_file "$DISABLE_IPV6_URL" '/etc/sysctl.d/20-disable-ipv6.conf'

  log 'Creating user directories...'
  for dir in "$HOME/git" "$HOME/temp" "$HOME/dev"; do
    [ -d "$dir" ] || run_command "mkdir -v '$dir'"
  done

  log 'User environment configuration setup completed successfully.'
}

remove_rhythmbox() {
  log 'Starting removal of Rhythmbox and Aisleriot...'
  run_command 'sudo apt purge -y rhythmbox* aisleriot'
  log 'Rhythmbox and Aisleriot removal completed successfully.'
}

configure_dotnet() {
  log 'Starting configuration of Dotnet packages...'
  download_file "$DOTNET_CONFIG_URL" '/etc/apt/preferences.d/dotnet-mspkgs'
  download_file "$DOTNET_PROFILE_URL" '/etc/profile.d/dotnet-cli-config.sh'
  run_command 'sudo add-apt-repository --yes ppa:dotnet/backports'
  run_command 'sudo apt update'
  log 'Dotnet configuration completed successfully.'
}

generate_ssh_keys() {
  log 'Checking for existing SSH keys...'
  if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    log 'Creating SSH key at ~/.ssh/id_rsa'
    run_command 'ssh-keygen -t rsa -b 4096 -C "$(id --name --user)@$(hostname --fqdn)" -N "" -f ~/.ssh/id_rsa'
    log 'SSH key generated successfully.'
  else
    echo -e "${ORANGE_RED}Warning: SSH key already exists. Skipping key generation.${NC}\n"
    log 'SSH key already exists.'
  fi
}

install_gh() {
  log 'Starting installation of GitHub CLI...'
  if [[ ! $(command -v gh) ]]; then
    run_command 'curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg'
    run_command 'sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg'
    run_command 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list'
    run_command 'sudo apt update'
    run_command 'sudo apt install gh -y'
    log 'GitHub CLI installation completed successfully.'
  else
    echo -e "${ORANGE_RED}Warning: GitHub CLI is already installed. Skipping installation.${NC}\n"
    log 'GitHub CLI is already installed.'
  fi
}

install_nvm() {
  log 'Starting installation of NVM and Node.js...'
  if [[ ! $(command -v nvm) && ! $(type -t nvm) == function ]]; then
    log 'Installing NVM...'
    run_command 'curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash'
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "$HOME/.nvm" || printf %s "$XDG_CONFIG_HOME/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    log 'NVM installation completed successfully.'
  else
    echo -e "${ORANGE_RED}Warning: NVM is already installed. Skipping installation.${NC}\n"
    log 'NVM is already installed.'
  fi

  if [[ ! $(command -v node) ]]; then
    log 'Installing Node.js...'
    source "$HOME/.bashrc"
    run_command 'nvm install --lts --latest-npm --default'
    run_command 'nvm use default'
    log 'Node.js installation completed successfully.'
  else
    echo -e "${ORANGE_RED}Warning: Node.js is already installed. Skipping installation.${NC}\n"
    log 'Node.js is already installed.'
  fi

  if [[ ! $(command -v tldr) ]]; then
    log 'Installing tldr...'
    source "$HOME/.bashrc"
    run_command 'npm install -g tldr'
    log 'tldr installation completed successfully.'
  else
    echo -e "${ORANGE_RED}Warning: tldr is already installed. Skipping installation.${NC}\n"
    log 'tldr is already installed.'
  fi
}

install_pwsh() {
  log 'Starting installation of PowerShell...'
  if [[ ! $(command -v pwsh) ]]; then
    run_command 'sudo apt update'
    run_command 'wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb'
    run_command 'sudo dpkg -i packages-microsoft-prod.deb'
    run_command 'sudo apt update'
    run_command 'rm -v packages-microsoft-prod.deb'
    run_command 'sudo apt install -y powershell'
    run_command "sudo pwsh -NoProfile -Command \"Invoke-Expression ([System.Net.WebClient]::new().DownloadString('$PWSH_CONFIG_URL'))\""
    download_file "$PWSH_PROFILE_URL" '/opt/microsoft/powershell/7/profile.ps1'
    log 'PowerShell installation completed successfully.'
  else
    echo -e "${ORANGE_RED}Warning: PowerShell is already installed. Skipping installation.${NC}\n"
    log 'PowerShell is already installed.'
  fi
}

install_vscode() {
  log 'Starting installation of Visual Studio Code...'
  if [[ ! $(command -v code) ]]; then
    run_command 'sudo apt-get install -y wget gpg'
    run_command 'wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --yes --dearmor >packages.microsoft.gpg'
    run_command 'sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg'
    run_command 'sudo sh -c "echo '\''deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main'\'' > /etc/apt/sources.list.d/vscode.list"'
    run_command 'rm -f packages.microsoft.gpg'
    run_command 'sudo apt update'
    run_command 'sudo apt install -y code'
    log 'Visual Studio Code installation completed successfully.'
  else
    echo -e "${ORANGE_RED}Warning: Visual Studio Code is already installed. Skipping installation.${NC}\n"
    log 'Visual Studio Code is already installed.'
  fi
}

install_az() {
  log 'Starting installation of Azure Cli...'
  if [[ ! $(command -v az) ]]; then
    run_command 'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash'
    log 'Azure Cli installation completed successfully.'
  else
    echo -e "${ORANGE_RED}Warning: Azure Cli is already installed. Skipping installation.${NC}\n"
    log 'Azure Cli is already installed.'
  fi
}

install_ngrok() {
  log 'Starting installation of ngrok...'
  if [[ ! $(command -v ngrok) ]]; then
    run_command 'curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null'
    run_command 'echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list'
    run_command 'sudo apt update'
    run_command 'sudo apt install -y ngrok'
    log 'ngrok installation completed successfully.'
  else
    echo -e "${ORANGE_RED}Warning: ngrok is already installed. Skipping installation.${NC}\n"
    log 'ngrok is already installed.'
  fi
}

install_1password() {
  log 'Starting installation of 1Password...'
  if [[ ! $(command -v 1password) || ! $(command -v op) ]]; then
    run_command 'curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --yes --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg'
    run_command 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list'
    run_command 'sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/'
    run_command 'curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol'
    run_command 'sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22'
    run_command 'curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --yes --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg'
    run_command 'sudo apt update'
    run_command 'sudo apt install -y 1password'
    run_command 'sudo apt install -y 1password-cli'
    log '1Password installation completed successfully.'
  else
    echo -e "${ORANGE_RED}Warning: 1Password is already installed. Skipping installation.${NC}\n"
    log '1Password is already installed.'
  fi
}

save_docker() {
  log 'Saving Docker install script...'
  download_file "$DOCKER_INSTALL_SCRIPT_URL" "$HOME/temp/install-docker.sh"
  log 'Docker install script saved successfully.'
}

remove_nano() {
  log 'Checking if nano is installed...'
  if [[ $(command -v nano) ]]; then
    log 'Nano is installed. Removing nano...'
    run_command 'sudo apt purge -y nano'
    log 'Nano removed successfully.'
  else
    echo -e "${ORANGE_RED}Warning: Nano is not installed. Skipping removal.${NC}\n"
    log 'Nano is not installed.'
  fi
}

clone_nano_syntax() {
  log 'Cloning nano syntax highlighting repository...'
  run_command "sudo rm --recursive --force \"$HOME/git/nano-syntax-highlighting\""
  run_command "git clone \"$NANO_SYNTAX_REPO\" \"$HOME/git/nano-syntax-highlighting\""
  readlink -f "$HOME/git/nano-syntax-highlighting" >"$NANO_SYNTAX_TEMP_PATH"
  log 'Cloned nano syntax highlighting repository successfully.'
}

get_installed_nano_version() {
  log "Fetching installed nano version" >/dev/null
  if [[ $(command -v nano) ]]; then
    local installed_nano_version
    installed_nano_version=$(nano --version | head -n1 | awk '{print $4}')
    log "Installed nano version is $installed_nano_version" >/dev/null
    echo "$installed_nano_version"
  else
    log "Nano is not installed, returning version 0.0" >/dev/null
    echo "0.0"
  fi
}

get_latest_nano_version() {
  log "Fetching latest nano version" >/dev/null
  local nano_version
  nano_version=$(git ls-remote --sort=-'version:refname' --tags https://git.savannah.gnu.org/git/nano.git 2>/dev/null \
    | head -n1 \
    | awk '{print $2}' \
    | sed -E "s/^refs\/tags\/v//; s/\^\{\}$//")
  if [[ -z "$nano_version" ]]; then
    nano_version="8.3"
    log "Git command failed, falling back to version $nano_version" >/dev/null
  fi
  log "Latest nano version is $nano_version" >/dev/null
  echo "$nano_version"
}

download_nano() {
  log 'Downloading nano source...'
  cd "$HOME/temp"
  run_command 'sudo rm --recursive --force ./nano-*'
  run_command "wget ${NANO_SOURCE_URL}"
  run_command "tar -xf nano-${NANO_LATEST_VERSION}.tar.xz"
  readlink -f $(printf 'nano-%s' "$NANO_LATEST_VERSION") >"$NANO_BUILD_TEMP_PATH"
  log 'Downloaded and extracted nano source successfully.'
}

build_nano() {
  log 'Configuring and building nano...'
  cd "$(cat "$NANO_BUILD_TEMP_PATH")"
  run_command "sudo ./configure --prefix=/usr --sysconfdir=/etc --enable-utf8 --enable-color --enable-extra --enable-nanorc --enable-multibuffer --docdir=/usr/share/doc/nano-${NANO_LATEST_VERSION}"
  run_command 'sudo make'
  run_command 'sudo make install'
  run_command "sudo install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-${NANO_LATEST_VERSION}"
  log 'Configured, built and installed nano successfully.'
}

should_install_nano() {
  if [ -z "$NANO_INSTALLED_VERSION" ]; then
    log "Nano is not installed; should install." >/dev/null
    echo "1"
    return 0
  fi

  if [ "$NANO_INSTALLED_VERSION" = "$NANO_LATEST_VERSION" ]; then
    log "Nano is up-to-date; no need to install." >/dev/null
    echo "0"
    return 0
  fi

  if [ "$(printf '%s\n%s' "$NANO_INSTALLED_VERSION" "$NANO_LATEST_VERSION" | sort -V | head -n1)" = "$NANO_INSTALLED_VERSION" ]; then
    log "A newer version of nano is available: $NANO_LATEST_VERSION > $NANO_INSTALLED_VERSION; should install." >/dev/null
    echo "1"
  else
    log "Installed version appears newer than the latest available version; no need to install." >/dev/null
    echo "0"
  fi
}

configure_nano() {
  log 'Configuring nano...'
  run_command 'sudo cp /etc/nanorc /etc/nanorc.bak'
  run_command "curl --silent $NANORC_URL | sudo tee /etc/nanorc >/dev/null"
  run_command "sudo mv --force \"$(cat "$NANO_SYNTAX_TEMP_PATH")\"/*.nanorc /usr/share/nano/"
  run_command 'sudo chmod --changes =644 /usr/share/nano/*.nanorc'
  run_command 'sudo chown --changes --recursive root:root /usr/share/nano/'
  log 'Nano configured successfully.'
}

set_default_editor() {
  log 'Setting nano as the default editor...'
  run_command 'sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nano 1'
  run_command 'sudo update-alternatives --set editor /usr/bin/nano'
  log 'Nano set as the default editor successfully.'
}

remove_tmpfiles() {
  log 'Deleting temporary files in /tmp directory...'
  run_command "sudo rm -f '$NANO_SYNTAX_TEMP_PATH' '$NANO_BUILD_TEMP_PATH'"
  log 'Temporary files deleted successfully.'
}

run_non_critical() {
  local func="$1"
  if ! $func; then
    echo -e "${ORANGE_RED}Warning: $func encountered an error.${NC}\n"
    log_error "$func"
  fi
}

# Starting function execution
log 'Starting critical function execution.'
check_updates || log_error 'check_updates'
install_updates || log_error 'install_updates'
install_software || log_error 'install_software'
configure_userenv || log_error 'configure_userenv'

NANO_INSTALLED_VERSION=$(get_installed_nano_version)
NANO_LATEST_VERSION=$(get_latest_nano_version)
SHOULD_INSTALL_NANO=$(should_install_nano)
NANO_SOURCE_URL="https://nano-editor.org/dist/v8/nano-${NANO_LATEST_VERSION}.tar.xz"

log 'Starting non-critical function execution.'
run_non_critical 'remove_rhythmbox'
run_non_critical 'configure_dotnet'
run_non_critical 'generate_ssh_keys'
run_non_critical 'install_gh'
run_non_critical 'install_nvm'
run_non_critical 'install_pwsh'
run_non_critical 'install_vscode'
run_non_critical 'install_1password'
run_non_critical 'install_az'
run_non_critical 'install_ngrok'
run_non_critical 'save_docker'

if [ "$SHOULD_INSTALL_NANO" = "1" ]; then
  run_non_critical 'remove_nano'
  run_non_critical 'download_nano'
  run_non_critical 'build_nano'
  run_non_critical 'clone_nano_syntax'
  run_non_critical 'configure_nano'
  run_non_critical 'set_default_editor'
fi

# Define the URLs for completions
TLDR_COMPLETION_URL='https://raw.githubusercontent.com/tldr-pages/tldr-node-client/main/bin/completion/bash/tldr'
DOTNET_COMPLETION_URL='https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/_completion/dotnet_completion.sh'
CLANG_COMPLETION_URL='https://raw.githubusercontent.com/llvm-mirror/clang/master/utils/bash-autocomplete.sh'
AZ_COMPLETION_URL='https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion'

# Table for command-based completions
declare -A command_completions=(
  [op]='op completion bash'
  [pip]='pip completion --bash'
  [npm]='npm completion bash'
  [rclone]='rclone completion bash'
  [ngrok]='ngrok completion bash'
  [gh]='gh completion --shell bash'
)

# Table for URL-based completions
declare -A url_completions=(
  [tldr]="$TLDR_COMPLETION_URL"
  [dotnet]="$DOTNET_COMPLETION_URL"
  [clang]="$CLANG_COMPLETION_URL"
  [az]="$AZ_COMPLETION_URL"
)

completions_target_dir='/etc/bash_completion.d'
timestamp=$(date +'%Y%m%d_%H%M%S')
error_log="error_log_${timestamp}.txt"

if [[ ! -d "$completions_target_dir" ]]; then
  error_msg="Target directory $completions_target_dir does not exist."
  echo -e "${ORANGE_RED}${error_msg}${NC}"
  echo "[$(date)] $error_msg" >>"$error_log"
  exit 1
fi

# Process command completions
for key in "${!command_completions[@]}"; do
  value="${command_completions[$key]}"
  output_file="${completions_target_dir}/${key}_completion"

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Generating command completion for key: $key" | tee -a "$error_log"

  # Ensure the command exists before generating the completion output
  command_name=$(echo "$value" | awk '{print $1}')
  if ! command -v "$command_name" &>/dev/null; then
    error_msg="[$key] Command '$command_name' not found. Skipping."
    echo -e "${ORANGE_RED}${error_msg}${NC}"
    echo "[$(date)] $error_msg" >>"$error_log"
    continue
  fi

  completion_output=$(eval "$value" 2>&1)
  if [[ -z "$completion_output" ]]; then
    error_msg="[$key] Command '$value' produced no output. Skipping."
    echo -e "${ORANGE_RED}${error_msg}${NC}"
    echo "[$(date)] $error_msg" >>"$error_log"
    continue
  fi

  echo "$completion_output" | sudo tee "$output_file" >/dev/null
  if ! sudo chmod 644 "$output_file"; then
    error_msg="[$key] Failed to set permissions on $output_file."
    echo -e "${ORANGE_RED}${error_msg}${NC}"
    echo "[$(date)] $error_msg" >>"$error_log"
    continue
  fi

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Successfully generated $key completion. Saved to $output_file." | tee -a "$error_log"
done

# Process URL completions
for key in "${!url_completions[@]}"; do
  value="${url_completions[$key]}"
  output_file="${completions_target_dir}/${key}_completion"

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Downloading URL completion for key: $key from $value" | tee -a "$error_log"
  if ! sudo curl -s "$value" -o "$output_file"; then
    error_msg="[$key] Failed to download completion script from $value"
    echo -e "${ORANGE_RED}${error_msg}${NC}"
    echo "[$(date)] $error_msg" >>"$error_log"
    continue
  fi

  if ! sudo chmod 644 "$output_file"; then
    error_msg="[$key] Failed to set permissions on $output_file."
    echo -e "${ORANGE_RED}${error_msg}${NC}"
    echo "[$(date)] $error_msg" >>"$error_log"
    continue
  fi

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Successfully downloaded $key completion. Saved to $output_file." | tee -a "$error_log"
done

echo "All completion scripts have been processed."

remove_tmpfiles || log_error 'remove_tmpfiles'

log 'All tasks completed successfully.'
echo 'All tasks completed successfully.'
