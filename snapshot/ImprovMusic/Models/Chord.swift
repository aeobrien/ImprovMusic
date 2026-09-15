import Foundation

/// The quality of a chord.
enum ChordQuality: String, Hashable, Sendable {
    case major          // Major triad (0, 4, 7)
    case minor          // Minor triad (0, 3, 7)
    case diminished     // Diminished triad (0, 3, 6)
    case augmented      // Augmented triad (0, 4, 8)
    case majorSeventh   // Major 7th (0, 4, 7, 11)
    case dominantSeventh // Dominant 7th (0, 4, 7, 10)
    case minorSeventh   // Minor 7th (0, 3, 7, 10)
    case halfDiminished // Half-diminished 7th (0, 3, 6, 10)
    case diminishedSeventh // Fully diminished 7th (0, 3, 6, 9)

    var displaySymbol: String {
        switch self {
        case .major:            return ""
        case .minor:            return "m"
        case .diminished:       return "dim"
        case .augmented:        return "aug"
        case .majorSeventh:     return "maj7"
        case .dominantSeventh:  return "7"
        case .minorSeventh:     return "m7"
        case .halfDiminished:   return "m7♭5"
        case .diminishedSeventh: return "dim7"
        }
    }

    var isTriad: Bool {
        switch self {
        case .major, .minor, .diminished, .augmented: return true
        default: return false
        }
    }

    /// The intervals (in semitones from root) that define this chord quality.
    var intervals: [Int] {
        switch self {
        case .major:            return [0, 4, 7]
        case .minor:            return [0, 3, 7]
        case .diminished:       return [0, 3, 6]
        case .augmented:        return [0, 4, 8]
        case .majorSeventh:     return [0, 4, 7, 11]
        case .dominantSeventh:  return [0, 4, 7, 10]
        case .minorSeventh:     return [0, 3, 7, 10]
        case .halfDiminished:   return [0, 3, 6, 10]
        case .diminishedSeventh: return [0, 3, 6, 9]
        }
    }
}

/// The harmonic function of a chord within a tonal context.
/// Only assigned for major and natural minor; modes use .unassigned.
enum HarmonicFunction: String, Hashable, Sendable {
    case tonic
    case predominant
    case dominant
    case unassigned
}

/// A chord built on a specific scale degree within a tonal context.
struct DiatonicChord: Hashable, Sendable {
    /// The scale degree (1-7).
    let scaleDegree: Int

    /// The root pitch class.
    let root: PitchClass

    /// The chord quality.
    let quality: ChordQuality

    /// The harmonic function in this context.
    let function: HarmonicFunction

    /// The pitch classes in this chord.
    var pitchClasses: Set<Int> {
        Set(quality.intervals.map { (root.value + $0) % 12 })
    }

    /// Display name (e.g., "Cmaj7", "Dm", "Bdim").
    func displayName(spelling: SpellingPreference) -> String {
        let rootName = PitchSpelling.name(for: root, preferring: spelling)
        return "\(rootName)\(quality.displaySymbol)"
    }

    /// Roman numeral label (e.g., "I", "ii", "V7", "viidim").
    var romanNumeral: String {
        let numerals = ["", "I", "II", "III", "IV", "V", "VI", "VII"]
        let base = numerals[scaleDegree]
        let isMinorish = quality == .minor || quality == .diminished ||
                         quality == .minorSeventh || quality == .halfDiminished ||
                         quality == .diminishedSeventh
        let numeral = isMinorish ? base.lowercased() : base
        let suffix: String
        switch quality {
        case .major, .minor: suffix = ""
        case .diminished: suffix = "°"
        case .augmented: suffix = "+"
        case .majorSeventh: suffix = "maj7"
        case .dominantSeventh: suffix = "7"
        case .minorSeventh: suffix = "7"
        case .halfDiminished: suffix = "ø7"
        case .diminishedSeventh: suffix = "°7"
        }
        return "\(numeral)\(suffix)"
    }
}
