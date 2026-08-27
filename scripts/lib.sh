#!/usr/bin/env bash
# Shared helpers. Sourced by every other script, never run directly.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_AZURE=(terraform -chdir="$ROOT/terraform/azure")
TF_OS=(terraform -chdir="$ROOT/terraform/openstack")
INVENTORY="$ROOT/ansible/inventory.ini"

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

confirm() {
  [[ "${YES:-}" == "1" ]] && return 0
  read -r -p "$1 [y/N] " answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}
