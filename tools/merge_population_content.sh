#!/usr/bin/env bash
set -euo pipefail

APP_CONTENT_DIR="MuseeRodinCompanion/Resources/Content"
POPULATION_DIR="population-output"
BACKUP_ROOT="artifacts/content-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/content-before-population-${TIMESTAMP}"

FILES=(
  sources.json
  source_chunks.json
  works.json
  topics.json
  routes.json
  audio_stops.json
)

for dir in "${APP_CONTENT_DIR}" "${POPULATION_DIR}"; do
  if [[ ! -d "${dir}" ]]; then
    echo "Missing directory: ${dir}" >&2
    exit 1
  fi
done

for file in "${FILES[@]}"; do
  if [[ ! -f "${APP_CONTENT_DIR}/${file}" ]]; then
    echo "Missing app content file: ${APP_CONTENT_DIR}/${file}" >&2
    exit 1
  fi
  if [[ ! -f "${POPULATION_DIR}/${file}" ]]; then
    echo "Missing population file: ${POPULATION_DIR}/${file}" >&2
    exit 1
  fi
done

python3 tools/validate_content.py "${APP_CONTENT_DIR}" "${POPULATION_DIR}"

mkdir -p "${BACKUP_DIR}"
for file in "${FILES[@]}"; do
  cp "${APP_CONTENT_DIR}/${file}" "${BACKUP_DIR}/${file}"
done

for file in "${FILES[@]}"; do
  cp "${POPULATION_DIR}/${file}" "${APP_CONTENT_DIR}/${file}"
done

python3 tools/validate_content.py "${APP_CONTENT_DIR}"

echo "Merged population content into ${APP_CONTENT_DIR}"
echo "Backup written to ${BACKUP_DIR}"
