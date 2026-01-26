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

NODE_DATA_DIR="${NODE_DATA_DIR:-${ROOT_DIR}/node-data}"
NODE_DATASETS_DIR="${NODE_DATASETS_DIR:-${NODE_DATA_DIR}/datasets}"
NODE_DATASET_METADATA_DIR="${NODE_DATASET_METADATA_DIR:-${NODE_DATA_DIR}/dataset_metadata}"

mkdir -p "${NODE_DATA_DIR}" "${NODE_DATASETS_DIR}" "${NODE_DATASET_METADATA_DIR}"

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

  echo "Waiting for orchestrator to start..."
  while true; do
    if (( $(date +%s) > end )); then
      echo "ERROR: Orchestrator did not start within ${timeout_s}s"
      exit 1
    fi

    local body code
    body="$(curl -sS -m 3 "${url}" 2>/dev/null || true)"
    code="$(curl -sS -m 3 -o /dev/null -w '%{http_code}' "${url}" 2>/dev/null || echo "000")"

    if [[ "${code}" == "200" && "${body}" == *'"status":"UP"'* ]]; then
      echo "Orchestrator is running."
      return 0
    fi
    sleep 2
  done
}

wait_for_node() {
  local url="http://localhost:${NODE_HOST_PORT}/taniwha/node/health"
  local timeout_s="${1:-120}"
  local end=$(( $(date +%s) + timeout_s ))

  echo "Waiting for node to start..."
  while true; do
    if (( $(date +%s) > end )); then
      echo "ERROR: Node did not start within ${timeout_s}s"
      docker logs --tail=200 mediata-node || true
      exit 1
    fi
    local code
    code="$(curl -sS -m 2 -o /dev/null -w '%{http_code}' "${url}" 2>/dev/null || echo "000")"
    if [[ "${code}" == "200" ]]; then
      echo "Node is running."
      return 0
    fi
    sleep 2
  done
}

[[ -d "$ORCH_DIR" ]] || { echo "Missing folder: $ORCH_DIR"; exit 1; }
[[ -f "${ORCH_DIR}/build-and-deploy.sh" ]] || { echo "Missing: ${ORCH_DIR}/build-and-deploy.sh"; exit 1; }

( cd "$ORCH_DIR" && run_bash_script "./build-and-deploy.sh" )
wait_for_orchestrator 300

[[ -d "$NODE_DIR" ]] || { echo "Missing folder: $NODE_DIR"; exit 1; }
[[ -f "${NODE_DIR}/node-secrets.env" ]] || { echo "Missing: ${NODE_DIR}/node-secrets.env"; exit 1; }

fix_crlf "${NODE_DIR}/entrypoint.sh"

if [[ -f "${NODE_DIR}/target/TANIWHA_Backend_node.jar" ]]; then
  NODE_DOCKERFILE="Dockerfile"
else
  NODE_DOCKERFILE="Dockerfile.build"
fi
docker build -f "${NODE_DIR}/${NODE_DOCKERFILE}" -t taniwha-backend-node "${NODE_DIR}"

docker rm -f mediata-node >/dev/null 2>&1 || true

NODE_IP_FOR_ORCH="http://host.docker.internal:${NODE_HOST_PORT}"

docker run -d \
  --name mediata-node \
  --add-host=host.docker.internal:host-gateway \
  --env-file "${NODE_DIR}/node-secrets.env" \
  -v "${NODE_DATA_DIR}:/taniwha" \
  -p "${NODE_HOST_PORT}:8080" \
  -e PORT=8080 \
  -e NAME="MEDIATA" \
  -e DESC="Your MEDIATA server" \
  -e COLOR="#008000" \
  -e NODE_IP="${NODE_IP_FOR_ORCH}" \
  -e HOST_URL="http://host.docker.internal:${ORCH_HOST_PORT}" \
  -e HOST_SERVICE="/taniwha" \
  -e tls.probe.enabled=false \
  taniwha-backend-node

wait_for_node 120

[[ -d "$FE_DIR" ]] || { echo "Missing folder: $FE_DIR"; exit 1; }

docker rm -f mediata-frontend >/dev/null 2>&1 || true

BACKEND_URL="${BACKEND_URL:-${ORCH_BASE_URL}}"

docker build \
  --no-cache \
  --build-arg REACT_APP_BACKEND_URL="${BACKEND_URL}" \
  --build-arg PUBLIC_URL="/" \
  -t mediata-frontend \
  "${FE_DIR}"

docker run -d --name mediata-frontend -p "${FE_HOST_PORT}:80" mediata-frontend

echo ""
echo "=============================="
echo "          FINISHED"
echo "=============================="
echo ""
echo "Frontend:     http://localhost:${FE_HOST_PORT}"
echo "Orchestrator: ${ORCH_BASE_URL}"
echo "Node API:     http://localhost:${NODE_HOST_PORT}/taniwha"
echo ""
echo "Node datasets folder (host):"
echo "  ${NODE_DATASETS_DIR}"
echo ""
echo "Node metadata folder (host):"
echo "  ${NODE_DATASET_METADATA_DIR}"
echo ""
