#!/usr/bin/env bash
# À lancer SUR la VM, avant d'installer DevStack.
# Sans KVM, Nova tombe en émulation logicielle, dix fois plus lente.
set -euo pipefail

echo "Flags processeur : $(grep -cE 'vmx|svm' /proc/cpuinfo)"
sudo apt-get update -qq && sudo apt-get install -y -qq cpu-checker
sudo kvm-ok
