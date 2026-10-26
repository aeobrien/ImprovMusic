import Foundation

/// A tonal context: a specific key or mode defined by a tonic pitch class and a scale type.
/// This is the fundamental unit of the modulation engine — each node in the modulation graph
/// is a TonalContext.
struct TonalContext: Hashable, Identifiable, Sendable {
    let tonic: PitchClass
    let scaleType: ScaleType

    var id: Int { tonic.value * ScaleType.allCases.count + ScaleType.allCases.firstIndex(of: scaleType)! }

    // MARK: - Computed properties

    /// The set of pitch classes in this scale.
    var pitchClassSet: Set<Int> {
        scaleType.pitchClasses(from: tonic)
    }

    /// The ordered scale degrees as pitch classes.
    var scaleDegrees: [PitchClass] {
        scaleType.scaleDegrees(from: tonic)
    }

    /// The spelling preference for note names in this context.
    var spellingPreference: SpellingPreference {
        PitchSpelling.preference(tonic: tonic, scaleType: scaleType)
    }

    /// Display name, e.g. "C Major", "D Dorian", "B♭ Minor".
    var displayName: String {
        let tonicName = PitchSpelling.tonicName(pitchClass: tonic, scaleType: scaleType)
        return "\(tonicName) \(scaleType.displayName)"
    }

    /// The diatonic collection ID (circle-of-fifths position of the parent major key).
    var diatonicCollectionId: Int {
        scaleType.diatonicCollectionId(from: tonic)
    }

    /// The diatonic triads built on each scale degree.
    var diatonicTriads: [DiatonicChord] {
        DiatonicChordGenerator.triads(for: self)
    }

    /// The diatonic seventh chords built on each scale degree.
    var diatonicSevenths: [DiatonicChord] {
        DiatonicChordGenerator.seventhChords(for: self)
    }

    // MARK: - Distance calculations

    /// Symmetric difference size between the pitch class sets of two tonal contexts.
    /// This counts how many notes change between the two scales.
    func scaleDistance(to other: TonalContext) -> Int {
        pitchClassSet.symmetricDifference(other.pitchClassSet).count
    }

    /// Circle-of-fifths distance between the diatonic collections (0-6).
    /// Two contexts sharing the same diatonic collection (e.g., C major and D Dorian) have distance 0.
    func regionDistance(to other: TonalContext) -> Int {
        let a = diatonicCollectionId
        let b = other.diatonicCollectionId
        let diff = abs(a - b)
        return min(diff, 12 - diff)
    }

    /// Circle-of-fifths distance between the tonics (0-6).
    func tonicDistance(to other: TonalContext) -> Int {
        tonic.fifthsDistance(to: other.tonic)
    }

    /// Colour-note edit distance between modes.
    /// Only meaningful when both contexts share the same tonic.
    /// Returns nil if tonics differ.
    func modeDistance(to other: TonalContext) -> Int? {
        guard tonic == other.tonic else { return nil }
        // Count how many pitch classes differ
        let diff = pitchClassSet.symmetricDifference(other.pitchClassSet).count
        return diff / 2 // Each colour-note edit changes one pitch out and one in
    }

    // MARK: - All contexts

    /// All 72 valid tonal contexts (12 tonics × 6 scale types).
    static let all: [TonalContext] = {
        var contexts: [TonalContext] = []
        for tonic in 0..<12 {
            for scaleType in ScaleType.allCases {
                contexts.append(TonalContext(tonic: PitchClass(tonic), scaleType: scaleType))
            }
        }
        return contexts
    }()
}
