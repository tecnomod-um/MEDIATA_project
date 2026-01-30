#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="${ROOT_DIR}/MEDIATA_orchestrator"
NODE_DIR="${ROOT_DIR}/MEDIATA_node"
FE_DIR="${ROOT_DIR}/MEDIATA_frontend"

ORCH_HOST_PORT="${ORCH_HOST_PORT:-18088}"
NODE_HOST_PORT="${NODE_HOST_PORT:-18082}"
FE_HOST_PORT="${FE_HOST_PORT:-3000}"

ORCH_BASE_URL="http://localhost:${ORCH_HOST_PORT}/taniwha"
NODE_DATA_DIR="${ROOT_DIR}/node-data"

fix_crlf() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  sed -i 's/\r$//' "$f" 2>/dev/null || true
}

run_bash_script() {
  local f="$1"
  [[ -f "$f" ]] || { echo "Missing script: $f"; exit 1; }
  fix_crlf "$f"
  chmod +x "$f" || true
  bash "$f"
}

wait_for_orchestrator() {
  local url="${ORCH_BASE_URL}/actuator/health"
  local timeout_s="${1:-300}"
  local end=$(( $(date +%s) + timeout_s ))

  echo "Waiting for orchestrator health to be UP: ${url}"
  while true; do
    if (( $(date +%s) > end )); then
      echo "ERROR: Orchestrator did not become UP within ${timeout_s}s: ${url}"
      echo "Try: (cd \"${ORCH_DIR}\" && docker compose ps && docker compose logs -n 200 orchestrator)"
      exit 1
    fi

    local body code
    body="$(curl -sS -m 3 "${url}" 2>/dev/null || true)"
    code="$(curl -sS -m 3 -o /dev/null -w '%{http_code}' "${url}" 2>/dev/null || echo "000")"

    if [[ "${code}" == "200" && "${body}" == *'"status":"UP"'* ]]; then
      echo "Orchestrator is UP."
      return 0
    fi
    echo "  not ready yet (HTTP ${code})"
    sleep 2
  done
}

wait_for_node() {
  local url="http://localhost:${NODE_HOST_PORT}/taniwha/node/health"
  local timeout_s="${1:-120}"
  local end=$(( $(date +%s) + timeout_s ))

  echo "Waiting for node health: ${url}"
  while true; do
    if (( $(date +%s) > end )); then
      echo "ERROR: Node not reachable in ${timeout_s}s"
      docker logs --tail=200 mediata-node || true
      exit 1
    fi
    local code
    code="$(curl -sS -m 2 -o /dev/null -w '%{http_code}' "${url}" 2>/dev/null || echo "000")"
    if [[ "${code}" == "200" ]]; then
      echo "Node is UP."
      return 0
    fi
    sleep 2
  done
}

# ---------------- Orchestrator ----------------
[[ -d "$ORCH_DIR" ]] || { echo "Missing folder: $ORCH_DIR"; exit 1; }
[[ -f "${ORCH_DIR}/build-and-deploy.sh" ]] || { echo "Missing: ${ORCH_DIR}/build-and-deploy.sh"; exit 1; }

( cd "$ORCH_DIR" && run_bash_script "./build-and-deploy.sh" )
wait_for_orchestrator 300

# ---------------- Node ----------------
mkdir -p "${NODE_DATA_DIR}"
[[ -d "$NODE_DIR" ]] || { echo "Missing folder: $NODE_DIR"; exit 1; }
[[ -f "${NODE_DIR}/node-secrets.env" ]] || { echo "Missing: ${NODE_DIR}/node-secrets.env"; exit 1; }

fix_crlf "${NODE_DIR}/entrypoint.sh"

# Build node image
if [[ -f "${NODE_DIR}/target/TANIWHA_Backend_node.jar" ]]; then
  NODE_DOCKERFILE="Dockerfile"
else
  NODE_DOCKERFILE="Dockerfile.build"
fi
docker build -f "${NODE_DIR}/${NODE_DOCKERFILE}" -t taniwha-backend-node "${NODE_DIR}"
docker rm -f mediata-node >/dev/null 2>&1 || true

NODE_IP="http://localhost:${NODE_HOST_PORT}"

docker run -d \
  --name mediata-node \
  --add-host=host.docker.internal:host-gateway \
  --env-file "${NODE_DIR}/node-secrets.env" \
  -v "${NODE_DATA_DIR}:/taniwha" \
  -p "0.0.0.0:${NODE_HOST_PORT}:8080" \
  -e PORT=8080 \
  -e NAME="MEDIATA" \
  -e DESC="Your MEDIATA server" \
  -e COLOR="#2596be" \
  -e NODE_IP="${NODE_IP}" \
  -e HOST_URL="http://host.docker.internal:${ORCH_HOST_PORT}" \
  -e HOST_SERVICE="/taniwha" \
  taniwha-backend-node

wait_for_node 120

echo "Node (host): http://localhost:${NODE_HOST_PORT}/taniwha"
echo "Node registered as: http://localhost:${NODE_HOST_PORT}"
docker exec -it mediata-orchestrator sh -lc \
  "curl -fsS http://host.docker.internal:${NODE_HOST_PORT}/taniwha/node/health"

# ---------------- Frontend ----------------
[[ -d "$FE_DIR" ]] || { echo "Missing folder: $FE_DIR"; exit 1; }

docker rm -f mediata-frontend >/dev/null 2>&1 || true

BACKEND_URL="${BACKEND_URL:-${ORCH_BASE_URL}}"
echo "Building frontend with REACT_APP_BACKEND_URL=${BACKEND_URL}"

docker build \
  --no-cache \
  --build-arg REACT_APP_BACKEND_URL="${BACKEND_URL}" \
  --build-arg PUBLIC_URL="/" \
  -t mediata-frontend \
  "${FE_DIR}"

docker run -d --name mediata-frontend -p "${FE_HOST_PORT}:80" mediata-frontend

# ---------------- Summary ----------------
echo ""
echo "========================================"
echo "                FINISHED"
echo "========================================"
echo ""
echo "Services:"
echo "  Frontend:     http://localhost:${FE_HOST_PORT}"
echo "  Orchestrator: ${ORCH_BASE_URL}"
echo "  Node API:     http://localhost:${NODE_HOST_PORT}/taniwha"
echo ""

echo "----------------------------------------"
echo "Node data storage"
echo "----------------------------------------"
echo ""
echo "  Host folder:  ${NODE_DATA_DIR}"
echo "  Container:    /taniwha"
echo ""

echo "----------------------------------------"
echo "Logs"
echo "----------------------------------------"
echo "  Orchestrator: (cd \"${ORCH_DIR}\" && docker compose logs -f orchestrator)"
echo "  Node:         docker logs -f mediata-node"
echo "  Frontend:     docker logs -f mediata-frontend"
echo ""
