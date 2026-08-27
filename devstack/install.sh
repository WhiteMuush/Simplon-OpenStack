#!/usr/bin/env bash
# À lancer SUR la VM. DevStack refuse de tourner en root.
set -euo pipefail

sudo apt-get update && sudo apt-get install -y git
sudo useradd -s /bin/bash -d /opt/stack -m stack || true
sudo chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

echo
echo "Basculer sur l'utilisateur stack, puis :"
echo "  sudo -u stack -i"
echo "  git clone https://opendev.org/openstack/devstack && cd devstack"
echo "  git branch -r | grep stable | tail -5   # prendre la dernière"
echo "  git checkout stable/XXXX.X"
echo "  cp ~/local.conf.example local.conf && \$EDITOR local.conf"
echo "  ./stack.sh"
