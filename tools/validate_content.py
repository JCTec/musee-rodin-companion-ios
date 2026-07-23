#!/usr/bin/env python3
"""Validate Musee Rodin Companion JSON content directories."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


CONTENT_FILES = {
    "sources": "sources.json",
    "source_chunks": "source_chunks.json",
    "works": "works.json",
    "topics": "topics.json",
    "routes": "routes.json",
    "audio_stops": "audio_stops.json",
}

SOURCE_KINDS = {"web", "pdf"}
CONFIDENCE_VALUES = {"verified", "reviewNeeded", "sourceNeeded", "tertiary"}
LINK_KINDS = {"work", "topic", "route", "source", "audioStop"}
AUDIO_EXTENSIONS = {".aac", ".aif", ".aiff", ".flac", ".m4a", ".mp3", ".wav"}


@dataclass
class ValidationResult:
    label: str
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    counts: dict[str, int] = field(default_factory=dict)

    @property
    def ok(self) -> bool:
        return not self.errors

    def error(self, message: str) -> None:
        self.errors.append(message)

    def warn(self, message: str) -> None:
        self.warnings.append(message)


def load_json_array(path: Path, result: ValidationResult) -> list[dict[str, Any]]:
    if not path.exists():
        result.error(f"Missing required file: {path}")
        return []

    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        result.error(f"{path}: invalid JSON: {exc}")
        return []

    if not isinstance(value, list):
        result.error(f"{path}: top-level value must be an array")
        return []

    records: list[dict[str, Any]] = []
    for index, item in enumerate(value):
        if isinstance(item, dict):
            records.append(item)
        else:
            result.error(f"{path}: item {index} must be an object")
    return records


def validate_localized(value: Any, path: str, result: ValidationResult) -> None:
    if not isinstance(value, dict):
        result.error(f"{path}: localized value must be an object")
        return

    for language in ("en", "fr", "es"):
        text = value.get(language)
        if not isinstance(text, str) or not text.strip():
            result.error(f"{path}.{language}: localized text is required")

    review_needed = value.get("reviewNeeded")
    if review_needed is not None and not isinstance(review_needed, bool):
        result.error(f"{path}.reviewNeeded: must be a boolean when present")


def validate_citation(value: Any, path: str, source_ids: set[str], result: ValidationResult) -> None:
    if not isinstance(value, dict):
        result.error(f"{path}: citation must be an object")
        return

    citation_id = value.get("id")
    source_id = value.get("sourceID")
    label = value.get("label")

    if not isinstance(citation_id, str) or not citation_id.strip():
        result.error(f"{path}.id: citation id is required")
    if not isinstance(source_id, str) or not source_id.strip():
        result.error(f"{path}.sourceID: source id is required")
    elif source_id not in source_ids:
        result.error(f"{path}.sourceID: missing referenced source {source_id}")
    if not isinstance(label, str) or not label.strip():
        result.error(f"{path}.label: citation label is required")

    page = value.get("page")
    if page is not None and not isinstance(page, int):
        result.error(f"{path}.page: must be an integer when present")

    note = value.get("note")
    if note is not None:
        validate_localized(note, f"{path}.note", result)


def ids_for(records: list[dict[str, Any]], kind: str, result: ValidationResult) -> set[str]:
    seen: set[str] = set()
    for index, record in enumerate(records):
        record_id = record.get("id")
        if not isinstance(record_id, str) or not record_id.strip():
            result.error(f"{kind}[{index}].id: id is required")
            continue
        if record_id in seen:
            result.error(f"{kind}: duplicate id {record_id}")
        seen.add(record_id)
    return seen


def require_string_list(record: dict[str, Any], key: str, path: str, result: ValidationResult) -> list[str]:
    value = record.get(key)
    if not isinstance(value, list):
        result.error(f"{path}.{key}: must be an array")
        return []

    strings: list[str] = []
    for index, item in enumerate(value):
        if isinstance(item, str) and item.strip():
            strings.append(item)
        else:
            result.error(f"{path}.{key}[{index}]: must be a non-empty string")
    return strings


def require_citations(record: dict[str, Any], path: str, source_ids: set[str], result: ValidationResult) -> None:
    citations = record.get("citations")
    if not isinstance(citations, list) or not citations:
        result.error(f"{path}.citations: at least one citation is required")
        return

    for index, citation in enumerate(citations):
        validate_citation(citation, f"{path}.citations[{index}]", source_ids, result)


def validate_content_dir(content_dir: Path, label: str) -> ValidationResult:
    result = ValidationResult(label=label)
    loaded = {
        key: load_json_array(content_dir / filename, result)
        for key, filename in CONTENT_FILES.items()
    }
    result.counts = {key: len(records) for key, records in loaded.items()}

    source_ids = ids_for(loaded["sources"], "sources", result)
    chunk_ids = ids_for(loaded["source_chunks"], "source_chunks", result)
    work_ids = ids_for(loaded["works"], "works", result)
    topic_ids = ids_for(loaded["topics"], "topics", result)
    route_ids = ids_for(loaded["routes"], "routes", result)
    stop_ids = ids_for(loaded["audio_stops"], "audio_stops", result)
    _ = chunk_ids

    for index, source in enumerate(loaded["sources"]):
        path = f"sources[{index}]"
        if source.get("kind") not in SOURCE_KINDS:
            result.error(f"{path}.kind: must be one of {sorted(SOURCE_KINDS)}")
        for key in ("title", "notes"):
            validate_localized(source.get(key), f"{path}.{key}", result)
        for key in ("publisher", "accessDate"):
            if not isinstance(source.get(key), str) or not source[key].strip():
                result.error(f"{path}.{key}: non-empty string is required")
        if not isinstance(source.get("url"), str) or not source["url"].strip():
            result.error(f"{path}.url: non-empty string is required")

    for index, chunk in enumerate(loaded["source_chunks"]):
        path = f"source_chunks[{index}]"
        source_id = chunk.get("sourceID")
        if source_id not in source_ids:
            result.error(f"{path}.sourceID: missing referenced source {source_id}")
        validate_localized(chunk.get("text"), f"{path}.text", result)
        if chunk.get("sectionHint") is not None:
            validate_localized(chunk.get("sectionHint"), f"{path}.sectionHint", result)
        validate_citation(chunk.get("citation"), f"{path}.citation", source_ids, result)

    for kind, records in (("works", loaded["works"]), ("topics", loaded["topics"])):
        for index, record in enumerate(records):
            path = f"{kind}[{index}]"
            for key in ("title", "summary", "researchNote"):
                validate_localized(record.get(key), f"{path}.{key}", result)
            if kind == "works":
                for key in ("material", "locationStatus"):
                    validate_localized(record.get(key), f"{path}.{key}", result)
            else:
                validate_localized(record.get("subtitle"), f"{path}.subtitle", result)
            if record.get("confidence") not in CONFIDENCE_VALUES:
                result.error(f"{path}.confidence: must be one of {sorted(CONFIDENCE_VALUES)}")
            require_string_list(record, "tags", path, result)
            require_citations(record, path, source_ids, result)

    for index, route in enumerate(loaded["routes"]):
        path = f"routes[{index}]"
        for key in ("title", "subtitle", "summary"):
            validate_localized(route.get(key), f"{path}.{key}", result)
        minutes = route.get("estimatedMinutes")
        if not isinstance(minutes, int) or minutes <= 0:
            result.error(f"{path}.estimatedMinutes: must be a positive integer")
        for stop_id in require_string_list(route, "stopIDs", path, result):
            if stop_id not in stop_ids:
                result.error(f"{path}.stopIDs: missing referenced audio stop {stop_id}")
        require_string_list(route, "tags", path, result)
        require_citations(route, path, source_ids, result)

    for index, stop in enumerate(loaded["audio_stops"]):
        path = f"audio_stops[{index}]"
        for key in ("title", "subtitle", "script"):
            validate_localized(stop.get(key), f"{path}.{key}", result)
        linked_kind = stop.get("linkedKind")
        linked_id = stop.get("linkedID")
        if linked_kind not in LINK_KINDS:
            result.error(f"{path}.linkedKind: must be one of {sorted(LINK_KINDS)}")
        elif isinstance(linked_id, str):
            linked_sets = {
                "work": work_ids,
                "topic": topic_ids,
                "route": route_ids,
                "source": source_ids,
                "audioStop": stop_ids,
            }
            if linked_id not in linked_sets[linked_kind]:
                result.error(f"{path}.linkedID: missing linked {linked_kind} {linked_id}")
        else:
            result.error(f"{path}.linkedID: non-empty string is required")

        for route_id in require_string_list(stop, "routeIDs", path, result):
            if route_id not in route_ids:
                result.error(f"{path}.routeIDs: missing referenced route {route_id}")
        order = stop.get("order")
        if not isinstance(order, int) or order <= 0:
            result.error(f"{path}.order: must be a positive integer")
        duration = stop.get("durationSecondsEstimate")
        if not isinstance(duration, int) or duration <= 0:
            result.error(f"{path}.durationSecondsEstimate: must be a positive integer")
        require_string_list(stop, "tags", path, result)
        require_citations(stop, path, source_ids, result)

    audio_files = [
        path.relative_to(content_dir)
        for path in content_dir.rglob("*")
        if path.is_file() and path.suffix.lower() in AUDIO_EXTENSIONS
    ]
    if audio_files:
        result.error(f"Audio files are not allowed in content directories: {audio_files}")

    return result


def print_result(result: ValidationResult) -> None:
    status = "OK" if result.ok else "FAILED"
    print(f"{result.label}: {status}")
    for key in CONTENT_FILES:
        print(f"  {key}: {result.counts.get(key, 0)}")
    for warning in result.warnings:
        print(f"  warning: {warning}")
    for error in result.errors:
        print(f"  error: {error}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "content_dirs",
        nargs="*",
        default=["MuseeRodinCompanion/Resources/Content", "population-output"],
        help="Content directories to validate.",
    )
    args = parser.parse_args()

    results = [
        validate_content_dir(Path(content_dir), content_dir)
        for content_dir in args.content_dirs
    ]
    for result in results:
        print_result(result)

    return 0 if all(result.ok for result in results) else 1


if __name__ == "__main__":
    sys.exit(main())
