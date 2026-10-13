import Foundation

/// Utilities for circle-of-fifths calculations.
enum CircleOfFifths {
    /// The circle of fifths as pitch classes, starting from C.
    /// C, G, D, A, E, B, F#/Gb, Db, Ab, Eb, Bb, F
    static let order: [PitchClass] = [
        .c, .g, .d, .a, .e, .b, .fs, PitchClass(1), .gs, .ds, PitchClass(10), .f
    ]

    /// Distance between two positions on the circle of fifths (0-6).
    /// Wraps at the tritone (6 is the maximum).
    static func distance(_ a: Int, _ b: Int) -> Int {
        let diff = ((a - b) % 12 + 12) % 12
        return min(diff, 12 - diff)
    }
}
