# ImprovMusic — Ledger

> iOS app for piano improvisation practice, focused on key recognition and modulation skills. Presents modulation challenges at configurable difficulty, shows target keys on a visual keyboard, and offers multi-step hint routes using diverse modulation techniques. Single-screen SwiftUI app, landscape iPhone, no backend.

## Status

**Lane:** personal
**Phase:** Phase 1 — Data Model and Music Theory Layer (not yet started)
**Last updated:** 2026-04-07

## Architecture

```
UI Layer
    Single-screen landscape interface: keyboard, key displays, controls, hints
    |
Engine Layer
    Challenge generation, tier filtering, timer/manual triggering,
    pathfinding (Dijkstra + Yen's k-shortest), hint diversity
    |
Music Theory Layer
    TonalContext, scale types (major, minor, 7 diatonic modes),
    pitch class sets, diatonic chords, modulation graph (72 nodes),
    edge generators, composite distance vectors
```

## Subsystems

| Subsystem | Status | Doc |
|-----------|--------|-----|
| Music Theory Layer | Not started | — |
| Modulation Graph | Not started | — |
| Engine | Not started | — |
| UI | Not started | — |

## Key Decisions

See [decisions/LOG.md](decisions/LOG.md) for the full decision log.

## Open Questions

1. **Difficulty weight calibration** — Exact weights in the composite distance formula need empirical tuning during Phase 5.
2. **Tonic library adequacy** — AudioKit's Tonic needs evaluation in Phase 1. May need custom replacements for chord quality comparison, enharmonic handling.
3. **Enharmonic spelling** — Context-aware note name display (Db vs C#). Tonic may or may not handle this.
4. **Graph precomputation performance** — 72 nodes should be fast, but needs validation. Serialise if startup time is noticeable.
5. **Keyboard visualisation design** — Exact visual treatment refined in Phase 4. Key constraint: readability at music-stand distance (~60-80cm).

## Linked Projects

None.

## Notes

- Built primarily for personal use. App Store publication not a driving goal.
- Music theory must be rigorous — the app should never give bad musical advice.
- Hint system shows multiple valid modulation routes, not a single "correct" answer.
- No scoring, assessment, or gamification — the app trusts the player to self-evaluate.
- Locrian excluded (diminished tonic triad). Harmonic/melodic minor deferred from initial release.
- Node set: 12 tonics x 6 scale types = 72 nodes (major, natural minor, Dorian, Phrygian, Lydian, Mixolydian).

## Key Files

| File | Purpose |
|------|---------|
| `VisionStatement-PM.md` | Product vision |
| `TechnicalBrief-PM.md` | Technical specification |
| `CLAUDE.md` | Project conventions |
| `ledger/ROADMAP.md` | Development roadmap |
