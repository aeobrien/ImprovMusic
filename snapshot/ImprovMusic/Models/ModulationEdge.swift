import Foundation

/// The type of modulation technique an edge represents.
enum ModulationTechnique: String, Hashable, Sendable {
    case pivotChord
    case commonTone
    case mixtureAssisted
    case direct
    case enharmonicReinterpretation
}

/// Evidence supporting a modulation edge — the specific musical material
/// that enables this modulation.
enum ModulationEvidence: Hashable, Sendable {
    /// A pivot chord shared between both keys, with its function in each.
    case pivot(chord: DiatonicChord, functionInSource: String, functionInTarget: String)

    /// A common tone connecting a chord in the source to a chord in the target.
    case commonTone(pitchClass: PitchClass, sourceChord: DiatonicChord, targetChord: DiatonicChord)

    /// A borrowed chord from mode mixture used as a pivot.
    case mixturePivot(borrowedChord: DiatonicChord, functionInTarget: String)

    /// Direct modulation — no specific pivot material.
    case direct

    /// An enharmonic reinterpretation of a chord.
    case enharmonic(sourceChord: DiatonicChord, reinterpretedAs: String)
}

/// A directed edge in the modulation graph, representing a single-step modulation
/// from one tonal context to another using a specific technique.
struct ModulationEdge: Hashable, Sendable {
    /// The source tonal context.
    let source: TonalContext

    /// The target tonal context.
    let target: TonalContext

    /// The modulation technique this edge represents.
    let technique: ModulationTechnique

    /// The composite difficulty cost of this edge.
    let cost: Double

    /// The musical evidence supporting this modulation.
    let evidence: ModulationEvidence
}
