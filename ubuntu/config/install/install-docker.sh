#!/bin/bash
set -e

if [[ ! $(which docker) ]]; then
    # Add Docker's official GPG key:
    sudo apt update
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt update

    # Install Docker Engine
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Setup root-less docker
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker

    # Test root-less docker
    docker run hello-world

    # Get Docker Desktop download url
    DOCKER_DESKTOP_URL="https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64"
    # Download Docker Desktop deb file
    curl -L $DOCKER_DESKTOP_URL -o docker-desktop-amd64.deb
    # Install Docker Desktop

    # Define styles and colors
    PASTEL_LIGHT_GREEN='\033[38;2;144;238;144m'  # LightGreen RGB (144,238,144)
    UNDERLINE='\033[4m'
    NC='\033[0m'
    echo -e "${UNDERLINE}${PASTEL_LIGHT_GREEN}Use \"sudo apt install ./docker-desktop-amd64.deb\" to install Docker Desktop${NC}"
    # sudo apt install ./docker-desktop-amd64.deb
fi
