import Foundation

/// Generates diatonic triads and seventh chords for a given tonal context.
enum DiatonicChordGenerator {

    /// Build the diatonic triads (7 chords, one per scale degree) for a tonal context.
    static func triads(for context: TonalContext) -> [DiatonicChord] {
        let degrees = context.scaleDegrees
        return (0..<7).map { i in
            let root = degrees[i]
            let third = degrees[(i + 2) % 7]
            let fifth = degrees[(i + 4) % 7]

            let thirdInterval = intervalInSemitones(from: root, to: third)
            let fifthInterval = intervalInSemitones(from: root, to: fifth)

            let quality = triadQuality(thirdInterval: thirdInterval, fifthInterval: fifthInterval)
            let function = harmonicFunction(
                scaleDegree: i + 1,
                quality: quality,
                scaleType: context.scaleType
            )

            return DiatonicChord(
                scaleDegree: i + 1,
                root: root,
                quality: quality,
                function: function
            )
        }
    }

    /// Build the diatonic seventh chords (7 chords, one per scale degree) for a tonal context.
    static func seventhChords(for context: TonalContext) -> [DiatonicChord] {
        let degrees = context.scaleDegrees
        return (0..<7).map { i in
            let root = degrees[i]
            let third = degrees[(i + 2) % 7]
            let fifth = degrees[(i + 4) % 7]
            let seventh = degrees[(i + 6) % 7]

            let thirdInterval = intervalInSemitones(from: root, to: third)
            let fifthInterval = intervalInSemitones(from: root, to: fifth)
            let seventhInterval = intervalInSemitones(from: root, to: seventh)

            let quality = seventhQuality(
                thirdInterval: thirdInterval,
                fifthInterval: fifthInterval,
                seventhInterval: seventhInterval
            )
            let function = harmonicFunction(
                scaleDegree: i + 1,
                quality: quality,
                scaleType: context.scaleType
            )

            return DiatonicChord(
                scaleDegree: i + 1,
                root: root,
                quality: quality,
                function: function
            )
        }
    }

    // MARK: - Quality determination

    private static func triadQuality(thirdInterval: Int, fifthInterval: Int) -> ChordQuality {
        switch (thirdInterval, fifthInterval) {
        case (4, 7): return .major
        case (3, 7): return .minor
        case (3, 6): return .diminished
        case (4, 8): return .augmented
        default:     return .major // Fallback; shouldn't occur in diatonic context
        }
    }

    private static func seventhQuality(
        thirdInterval: Int,
        fifthInterval: Int,
        seventhInterval: Int
    ) -> ChordQuality {
        switch (thirdInterval, fifthInterval, seventhInterval) {
        case (4, 7, 11): return .majorSeventh
        case (4, 7, 10): return .dominantSeventh
        case (3, 7, 10): return .minorSeventh
        case (3, 6, 10): return .halfDiminished
        case (3, 6, 9):  return .diminishedSeventh
        default:         return .majorSeventh // Fallback
        }
    }

    // MARK: - Harmonic function assignment

    /// Assigns harmonic function for major and natural minor keys.
    /// For modes, all chords get .unassigned since modal function hierarchies
    /// don't map cleanly to tonal functions.
    private static func harmonicFunction(
        scaleDegree: Int,
        quality: ChordQuality,
        scaleType: ScaleType
    ) -> HarmonicFunction {
        switch scaleType {
        case .major:
            return majorFunction(scaleDegree: scaleDegree)
        case .naturalMinor:
            return minorFunction(scaleDegree: scaleDegree)
        default:
            return .unassigned
        }
    }

    /// Harmonic functions in major keys.
    /// I, vi = tonic; ii, IV = predominant; V, viidim = dominant; iii = tonic (weak).
    private static func majorFunction(scaleDegree: Int) -> HarmonicFunction {
        switch scaleDegree {
        case 1: return .tonic
        case 2: return .predominant
        case 3: return .tonic           // iii is weak tonic
        case 4: return .predominant
        case 5: return .dominant
        case 6: return .tonic           // vi is tonic substitute
        case 7: return .dominant        // viidim is dominant function
        default: return .unassigned
        }
    }

    /// Harmonic functions in natural minor keys.
    /// i, VI = tonic; ii°, iv = predominant; v, VII = dominant (weaker without leading tone).
    private static func minorFunction(scaleDegree: Int) -> HarmonicFunction {
        switch scaleDegree {
        case 1: return .tonic
        case 2: return .predominant     // iidim
        case 3: return .tonic           // III is tonic substitute
        case 4: return .predominant
        case 5: return .dominant        // v (minor dominant, weaker)
        case 6: return .tonic           // VI is tonic substitute
        case 7: return .dominant        // VII (subtonic, weaker)
        default: return .unassigned
        }
    }

    // MARK: - Utilities

    /// Interval in semitones between two pitch classes (ascending).
    private static func intervalInSemitones(from a: PitchClass, to b: PitchClass) -> Int {
        ((b.value - a.value) % 12 + 12) % 12
    }
}
