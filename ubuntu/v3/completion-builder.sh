#!/bin/bash

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
    [tldr]="$(if command -v tldr > /dev/null 2>&1; then echo 'cat $(realpath -e "$(dirname $(realpath -e $(which tldr)))/completion/bash/tldr")'; else echo ''; fi)"
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
        # echo "Generating completion script for $key..."
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
        # echo "Downloading completion script for $key..."
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
        # echo "Generating completion script for $key..."
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

    # echo "Completion script for $key saved to $output_file."
done

echo "All completion scripts have been processed."
