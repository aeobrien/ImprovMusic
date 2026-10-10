import XCTest
@testable import ImprovMusic

final class ChordTests: XCTestCase {

    // MARK: - C Major triads

    func test_cMajor_triads_count() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        XCTAssertEqual(ctx.diatonicTriads.count, 7)
    }

    func test_cMajor_triad_I_isCMajor() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicTriads[0]
        XCTAssertEqual(chord.scaleDegree, 1)
        XCTAssertEqual(chord.root, .c)
        XCTAssertEqual(chord.quality, .major)
        XCTAssertEqual(chord.function, .tonic)
    }

    func test_cMajor_triad_ii_isDMinor() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicTriads[1]
        XCTAssertEqual(chord.scaleDegree, 2)
        XCTAssertEqual(chord.root, .d)
        XCTAssertEqual(chord.quality, .minor)
        XCTAssertEqual(chord.function, .predominant)
    }

    func test_cMajor_triad_iii_isEMinor() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicTriads[2]
        XCTAssertEqual(chord.root, .e)
        XCTAssertEqual(chord.quality, .minor)
    }

    func test_cMajor_triad_IV_isFMajor() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicTriads[3]
        XCTAssertEqual(chord.root, .f)
        XCTAssertEqual(chord.quality, .major)
        XCTAssertEqual(chord.function, .predominant)
    }

    func test_cMajor_triad_V_isGMajor() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicTriads[4]
        XCTAssertEqual(chord.root, .g)
        XCTAssertEqual(chord.quality, .major)
        XCTAssertEqual(chord.function, .dominant)
    }

    func test_cMajor_triad_vi_isAMinor() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicTriads[5]
        XCTAssertEqual(chord.root, .a)
        XCTAssertEqual(chord.quality, .minor)
        XCTAssertEqual(chord.function, .tonic)
    }

    func test_cMajor_triad_vii_isBDiminished() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicTriads[6]
        XCTAssertEqual(chord.root, .b)
        XCTAssertEqual(chord.quality, .diminished)
        XCTAssertEqual(chord.function, .dominant)
    }

    // MARK: - C Major seventh chords

    func test_cMajor_seventh_I_isCMaj7() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicSevenths[0]
        XCTAssertEqual(chord.root, .c)
        XCTAssertEqual(chord.quality, .majorSeventh)
    }

    func test_cMajor_seventh_ii_isDm7() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicSevenths[1]
        XCTAssertEqual(chord.root, .d)
        XCTAssertEqual(chord.quality, .minorSeventh)
    }

    func test_cMajor_seventh_V_isG7() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicSevenths[4]
        XCTAssertEqual(chord.root, .g)
        XCTAssertEqual(chord.quality, .dominantSeventh)
    }

    func test_cMajor_seventh_vii_isBhalfDim() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicSevenths[6]
        XCTAssertEqual(chord.root, .b)
        XCTAssertEqual(chord.quality, .halfDiminished)
    }

    // MARK: - A Minor triads

    func test_aMinor_triad_i_isAMinor() {
        let ctx = TonalContext(tonic: .a, scaleType: .naturalMinor)
        let chord = ctx.diatonicTriads[0]
        XCTAssertEqual(chord.root, .a)
        XCTAssertEqual(chord.quality, .minor)
        XCTAssertEqual(chord.function, .tonic)
    }

    func test_aMinor_triad_III_isCMajor() {
        let ctx = TonalContext(tonic: .a, scaleType: .naturalMinor)
        let chord = ctx.diatonicTriads[2]
        XCTAssertEqual(chord.root, .c)
        XCTAssertEqual(chord.quality, .major)
        XCTAssertEqual(chord.function, .tonic)
    }

    func test_aMinor_triad_v_isEMinor() {
        let ctx = TonalContext(tonic: .a, scaleType: .naturalMinor)
        let chord = ctx.diatonicTriads[4]
        XCTAssertEqual(chord.root, .e)
        XCTAssertEqual(chord.quality, .minor)
        XCTAssertEqual(chord.function, .dominant)
    }

    // MARK: - Modal chords (no forced function labels)

    func test_dDorian_chords_haveUnassignedFunction() {
        let ctx = TonalContext(tonic: .d, scaleType: .dorian)
        for chord in ctx.diatonicTriads {
            XCTAssertEqual(chord.function, .unassigned,
                           "Degree \(chord.scaleDegree) in Dorian should be .unassigned")
        }
    }

    func test_dDorian_triad_I_isDMinor() {
        let ctx = TonalContext(tonic: .d, scaleType: .dorian)
        let chord = ctx.diatonicTriads[0]
        XCTAssertEqual(chord.root, .d)
        XCTAssertEqual(chord.quality, .minor)
    }

    func test_dDorian_triad_IV_isGMajor() {
        // Dorian characteristic: major IV chord (unlike natural minor which has minor iv)
        let ctx = TonalContext(tonic: .d, scaleType: .dorian)
        let chord = ctx.diatonicTriads[3]
        XCTAssertEqual(chord.root, .g)
        XCTAssertEqual(chord.quality, .major)
    }

    // MARK: - Roman numerals

    func test_romanNumeral_I() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        XCTAssertEqual(ctx.diatonicTriads[0].romanNumeral, "I")
    }

    func test_romanNumeral_ii() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        XCTAssertEqual(ctx.diatonicTriads[1].romanNumeral, "ii")
    }

    func test_romanNumeral_viidim() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        XCTAssertEqual(ctx.diatonicTriads[6].romanNumeral, "vii°")
    }

    func test_romanNumeral_V7() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        XCTAssertEqual(ctx.diatonicSevenths[4].romanNumeral, "V7")
    }

    // MARK: - Chord pitch classes

    func test_cMajorTriad_pitchClasses() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicTriads[0]
        XCTAssertEqual(chord.pitchClasses, [0, 4, 7]) // C E G
    }

    func test_dMinorTriad_pitchClasses() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let chord = ctx.diatonicTriads[1]
        XCTAssertEqual(chord.pitchClasses, [2, 5, 9]) // D F A
    }

    // MARK: - Display names

    func test_chordDisplayName_cMajor() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let name = ctx.diatonicTriads[0].displayName(spelling: .natural)
        XCTAssertEqual(name, "C")
    }

    func test_chordDisplayName_dMinor() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let name = ctx.diatonicTriads[1].displayName(spelling: .natural)
        XCTAssertEqual(name, "Dm")
    }

    func test_chordDisplayName_bDim() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        let name = ctx.diatonicTriads[6].displayName(spelling: .natural)
        XCTAssertEqual(name, "Bdim")
    }
}
