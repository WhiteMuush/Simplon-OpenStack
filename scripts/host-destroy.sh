#!/usr/bin/env bash
# Destroy the Azure host VM and its network. Irreversible.
source "$(dirname "$0")/lib.sh"

load_env
confirm "Destroy the host VM $VM and its network?" || die "aborted"
"${TF_AZURE[@]}" destroy -input=false ${YES:+-auto-approve}
rm -f "$INVENTORY"
