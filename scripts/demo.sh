#!/usr/bin/env bash
# One command to run in front of an audience: opens the path to the lab,
# creates an instance with Terraform, then shows what the cloud now holds.
source "$(dirname "$0")/lib.sh"

load_env
here="$(dirname "$0")"
export OS_CLOUD=lab

step() { printf '\n\033[1;36m%s\033[0m\n' "$*"; }

step "1. Opening the path to the lab"
"$here/tunnel.sh"
"$here/clouds-config.sh"

step "2. What the cloud looks like right now"
openstack server list

step "3. Creating an instance with Terraform"
"${TF_OS[@]}" init -input=false -no-color
"${TF_OS[@]}" apply -input=false -auto-approve -no-color

step "4. The instance is up"
openstack server list
openstack server show -c name -c status -c addresses -c flavor \
  "$("${TF_OS[@]}" output -raw instance_id)"

step "5. Where it actually runs"
openstack hypervisor list

step "Dashboard: http://localhost:${HORIZON_PORT}/dashboard  (user admin)"
step "Tear the instance down with: make demo-clean"
