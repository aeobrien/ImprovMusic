import Foundation

/// Generates common-tone modulation edges.
/// A common tone is a shared pitch class that serves as a "hinge" note
/// connecting a chord in the source to a chord in the target.
enum CommonToneGenerator {

    static func generate(
        from source: TonalContext,
        to target: TonalContext,
        vector: DistanceVector,
        weights: DistanceWeights
    ) -> [ModulationEdge] {
        let sharedPitchClasses = source.pitchClassSet.intersection(target.pitchClassSet)
        guard !sharedPitchClasses.isEmpty else { return [] }

        // Find the best common-tone connection
        var bestConnection: Connection?
        var bestScore = -1

        for pc in sharedPitchClasses {
            let hingePC = PitchClass(pc)

            // Find a chord in source that contains this pitch class
            let sourceChords = source.diatonicTriads.filter { $0.pitchClasses.contains(pc) }
            let targetChords = target.diatonicTriads.filter { $0.pitchClasses.contains(pc) }

            for sc in sourceChords {
                for tc in targetChords {
                    // Score: prefer chords where the hinge is the root, and where
                    // the target chord can cadentially confirm the new key
                    var score = 1
                    if sc.root.value == pc { score += 1 } // Hinge is root of source chord
                    if tc.root.value == pc { score += 1 } // Hinge is root of target chord
                    if tc.function == .dominant { score += 2 } // Target chord has dominant function
                    if tc.function == .tonic { score += 1 }

                    if score > bestScore {
                        bestScore = score
                        bestConnection = Connection(
                            hinge: hingePC,
                            sourceChord: sc,
                            targetChord: tc
                        )
                    }
                }
            }
        }

        guard let connection = bestConnection else { return [] }

        // Cost: base + common-tone penalty, reduced by shared tone count
        var cost = weights.baseCost(from: vector) + weights.commonTonePenalty
        cost -= Double(sharedPitchClasses.count) * 0.3 // More shared tones = easier
        cost = max(cost, 0.5)

        let evidence = ModulationEvidence.commonTone(
            pitchClass: connection.hinge,
            sourceChord: connection.sourceChord,
            targetChord: connection.targetChord
        )

        return [ModulationEdge(
            source: source,
            target: target,
            technique: .commonTone,
            cost: cost,
            evidence: evidence
        )]
    }

    private struct Connection {
        let hinge: PitchClass
        let sourceChord: DiatonicChord
        let targetChord: DiatonicChord
    }
}
