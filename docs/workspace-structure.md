# iOS Repository Structure

This folder is the public iOS app repository. Research, population-worker output, generated screenshots, and raw PDFs are intentionally kept outside this repo in the parent workspace unless they are explicitly merged into the app bundle.

The parent workspace also contains `shared-assets/`, the local source of truth for app-bundled content and media that can be regenerated into platform projects.

## App

- `MuseeRodinCompanion/` - SwiftUI app source, resources, and bundled content.
- `Tests/` - unit tests, UI tests, robots, and screenshot capture tests.
- `project.yml` - XcodeGen source of truth.
- `MuseeRodinCompanion.xcodeproj/` - generated Xcode project.

## App Content

- `MuseeRodinCompanion/Resources/Content/` - generated app-bundled JSON content copied from `../shared-assets/content/`.
- `MuseeRodinCompanion/Resources/Assets.xcassets/work-*.imageset/` - generated iOS work artwork copied from `../shared-assets/artwork/work-images/`.
- `docs/schema/` - content-schema notes.
- `tools/validate_content.py` - local content validator.

Rebuild managed resources from the workspace root before local builds if generated files are missing or stale:

```sh
python3 ../tools/sync_app_assets.py --target ios --write
```

Use `--check` to verify the iOS resource copies match `../shared-assets/`.

To refresh both iOS and Android from the same asset package, run from the parent workspace:

```sh
python3 tools/sync_app_assets.py --target all --write
```

## Design And App Artifacts

- `docs/design/` - design PDFs and design-review images.
- `tools/capture_screenshots.sh` - generates screenshots into `artifacts/screenshots/`, which is ignored by git.
- `tools/merge_population_content.sh` - optional local merge helper for external `population-output/`.

Generated iOS resources are currently kept in git so GitHub CI can build without the parent workspace. If those generated files are later removed from git, CI must restore `shared-assets/` before validation and build steps.

## Generated Local Build Output

- `build/` - local Xcode derived data used by test and screenshot commands, ignored by git.
