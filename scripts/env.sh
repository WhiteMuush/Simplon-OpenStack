#!/usr/bin/env bash
# Create the local config files from their committed examples.
source "$(dirname "$0")/lib.sh"

copy_missing() {
  if [[ -f "$2" ]]; then
    log "$2 already exists, left untouched"
  else
    cp "$1" "$2"
    log "created $2"
  fi
}

copy_missing "$ROOT/.env.example" "$ROOT/.env"
copy_missing "$ROOT/terraform/azure/terraform.tfvars.example" "$ROOT/terraform/azure/terraform.tfvars"
copy_missing "$ROOT/terraform/openstack/terraform.tfvars.example" "$ROOT/terraform/openstack/terraform.tfvars"

# A lab password still deserves a real one: the repo is public and the file is
# gitignored, so there is no reason to reuse a weak value.
if ! grep -q '^DEVSTACK_PASSWORD=.\+' "$ROOT/.env"; then
  password="$(openssl rand -base64 24)"
  sed -i "s|^DEVSTACK_PASSWORD=.*|DEVSTACK_PASSWORD=${password}|" "$ROOT/.env"
  log "generated DEVSTACK_PASSWORD"
fi

warn "review terraform/azure/terraform.tfvars before applying, especially allowed_ssh_cidr"
