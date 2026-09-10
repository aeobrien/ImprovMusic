import Foundation

/// The five difficulty tiers for modulation challenges.
/// Assignment is rule-based, checking edge properties against categorical criteria.
enum DifficultyTier: Int, CaseIterable, Comparable, Sendable {
    case modalShift = 1
    case closelyRelated = 2
    case moderate = 3
    case distant = 4
    case remote = 5

    var displayName: String {
        switch self {
        case .modalShift:     return "Tier 1 — Modal Shift"
        case .closelyRelated: return "Tier 2 — Closely Related"
        case .moderate:       return "Tier 3 — Moderate"
        case .distant:        return "Tier 4 — Distant"
        case .remote:         return "Tier 5 — Remote"
        }
    }

    var shortName: String {
        switch self {
        case .modalShift:     return "1"
        case .closelyRelated: return "2"
        case .moderate:       return "3"
        case .distant:        return "4"
        case .remote:         return "5"
        }
    }

    static func < (lhs: DifficultyTier, rhs: DifficultyTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Assign a difficulty tier to an edge based on its properties.
    /// This is rule-based — it checks the edge's technique, distance components,
    /// and pivot availability rather than mapping a continuous cost to a range.
    static func assign(for edge: ModulationEdge, vector: DistanceVector) -> DifficultyTier {
        // Tier 1 — Modal shift: same tonic, one colour-note difference
        if edge.source.tonic == edge.target.tonic,
           let modeDist = vector.modeDistance, modeDist == 1 {
            return .modalShift
        }

        // Tier 2 — Closely related: Δregion ≤ 1 with pivot, or relative keys (same pitch set)
        if vector.scaleDistance == 0 && vector.tonicDistance > 0 {
            // Relative keys (shared pitch set, different tonic)
            return .closelyRelated
        }
        if vector.regionDistance <= 1 && edge.technique == .pivotChord {
            return .closelyRelated
        }
        if vector.regionDistance <= 1 && vector.commonTriadCount >= 3 {
            return .closelyRelated
        }

        // Tier 3 — Moderate: parallel keys, or Δregion = 2 with good pivots
        if edge.source.tonic == edge.target.tonic && vector.modeDistance == nil {
            // Same tonic, different major/minor (parallel key) — shouldn't happen with our
            // mode distance check, but guard for clarity
            return .moderate
        }
        if isParallelKey(edge.source, edge.target) {
            return .moderate
        }
        if vector.regionDistance == 2 && vector.commonTriadCount >= 2 {
            return .moderate
        }
        if vector.regionDistance == 2 && edge.technique == .pivotChord {
            return .moderate
        }

        // Tier 5 — Remote: enharmonic reinterpretation or very distant
        if edge.technique == .enharmonicReinterpretation {
            return .remote
        }
        if vector.regionDistance >= 5 {
            return .remote
        }

        // Tier 4 — Distant: everything else (mixture-assisted, common-tone for distant keys, etc.)
        return .distant
    }

    /// Check if two contexts are parallel keys (same tonic, one major, one minor).
    private static func isParallelKey(_ a: TonalContext, _ b: TonalContext) -> Bool {
        guard a.tonic == b.tonic else { return false }
        let types: Set<ScaleType> = [a.scaleType, b.scaleType]
        return types == [.major, .naturalMinor]
    }
}
