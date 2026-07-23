# iOS Repository Structure

This folder is the public iOS app repository. Research, population-worker output, downloaded work images, generated screenshots, and raw PDFs are intentionally kept outside this repo in the parent workspace unless they are explicitly merged into the app bundle.

## App

- `MuseeRodinCompanion/` - SwiftUI app source, resources, and bundled content.
- `Tests/` - unit tests, UI tests, robots, and screenshot capture tests.
- `project.yml` - XcodeGen source of truth.
- `MuseeRodinCompanion.xcodeproj/` - generated Xcode project.

## App Content

- `MuseeRodinCompanion/Resources/Content/` - app-bundled JSON content.
- `docs/schema/` - content-schema notes.
- `tools/validate_content.py` - local content validator.

## Design And App Artifacts

- `docs/design/` - design PDFs and design-review images.
- `tools/capture_screenshots.sh` - generates screenshots into `artifacts/screenshots/`, which is ignored by git.
- `tools/merge_population_content.sh` - optional local merge helper for external `population-output/`.

## Generated Local Build Output

- `build/` - local Xcode derived data used by test and screenshot commands, ignored by git.
