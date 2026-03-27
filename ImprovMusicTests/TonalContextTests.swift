import XCTest
@testable import ImprovMusic

final class TonalContextTests: XCTestCase {

    // MARK: - Pitch class set

    func test_cMajor_pitchClassSet() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        XCTAssertEqual(ctx.pitchClassSet, [0, 2, 4, 5, 7, 9, 11])
    }

    func test_dDorian_pitchClassSet() {
        let ctx = TonalContext(tonic: .d, scaleType: .dorian)
        // D Dorian shares the C major collection
        XCTAssertEqual(ctx.pitchClassSet, [0, 2, 4, 5, 7, 9, 11])
    }

    // MARK: - Display names

    func test_displayName_cMajor() {
        let ctx = TonalContext(tonic: .c, scaleType: .major)
        XCTAssertEqual(ctx.displayName, "C Major")
    }

    func test_displayName_dDorian() {
        let ctx = TonalContext(tonic: .d, scaleType: .dorian)
        XCTAssertEqual(ctx.displayName, "D Dorian")
    }

    func test_displayName_bbMinor() {
        let ctx = TonalContext(tonic: PitchClass(10), scaleType: .naturalMinor)
        XCTAssertEqual(ctx.displayName, "B♭ Minor")
    }

    func test_displayName_fSharpMajor() {
        // F#/Gb major — pitch class 6. For major, preference is flat (Gb)
        let ctx = TonalContext(tonic: .fs, scaleType: .major)
        XCTAssertEqual(ctx.displayName, "G♭ Major")
    }

    // MARK: - Scale distance (symmetric difference)

    func test_scaleDistance_cMajor_to_gMajor() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let g = TonalContext(tonic: .g, scaleType: .major)
        // C major: {0,2,4,5,7,9,11}, G major: {0,2,4,6,7,9,11}
        // Symmetric diff: {5, 6} → size 2
        XCTAssertEqual(c.scaleDistance(to: g), 2)
    }

    func test_scaleDistance_cMajor_to_aMinor_isZero() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let a = TonalContext(tonic: .a, scaleType: .naturalMinor)
        // Relative keys share the same pitch set
        XCTAssertEqual(c.scaleDistance(to: a), 0)
    }

    func test_scaleDistance_cMajor_to_cMixolydian() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let cMix = TonalContext(tonic: .c, scaleType: .mixolydian)
        // C major: {0,2,4,5,7,9,11}, C Mixolydian: {0,2,4,5,7,9,10}
        // Symmetric diff: {10, 11} → size 2
        XCTAssertEqual(c.scaleDistance(to: cMix), 2)
    }

    func test_scaleDistance_isSymmetric() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let g = TonalContext(tonic: .g, scaleType: .major)
        XCTAssertEqual(c.scaleDistance(to: g), g.scaleDistance(to: c))
    }

    // MARK: - Region distance

    func test_regionDistance_cMajor_to_gMajor_is1() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let g = TonalContext(tonic: .g, scaleType: .major)
        XCTAssertEqual(c.regionDistance(to: g), 1)
    }

    func test_regionDistance_cMajor_to_aMinor_is0() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let a = TonalContext(tonic: .a, scaleType: .naturalMinor)
        // Relative keys share the same diatonic collection
        XCTAssertEqual(c.regionDistance(to: a), 0)
    }

    func test_regionDistance_cMajor_to_dDorian_is0() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let d = TonalContext(tonic: .d, scaleType: .dorian)
        // D Dorian is a mode of C major
        XCTAssertEqual(c.regionDistance(to: d), 0)
    }

    func test_regionDistance_cMajor_to_dMajor_is2() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let d = TonalContext(tonic: .d, scaleType: .major)
        XCTAssertEqual(c.regionDistance(to: d), 2)
    }

    func test_regionDistance_cMajor_to_fsMajor_is6() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let fs = TonalContext(tonic: .fs, scaleType: .major)
        XCTAssertEqual(c.regionDistance(to: fs), 6)
    }

    // MARK: - Tonic distance

    func test_tonicDistance_C_to_G_is1() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let g = TonalContext(tonic: .g, scaleType: .major)
        XCTAssertEqual(c.tonicDistance(to: g), 1)
    }

    func test_tonicDistance_C_to_A_is3() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let a = TonalContext(tonic: .a, scaleType: .naturalMinor)
        XCTAssertEqual(c.tonicDistance(to: a), 3)
    }

    // MARK: - Mode distance

    func test_modeDistance_cMajor_to_cMixolydian_is1() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let cMix = TonalContext(tonic: .c, scaleType: .mixolydian)
        XCTAssertEqual(c.modeDistance(to: cMix), 1)
    }

    func test_modeDistance_cMajor_to_cLydian_is1() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let cLyd = TonalContext(tonic: .c, scaleType: .lydian)
        XCTAssertEqual(c.modeDistance(to: cLyd), 1)
    }

    func test_modeDistance_differentTonics_isNil() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        let g = TonalContext(tonic: .g, scaleType: .major)
        XCTAssertNil(c.modeDistance(to: g))
    }

    func test_modeDistance_sameTonic_sameMode_is0() {
        let c = TonalContext(tonic: .c, scaleType: .major)
        XCTAssertEqual(c.modeDistance(to: c), 0)
    }

    // MARK: - All contexts

    func test_allContexts_has72() {
        XCTAssertEqual(TonalContext.all.count, 72)
    }

    func test_allContexts_uniqueIds() {
        let ids = TonalContext.all.map(\.id)
        XCTAssertEqual(Set(ids).count, 72)
    }
}
