#!/usr/bin/env bash
# Power actions on the host. A deallocated VM stops the compute billing,
# a plain poweroff does not.
source "$(dirname "$0")/lib.sh"

load_env
require_vars RG VM

case "${1:-status}" in
  status) az vm show -d -g "$RG" -n "$VM" --query powerState -o tsv ;;
  start)  az vm start -g "$RG" -n "$VM" ;;
  stop)   az vm deallocate -g "$RG" -n "$VM" ;;
  *)      die "usage: power.sh [status|start|stop]" ;;
esac
