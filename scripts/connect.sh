#!/usr/bin/env bash
# SSH into the host with Horizon tunnelled to a local port.
source "$(dirname "$0")/lib.sh"

load_env
require_vars HORIZON_PORT

host="$("${TF_AZURE[@]}" output -raw public_ip)"
user="$("${TF_AZURE[@]}" output -raw admin_username)"

log "horizon: http://localhost:${HORIZON_PORT}/dashboard"
log "password is DEVSTACK_PASSWORD from .env"
exec ssh -L "${HORIZON_PORT}:localhost:80" "${user}@${host}"
