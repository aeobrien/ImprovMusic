# ImprovMusic — Project Conventions

## Overview

ImprovMusic is an iOS app (iPhone only) for piano improvisation practice, focused on modulation skills. It presents modulation challenges at configurable difficulty, shows target keys on a visual keyboard, and offers multi-step hint routes using diverse modulation techniques. The app is a prompt generator — it trusts the player to execute and self-evaluate. Local-only, single-user, no backend.

## Architecture

**Framework:** SwiftUI
**Platform:** iOS, landscape orientation, iPhone only
**Minimum iOS:** TBD (latest or latest-1)
**Language:** Swift
**Persistence:** UserDefaults (settings only)
**Music Theory Primitives:** AudioKit's Tonic library (convenience dependency — replaceable if insufficient)
**Backend:** None — entirely self-contained

## Current Project State

**Current Phase:** Phase 1 (next to start)
**Phases complete:** None

## Application Layers

```
UI Layer
    Single-screen landscape interface: keyboard, key displays, controls, hints
    |
Engine Layer
    Challenge generation, tier assignment, arrival/advancement,
    timer/manual triggering, pathfinding, hint diversity
    |
Music Theory Layer
    TonalContext, scale types, pitch class sets, diatonic chords,
    modulation graph (72 nodes), edge generators, distance vectors
```

## Build & Test Commands

```bash
# Open project in Xcode
open ImprovMusic.xcodeproj

# Build (Xcode CLI)
xcodebuild -scheme ImprovMusic -sdk iphonesimulator -configuration Debug build

# Run tests (Xcode CLI)
xcodebuild -scheme ImprovMusic -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' test

# Run tests (Swift CLI, for SPM-based test targets)
swift test

# Add Tonic via Swift Package Manager (if not yet added)
# In Xcode: File → Add Package Dependencies → https://github.com/AudioKit/Tonic
```

## Code Style

### Naming
- **Files:** `PascalCase.swift` (matching primary type name)
- **Types/Protocols:** `PascalCase`
- **Variables/Functions:** `camelCase`
- **Enum cases:** `camelCase`
- **Test files:** `*Tests.swift` in test target, mirroring source structure
- **Test methods:** `test_descriptiveName_expectedOutcome()`

### Project Structure

```
ImprovMusic/
├── Models/
│   ├── PitchClass.swift          # Pitch class (0-11) with spelling preference
│   ├── ScaleType.swift           # Enum: major, naturalMinor, dorian, phrygian, lydian, mixolydian
│   ├── TonalContext.swift        # Tonic + scale type → pitch class set + diatonic chords
│   ├── ModulationEdge.swift      # Directed edge: technique, cost, evidence
│   └── ModulationGraph.swift     # 72-node precomputed graph
├── Engine/
│   ├── ChallengeEngine.swift     # Challenge generation, tier filtering, advancement
│   ├── DifficultyTier.swift      # Rule-based tier assignment
│   ├── Pathfinder.swift          # Dijkstra + Yen's k-shortest paths
│   └── HintGenerator.swift       # Technique-diverse route selection
├── EdgeGenerators/
│   ├── PivotChordGenerator.swift
│   ├── CommonToneGenerator.swift
│   ├── MixtureAssistedGenerator.swift
│   ├── DirectModulationGenerator.swift
│   └── EnharmonicGenerator.swift
├── Views/
│   ├── MainView.swift            # Single-screen layout
│   ├── KeyboardView.swift        # Single-octave piano keyboard
│   ├── KeyDisplayView.swift      # Current + target key names
│   ├── HintView.swift            # Progressive disclosure hint overlay
│   └── ControlsView.swift        # Tier selector, trigger mode, timer, key picker
└── Utilities/
    ├── CircleOfFifths.swift      # Fifths distance calculations
    └── SpellingPreference.swift  # Enharmonic display rules
```

### Commits
- Format: `Phase N: [summary of what this phase delivers]`
- Branches: `phase-N/name`

### Testing
- Framework: XCTest
- **Every new public method gets a test**
- Music theory tests: validate against known scale/chord/modulation facts
- Edge cases to always cover: enharmonic equivalents, modal contexts, boundary tiers, sparse pools
- Engine tests: verify tier assignment, challenge distribution, pathfinding correctness
- UI tests: verify keyboard rendering, hint disclosure, control interactions

### Data Model Rules
- **Pitch classes** are integers 0-11. All pitch-class arithmetic is mod 12.
- **Spelling preference** is metadata on the tonic, not a separate node. F# major and Gb major are the same node.
- **Suppress absurd spellings**: D# major, A# minor, Fb major, etc. Use conventional key-signature spellings only.
- **Functional labels** on diatonic chords use major/minor tonal function where applicable. For modes, fall back to chord-overlap scoring rather than forcing tonal function hierarchies.
- **Edge evidence** for pivot chords includes Roman numeral function in both keys.

### Views/UI
- **Landscape only** — app is read from a piano music stand
- **No portrait support** — lock orientation
- **Readability at ~60-80cm** — all text and keyboard elements sized accordingly
- **Tonic visually distinct** from other scale tones on the keyboard
- **Three-way colour distinction** on keyboard when challenge active: notes in both scales, notes only in current, notes only in target
- **Neutral styling throughout** — no gamification, no scores, no streaks

## Key Files

| File | Purpose |
|------|---------|
| `ROADMAP.md` | Master development plan |
| `WORKFLOW.md` | Development cycle and debugging protocol |
| `CLAUDE.md` | This file — project conventions |
| `Improv music — Vision Statement.md` | Product vision |
| `Improv music — Technical Brief.md` | Technical specification |
| `Improv music — Research Report 1 (ChatGPT).md` | Music theory research (reference only) |
| `Improv music — Research Report 2 (Claude).md` | Music theory research (reference only) |
| `docs/manual-tests/` | Manual test briefs and results |
| `docs/session-log.md` | What was built per session |

## Mistakes to Avoid

1. **Don't treat Tonic as structural** — it's a convenience dependency. If it can't do something (chord quality comparison, enharmonic spelling, modal support), build a custom replacement rather than working around its limitations.
2. **Don't create separate graph nodes for enharmonic equivalents** — F# major and Gb major are the same pitch classes, same node, different display name via spelling preference.
3. **Don't include Locrian as a scale type** — its diminished tonic triad means it can't function as a stable tonal centre. It's excluded from the initial implementation.
4. **Don't include harmonic minor or melodic minor yet** — deferred from initial release. They add complexity to chord generation and distance computation without being core to the modulation practice loop.
5. **Don't force major/minor functional labels onto modes** — not all modes have clear predominant/dominant/tonic hierarchies. Modal edge generation should fall back to chord-overlap count.
6. **Don't assign difficulty tiers by cost range** — tier assignment is rule-based, checking edge properties (technique type, distance components, pivot availability) against categorical criteria.
7. **Don't return k-lowest-cost paths as hints** — prioritise technique diversity (one route via pivots, another via common tones) over minor cost variations of the same approach.
8. **Don't build for portrait orientation** — the app is designed for landscape on a piano music stand.
9. **Don't add scoring, assessment, or gamification** — the app is a prompt generator that trusts the player to self-evaluate.
10. **Don't skip Tonic evaluation in Phase 1** — validate it against the project's actual needs before building on it. Don't defer this as a discovery risk.
