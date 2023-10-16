#!/bin/bash

# install curl if needed
if [[ ! $(which curl) ]]; then
  sudo apt install -y curl
fi

# config bashrc and aliases
curl https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bashrc | tee ~/.bashrc >/dev/null
curl https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/.bash_aliases | tee ~/.bash_aliases >/dev/null

# link user bashrc and aliases to root
# sudo ln ~/.bashrc /root/.bashrc
sudo cp --force ~/.bashrc /root/.bashrc
sudo ln --force ~/.bash_aliases /root/.bash_aliases

# config sudoers and inputrc
curl https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/sudoers.woz | sudo tee /etc/sudoers.d/woz >/dev/null
curl https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/config/inputrc | sudo tee /etc/inputrc >/dev/null

# create user directories
mkdir -v ~/{git,temp}

# start install-apps.sh script
curl -o- https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/install-apps.sh | bash

