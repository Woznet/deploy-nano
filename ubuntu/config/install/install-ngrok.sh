#!/bin/bash
set -e
if [[ ! $(which ngrok) ]]; then
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null &&
        echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" | sudo tee /etc/apt/sources.list.d/ngrok.list &&
        sudo apt update &&
        sudo apt install -y ngrok
    # Create ngrok bash completion file in /etc/bash_completion.d
    if command -v ngrok >/dev/null 2>&1; then
        sudo mkdir -p /etc/bash_completion.d
        ngrok completion bash | sudo tee /etc/bash_completion.d/ngrok_completion >/dev/null
        sudo chmod 644 /etc/bash_completion.d/ngrok_completion
    fi
fi
