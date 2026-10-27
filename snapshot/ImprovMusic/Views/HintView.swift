import SwiftUI

/// Progressive disclosure hint view showing modulation route suggestions.
struct HintView: View {
    let challenge: Challenge
    let sourceContext: TonalContext
    @State private var revealedSteps = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if challenge.hintPaths.isEmpty {
                Text("No hints available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                let path = challenge.hintPaths[0]

                if path.steps.count == 1 {
                    // Single-step: show technique and evidence directly
                    singleStepHint(path.steps[0])
                } else {
                    // Multi-step: progressive disclosure
                    multiStepHint(path)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func singleStepHint(_ step: HintStep) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(techniqueLabel(step.technique))
                .font(.subheadline.bold())
                .foregroundStyle(.blue)
            Text(evidenceDescription(step.evidence, spelling: sourceContext.spellingPreference))
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    private func multiStepHint(_ path: ModulationPath) -> some View {
        HStack(spacing: 8) {
            Text("Route:")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            Text(sourceContext.displayName)
                .font(.subheadline.bold())

            ForEach(0..<path.steps.count, id: \.self) { i in
                if i < revealedSteps {
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text(path.steps[i].context.displayName)
                        .font(.subheadline.bold())
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text("?")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                }
            }
        }

        if revealedSteps > 0 {
            // Show technique detail for the last revealed step
            let stepIndex = revealedSteps - 1
            let step = path.steps[stepIndex]
            HStack(spacing: 4) {
                Text(techniqueLabel(step.technique))
                    .font(.caption.bold())
                    .foregroundStyle(.blue)
                Text(evidenceDescription(step.evidence, spelling: sourceContext.spellingPreference))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        if revealedSteps < path.steps.count {
            Button("Reveal next step") {
                withAnimation(.easeInOut(duration: 0.2)) {
                    revealedSteps += 1
                }
            }
            .font(.caption)
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }

    private func techniqueLabel(_ technique: ModulationTechnique) -> String {
        switch technique {
        case .pivotChord: return "Pivot Chord"
        case .commonTone: return "Common Tone"
        case .mixtureAssisted: return "Mixture"
        case .direct: return "Direct"
        case .enharmonicReinterpretation: return "Enharmonic"
        }
    }

    private func evidenceDescription(_ evidence: ModulationEvidence, spelling: SpellingPreference) -> String {
        switch evidence {
        case .pivot(let chord, let funcSource, let funcTarget):
            let chordName = chord.displayName(spelling: spelling)
            return "\(chordName): \(funcSource) → \(funcTarget)"
        case .commonTone(let pc, let sourceChord, let targetChord):
            let toneName = PitchSpelling.name(for: pc, preferring: spelling)
            let sName = sourceChord.displayName(spelling: spelling)
            let tName = targetChord.displayName(spelling: spelling)
            return "Hold \(toneName) (\(sName) → \(tName))"
        case .mixturePivot(let chord, let funcTarget):
            let chordName = chord.displayName(spelling: spelling)
            return "Borrow \(chordName) → \(funcTarget)"
        case .direct:
            return "Assert new key at phrase boundary"
        case .enharmonic(let chord, let reinterp):
            let chordName = chord.displayName(spelling: spelling)
            return "\(chordName) reinterpreted as \(reinterp)"
        }
    }
}
