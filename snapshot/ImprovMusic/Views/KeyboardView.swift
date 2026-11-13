import SwiftUI

/// A two-octave piano keyboard (C to B, twice) that highlights one octave of scale notes
/// starting from the lowest instance of the tonic.
///
/// When no challenge is active, shows the current scale.
/// When a challenge is active, shows the target scale instead.
struct KeyboardView: View {
    let currentContext: TonalContext
    let targetContext: TonalContext?

    private var displayContext: TonalContext {
        targetContext ?? currentContext
    }

    /// Each key across two octaves, in chromatic order, with enough info to render and position.
    /// chromaticIndex: 0-23 (two octaves of semitones starting from C)
    /// pitchClass: 0-11
    /// isBlack: whether it's a black key
    /// whiteKeyPosition: which white key slot it occupies or sits next to (for x positioning)
    private struct KeyInfo: Identifiable {
        let id: Int           // unique across all 24 chromatic positions
        let pitchClass: Int
        let chromaticIndex: Int
        let isBlack: Bool
        let whiteKeyPosition: Int  // 0-13 for white keys; for black keys, the white key to its left
    }

    private static let allKeys: [KeyInfo] = {
        // Two octaves: chromatic indices 0-23
        // White key positions increment only for white keys
        var keys: [KeyInfo] = []
        let isBlack = [false, true, false, true, false, false, true, false, true, false, true, false]
        var whitePos = 0
        for i in 0..<24 {
            let semitone = i % 12
            let octaveOffset = (i / 12) * 7  // white key offset per octave
            let black = isBlack[semitone]

            // White key position within this octave
            let whitePositionsForSemitone = [0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6]
            let localWhitePos = whitePositionsForSemitone[semitone]
            let globalWhitePos = localWhitePos + octaveOffset

            keys.append(KeyInfo(
                id: i,
                pitchClass: semitone,
                chromaticIndex: i,
                isBlack: black,
                whiteKeyPosition: globalWhitePos
            ))
        }
        return keys
    }()

    private static let whiteKeys: [KeyInfo] = allKeys.filter { !$0.isBlack }
    private static let blackKeys: [KeyInfo] = allKeys.filter { $0.isBlack }

    /// The chromatic range to highlight: from the first instance of the tonic
    /// through one octave (12 semitones), inclusive of both endpoints.
    private var highlightChromaticRange: ClosedRange<Int> {
        let tonicPC = displayContext.tonic.value
        // First occurrence of the tonic in our two-octave span
        let start = tonicPC  // In the first octave, the tonic's chromatic index equals its pitch class
        return start...(start + 12)
    }

    /// Whether a key at a given chromatic index should be highlighted.
    private func isHighlighted(key: KeyInfo) -> Bool {
        guard highlightChromaticRange.contains(key.chromaticIndex) else { return false }
        return displayContext.pitchClassSet.contains(key.pitchClass)
    }

    /// Whether a key is the tonic within the highlighted range.
    private func isTonic(key: KeyInfo) -> Bool {
        key.pitchClass == displayContext.tonic.value && highlightChromaticRange.contains(key.chromaticIndex)
    }

    // Colours — opaque fills only; no transparency over key gaps
    private let highlightColor = Color(red: 0.65, green: 0.85, blue: 0.65)
    private let highlightBlackColor = Color(red: 0.3, green: 0.55, blue: 0.3)
    private let tonicColor = Color.green
    private let tonicBorderColor = Color(white: 0.25)
    private let keyBorderColor = Color(white: 0.45)

    var body: some View {
        GeometryReader { geo in
            let whiteKeyWidth = geo.size.width / 14.0
            let whiteKeyHeight = geo.size.height
            let blackKeyWidth = whiteKeyWidth * 0.6
            let blackKeyHeight = whiteKeyHeight * 0.6

            ZStack(alignment: .topLeading) {
                // White keys
                HStack(spacing: 0) {
                    ForEach(Self.whiteKeys) { key in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(whiteKeyColor(key: key))
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(isTonic(key: key) ? tonicBorderColor : keyBorderColor,
                                            lineWidth: isTonic(key: key) ? 3 : 1)
                            )
                            .frame(width: whiteKeyWidth, height: whiteKeyHeight)
                    }
                }

                // Black keys
                ForEach(Self.blackKeys) { key in
                    let xOffset = (CGFloat(key.whiteKeyPosition) + 1) * whiteKeyWidth - blackKeyWidth / 2
                    RoundedRectangle(cornerRadius: 2)
                        .fill(blackKeyColor(key: key))
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(isTonic(key: key) ? tonicBorderColor : keyBorderColor,
                                        lineWidth: isTonic(key: key) ? 3 : 1)
                        )
                        .frame(width: blackKeyWidth, height: blackKeyHeight)
                        .offset(x: xOffset)
                }
            }
        }
    }

    private func whiteKeyColor(key: KeyInfo) -> Color {
        if isTonic(key: key) { return tonicColor }
        if isHighlighted(key: key) { return highlightColor }
        return Color.white
    }

    private func blackKeyColor(key: KeyInfo) -> Color {
        if isTonic(key: key) { return tonicColor }
        if isHighlighted(key: key) { return highlightBlackColor }
        return Color(white: 0.15)
    }
}
