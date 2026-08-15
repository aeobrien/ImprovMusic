import Foundation

/// Generates mixture-assisted modulation edges.
/// Extends the source's chord set by borrowing from its parallel major/minor,
/// then looks for pivots between the extended set and the target's diatonic chords.
enum MixtureAssistedGenerator {

    static func generate(
        from source: TonalContext,
        to target: TonalContext,
        vector: DistanceVector,
        weights: DistanceWeights
    ) -> [ModulationEdge] {
        // Only applies to major/minor source contexts (borrowing from parallel)
        guard source.scaleType == .major || source.scaleType == .naturalMinor else {
            return []
        }

        // Get the parallel mode's chords
        let parallelType: ScaleType = source.scaleType == .major ? .naturalMinor : .major
        let parallel = TonalContext(tonic: source.tonic, scaleType: parallelType)
        let borrowedChords = parallel.diatonicTriads

        // Find borrowed chords that pivot into the target
        var bestPivot: (borrowed: DiatonicChord, target: DiatonicChord)?
        for borrowed in borrowedChords {
            // Skip chords already diatonic in the source
            let isDiatonicInSource = source.diatonicTriads.contains(where: {
                $0.root == borrowed.root && $0.quality == borrowed.quality
            })
            if isDiatonicInSource { continue }

            // Check if this borrowed chord matches anything in the target
            for targetChord in target.diatonicTriads {
                if borrowed.root == targetChord.root && borrowed.quality == targetChord.quality {
                    if bestPivot == nil {
                        bestPivot = (borrowed, targetChord)
                    }
                }
            }
        }

        guard let pivot = bestPivot else { return [] }

        // Cost: base + mixture penalty
        var cost = weights.baseCost(from: vector) + weights.mixturePenalty
        cost = max(cost, 1.0)

        let evidence = ModulationEvidence.mixturePivot(
            borrowedChord: pivot.borrowed,
            functionInTarget: pivot.target.romanNumeral
        )

        return [ModulationEdge(
            source: source,
            target: target,
            technique: .mixtureAssisted,
            cost: cost,
            evidence: evidence
        )]
    }
}
