#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="${ROOT_DIR}/MEDIATA_orchestrator"
NODE_DIR="${ROOT_DIR}/MEDIATA_node"
FE_DIR="${ROOT_DIR}/MEDIATA_frontend"

ORCH_HOST_PORT="${ORCH_HOST_PORT:-18088}"
NODE_HOST_PORT="${NODE_HOST_PORT:-18082}"
FE_HOST_PORT="${FE_HOST_PORT:-3000}"
NODE_DOCKER_PLATFORM="${NODE_DOCKER_PLATFORM:-linux/amd64}"
NODE_HEALTH_TIMEOUT_S="${NODE_HEALTH_TIMEOUT_S:-600}"
LOCAL_FDP_TIMEOUT_S="${LOCAL_FDP_TIMEOUT_S:-300}"

ORCH_BASE_URL="http://localhost:${ORCH_HOST_PORT}/taniwha"
NODE_DATA_DIR="${ROOT_DIR}/node-data"
TRUSTED_NODE_CONFIG="${ORCH_DIR}/trusted-servers.config"

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
  sed_in_place 's/\r$//' "$f" 2>/dev/null || true
}

run_bash_script() {
  local f="$1"
  [[ -f "$f" ]] || { echo "Missing script: $f"; exit 1; }
  fix_crlf "$f"
  chmod +x "$f" || true
  bash "$f"
}

ensure_node_secrets_file() {
  if [[ ! -f "${NODE_DIR}/node-secrets.env" ]]; then
    if [[ -f "${NODE_DIR}/node-secrets.env.example" ]]; then
      echo "No node-secrets.env found. Creating from node-secrets.env.example..."
      cp "${NODE_DIR}/node-secrets.env.example" "${NODE_DIR}/node-secrets.env"
      echo "✓ Created ${NODE_DIR}/node-secrets.env"
      echo "IMPORTANT: Review ${NODE_DIR}/node-secrets.env and set real secret values before production."
    else
      echo "Missing: ${NODE_DIR}/node-secrets.env (and no ${NODE_DIR}/node-secrets.env.example to copy from)"
      exit 1
    fi
  fi
}

read_env_var() {
  local file="$1"
  local key="$2"
  [[ -f "$file" ]] || return 0
  grep -E "^${key}=" "$file" | tail -n 1 | cut -d= -f2- || true
}

upsert_env_var() {
  local file="$1"
  local key="$2"
  local value="$3"

  if grep -qE "^${key}=" "$file"; then
    sed_in_place "s|^${key}=.*|${key}=${value}|" "$file"
  else
    printf '\n%s=%s\n' "$key" "$value" >> "$file"
  fi
}

generate_shared_secret() {
  python3 - <<'PY'
import secrets
print(secrets.token_urlsafe(48))
PY
}

configure_trusted_proxy_secret() {
  local secret="${TRUSTED_PROXY_SHARED_SECRET:-}"

  ensure_node_secrets_file
  if [[ -z "$secret" ]]; then
    secret="$(read_env_var "${NODE_DIR}/node-secrets.env" "TRUSTED_PROXY_SHARED_SECRET")"
  fi
  if [[ -z "$secret" ]]; then
    secret="$(generate_shared_secret)"
  fi

  export TRUSTED_PROXY_SHARED_SECRET="$secret"
  upsert_env_var "${NODE_DIR}/node-secrets.env" "TRUSTED_PROXY_SHARED_SECRET" "$secret"

  mkdir -p "$(dirname "${TRUSTED_NODE_CONFIG}")"
  cat > "${TRUSTED_NODE_CONFIG}" <<EOF
# public HTTP node URL | upstream URL from orchestrator container | optional shared secret
http://localhost:${NODE_HOST_PORT}|http://host.docker.internal:${NODE_HOST_PORT}|${TRUSTED_PROXY_SHARED_SECRET}
EOF
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

wait_for_local_fdp() {
  local timeout_s="${1:-300}"
  local end=$(( $(date +%s) + timeout_s ))

  echo "Waiting for bundled FAIR Data Point inside node container..."
  while true; do
    if (( $(date +%s) > end )); then
      echo "ERROR: Bundled FAIR Data Point not ready in ${timeout_s}s"
      docker logs --tail=200 mediata-node || true
      docker exec mediata-node sh -lc \
        'echo "--- /var/log/taniwha"; ls -la /var/log/taniwha 2>/dev/null || true; \
         echo "--- fdp.log"; tail -n 200 /var/log/taniwha/fdp.log 2>/dev/null || true; \
         echo "--- mongod.log"; tail -n 200 /var/log/taniwha/mongod.log 2>/dev/null || true' || true
      exit 1
    fi

    if docker exec mediata-node sh -lc \
      "curl -fsS http://127.0.0.1:18080/v3/api-docs >/dev/null" >/dev/null 2>&1; then
      echo "Bundled FAIR Data Point is UP."
      return 0
    fi

    sleep 2
  done
}

json_field() {
  local json="$1"
  local field="$2"
  JSON_PAYLOAD="${json}" python3 - "$field" <<'PY'
import json
import os
import sys

field = sys.argv[1]
payload = os.environ.get("JSON_PAYLOAD", "")

try:
    data = json.loads(payload)
except json.JSONDecodeError:
    sys.exit(1)

value = data.get(field, "")
if isinstance(value, str):
    sys.stdout.write(value)
PY
}

json_first_array_field() {
  local json="$1"
  local field="$2"
  JSON_PAYLOAD="${json}" python3 - "$field" <<'PY'
import json
import os
import sys

field = sys.argv[1]
payload = os.environ.get("JSON_PAYLOAD", "")

try:
    data = json.loads(payload)
except json.JSONDecodeError:
    sys.exit(1)

if isinstance(data, list) and data:
    value = data[0].get(field, "")
    if isinstance(value, str):
        sys.stdout.write(value)
PY
}

sync_sample_fair_metadata() {
  local username="${LOCAL_ADMIN_USER:-admin}"
  local password="${LOCAL_ADMIN_PASSWORD:-admin}"
  local registration_timeout_s="${NODE_REGISTRATION_TIMEOUT_S:-60}"
  local registration_sleep_s="${NODE_REGISTRATION_SLEEP_S:-2}"
  local registration_deadline=$(( $(date +%s) + registration_timeout_s ))
  local sync_timeout_s="${NODE_SYNC_TIMEOUT_S:-90}"
  local sync_sleep_s="${NODE_SYNC_SLEEP_S:-3}"
  local sync_deadline=$(( $(date +%s) + sync_timeout_s ))

  echo "Refreshing FAIR metadata for loaded sample datasets..."

  local login_response
  login_response="$(curl -sS -f \
    -H 'Content-Type: application/json' \
    -d "{\"username\":\"${username}\",\"password\":\"${password}\"}" \
    "${ORCH_BASE_URL}/api/user/login")"

  local central_jwt kerberos_tgt node_id node_info_response service_ticket node_jwt sync_response
  central_jwt="$(json_field "${login_response}" "token")"
  kerberos_tgt="$(json_field "${login_response}" "tgt")"
  [[ -n "${central_jwt}" && -n "${kerberos_tgt}" ]] || {
    echo "ERROR: Could not obtain local admin session for FAIR metadata sync."
    exit 1
  }

  while [[ -z "${node_id:-}" ]]; do
    if (( $(date +%s) > registration_deadline )); then
      echo "ERROR: Could not resolve local node id for FAIR metadata sync."
      exit 1
    fi

    node_id="$(
      curl -sS -f \
        -H "Authorization: Bearer ${central_jwt}" \
        "${ORCH_BASE_URL}/nodes/connect/list" \
      | { response="$(cat)"; json_first_array_field "${response}" "nodeId"; }
    )"

    if [[ -z "${node_id}" ]]; then
      sleep "${registration_sleep_s}"
    fi
  done

  while true; do
    if (( $(date +%s) > sync_deadline )); then
      echo "ERROR: FAIR metadata sync did not become ready within ${sync_timeout_s}s."
      exit 1
    fi

    node_info_response="$(curl -sS \
      -H "Authorization: Bearer ${central_jwt}" \
      -H "Kerberos-TGT: ${kerberos_tgt}" \
      "${ORCH_BASE_URL}/nodes/connect/info/${node_id}" 2>/dev/null || true)"
    service_ticket="$(json_field "${node_info_response}" "token" || true)"

    if [[ -z "${service_ticket}" ]]; then
      sleep "${sync_sleep_s}"
      continue
    fi

    node_jwt="$(
      curl -sS \
        -H "Authorization: Bearer ${central_jwt}" \
        -H 'Content-Type: application/json' \
        -d "{\"kerberosToken\":\"${service_ticket}\"}" \
        "${ORCH_BASE_URL}/nodes/proxy/${node_id}/taniwha/node/validate" 2>/dev/null \
      | { response="$(cat)"; json_field "${response}" "jwtNodeToken" || true; }
    )"

    if [[ -z "${node_jwt}" || "${node_jwt}" == "Unauthorized" ]]; then
      sleep "${sync_sleep_s}"
      continue
    fi

    sync_response="$(curl -sS \
      -X POST \
      -H "Authorization: Bearer ${central_jwt}" \
      -H "X-Node-Authorization: Bearer ${node_jwt}" \
      "${ORCH_BASE_URL}/nodes/proxy/${node_id}/taniwha/api/fairdatapoint/sync" 2>/dev/null || true)"

    if [[ "${sync_response}" == *'"status":"COMPLETED"'* ]]; then
      break
    fi

    sleep "${sync_sleep_s}"
  done

  echo "FAIR metadata refreshed."
}

# ---------------- Evaluation PDFs ----------------
if [[ ! -f "${ROOT_DIR}/evaluation/questionnaire.pdf" || ! -f "${ROOT_DIR}/evaluation/evaluation_tasks.pdf" ]]; then
  if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is required to run this project."
    exit 1
  fi

  if ! docker image inspect python:3.11-slim >/dev/null 2>&1; then
    docker pull --quiet python:3.11-slim >/dev/null 2>&1
  fi

  docker run --rm --pull=never \
    -v "${ROOT_DIR}:/work" \
    -w /work \
    python:3.11-slim \
    sh -lc "python -m pip -q install --no-cache-dir reportlab >/dev/null 2>&1 && python evaluation/scripts/generate_pdfs.py"
fi

# ---------------- Orchestrator ----------------
[[ -d "$ORCH_DIR" ]] || { echo "Missing folder: $ORCH_DIR"; exit 1; }
[[ -f "${ORCH_DIR}/build-and-deploy.sh" ]] || { echo "Missing: ${ORCH_DIR}/build-and-deploy.sh"; exit 1; }

configure_trusted_proxy_secret

( cd "$ORCH_DIR" && run_bash_script "./build-and-deploy.sh" )
wait_for_orchestrator 300

# ---------------- Node ----------------
mkdir -p "${NODE_DATA_DIR}"
[[ -d "$NODE_DIR" ]] || { echo "Missing folder: $NODE_DIR"; exit 1; }
ensure_node_secrets_file

fix_crlf "${NODE_DIR}/entrypoint.sh"

# Build node image
if [[ -f "${NODE_DIR}/target/TANIWHA_Backend_node.jar" ]]; then
  NODE_DOCKERFILE="Dockerfile"
else
  NODE_DOCKERFILE="Dockerfile.build"
fi
docker build --platform "${NODE_DOCKER_PLATFORM}" -f "${NODE_DIR}/${NODE_DOCKERFILE}" -t taniwha-backend-node "${NODE_DIR}"
docker rm -f mediata-node >/dev/null 2>&1 || true

NODE_IP="http://localhost:${NODE_HOST_PORT}"

docker run -d \
  --platform "${NODE_DOCKER_PLATFORM}" \
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
  -e FAIRDATAPOINT_PUBLISH_ON_STARTUP=false \
  taniwha-backend-node

wait_for_node "${NODE_HEALTH_TIMEOUT_S}"
wait_for_local_fdp "${LOCAL_FDP_TIMEOUT_S}"

sh "${ROOT_DIR}/evaluation/scripts/load_sample_datasets.sh"
sync_sample_fair_metadata

echo "Node (host): http://localhost:${NODE_HOST_PORT}/taniwha"
echo "Node registered as: http://localhost:${NODE_HOST_PORT}"
docker exec mediata-orchestrator sh -lc \
  "curl -fsS http://host.docker.internal:${NODE_HOST_PORT}/taniwha/node/health"

# ---------------- Frontend ----------------
[[ -d "$FE_DIR" ]] || { echo "Missing folder: $FE_DIR"; exit 1; }

docker rm -f mediata-frontend >/dev/null 2>&1 || true

BACKEND_URL="${BACKEND_URL:-${ORCH_BASE_URL}}"
echo "Building frontend with REACT_APP_BACKEND_URL=${BACKEND_URL}"

docker build \
  --no-cache \
  --build-arg VITE_BACKEND_URL="${BACKEND_URL}" \
  --build-arg VITE_BASE_PATH="/" \
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
