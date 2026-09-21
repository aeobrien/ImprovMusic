import Foundation

/// The six scale types supported by the app.
/// Ionian is an alias for major; Aeolian is an alias for naturalMinor.
/// Locrian is excluded (diminished tonic triad, can't function as stable tonal centre).
/// Harmonic minor and melodic minor are deferred from the initial implementation.
enum ScaleType: String, CaseIterable, Hashable, Sendable {
    case major
    case naturalMinor
    case dorian
    case phrygian
    case lydian
    case mixolydian

    /// The interval recipe as a sequence of semitone steps that sum to 12.
    var intervals: [Int] {
        switch self {
        case .major:        return [2, 2, 1, 2, 2, 2, 1]  // W W H W W W H
        case .naturalMinor: return [2, 1, 2, 2, 1, 2, 2]  // W H W W H W W
        case .dorian:       return [2, 1, 2, 2, 2, 1, 2]  // W H W W W H W
        case .phrygian:     return [1, 2, 2, 2, 1, 2, 2]  // H W W W H W W
        case .lydian:       return [2, 2, 2, 1, 2, 2, 1]  // W W W H W W H
        case .mixolydian:   return [2, 2, 1, 2, 2, 1, 2]  // W W H W W H W
        }
    }

    /// Display name for the scale type.
    var displayName: String {
        switch self {
        case .major:        return "Major"
        case .naturalMinor: return "Minor"
        case .dorian:       return "Dorian"
        case .phrygian:     return "Phrygian"
        case .lydian:       return "Lydian"
        case .mixolydian:   return "Mixolydian"
        }
    }

    /// Whether this is a "major-ish" mode (brighter, major third above tonic)
    /// or a "minor-ish" mode (darker, minor third above tonic).
    var isMajorish: Bool {
        switch self {
        case .major, .lydian, .mixolydian: return true
        case .naturalMinor, .dorian, .phrygian: return false
        }
    }

    /// Whether this is a standard key (major or natural minor) vs a mode.
    /// Used for weighting challenge selection — standard keys are selected more often.
    var isStandardKey: Bool {
        self == .major || self == .naturalMinor
    }

    /// The reference scale type for colour-note distance calculation.
    /// Major-ish modes are compared to major; minor-ish modes to natural minor.
    var referenceType: ScaleType {
        isMajorish ? .major : .naturalMinor
    }

    /// The number of colour-note edits from the reference type (major or natural minor).
    /// This measures how many scale degrees differ from the reference when the same tonic is used.
    ///
    /// - Major-ish: compared to major. Lydian = 1 (♯4), Mixolydian = 1 (♭7).
    /// - Minor-ish: compared to natural minor. Dorian = 1 (♮6), Phrygian = 1 (♭2).
    var colourNoteDistance: Int {
        if self == referenceType { return 0 }
        // Compute the symmetric difference of pitch classes when both share tonic C.
        let selfPitches = pitchClasses(from: PitchClass.c)
        let refPitches = referenceType.pitchClasses(from: PitchClass.c)
        return selfPitches.symmetricDifference(refPitches).count / 2
        // Divided by 2 because each colour-note edit changes one pitch out and one in.
    }

    /// Compute the set of pitch classes for this scale type starting from a given tonic.
    func pitchClasses(from tonic: PitchClass) -> Set<Int> {
        var result = Set<Int>()
        var current = tonic.value
        result.insert(current)
        for interval in intervals.dropLast() {
            current = (current + interval) % 12
            result.insert(current)
        }
        return result
    }

    /// Returns the ordered scale degrees (pitch classes) starting from the tonic.
    func scaleDegrees(from tonic: PitchClass) -> [PitchClass] {
        var degrees: [PitchClass] = []
        var current = tonic.value
        degrees.append(PitchClass(current))
        for interval in intervals.dropLast() {
            current = (current + interval) % 12
            degrees.append(PitchClass(current))
        }
        return degrees
    }

    /// The offset from the parent major key's tonic, in semitones.
    /// E.g., Dorian's tonic is 2 semitones above its parent major tonic (D Dorian → C major).
    var offsetFromParentMajor: Int {
        switch self {
        case .major:        return 0   // Ionian: same tonic as parent major
        case .dorian:       return 2   // 2nd degree of parent major
        case .phrygian:     return 4   // 3rd degree
        case .lydian:       return 5   // 4th degree
        case .mixolydian:   return 7   // 5th degree
        case .naturalMinor: return 9   // 6th degree (Aeolian)
        }
    }

    /// Given this mode's tonic, returns the tonic of the parent major key
    /// that shares the same diatonic collection.
    /// E.g., D Dorian → C major, A natural minor → C major.
    func parentMajorTonic(from tonic: PitchClass) -> PitchClass {
        PitchClass(tonic.value - offsetFromParentMajor)
    }

    /// The "diatonic collection ID" — the position of the parent major key on the circle of fifths.
    /// This allows comparing whether two tonal contexts share the same underlying diatonic collection
    /// (they do if their collection IDs match) and computing the regional distance between collections.
    func diatonicCollectionId(from tonic: PitchClass) -> Int {
        let parentTonic = parentMajorTonic(from: tonic)
        // The circle-of-fifths position: C=0, G=1, D=2, ... F=11 (or equivalently -1).
        // We use the semitone→fifths mapping.
        let semitoneToFifths = [0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5]
        return semitoneToFifths[parentTonic.value]
    }
}
