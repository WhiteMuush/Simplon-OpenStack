#!/usr/bin/env bash
# Loads .env, then falls back to defaults for anything left unset.

ENV_FILE="$(dirname "$0")/../.env"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  source "$ENV_FILE"
  set +a
fi

export RG="${RG:-mpetitRG}"
export LOC="${LOC:-francecentral}"
export VM="${VM:-devstack}"
export ADMIN="${ADMIN:-azureuser}"
export SIZE="${SIZE:-Standard_D4s_v4}"
export DISK_GB="${DISK_GB:-64}"
export SHUTDOWN_TIME="${SHUTDOWN_TIME:-2000}"
export HORIZON_PORT="${HORIZON_PORT:-8080}"
