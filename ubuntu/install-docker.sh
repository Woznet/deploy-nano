#!/bin/bash

if [[ ! $(which docker) ]]; then
    # Add Docker's official GPG key:
    sudo apt update
    sudo apt install ca-certificates curl
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
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Setup root-less docker
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker

    # Test root-less docker
    docker run hello-world

    # Get Docker Desktop download url
    URL_FILE="https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/docker-desktop-url.txt"
    DOCKER_DESKTOP_URL=$(curl -sL $URL_FILE)
    # Download Docker Desktop deb file
    curl -L $DOCKER_DESKTOP_URL -o docker-desktop.deb
    # Install Docker Desktop
    sudo apt install ./docker-desktop.deb
fi
