import Foundation

/// The composite distance between two tonal contexts, broken into components.
/// Used to compute edge costs and inform difficulty tier assignment.
struct DistanceVector: Sendable {
    /// Symmetric difference of pitch class sets — how many notes change.
    let scaleDistance: Int

    /// Circle-of-fifths distance between underlying diatonic collections (0-6).
    let regionDistance: Int

    /// Circle-of-fifths distance between tonics (0-6).
    let tonicDistance: Int

    /// Colour-note edit count between modes (nil if tonics differ).
    let modeDistance: Int?

    /// Number of common triads (same root pitch class + same quality) between the two contexts.
    let commonTriadCount: Int

    /// Number of common seventh chords between the two contexts.
    let commonSeventhCount: Int

    /// Whether the target context has a leading tone (semitone below the tonic).
    let targetHasLeadingTone: Bool

    /// Whether the target context has a major dominant chord (V).
    let targetHasMajorDominant: Bool

    /// Compute the distance vector between two tonal contexts.
    static func compute(from source: TonalContext, to target: TonalContext) -> DistanceVector {
        let commonTriads = Self.countCommonChords(source.diatonicTriads, target.diatonicTriads)
        let commonSevenths = Self.countCommonChords(source.diatonicSevenths, target.diatonicSevenths)

        let targetDegrees = target.scaleDegrees
        let tonicValue = target.tonic.value
        let hasLeadingTone = targetDegrees.contains(where: {
            ($0.value == (tonicValue + 11) % 12)
        })

        // Check if the 5th degree chord is major (dominant)
        let fifthDegreeTriad = target.diatonicTriads[4]
        let hasMajorDominant = fifthDegreeTriad.quality == .major

        return DistanceVector(
            scaleDistance: source.scaleDistance(to: target),
            regionDistance: source.regionDistance(to: target),
            tonicDistance: source.tonicDistance(to: target),
            modeDistance: source.modeDistance(to: target),
            commonTriadCount: commonTriads,
            commonSeventhCount: commonSevenths,
            targetHasLeadingTone: hasLeadingTone,
            targetHasMajorDominant: hasMajorDominant
        )
    }

    /// Count chords that share the same root pitch class and quality.
    private static func countCommonChords(_ a: [DiatonicChord], _ b: [DiatonicChord]) -> Int {
        var count = 0
        for chordA in a {
            for chordB in b {
                if chordA.root == chordB.root && chordA.quality == chordB.quality {
                    count += 1
                }
            }
        }
        return count
    }
}

/// Tunable weights for computing edge costs from distance vectors.
/// These are calibrated empirically during Phase 5.
struct DistanceWeights: Sendable {
    var scaleWeight: Double = 1.0
    var regionWeight: Double = 2.0
    var tonicWeight: Double = 1.5
    var modeWeight: Double = 0.5

    // Technique complexity penalties
    var mixturePenalty: Double = 3.0
    var commonTonePenalty: Double = 2.0
    var enharmonicPenalty: Double = 5.0
    var directPenalty: Double = 4.0

    // Pivot availability bonus (subtracted from cost)
    var pivotBonusPerTriad: Double = 1.0
    var pivotBonusPerSeventh: Double = 0.5
    var predominantPivotBonus: Double = 2.0

    // Cadence support bonus (subtracted from cost)
    var leadingToneBonus: Double = 1.0
    var majorDominantBonus: Double = 1.0

    static let `default` = DistanceWeights()

    /// Compute the base cost from a distance vector (before technique-specific adjustments).
    func baseCost(from vector: DistanceVector) -> Double {
        var cost = 0.0
        cost += Double(vector.scaleDistance) * scaleWeight
        cost += Double(vector.regionDistance) * regionWeight
        cost += Double(vector.tonicDistance) * tonicWeight
        if let mode = vector.modeDistance {
            cost += Double(mode) * modeWeight
        }

        // Subtract cadence support bonuses
        if vector.targetHasLeadingTone { cost -= leadingToneBonus }
        if vector.targetHasMajorDominant { cost -= majorDominantBonus }

        return max(cost, 0.1) // Never zero — even the closest modulations have some cost
    }
}
