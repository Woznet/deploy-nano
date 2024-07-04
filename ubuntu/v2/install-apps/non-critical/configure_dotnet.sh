#!/bin/bash

configure_dotnet() {
    echo "Starting configuration of Dotnet packages..."
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-mspkgs | sudo tee /etc/apt/preferences.d/dotnet-mspkgs || { log_error "configure_dotnet - curl dotnet-mspkgs"; error_exit; }
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/dotnet-cli-config.sh | sudo tee /etc/profile.d/dotnet-cli-config.sh || { log_error "configure_dotnet - curl dotnet-cli-config"; error_exit; }
    echo "Dotnet configuration completed successfully."
}

configure_dotnet
