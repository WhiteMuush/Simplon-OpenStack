#!/usr/bin/env bash
# Write ~/.config/openstack/clouds.yaml from .env, so the password is never
# copied by hand. Only touches a file this script wrote itself.
source "$(dirname "$0")/lib.sh"

load_env
require_vars DEVSTACK_PASSWORD HORIZON_PORT

target="$HOME/.config/openstack/clouds.yaml"
marker="# managed by Simplon-OpenStack"

if [[ -f "$target" ]] && ! grep -qF "$marker" "$target"; then
  die "$target exists and was not written by this repo, leaving it alone"
fi

mkdir -p "$(dirname "$target")"
cat > "$target" <<YAML
${marker}
clouds:
  lab:
    auth:
      auth_url: http://127.0.0.1:${HORIZON_PORT}/identity
      username: admin
      password: ${DEVSTACK_PASSWORD}
      project_name: admin
      user_domain_name: Default
      project_domain_name: Default
    region_name: RegionOne
    interface: public
    identity_api_version: 3
YAML
chmod 600 "$target"
log "wrote $target"
