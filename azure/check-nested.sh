#!/usr/bin/env bash
# Run this ON the VM, before installing DevStack.
# Without KVM, Nova falls back to software emulation, roughly ten times slower.
set -euo pipefail

echo "CPU flags: $(grep -cE 'vmx|svm' /proc/cpuinfo)"
sudo apt-get update -qq && sudo apt-get install -y -qq cpu-checker
sudo kvm-ok
