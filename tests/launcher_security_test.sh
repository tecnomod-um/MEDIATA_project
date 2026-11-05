#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$(mktemp -d /tmp/mediata-launcher-security.XXXXXX)"
cleanup() {
  if [[ "$FIXTURE" == /tmp/mediata-launcher-security.* ]]; then
    rm -rf -- "$FIXTURE"
  fi
}
trap cleanup EXIT

mkdir -p "$FIXTURE/bin"
cat > "$FIXTURE/bin/docker" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$*" == "compose version" ]]; then exit 0; fi
if [[ "${1:-}" == compose && "${2:-}" == up ]]; then
  [[ -f trusted-servers.config && ! -d trusted-servers.config ]] || {
    echo 'Trusted config file was not initialized before Compose' >&2
    exit 60
  }
  [[ "${TRUSTED_PROXY_ALLOW_HTTP_UPSTREAM:-}" == "$EXPECTED_HTTP" ]] || {
    echo 'HTTP policy did not honor its intended source' >&2
    exit 61
  }
  if [[ "$EXPECTED_HTTP" == true ]]; then
    [[ ",${TRUSTED_PROXY_ALLOWED_UPSTREAM_HOSTS}," == *,mediata-node,* ]] || exit 62
    grep -q 'http://mediata-node:8080|' trusted-servers.config || exit 63
  fi
  printf 'checked\n' > "$MARKER"
  # Stop before any actual service startup, health polling, or image build.
  exit 78
fi
echo "Unexpected Docker invocation: $*" >&2
exit 64
SH
chmod +x "$FIXTURE/bin/docker"

make_fixture() {
  local dest="$1"
  mkdir -p "$dest/MEDIATA_orchestrator" "$dest/MEDIATA_node" "$dest/evaluation"
  sed 's/\r$//' "$ROOT/run.sh" > "$dest/run.sh"
  sed 's/\r$//' "$ROOT/MEDIATA_orchestrator/build-and-deploy.sh" > "$dest/MEDIATA_orchestrator/build-and-deploy.sh"
  sed 's/\r$//' "$ROOT/MEDIATA_orchestrator/.env.example" > "$dest/MEDIATA_orchestrator/.env.example"
  printf 'TRUSTED_PROXY_SHARED_SECRET=fixture-only-shared-secret-at-least-32-characters\r\n' \
    > "$dest/MEDIATA_node/node-secrets.env.example"
  touch "$dest/evaluation/questionnaire.pdf" "$dest/evaluation/evaluation_tasks.pdf"
}

make_fixture "$FIXTURE/local"
set +e
env -u TRUSTED_PROXY_ALLOW_HTTP_UPSTREAM -u TRUSTED_PROXY_ALLOWED_UPSTREAM_HOSTS \
  -u TRUSTED_PROXY_SHARED_SECRET -u NODE_UPSTREAM_URL -u NODE_PUBLIC_HOST -u NODE_HOST_PORT \
  PATH="$FIXTURE/bin:$PATH" EXPECTED_HTTP=true MARKER="$FIXTURE/local.checked" \
  bash "$FIXTURE/local/run.sh" > "$FIXTURE/local.log" 2>&1
status=$?
set -e
if [[ $status != 78 || ! -f "$FIXTURE/local.checked" ]]; then
  cat "$FIXTURE/local.log" >&2
  echo "Fresh local bootstrap regression: exit $status" >&2
  exit 1
fi
echo 'PASS: fresh local bootstrap creates the bind file and preserves the private HTTP route'

make_fixture "$FIXTURE/production"
printf '# operator-supplied production config\n' > "$FIXTURE/production/MEDIATA_orchestrator/trusted-servers.config"
set +e
(
  cd "$FIXTURE/production/MEDIATA_orchestrator"
  env -u TRUSTED_PROXY_ALLOW_HTTP_UPSTREAM -u TRUSTED_PROXY_ALLOWED_UPSTREAM_HOSTS \
    PATH="$FIXTURE/bin:$PATH" EXPECTED_HTTP=false MARKER="$FIXTURE/production.checked" \
    bash ./build-and-deploy.sh
) > "$FIXTURE/production.log" 2>&1
status=$?
set -e
if [[ $status != 78 || ! -f "$FIXTURE/production.checked" ]]; then
  cat "$FIXTURE/production.log" >&2
  echo "Standalone production policy regression: exit $status" >&2
  exit 1
fi
echo 'PASS: standalone Compose keeps the production HTTP-deny default'
