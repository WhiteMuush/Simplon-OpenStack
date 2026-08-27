#!/usr/bin/env bash
# Create the OpenStack resources described in terraform/openstack.
source "$(dirname "$0")/lib.sh"

load_env

# Both are idempotent: the tunnel is reused when already open, and the config
# is only rewritten when this repo owns it.
here="$(dirname "$0")"
"$here/tunnel.sh"
"$here/clouds-config.sh"

"${TF_OS[@]}" init -input=false
"${TF_OS[@]}" apply -input=false ${YES:+-auto-approve}
