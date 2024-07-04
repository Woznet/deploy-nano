#!/bin/bash

update_software() {
    echo "Starting software update..."
    sudo apt update || { log_error "update_software - sudo apt update"; error_exit; }
    echo "Software update completed successfully."
}

update_software
