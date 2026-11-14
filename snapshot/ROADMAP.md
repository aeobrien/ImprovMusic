# ImprovMusic — Roadmap

## Overview

This roadmap covers the full development of ImprovMusic, a piano improvisation practice companion built in SwiftUI.

**5 phases, each self-contained and testable before proceeding.**

---

## Architecture

```
UI Layer (Phase 4)
    Single-screen landscape: keyboard, key displays, controls, hint overlay
    |
Engine Layer (Phase 3)
    Challenge generation, tier assignment, arrival/advancement,
    pathfinding, hint diversity, timer/manual triggering
    |
Music Theory Layer (Phases 1-2)
    TonalContext (tonic + scale type + pitch class set + chords)
    Modulation Graph (72 nodes, directed weighted edges)
    Edge Generators (pivot, common-tone, mixture, direct, enharmonic)
    Distance Vector (Δscale, Δregion, Δtonic, Δmode, pivotAvailability, cadenceSupport)
```

---

## Phase 1: Project Setup + Music Theory Primitives — "The foundation"

**Branch:** `phase-1/music-theory-primitives`
**Depends on:** Nothing

### Sub-modules

- 1.1 **Xcode project scaffold** — Create SwiftUI project targeting iOS (iPhone only), landscape-only. Add placeholder `MainView` that displays "ImprovMusic" in landscape.
- 1.2 **Evaluate Tonic library** — Add AudioKit's Tonic via SPM. Test whether it supports: pitch class representation, all required scale types (major, natural minor, Dorian, Phrygian, Lydian, Mixolydian), chord construction per scale degree, chord quality comparison, and enharmonic spelling. Document gaps. If critical gaps exist, plan custom replacements.
- 1.3 **PitchClass** — Implement pitch class type (0-11) with spelling preference. Spelling rules: use conventional key-signature spellings, suppress absurd spellings (D# major, A# minor, etc.). Include circle-of-fifths distance calculation (0-6, wrapping at tritone).
- 1.4 **ScaleType** — Enum with interval recipes for: major, naturalMinor, dorian, phrygian, lydian, mixolydian. Ionian and Aeolian are aliases for major and naturalMinor. Locrian excluded. Each case provides its semitone step sequence and its "colour-note edit distance" from major (for major-ish modes) or natural minor (for minor-ish modes).
- 1.5 **TonalContext** — Core type combining tonic (PitchClass) + scaleType → computed pitchClassSet (12-bit bitset or Set<Int>). Include symmetric difference computation between any two TonalContexts.
- 1.6 **Diatonic chord generation** — For each TonalContext, generate the triads and seventh chords on each scale degree. Attach functional labels (tonic, predominant, dominant) for major and natural minor. For modes, store chords without forcing tonal function labels — annotate with scale degree only.
- 1.7 **Tests** — Validate: C major = {0,2,4,5,7,9,11}. D Dorian = {0,2,3,5,7,9,10}. C major diatonic triads = Cmaj, Dmin, Emin, Fmaj, Gmaj, Amin, Bdim. Circle-of-fifths distance C↔G = 1, C↔F# = 6. Spelling preference for pitch class 1 in Db major = "Db", in C# minor = "C#". Symmetric difference between C major and G major = {5,6} (F→F#), size 2.

### Deliverables

- [ ] Xcode project builds and launches in landscape on iPhone simulator
- [ ] Tonic evaluation documented (capabilities and gaps)
- [ ] PitchClass with spelling preference and fifths distance
- [ ] ScaleType enum with all 6 types + interval recipes + colour-note distances
- [ ] TonalContext with pitch class set computation and symmetric difference
- [ ] Diatonic chord generation with appropriate functional labels
- [ ] 30+ unit tests covering scales, chords, distances, spelling

### Manual Test Brief

- Launch app on iPhone simulator — verify it opens in landscape with placeholder UI, verify legibility

---

## Phase 2: Modulation Graph — "The relationships between keys"

**Branch:** `phase-2/modulation-graph`
**Depends on:** Phase 1

### Sub-modules

- 2.1 **Graph data structure** — Directed weighted multigraph: 72 nodes (12 tonics × 6 scale types), directed edges with cost, technique type, and evidence. Multiple edges allowed between the same node pair (different techniques).
- 2.2 **Distance vector** — Implement composite distance: Δscale (symmetric difference size), Δregion (circle-of-fifths distance between diatonic collections, 0-6), Δtonic (fifths distance between tonics, 0-6), Δmode (colour-note edit count). Combine via weighted sum with tunable weights.
- 2.3 **Pivot chord edge generator** — For each ordered pair (A, B): find chords diatonic in both (same root pitch class + same quality). Score by count and functional quality (predominant→predominant best). For modal contexts, fall back to overlap count rather than functional scoring.
- 2.4 **Common-tone edge generator** — Find shared pitch classes that connect a chord in A to a chord in B. Score by number of shared tones and chord quality.
- 2.5 **Mixture-assisted edge generator** — Extend A's chord set with parallel major/minor borrowings. Find pivots between extended set and B's diatonic chords. Higher base cost than diatonic pivot.
- 2.6 **Direct modulation edge generator** — Always available. Cost is raw distance with no pivot reduction.
- 2.7 **Enharmonic reinterpretation edge generator** — Check for chords in A that can be respelled to function in B (e.g., V7 ↔ Ger+6). High base cost.
- 2.8 **Graph precomputation** — Generate all edges for all 72×71 ordered pairs. Cache the full graph. Measure precomputation time.
- 2.9 **Tests** — Validate known relationships: C major → G major has low-cost pivot edges with multiple pivots. C major → F# major has high cost, limited to direct/enharmonic. C major → A minor (relative) has zero Δscale but nonzero Δtonic. C major → C Mixolydian has Δmode=1 and shares tonic. Edges are asymmetric where expected.

### Deliverables

- [ ] Graph data structure with nodes, directed edges, multiple edge types
- [ ] Distance vector computation (all components)
- [ ] 5 edge generators (pivot, common-tone, mixture, direct, enharmonic)
- [ ] Full graph precomputed for 72 nodes
- [ ] Precomputation time measured and acceptable (< 2 seconds)
- [ ] 40+ unit tests validating known modulation relationships
- [ ] App still builds

### MVP Checkpoint

At the end of Phase 2, the data model and graph should be solid for major and natural minor keys. Modal edge generation (which requires adapted functional logic) can be refined iteratively but should not block Phase 3.

### Manual Test Brief

- N/A — pure logic, validated by unit tests
- Manual test brief documents test coverage and known relationship validations

---

## Phase 3: Challenge Engine — "The brain"

**Branch:** `phase-3/challenge-engine`
**Depends on:** Phase 2

### Sub-modules

- 3.1 **Difficulty tier assignment** — Rule-based assignment (not cost-range). Tier 1: same tonic, Δmode=1. Tier 2: Δregion=1 with strong pivots, or relative keys. Tier 3: parallel keys or Δregion=2 with good pivots. Tier 4: distant, mixture-assisted or common-tone. Tier 5: enharmonic reinterpretation, chromatic mediants, remote.
- 3.2 **Challenge generation** — Given current context and max tier: query graph for edges matching tier criteria, select target randomly with weighting to avoid recently visited keys.
- 3.3 **Arrival and key advancement** — When a new challenge triggers, current key auto-advances to previous target. No confirmation step.
- 3.4 **Sparse pool fallback** — If fewer than 3 valid targets at current tier, widen by one tier.
- 3.5 **Recently-visited avoidance** — Rolling buffer of last 5 visited keys. Weight selection away from these.
- 3.6 **Initial key selection** — User picks starting key or randomises. Persisted across launches.
- 3.7 **Pathfinding** — Dijkstra for lowest-cost path. Yen's algorithm for k-shortest alternative paths.
- 3.8 **Hint diversity** — When selecting k paths for display, prioritise technique diversity (pivot route vs common-tone route vs direct) over cost-similar variations.
- 3.9 **Hint data model** — Each hint step: intermediate key name, technique label, evidence (pivot chord with Roman numeral function in both keys for pivot modulations).
- 3.10 **Timer mode** — User-configurable interval. Timer triggers the same challenge logic as manual tap. Firing replaces any in-progress challenge.
- 3.11 **Tests** — Tier assignment for known pairs. Challenge generation at each tier produces valid targets. Sparse fallback triggers correctly. Pathfinding returns valid multi-step routes. Hint diversity selects technique-varied routes. Timer triggers advancement.

### Deliverables

- [ ] Rule-based tier assignment for all edge types
- [ ] Challenge generation with tier filtering and random selection
- [ ] Arrival/advancement mechanism
- [ ] Sparse pool fallback
- [ ] Recently-visited avoidance (rolling buffer of 5)
- [ ] Initial key selection with persistence
- [ ] Dijkstra + Yen's k-shortest pathfinding
- [ ] Technique-diverse hint selection
- [ ] Timer mode with configurable interval
- [ ] 40+ unit tests
- [ ] App still builds

### Manual Test Brief

- N/A — engine logic, validated by unit tests
- Manual test brief documents test coverage and engine behaviour verification

---

## Phase 4: UI — "The thing on the piano"

**Branch:** `phase-4/ui`
**Depends on:** Phase 3

### Sub-modules

- 4.1 **Main layout** — Single-screen landscape layout. Current key display prominent at top. Keyboard centred. Controls accessible but not dominant. Hint overlay appears on demand.
- 4.2 **Visual keyboard** — Single-octave piano keyboard. White and black keys rendered correctly. Scale tones highlighted. Tonic visually distinct (stronger colour or border). Note names displayed on keys. Sized for readability at ~60-80cm.
- 4.3 **Target overlay on keyboard** — When challenge active, three-way colour distinction: notes in both scales, notes only in current, notes only in target.
- 4.4 **Current key display** — Shows tonal context name (e.g., "G Major", "D Dorian") in large, readable text.
- 4.5 **Target key display** — When challenge active, shows target key name. Clear visual separation from current key.
- 4.6 **Hint system UI** — Hint button reveals route suggestions one step at a time (progressive disclosure). Each step shows: intermediate key, technique label, and evidence (e.g., "Pivot: Am — vi in C major, ii in G major"). For single-step modulations, shows technique and evidence directly.
- 4.7 **Controls** — Difficulty tier selector (1-5). Trigger mode toggle (tap/timer). Timer interval picker. All compact, not visually dominant.
- 4.8 **Starting key picker** — Key/mode picker accessible from controls. "Randomise" option. Persisted via UserDefaults.
- 4.9 **Randomise / next challenge button** — In manual mode, prominent button to trigger next challenge.
- 4.10 **Settings persistence** — Persist difficulty tier, trigger mode, timer interval, current key, starting key preference via UserDefaults. Restore on launch.
- 4.11 **iPhone layout** — Keyboard and text sized for iPhone in landscape. Prioritise legibility at music-stand distance.

### Deliverables

- [ ] Single-screen landscape interface, functional end to end
- [ ] Visual keyboard with scale highlighting, tonic distinction, note names
- [ ] Three-way colour overlay for active challenges
- [ ] Current and target key displays
- [ ] Hint system with progressive disclosure and technique/evidence detail
- [ ] All controls functional (tier, mode, timer, key picker)
- [ ] Settings persisted and restored on launch
- [ ] Readable at music-stand distance on iPhone
- [ ] 10+ UI tests

### Manual Test Brief

- Launch on iPhone simulator — verify landscape, keyboard readable, controls accessible
- Set starting key to Bb major — verify keyboard shows correct notes, Bb tonic highlighted
- Tap randomise — verify new target appears, keyboard overlay shows changing notes
- Request hint — verify step-by-step disclosure with technique and evidence
- Switch to timer mode, set 30s interval — verify challenge auto-fires
- When timer fires — verify current key advances to previous target, new target issued
- Set tier 1 — verify only modal shifts offered
- Set tier 5 — verify distant modulations offered with multi-step hints
- Kill and relaunch app — verify settings restored
- Place iPhone on piano music stand — verify readability at arm's length

---

## Phase 5: Calibration and Polish — "Does it feel right?"

**Branch:** `phase-5/calibration-polish`
**Depends on:** Phase 4

### Sub-modules

- 5.1 **Difficulty weight tuning** — Use the app during real practice sessions. Adjust the weighted sum coefficients in the distance vector until tiers feel musically appropriate. Document the final weights.
- 5.2 **Tier 1 assessment** — Specifically test whether modal shifts (Tier 1) genuinely feel easiest, or whether closely-related key modulations (Tier 2) are more natural for this player. Adjust tier ordering if needed, or add a user toggle for "include modes" independent of difficulty.
- 5.3 **Exemplar validation** — Validate the engine against a set of known exemplar modulations: textbook pivot-chord modulations should produce low-cost edges with correct pivot identification; distant modulations should suggest plausible multi-step routes; modal shifts should suggest the correct colour-note change.
- 5.4 **Hint quality review** — Assess whether hints are genuinely useful during practice. Are technique labels clear? Is the Roman numeral evidence helpful or distracting? Does progressive disclosure work, or should all steps show at once? Adjust based on real use.
- 5.5 **Keyboard readability** — Refine colours, sizing, contrast for real-world music-stand use. Test in different lighting conditions.
- 5.6 **Timer UX** — Test timer intervals in practice. Are the available intervals right? Does the auto-advancement feel natural or jarring?
- 5.7 **Edge case handling** — Test: all tiers from unusual starting keys (e.g., F# Phrygian at Tier 1 — does sparse fallback trigger?). Timer firing rapidly. Switching settings mid-challenge. App backgrounding and foregrounding.
- 5.8 **Vision statement audit** — Walk through every principle and requirement in the vision statement. Verify each is met.

### Deliverables

- [ ] Difficulty weights documented and calibrated
- [ ] Tier ordering validated (or adjusted) against real practice
- [ ] Exemplar modulations validated
- [ ] Hint presentation refined for practice use
- [ ] Keyboard readable on piano stand in normal lighting
- [ ] Timer UX feels natural
- [ ] All edge cases handled gracefully
- [ ] Vision statement audit passed

### Manual Test Brief

This IS the manual test. The user works through the full calibration using the app at a real piano over multiple practice sessions.

---

## Decision Log

| # | Decision | Rationale | Date |
|---|----------|-----------|------|
| 1 | Exclude Locrian from scale types | Diminished tonic triad — can't function as stable tonal centre | 2026-03-26 |
| 2 | Defer harmonic minor and melodic minor | Adds complexity without being core to modulation practice loop | 2026-03-26 |
| 3 | 12 pitch classes, not 15 key signatures | Enharmonic equivalents are the same node; spelling is display metadata | 2026-03-26 |
| 4 | Rule-based tier assignment, not cost ranges | Categorical tier definitions don't map cleanly to continuous costs | 2026-03-26 |
| 5 | Auto-advance current key on new challenge | Avoids interrupting practice with confirmation prompts | 2026-03-26 |
| 6 | Technique-diverse hints over cost-similar hints | Fulfils "multiple valid paths" principle meaningfully | 2026-03-26 |
| 7 | Tonic as replaceable convenience dependency | App's theory layer must be authoritative; can't be boxed in by library limits | 2026-03-26 |
| 8 | iPhone only (landscape) | iPhone in landscape on a piano stand provides sufficient screen real estate; no need for iPad support | 2026-03-26 |
| 9 | Sparse pool fallback (widen by one tier) | Prevents repetitive challenges from modal corners of the tonal space | 2026-03-26 |
| 10 | Sequential modulation excluded from edge types | Requires pattern repetition — can't be hinted at without notation/audio | 2026-03-26 |
| 11 | Defer pentatonic scales (major and minor) | 5-note scales break diatonic chord generation and distance calculations which assume 7-note scales. Requires theory layer changes. | 2026-03-27 |
| 12 | Weight challenge selection toward major/minor keys | Modes are included but deprioritised (5:1 weighting) — modal modulations are harder in practice than their theoretical distance suggests | 2026-03-27 |
