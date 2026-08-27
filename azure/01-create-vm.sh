#!/usr/bin/env bash
# Create the DevStack host VM.
set -euo pipefail
source "$(dirname "$0")/00-vars.sh"

# --security-type Standard is mandatory: Trusted Launch blocks nested
# virtualization, which Nova needs to run KVM.
az vm create \
  --resource-group "$RG" \
  --name "$VM" \
  --location "$LOC" \
  --image Canonical:ubuntu-24_04-lts:server:latest \
  --size "$SIZE" \
  --security-type Standard \
  --os-disk-size-gb "$DISK_GB" \
  --admin-username "$ADMIN" \
  --generate-ssh-keys

# Safety net in case we forget to deallocate.
az vm auto-shutdown --resource-group "$RG" --name "$VM" --time 2000

az vm show -d -g "$RG" -n "$VM" --query publicIps -o tsv
