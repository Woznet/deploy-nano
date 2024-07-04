#!/bin/bash

install_nano() {
    echo "Installing nano..."
    sudo -i
    cd $(cat /tmp/nanobuildpath.tmp)
    make install >>/tmp/nano-makeinstall.log || { log_error "install_nano - make install"; error_exit; }
    install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-8.0 >>/tmp/nano-makeinstall.log || { log_error "install_nano - install docs"; error_exit; }
    echo "Nano installed successfully."
}

install_nano
