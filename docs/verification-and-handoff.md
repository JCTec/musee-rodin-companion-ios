# Musee Rodin Companion Verification And Handoff

Generated on 2026-07-23.

## Current Content State

The app is now merged and runs against populated Musée Rodin content in:

- `MuseeRodinCompanion/Resources/Content/`

The Python population lane remains available as provenance in:

- `population-output/`

The pre-merge starter content was backed up to:

- `artifacts/content-backups/content-before-population-20260723-112522/`

## Content Validation

Validate both the bundled app fixtures and the population output:

```sh
python3 tools/validate_content.py
```

Expected result:

- `MuseeRodinCompanion/Resources/Content`: OK
- `population-output`: OK

The validator checks required JSON files, unique IDs, localized EN/FR/ES fields, citation coverage, citation-source resolution, route/audio-stop links, audio-stop linked content, enum values, and the no-audio-files rule.

## App Verification

Run the full iPhone suite:

```sh
xcodebuild -project MuseeRodinCompanion.xcodeproj -scheme MuseeRodinCompanion -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -derivedDataPath build/DerivedData test -quiet
```

Run the full iPad suite:

```sh
xcodebuild -project MuseeRodinCompanion.xcodeproj -scheme MuseeRodinCompanion -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=26.5' -derivedDataPath build/DerivedData test -quiet
```

Both suites include:

- Data-model decoding and citation tests.
- SwiftData user-state persistence tests.
- Search and narration state tests.
- Robot UI flows for Places, Works, Work detail, Paths, Search, and Notes.
- 1:1 robots for every named SwiftUI `View` type, including reusable components such as citations, confidence chips, metadata, work rows, placeholders, read-aloud controls, topic/source details, and the note editor.
- An accessibility display smoke test using dark mode, largest accessibility Dynamic Type, high contrast, and Reduce Motion launch settings.

## Population Output Summary

See `population-output/validation_report.md` for the full report.

Current app bundle counts:

- `sources.json`: 47 records.
- `source_chunks.json`: 28 records.
- `works.json`: 18 records.
- `topics.json`: 16 records.
- `routes.json`: 12 records.
- `audio_stops.json`: 29 records.

Known review points before treating the population output as final production content:

- Visitor facts are time-sensitive and should be refreshed from official pages before live trip-planning use.
- Some EN/FR/ES localized fields are conservatively marked `reviewNeeded`.
- Annual-report numeric tables were sampled, not deeply extracted.
- Full provenance, conservation, edition, and exhibition histories remain outside the current structured data.
