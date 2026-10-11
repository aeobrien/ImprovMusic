import XCTest
@testable import ImprovMusic

final class DistanceVectorTests: XCTestCase {

    // MARK: - Scale distance

    func test_cMajor_to_gMajor_scaleDistance_is2() {
        let v = vector(.c, .major, .g, .major)
        XCTAssertEqual(v.scaleDistance, 2)
    }

    func test_cMajor_to_aMinor_scaleDistance_is0() {
        let v = vector(.c, .major, .a, .naturalMinor)
        XCTAssertEqual(v.scaleDistance, 0) // Relative keys
    }

    // MARK: - Region distance

    func test_cMajor_to_gMajor_regionDistance_is1() {
        let v = vector(.c, .major, .g, .major)
        XCTAssertEqual(v.regionDistance, 1)
    }

    func test_cMajor_to_dDorian_regionDistance_is0() {
        let v = vector(.c, .major, .d, .dorian)
        XCTAssertEqual(v.regionDistance, 0) // Same diatonic collection
    }

    func test_cMajor_to_fsMajor_regionDistance_is6() {
        let v = vector(.c, .major, .fs, .major)
        XCTAssertEqual(v.regionDistance, 6)
    }

    // MARK: - Tonic distance

    func test_cMajor_to_gMajor_tonicDistance_is1() {
        let v = vector(.c, .major, .g, .major)
        XCTAssertEqual(v.tonicDistance, 1)
    }

    func test_cMajor_to_aMinor_tonicDistance_is3() {
        let v = vector(.c, .major, .a, .naturalMinor)
        XCTAssertEqual(v.tonicDistance, 3)
    }

    // MARK: - Mode distance

    func test_cMajor_to_cMixolydian_modeDistance_is1() {
        let v = vector(.c, .major, .c, .mixolydian)
        XCTAssertEqual(v.modeDistance, 1)
    }

    func test_cMajor_to_gMajor_modeDistance_isNil() {
        let v = vector(.c, .major, .g, .major)
        XCTAssertNil(v.modeDistance) // Different tonics
    }

    // MARK: - Common chords

    func test_cMajor_to_gMajor_hasCommonTriads() {
        let v = vector(.c, .major, .g, .major)
        XCTAssertGreaterThan(v.commonTriadCount, 0)
    }

    func test_cMajor_to_fsMajor_hasFewerCommonTriads() {
        let close = vector(.c, .major, .g, .major)
        let distant = vector(.c, .major, .fs, .major)
        XCTAssertGreaterThan(close.commonTriadCount, distant.commonTriadCount)
    }

    // MARK: - Cadence support

    func test_majorTarget_hasLeadingTone() {
        let v = vector(.c, .major, .g, .major)
        XCTAssertTrue(v.targetHasLeadingTone)
    }

    func test_majorTarget_hasMajorDominant() {
        let v = vector(.c, .major, .g, .major)
        XCTAssertTrue(v.targetHasMajorDominant)
    }

    func test_minorTarget_hasLeadingTone_false() {
        // Natural minor lacks a leading tone (has whole step below tonic)
        let v = vector(.c, .major, .a, .naturalMinor)
        XCTAssertFalse(v.targetHasLeadingTone)
    }

    // MARK: - Helpers

    private func vector(
        _ sTonic: PitchClass, _ sType: ScaleType,
        _ tTonic: PitchClass, _ tType: ScaleType
    ) -> DistanceVector {
        let source = TonalContext(tonic: sTonic, scaleType: sType)
        let target = TonalContext(tonic: tTonic, scaleType: tType)
        return DistanceVector.compute(from: source, to: target)
    }
}
