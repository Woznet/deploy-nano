#!/bin/bash

# Critical functions
update_software() {
    log "Starting software update..."
    run_command "sudo apt update"
    log "Software update completed successfully."
}

install_software() {
    log "Starting installation of required software packages..."
    run_command "sudo apt install -y apt-transport-https curl software-properties-common git-all \
    autopoint build-essential devhelp devhelp-common freetype2-doc g++-multilib gcc-multilib wget xdg-utils \
    glibc-doc glibc-doc-reference glibc-source groff groff-base language-pack-en language-pack-en-base clang \
    libasprintf-dev libbsd-dev libc++-dev libc6 libc6-dev libcairo2-dev libcairo2-doc libc-ares-dev python3-pip \
    libc-dev libev-dev libgettextpo-dev libgirepository1.0-dev libglib2.0-doc libice-doc libmagic1 ca-certificates \
    libmagic-dev libmagick++-dev libmagics++-dev libncurses5-dev libncurses-dev libncursesw5-dev python-is-python3 \
    libsm-doc libx11-doc libxcb-doc libxext-doc libxml2-utils ncurses-doc pkg-config zlib1g-dev net-tools gpg \
    ffmpeg ffmpeg-doc most openssh-client openssh-known-hosts openssh-tests python3 python3-doc p7zip-full p7zip-rar"
    log "Software installation completed successfully."
}

install_updates() {
    log "Starting full upgrade..."
    run_command "sudo apt full-upgrade -y"
    log "Full upgrade completed successfully."
}

configure_userenv() {
    log "Starting user environment configuration setup..."

    # Generate SSH keys if not present
    generate_ssh_keys

    # Set clock to 12-hour format if possible
    if command -v gsettings &>/dev/null; then
        run_command "gsettings set org.gnome.desktop.interface clock-format 12h"
        log "Clock format set to 12-hour."
    fi

    # Configure .bashrc and .bash_aliases
    log "Configuring .bashrc and .bash_aliases..."
    download_file "$BASHRC_URL" "$HOME/.bashrc"
    download_file "$BASH_ALIASES_URL" "$HOME/.bash_aliases"

    # Link user bashrc and aliases to root
    run_command "sudo cp --force ~/.bashrc /root/.bashrc"
    run_command "sudo ln --force ~/.bash_aliases /root/.bash_aliases"

    # Configure sudoers and inputrc
    log "Configuring sudoers and inputrc..."
    download_file "$SUDOERS_URL" "/etc/sudoers.d/woz"
    download_file "$INPUTRC_URL" "/etc/inputrc"
    download_file "$DISABLE_IPV6_URL" "/etc/sysctl.d/20-disable-ipv6.conf"

    # Create user directories
    log "Creating user directories..."
    for dir in "$HOME/git" "$HOME/temp" "$HOME/dev"; do
        [ -d "$dir" ] || run_command "mkdir -v $dir"
    done

    log "User environment configuration setup completed successfully."
}
