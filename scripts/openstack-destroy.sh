#!/usr/bin/env bash
# Remove every OpenStack resource, leaving the host VM alone.
source "$(dirname "$0")/lib.sh"

load_env
"${TF_OS[@]}" destroy -input=false ${YES:+-auto-approve}
