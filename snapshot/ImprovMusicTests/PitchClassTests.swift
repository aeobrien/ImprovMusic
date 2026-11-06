import XCTest
@testable import ImprovMusic

final class PitchClassTests: XCTestCase {

    // MARK: - Construction

    func test_pitchClass_wrapsAt12() {
        XCTAssertEqual(PitchClass(12).value, 0)
        XCTAssertEqual(PitchClass(13).value, 1)
        XCTAssertEqual(PitchClass(-1).value, 11)
        XCTAssertEqual(PitchClass(-12).value, 0)
    }

    func test_pitchClass_namedConstructors() {
        XCTAssertEqual(PitchClass.c.value, 0)
        XCTAssertEqual(PitchClass.cs.value, 1)
        XCTAssertEqual(PitchClass.d.value, 2)
        XCTAssertEqual(PitchClass.e.value, 4)
        XCTAssertEqual(PitchClass.f.value, 5)
        XCTAssertEqual(PitchClass.fs.value, 6)
        XCTAssertEqual(PitchClass.g.value, 7)
        XCTAssertEqual(PitchClass.a.value, 9)
        XCTAssertEqual(PitchClass.b.value, 11)
    }

    // MARK: - Circle of fifths distance

    func test_fifthsDistance_unison() {
        XCTAssertEqual(PitchClass.c.fifthsDistance(to: .c), 0)
    }

    func test_fifthsDistance_C_to_G_is1() {
        XCTAssertEqual(PitchClass.c.fifthsDistance(to: .g), 1)
    }

    func test_fifthsDistance_C_to_F_is1() {
        XCTAssertEqual(PitchClass.c.fifthsDistance(to: .f), 1)
    }

    func test_fifthsDistance_C_to_D_is2() {
        XCTAssertEqual(PitchClass.c.fifthsDistance(to: .d), 2)
    }

    func test_fifthsDistance_C_to_Fs_is6() {
        XCTAssertEqual(PitchClass.c.fifthsDistance(to: .fs), 6)
    }

    func test_fifthsDistance_isSymmetric() {
        XCTAssertEqual(PitchClass.c.fifthsDistance(to: .e), PitchClass.e.fifthsDistance(to: .c))
        XCTAssertEqual(PitchClass.g.fifthsDistance(to: .d), PitchClass.d.fifthsDistance(to: .g))
    }

    func test_fifthsDistance_C_to_A_is3() {
        XCTAssertEqual(PitchClass.c.fifthsDistance(to: .a), 3)
    }

    func test_fifthsDistance_C_to_Eb_is3() {
        XCTAssertEqual(PitchClass.c.fifthsDistance(to: .ds), 3)
    }

    // MARK: - Transposition

    func test_transposed_up() {
        XCTAssertEqual(PitchClass.c.transposed(by: 7), .g)
    }

    func test_transposed_wraps() {
        XCTAssertEqual(PitchClass.a.transposed(by: 5), PitchClass(2)) // A + 5 = D
    }

    // MARK: - Spelling

    func test_spelling_sharpNames() {
        XCTAssertEqual(PitchSpelling.name(for: .cs, preferring: .sharp), "C♯")
        XCTAssertEqual(PitchSpelling.name(for: .c, preferring: .sharp), "C")
    }

    func test_spelling_flatNames() {
        XCTAssertEqual(PitchSpelling.name(for: .cs, preferring: .flat), "D♭")
        XCTAssertEqual(PitchSpelling.name(for: .ds, preferring: .flat), "E♭")
    }

    func test_spelling_majorKeyPreference_C_isNatural() {
        XCTAssertEqual(PitchSpelling.preferenceForMajorKey(tonic: .c), .natural)
    }

    func test_spelling_majorKeyPreference_G_isSharp() {
        XCTAssertEqual(PitchSpelling.preferenceForMajorKey(tonic: .g), .sharp)
    }

    func test_spelling_majorKeyPreference_F_isFlat() {
        XCTAssertEqual(PitchSpelling.preferenceForMajorKey(tonic: .f), .flat)
    }

    func test_spelling_Db_major_tonic_isDb() {
        let name = PitchSpelling.tonicName(pitchClass: PitchClass(1), scaleType: .major)
        XCTAssertEqual(name, "D♭")
    }

    func test_spelling_Cs_minor_tonic_isCSharp() {
        // C# minor's parent major is E major (sharp key)
        let name = PitchSpelling.tonicName(pitchClass: PitchClass(1), scaleType: .naturalMinor)
        XCTAssertEqual(name, "C♯")
    }

    func test_spelling_Bb_major_tonic_isBb() {
        let name = PitchSpelling.tonicName(pitchClass: PitchClass(10), scaleType: .major)
        XCTAssertEqual(name, "B♭")
    }
}
