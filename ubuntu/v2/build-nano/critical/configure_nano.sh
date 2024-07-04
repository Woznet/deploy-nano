#!/bin/bash

configure_nano() {
    echo "Configuring nano..."
    cp /etc/nanorc /etc/nanorc.bak >/dev/null || { log_error "configure_nano - cp nanorc"; error_exit; }
    curl https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/nanorc | tee /etc/nanorc >/dev/null || { log_error "configure_nano - curl nanorc"; error_exit; }
    mv --force $(cat /tmp/nanosyntaxpath.tmp)/*.nanorc /usr/share/nano/ >/dev/null || { log_error "configure_nano - mv syntax files"; error_exit; }
    chmod --changes =644 /usr/share/nano/*.nanorc >/dev/null || { log_error "configure_nano - chmod syntax files"; error_exit; }
    chown --changes --recursive root:root /usr/share/nano/ >/dev/null || { log_error "configure_nano - chown syntax files"; error_exit; }
    rm -v /tmp/*.tmp >/dev/null || { log_error "configure_nano - rm tmp files"; error_exit; }
    echo "Nano configured successfully."
}

configure_nano
