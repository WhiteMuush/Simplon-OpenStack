#!/usr/bin/env bash
# À lancer en fin de session. Un simple poweroff continue d'être facturé.
set -euo pipefail
source "$(dirname "$0")/00-vars.sh"

az vm deallocate --resource-group "$RG" --name "$VM"
az vm show -d -g "$RG" -n "$VM" --query powerState -o tsv
