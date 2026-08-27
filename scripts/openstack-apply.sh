#!/usr/bin/env bash
# Create the OpenStack resources described in terraform/openstack.
source "$(dirname "$0")/lib.sh"

load_env
[[ -f "$HOME/.config/openstack/clouds.yaml" ]] \
  || die "~/.config/openstack/clouds.yaml is missing, start from clouds.yaml.example"

"${TF_OS[@]}" init -input=false
"${TF_OS[@]}" apply -input=false ${YES:+-auto-approve}
