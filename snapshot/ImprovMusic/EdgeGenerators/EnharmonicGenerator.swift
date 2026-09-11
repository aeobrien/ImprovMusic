import Foundation

/// Generates enharmonic reinterpretation modulation edges.
/// Checks for chords in the source that can be enharmonically respelled to function
/// in the target (e.g., dominant seventh reinterpreted as German augmented sixth).
/// High base cost; applies mainly to distant modulations.
enum EnharmonicGenerator {

    static func generate(
        from source: TonalContext,
        to target: TonalContext,
        vector: DistanceVector,
        weights: DistanceWeights
    ) -> [ModulationEdge] {
        // Only consider when keys are distant (region distance >= 3)
        guard vector.regionDistance >= 3 else { return [] }

        // Skip self-modulations
        guard source != target else { return [] }

        var edges: [ModulationEdge] = []

        // Check for dominant 7th ↔ German augmented 6th reinterpretation
        // V7 in source = a dominant seventh chord.
        // German +6 resolves to the dominant of the target key.
        // The V7 chord built on scale degree 5 of the source can be reinterpreted
        // as a Ger+6 in the target if the pitch classes match.

        let sourceDom7 = source.diatonicSevenths[4] // V7
        if sourceDom7.quality == .dominantSeventh {
            // The Ger+6 in a key resolves to V, so it's built on b6 of the target.
            // Check: does the source V7 share pitch classes with a chord that could
            // function as Ger+6 in the target?
            // Ger+6 = b6, 1, #2(=b3), #4(=b5) — same pitch classes as a dominant 7th
            // on b6 of the target.

            let targetFlatSix = (target.tonic.value + 8) % 12 // b6 = 8 semitones above tonic
            if sourceDom7.root.value == targetFlatSix {
                let evidence = ModulationEvidence.enharmonic(
                    sourceChord: sourceDom7,
                    reinterpretedAs: "Ger+6 → V in target"
                )
                var cost = weights.baseCost(from: vector) + weights.enharmonicPenalty
                cost = max(cost, 2.0)

                edges.append(ModulationEdge(
                    source: source,
                    target: target,
                    technique: .enharmonicReinterpretation,
                    cost: cost,
                    evidence: evidence
                ))
            }
        }

        // Check for diminished seventh chord reinterpretation
        // Diminished 7th chords are symmetrical — any note can be respelled as the root.
        // viidim7 in source can be reinterpreted as viidim7 in the target if they
        // share pitch classes.
        let sourceViiDim = source.diatonicSevenths[6]
        if sourceViiDim.quality == .halfDiminished || sourceViiDim.quality == .diminishedSeventh {
            let targetViiDim = target.diatonicSevenths[6]
            // Check for pitch class overlap (at least 3 shared pitch classes)
            let shared = sourceViiDim.pitchClasses.intersection(targetViiDim.pitchClasses)
            if shared.count >= 3 {
                let evidence = ModulationEvidence.enharmonic(
                    sourceChord: sourceViiDim,
                    reinterpretedAs: "vii° respelled as \(targetViiDim.romanNumeral) in target"
                )
                var cost = weights.baseCost(from: vector) + weights.enharmonicPenalty
                cost = max(cost, 2.0)

                edges.append(ModulationEdge(
                    source: source,
                    target: target,
                    technique: .enharmonicReinterpretation,
                    cost: cost,
                    evidence: evidence
                ))
            }
        }

        return edges
    }
}
