import Foundation

/// Generates direct modulation edges.
/// Always available as a fallback — simply assert the new key at a phrase boundary.
/// Cost is a function of the raw distance with no reduction for pivot availability.
enum DirectModulationGenerator {

    static func generate(
        from source: TonalContext,
        to target: TonalContext,
        vector: DistanceVector,
        weights: DistanceWeights
    ) -> [ModulationEdge] {
        // Skip self-modulations
        guard source != target else { return [] }

        // Cost: base distance + direct modulation penalty (no pivot support)
        var cost = weights.baseCost(from: vector) + weights.directPenalty
        cost = max(cost, 1.0)

        return [ModulationEdge(
            source: source,
            target: target,
            technique: .direct,
            cost: cost,
            evidence: .direct
        )]
    }
}
