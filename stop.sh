#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="${ROOT_DIR}/MEDIATA_orchestrator"
NODE_DIR="${ROOT_DIR}/MEDIATA_node"
FE_DIR="${ROOT_DIR}/MEDIATA_frontend"

fix_crlf() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  sed -i 's/\r$//' "$f" || true
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
docker rm -f mediata-node >/dev/null 2>&1 || true
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
