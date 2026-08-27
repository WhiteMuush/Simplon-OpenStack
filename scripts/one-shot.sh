#!/usr/bin/env bash
# Everything in one run: checks, host VM, inventory, DevStack.
# Roughly an hour, most of it inside stack.sh.
source "$(dirname "$0")/lib.sh"

here="$(dirname "$0")"

[[ -f "$ROOT/.env" ]] || "$here/env.sh"

load_env
log "target: VM $VM in $RG"

# Checks first, so a wrong CIDR or a missing tool fails before the prompt.
"$here/preflight.sh"

confirm "This creates billable Azure resources. Continue?" || die "aborted"
"$here/host-apply.sh"
"$here/inventory.sh"
"$here/devstack-install.sh"

log "done"
log "open the dashboard with: make connect"
log "stop the billing with:   make stop"
