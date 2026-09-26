import XCTest
@testable import ImprovMusic

final class ModulationGraphTests: XCTestCase {

    // Shared graph — built once for all tests
    static var graph: ModulationGraph!

    override class func setUp() {
        super.setUp()
        graph = GraphBuilder.build()
    }

    var graph: ModulationGraph { Self.graph }

    // MARK: - Graph structure

    func test_graph_has72Nodes() {
        XCTAssertEqual(graph.nodes.count, 72)
    }

    func test_graph_hasEdges() {
        XCTAssertGreaterThan(graph.edgeCount, 0, "Graph should have edges")
    }

    func test_graph_everyNodeHasOutgoingEdges() {
        for node in graph.nodes {
            let edges = graph.edges(from: node)
            XCTAssertGreaterThan(edges.count, 0,
                                 "\(node.displayName) should have at least one outgoing edge")
        }
    }

    // MARK: - Known relationships: C major → G major

    func test_cToG_hasPivotEdge() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let g = TonalContext(tonic: .g, scaleType: .major)
        let edges = graph.edges(from: c, to: g)
        let hasPivot = edges.contains { $0.technique == .pivotChord }
        XCTAssertTrue(hasPivot, "C→G should have a pivot chord edge")
    }

    func test_cToG_pivotCheaperThanDirect() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let g = TonalContext(tonic: .g, scaleType: .major)
        let edges = graph.edges(from: c, to: g)
        let pivot = edges.first { $0.technique == .pivotChord }
        let direct = edges.first { $0.technique == .direct }
        guard let p = pivot, let d = direct else { return XCTFail("Expected both edge types") }
        XCTAssertLessThan(p.cost, d.cost, "Pivot should be cheaper than direct for close keys")
    }

    // MARK: - Known relationships: C major → F# major (distant)

    func test_cToFs_hasDirectEdge() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let fs = TonalContext(tonic: .fs, scaleType: .major)
        let edges = graph.edges(from: c, to: fs)
        let hasDirect = edges.contains { $0.technique == .direct }
        XCTAssertTrue(hasDirect, "C→F# should have a direct modulation edge")
    }

    func test_cToFs_noPivotEdge() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let fs = TonalContext(tonic: .fs, scaleType: .major)
        let edges = graph.edges(from: c, to: fs)
        let hasPivot = edges.contains { $0.technique == .pivotChord }
        XCTAssertFalse(hasPivot, "C→F# should have no diatonic pivot chords")
    }

    func test_cToFs_costHigherThanCToG() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let g = TonalContext(tonic: .g, scaleType: .major)
        let fs = TonalContext(tonic: .fs, scaleType: .major)

        let cgCost = graph.cheapestEdge(from: c, to: g)!.cost
        let cfsCost = graph.cheapestEdge(from: c, to: fs)!.cost
        XCTAssertLessThan(cgCost, cfsCost, "C→G should be cheaper than C→F#")
    }

    // MARK: - Known relationships: C major → A minor (relative)

    func test_cToAm_zeroScaleDistance() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let a = TonalContext(tonic: .a, scaleType: .naturalMinor)
        XCTAssertEqual(c.scaleDistance(to: a), 0)
    }

    func test_cToAm_hasPivotEdge() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let a = TonalContext(tonic: .a, scaleType: .naturalMinor)
        let edges = graph.edges(from: c, to: a)
        let hasPivot = edges.contains { $0.technique == .pivotChord }
        XCTAssertTrue(hasPivot, "C→Am (relative) should have pivot chord edges")
    }

    // MARK: - Known relationships: C major → C Mixolydian (modal shift)

    func test_cToCmix_sameTonicDifferentMode() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let cmix = TonalContext(tonic: .c, scaleType: .mixolydian)
        XCTAssertEqual(c.tonic, cmix.tonic)
        XCTAssertNotEqual(c.scaleType, cmix.scaleType)
    }

    func test_cToCmix_modeDistanceIs1() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let cmix = TonalContext(tonic: .c, scaleType: .mixolydian)
        XCTAssertEqual(c.modeDistance(to: cmix), 1)
    }

    func test_cToCmix_hasEdges() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let cmix = TonalContext(tonic: .c, scaleType: .mixolydian)
        let edges = graph.edges(from: c, to: cmix)
        XCTAssertFalse(edges.isEmpty, "C major → C Mixolydian should have edges")
    }

    // MARK: - Asymmetry

    func test_asymmetry_costCanDiffer() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let a = TonalContext(tonic: .a, scaleType: .naturalMinor)

        let forwardCost = graph.cheapestEdge(from: c, to: a)?.cost
        let backwardCost = graph.cheapestEdge(from: a, to: c)?.cost

        // Both should exist
        XCTAssertNotNil(forwardCost)
        XCTAssertNotNil(backwardCost)
        // They may differ due to asymmetric functional roles
        // (We don't assert inequality — just that both exist and are valid)
    }

    // MARK: - Edge type distribution

    func test_graph_hasMultipleTechniqueTypes() {
        var techniques: Set<ModulationTechnique> = []
        for node in graph.nodes {
            for edge in graph.edges(from: node) {
                techniques.insert(edge.technique)
            }
        }
        // Should have at least pivot, common-tone, and direct
        XCTAssertTrue(techniques.contains(.pivotChord), "Graph should have pivot chord edges")
        XCTAssertTrue(techniques.contains(.commonTone), "Graph should have common-tone edges")
        XCTAssertTrue(techniques.contains(.direct), "Graph should have direct modulation edges")
    }

    // MARK: - Multiple edges between same pair

    func test_multipleTechniquesBetweenSamePair() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let g = TonalContext(tonic: .g, scaleType: .major)
        let edges = graph.edges(from: c, to: g)
        let techniques = Set(edges.map(\.technique))
        XCTAssertGreaterThan(techniques.count, 1,
                             "C→G should have multiple technique types")
    }

    // MARK: - Precomputation performance

    func test_graphBuild_completesInUnder2Seconds() {
        let start = Date()
        _ = GraphBuilder.build()
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertLessThan(elapsed, 2.0, "Graph build should complete in under 2 seconds")
    }

    // MARK: - Cost ordering (closer keys cheaper)

    func test_costOrdering_adjacentCheaperThanDistant() {
        let c = TonalContext(tonic: .c, scaleType: .major)

        // Adjacent on circle of fifths
        let g = TonalContext(tonic: .g, scaleType: .major)
        // Two steps
        let d = TonalContext(tonic: .d, scaleType: .major)
        // Distant
        let fs = TonalContext(tonic: .fs, scaleType: .major)

        let cgCost = graph.cheapestEdge(from: c, to: g)!.cost
        let cdCost = graph.cheapestEdge(from: c, to: d)!.cost
        let cfsCost = graph.cheapestEdge(from: c, to: fs)!.cost

        XCTAssertLessThan(cgCost, cdCost, "C→G should be cheaper than C→D")
        XCTAssertLessThan(cdCost, cfsCost, "C→D should be cheaper than C→F#")
    }

    // MARK: - No self-edges

    func test_noSelfEdges() {
        for node in graph.nodes {
            let selfEdges = graph.edges(from: node, to: node)
            XCTAssertTrue(selfEdges.isEmpty, "\(node.displayName) should have no self-edges")
        }
    }

    // MARK: - All costs positive

    func test_allCostsPositive() {
        for node in graph.nodes {
            for edge in graph.edges(from: node) {
                XCTAssertGreaterThan(edge.cost, 0, "Edge \(edge.source.displayName)→\(edge.target.displayName) has non-positive cost")
            }
        }
    }
}
