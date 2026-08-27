#!/usr/bin/env bash
# Write the Ansible inventory from the Terraform outputs.
source "$(dirname "$0")/lib.sh"

load_env
require_vars ADMIN HORIZON_PORT

public="$("${TF_AZURE[@]}" output -raw public_ip)"
private="$("${TF_AZURE[@]}" output -raw private_ip)"
user="$("${TF_AZURE[@]}" output -raw admin_username)"

cat > "$INVENTORY" <<INV
[devstack]
${public} ansible_user=${user}

[devstack:vars]
private_ip=${private}
horizon_port=${HORIZON_PORT}
INV

log "wrote $INVENTORY"
cat "$INVENTORY"
