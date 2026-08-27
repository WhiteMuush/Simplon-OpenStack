#!/usr/bin/env bash
# Destroy the Kubernetes node, leaving the OpenStack lab running.
source "$(dirname "$0")/lib.sh"

load_env
[[ -f "$INVENTORY" ]] || die "inventory is missing, run: make inventory"

host="$(awk '/ansible_user=/ {print $1; exit}' "$INVENTORY")"
user="$(awk -F'ansible_user=' '/ansible_user=/ {print $2; exit}' "$INVENTORY")"

ssh "${user}@${host}" "sudo -u stack -i bash -lc 'cd /opt/stack/lab-kubernetes && terraform destroy -input=false -auto-approve -no-color'"
rm -f "$ROOT/kubeconfig"
