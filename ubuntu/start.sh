#!/bin/bash

# Set console to not show prompts or require user input
export DEBIAN_FRONTEND=noninteractive

# install curl if needed
if [[ ! $(which curl) ]]; then
  sudo apt install -y curl
fi

# config bashrc and aliases
curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bashrc | tee ~/.bashrc >/dev/null
curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bash_aliases | tee ~/.bash_aliases >/dev/null

# link user bashrc and aliases to root
sudo cp --force ~/.bashrc /root/.bashrc
sudo ln --force ~/.bash_aliases /root/.bash_aliases

# config sudoers and inputrc
# set disable ipv6 using 20-disable-ipv6.conf in /etc/sysctl.d
curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/sudoers.woz | sudo tee /etc/sudoers.d/woz >/dev/null
curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/inputrc | sudo tee /etc/inputrc >/dev/null
curl --silent https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/20-disable-ipv6.conf | sudo tee /etc/sysctl.d/20-disable-ipv6.conf >/dev/null

# create user directories
mkdir -v ~/{git,temp,dev}

# start install-apps.sh script
curl -o- https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/install-apps.sh | bash
