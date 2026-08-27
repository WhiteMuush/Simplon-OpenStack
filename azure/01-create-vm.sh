#!/usr/bin/env bash
# Crée la VM hôte du lab DevStack.
set -euo pipefail
source "$(dirname "$0")/00-vars.sh"

# --security-type Standard est obligatoire : Trusted Launch bloque la
# virtualisation imbriquée, et Nova en a besoin pour utiliser KVM.
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

# Filet de sécurité si on oublie de désallouer.
az vm auto-shutdown --resource-group "$RG" --name "$VM" --time 2000

az vm show -d -g "$RG" -n "$VM" --query publicIps -o tsv
