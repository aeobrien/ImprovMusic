# Phase 1 Manual Test Brief — Music Theory Primitives

## Prerequisites
- Xcode 16.3 installed
- Project open: `open ImprovMusic.xcodeproj`

## Tests

### 1. App launches on iPhone simulator
1. Select "iPhone 16 Pro" as the run destination
2. Press Cmd+R to build and run
3. **Expected:** App launches in landscape orientation displaying "ImprovMusic" and "Modulation Practice Companion"
4. **Pass criteria:** Landscape only, no portrait rotation, text legible

### 3. Unit tests pass
1. Press Cmd+U to run all tests
2. **Expected:** All 97 tests pass (PitchClassTests: 20, ScaleTypeTests: 27, TonalContextTests: 23, ChordTests: 27)
3. **Pass criteria:** 0 failures
