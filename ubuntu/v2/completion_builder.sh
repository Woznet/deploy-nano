#!/bin/bash

# List of commands and their completion commands
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
    [curl]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/curl"
    [az]="https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion"
    [ip]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/ip"
    [jq]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/jq"
    [perl]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/perl"
    [python]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/python"
    [resolvconf]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/resolvconf"
    [rsync]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/rsync"
    [ssh]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/ssh"
    [wget]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/wget"
    [wsimport]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/wsimport"
    [xdg-settings]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/xdg-settings"
    [7z]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/7z"
    [bind]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/bind"
    [dd]="https://raw.githubusercontent.com/scop/bash-completion/main/completions/dd"
)

# Log file for errors
error_log="/var/log/completion_errors.log"

# Ensure the error log file exists and set the appropriate permissions
sudo touch "$error_log"
sudo chown $USER "$error_log"

# ANSI color codes for orange-red
ORANGE_RED='\033[38;2;255;69;0m'
NC='\033[0m' # No Color

# Function to check command existence and setup completion
setup_completion() {
    local cmd=$1
    local completion_cmd_or_url=$2
    local completion_file="/etc/bash_completion.d/${cmd}_completion"

    if command -v "$cmd" >/dev/null 2>&1; then
        if [[ $completion_cmd_or_url == http* ]]; then
            # Download the completion script from the URL
            curl -s "$completion_cmd_or_url" -o "$completion_file"
            if [[ $? -ne 0 ]]; then
                echo "Failed to download completion script for $cmd from $completion_cmd_or_url" | tee -a "$error_log" >&2
            fi
        else
            # Run the completion command and use tee to write to the file,
            # redirecting standard output to /dev/null and leaving standard error intact.
            $completion_cmd_or_url 2>/tmp/$$.stderr | sudo tee "$completion_file" >/dev/null 2>/tmp/$$.stderr
            # If there were any errors, append them to the error log and output them
            if [ -s /tmp/$$.stderr ]; then
                cat /tmp/$$.stderr >>"$error_log"
                cat /tmp/$$.stderr >&2
            fi
            rm -f /tmp/$$.stderr
        fi
    else
        printf "Command not found - ${ORANGE_RED}%s${NC}\n" "$cmd" | tee -a "$error_log" >&2
    fi
}

# Iterate through the commands and setup completion
for cmd in "${!completions[@]}"; do
    setup_completion "$cmd" "${completions[$cmd]}"
done
