# Population Merge Plan

Generated on 2026-07-23.

Status: implemented on 2026-07-23.

Backup created by the merge:

- `artifacts/content-backups/content-before-population-20260723-112522/`

## Goal

Merge the validated Python population output into the app bundle so `MuseeRodinCompanion` runs against the richer Musée Rodin data set instead of the starter fixture set.

This is the next phase after the completed separation of:

- App lane: `MuseeRodinCompanion/Resources/Content/`
- Population lane: `population-output/`

## Recommendation

Use an atomic content replacement from `population-output/*.json` into `MuseeRodinCompanion/Resources/Content/*.json`, then tighten tests around the new counts and representative new records.

This recommendation has been applied. The app bundle now contains the population JSON records.

Do not hand-edit individual records during the merge. The population output already validates as a complete content set, preserves all existing app fixture IDs, and adds new records without removing any current IDs.

Do not copy these into the app bundle:

- `population-output/tools/generate_population.py`
- `population-output/validation_report.md`
- PDFs or research source files
- Any generated audio files, embeddings, prompts, or chat artifacts

## Current Evidence

Validation command:

```sh
python3 tools/validate_content.py
```

Current result:

- `MuseeRodinCompanion/Resources/Content`: OK
- `population-output`: OK

Population report:

- `population-output/validation_report.md`

The report says all listed input files were present, all PDFs opened with matching page counts, schema validation passed, cited sources resolve, route/stop links are consistent, and every work/topic/route/audio stop has at least one citation.

## Merge Impact Summary

Comparing `MuseeRodinCompanion/Resources/Content/` to `population-output/`:

| File | Fixture | Population | Same IDs | Changed Existing IDs | Added IDs | Removed IDs |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `sources.json` | 32 | 47 | 32 | 0 | 15 | 0 |
| `source_chunks.json` | 9 | 28 | 9 | 0 | 19 | 0 |
| `works.json` | 18 | 18 | 18 | 0 | 0 | 0 |
| `topics.json` | 10 | 16 | 10 | 0 | 6 | 0 |
| `routes.json` | 9 | 12 | 9 | 0 | 3 | 0 |
| `audio_stops.json` | 21 | 29 | 16 | 5 | 8 | 0 |

The five changed audio stops only gain additional `routeIDs`:

- `stop-bronze-editions`: adds `route-researcher`
- `stop-drawings`: adds `route-researcher`
- `stop-garden`: adds `route-visit-context`
- `stop-hotel-biron`: adds `route-visit-context`
- `stop-meudon`: adds `route-visit-context`

Their titles, subtitles, scripts, citations, linked content, order, tags, and duration estimates are unchanged.

## Added Content

Added sources:

- `P01`, `P02`, `P03`, `P04`, `P05`, `P06`, `P08`, `P11`, `P12`, `P13`
- `S02`, `S04`, `S07`, `S13`, `S14`

Added topics:

- `topic-antiques-collection`
- `topic-education-studio`
- `topic-founding-donation`
- `topic-governance-finance`
- `topic-research-resources`
- `topic-visitor-practical`

Added routes:

- `route-institution-research`
- `route-researcher`
- `route-visit-context`

Added audio stops:

- `stop-antiques-collection`
- `stop-archives-research`
- `stop-education-studio`
- `stop-founding-donation`
- `stop-governance-finance`
- `stop-moral-rights`
- `stop-research-resources`
- `stop-visitor-planning`

## Risk Assessment

Low technical risk:

- No existing IDs are removed.
- All existing works are byte-for-byte unchanged.
- Existing topics, routes, sources, and source chunks are preserved unchanged.
- User-state links to works, favorites, seen state, notes, and route progress should continue to resolve.
- Audio remains script-only and still uses `AVSpeechSynthesizer`.

Medium content risk:

- Visitor facts are date-sensitive.
- Some generated localized fields are marked `reviewNeeded`.
- Annual-report numeric tables were sampled, not deeply extracted.
- Some object-level provenance/conservation/exhibition detail remains intentionally non-exhaustive.

Acceptable for personal use if the app clearly treats practical visitor facts as source-backed but review-sensitive, not live trip-planning truth.

## Pre-Merge Gates

Run before copying anything:

```sh
python3 tools/validate_content.py MuseeRodinCompanion/Resources/Content population-output
```

Review:

- `population-output/validation_report.md`
- Counts and added IDs in this plan
- The `reviewNeeded` localization counts
- The volatile visitor-facts warning

Because this folder is not currently a Git repository, create a filesystem backup before replacing app bundle content.

Recommended backup path:

```text
artifacts/content-backups/content-before-population-YYYYMMDD-HHMMSS/
```

## Merge Steps

1. Back up the current bundle content directory.

   ```sh
   mkdir -p artifacts/content-backups/content-before-population-YYYYMMDD-HHMMSS
   cp MuseeRodinCompanion/Resources/Content/*.json artifacts/content-backups/content-before-population-YYYYMMDD-HHMMSS/
   ```

2. Copy only the six schema JSON files from `population-output/` into `MuseeRodinCompanion/Resources/Content/`.

   ```sh
   cp population-output/sources.json MuseeRodinCompanion/Resources/Content/sources.json
   cp population-output/source_chunks.json MuseeRodinCompanion/Resources/Content/source_chunks.json
   cp population-output/works.json MuseeRodinCompanion/Resources/Content/works.json
   cp population-output/topics.json MuseeRodinCompanion/Resources/Content/topics.json
   cp population-output/routes.json MuseeRodinCompanion/Resources/Content/routes.json
   cp population-output/audio_stops.json MuseeRodinCompanion/Resources/Content/audio_stops.json
   ```

3. Run validation against the merged app bundle.

   ```sh
   python3 tools/validate_content.py MuseeRodinCompanion/Resources/Content
   ```

4. Update unit tests to assert the merged counts:

   - Sources: 47
   - Source chunks: 28
   - Works: 18
   - Topics: 16
   - Routes: 12
   - Audio stops: 29

5. Add/adjust tests for representative new IDs:

   - Search finds `Studio Rodin`, `visitor`, `research resources`, and `moral rights`.
   - `route-visit-context` exists and includes the expected mixed reused/new stops.
   - `route-researcher` exists and reuses the expanded `routeIDs` on `stop-bronze-editions` and `stop-drawings`.
   - Source citation chips remain compact outbound source buttons without reintroducing a source-detail screen.

6. Run the full iPhone and iPad suites:

   ```sh
   xcodebuild -project MuseeRodinCompanion.xcodeproj -scheme MuseeRodinCompanion -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -derivedDataPath build/DerivedData test -quiet
   xcodebuild -project MuseeRodinCompanion.xcodeproj -scheme MuseeRodinCompanion -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=26.5' -derivedDataPath build/DerivedData test -quiet
   ```

7. Do a focused UI inspection through robot-driven flows:

   - Places shows the physical place entries only.
   - Paths list includes 12 symbolic paths.
   - New routes open and speak with system voice.
   - Search returns works, topics, routes, and notes.
   - Source URLs remain demoted to compact provenance chips.

8. Update handoff docs:

   - `docs/verification-and-handoff.md`
   - `docs/schema/content-schema.md` only if schema semantics change, which is not expected for this merge.

## Rollback Plan

If validation or app tests fail after copying:

1. Restore the backup JSON files into `MuseeRodinCompanion/Resources/Content/`.
2. Run:

   ```sh
   python3 tools/validate_content.py MuseeRodinCompanion/Resources/Content
   ```

3. Run at least the unit test suite before continuing.

No SwiftData migration rollback is expected because the merge does not remove existing linked IDs.

## Post-Merge Boundary

After a successful merge:

- Keep `population-output/` as provenance unless explicitly archived later.
- Keep PDFs and research material outside the app bundle.
- Continue to use placeholders for imagery.
- Continue to use `AVSpeechSynthesizer`; do not add bundled or cached audio files.
- Continue to avoid AI chat, prompts, embeddings, or model-facing artifacts.

## Completed Merge

The merge has been completed as a content-only replacement plus test updates.

The deterministic merge command is:

```sh
tools/merge_population_content.sh
```

Do not run it again unless you intentionally want to create a new backup and re-copy the current `population-output/` JSON files into the app bundle.
