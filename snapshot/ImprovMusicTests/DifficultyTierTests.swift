import XCTest
@testable import ImprovMusic

final class DifficultyTierTests: XCTestCase {

    let weights = DistanceWeights.default

    // MARK: - Tier 1: Modal shift

    func test_tier1_cMajor_to_cMixolydian() {
        let tier = assignTier(.c, .major, .c, .mixolydian)
        XCTAssertEqual(tier, .modalShift)
    }

    func test_tier1_cMajor_to_cLydian() {
        let tier = assignTier(.c, .major, .c, .lydian)
        XCTAssertEqual(tier, .modalShift)
    }

    func test_tier1_aMinor_to_aDorian() {
        let tier = assignTier(.a, .naturalMinor, .a, .dorian)
        XCTAssertEqual(tier, .modalShift)
    }

    func test_tier1_aMinor_to_aPhrygian() {
        let tier = assignTier(.a, .naturalMinor, .a, .phrygian)
        XCTAssertEqual(tier, .modalShift)
    }

    // MARK: - Tier 2: Closely related

    func test_tier2_cMajor_to_gMajor() {
        let tier = assignTier(.c, .major, .g, .major)
        XCTAssertEqual(tier, .closelyRelated)
    }

    func test_tier2_cMajor_to_fMajor() {
        let tier = assignTier(.c, .major, .f, .major)
        XCTAssertEqual(tier, .closelyRelated)
    }

    func test_tier2_cMajor_to_aMinor_relative() {
        let tier = assignTier(.c, .major, .a, .naturalMinor)
        XCTAssertEqual(tier, .closelyRelated)
    }

    func test_tier2_gMajor_to_eMinor_relative() {
        let tier = assignTier(.g, .major, .e, .naturalMinor)
        XCTAssertEqual(tier, .closelyRelated)
    }

    // MARK: - Tier 3: Moderate

    func test_tier3_cMajor_to_cMinor_parallel() {
        let tier = assignTier(.c, .major, .c, .naturalMinor)
        XCTAssertEqual(tier, .moderate)
    }

    func test_tier3_cMajor_to_dMajor() {
        let tier = assignTier(.c, .major, .d, .major)
        XCTAssertEqual(tier, .moderate)
    }

    // MARK: - Tier 5: Remote

    func test_tier5_cMajor_to_fsMajor() {
        // F# major is maximally distant on the circle of fifths
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .fs, scaleType: .major)
        let edges = buildGraph().edges(from: source, to: target)
        // At least the direct edge should be tier 5 (region distance = 6)
        let directEdge = edges.first { $0.technique == .direct }!
        let vector = DistanceVector.compute(from: source, to: target)
        let tier = DifficultyTier.assign(for: directEdge, vector: vector)
        XCTAssertEqual(tier, .remote)
    }

    // MARK: - Tier ordering

    func test_tiers_areOrdered() {
        XCTAssertLessThan(DifficultyTier.modalShift, .closelyRelated)
        XCTAssertLessThan(DifficultyTier.closelyRelated, .moderate)
        XCTAssertLessThan(DifficultyTier.moderate, .distant)
        XCTAssertLessThan(DifficultyTier.distant, .remote)
    }

    // MARK: - Helpers

    private func assignTier(
        _ sTonic: PitchClass, _ sType: ScaleType,
        _ tTonic: PitchClass, _ tType: ScaleType
    ) -> DifficultyTier {
        let source = TonalContext(tonic: sTonic, scaleType: sType)
        let target = TonalContext(tonic: tTonic, scaleType: tType)
        let vector = DistanceVector.compute(from: source, to: target)
        // Use the cheapest edge for tier assignment
        let graph = buildGraph()
        let edges = graph.edges(from: source, to: target)
        guard let bestEdge = edges.min(by: { $0.cost < $1.cost }) else {
            XCTFail("No edge from \(source.displayName) to \(target.displayName)")
            return .remote
        }
        return DifficultyTier.assign(for: bestEdge, vector: vector)
    }

    private static var _cachedGraph: ModulationGraph?
    private func buildGraph() -> ModulationGraph {
        if Self._cachedGraph == nil {
            Self._cachedGraph = GraphBuilder.build()
        }
        return Self._cachedGraph!
    }
}
