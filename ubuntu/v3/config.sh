#!/bin/bash

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
