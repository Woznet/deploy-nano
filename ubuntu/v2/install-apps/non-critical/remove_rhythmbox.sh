#!/bin/bash

remove_rhythmbox() {
    echo "Starting removal of Rhythmbox and Aisleriot..."
    sudo apt purge -y rhythmbox* aisleriot || { log_error "remove_rhythmbox - sudo apt purge"; error_exit; }
    echo "Rhythmbox and Aisleriot removal completed successfully."
}

remove_rhythmbox
