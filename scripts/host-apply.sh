#!/usr/bin/env bash
# Build the Azure host VM.
source "$(dirname "$0")/lib.sh"

load_env
"${TF_AZURE[@]}" init -input=false
"${TF_AZURE[@]}" apply -input=false ${YES:+-auto-approve}
log "public ip: $("${TF_AZURE[@]}" output -raw public_ip)"
