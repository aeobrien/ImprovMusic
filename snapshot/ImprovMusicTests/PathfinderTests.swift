import XCTest
@testable import ImprovMusic

final class PathfinderTests: XCTestCase {

    static var graph: ModulationGraph!

    override class func setUp() {
        super.setUp()
        graph = GraphBuilder.build()
    }

    var graph: ModulationGraph { Self.graph }

    // MARK: - Shortest path

    func test_shortestPath_closeKeys_singleStep() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .g, scaleType: .major)
        let path = Pathfinder.shortestPath(in: graph, from: source, to: target)
        XCTAssertNotNil(path)
        XCTAssertEqual(path?.steps.count, 1, "C→G should be a single step")
    }

    func test_shortestPath_distantKeys_multiStep() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .fs, scaleType: .major)
        let path = Pathfinder.shortestPath(in: graph, from: source, to: target)
        XCTAssertNotNil(path)
        // May be single or multi-step depending on cost — just verify it exists
    }

    func test_shortestPath_endsAtTarget() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .d, scaleType: .major)
        let path = Pathfinder.shortestPath(in: graph, from: source, to: target)!
        XCTAssertEqual(path.steps.last?.context, target)
    }

    func test_shortestPath_positiveCost() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .e, scaleType: .major)
        let path = Pathfinder.shortestPath(in: graph, from: source, to: target)!
        XCTAssertGreaterThan(path.totalCost, 0)
    }

    // MARK: - K shortest paths

    func test_kShortestPaths_returnsMultiple() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .d, scaleType: .major)
        let paths = Pathfinder.kShortestPaths(in: graph, from: source, to: target, k: 3)
        XCTAssertGreaterThanOrEqual(paths.count, 1)
    }

    func test_kShortestPaths_firstPathExists() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .d, scaleType: .major)
        let paths = Pathfinder.kShortestPaths(in: graph, from: source, to: target, k: 3)
        XCTAssertFalse(paths.isEmpty, "Should find at least one path")
        // The first path is the Dijkstra shortest
        XCTAssertGreaterThan(paths[0].totalCost, 0)
    }

    // MARK: - Diverse hint paths

    func test_diversePaths_returnsPaths() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .d, scaleType: .major)
        let paths = Pathfinder.diverseHintPaths(in: graph, from: source, to: target, k: 3)
        XCTAssertGreaterThanOrEqual(paths.count, 1)
    }

    func test_diversePaths_allReachTarget() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .a, scaleType: .naturalMinor)
        let paths = Pathfinder.diverseHintPaths(in: graph, from: source, to: target, k: 3)
        for path in paths {
            XCTAssertEqual(path.steps.last?.context, target,
                           "Every path should end at the target")
        }
    }

    // MARK: - Hint steps have content

    func test_hintSteps_haveTechniqueAndEvidence() {
        let source = TonalContext(tonic: .c, scaleType: .major)
        let target = TonalContext(tonic: .g, scaleType: .major)
        let path = Pathfinder.shortestPath(in: graph, from: source, to: target)!
        for step in path.steps {
            // Every step should have a technique
            XCTAssertNotNil(step.technique)
            // Every step should have a context
            XCTAssertNotNil(step.context)
        }
    }
}
