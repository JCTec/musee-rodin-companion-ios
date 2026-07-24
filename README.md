# Musee Rodin Companion

[![iOS CI](https://github.com/JCTec/musee-rodin-companion-ios/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/JCTec/musee-rodin-companion-ios/actions/workflows/ios-ci.yml)
[![CodeQL](https://github.com/JCTec/musee-rodin-companion-ios/actions/workflows/codeql.yml/badge.svg)](https://github.com/JCTec/musee-rodin-companion-ios/actions/workflows/codeql.yml)

Personal iOS/iPadOS companion app for exploring Musée Rodin places, works, symbolic paths, search, and notes.

## Project

- `MuseeRodinCompanion/` - SwiftUI app source and bundled JSON content.
- `Tests/` - unit tests, UI tests, robots, and screenshot capture automation.
- `project.yml` - XcodeGen source of truth.
- `MuseeRodinCompanion.xcodeproj/` - generated Xcode project.
- `tools/` - validation, content-merge, and screenshot capture scripts.
- `docs/` - schema, verification, design, and workspace notes.

## Shared Assets

The parent workspace has a canonical local asset package in `../shared-assets/`. It contains the app content JSON, artwork source images, iOS app icon, color sets, and localization file.

Rebuild managed iOS resources from the workspace root package when resources are missing or stale:

```sh
python3 ../tools/sync_app_assets.py --target ios --write
```

Use `--dry-run` to preview changes and `--check` to fail when the iOS resources differ from `../shared-assets/`.

When both platform projects should be refreshed from the same source package, run from the workspace root:

```sh
python3 tools/sync_app_assets.py --target all --write
```

Generated iOS resources are still checked into this repo so remote GitHub CI remains self-contained. If they are untracked later, CI will need access to `../shared-assets/` or a packaging step that restores it before build.

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

## CI/CD

GitHub Actions provide fast required CI, manual release-candidate artifacts, manual UI/screenshot checks, and CodeQL scanning. Screenshot capture is never scheduled or run automatically; trigger it manually when screenshots are intentionally needed.

See [docs/ci-cd.md](docs/ci-cd.md) for workflow details, branch protection recommendations, and future TestFlight prerequisites.
