# Roadmap

## Next Up

| Task | Milestone | Phase | Status | Effort |
|------|-----------|-------|--------|--------|
| 1.1.1 Implement PitchClass type (0-11 with spelling preference) | 1.1 Core Data Types | 1: Data Model & Music Theory | Todo | Deep Focus |
| 1.1.2 Implement ScaleType enum with interval recipes | 1.1 Core Data Types | 1: Data Model & Music Theory | Todo | Deep Focus |
| 1.1.3 Implement TonalContext (tonic + scale type -> pitch class set + diatonic chords) | 1.1 Core Data Types | 1: Data Model & Music Theory | Todo | Deep Focus |
| 1.2.1 Evaluate AudioKit Tonic library against project needs | 1.2 Tonic Evaluation | 1: Data Model & Music Theory | Todo | Deep Focus |

---

## Phase 1: Data Model & Music Theory Layer
**Status:** Todo
**Definition of Done:** TonalContext correctly produces scales, pitch class sets, and diatonic chords for all 72 nodes (12 tonics x 6 scale types). Tonic library evaluated and integrated or replaced. All outputs validated by tests against known music theory facts.

### 1.1 — Core Data Types
**Status:** Todo
**Priority:** High
**Definition of Done:** PitchClass, ScaleType, and TonalContext types implemented with correct pitch class sets and diatonic chord generation for all scale types.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 1.1.1 | Implement PitchClass type (0-11 with spelling preference) | Todo | Deep Focus | | Enharmonic spelling metadata on the tonic |
| 1.1.2 | Implement ScaleType enum with interval recipes | Todo | Deep Focus | | Major, natural minor, Dorian, Phrygian, Lydian, Mixolydian |
| 1.1.3 | Implement TonalContext (tonic + scale -> pitch class set + diatonic chords) | Todo | Deep Focus | | Core data structure for everything |
| 1.1.4 | Write comprehensive tests for all 72 tonal contexts | Todo | Deep Focus | | Validate against known scale/chord facts |

### 1.2 — Tonic Library Evaluation
**Status:** Todo
**Priority:** High
**Definition of Done:** Tonic evaluated for pitch class representation, scale generation, chord quality comparison, enharmonic handling, and modal support. Decision made: integrate, wrap, or replace.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 1.2.1 | Evaluate Tonic API against project needs | Todo | Deep Focus | | Do not defer — this is a discovery risk |
| 1.2.2 | Build custom replacements for any gaps | Todo | Deep Focus | | Only if evaluation reveals insufficiency |

---

## Phase 2: Modulation Graph
**Status:** Todo
**Definition of Done:** Full 72-node directed weighted graph precomputed with edges for all five modulation techniques. Distance vectors computed correctly. Tests validate known modulation relationships.

### 2.1 — Edge Generators
**Status:** Todo
**Priority:** High
**Definition of Done:** All five edge generator types implemented and producing correct edges with cost, technique type, and evidence.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 2.1.1 | Implement pivot chord edge generator | Todo | Deep Focus | | Find diatonic chords common to both contexts |
| 2.1.2 | Implement common-tone edge generator | Todo | Deep Focus | | Shared pitch classes as hinge notes |
| 2.1.3 | Implement mixture-assisted edge generator | Todo | Deep Focus | | Borrow from parallel major/minor |
| 2.1.4 | Implement direct modulation edge generator | Todo | Deep Focus | | Fallback — always available |
| 2.1.5 | Implement enharmonic reinterpretation edge generator | Todo | Deep Focus | | Dom7 as Ger+6, etc. |

### 2.2 — Graph Construction
**Status:** Todo
**Priority:** High
**Definition of Done:** Complete graph built from all edge generators, with composite distance scoring and precomputation.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 2.2.1 | Implement composite distance vector calculation | Todo | Deep Focus | | Weighted sum of delta-scale, delta-region, delta-tonic, delta-mode, pivot availability, cadence support |
| 2.2.2 | Build full graph precomputation | Todo | Deep Focus | | Evaluate all ordered pairs, cache for session |
| 2.2.3 | Write graph validation tests | Todo | Deep Focus | | C maj -> G maj = low cost; C maj -> F# maj = high cost |

---

## Phase 3: Engine
**Status:** Todo
**Definition of Done:** Challenge generation works at all five difficulty tiers. Pathfinding returns technique-diverse hint routes. Timer and manual trigger modes functional.

### 3.1 — Difficulty & Challenge Generation
**Status:** Todo
**Priority:** High
**Definition of Done:** Rule-based tier assignment working. Challenge generator selects targets within configured tier, avoids recently visited keys.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 3.1.1 | Implement rule-based difficulty tier assignment | Todo | Deep Focus | | Tiers 1-5 based on edge properties, not cost ranges |
| 3.1.2 | Implement challenge generation with tier filtering | Todo | Deep Focus | | Random selection with recency weighting |
| 3.1.3 | Implement timer and manual trigger modes | Todo | Deep Focus | | Configurable interval for timer |

### 3.2 — Pathfinding & Hints
**Status:** Todo
**Priority:** High
**Definition of Done:** Dijkstra + Yen's k-shortest paths. Hint routes prioritise technique diversity over minor cost variations.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 3.2.1 | Implement Dijkstra's algorithm on modulation graph | Todo | Deep Focus | | Lowest-cost path |
| 3.2.2 | Implement Yen's k-shortest paths | Todo | Deep Focus | | Alternative routes for hints |
| 3.2.3 | Implement technique-diverse route selection | Todo | Deep Focus | | Prefer one pivot route, one common-tone route, etc. |
| 3.2.4 | Write engine integration tests | Todo | Deep Focus | | Challenge distribution, path quality |

---

## Phase 4: UI
**Status:** Todo
**Definition of Done:** Single-screen landscape interface with visual keyboard, key displays, controls, and progressive-disclosure hint overlay. Connected to engine. Settings persisted via UserDefaults.

### 4.1 — Core Interface
**Status:** Todo
**Priority:** High
**Definition of Done:** Main screen layout with keyboard visualisation, current/target key display, and controls.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 4.1.1 | Build main screen layout (landscape) | Todo | Deep Focus | | Single-screen, no navigation |
| 4.1.2 | Implement visual keyboard with scale highlighting | Todo | Deep Focus | | Three-way colour: both, current-only, target-only. Tonic visually distinct. |
| 4.1.3 | Implement current and target key display | Todo | Deep Focus | | Large, readable at 60-80cm |
| 4.1.4 | Implement controls (tier selector, trigger mode, timer interval, key picker) | Todo | Deep Focus | | |

### 4.2 — Hints & Persistence
**Status:** Todo
**Priority:** Normal
**Definition of Done:** Progressive disclosure hint overlay. UserDefaults persistence for all settings.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 4.2.1 | Implement progressive disclosure hint overlay | Todo | Deep Focus | | Reveal one step at a time |
| 4.2.2 | Implement UserDefaults persistence | Todo | Quick Win | | Difficulty, trigger mode, timer interval, current key |

---

## Phase 5: Calibration & Polish
**Status:** Todo
**Definition of Done:** Difficulty weights tuned against real practice sessions. Tier boundaries feel right. Hint presentation refined. App is comfortable to use on a piano music stand.

### 5.1 — Tuning
**Status:** Todo
**Priority:** High
**Definition of Done:** Distance formula weights calibrated empirically. Tier boundaries adjusted. Usability improvements from real use.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 5.1.1 | Tune difficulty weights against practice sessions | Todo | Creative | | Empirical — use the app and adjust |
| 5.1.2 | Adjust tier boundaries based on feel | Todo | Creative | | |
| 5.1.3 | Refine hint presentation | Todo | Creative | | |
| 5.1.4 | General usability improvements | Todo | Creative | | Based on actual piano-stand use |

---

## Dependencies

| Item | Depends On | Status |
|------|-----------|--------|
| 2.1.1-2.1.5 (Edge generators) | 1.1 (Core data types) | Unmet |
| 2.2.1-2.2.2 (Graph construction) | 2.1 (Edge generators) | Unmet |
| 3.1.1 (Tier assignment) | 2.2 (Graph construction) | Unmet |
| 3.2.1-3.2.3 (Pathfinding) | 2.2 (Graph construction) | Unmet |
| 4.1.1-4.2.2 (UI) | 3.1-3.2 (Engine) | Unmet |
| 5.1.1-5.1.4 (Calibration) | 4.1-4.2 (UI) | Unmet |

---

## Reference

### Status Values
| Status | Meaning |
|--------|---------|
| Todo | Not yet started |
| In Progress | Actively being worked on |
| Blocked: [reason] | Cannot proceed — reason is one of: poorly-defined, too-large, missing-info, missing-resource, decision-required |
| Waiting | User's part done, waiting on external input |
| Done | Complete |
| Dropped | Deliberately abandoned |

### Effort Types
| Type | Description |
|------|-------------|
| Deep Focus | Sustained concentration, problem-solving, design work |
| Creative | Open-ended, generative, exploratory |
| Administrative | Organising, documenting, updating, filing |
| Communication | Discussions, reviews, feedback |
| Physical | Hands-on work, building, soldering |
| Quick Win | Small, low-effort, momentum-building |

### Priority
High / Normal / Low — milestones only. Tasks inherit from their milestone unless overridden.
