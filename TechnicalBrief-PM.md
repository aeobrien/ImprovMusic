# Technical Brief — Improv Music

## Architecture Overview

The app is a single-screen SwiftUI application with three distinct layers:

**Music Theory Layer** — The foundational data model and logic for representing tonal contexts, computing relationships between them, and generating modulation paths. This is the heart of the app and where the majority of the complexity lives.

**Engine Layer** — The challenge generation logic that selects modulation targets based on difficulty settings, manages the current tonal context, handles timer/manual triggering, and serves hint data to the UI.

**UI Layer** — A focused, minimal interface displaying the current key, a visual keyboard with highlighted notes, difficulty controls, trigger mode selection, and a hint overlay.

## Data Model

### Tonal Context

The fundamental unit is a TonalContext, representing a specific key or mode:

- **tonic**: a pitch class (0–11, mapped to note names with correct enharmonic spelling)
- **scaleType**: an enum covering major, natural minor, harmonic minor, melodic minor, and the seven diatonic modes (Ionian through Locrian)
- **pitchClassSet**: a Set<Int> (or 12-bit bitset) of the pitch classes in this scale, derived from the tonic and scale type's interval recipe
- **diatonicChords**: the triads and seventh chords built on each scale degree, precomputed from the pitch class set

Scale types are defined as interval recipes (sequences of semitone steps). AudioKit's Tonic library already encodes these and can be used as the foundation, with the app's TonalContext wrapping Tonic's primitives to add modulation-specific data.

### Modulation Graph

The full set of tonal contexts forms the nodes of a directed, weighted graph. For the initial implementation, the node set should include all 12 tonics × major, natural minor, and the 7 diatonic modes. This gives 108 nodes (12 × 9), which is small enough to precompute entirely.

Each directed edge represents a possible single-step modulation from context A to context B, and carries:

- **cost**: a composite difficulty score (see Difficulty Framework below)
- **techniqueType**: which modulation technique this edge represents (pivot chord, common-tone, direct, mixture-assisted, enharmonic reinterpretation)
- **evidence**: the specific musical material that enables this modulation (e.g., the pivot chord and its function in both keys, the common tone, the suggested cadence)

Multiple edges can exist between the same pair of nodes if multiple techniques apply. The graph is precomputed at app startup (or at build time if performance warrants it) and cached for the lifetime of the session.

### Edge Generation

For each ordered pair of tonal contexts (A, B), the engine evaluates whether each modulation technique applies:

**Pivot chord modulation**: Find all chords that are diatonic in both A and B (same root pitch class and chord quality). If any exist, generate an edge. Cost is lower when more pivots are available and when pivots serve strong harmonic functions (predominant in both keys is ideal; tonic-becoming-predominant is next best).

**Common-tone modulation**: Identify shared pitch classes between A and B that could serve as a sustained "hinge" note connecting a chord in A to a chord in B. More shared tones and stronger chord contexts reduce cost.

**Mixture-assisted modulation**: Extend A's chord set by borrowing from its parallel major/minor (mode mixture), then look for pivots between the extended set and B's diatonic chords. Applies when standard pivot chord modulation fails due to distance. Higher base cost than diatonic pivot.

**Direct modulation**: Always available as a fallback — simply assert the new key at a phrase boundary. Cost is a function of the raw distance between A and B with no reduction for pivot availability.

**Enharmonic reinterpretation**: Check for chords in A that can be enharmonically respelled to function in B (e.g., dominant seventh reinterpreted as German augmented sixth). High base cost; applies mainly to distant modulations.

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

The engine maps edge costs to five difficulty tiers:

**Tier 1 — Modal shift**: Same tonic, one colour-note difference. Example: C major to C Mixolydian. The player changes one note in their scale without shifting tonal centre.

**Tier 2 — Closely related**: Adjacent on the circle of fifths (Δregion = 1) with strong diatonic pivot chord availability. Example: C major to G major, or C major to A minor. Classic "easy" modulations with clear pivot points.

**Tier 3 — Moderate**: Relative/parallel key changes requiring cadential confirmation, or Δregion = 2 with good pivot availability. Example: C major to E minor (relative, same pitch set but tonic shift), or C major to D major.

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

The hint system presents paths as a sequence of tonal contexts with the suggested technique for each step. The user can reveal one step at a time (progressive disclosure) rather than seeing the full route immediately.

## Challenge Generation

When a modulation challenge is triggered (by tap or timer):

1. Query the graph for all nodes reachable from the current context within the user's difficulty tier
2. Filter to edges whose cost falls within the tier's cost range
3. Select a target randomly from the filtered set (with optional weighting to avoid recently visited keys)
4. If the selected target requires multi-step modulation at the current tier, precompute the hint paths
5. Present the target to the user

For the timer mode, the interval is user-configurable. When the timer fires, it triggers the same challenge generation logic as a manual tap.

## UI Architecture

### Main Screen

The app is a single-screen interface with these elements:

- **Current key display**: the name of the current tonal context (e.g., "G Major", "D Dorian")
- **Visual keyboard**: a piano keyboard graphic with the notes in the current scale highlighted. This is the primary visual element and should be large enough to read from a piano music stand
- **Target key display**: when a modulation challenge is active, shows the target key name (and optionally its keyboard visualisation)
- **Hint button**: reveals modulation route suggestions, one step at a time
- **Controls**: difficulty tier selector, trigger mode toggle (tap/timer), timer interval picker
- **Randomise button**: in manual mode, triggers a new challenge

### Visual Keyboard

The keyboard visualisation needs to clearly show which notes are in the current scale. Design considerations:
- Highlight both the white and black keys that are in the scale
- Use colour or shading that's readable at arm's length (piano music stand distance)
- When a modulation challenge is active, optionally show the target key's notes in a different colour so the player can see what's changing

### State Persistence

User settings (difficulty tier, trigger mode, timer interval, current key) are persisted using UserDefaults. On launch, the app restores the last-used configuration. No other persistence is needed — no user accounts, no progress tracking, no history.

## Technology Stack

- **Platform**: iOS, minimum version TBD (latest or latest-1 is fine for personal use)
- **UI Framework**: SwiftUI
- **Music Theory Primitives**: AudioKit's Tonic library for pitch classes, intervals, scales, and chord construction
- **Modulation Engine**: Custom-built on top of Tonic. The graph, edge generation, difficulty ranking, and pathfinding are all bespoke
- **Persistence**: UserDefaults for settings
- **No backend**: the app is entirely self-contained with no network requirements

## Implementation Phases

The natural dependency chain suggests this build order:

**Phase 1 — Data Model and Music Theory Layer**
Implement TonalContext, scale type definitions, pitch class set computation, and diatonic chord generation. Integrate Tonic library. Write tests validating that the model produces correct scales and chords for known inputs.

**Phase 2 — Modulation Graph**
Implement edge generation for each modulation technique. Build the composite distance calculation. Precompute the full graph. Write tests validating known modulation relationships (e.g., C major to G major should have low-cost pivot chord edges; C major to F# major should have high cost and limited direct options).

**Phase 3 — Engine**
Implement difficulty tier filtering, challenge generation, and pathfinding. This is where the graph gets queried at runtime. Write tests for challenge generation at each tier and for path quality.

**Phase 4 — UI**
Build the single-screen interface: keyboard visualisation, key display, controls, hint system. Connect to the engine layer. Implement settings persistence.

**Phase 5 — Calibration and Polish**
Tune difficulty weights against real practice sessions. Adjust tier boundaries. Refine hint presentation. General usability improvements based on actual use.

## Open Questions

1. **Difficulty weight calibration**: The research provides a framework but the exact weights in the composite distance formula will need tuning. This is best done empirically during Phase 5 by using the app and adjusting until the difficulty tiers feel right.

2. **Tonic library adequacy**: The research suggests Tonic covers pitch/scale/chord basics, but its actual API needs to be evaluated during Phase 1. If it's missing critical features (e.g., chord quality comparison, enharmonic handling), those gaps need to be filled.

3. **Enharmonic spelling**: Displaying note names correctly (Db vs C#) requires context-aware spelling. Tonic may handle this; if not, it's a Phase 1 concern.

4. **Graph precomputation performance**: 108 nodes with potentially thousands of edges should be fast to compute, but this needs to be validated. If startup time is noticeable, the graph could be serialised and bundled with the app.

5. **Keyboard visualisation design**: The exact visual treatment of the keyboard (size, colours, layout) will be refined during Phase 4. The key constraint is readability at music-stand distance.
