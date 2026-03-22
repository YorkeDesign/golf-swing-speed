import SwiftUI

struct CaptureView: View {
    @State private var swingState: SwingState = .idle
    @State private var lastSpeedMph: Double?
    @State private var isCalibrated = false
    @State private var showCalibration = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview placeholder
                Color.black
                    .ignoresSafeArea()

                // Overlay content
                VStack {
                    Spacer()

                    // State indicator
                    stateIndicator

                    // Speed display
                    if let speed = lastSpeedMph {
                        speedDisplay(speed: speed)
                    }

                    Spacer()

                    // Bottom controls
                    bottomControls
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Calibrate") {
                        showCalibration = true
                    }
                    .tint(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    stateLabel
                }
            }
            .sheet(isPresented: $showCalibration) {
                ManualCalibrationView(isCalibrated: $isCalibrated)
            }
        }
    }

    // MARK: - State Indicator

    @ViewBuilder
    private var stateIndicator: some View {
        switch swingState {
        case .idle:
            Label("Point camera at player", systemImage: "person.fill.viewfinder")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.7))

        case .playerDetected:
            Label("Player detected — take address position", systemImage: "person.fill.checkmark")
                .font(.headline)
                .foregroundStyle(.yellow)

        case .ready:
            Label("READY — Swing when ready", systemImage: "checkmark.circle.fill")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.green)

        case .swingInProgress:
            Label("Capturing...", systemImage: "record.circle")
                .font(.headline)
                .foregroundStyle(.red)

        case .swingComplete, .processing:
            ProgressView("Analysing swing...")
                .tint(.white)
                .foregroundStyle(.white)

        case .result:
            EmptyView()
        }
    }

    // MARK: - Speed Display

    private func speedDisplay(speed: Double) -> some View {
        VStack(spacing: 4) {
            Text(speed.formattedSpeed)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("mph")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        HStack(spacing: 40) {
            if !isCalibrated {
                Button {
                    showCalibration = true
                } label: {
                    VStack {
                        Image(systemName: "scope")
                            .font(.title)
                        Text("Calibrate")
                            .font(.caption)
                    }
                    .foregroundStyle(.white)
                }
            }

            // Manual record button (Phase 1 — before auto-detection)
            Button {
                toggleRecording()
            } label: {
                Circle()
                    .fill(swingState == .swingInProgress ? .red : .white)
                    .frame(width: 72, height: 72)
                    .overlay {
                        if swingState == .swingInProgress {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white)
                                .frame(width: 28, height: 28)
                        }
                    }
            }

            // Club type selector
            Menu {
                ForEach(ClubType.allCases) { club in
                    Button(club.displayName) {
                        // Set selected club
                    }
                }
            } label: {
                VStack {
                    Image(systemName: "figure.golf")
                        .font(.title)
                    Text("Driver")
                        .font(.caption)
                }
                .foregroundStyle(.white)
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - State Label

    private var stateLabel: some View {
        Text(swingState.rawValue.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(stateColor.opacity(0.8), in: Capsule())
    }

    private var stateColor: Color {
        switch swingState {
        case .idle: return .gray
        case .playerDetected: return .yellow
        case .ready: return .green
        case .swingInProgress: return .red
        case .swingComplete, .processing: return .orange
        case .result: return .blue
        }
    }

    // MARK: - Actions

    private func toggleRecording() {
        if swingState == .swingInProgress {
            swingState = .processing
            // Simulate processing delay for Phase 1
            Task {
                try? await Task.sleep(for: .seconds(1))
                lastSpeedMph = Double.random(in: 80...110)
                swingState = .result
            }
        } else {
            swingState = .swingInProgress
        }
    }
}

#Preview {
    CaptureView()
}
