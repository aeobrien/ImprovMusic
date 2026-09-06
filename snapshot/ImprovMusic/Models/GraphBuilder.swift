import Foundation

/// Builds the complete modulation graph by running all edge generators
/// for every ordered pair of tonal contexts.
enum GraphBuilder {

    /// Build the full modulation graph with default weights.
    static func build(weights: DistanceWeights = .default) -> ModulationGraph {
        let nodes = TonalContext.all
        var edges: [ModulationEdge] = []

        for source in nodes {
            for target in nodes {
                guard source != target else { continue }

                let vector = DistanceVector.compute(from: source, to: target)

                // Run all edge generators
                edges.append(contentsOf:
                    PivotChordGenerator.generate(from: source, to: target, vector: vector, weights: weights))
                edges.append(contentsOf:
                    CommonToneGenerator.generate(from: source, to: target, vector: vector, weights: weights))
                edges.append(contentsOf:
                    MixtureAssistedGenerator.generate(from: source, to: target, vector: vector, weights: weights))
                edges.append(contentsOf:
                    DirectModulationGenerator.generate(from: source, to: target, vector: vector, weights: weights))
                edges.append(contentsOf:
                    EnharmonicGenerator.generate(from: source, to: target, vector: vector, weights: weights))
            }
        }

        return ModulationGraph(nodes: nodes, edges: edges)
    }
}
