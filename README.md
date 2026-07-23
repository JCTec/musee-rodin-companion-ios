# Musee Rodin Companion

Personal iOS/iPadOS companion app for exploring Musée Rodin places, works, symbolic paths, search, and notes.

## Project

- `MuseeRodinCompanion/` - SwiftUI app source and bundled JSON content.
- `Tests/` - unit tests, UI tests, robots, and screenshot capture automation.
- `project.yml` - XcodeGen source of truth.
- `MuseeRodinCompanion.xcodeproj/` - generated Xcode project.
- `tools/` - validation, content-merge, and screenshot capture scripts.
- `docs/` - schema, verification, design, and workspace notes.

## Common Commands

Validate bundled content:

```sh
python3 tools/validate_content.py MuseeRodinCompanion/Resources/Content
```

Run tests:

```sh
xcodebuild -project MuseeRodinCompanion.xcodeproj -scheme MuseeRodinCompanion -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -derivedDataPath build/DerivedData test -quiet
```

Capture screenshots:

```sh
tools/capture_screenshots.sh
```

