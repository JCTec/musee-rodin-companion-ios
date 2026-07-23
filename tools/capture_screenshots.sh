#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OUTPUT_ROOT="${1:-artifacts/screenshots/$TIMESTAMP}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-build/DerivedData}"
IOS_SIM_OS="${IOS_SIM_OS:-26.5}"

mkdir -p "$OUTPUT_ROOT/_results" "$OUTPUT_ROOT/_exports"

run_device() {
  local device_name="$1"
  local device_slug="$2"
  local result_bundle="$OUTPUT_ROOT/_results/$device_slug.xcresult"
  local export_dir="$OUTPUT_ROOT/_exports/$device_slug"
  local normalized_dir="$OUTPUT_ROOT/$device_slug"

  rm -rf "$result_bundle" "$export_dir" "$normalized_dir"
  mkdir -p "$export_dir" "$normalized_dir"

  echo "Capturing screenshots on $device_name..."
  SCREENSHOT_DEVICE_SLUG="$device_slug" \
    xcodebuild \
      -project MuseeRodinCompanion.xcodeproj \
      -scheme MuseeRodinCompanion \
      -destination "platform=iOS Simulator,name=$device_name,OS=$IOS_SIM_OS" \
      -derivedDataPath "$DERIVED_DATA_PATH" \
      -resultBundlePath "$result_bundle" \
      test \
      -only-testing:MuseeRodinCompanionUITests/ScreenshotCaptureTests \
      -quiet

  xcrun xcresulttool export attachments \
    --path "$result_bundle" \
    --output-path "$export_dir"

  python3 - "$export_dir" "$normalized_dir" "$device_slug" <<'PY'
import json
import re
import shutil
import struct
import sys
from pathlib import Path

export_dir = Path(sys.argv[1])
normalized_dir = Path(sys.argv[2])
device_slug = sys.argv[3]
raw_manifest_path = export_dir / "manifest.json"

def safe_name(value):
    value = value.strip().lower()
    value = re.sub(r"[^a-z0-9_.-]+", "_", value)
    value = re.sub(r"_+", "_", value)
    return value.strip("_") or "screenshot"

def png_dimensions(path):
    data = path.read_bytes()
    if len(data) >= 24 and data[:8] == b"\x89PNG\r\n\x1a\n":
        return struct.unpack(">II", data[16:24])
    return None, None

entries = []
if raw_manifest_path.exists():
    raw_manifest = json.loads(raw_manifest_path.read_text())
else:
    raw_manifest = []

for test_details in raw_manifest:
    for attachment in test_details.get("attachments", []):
        exported_name = attachment.get("suggestedHumanReadableName") or attachment.get("exportedFileName") or ""
        base_name = Path(exported_name).stem
        base_name = re.sub(r"_\d+_[0-9A-Fa-f-]{8}-[0-9A-Fa-f-]{4}-[0-9A-Fa-f-]{4}-[0-9A-Fa-f-]{4}-[0-9A-Fa-f-]{12}$", "", base_name)
        parts = base_name.split("__")
        if len(parts) != 4:
            continue

        source = export_dir / attachment["exportedFileName"]
        if not source.exists() or source.suffix.lower() != ".png":
            continue

        _, view, state, appearance = parts
        canonical_name = f"{device_slug}__{view}__{state}__{appearance}"
        filename = f"{safe_name(canonical_name)}.png"
        target = normalized_dir / filename
        shutil.copy2(source, target)
        width, height = png_dimensions(target)

        entries.append({
            "deviceSlug": device_slug,
            "deviceName": attachment.get("deviceName"),
            "view": view,
            "state": state,
            "appearance": appearance,
            "attachmentName": exported_name,
            "canonicalName": canonical_name,
            "fileName": filename,
            "path": str(target),
            "byteSize": target.stat().st_size,
            "width": width,
            "height": height,
            "testIdentifier": test_details.get("testIdentifier"),
            "timestamp": attachment.get("timestamp"),
        })

entries.sort(key=lambda item: item["fileName"])
(normalized_dir / "manifest.json").write_text(json.dumps(entries, indent=2) + "\n")
print(f"Exported {len(entries)} screenshots to {normalized_dir}")
PY
}

run_device "iPhone 17 Pro" "iphone_17_pro"
run_device "iPad Pro 13-inch (M5)" "ipad_pro_13_m5"

python3 - "$OUTPUT_ROOT" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
combined = []
for manifest_path in sorted(root.glob("*/manifest.json")):
    if manifest_path.parent.name.startswith("_"):
        continue
    combined.extend(json.loads(manifest_path.read_text()))

(root / "manifest.json").write_text(json.dumps(combined, indent=2) + "\n")
(root / "README.md").write_text(
    "# Musée Rodin Companion Screenshots\n\n"
    f"Generated screenshot count: {len(combined)}\n\n"
    "Device folders contain normalized PNG files plus per-device manifests. "
    "The `_results` and `_exports` folders keep the raw XCTest result bundles and attachment exports.\n"
)
print(f"Combined manifest written to {root / 'manifest.json'}")
PY

echo "Screenshots saved in $OUTPUT_ROOT"
