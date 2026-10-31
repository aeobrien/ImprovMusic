import SwiftUI

/// Displays the current key and optional target key names.
struct KeyDisplayView: View {
    let currentContext: TonalContext
    let challenge: Challenge?

    var body: some View {
        HStack(spacing: 20) {
            // Current key
            VStack(spacing: 4) {
                Text("Current")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(currentContext.displayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.green)
            }

            if let challenge = challenge {
                Image(systemName: "arrow.right")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.tertiary)

                // Target key
                VStack(spacing: 4) {
                    Text("Target")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(challenge.target.displayName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.purple)
                }

                // Tier badge
                Text(challenge.tier.shortName)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(tierColor(challenge.tier).opacity(0.15))
                    .foregroundStyle(tierColor(challenge.tier))
                    .clipShape(Capsule())
            }
        }
    }

    private func tierColor(_ tier: DifficultyTier) -> Color {
        switch tier {
        case .modalShift:     return .green
        case .closelyRelated: return .blue
        case .moderate:       return .orange
        case .distant:        return .red
        case .remote:         return .purple
        }
    }
}
