import Foundation

/// A single step in a modulation path.
struct HintStep: Hashable, Sendable {
    /// The intermediate tonal context to pass through.
    let context: TonalContext

    /// The modulation technique for this step.
    let technique: ModulationTechnique

    /// The musical evidence (pivot chord, common tone, etc.).
    let evidence: ModulationEvidence
}

/// A complete multi-step modulation path with its total cost.
struct ModulationPath: Sendable {
    /// The sequence of steps from source to target.
    let steps: [HintStep]

    /// The total cost (sum of edge costs along the path).
    let totalCost: Double

    /// The set of techniques used across all steps.
    var techniques: Set<ModulationTechnique> {
        Set(steps.map(\.technique))
    }
}

/// Finds shortest and k-shortest paths through the modulation graph.
enum Pathfinder {

    /// Find the shortest path from source to target using Dijkstra's algorithm.
    /// Returns nil if no path exists.
    static func shortestPath(
        in graph: ModulationGraph,
        from source: TonalContext,
        to target: TonalContext
    ) -> ModulationPath? {
        // Dijkstra's algorithm
        var dist: [Int: Double] = [source.id: 0]
        var prev: [Int: (TonalContext, ModulationEdge)] = [:]
        var visited: Set<Int> = []

        // Simple priority queue using sorted array (72 nodes — fine for this scale)
        var queue: [(id: Int, cost: Double)] = [(source.id, 0)]

        while !queue.isEmpty {
            queue.sort { $0.cost < $1.cost }
            let current = queue.removeFirst()

            if current.id == target.id {
                return reconstructPath(prev: prev, source: source, target: target)
            }

            if visited.contains(current.id) { continue }
            visited.insert(current.id)

            let currentContext = graph.nodes.first { $0.id == current.id }!
            for edge in graph.edges(from: currentContext) {
                let newDist = current.cost + edge.cost
                let targetId = edge.target.id
                if newDist < (dist[targetId] ?? .infinity) {
                    dist[targetId] = newDist
                    prev[targetId] = (currentContext, edge)
                    queue.append((targetId, newDist))
                }
            }
        }

        return nil
    }

    /// Find k shortest paths using a simplified Yen's algorithm.
    /// Returns up to k paths, sorted by cost.
    static func kShortestPaths(
        in graph: ModulationGraph,
        from source: TonalContext,
        to target: TonalContext,
        k: Int = 3
    ) -> [ModulationPath] {
        guard let shortest = shortestPath(in: graph, from: source, to: target) else {
            return []
        }

        var result: [ModulationPath] = [shortest]
        var candidates: [ModulationPath] = []

        for i in 0..<min(k - 1, shortest.steps.count) {
            // For each step in the previous shortest path, try deviating
            let spurNode: TonalContext
            if i == 0 {
                spurNode = source
            } else {
                spurNode = shortest.steps[i - 1].context
            }

            // Find an alternative path from the spur node that avoids the edges
            // used in known shortest paths at this spur point
            let excludedTargets = Set(result.compactMap { path -> Int? in
                guard path.steps.count > i else { return nil }
                return path.steps[i].context.id
            })

            if let altPath = shortestPathAvoiding(
                in: graph,
                from: spurNode,
                to: target,
                avoiding: excludedTargets
            ) {
                // Combine the root path (source → spur) with the spur path
                let rootSteps = Array(shortest.steps.prefix(i))
                let rootCost = rootSteps.reduce(0.0) { sum, step in
                    // Approximate cost — use the edge cost from the original path
                    sum + (graph.edges(from: i > 0 ? shortest.steps[i-1].context : source)
                        .first { $0.target == step.context }?.cost ?? 0)
                }
                let combined = ModulationPath(
                    steps: rootSteps + altPath.steps,
                    totalCost: rootCost + altPath.totalCost
                )
                candidates.append(combined)
            }
        }

        candidates.sort { $0.totalCost < $1.totalCost }
        result.append(contentsOf: candidates.prefix(k - 1))

        return Array(result.prefix(k))
    }

    /// Find k paths that maximise technique diversity.
    /// Prefers showing routes using different techniques over cost-similar routes.
    static func diverseHintPaths(
        in graph: ModulationGraph,
        from source: TonalContext,
        to target: TonalContext,
        k: Int = 3
    ) -> [ModulationPath] {
        let paths = kShortestPaths(in: graph, from: source, to: target, k: k * 2)
        guard paths.count > k else { return paths }

        // Greedily select paths that add technique diversity
        var selected: [ModulationPath] = []
        var coveredTechniques: Set<ModulationTechnique> = []

        for path in paths {
            let newTechniques = path.techniques.subtracting(coveredTechniques)
            if !newTechniques.isEmpty || selected.count < k {
                selected.append(path)
                coveredTechniques.formUnion(path.techniques)
                if selected.count >= k { break }
            }
        }

        return selected
    }

    // MARK: - Private

    private static func reconstructPath(
        prev: [Int: (TonalContext, ModulationEdge)],
        source: TonalContext,
        target: TonalContext
    ) -> ModulationPath {
        var steps: [HintStep] = []
        var totalCost = 0.0
        var current = target

        while current != source {
            guard let (_, edge) = prev[current.id] else { break }
            steps.append(HintStep(
                context: current,
                technique: edge.technique,
                evidence: edge.evidence
            ))
            totalCost += edge.cost
            current = edge.source
        }

        steps.reverse()
        return ModulationPath(steps: steps, totalCost: totalCost)
    }

    /// Dijkstra avoiding specific intermediate node IDs.
    private static func shortestPathAvoiding(
        in graph: ModulationGraph,
        from source: TonalContext,
        to target: TonalContext,
        avoiding excludedIds: Set<Int>
    ) -> ModulationPath? {
        var dist: [Int: Double] = [source.id: 0]
        var prev: [Int: (TonalContext, ModulationEdge)] = [:]
        var visited: Set<Int> = []

        var queue: [(id: Int, cost: Double)] = [(source.id, 0)]

        while !queue.isEmpty {
            queue.sort { $0.cost < $1.cost }
            let current = queue.removeFirst()

            if current.id == target.id {
                return reconstructPath(prev: prev, source: source, target: target)
            }

            if visited.contains(current.id) { continue }
            visited.insert(current.id)

            let currentContext = graph.nodes.first { $0.id == current.id }!
            for edge in graph.edges(from: currentContext) {
                let targetId = edge.target.id
                // Skip excluded nodes (unless it's the final target)
                if excludedIds.contains(targetId) && targetId != target.id { continue }

                let newDist = current.cost + edge.cost
                if newDist < (dist[targetId] ?? .infinity) {
                    dist[targetId] = newDist
                    prev[targetId] = (currentContext, edge)
                    queue.append((targetId, newDist))
                }
            }
        }

        return nil
    }
}
