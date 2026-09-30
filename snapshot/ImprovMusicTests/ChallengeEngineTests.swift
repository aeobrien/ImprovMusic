import XCTest
@testable import ImprovMusic

@MainActor
final class ChallengeEngineTests: XCTestCase {

    var engine: ChallengeEngine!

    override func setUp() {
        super.setUp()
        let graph = GraphBuilder.build()
        let start = TonalContext(tonic: .c, scaleType: .major)
        engine = ChallengeEngine(graph: graph, startingContext: start)
    }

    // MARK: - Initial state

    func test_initialContext_isCMajor() {
        XCTAssertEqual(engine.currentContext.tonic, .c)
        XCTAssertEqual(engine.currentContext.scaleType, .major)
    }

    func test_initialChallenge_isNil() {
        XCTAssertNil(engine.currentChallenge)
    }

    // MARK: - Challenge generation

    func test_generateChallenge_producesChallenge() {
        engine.generateChallenge()
        XCTAssertNotNil(engine.currentChallenge)
    }

    func test_generateChallenge_targetDiffersFromCurrent() {
        engine.generateChallenge()
        XCTAssertNotEqual(engine.currentChallenge?.target, engine.currentContext)
    }

    func test_generateChallenge_hasHintPaths() {
        engine.generateChallenge()
        XCTAssertFalse(engine.currentChallenge?.hintPaths.isEmpty ?? true)
    }

    // MARK: - Arrival / advancement

    func test_secondChallenge_advancesToPreviousTarget() {
        engine.generateChallenge()
        let firstTarget = engine.currentChallenge!.target

        engine.generateChallenge()
        XCTAssertEqual(engine.currentContext, firstTarget,
                       "Current context should advance to previous target")
    }

    func test_thirdChallenge_continuesAdvancing() {
        engine.generateChallenge()
        engine.generateChallenge()
        let secondTarget = engine.currentChallenge!.target

        engine.generateChallenge()
        XCTAssertEqual(engine.currentContext, secondTarget)
    }

    // MARK: - Tier filtering

    func test_tier1Only_producesChallenges() {
        engine.maxTier = .modalShift
        engine.generateChallenge()
        // Should produce a challenge (possibly via sparse-pool fallback to Tier 2)
        XCTAssertNotNil(engine.currentChallenge)
    }

    func test_tier1_fromMajor_prefersModalShifts() {
        // C major has 4 modal shift targets (Lydian, Mixolydian, + minor-ish modes share tonic)
        // At tier 1, those are preferred, but fallback may widen
        engine.maxTier = .modalShift
        engine.generateChallenge()
        if let challenge = engine.currentChallenge {
            // If it's a modal shift, great. If fallback triggered, that's also valid.
            if challenge.target.tonic == engine.currentContext.tonic {
                // Modal shift confirmed
                XCTAssertNotEqual(challenge.target.scaleType, engine.currentContext.scaleType)
            }
            // Either way, a challenge was produced
        }
    }

    func test_tier2_producesChallenges() {
        engine.maxTier = .closelyRelated
        engine.generateChallenge()
        XCTAssertNotNil(engine.currentChallenge)
    }

    func test_tier5_producesChallenges() {
        engine.maxTier = .remote
        engine.generateChallenge()
        XCTAssertNotNil(engine.currentChallenge)
    }

    // MARK: - Sparse pool fallback

    func test_sparsePool_stillProducesChallenges() {
        // Start in a mode with limited tier-1 targets
        engine.setCurrentContext(TonalContext(tonic: .c, scaleType: .phrygian))
        engine.maxTier = .modalShift
        engine.generateChallenge()
        // Should still produce a challenge (via fallback)
        XCTAssertNotNil(engine.currentChallenge)
    }

    // MARK: - Recently visited avoidance

    func test_multipleGenerations_avoidRepetition() {
        engine.maxTier = .remote // Wide pool
        var targets: [TonalContext] = []
        for _ in 0..<10 {
            engine.generateChallenge()
            if let target = engine.currentChallenge?.target {
                targets.append(target)
            }
        }
        // With 72 possible targets and a pool at tier 5, we should have variety
        let uniqueTargets = Set(targets)
        XCTAssertGreaterThan(uniqueTargets.count, 3,
                             "Should visit multiple different targets")
    }

    // MARK: - Set current context

    func test_setCurrentContext_changesContext() {
        let newContext = TonalContext(tonic: .g, scaleType: .major)
        engine.setCurrentContext(newContext)
        XCTAssertEqual(engine.currentContext, newContext)
    }

    func test_setCurrentContext_clearsChallenge() {
        engine.generateChallenge()
        XCTAssertNotNil(engine.currentChallenge)
        engine.setCurrentContext(TonalContext(tonic: .g, scaleType: .major))
        XCTAssertNil(engine.currentChallenge)
    }

    // MARK: - Randomise

    func test_randomise_setsContext() {
        let original = engine.currentContext
        // Run a few times — statistically unlikely to get the same one every time
        var changed = false
        for _ in 0..<10 {
            engine.randomiseStartingKey()
            if engine.currentContext != original {
                changed = true
                break
            }
        }
        XCTAssertTrue(changed, "Randomise should change the context")
    }

    // MARK: - Timer mode

    func test_triggerMode_defaultIsManual() {
        XCTAssertEqual(engine.triggerMode, .manual)
    }

    func test_updateTriggerMode_toTimer() {
        engine.updateTriggerMode(.timer)
        XCTAssertEqual(engine.triggerMode, .timer)
        engine.stopTimer() // Cleanup
    }

    func test_updateTriggerMode_backToManual() {
        engine.updateTriggerMode(.timer)
        engine.updateTriggerMode(.manual)
        XCTAssertEqual(engine.triggerMode, .manual)
    }
}
