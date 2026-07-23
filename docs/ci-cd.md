# CI/CD

This repo uses GitHub Actions for validation, manual release-candidate artifacts, manual UI checks, and CodeQL scanning. Workflows run from the `ios/` repo root; paths do not need an extra `ios/` prefix.

## Required CI

`iOS CI` runs on pull requests, pushes to `main`, and manual dispatch.

Recommended required branch-protection checks:

- `content`: validates bundled JSON with `python3 tools/validate_content.py MuseeRodinCompanion/Resources/Content`.
- `project`: regenerates `MuseeRodinCompanion.xcodeproj` from `project.yml` with XcodeGen and fails if the generated project drifts.
- `build-and-unit-tests`: runs only `MuseeRodinCompanionTests` with code signing disabled.

Screenshot tests are not part of required CI.

## Manual Release-Candidate Artifacts

`iOS Release Candidate` is manual-only through `workflow_dispatch`.

Inputs:

- `configuration`: `Release` by default, with `Debug` available for diagnostics.
- `include_screenshots`: `false` by default. Set to `true` only when you intentionally want screenshot artifacts.

Outputs:

- Unsigned simulator `.app` zip.
- Xcode build logs and result bundles.
- Optional screenshot artifacts when requested manually.

This workflow does not create GitHub Releases, tags, signed IPAs, ad hoc builds, or TestFlight uploads.

## Manual UI And Screenshot Checks

`iOS UI Checks` is manual-only.

- The default run executes the non-screenshot UI test class.
- Set `run_screenshots` to `true` to run `tools/capture_screenshots.sh`.
- Screenshot artifacts are retained briefly because they are review aids, not release assets.

No scheduled workflow runs screenshot capture.

## Security And Maintenance

- `CodeQL` runs for Swift on pull requests, pushes to `main`, a weekly schedule, and manual dispatch.
- Dependabot checks GitHub Actions weekly.
- Issue templates separate app bugs, feature requests, and content/asset changes.

## Future TestFlight Prerequisites

Before adding TestFlight deployment, decide on signing ownership and add secrets for:

- App Store Connect API key ID, issuer ID, and private key.
- Certificate and provisioning profile management, or a managed signing service.
- Bundle/version bumping policy.
- Release notes and tester group policy.

Keep TestFlight separate from required PR CI so validation remains fast and secret-free.
