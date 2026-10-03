# Tonic Library Evaluation

**Library:** AudioKit/Tonic (https://github.com/AudioKit/Tonic)
**Evaluated:** 2026-03-26
**Decision:** Not used. Custom theory layer built instead.

## Capabilities

| Requirement | Supported? | Notes |
|-------------|-----------|-------|
| Pitch class representation (0-11) | Yes | Via `NoteClass` enum |
| Scale types (major, minor, modes) | Yes | `Scale` enum with Dorian, Phrygian, Lydian, Mixolydian |
| Chord construction per scale degree | Partial | `Key.primaryTriads` exists but missing augmented triads for modes |
| Chord quality comparison | Yes | Via `Chord` type with quality property |
| Enharmonic spelling (Db vs C#) | No | Works at pitch-class level only; no spelling preference |
| Set operations (intersection, symmetric diff) | Yes | Via `NoteSet` bitset type |
| Circle-of-fifths distance | No | Not provided |

## Gaps

1. **No enharmonic spelling support** — critical for displaying key names correctly (Db Major vs C# Major). The app needs to choose the conventional spelling based on key context.
2. **No circle-of-fifths distance** — needed for the distance vector and region distance calculations.
3. **Incomplete modal chord generation** — `primaryTriads` misses augmented triads in certain modes.
4. **No functional labels** — no concept of tonic/predominant/dominant function on chords.

## Decision Rationale

The three missing features (spelling, fifths distance, functional labels) are all core to the modulation engine. Wrapping Tonic and filling gaps would create a fragmented API where some primitives come from Tonic and others are custom. Since the primitives themselves are straightforward (pitch classes, interval recipes, chord construction), a clean custom implementation is simpler and gives full control.

The custom layer implements:
- `PitchClass` with spelling preference
- `ScaleType` with interval recipes and colour-note distances
- `TonalContext` with all distance calculations
- `DiatonicChordGenerator` with functional labels for major/minor
