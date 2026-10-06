import Foundation

/// Generates pivot chord modulation edges.
/// A pivot chord is diatonic in both the source and target keys (same root + same quality).
enum PivotChordGenerator {

    static func generate(
        from source: TonalContext,
        to target: TonalContext,
        vector: DistanceVector,
        weights: DistanceWeights
    ) -> [ModulationEdge] {
        let commonTriads = findCommonChords(source.diatonicTriads, target.diatonicTriads)
        guard !commonTriads.isEmpty else { return [] }

        // Find the best pivot (used for evidence)
        let bestPivot = selectBestPivot(commonTriads, source: source, target: target)

        // Cost: base distance minus pivot bonuses
        var cost = weights.baseCost(from: vector)
        cost -= Double(commonTriads.count) * weights.pivotBonusPerTriad

        // Bonus for predominant→predominant pivots
        if let best = bestPivot {
            let sourceFunc = best.sourceChord.function
            let targetFunc = best.targetChord.function
            if sourceFunc == .predominant && targetFunc == .predominant {
                cost -= weights.predominantPivotBonus
            } else if sourceFunc == .tonic && targetFunc == .predominant {
                cost -= weights.predominantPivotBonus * 0.5
            }
        }

        // Also check sevenths
        let commonSevenths = findCommonChords(source.diatonicSevenths, target.diatonicSevenths)
        cost -= Double(commonSevenths.count) * weights.pivotBonusPerSeventh

        cost = max(cost, 0.1)

        guard let best = bestPivot else { return [] }

        let evidence = ModulationEvidence.pivot(
            chord: best.sourceChord,
            functionInSource: best.sourceChord.romanNumeral,
            functionInTarget: best.targetChord.romanNumeral
        )

        return [ModulationEdge(
            source: source,
            target: target,
            technique: .pivotChord,
            cost: cost,
            evidence: evidence
        )]
    }

    // MARK: - Private

    private struct PivotPair {
        let sourceChord: DiatonicChord
        let targetChord: DiatonicChord
    }

    private static func findCommonChords(
        _ a: [DiatonicChord],
        _ b: [DiatonicChord]
    ) -> [PivotPair] {
        var pairs: [PivotPair] = []
        for chordA in a {
            for chordB in b {
                if chordA.root == chordB.root && chordA.quality == chordB.quality {
                    pairs.append(PivotPair(sourceChord: chordA, targetChord: chordB))
                }
            }
        }
        return pairs
    }

    /// Select the best pivot chord based on functional quality.
    /// Prefer predominant→predominant, then tonic→predominant.
    /// For modal contexts (unassigned function), prefer by chord overlap count.
    private static func selectBestPivot(
        _ pivots: [PivotPair],
        source: TonalContext,
        target: TonalContext
    ) -> PivotPair? {
        guard !pivots.isEmpty else { return nil }

        // If either context is modal, just return the first pivot (no function ranking)
        if source.scaleType != .major && source.scaleType != .naturalMinor {
            return pivots.first
        }
        if target.scaleType != .major && target.scaleType != .naturalMinor {
            return pivots.first
        }

        // Rank by function quality
        return pivots.max(by: { pivotScore($0) < pivotScore($1) })
    }

    private static func pivotScore(_ pair: PivotPair) -> Int {
        let sf = pair.sourceChord.function
        let tf = pair.targetChord.function

        if sf == .predominant && tf == .predominant { return 4 }
        if sf == .tonic && tf == .predominant { return 3 }
        if sf == .predominant && tf == .tonic { return 2 }
        if sf == .tonic && tf == .tonic { return 1 }
        return 0
    }
}
