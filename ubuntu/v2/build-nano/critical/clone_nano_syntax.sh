#!/bin/bash

clone_nano_syntax() {
    echo "Cloning nano syntax highlighting repository..."
    cd ~/git
    git clone https://github.com/galenguyer/nano-syntax-highlighting.git || { log_error "clone_nano_syntax - git clone"; error_exit; }
    readlink -f ./nano-syntax-highlighting >/tmp/nanosyntaxpath.tmp
    echo "Cloned nano syntax highlighting repository successfully."
}

clone_nano_syntax
