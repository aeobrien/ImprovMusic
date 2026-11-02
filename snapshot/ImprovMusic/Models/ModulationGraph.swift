import Foundation

/// A directed, weighted multigraph of modulation relationships between tonal contexts.
/// Nodes are TonalContexts (72 total). Edges represent possible single-step modulations
/// with associated cost, technique type, and musical evidence.
/// Multiple edges can exist between the same pair of nodes (different techniques).
final class ModulationGraph: Sendable {
    /// All nodes in the graph.
    let nodes: [TonalContext]

    /// Edges indexed by source node ID for fast lookup.
    /// Key: source TonalContext ID. Value: array of edges from that source.
    let edgesBySource: [Int: [ModulationEdge]]

    /// Total number of edges in the graph.
    let edgeCount: Int

    init(nodes: [TonalContext], edges: [ModulationEdge]) {
        self.nodes = nodes
        self.edgeCount = edges.count
        var grouped: [Int: [ModulationEdge]] = [:]
        for edge in edges {
            grouped[edge.source.id, default: []].append(edge)
        }
        self.edgesBySource = grouped
    }

    /// All edges from a given source context.
    func edges(from source: TonalContext) -> [ModulationEdge] {
        edgesBySource[source.id] ?? []
    }

    /// All edges from a given source to a specific target.
    func edges(from source: TonalContext, to target: TonalContext) -> [ModulationEdge] {
        edges(from: source).filter { $0.target == target }
    }

    /// The minimum-cost edge from source to target, if any edge exists.
    func cheapestEdge(from source: TonalContext, to target: TonalContext) -> ModulationEdge? {
        edges(from: source, to: target).min(by: { $0.cost < $1.cost })
    }

    /// All unique targets reachable from a source.
    func targets(from source: TonalContext) -> Set<TonalContext> {
        Set(edges(from: source).map(\.target))
    }
}
