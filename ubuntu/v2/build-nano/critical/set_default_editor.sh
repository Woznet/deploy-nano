#!/bin/bash

set_default_editor() {
    echo "Setting nano as the default editor..."
    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nano 1 || { log_error "set_default_editor - update-alternatives --install"; error_exit; }
    sudo update-alternatives --set editor /usr/bin/nano || { log_error "set_default_editor - update-alternatives --set"; error_exit; }
    echo "Nano set as the default editor successfully."
}

set_default_editor
