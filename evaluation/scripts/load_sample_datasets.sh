#!/usr/bin/env sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
NODE_DATA_DIR="${ROOT_DIR}/node-data"
TARGET_DIR="${NODE_DATA_DIR}/datasets"
SAMPLE_DIR="${ROOT_DIR}/evaluation/sample_datasets"
TIMEOUT_S="${TIMEOUT_S:-120}"
SLEEP_S="${SLEEP_S:-2}"

if [ ! -d "${SAMPLE_DIR}" ]; then
  echo "ERROR: Sample datasets not found at ${SAMPLE_DIR}"
  exit 1
fi

start_time=$(date +%s)
while [ ! -d "${TARGET_DIR}" ]; do
  now=$(date +%s)
  elapsed=$((now - start_time))
  if [ "${elapsed}" -ge "${TIMEOUT_S}" ]; then
    echo "ERROR: Node datasets folder not found after ${TIMEOUT_S}s: ${TARGET_DIR}"
    echo "Hint: Start the node first (run.sh) so it creates node-data."
    exit 1
  fi
  sleep "${SLEEP_S}"
done

mkdir -p "${TARGET_DIR}"

copied=0
for file in "${SAMPLE_DIR}"/*; do
  if [ -f "${file}" ]; then
    base=$(basename "${file}")
    dest="${TARGET_DIR}/${base}"
    if [ ! -f "${dest}" ]; then
      cp "${file}" "${dest}"
      copied=$((copied + 1))
    fi
  fi
done

echo "Sample datasets copied to ${TARGET_DIR} (${copied} new files)."
