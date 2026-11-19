# Encoding Key, Mode, and Modulation Relationships for an Improv Practice Engine

## Tonal objects and boundaries

A reliable modulation engine starts with a clear distinction between **tonicisation** (brief, local emphasis of a non-tonic chord) and **modulation** (a sustained change of tonic that is *confirmed* in the new key). Multiple pedagogical sources converge on the idea that the practical “test” for modulation is the presence of a cadence that establishes the new tonic (whereas tonicisation lacks such a cadence). citeturn12view1turn5view0turn12view0

For implementation, it is useful to model every “destination” as a **tonal context**:

- **Tonic** (pitch class + spelling preference)
- **Scale / mode type** (major/minor, plus modal variants like Dorian, Mixolydian, etc.)
- **Pitch collection** (the set of pitch classes implied by that scale/mode)

This unifies major/minor keys and modes in one data model. In practice, this is not just theoretical: the `music21` toolkit uses a `Key` object that can represent not only major/minor but also “church modes” directly (e.g., Mixolydian), and associates those with key-signature information (number of sharps/flats) and altered pitches. citeturn9view0

A second implementation-friendly concept is the **diatonic collection**: a 7-note diatonic scale can be treated as *seven adjacent positions on the circle/line of fifths*. citeturn11view3 This matters because:

- “Closely related keys” are conventionally those whose key signatures lie one step “sharper” or “flatter” (≈ one move on the circle of fifths), and pedagogical sources commonly describe *five* closely related keys for any given major/minor key. citeturn10view0turn19view0turn5view0
- Cognitive and theoretical models of tonal proximity often organise key relations around the circle of fifths plus relative/parallel relations between major and minor. citeturn11view0

Within entity["people","Fred Lerdahl","music theorist"]’s tonal-pitch-space framework (as summarised in later analytical work), **regional proximity** can be expressed as moves around a *regional circle of fifths* that transforms one diatonic collection into another; repeated applications generate all major diatonic collections, and minor regions are commonly represented via their relative majors (shared key signature). citeturn5view1 This “regional move count” becomes a natural, computable ingredient for a distance metric.

Modes can be treated as “major-ish” or “minor-ish” variants with characteristic “colour notes” (scale-degree inflections) relative to major or natural minor. For example, Mixolydian differs from major by a lowered 7; Lydian differs by a raised 4; Dorian differs from natural minor by a raised 6; Phrygian differs by a lowered 2; Aeolian is the natural minor and characteristically avoids a raised leading tone. citeturn10view4

image_group{"layout":"carousel","aspect_ratio":"16:9","query":["circle of fifths diagram showing key signatures major and minor","diatonic modes chart ionian dorian phrygian lydian mixolydian aeolian locrian"]}

## Distance metrics that work for both keys and modes

A modulation engine needs a distance metric that (a) is computable from symbolic structures and (b) correlates with real musical difficulty in practice. A single metric rarely captures everything, but you *can* build an implementable composite that stays consistent across **key-to-key**, **key-to-mode**, and **mode-to-mode** cases.

### Pitch-set distance as a baseline

A straightforward unified baseline is to represent each scale/mode as a **pitch-class set** (e.g., a 12-bit bitset) and compute the **symmetric difference** size:

- `pitchSetDistance(A,B) = |A Δ B|` (how many pitch classes must change)
- Equivalent: `|A| + |B| − 2|A ∩ B|`

This has three advantages for your engine:

1. It works for any scale type (major/minor/modes/other).
2. It aligns with the “one accidental step” intuition: moving one notch on the circle of fifths changes one pitch class in the diatonic collection. citeturn2search6turn11view3
3. It’s easy to compute and easy to cache.

A crucial caveat: **pitch-set distance is insufficient alone** because different tonal contexts can share the same pitch collection. The classic example is **relative keys**, which share a key signature (same pitch set) but have different tonics. Pedagogical summaries explicitly distinguish *relative* (shared signature, different tonic) from other relationships. citeturn19view0turn10view0 If your engine used pitch-set distance only, it would score relative-key modulations as “distance 0”, which does not match either classical practice (still a real key change) or the improviser’s task (must redirect tonal gravity).

### Add tonic-distance inside a shared collection

To correct that, compute a **tonic-distance** feature that is independent of collection overlap. Two practical options:

- **Circle-of-fifths tonic distance**: distance between tonics as steps on the circle of fifths (wrapping at 12), which matches how tonal space is often conceptualised in cognition and theory. citeturn11view0turn2search6  
- **Scale-degree tonic distance (within a collection)**: if two contexts share an underlying 7-note collection, measure how far apart their tonics are as degrees 1–7 within that collection.

For implementation, you can compute both and combine them: fifths-distance is globally stable; scale-degree distance captures “relative-mode shifts” inside one diatonic collection.

### Add mode-distance (colour-note edits)

For modes, a useful *computable* “mode distance” is the number of **altered degrees** relative to a reference (major for major-ish modes; natural minor for minor-ish modes). Open educational materials already frame modes as “major/minor-ish with inflected colour notes.” citeturn10view4  
For example:

- Ionian → Mixolydian: 1 altered degree (♭7)
- Ionian → Lydian: 1 altered degree (♯4)
- Aeolian → Dorian: 1 altered degree (♮6)
- Aeolian → Phrygian: 1 altered degree (♭2)

This “edit count” is extremely convenient for tiering difficulty, because single-colour-note shifts can be offered as early-stage challenges.

### Add technique-availability features (why equal note-differences are not equally hard)

Even if two target contexts are equally close in pitch-set terms, they may not be equally easy to *modulate into* because modulation is not just “change scale”; it is “make the listener/player accept the new tonic.” Multiple sources emphasise that modulation is established by cadential/harmonic behaviour and that pivot strategies depend on what chords/functions are available. citeturn12view0turn12view1turn10view6

Two implementable “availability” measures that strongly affect difficulty:

1. **Common-chord availability (pivot potential)**  
   In diatonic pivot-chord modulation, you explicitly look for chords that are diatonic in both keys—same root and quality. citeturn10view1turn12view0turn12view1  
   You can compute:
   - `commonTriadsCount`
   - `commonSeventhsCount`
   - and (critically) the *functional roles* those chords play in source vs target.

2. **Cadential strength in the target context**  
   Many modulation descriptions treat a cadence in the new key as the confirmation step. citeturn12view1turn5view0  
   For major/minor, your engine can model “strong cadence available” using the presence/availability of dominant-function patterns. For certain modes, Open Music Theory explicitly notes that Aeolian “avoids the raised leading tone,” implying that classical V–I leading-tone pull is weaker unless you borrow from harmonic minor or mixture. citeturn10view4turn10view5

### A recommended composite distance vector

Instead of one scalar too early, define a **distance vector** that later folds into difficulty:

- `Δscale = |pitchSetA Δ pitchSetB|`  
- `Δregion = circleOfFifthsDistance(diatonicCollectionA, diatonicCollectionB)` (0–6) citeturn5view1turn2search6  
- `Δtonic = fifthsDistance(tonicA, tonicB)` and/or `scaleDegreeDistanceIfSharedCollection` citeturn11view0turn11view3  
- `Δmode = colourNoteEditCount(modeA, modeB)` citeturn10view4  
- `pivotOptions = (commonTriadsCount, commonSeventhsCount, bestPivotFunctionMatchScore)` citeturn10view1turn12view0  
- `cadenceSupport = (leadingTonePresent?, dominantQualityAvailable?, modalCadenceAvailable?)` citeturn10view4turn10view5

Your engine can then map that vector to difficulty tiers (next section) or to edge costs in a modulation graph (pathfinding section).

## Modulation techniques as computable “edge types”

Treat each modulation technique as an **edge generator**: given a source context A and target context B, the technique either applies (with computed “how”) or it doesn’t. This turns theory into code-friendly rules.

### Diatonic pivot-chord modulation

Core definition (agrees across multiple teaching sources): a pivot chord is **diatonic to both keys** and is reinterpreted with different harmonic function to move from one tonic to another. citeturn12view0turn12view1turn5view0turn10view1

Computable requirements:

- A chord type list for each context (triads and/or sevenths built on each scale degree).
- A test for “common chord”: same root pitch class + same chord quality across both contexts (explicitly recommended for identifying common chords). citeturn10view1
- A strategy for selecting “best pivot placement”:  
  entity["book","Open Music Theory","open textbook"] suggests that if multiple pivots are possible, the best ones often involve **predominant function in both keys**, because you typically head to V soon after the pivot; second-best is tonic in old becoming predominant in new (I→IV). citeturn12view0

Difficulty factors you can encode:

- More common chords → lower difficulty.
- “Predominant→predominant” pivots → lower difficulty than “tonic→predominant” → lower than “dominant→something unusual.” citeturn12view0turn12view1
- Keys more than one accidental apart: pivot finding becomes harder in general. citeturn10view6

### Borrowed-pivot / mixture-assisted modulation

When two keys are **more than one accidental apart** on the circle of fifths, Open Music Theory explicitly notes it becomes harder to find a smooth pivot chord; **mode mixture** (borrowing from the parallel mode) expands the available chromatic chords and therefore expands pivot options. citeturn10view6turn10view5  
A parallel idea appears in other pedagogy: common-chord modulations to “foreign” keys often require an altered chord as pivot. citeturn5view0

Computable requirements:

- A catalogue of mixture chords available in the source (borrow from parallel major/minor), where mixture is defined as borrowing notes from the parallel key and typically preserves functional role while changing chord quality/colour. citeturn10view5turn2search13
- Generate extended chord sets:
  - `diatonicChords(source)` plus `mixtureChords(source)`
  - Then intersect with `diatonicChords(target)` for candidate pivots.

Difficulty factors:

- Any chromatic borrowing increases cognitive/motor load and is more “remote-key” typical. citeturn10view6turn5view0turn10view5
- If the borrowed pivot still leads cleanly into a cadence in the target, reduce difficulty (because confirmation is clearer). citeturn12view1turn12view0

### Common-tone modulation

A compact, implementable description: one note is sustained or repeated while other chord tones change, and that sustained pitch belongs to both harmonic contexts—often with enharmonic respelling. citeturn10view2  
Another pedagogy frames it as connecting two chords through a single “hinge note” to bridge the distance between keys. citeturn12view2

Computable requirements:

- At least one shared pitch class between a “source-side chord” and a “target-side chord”.
- A generator that selects:
  - a source chord strongly establishing A, and
  - a target chord that can cadentially confirm B,
  - with at least one shared tone which you can label as the hinge.

Difficulty factors:

- Only one common tone (vs two or more) raises difficulty because voice-leading and perception of continuity are weaker. citeturn12view2turn13view0
- If the hinge requires enharmonic reinterpretation, raise difficulty. citeturn10view2turn10view3turn5view2

### Direct (phrase) modulation

Direct modulation is repeatedly defined as an abrupt change of key, often at phrase boundaries, with no pivot chord preparation. citeturn12view1turn12view2turn5view0  
Open Music Theory also frames “direct/phrase modulation” as moving from a chord in the old key directly to a chord in the new key without overlap. citeturn12view1

Computable requirements:

- None, beyond selecting a clear target-entry chord/progression (often tonic in new key).
- Optionally enforce “phrase boundary” in your exercise generator as a timing constraint (e.g., after N bars).

Difficulty factors:

- Without pivot material, success depends heavily on how clearly the player can *assert* the new tonic.
- In a practice tool, you can treat direct modulation difficulty as a function of `Δregion + Δtonic` and whether a confirming cadence is required. citeturn12view1turn5view0

### Sequential modulation

Sequential modulation is described as modulation achieved through repeating melodic/harmonic material at a new pitch level and using that sequence to establish or lead to the new key. citeturn5view0turn12view2

Computable requirements:

- A pattern (melodic/harmonic) that can be transposed and repeated.
- A target whose tonic is implied by the repetition at the new level.

Difficulty factors:

- The more transposition steps and the less “diatonic” the sequence remains, the harder it is to track. (In pedagogy, many sequential modulations are short and can resemble tonicisations.) citeturn5view0turn12view2

### Enharmonic reinterpretation (chromatic pivot)

Enharmonic reinterpretation is a classic “remote modulation” technique: approach a chord in one key, respell one or more notes, then resolve it to imply a different key. A common textbook example is interpreting V7 as German +6 or vice versa, which typically yields a modulation by semitone to a key a half-step away. citeturn10view3turn5view2turn4search26turn4search18

Computable requirements:

- A chord family that has enharmonic equivalences usable as pivots (e.g., dominant seventh ↔ German +6). citeturn10view3turn5view2turn4search30
- Resolution rules to the target dominant/tonic context.

Difficulty factors:

- High by default (requires conceptual respelling and non-diatonic handling). citeturn5view2turn10view3turn4search30

### Voice-leading-based proximity as an “advanced” edge generator

If you want to support late-Romantic / chromatic-mediant style challenges, entity["people","Richard Cohn","music theorist"]’s neo-Riemannian framing is extremely “computable”: transformations between major/minor triads preserve two common tones and move one note by semitone or tone (P/L/R operations). citeturn13view0turn3search6

Even if your app remains tonal, these operations can serve as **intermediate chord moves** that often underpin common-tone modulations and chromatic-mediant shifts (and Puget Sound explicitly ties common-tone modulation examples to chromatic mediant relationships). citeturn12view2turn13view0

image_group{"layout":"carousel","aspect_ratio":"16:9","query":["Tonnetz diagram neo-Riemannian PLR operations","chromatic mediant modulation example common tone diagram"]}

## A concrete difficulty-ranking framework

A practice tool needs stable tiers that feel musically sensible, but remain implementable. A robust approach is:

1. Compute **all applicable technique edges** from A→B.
2. Assign each edge a **directed cost**.
3. Define difficulty(A→B) as the **minimum cost** edge (or minimum-cost short path if you allow “one-step only” vs “multi-step allowed”).

This automatically handles **asymmetry**: if A→B has an easy pivot with predominant→predominant function but B→A does not, costs differ because the edge generator evaluates direction-specific harmonic roles. citeturn12view0turn10view1

### A recommended cost model (implementable and tunable)

This report proposes encoding each edge’s cost as a weighted sum of directly computable features:

- **Collection remoteness**: `wR * Δregion`  
  Motivated by the repeated emphasis that keys more than one accidental apart are harder to connect smoothly via pivots. citeturn10view6turn10view0

- **Pitch edits**: `wS * Δscale`  
  Grounded in the idea that adjacency on the fifths-organisation corresponds to minimal pitch change, and in practical set-difference computation (see tooling section for libraries that already compute symmetric differences). citeturn11view3turn16view0

- **Tonic shift**: `wT * Δtonic`  
  Required because relative-key shifts would otherwise be “free” under pitch-set distance. citeturn19view0turn11view0

- **Mode shift**: `wM * Δmode`  
  Grounded in “colour-note” framing of modes. citeturn10view4

- **Technique complexity penalty**:  
  - diatonic pivot: +0  
  - mixture-assisted pivot: +`kMix` (chromatic borrowing) citeturn10view6turn10view5  
  - common-tone: +`kCT` (hinge-note reasoning) citeturn10view2turn12view2  
  - enharmonic reinterpretation: +`kEnh` (respelling + remote pivoting) citeturn5view2turn10view3  
  - direct: +`kDir` (no overlap support) citeturn12view1turn5view0

- **Pivot availability bonus (subtract cost)**:  
  Subtract a bonus proportional to:
  - number of candidate pivot chords, and
  - quality of best pivot match (predominant→predominant biggest bonus). citeturn12view0turn10view1

- **Target confirmation requirement**:  
  Add cost if the exercise requires “confirm with cadence”. This is justified by the cadence-based definition of modulation vs tonicisation. citeturn12view1turn5view0turn12view0

### Difficulty tiers that map well to practice UX

Below is a tier scheme that Claude Code can implement directly (using the edge-cost approach, you can map cost ranges to tiers):

- **Tier A (very easy)**: same tonic, 1 colour-note edit (parallel modal shift); or same collection, small tonic shift with no cadence requirement. citeturn10view4turn19view0  
- **Tier B (easy)**: closely related collections (Δregion=1) with a diatonic pivot chord available and at least one “good” pivot function match. citeturn10view0turn12view0turn10view1  
- **Tier C (moderate)**: relative/parallel key changes that require cadence confirmation; or Δregion=2 with strong pivot availability. citeturn19view0turn12view1turn10view6  
- **Tier D (hard)**: distant keys (more than one accidental apart) requiring mixture-assisted pivots or common-tone strategies. citeturn10view6turn10view2  
- **Tier E (expert)**: enharmonic reinterpretation pivots and/or chromatic-mediant networks where tonal function is less explicit (e.g., neo-Riemannian/voice-leading driven challenges). citeturn5view2turn13view0turn12view2

## Modal modulation in the same framework

A key design question is whether modes should be “special-cased.” A practical answer is: **no separate system is required**, but you must distinguish two different musical tasks:

- **Modal shift** (change scale colour while keeping tonic stable)  
- **Tonic shift** (change tonal centre, possibly with or without a mode change)

The reason is simple and implementable: two destinations can have the same pitch-set distance yet differ in perceived difficulty because tonic stability changes what the player must *prove*. The pitch-set distance between G Ionian → G Mixolydian is 1 (lowered 7), and G Ionian → C Ionian is also 1 (one accidental difference) because these collections are adjacent on the circle of fifths. citeturn2search6turn10view4  
But only the second case demands a tonic migration (G→C). Your engine should therefore treat **tonic distance** and **cadence/confirmation requirement** as first-class difficulty drivers. citeturn12view1turn5view0

### Implementation-friendly modal points

- Modes can be encoded as interval sets; for instance, entity["organization","AudioKit","audio software org"]’s Tonic library defines Dorian, Mixolydian, Phrygian, and Lydian explicitly via interval recipes, and defines major as Ionian and minor as Aeolian. citeturn18view0turn18view2  
- A mode’s “colour note” count is computable and maps cleanly to beginner-to-advanced tiers. citeturn10view4  
- Mode mixture (borrowing from the parallel major/minor) is explicitly described as changing chord quality/colour without necessarily changing function, and is treated as a bridge to chromaticism and even modulation. citeturn10view5turn10view6

### Modal cadential logic (for “confirm the new centre” exercises)

Because modulation is commonly defined as being confirmed by cadential behaviour, you’ll need “cadence templates” not only for major/minor but also for modes if your app expects users to demonstrate the new mode as a tonal centre. citeturn12view1turn12view0turn5view0

This report proposes modelling **cadence support** per mode as a set of allowable “confirmation patterns,” where:

- Ionian / Lydian (major-ish with leading tone) can support classical dominant-style confirmation more directly. citeturn10view4  
- Aeolian (natural minor) lacks raised leading tone by default; if you require a strong V–i leading-tone cadence, allow mixture/alteration (harmonic minor behaviour). citeturn10view4turn10view5  
- Other modes may be confirmed by characteristic modal progressions rather than strict V–I logic; represent these as separate templates and treat them as a different (often lower-level) “modal shift” exercise type rather than a full tonal modulation.

The key for implementation is that **mode-to-mode routing can still use the same graph and cost framework**, as long as “confirmation type” is part of the edge definition (major/minor cadence vs modal confirmation vs “scale-only switch”).

## Modulation pathfinding for multi-step routes

For distant targets, a single-step modulation may be pedagogically unhelpful. A pathfinding system turns “too distant” into a sequence of manageable sub-problems.

### Why graph search fits the theory

Several sources point in the same direction:

- Closely related keys are explicitly enumerated and treated as the most common/easiest modulatory destinations. citeturn10view0turn19view0turn1search4  
- When keys are more than one accidental apart, smooth pivoting is harder and chromatic resources (mixture) are often invoked—suggesting that “remote” modulations often benefit from intermediate steps. citeturn10view6turn5view0  
- Modulation is commonly treated as “establish new key with cadence,” which implies each intermediate node in a path should be *confirmable* (at least by a lightweight cadence template) if your exercise requires it. citeturn12view1turn5view0turn12view0

### A directed modulation graph model

This report proposes:

- **Node**: `(tonicPitchClass, modeType)` plus cached `pitchSetBitset`, `diatonicCollectionId`, `keySignatureCoordinate`, `diatonicChordSet`.
- **Directed edge**: a technique-specific modulation step with:
  - `sourceNode`, `targetNode`
  - `techniqueType` (pivot, mixture-pivot, common-tone, direct, sequential, enharmonic)
  - `evidence` (pivot chord(s), hinge tone, suggested cadence template)
  - `cost` (computed as in the difficulty framework)

Once you have edges, run Dijkstra (or A*) to find:

- the lowest-cost path (best suggested route),
- plus k-alternatives (for hint variety).

Asymmetry emerges naturally because “best pivot roles” are directional (predominant→predominant is evaluated in the A→B direction). citeturn12view0turn10view1

### Heuristics for “better” intermediate paths

To make results musically plausible (and not just mathematically short), add constraints/heuristics grounded in pedagogy:

- Prefer paths where each step is to a **closely related** key/collection (Δregion ≤ 1) unless the user is explicitly in advanced tiers. citeturn10view0turn19view0turn10view6  
- Prefer edges that have more pivot options and better functional alignment (predominant→predominant). citeturn12view0turn10view1  
- Penalise repeated “direct modulation” steps early, because direct modulation is explicitly framed as lacking preparation and is often treated as abrupt. citeturn12view1turn5view0  
- Allow “sequence edges” as a special case when a sequence-based exercise is desired; sequential modulation is explicitly described as establishing the new key by repetition at a new level. citeturn5view0turn12view2

## Library and tooling landscape for Swift implementation

The most important question for implementation is not “does a library know what modulation is?” (most don’t), but: **does it already encode the primitives** your engine needs (notes, scales/modes, chords, pitch sets, intersections, key signature logic), so you can spend your time on the modulation graph and difficulty logic.

### Swift-first options

**entity["organization","AudioKit Tonic","swift music theory library"]** is notable because it explicitly supports *set operations that mirror your distance-metric needs*. The README shows:

- how to query chords in a key (`Key.Cm.chords`),
- filter chords by contained note classes,
- compute common notes via set intersection,
- compute “note difference” via symmetric difference,
- and it states it uses bit sets for pitch/note sets (performance + easy distance). citeturn16view0  
Tonic also defines a circle-of-fifths list in code and includes modal scales defined by interval patterns (Dorian, Mixolydian, Phrygian, Lydian, etc.). citeturn15search21turn18view0turn18view2turn8view0

The **cemolcay/MusicTheory** package provides enums for `Key`, `Pitch`, `Interval`, `Scale`, and `Chord`, but its last release is older (and the repository is less recently active per Swift Package Index metadata). citeturn6view0turn15search15  
It may still be useful as a reference, but for an actively maintained SwiftUI app, you’ll likely prefer the more recently updated Tonic package. citeturn8view0turn6view0

**CorvidLabs/swift-music** positions itself as a comprehensive Swift package covering notes, scales, chords, progressions, rhythm, and MIDI, but it is explicitly “pre-1.0” with an API that may change. citeturn6view1turn15search8  
If your app needs MIDI parsing/encoding alongside theory primitives, pairing its MIDI tooling with a stable theory core could make sense. citeturn6view1

**fwcd/swift-music-theory** is a minimal pure-Swift library for notes, scales, chords, intervals and progressions. citeturn6view2turn15search1  
It looks suitable as a lightweight dependency, but its scope is smaller than Tonic’s chord/key convenience features. citeturn6view2turn16view0

### Cross-language references worth porting

If you want proven data structures and analysis concepts to port into Swift:

- **music21 (Python)** provides mature representations for keys, key signatures, scales, chords, and Roman-numeral analysis objects (storing function and scale degree within a key). citeturn9view0turn6view4turn6view5turn14search5turn14search1  
- **tonal (JavaScript/TypeScript)** is explicitly a music-theory abstraction library that manipulates notes, intervals, chords, scales, modes, and keys in a pure-functional style—useful as a conceptual model for immutable structures and cached lookups. citeturn14search0turn14search8turn14search20  
- **mingus (Python)** provides core modules for keys/diatonic scales, chords, and progressions. citeturn14search2turn14search18turn14search34

### Recommendation: build vs leverage

For the specific goal of a modulation engine, the key observation is: libraries tend to provide **primitives** (keys/scales/chords/sets), while the “rules of modulation difficulty” and “pathfinding” are application logic.

This report recommends:

- **Leverage** Tonic (or a similar Swift theory library) for:
  - pitch-class and note spelling,
  - modal scale definitions,
  - chord-generation-in-key,
  - set intersection/symmetric difference,
  - circle-of-fifths/key-signature scaffolding. citeturn16view0turn18view0turn15search21turn8view0  
- **Implement from scratch** (app-specific):
  - technique edge generators (pivot/mixture/common-tone/direct/sequence/enharmonic),
  - directed cost function and tier mapping,
  - Dijkstra/A* modulation pathfinding,
  - hint generation (top-k pivots/routes).

That division of labour aligns with how modulation is described pedagogically (as technique selection + cadence confirmation), and it matches the fact that open libraries rarely encode “difficulty tiers” as a first-class concept. citeturn12view0turn12view1turn10view6

## Selected short quotations for implementation reference

> “The principal difference between tonicization and modulation is the presence or absence of a cadence…” citeturn12view1

> “Closely related keys have key signatures one degree ‘sharper’ or ‘flatter’…” citeturn10view0

> “These distances produce a toroidal map of key relations generated by… the circle of fifths and the relative and parallel major-minor key relations…” citeturn11view0

> “Tonic uses bit sets to represent pitch sets and note sets.” citeturn16view0