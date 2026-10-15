import SwiftUI

/// Compact controls for difficulty, trigger mode, timer, and starting key.
struct ControlsView: View {
    @ObservedObject var engine: ChallengeEngine
    @State private var showKeyPicker = false

    var body: some View {
        HStack(spacing: 12) {
            // Difficulty tier (dropdown menu)
            Menu {
                ForEach(DifficultyTier.allCases, id: \.self) { tier in
                    Button {
                        engine.maxTier = tier
                    } label: {
                        if tier == engine.maxTier {
                            Label(tier.displayName, systemImage: "checkmark")
                        } else {
                            Text(tier.displayName)
                        }
                    }
                }
            } label: {
                Label("Tier \(engine.maxTier.shortName)", systemImage: "slider.horizontal.3")
                    .font(.subheadline)
            }

            Divider().frame(height: 20)

            // Trigger mode
            Picker("", selection: Binding(
                get: { engine.triggerMode },
                set: { engine.updateTriggerMode($0) }
            )) {
                Text("Tap").tag(TriggerMode.manual)
                Text("Timer").tag(TriggerMode.timer)
            }
            .pickerStyle(.segmented)
            .frame(width: 110)

            if engine.triggerMode == .timer {
                Picker("", selection: $engine.timerInterval) {
                    Text("1 min").tag(60.0 as TimeInterval)
                    Text("2 min").tag(120.0 as TimeInterval)
                    Text("3 min").tag(180.0 as TimeInterval)
                    Text("4 min").tag(240.0 as TimeInterval)
                    Text("5 min").tag(300.0 as TimeInterval)
                }
                .pickerStyle(.menu)
                .onChange(of: engine.timerInterval) {
                    if engine.triggerMode == .timer {
                        engine.startTimer()
                    }
                }
            }

            Divider().frame(height: 20)

            // Key picker
            Button {
                showKeyPicker = true
            } label: {
                Image(systemName: "music.note.list")
                    .font(.body)
            }
            .buttonStyle(.bordered)
            .sheet(isPresented: $showKeyPicker) {
                KeyPickerView(engine: engine, isPresented: $showKeyPicker)
            }
        }
    }
}

/// Sheet for selecting a starting key or randomising.
struct KeyPickerView: View {
    @ObservedObject var engine: ChallengeEngine
    @Binding var isPresented: Bool

    private let scaleTypes = ScaleType.allCases
    private let tonics: [PitchClass] = (0..<12).map { PitchClass($0) }

    var body: some View {
        NavigationStack {
            List {
                Section("Quick Actions") {
                    Button("Randomise") {
                        engine.randomiseStartingKey()
                        isPresented = false
                    }
                }

                ForEach(scaleTypes, id: \.self) { scaleType in
                    Section(scaleType.displayName) {
                        ForEach(tonics, id: \.value) { tonic in
                            let context = TonalContext(tonic: tonic, scaleType: scaleType)
                            Button {
                                engine.setCurrentContext(context)
                                isPresented = false
                            } label: {
                                HStack {
                                    Text(context.displayName)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if engine.currentContext == context {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Starting Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { isPresented = false }
                }
            }
        }
    }
}
