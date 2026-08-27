#!/usr/bin/env bash
# Shared helpers. Sourced by every other script, never run directly.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_AZURE=(terraform -chdir="$ROOT/terraform/azure")
TF_OS=(terraform -chdir="$ROOT/terraform/openstack")
INVENTORY="$ROOT/ansible/inventory.ini"

# Keeps the credentials inside the project rather than in the home directory.
# Gitignored, and read by both the openstack client and the Terraform provider.
export OS_CLIENT_CONFIG_FILE="$ROOT/clouds.yaml"

log()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31mxx\033[0m %s\n' "$*" >&2; exit 1; }

load_env() {
  [[ -f "$ROOT/.env" ]] || die ".env is missing, run: make env"
  set -a
  # shellcheck source=/dev/null
  source "$ROOT/.env"
  set +a
}

require_vars() {
  local missing=()
  for v in "$@"; do
    [[ -n "${!v:-}" ]] || missing+=("$v")
  done
  (( ${#missing[@]} == 0 )) || die "missing in .env: ${missing[*]}"
}

require_cmd() {
  local missing=()
  for c in "$@"; do
    command -v "$c" >/dev/null || missing+=("$c")
  done
  (( ${#missing[@]} == 0 )) || die "not installed: ${missing[*]}"
}

# Asks on /dev/tty rather than stdin, which make swallows. Some runners have
# no terminal at all, hence the explicit open test instead of a -r check.
confirm() {
  [[ "${YES:-}" == "1" ]] && return 0

  local answer=""
  if ! { exec 3</dev/tty; } 2>/dev/null; then
    die "no terminal to ask on, rerun with: make <target> YES=1"
  fi

  read -r -p "$1 [y/N] " answer <&3 || answer=""
  exec 3<&-
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}
