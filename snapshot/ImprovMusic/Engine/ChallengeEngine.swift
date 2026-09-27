import Foundation
import Combine

/// The result of generating a challenge.
struct Challenge: Sendable {
    let target: TonalContext
    let tier: DifficultyTier
    let hintPaths: [ModulationPath]
}

/// The main challenge engine. Manages the current tonal context, generates challenges,
/// handles tier filtering, and provides hints.
@MainActor
final class ChallengeEngine: ObservableObject {

    // MARK: - Published state

    @Published private(set) var currentContext: TonalContext
    @Published private(set) var currentChallenge: Challenge?
    @Published var maxTier: DifficultyTier = .closelyRelated
    @Published var triggerMode: TriggerMode = .manual
    @Published var timerInterval: TimeInterval = 60.0

    // MARK: - Private state

    private let graph: ModulationGraph
    private var recentlyVisited: [TonalContext] = []
    private let recentBufferSize = 5
    private var timer: Timer?

    // MARK: - Init

    init(graph: ModulationGraph, startingContext: TonalContext) {
        self.graph = graph
        self.currentContext = startingContext
    }

    convenience init(startingContext: TonalContext) {
        let graph = GraphBuilder.build()
        self.init(graph: graph, startingContext: startingContext)
    }

    // MARK: - Challenge generation

    /// Generate a new challenge. Advances current key to previous target first.
    func generateChallenge() {
        // Arrival: advance to previous target
        if let challenge = currentChallenge {
            advanceTo(challenge.target)
        }

        // Find valid targets at current tier
        var candidates = findCandidates(at: maxTier)

        // Sparse pool fallback: widen by one tier if fewer than 3 candidates
        var effectiveTier = maxTier
        while candidates.count < 3 && effectiveTier < .remote {
            effectiveTier = DifficultyTier(rawValue: effectiveTier.rawValue + 1)!
            candidates = findCandidates(at: effectiveTier)
        }

        guard !candidates.isEmpty else { return }

        // Select target, weighted to avoid recently visited
        let target = selectTarget(from: candidates)

        // Determine the tier of the best edge to this target
        let edgesToTarget = graph.edges(from: currentContext, to: target)
        let bestEdge = edgesToTarget.min(by: { $0.cost < $1.cost })
        let vector = DistanceVector.compute(from: currentContext, to: target)
        let tier = bestEdge.map { DifficultyTier.assign(for: $0, vector: vector) } ?? effectiveTier

        // Compute hint paths
        let hintPaths = Pathfinder.diverseHintPaths(
            in: graph, from: currentContext, to: target, k: 3
        )

        currentChallenge = Challenge(target: target, tier: tier, hintPaths: hintPaths)
    }

    /// Set the current context directly (for initial key selection).
    func setCurrentContext(_ context: TonalContext) {
        currentContext = context
        currentChallenge = nil
        recentlyVisited.removeAll()
    }

    /// Set to a random starting context.
    func randomiseStartingKey() {
        let context = TonalContext.all.randomElement()!
        setCurrentContext(context)
    }

    // MARK: - Timer

    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.generateChallenge()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateTriggerMode(_ mode: TriggerMode) {
        triggerMode = mode
        switch mode {
        case .manual:
            stopTimer()
        case .timer:
            startTimer()
        }
    }

    // MARK: - Private

    /// Advance the current context to a new context (arrival mechanism).
    private func advanceTo(_ context: TonalContext) {
        recentlyVisited.append(currentContext)
        if recentlyVisited.count > recentBufferSize {
            recentlyVisited.removeFirst()
        }
        currentContext = context
    }

    /// Find all distinct target contexts reachable at or below the given tier.
    private func findCandidates(at maxTier: DifficultyTier) -> [TonalContext] {
        let edges = graph.edges(from: currentContext)
        var seen: Set<Int> = []
        var candidates: [TonalContext] = []

        for edge in edges {
            let vector = DistanceVector.compute(from: currentContext, to: edge.target)
            let tier = DifficultyTier.assign(for: edge, vector: vector)
            if tier <= maxTier && !seen.contains(edge.target.id) {
                seen.insert(edge.target.id)
                candidates.append(edge.target)
            }
        }
        return candidates
    }

    /// Select a target from candidates, weighted to:
    /// 1. Avoid recently visited keys
    /// 2. Strongly prefer major and minor keys over modes
    private func selectTarget(from candidates: [TonalContext]) -> TonalContext {
        let recentIds = Set(recentlyVisited.map(\.id))

        // Filter out recently visited
        let fresh = candidates.filter { !recentIds.contains($0.id) }
        let pool = fresh.isEmpty ? candidates : fresh

        // Build weighted pool: major/minor get 5x weight, modes get 1x
        var weighted: [TonalContext] = []
        for candidate in pool {
            let weight = candidate.scaleType.isStandardKey ? 5 : 1
            for _ in 0..<weight {
                weighted.append(candidate)
            }
        }

        return weighted.randomElement() ?? candidates.randomElement()!
    }
}

// MARK: - Trigger mode

enum TriggerMode: String, Sendable {
    case manual
    case timer
}
