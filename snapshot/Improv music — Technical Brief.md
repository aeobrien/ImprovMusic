# Technical Brief — Improv Music

## Architecture Overview

The app is a single-screen SwiftUI application with three distinct layers:

**Music Theory Layer** — The foundational data model and logic for representing tonal contexts, computing relationships between them, and generating modulation paths. This is the heart of the app and where the majority of the complexity lives.

**Engine Layer** — The challenge generation logic that selects modulation targets based on difficulty settings, manages the current tonal context, handles timer/manual triggering, and serves hint data to the UI.

**UI Layer** — A focused, minimal interface displaying the current key, a visual keyboard with highlighted notes, difficulty controls, trigger mode selection, and a hint overlay.

## Data Model

### Tonal Context

The fundamental unit is a TonalContext, representing a specific key or mode:

- **tonic**: a pitch class (0–11) with an associated **spelling preference** that determines how the note is displayed (e.g., pitch class 1 displays as "Db" or "C#" depending on context). Pedagogically absurd spellings (D# major, A# minor, etc.) are suppressed — the app uses conventional key-signature spellings
- **scaleType**: an enum covering major, natural minor, and the five usable diatonic modes (Dorian, Phrygian, Lydian, Mixolydian, Ionian and Aeolian are aliases for major and natural minor respectively). Locrian is excluded — its diminished tonic triad prevents it from functioning as a stable tonal centre. Harmonic minor and melodic minor are deferred from the initial implementation; they add significant complexity to chord generation and distance computation without being core to the modulation practice loop
- **pitchClassSet**: a Set<Int> (or 12-bit bitset) of the pitch classes in this scale, derived from the tonic and scale type's interval recipe
- **diatonicChords**: the triads and seventh chords built on each scale degree, precomputed from the pitch class set, with functional labels (tonic, predominant, dominant) where applicable. For modes, functional labelling is adapted: not all modes support classical tonal function hierarchies, and modal chord roles should be derived from each mode's characteristic patterns rather than forced into major/minor functional templates

Scale types are defined as interval recipes (sequences of semitone steps). AudioKit's Tonic library can provide pitch, scale, and chord primitives, with the app's TonalContext wrapping these to add modulation-specific data. However, the app's theory layer must remain authoritative — if Tonic proves insufficient for chord quality comparison, enharmonic handling, or modal support, it should be replaced with a thin custom layer rather than worked around.

### Modulation Graph

The full set of tonal contexts forms the nodes of a directed, weighted graph. The node set includes 12 tonics × 6 scale types (major, natural minor, Dorian, Phrygian, Lydian, Mixolydian — noting that Ionian and Aeolian are aliases for major and natural minor respectively). This gives 72 nodes, which is small enough to precompute entirely. Enharmonically equivalent keys (e.g., F# major and Gb major) share the same node — they are the same pitch classes — but the spelling preference on the tonic determines display.

Each directed edge represents a possible single-step modulation from context A to context B, and carries:

- **cost**: a composite difficulty score (see Difficulty Framework below)
- **techniqueType**: which modulation technique this edge represents (pivot chord, common-tone, direct, mixture-assisted, enharmonic reinterpretation)
- **evidence**: the specific musical material that enables this modulation (e.g., the pivot chord and its function in both keys, the common tone, the suggested cadence)

Multiple edges can exist between the same pair of nodes if multiple techniques apply. The graph is precomputed at app startup (or at build time if performance warrants it) and cached for the lifetime of the session.

### Edge Generation

For each ordered pair of tonal contexts (A, B), the engine evaluates whether each modulation technique applies:

**Pivot chord modulation**: Find all chords that are diatonic in both A and B (same root pitch class and chord quality). If any exist, generate an edge. Cost is lower when more pivots are available and when pivots serve strong harmonic functions (predominant in both keys is ideal; tonic-becoming-predominant is next best). When one or both contexts is a mode rather than major/minor, the functional hierarchy used for pivot quality assessment must be adapted — modal contexts may not have clear predominant/dominant roles, and the edge generator should fall back to chord-overlap count rather than forcing tonal function labels.

**Common-tone modulation**: Identify shared pitch classes between A and B that could serve as a sustained "hinge" note connecting a chord in A to a chord in B. More shared tones and stronger chord contexts reduce cost.

**Mixture-assisted modulation**: Extend A's chord set by borrowing from its parallel major/minor (mode mixture), then look for pivots between the extended set and B's diatonic chords. Applies when standard pivot chord modulation fails due to distance. Higher base cost than diatonic pivot.

**Direct modulation**: Always available as a fallback — simply assert the new key at a phrase boundary. Cost is a function of the raw distance between A and B with no reduction for pivot availability.

**Enharmonic reinterpretation**: Check for chords in A that can be enharmonically respelled to function in B (e.g., dominant seventh reinterpreted as German augmented sixth). High base cost; applies mainly to distant modulations.

Note: **sequential modulation** (repeating a melodic/harmonic pattern at a new pitch level) is covered in the research but deliberately excluded as an edge type. It requires pattern repetition that the app cannot hint at without notation or audio — it is a performance technique rather than something the hint system can usefully suggest.

### Distance Vector

Each edge's cost is computed from a composite distance vector:

- **Δscale**: symmetric difference of pitch class sets (|A Δ B|), representing how many notes change
- **Δregion**: circle-of-fifths distance between the underlying diatonic collections (0–6)
- **Δtonic**: circle-of-fifths distance between the two tonics (0–6)
- **Δmode**: number of colour-note edits between the two mode types when they share a tonic (e.g., Ionian to Mixolydian = 1)
- **pivotAvailability**: number and functional quality of available pivot chords (reduces cost)
- **cadenceSupport**: whether the target context supports strong cadential confirmation (leading tone present, dominant chord available)

These components are combined via weighted sum to produce the edge cost. The weights are tunable and should be calibrated against musical intuition during development — the research reports provide a starting framework but the exact weights will need empirical adjustment.

## Difficulty Framework

The engine maps modulations to five difficulty tiers. Tier assignment is **rule-based**, determined by checking the properties of the edge (technique type, distance components, pivot availability) against the criteria below — not by mapping a continuous cost value to numeric ranges.

**Tier 1 — Modal shift**: Same tonic, one colour-note difference. Example: C major to C Mixolydian. The player changes one note in their scale without shifting tonal centre. Note: despite involving fewer pitch changes, modal shifts may feel unfamiliar to players with limited modal experience. The Phase 5 calibration should assess whether this tier genuinely feels easiest in practice.

**Tier 2 — Closely related**: Adjacent on the circle of fifths (Δregion = 1) with strong diatonic pivot chord availability, or relative key modulations (shared pitch set, different tonic — e.g., C major to A minor). Classic modulations with clear pivot points.

**Tier 3 — Moderate**: Parallel key changes (e.g., C major to C minor) or Δregion = 2 with good pivot availability. Example: C major to D major, or C major to C minor. These require more deliberate cadential work to establish the new tonal centre.

**Tier 4 — Distant**: More than two accidentals apart, requiring mixture-assisted pivots or common-tone strategies. Example: C major to Eb major. Single-step modulation is possible but requires more sophisticated technique.

**Tier 5 — Remote**: Enharmonic reinterpretation, chromatic mediant relationships, or modulations where no smooth single-step technique exists and multi-step paths are recommended. Example: C major to F# major.

The user's difficulty setting determines the maximum tier the challenge generator will draw from. At Tier 1, only modal shifts are offered. At Tier 5, anything goes.

## Pathfinding

For modulations at higher difficulty tiers (particularly Tier 4 and 5), the hint system needs to suggest multi-step routes through intermediate keys.

The precomputed modulation graph is queried using Dijkstra's algorithm to find the lowest-cost path from the current context to the target. Additionally, k-shortest-paths (Yen's algorithm or similar) are computed to provide alternative routes for the hint system.

Path quality heuristics:
- Prefer paths where each intermediate step is Tier 2 or 3 (closely related), even if the overall journey is long
- Penalise paths with consecutive direct modulations (no pivot support)
- Prefer paths where intermediate keys are musically "interesting" stopping points (major and minor keys over obscure modes, unless the user is working at a tier that includes modes)

**Hint diversity**: The hint system should prefer showing routes that use genuinely different techniques rather than minor cost variations of the same approach. When selecting k paths for display, prioritise technique diversity — e.g., one route using pivot chords and another using common tones — over simply returning the k lowest-cost paths.

### Hint Data Model

Each hint step presented to the user contains:
- **Intermediate tonal context**: the key/mode name (e.g., "A minor")
- **Technique label**: the modulation technique for this step (pivot chord, common-tone, direct, etc.)
- **Evidence** (for pivot chord modulations): the specific pivot chord with its Roman numeral function in both keys (e.g., "Am: vi in C major → ii in G major")

The hint system uses progressive disclosure — the user reveals one step at a time. For single-step modulations, the hint shows the recommended technique and evidence directly without intermediate keys.

## Challenge Generation

### Initial Key Selection

On first launch (or when no persisted state exists), the user is presented with a key picker to choose their starting tonal context. They can also choose to randomise. The starting key is persisted and restored on subsequent launches.

### Arrival and Key Advancement

When a new challenge is triggered, the current key **automatically advances to the previous target**. The app assumes the player has arrived and moves on — there is no confirmation step. This keeps the practice loop moving and avoids interrupting the player with a "did you make it?" prompt. In timer mode, this means the timer firing always replaces the current challenge: the previous target becomes the current key and a new target is issued.

### Challenge Trigger

When a modulation challenge is triggered (by tap or timer):

1. Advance the current key to the previous target (if one exists)
2. Query the graph for all nodes reachable from the current context whose edges match the user's difficulty tier (using the rule-based tier criteria, not a cost range)
3. Select a target randomly from the filtered set, weighted to avoid the last 5 visited keys (tracked as a rolling buffer)
4. If the selected target would benefit from multi-step modulation at the current tier, precompute the hint paths
5. Present the target to the user

**Sparse pool fallback**: If fewer than 3 valid targets exist at the current tier from the current context, the engine widens by one tier (e.g., Tier 1 expands to include Tier 2 candidates). This prevents the player from getting stuck in a corner of the tonal space with repetitive challenges.

For the timer mode, the interval is user-configurable. When the timer fires, it triggers the same challenge generation logic as a manual tap.

## UI Architecture

### Main Screen

The app is a single-screen interface in **landscape orientation** with these elements:

- **Current key display**: the name of the current tonal context (e.g., "G Major", "D Dorian")
- **Visual keyboard**: a piano keyboard graphic with the notes in the current scale highlighted. This is the primary visual element and should be large enough to read from a piano music stand
- **Target key display**: when a modulation challenge is active, shows the target key name (and optionally its keyboard visualisation)
- **Hint button**: reveals modulation route suggestions one step at a time, showing the intermediate key, technique, and (for pivot modulations) the specific chord with its function in both keys
- **Controls**: difficulty tier selector, trigger mode toggle (tap/timer), timer interval picker
- **Randomise button**: in manual mode, triggers a new challenge
- **Starting key picker**: allows the user to select or randomise the initial tonal context

### Visual Keyboard

The keyboard visualisation is the primary interface element and needs to clearly show which notes are in the current scale.

Specification:
- **Range**: a single octave (sufficient for showing scale membership; avoids clutter)
- **Tonic highlighting**: the tonic note is visually distinguished from other scale tones (e.g., stronger colour or border) so the player can immediately see the tonal centre
- **Note names**: displayed on each key for quick reference at arm's length
- **Scale highlighting**: both white and black keys in the scale are highlighted with colour or shading readable at music-stand distance (~60–80cm)
- **Target overlay**: when a modulation challenge is active, the target key's notes are shown in a different colour so the player can see what's changing — notes in both scales, notes only in the current scale, and notes only in the target scale should be visually distinguishable
- **Device sizing**: the keyboard should be legible on iPhone in landscape at music-stand distance (~60-80cm). Exact visual treatment (colours, sizing, layout) is refined during Phase 4

### State Persistence

User settings (difficulty tier, trigger mode, timer interval, current key, starting key preference) are persisted using UserDefaults. On launch, the app restores the last-used configuration. No other persistence is needed — no user accounts, no progress tracking, no history.

## Technology Stack

- **Platform**: iOS (iPhone only), minimum version TBD (latest or latest-1 is fine for personal use), landscape orientation
- **UI Framework**: SwiftUI
- **Music Theory Primitives**: AudioKit's Tonic library for pitch classes, intervals, scales, and chord construction — used as a convenience dependency, not a structural one. The app's own theory layer is authoritative; if Tonic proves insufficient, it is replaced rather than worked around
- **Modulation Engine**: Custom-built on top of the theory layer. The graph, edge generation, difficulty ranking, and pathfinding are all bespoke
- **Persistence**: UserDefaults for settings
- **No backend**: the app is entirely self-contained with no network requirements

## Implementation Phases

The natural dependency chain suggests this build order:

**Phase 1 — Data Model and Music Theory Layer**
Implement TonalContext (including spelling preference), scale type definitions, pitch class set computation, and diatonic chord generation. Evaluate and integrate Tonic library — validate that it supports chord quality comparison, enharmonic handling, and modal scales. If gaps exist, fill them with custom implementations before proceeding. Write tests validating that the model produces correct scales and chords for known inputs.

**Phase 2 — Modulation Graph**
Implement edge generation for each modulation technique. Build the composite distance calculation. Precompute the full graph. Write tests validating known modulation relationships (e.g., C major to G major should have low-cost pivot chord edges; C major to F# major should have high cost and limited direct options). **MVP checkpoint**: at the end of Phase 2, the data model and graph should be solid for major and natural minor keys. Modal edge generation (which requires adapted functional logic) can be refined iteratively but should not block Phase 3.

**Phase 3 — Engine**
Implement difficulty tier assignment (rule-based), challenge generation (including arrival/advancement, sparse-pool fallback, recently-visited avoidance), initial key selection, and pathfinding. Write tests for challenge generation at each tier and for path quality.

**Phase 4 — UI**
Build the single-screen landscape interface: keyboard visualisation, key display, controls, hint system with progressive disclosure and technique-diverse routes. Connect to the engine layer. Implement settings persistence. Target iPhone in landscape.

**Phase 5 — Calibration and Polish**
Tune difficulty weights against real practice sessions. In particular, assess whether Tier 1 (modal shifts) genuinely feels easiest or whether players find standard key modulations more natural. Adjust tier boundaries. Validate the engine against a set of known exemplar modulations (e.g., textbook pivot-chord modulations should produce low-cost edges with correct pivot identification). Refine hint presentation. General usability improvements based on actual use.

## Open Questions

1. **Difficulty weight calibration**: The research provides a framework but the exact weights in the composite distance formula will need tuning. This is best done empirically during Phase 5 by using the app and adjusting until the difficulty tiers feel right. In particular, the relative ordering of modal shifts (Tier 1) and closely-related key modulations (Tier 2) should be tested — modal shifts involve fewer pitch changes but may feel harder to players with limited modal experience.

2. **Tonic library adequacy**: Tonic must be evaluated concretely during Phase 1 — not deferred as a discovery risk. Required capabilities: chord quality comparison, enharmonic spelling, modal scale definitions for all included modes. If Tonic falls short, replace it with a thin custom layer.

3. **Enharmonic spelling**: The TonalContext includes a spelling preference, but the rules for selecting the preferred spelling (e.g., always use the conventional key-signature spelling) need to be defined during Phase 1. Suppress spellings that would produce double-sharps/flats in key signatures.

4. **Graph precomputation performance**: 72 nodes with potentially thousands of edges should be fast to compute, but this needs to be validated. If startup time is noticeable, the graph could be serialised and bundled with the app.

5. **Keyboard visualisation design**: The information architecture is defined (single octave, tonic highlighting, note names, target overlay with three-way colour distinction). Exact visual treatment (colours, sizing, layout) will be refined during Phase 4. The key constraint is readability at music-stand distance on iPhone in landscape.

6. **Modal edge generation**: The pivot chord and functional-quality logic in the edge generators assumes major/minor tonal function hierarchies. For edges involving modal contexts, the functional assessment needs to be adapted — either by defining per-mode chord role mappings or by falling back to simpler overlap-based scoring. This should be addressed during Phase 2 but refined iteratively.

7. **Future scope — harmonic/melodic minor and Locrian**: Harmonic minor, melodic minor (jazz convention: ascending form used in both directions), and Locrian are excluded from the initial implementation. They can be added later as additional scale types in the data model and graph. Locrian would need special handling (e.g., expert-only, or excluded from random challenge targets).