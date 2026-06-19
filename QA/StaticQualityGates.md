# Static Quality Gates

These checks validate source and metadata without launching the app.

## Full Static QA

Run:

```bash
scripts/run-static-qa.sh
```

This is the standard static gate before release or handoff. It runs localization lint, AI subsystem static QA, content completeness checks, transport/KNM/course checks, media checks, icon validation, history media static QA, and aggregate brand static QA.

## AI Subsystem

Run:

```bash
python3 scripts/ai-subsystem-static-qa.py
```

This gate verifies the AI assistant subsystem without CoreSimulator. It checks that the five AI release artifacts exist, the knowledge index/graph/search/resolver are present, workflows cover BSN, DigiD, health insurance, fine letters, housing, and next-step guidance, context carries route/search/progress/saved signals, quick actions include navigation/source/save/share/related-topic support, and the global launcher exposes all required modes.

## History Media

Run:

```bash
python3 scripts/history-media-static-qa.py
```

This gate validates the curated history image registry. It must remain runnable without iOS Simulator, CoreSimulator, macOS app runtime, UI test runner provisioning, or a physical device.

The gate fails if verified history media is missing exact Wikimedia Commons File-page attribution, license metadata, attribution, dimensions, aspect ratio, retrieval date, or if source and render URLs are mixed.

## Aggregate Static QA

Run:

```bash
python3 scripts/brand-static-qa.py
```

This aggregate gate includes history media static QA and should be run before release or handoff.
