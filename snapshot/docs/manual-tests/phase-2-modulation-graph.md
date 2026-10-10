# Phase 2 Manual Test Brief — Modulation Graph

## Status
Pure logic phase — validated entirely by unit tests.

## Test Coverage (49 tests)

### DistanceVectorTests (14 tests)
- Scale distance, region distance, tonic distance, mode distance
- Common chord counts (close vs distant keys)
- Cadence support (leading tone, major dominant)

### EdgeGeneratorTests (15 tests)
- Pivot chord: generates for close keys, absent for distant keys, evidence has Roman numerals
- Common tone: generates for moderately distant keys
- Mixture-assisted: only from major/minor source contexts
- Direct: always generates, costs more for distant keys, no self-modulation
- Enharmonic: only for distant keys (region distance >= 3)

### ModulationGraphTests (20 tests)
- Graph structure: 72 nodes, all nodes have outgoing edges, positive costs, no self-edges
- Known relationships validated:
  - C→G: has pivot edge, pivot cheaper than direct
  - C→F#: has direct edge, no pivot edge, costs more than C→G
  - C→Am: zero scale distance, has pivot edge
  - C→C Mixolydian: mode distance 1, has edges
- Cost ordering: adjacent < moderate < distant
- Multiple technique types between same pair
- Asymmetry exists (forward/backward costs can differ)
- Precomputation completes in under 2 seconds (measured: ~0.73s)

## Graph Statistics
- 72 nodes (12 tonics × 6 scale types)
- Graph builds in ~0.73 seconds
- Every node has outgoing edges
- Multiple technique types present (pivot, common-tone, direct, mixture, enharmonic)
