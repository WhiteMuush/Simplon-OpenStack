#!/usr/bin/env bash
# Install DevStack through Ansible. stack.sh runs for 30 to 60 minutes.
source "$(dirname "$0")/lib.sh"

load_env
require_vars DEVSTACK_PASSWORD
[[ -f "$INVENTORY" ]] || die "inventory is missing, run: make inventory"

# Wait for cloud-init, otherwise apt is still locked by the first boot.
host="$(awk '/ansible_user=/ {print $1; exit}' "$INVENTORY")"
user="$(awk -F'ansible_user=' '/ansible_user=/ {print $2; exit}' "$INVENTORY")"
log "waiting for cloud-init on $host"
until ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 \
  "${user}@${host}" "cloud-init status --wait" >/dev/null 2>&1; do
  sleep 10
done

cd "$ROOT/ansible"
ansible-playbook site.yml
