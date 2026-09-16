import SwiftUI

struct MainView: View {
    @StateObject private var engine: ChallengeEngine = {
        let context = SettingsManager.restoredContext()
        let engine = ChallengeEngine(startingContext: context)
        engine.maxTier = SettingsManager.restoredMaxTier()
        engine.timerInterval = SettingsManager.restoredTimerInterval()
        let mode = SettingsManager.restoredTriggerMode()
        if mode == .timer {
            engine.updateTriggerMode(.timer)
        }
        return engine
    }()

    @State private var showHints = false

    var body: some View {
        VStack(spacing: 0) {
            // Top: Key display
            KeyDisplayView(
                currentContext: engine.currentContext,
                challenge: engine.currentChallenge
            )
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Middle: Keyboard
            KeyboardView(
                currentContext: engine.currentContext,
                targetContext: engine.currentChallenge?.target
            )
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity)

            // Hint overlay
            if showHints, let challenge = engine.currentChallenge {
                HintView(challenge: challenge, sourceContext: engine.currentContext)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Bottom bar
            HStack(spacing: 16) {
                // Next challenge
                Button {
                    engine.generateChallenge()
                    showHints = false
                    saveSettings()
                } label: {
                    Image(systemName: "forward.fill")
                    Text("Next")
                }
                .font(.body.bold())
                .buttonStyle(.borderedProminent)

                // Hint toggle
                if engine.currentChallenge != nil {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showHints.toggle()
                        }
                    } label: {
                        Image(systemName: showHints ? "eye.slash" : "lightbulb")
                        Text(showHints ? "Hide" : "Hint")
                    }
                    .font(.body)
                    .buttonStyle(.bordered)
                }

                Spacer()

                ControlsView(engine: engine)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .onChange(of: engine.maxTier) { saveSettings() }
        .onChange(of: engine.triggerMode) { saveSettings() }
        .onChange(of: engine.timerInterval) { saveSettings() }
    }

    private func saveSettings() {
        SettingsManager.save(engine: engine)
    }
}

#Preview {
    MainView()
}
