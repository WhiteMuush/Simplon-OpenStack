#!/usr/bin/env bash
# Run at the end of every session. A plain poweroff keeps billing running.
set -euo pipefail
source "$(dirname "$0")/00-vars.sh"

az vm deallocate --resource-group "$RG" --name "$VM"
az vm show -d -g "$RG" -n "$VM" --query powerState -o tsv
