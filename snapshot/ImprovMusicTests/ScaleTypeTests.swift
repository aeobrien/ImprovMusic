import XCTest
@testable import ImprovMusic

final class ScaleTypeTests: XCTestCase {

    // MARK: - Interval recipes

    func test_intervals_sumTo12() {
        for scaleType in ScaleType.allCases {
            XCTAssertEqual(scaleType.intervals.reduce(0, +), 12,
                           "\(scaleType) intervals don't sum to 12")
        }
    }

    func test_intervals_have7Steps() {
        for scaleType in ScaleType.allCases {
            XCTAssertEqual(scaleType.intervals.count, 7,
                           "\(scaleType) should have 7 interval steps")
        }
    }

    // MARK: - Pitch class generation

    func test_cMajor_pitchClasses() {
        let expected: Set<Int> = [0, 2, 4, 5, 7, 9, 11]
        XCTAssertEqual(ScaleType.major.pitchClasses(from: .c), expected)
    }

    func test_aMinor_pitchClasses() {
        // A natural minor = A B C D E F G = {9, 11, 0, 2, 4, 5, 7}
        let expected: Set<Int> = [0, 2, 4, 5, 7, 9, 11]
        XCTAssertEqual(ScaleType.naturalMinor.pitchClasses(from: .a), expected)
    }

    func test_dDorian_pitchClasses() {
        // D Dorian = D E F G A B C = {2, 4, 5, 7, 9, 11, 0}
        let expected: Set<Int> = [0, 2, 4, 5, 7, 9, 11]
        XCTAssertEqual(ScaleType.dorian.pitchClasses(from: .d), expected)
    }

    func test_gMixolydian_pitchClasses() {
        // G Mixolydian = G A B C D E F = {7, 9, 11, 0, 2, 4, 5}
        let expected: Set<Int> = [0, 2, 4, 5, 7, 9, 11]
        XCTAssertEqual(ScaleType.mixolydian.pitchClasses(from: .g), expected)
    }

    func test_fLydian_pitchClasses() {
        // F Lydian = F G A B C D E = {5, 7, 9, 11, 0, 2, 4}
        let expected: Set<Int> = [0, 2, 4, 5, 7, 9, 11]
        XCTAssertEqual(ScaleType.lydian.pitchClasses(from: .f), expected)
    }

    func test_ePhrygian_pitchClasses() {
        // E Phrygian = E F G A B C D = {4, 5, 7, 9, 11, 0, 2}
        let expected: Set<Int> = [0, 2, 4, 5, 7, 9, 11]
        XCTAssertEqual(ScaleType.phrygian.pitchClasses(from: .e), expected)
    }

    func test_allModesOfC_shareSamePitchSet() {
        // All modes rooted on their natural degree of C major share the C major pitch set
        let cMajorPitches = ScaleType.major.pitchClasses(from: .c)
        XCTAssertEqual(ScaleType.dorian.pitchClasses(from: .d), cMajorPitches)
        XCTAssertEqual(ScaleType.phrygian.pitchClasses(from: .e), cMajorPitches)
        XCTAssertEqual(ScaleType.lydian.pitchClasses(from: .f), cMajorPitches)
        XCTAssertEqual(ScaleType.mixolydian.pitchClasses(from: .g), cMajorPitches)
        XCTAssertEqual(ScaleType.naturalMinor.pitchClasses(from: .a), cMajorPitches)
    }

    func test_gMajor_pitchClasses() {
        // G major = G A B C D E F# = {7, 9, 11, 0, 2, 4, 6}
        let expected: Set<Int> = [0, 2, 4, 6, 7, 9, 11]
        XCTAssertEqual(ScaleType.major.pitchClasses(from: .g), expected)
    }

    // MARK: - Scale degrees

    func test_cMajor_scaleDegrees() {
        let degrees = ScaleType.major.scaleDegrees(from: .c)
        XCTAssertEqual(degrees.count, 7)
        XCTAssertEqual(degrees.map(\.value), [0, 2, 4, 5, 7, 9, 11])
    }

    // MARK: - Colour-note distances

    func test_colourNote_majorToMajor_is0() {
        XCTAssertEqual(ScaleType.major.colourNoteDistance, 0)
    }

    func test_colourNote_minorToMinor_is0() {
        XCTAssertEqual(ScaleType.naturalMinor.colourNoteDistance, 0)
    }

    func test_colourNote_lydian_is1() {
        // Lydian differs from major by raised 4th
        XCTAssertEqual(ScaleType.lydian.colourNoteDistance, 1)
    }

    func test_colourNote_mixolydian_is1() {
        // Mixolydian differs from major by lowered 7th
        XCTAssertEqual(ScaleType.mixolydian.colourNoteDistance, 1)
    }

    func test_colourNote_dorian_is1() {
        // Dorian differs from natural minor by raised 6th
        XCTAssertEqual(ScaleType.dorian.colourNoteDistance, 1)
    }

    func test_colourNote_phrygian_is1() {
        // Phrygian differs from natural minor by lowered 2nd
        XCTAssertEqual(ScaleType.phrygian.colourNoteDistance, 1)
    }

    // MARK: - Major-ish / Minor-ish classification

    func test_majorish() {
        XCTAssertTrue(ScaleType.major.isMajorish)
        XCTAssertTrue(ScaleType.lydian.isMajorish)
        XCTAssertTrue(ScaleType.mixolydian.isMajorish)
    }

    func test_minorish() {
        XCTAssertFalse(ScaleType.naturalMinor.isMajorish)
        XCTAssertFalse(ScaleType.dorian.isMajorish)
        XCTAssertFalse(ScaleType.phrygian.isMajorish)
    }

    // MARK: - Parent major tonic

    func test_parentMajor_Cmajor_isC() {
        XCTAssertEqual(ScaleType.major.parentMajorTonic(from: .c), .c)
    }

    func test_parentMajor_DDorian_isC() {
        XCTAssertEqual(ScaleType.dorian.parentMajorTonic(from: .d), .c)
    }

    func test_parentMajor_AMinor_isC() {
        XCTAssertEqual(ScaleType.naturalMinor.parentMajorTonic(from: .a), .c)
    }

    func test_parentMajor_EPhrygian_isC() {
        XCTAssertEqual(ScaleType.phrygian.parentMajorTonic(from: .e), .c)
    }

    func test_parentMajor_FLydian_isC() {
        XCTAssertEqual(ScaleType.lydian.parentMajorTonic(from: .f), .c)
    }

    func test_parentMajor_GMixolydian_isC() {
        XCTAssertEqual(ScaleType.mixolydian.parentMajorTonic(from: .g), .c)
    }

    // MARK: - Diatonic collection ID

    func test_diatonicCollectionId_sameForAllModesOfC() {
        let cId = ScaleType.major.diatonicCollectionId(from: .c)
        XCTAssertEqual(ScaleType.dorian.diatonicCollectionId(from: .d), cId)
        XCTAssertEqual(ScaleType.naturalMinor.diatonicCollectionId(from: .a), cId)
    }

    func test_diatonicCollectionId_differsBetweenKeys() {
        let cId = ScaleType.major.diatonicCollectionId(from: .c)
        let gId = ScaleType.major.diatonicCollectionId(from: .g)
        XCTAssertNotEqual(cId, gId)
    }
}
