#!/usr/bin/env bash
# Ouvre un SSH avec un tunnel vers Horizon.
# Horizon devient joignable sur http://localhost:8080/dashboard
set -euo pipefail
source "$(dirname "$0")/00-vars.sh"

IP=$(az vm show -d -g "$RG" -n "$VM" --query publicIps -o tsv)
echo "VM : $IP"
echo "Horizon : http://localhost:8080/dashboard"

ssh -L 8080:localhost:80 "$ADMIN@$IP"
