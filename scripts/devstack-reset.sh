#!/usr/bin/env bash
# Wipe a broken DevStack so stack.sh can start over. Mandatory after a failed
# run: DevStack has no partial rollback, a retry on a dirty tree fails again.
source "$(dirname "$0")/lib.sh"

load_env
[[ -f "$INVENTORY" ]] || die "inventory is missing, run: make inventory"

host="$(awk '/ansible_user=/ {print $1; exit}' "$INVENTORY")"
user="$(awk -F'ansible_user=' '/ansible_user=/ {print $2; exit}' "$INVENTORY")"

confirm "Wipe the DevStack install on ${host}?" || die "aborted"

ssh "${user}@${host}" 'sudo -u stack -i bash -lc "cd /opt/stack/devstack && ./unstack.sh; ./clean.sh"'
log "reset done, run: make install"
