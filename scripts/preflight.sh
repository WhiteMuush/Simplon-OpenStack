#!/usr/bin/env bash
# Fail early on anything that would break halfway through the install.
source "$(dirname "$0")/lib.sh"

load_env
require_vars RG VM ADMIN HORIZON_PORT DEVSTACK_PASSWORD
require_cmd az terraform ansible-playbook ssh openssl

az account show >/dev/null 2>&1 || die "not logged in, run: az login"
log "azure subscription: $(az account show --query name -o tsv)"

[[ -f "$ROOT/terraform/azure/terraform.tfvars" ]] || die "terraform.tfvars is missing, run: make env"

cidr="$(grep -E '^allowed_ssh_cidr' "$ROOT/terraform/azure/terraform.tfvars" | cut -d'"' -f2)"
[[ -n "$cidr" ]] || die "allowed_ssh_cidr is not set in terraform/azure/terraform.tfvars"
[[ "$cidr" != "0.0.0.0/0" ]] || die "allowed_ssh_cidr is 0.0.0.0/0, narrow it to your own address"
# 203.0.113.0/24 is the documentation range shipped in the example file. Left
# as is it would lock you out of your own VM.
[[ "$cidr" != 203.0.113.* ]] \
  || die "allowed_ssh_cidr still holds the example value, set it to $(curl -s ifconfig.me 2>/dev/null || echo 'your public IP')/32"
log "ssh allowed from: $cidr"

# Nested virtualization exists on Dv3 and later, on the E and F families, and
# nowhere else. Without it Nova falls back to slow software emulation.
size="$(grep -E '^vm_size' "$ROOT/terraform/azure/terraform.tfvars" | cut -d'"' -f2)"
case "$size" in
  Standard_B*|Standard_A*|*_v2)
    die "$size has no nested virtualization, use Standard_D2s_v3" ;;
esac
log "vm size: $size"

# The quota is shared with the class, so a full region is a likely failure.
used="$(az vm list-usage -l "$(az group show -n "$RG" --query location -o tsv)" \
  --query "[?localName=='Total Regional vCPUs'].currentValue" -o tsv)"
limit="$(az vm list-usage -l "$(az group show -n "$RG" --query location -o tsv)" \
  --query "[?localName=='Total Regional vCPUs'].limit" -o tsv)"
log "regional vCPU quota: ${used}/${limit} used"

log "preflight passed"
