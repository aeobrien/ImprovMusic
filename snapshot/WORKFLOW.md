# ImprovMusic — Development Workflow

## Module Development Cycle

Every phase follows this exact cycle:

### 1. Build
- Create branch `phase-N/name`
- Implement all sub-modules
- Follow conventions in CLAUDE.md

### 2. Auto-Test
- Write unit tests for all new public API
- Run tests: `xcodebuild test` or `swift test`
- All tests must pass before proceeding

### 3. Integrate
- Build the full app: `xcodebuild -scheme ImprovMusic build`
- Run on simulator or device to verify no integration issues
- Fix any build or runtime errors

### 4. Manual Test Brief
- Write test brief at `docs/manual-tests/phase-N-name.md`
- Include: prerequisites, step-by-step instructions, expected outcomes, pass criteria
- User performs manual testing on device (iPhone on piano stand preferred) and provides feedback

### 5. Commit
- Only after both auto-tests and manual tests pass
- Commit message: `Phase N: [what this phase delivers]`
- Update session log at `docs/session-log.md`

---

## Phase-Specific Workflow Variations

### Phase 1 (Project Setup + Music Theory Primitives)
The first phase includes Xcode project creation, so the cycle is adjusted:
- **Build:** Create Xcode project, add Tonic dependency, implement data model types
- **Auto-Test:** Write tests for all music theory primitives (scales, chords, pitch class sets)
- **Integrate:** App builds and launches (may show placeholder UI)
- **Manual Test:** "App launches in landscape on iPhone simulator" — no functional UI to test yet
- **Commit:** Commit the full project scaffold + data model + tests

### Phase 2 (Modulation Graph)
No UI changes. The cycle focuses on the graph:
- **Build:** Implement edge generators and graph precomputation
- **Auto-Test:** Extensive tests validating known modulation relationships
- **Integrate:** Graph precomputes without errors; app still builds
- **Manual Test:** N/A — pure logic, validated by unit tests. Manual test brief documents test coverage instead.
- **Commit:** Commit graph implementation + tests

### Phase 3 (Engine)
No UI changes. The cycle focuses on challenge generation:
- **Build:** Implement engine logic (tiers, challenges, pathfinding, hints)
- **Auto-Test:** Tests for tier assignment, challenge generation, pathfinding, hint diversity
- **Integrate:** Engine runs correctly when invoked programmatically; app still builds
- **Manual Test:** N/A — engine logic, validated by unit tests
- **Commit:** Commit engine + tests

### Phases 4-5 (UI + Calibration)
Full 5-step cycle applies. Manual testing is substantive — the app is used on a real device at a piano.

---

## Debugging Protocol

When a build or test fails:

1. Read the full error message
2. Identify the root cause (don't guess)
3. Fix the cause, not the symptom
4. Re-run the specific failing test
5. Re-run the full test suite
6. Re-build the app
7. Only proceed when everything passes

---

## Music Theory Validation Protocol

The music theory layer is the foundation of the app. Errors here propagate everywhere. When implementing or modifying music theory logic:

1. **Cross-reference against research reports** — the two research documents are the authoritative source for modulation rules, distance metrics, and difficulty ranking
2. **Validate against known facts** — e.g., C major scale = {0, 2, 4, 5, 7, 9, 11}, C major to G major should have abundant pivot chords, relative keys share pitch sets
3. **Check enharmonic correctness** — verify that spelling preferences produce conventional key names, not theoretical absurdities
4. **Test edge cases** — modal contexts, distant modulations, keys with many accidentals, boundaries between difficulty tiers

---

## Swift / Xcode Notes

### SwiftUI
- Use `@State`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject` appropriately
- Keep views lightweight — business logic belongs in the engine layer, not in views
- Use `PreviewProvider` for UI development in Xcode previews

### Testing
- XCTest is the primary test framework
- Test files go in the test target, mirroring the source structure
- Use `XCTAssertEqual`, `XCTAssertTrue`, etc. for assertions
- For floating-point comparisons (distance calculations), use `XCTAssertEqual(a, b, accuracy: 0.001)`

### Swift Package Manager
- Tonic (and any other dependencies) are managed via SPM
- Add packages via Xcode: File > Add Package Dependencies
- Or edit `Package.swift` / the project's package dependencies directly

### Device Testing
- Test device: iPhone (landscape, music stand distance)
- Simulator is fine for most testing; real device preferred for readability assessment
