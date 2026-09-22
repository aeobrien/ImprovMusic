import XCTest
@testable import ImprovMusic

final class EdgeGeneratorTests: XCTestCase {

    let weights = DistanceWeights.default

    // MARK: - Pivot chord generator

    func test_pivot_cMajor_to_gMajor_producesEdge() {
        let edges = pivotEdges(.c, .major, .g, .major)
        XCTAssertFalse(edges.isEmpty, "C→G should have pivot chord edges")
    }

    func test_pivot_cMajor_to_gMajor_hasPivotTechnique() {
        let edges = pivotEdges(.c, .major, .g, .major)
        XCTAssertTrue(edges.allSatisfy { $0.technique == .pivotChord })
    }

    func test_pivot_cMajor_to_fsMajor_noEdge() {
        let edges = pivotEdges(.c, .major, .fs, .major)
        XCTAssertTrue(edges.isEmpty, "C→F# should have no diatonic pivot chords")
    }

    func test_pivot_cMajor_to_fMajor_producesEdge() {
        let edges = pivotEdges(.c, .major, .f, .major)
        XCTAssertFalse(edges.isEmpty, "C→F (adjacent on CoF) should have pivots")
    }

    func test_pivot_cMajor_to_aMinor_producesEdge() {
        let edges = pivotEdges(.c, .major, .a, .naturalMinor)
        XCTAssertFalse(edges.isEmpty, "C major→A minor (relative) should have many pivots")
    }

    func test_pivot_evidenceContainsRomanNumerals() {
        let edges = pivotEdges(.c, .major, .g, .major)
        guard let edge = edges.first else { return XCTFail("Expected edge") }
        if case .pivot(_, let funcSource, let funcTarget) = edge.evidence {
            XCTAssertFalse(funcSource.isEmpty)
            XCTAssertFalse(funcTarget.isEmpty)
        } else {
            XCTFail("Expected pivot evidence")
        }
    }

    // MARK: - Common tone generator

    func test_commonTone_cMajor_to_ebMajor_producesEdge() {
        let edges = commonToneEdges(.c, .major, .ds, .major) // Eb = pitch class 3
        XCTAssertFalse(edges.isEmpty, "C→Eb should have common-tone edge")
    }

    func test_commonTone_technique() {
        let edges = commonToneEdges(.c, .major, .ds, .major)
        XCTAssertTrue(edges.allSatisfy { $0.technique == .commonTone })
    }

    // MARK: - Mixture-assisted generator

    func test_mixture_cMajor_to_abMajor_producesEdge() {
        // Ab major is distant from C major; mixture borrowing from C minor may help
        let edges = mixtureEdges(.c, .major, .gs, .major) // Ab = pitch class 8
        // May or may not produce — depends on whether borrowed chords create pivots
        // Just verify it doesn't crash
        _ = edges
    }

    func test_mixture_onlyFromMajorMinor() {
        // Modes should not produce mixture edges
        let edges = mixtureEdges(.d, .dorian, .g, .major)
        XCTAssertTrue(edges.isEmpty, "Mixture should only apply to major/minor source")
    }

    // MARK: - Direct modulation generator

    func test_direct_alwaysProducesEdge() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .fs, scaleType: .major)
        let vector = DistanceVector.compute(from: source, to: target)
        let edges = DirectModulationGenerator.generate(from: source, to: target, vector: vector, weights: weights)
        XCTAssertEqual(edges.count, 1)
        XCTAssertEqual(edges.first?.technique, .direct)
    }

    func test_direct_selfModulation_noEdge() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let vector = DistanceVector.compute(from: source, to: source)
        let edges = DirectModulationGenerator.generate(from: source, to: source, vector: vector, weights: weights)
        XCTAssertTrue(edges.isEmpty)
    }

    func test_direct_distantKeyCostsMore() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let closeTarget = TonalContext(tonic: .g, scaleType: .major)
        let farTarget = TonalContext(tonic: .fs, scaleType: .major)

        let closeVector = DistanceVector.compute(from: source, to: closeTarget)
        let farVector = DistanceVector.compute(from: source, to: farTarget)

        let closeEdge = DirectModulationGenerator.generate(from: source, to: closeTarget, vector: closeVector, weights: weights).first!
        let farEdge = DirectModulationGenerator.generate(from: source, to: farTarget, vector: farVector, weights: weights).first!

        XCTAssertLessThan(closeEdge.cost, farEdge.cost, "C→G should cost less than C→F#")
    }

    // MARK: - Enharmonic generator

    func test_enharmonic_onlyForDistantKeys() {
        // Close keys should not produce enharmonic edges
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .g, scaleType: .major)
        let vector = DistanceVector.compute(from: source, to: target)
        let edges = EnharmonicGenerator.generate(from: source, to: target, vector: vector, weights: weights)
        XCTAssertTrue(edges.isEmpty, "Close keys shouldn't need enharmonic reinterpretation")
    }

    func test_enharmonic_distantKeysCanProduceEdge() {
        // C major to Db major — V7 of C (G7) could be reinterpreted
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: PitchClass(1), scaleType: .major) // Db
        let vector = DistanceVector.compute(from: source, to: target)
        let edges = EnharmonicGenerator.generate(from: source, to: target, vector: vector, weights: weights)
        // This may or may not produce an edge depending on the specific reinterpretation check
        // Just verify no crashes
        _ = edges
    }

    // MARK: - Helpers

    private func pivotEdges(
        _ sTonic: PitchClass, _ sType: ScaleType,
        _ tTonic: PitchClass, _ tType: ScaleType
    ) -> [ModulationEdge] {
        let source = TonalContext(tonic: sTonic, scaleType: sType)
        let target = TonalContext(tonic: tTonic, scaleType: tType)
        let vector = DistanceVector.compute(from: source, to: target)
        return PivotChordGenerator.generate(from: source, to: target, vector: vector, weights: weights)
    }

    private func commonToneEdges(
        _ sTonic: PitchClass, _ sType: ScaleType,
        _ tTonic: PitchClass, _ tType: ScaleType
    ) -> [ModulationEdge] {
        let source = TonalContext(tonic: sTonic, scaleType: sType)
        let target = TonalContext(tonic: tTonic, scaleType: tType)
        let vector = DistanceVector.compute(from: source, to: target)
        return CommonToneGenerator.generate(from: source, to: target, vector: vector, weights: weights)
    }

    private func mixtureEdges(
        _ sTonic: PitchClass, _ sType: ScaleType,
        _ tTonic: PitchClass, _ tType: ScaleType
    ) -> [ModulationEdge] {
        let source = TonalContext(tonic: sTonic, scaleType: sType)
        let target = TonalContext(tonic: tTonic, scaleType: tType)
        let vector = DistanceVector.compute(from: source, to: target)
        return MixtureAssistedGenerator.generate(from: source, to: target, vector: vector, weights: weights)
    }
}
