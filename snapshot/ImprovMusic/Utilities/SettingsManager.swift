import Foundation

/// Persists and restores user settings via UserDefaults.
@MainActor
enum SettingsManager {
    private static let defaults = UserDefaults.standard

    private enum Keys {
        static let currentTonic = "currentTonic"
        static let currentScaleType = "currentScaleType"
        static let maxTier = "maxTier"
        static let triggerMode = "triggerMode"
        static let timerInterval = "timerInterval"
    }

    // MARK: - Save

    static func save(engine: ChallengeEngine) {
        defaults.set(engine.currentContext.tonic.value, forKey: Keys.currentTonic)
        defaults.set(engine.currentContext.scaleType.rawValue, forKey: Keys.currentScaleType)
        defaults.set(engine.maxTier.rawValue, forKey: Keys.maxTier)
        defaults.set(engine.triggerMode.rawValue, forKey: Keys.triggerMode)
        defaults.set(engine.timerInterval, forKey: Keys.timerInterval)
    }

    // MARK: - Restore

    static func restoredContext() -> TonalContext {
        let tonic = defaults.object(forKey: Keys.currentTonic) as? Int ?? 0
        let scaleRaw = defaults.string(forKey: Keys.currentScaleType) ?? ScaleType.major.rawValue
        let scaleType = ScaleType(rawValue: scaleRaw) ?? .major
        return TonalContext(tonic: PitchClass(tonic), scaleType: scaleType)
    }

    static func restoredMaxTier() -> DifficultyTier {
        let raw = defaults.object(forKey: Keys.maxTier) as? Int ?? DifficultyTier.closelyRelated.rawValue
        return DifficultyTier(rawValue: raw) ?? .closelyRelated
    }

    static func restoredTriggerMode() -> TriggerMode {
        let raw = defaults.string(forKey: Keys.triggerMode) ?? TriggerMode.manual.rawValue
        return TriggerMode(rawValue: raw) ?? .manual
    }

    static func restoredTimerInterval() -> TimeInterval {
        let interval = defaults.double(forKey: Keys.timerInterval)
        return interval >= 60 ? interval : 60.0
    }
}
