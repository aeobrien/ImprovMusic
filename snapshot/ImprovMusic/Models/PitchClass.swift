import Foundation

/// A pitch class (0-11) representing one of the 12 chromatic pitches,
/// independent of octave. C=0, C#/Db=1, D=2, ... B=11.
struct PitchClass: Hashable, Comparable, Sendable {
    /// The integer value (0-11).
    let value: Int

    init(_ value: Int) {
        self.value = ((value % 12) + 12) % 12
    }

    // MARK: - Named constructors

    static let c  = PitchClass(0)
    static let cs = PitchClass(1)
    static let d  = PitchClass(2)
    static let ds = PitchClass(3)
    static let e  = PitchClass(4)
    static let f  = PitchClass(5)
    static let fs = PitchClass(6)
    static let g  = PitchClass(7)
    static let gs = PitchClass(8)
    static let a  = PitchClass(9)
    static let as_ = PitchClass(10) // trailing underscore to avoid keyword
    static let b  = PitchClass(11)

    // MARK: - Circle of fifths distance

    /// Distance on the circle of fifths (0-6), wrapping at the tritone.
    /// C↔G = 1, C↔D = 2, C↔F# = 6.
    func fifthsDistance(to other: PitchClass) -> Int {
        // Each step of +7 semitones = one fifth.
        // The minimum number of fifths steps to get from self to other (in either direction).
        let diff = ((other.value - self.value) % 12 + 12) % 12
        // Convert semitone difference to fifths-steps.
        // fifths-step n corresponds to semitone (7*n) % 12.
        // We precompute the mapping: semitone → minimum fifths distance.
        let semitonesToFifths = [0, 5, 2, 3, 4, 1, 6, 1, 4, 3, 2, 5]
        return semitonesToFifths[diff]
    }

    /// Transpose by an interval in semitones.
    func transposed(by semitones: Int) -> PitchClass {
        PitchClass(value + semitones)
    }

    static func < (lhs: PitchClass, rhs: PitchClass) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Spelling

/// The conventional name for a pitch class in a given key context.
enum SpellingPreference: Hashable, Sendable {
    case sharp   // Use sharps: C#, D#, F#, G#, A#
    case flat    // Use flats: Db, Eb, Gb, Ab, Bb
    case natural // Only for natural notes
}

/// Maps a pitch class to its display name given a key's spelling context.
///
/// The spelling context is determined by the key signature — sharp keys use sharp
/// spellings, flat keys use flat spellings. This avoids absurd spellings like D# major.
struct PitchSpelling: Sendable {

    /// The 12 pitch class names when using sharps.
    static let sharpNames = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]

    /// The 12 pitch class names when using flats.
    static let flatNames = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    /// Returns the conventional display name for a pitch class given a spelling preference.
    static func name(for pitchClass: PitchClass, preferring preference: SpellingPreference) -> String {
        switch preference {
        case .sharp:
            return sharpNames[pitchClass.value]
        case .flat:
            return flatNames[pitchClass.value]
        case .natural:
            // Natural notes have only one name; accidentals default to sharp.
            let naturals: [Int: String] = [0: "C", 2: "D", 4: "E", 5: "F", 7: "G", 9: "A", 11: "B"]
            return naturals[pitchClass.value] ?? sharpNames[pitchClass.value]
        }
    }

    /// Determines the conventional spelling preference for a key.
    /// Sharp keys: G, D, A, E, B, F# (and their relative minors / modes).
    /// Flat keys: F, Bb, Eb, Ab, Db, Gb (and their relative minors / modes).
    /// C major / A minor: natural.
    ///
    /// This is based on the tonic's position on the circle of fifths.
    /// The tonic pitch classes that conventionally use flats: F(5), Bb(10), Eb(3), Ab(8), Db(1), Gb(6).
    /// The tonic pitch classes that conventionally use sharps: G(7), D(2), A(9), E(4), B(11), F#(6).
    /// C(0) uses naturals. F#/Gb (6) prefers flats (Gb) to avoid 6 sharps vs 6 flats — both are valid
    /// but Gb is more conventional for major keys.
    static func preferenceForMajorKey(tonic: PitchClass) -> SpellingPreference {
        // Flat keys: F, Bb, Eb, Ab, Db, Gb
        let flatTonics: Set<Int> = [5, 10, 3, 8, 1, 6]
        // Sharp keys: G, D, A, E, B
        let sharpTonics: Set<Int> = [7, 2, 9, 4, 11]

        if tonic.value == 0 { return .natural }
        if flatTonics.contains(tonic.value) { return .flat }
        if sharpTonics.contains(tonic.value) { return .sharp }
        return .natural // Shouldn't reach here for 0-11
    }

    /// Determines spelling preference for any scale type by mapping to the
    /// underlying diatonic collection's major key equivalent.
    static func preference(tonic: PitchClass, scaleType: ScaleType) -> SpellingPreference {
        // Modes share a diatonic collection with their parent major key.
        // E.g., D Dorian shares the C major collection.
        // We find the parent major tonic and use its preference.
        let parentMajorTonic = scaleType.parentMajorTonic(from: tonic)
        return preferenceForMajorKey(tonic: parentMajorTonic)
    }

    /// The conventional display name for a tonic in a given scale type context.
    /// Suppresses absurd spellings by always using the conventional key-signature spelling.
    static func tonicName(pitchClass: PitchClass, scaleType: ScaleType) -> String {
        let pref = preference(tonic: pitchClass, scaleType: scaleType)
        return name(for: pitchClass, preferring: pref)
    }
}
