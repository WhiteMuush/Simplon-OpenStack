#!/usr/bin/env bash
# One command to run in front of an audience.
# Everything OpenStack runs on the lab host: Keystone advertises its catalog on
# the private address, so a client on the workstation authenticates and then
# hangs on the first real call.
source "$(dirname "$0")/lib.sh"

load_env
require_vars DEVSTACK_PASSWORD HORIZON_PORT
[[ -f "$INVENTORY" ]] || die "inventory is missing, run: make inventory"

here="$(dirname "$0")"

# Two runs at once fight over the Terraform state and leave the second one
# reading a half destroyed stack.
lock="${TMPDIR:-/tmp}/simplon-openstack-demo.lock"
exec 9>"$lock"
flock -n 9 || die "another demo is already running"

host="$(awk '/ansible_user=/ {print $1; exit}' "$INVENTORY")"
user="$(awk -F'ansible_user=' '/ansible_user=/ {print $2; exit}' "$INVENTORY")"

step() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
on_host() { ssh "${user}@${host}" "sudo -u stack -i bash -lc '$1'"; }
in_stack() { on_host "cd /opt/stack/lab-terraform && $1"; }

step "1. Preparing the host"
(cd "$ROOT/ansible" && ansible-playbook demo.yml)
"$here/tunnel.sh"

step "2. What the cloud holds before"
on_host "OS_CLOUD=lab openstack server list"

step "3. Terraform creates an instance"
in_stack "terraform init -input=false -no-color"
in_stack "terraform apply -input=false -auto-approve -no-color"

step "4. The instance is up"
on_host "OS_CLOUD=lab openstack server list"

step "5. Where it actually runs"
on_host "OS_CLOUD=lab openstack hypervisor list"

step "6. Logging into the instance from here"
fip="$(in_stack 'terraform output -raw floating_ip' | tr -d '\r' | tr -d '[:space:]')"
[[ -n "$fip" ]] || die "no floating IP in the Terraform state, rerun: make demo"

# Terraform returns as soon as Nova reports ACTIVE, well before CirrOS has
# started sshd. Retry rather than fail on the first refusal.
log "waiting for sshd on ${fip}"
for _ in $(seq 30); do
  if ssh -J "${user}@${host}" -o StrictHostKeyChecking=accept-new \
       -o ConnectTimeout=5 -o BatchMode=yes "cirros@${fip}" true 2>/dev/null; then
    break
  fi
  sleep 5
done

ssh -J "${user}@${host}" -o StrictHostKeyChecking=accept-new \
  -o ConnectTimeout=10 "cirros@${fip}" 'hostname; uptime'

step "Dashboard: http://localhost:${HORIZON_PORT}/dashboard  (user admin)"
step "Reconnect: ssh -J ${user}@${host} cirros@${fip}"
step "Tear it down with: make demo-clean"
