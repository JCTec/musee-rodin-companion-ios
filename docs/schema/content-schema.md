# Musee Rodin Companion Content Schema

Version: 1.0

The app reads museum content from bundled JSON files. Content is read-only in the app. Personal/user data is stored separately in SwiftData.

## Files

- `sources.json`: `[Source]`
- `source_chunks.json`: `[SourceChunk]`
- `works.json`: `[Work]`
- `topics.json`: `[Topic]`
- `routes.json`: `[Route]`
- `audio_stops.json`: `[AudioStop]`

## Localization

Localized prose uses:

```json
{ "en": "...", "fr": "...", "es": "...", "reviewNeeded": false }
```

If a translation is rough or source-derived but not reviewed, set `reviewNeeded` to `true`.

## Citation Rule

Every `Work`, `Topic`, `Route`, and `AudioStop` must include at least one citation. Unknown fields must be represented in prose as source-needed/review-needed rather than invented.

## Confidence Values

- `verified`: supported by an official source or clearly cited record.
- `reviewNeeded`: plausible from extracted material but needs human review.
- `sourceNeeded`: included as a placeholder requiring a better source.
- `tertiary`: supported by a historical or non-primary source.

## Audio Rule

`audio_stops.json` stores scripts/transcripts only. The app speaks them with `AVSpeechSynthesizer`; no audio files are created, bundled, cached, or downloaded.

## Out Of Scope

No AI chat, embeddings, prompt artifacts, or network AI calls are represented in this schema.
