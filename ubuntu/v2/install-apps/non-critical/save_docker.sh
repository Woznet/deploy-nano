#!/bin/bash

save_docker() {
    echo "Saving Docker install script..."
    curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/install-docker.sh | tee ~/temp/install-docker.sh || { log_error "save_docker - curl install-docker"; error_exit; }
    echo "Docker install script saved successfully."
}

save_docker
