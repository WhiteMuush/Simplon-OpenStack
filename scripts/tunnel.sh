#!/usr/bin/env bash
# Make sure the SSH tunnel to the lab API is up, opening it in the background
# when it is not. Nothing has to stay running in a second terminal.
source "$(dirname "$0")/lib.sh"

load_env
require_vars HORIZON_PORT

if timeout 2 bash -c "</dev/tcp/127.0.0.1/${HORIZON_PORT}" 2>/dev/null; then
  log "tunnel already up on port ${HORIZON_PORT}"
  exit 0
fi

host="$("${TF_AZURE[@]}" output -raw public_ip)"
user="$("${TF_AZURE[@]}" output -raw admin_username)"

# -f backgrounds it, -N asks for no remote command: it only forwards.
ssh -f -N -L "${HORIZON_PORT}:localhost:80" "${user}@${host}"
log "tunnel opened on port ${HORIZON_PORT}"
