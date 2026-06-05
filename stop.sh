#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="${ROOT_DIR}/MEDIATA_orchestrator"
NODE_DIR="${ROOT_DIR}/MEDIATA_node"
FE_DIR="${ROOT_DIR}/MEDIATA_frontend"

sed_in_place() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

fix_crlf() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  sed_in_place 's/\r$//' "$f" || true
}

compose_down_if_present() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  if [[ -f "${dir}/docker-compose.yml" ]]; then
    ( cd "$dir" && docker compose down -v --remove-orphans || true )
  elif [[ -f "${dir}/compose.yml" ]]; then
    ( cd "$dir" && docker compose -f compose.yml down -v --remove-orphans || true )
  fi
}

remove_container_if_present() {
  local name="$1"
  local timeout_s="${2:-30}"

  if ! docker ps -a --format '{{.Names}}' | grep -Fxq "$name"; then
    return 0
  fi

  docker stop -t "${timeout_s}" "$name" >/dev/null 2>&1 || true
  docker rm -f "$name" >/dev/null 2>&1 || true
}

echo "================================================"
echo "MEDIATA - Teardown Script"
echo "================================================"
echo ""

# ---- Frontend ----
echo "[1/3] Stopping frontend..."
compose_down_if_present "$FE_DIR"
docker rm -f mediata-frontend >/dev/null 2>&1 || true
echo "✓ Frontend stopped"

# ---- Node ----
echo "[2/3] Stopping node..."
remove_container_if_present mediata-node 45
echo "✓ Node stopped"

# ---- Orchestrator stack ----
echo "[3/3] Stopping orchestrator stack..."
compose_down_if_present "$ORCH_DIR"
echo "✓ Orchestrator stack stopped"

echo ""
echo "================================================"
echo "Teardown complete."
echo "================================================"
echo ""
