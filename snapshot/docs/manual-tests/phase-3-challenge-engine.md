# Phase 3 Manual Test Brief — Challenge Engine

## Status
Pure logic phase — validated entirely by unit tests.

## Test Coverage (40 new tests, 186 total)

### DifficultyTierTests (12 tests)
- Tier 1: modal shifts (C→C Mixolydian, C→C Lydian, Am→A Dorian, Am→A Phrygian)
- Tier 2: closely related (C→G, C→F, C→Am relative, G→Em relative)
- Tier 3: moderate (C→Cm parallel, C→D)
- Tier 5: remote (C→F# via direct edge)
- Tier ordering verified

### PathfinderTests (9 tests)
- Shortest path: single step for close keys, exists for distant keys, ends at target, positive cost
- K-shortest paths: returns multiple paths, first path exists
- Diverse hint paths: returns paths, all reach target
- Hint steps contain technique and evidence

### ChallengeEngineTests (19 tests)
- Initial state: C major, no challenge
- Challenge generation: produces challenge, target differs from current, has hints
- Arrival/advancement: second challenge advances to previous target, third continues
- Tier filtering: tier 1 produces challenges (with fallback), tier 2 works, tier 5 works
- Sparse pool fallback: still produces challenges from limited contexts
- Recently-visited avoidance: 10 generations produce variety
- Set context: changes context, clears challenge
- Randomise: changes context
- Timer mode: default manual, switch to timer, switch back

## Engine Capabilities
- Rule-based tier assignment (5 tiers)
- Challenge generation with tier filtering
- Auto-advancement (current key → previous target on new challenge)
- Sparse pool fallback (widens tier if < 3 candidates)
- Recently-visited avoidance (rolling buffer of 5)
- Dijkstra shortest path + k-shortest alternative paths
- Technique-diverse hint selection
- Timer mode with configurable interval
