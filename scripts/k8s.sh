#!/usr/bin/env bash
# Single node k3s inside the OpenStack lab, driven by Terraform.
# One node on purpose: the host has 8 GB and OpenStack already holds three of
# them. This shows the chain, not high availability.
source "$(dirname "$0")/lib.sh"

load_env
require_vars DEVSTACK_PASSWORD
[[ -f "$INVENTORY" ]] || die "inventory is missing, run: make inventory"

lock="${TMPDIR:-/tmp}/simplon-openstack-k8s.lock"
exec 9>"$lock"
flock -n 9 || die "another kubernetes run is already in progress"

here="$(dirname "$0")"
host="$(awk '/ansible_user=/ {print $1; exit}' "$INVENTORY")"
user="$(awk -F'ansible_user=' '/ansible_user=/ {print $2; exit}' "$INVENTORY")"

step() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
on_host() { ssh "${user}@${host}" "sudo -u stack -i bash -lc '$1'"; }
in_stack() { on_host "cd /opt/stack/lab-kubernetes && $1"; }

step "1. Preparing the host and the Ubuntu image"
(cd "$ROOT/ansible" && ansible-playbook demo.yml)
(cd "$ROOT/ansible" && ansible-playbook k8s.yml)

step "2. Terraform creates the node"
in_stack "terraform init -input=false -no-color"
in_stack "terraform apply -input=false -auto-approve -no-color ${REPLACE:+-replace=openstack_compute_instance_v2.k3s}"

fip="$(in_stack 'terraform output -raw floating_ip' | tr -d '[:space:]')"
[[ -n "$fip" ]] || die "no floating IP in the Terraform state"

# Floating IPs are recycled here, so a recreated node presents a new host key
# on an address that is already known. The entry is dropped from a known_hosts
# file scoped to this lab, never from the personal one.
known_hosts="$ROOT/.lab_known_hosts"
touch "$known_hosts"
ssh-keygen -f "$known_hosts" -R "$fip" >/dev/null 2>&1 || true

step "3. Waiting for k3s"
# The node holds the workstation public key, so the jump has to start here:
# the lab host has no private key of its own.
node_ssh() {
  ssh -J "${user}@${host}" -o StrictHostKeyChecking=accept-new \
    -o UserKnownHostsFile="$known_hosts" \
    -o ConnectTimeout=10 "ubuntu@${fip}" "$1"
}

# cloud-init boots the node, then pulls and starts k3s. Several minutes on a
# 1 vCPU flavor, so this polls rather than failing on the first refusal.
for _ in $(seq 60); do
  if node_ssh 'test -f /etc/rancher/k3s/k3s.yaml' 2>/dev/null; then
    break
  fi
  sleep 10
done
node_ssh 'sudo k3s kubectl get nodes' \
  || die "k3s did not come up, check: ssh -J ${user}@${host} ubuntu@${fip}"

step "4. Fetching the kubeconfig"
# The API answers on the node, so the file is rewritten to point at the local
# end of an SSH tunnel. k3s already lists 127.0.0.1 in its certificate.
node_ssh 'sudo cat /etc/rancher/k3s/k3s.yaml' > "$ROOT/kubeconfig"
chmod 600 "$ROOT/kubeconfig"
log "wrote $ROOT/kubeconfig"

step "What you can do now"
cat <<SUMMARY

  Open the tunnel to the Kubernetes API, and leave it running
    ssh -N -L 6443:${fip}:6443 ${user}@${host}

  Then, from this project directory
    export KUBECONFIG=\$PWD/kubeconfig
    kubectl get nodes

  Log into the node itself
    ssh -J ${user}@${host} -o UserKnownHostsFile=.lab_known_hosts ubuntu@${fip}

  Remove the cluster
    make k8s-clean

SUMMARY
