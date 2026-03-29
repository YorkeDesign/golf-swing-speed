import SwiftUI
import SwiftData
import AVFoundation

struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var swingState: SwingState = .idle
    @State private var lastSpeedMph: Double?
    @State private var lastFrameCount: Int?
    @State private var lastRecordingURL: URL?
    @State private var showCalibration = false
    @State private var showFrameAnalysis = false
    @State private var selectedClub: ClubType = .driver
    @State private var errorMessage: String?
    @State private var sessionId = UUID()

    @State private var cameraManager = CameraManager()
    @State private var permissionsManager = PermissionsManager()
    @State private var calibrationManager = CalibrationManager()
    @State private var audioFeedback = AudioFeedbackManager()
    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    @State private var cameraConfigured = false
    @State private var showDebugOverlay = false
    @State private var debugHeatmap: [[Double]] = []
    @State private var debugMotionMagnitude: Double = 0
    @State private var debugCentroid: CGPoint?

    // Auto-capture
    @AppStorage("autoCapture") private var autoCaptureEnabled = false
    @State private var captureCoordinator: SwingCaptureCoordinator?
    @State private var analysisProgress: Double = 0
    @State private var analysisPhaseLabel: String = ""
    @State private var showAutoAnalysisResult = false
    @State private var cameraMovementDetector = CameraMovementDetector()

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview or black placeholder
                cameraPreviewContent
                    .ignoresSafeArea()
                    .overlay {
                        if showDebugOverlay {
                            MotionDebugOverlay(
                                heatmap: debugHeatmap,
                                motionMagnitude: debugMotionMagnitude,
                                centroid: debugCentroid,
                                threshold: AppConstants.SwingDetection.motionOnsetThreshold
                            )
                        }
                    }

                // Permission overlay (shown when camera not authorized)
                if !permissionsManager.cameraAuthorized {
                    permissionOverlay
                }

                // Main overlay content (shown when camera authorized)
                if permissionsManager.cameraAuthorized {
                    VStack {
                        // Calibration status badge
                        HStack {
                            CalibrationOverlay(calibrationData: calibrationManager.calibrationData)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 60)

                        Spacer()

                        // State indicator
                        stateIndicator

                        // Auto-capture analysis progress
                        if let coordinator = captureCoordinator,
                           coordinator.state == .analysing {
                            analysisProgressView
                        }

                        // Speed display
                        if let speed = lastSpeedMph {
                            speedDisplay(speed: speed)
                        }

                        // Recording info
                        if let frameCount = lastFrameCount {
                            recordingInfo(frameCount: frameCount)
                        }

                        // Camera movement warning
                        if !cameraMovementDetector.isStable {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                Text(cameraMovementDetector.warningMessage ?? "Camera moved")
                                    .font(.caption)
                                    .foregroundStyle(.yellow)
                            }
                            .padding(8)
                            .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
                        }

                        // Error message
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(8)
                                .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
                        }

                        Spacer()

                        // Bottom controls
                        bottomControls
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if permissionsManager.cameraAuthorized {
                        Button("Calibrate") {
                            showCalibration = true
                        }
                        .tint(.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        Button {
                            showDebugOverlay.toggle()
                        } label: {
                            Image(systemName: showDebugOverlay ? "waveform.circle.fill" : "waveform.circle")
                                .foregroundStyle(showDebugOverlay ? .green : .white)
                        }
                        stateLabel
                    }
                }
            }
            .sheet(isPresented: $showCalibration) {
                ManualCalibrationView(calibrationManager: calibrationManager, cameraManager: cameraManager, audioFeedback: audioFeedback)
            }
            .fullScreenCover(isPresented: $showFrameAnalysis) {
                if let url = lastRecordingURL {
                    FrameAnalysisView(
                        videoURL: url,
                        calibration: calibrationManager.calibrationData
                    ) { speed, profile in
                        if let speed {
                            lastSpeedMph = speed
                            audioFeedback.speedResult(mph: speed)
                        }
                        saveSwingRecord(speed: speed, profile: profile)
                    }
                }
            }
            .task {
                await setupCamera()
            }
        }
    }

    // MARK: - Camera Preview

    @ViewBuilder
    private var cameraPreviewContent: some View {
        if let previewLayer {
            CameraPreviewView(previewLayer: previewLayer)
        } else {
            Color.black
        }
    }

    // MARK: - Permission Overlay

    private var permissionOverlay: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.6))

            Text("Camera Access Required")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Golf Swing Speed App needs access to your camera to record swings at 240fps for speed measurement.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
                VStack(spacing: 12) {
                    Text("Camera access was denied. Please enable it in Settings.")
                        .font(.callout)
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Button("Enable Camera") {
                    Task {
                        _ = await permissionsManager.requestCameraPermission()
                        _ = await permissionsManager.requestMicrophonePermission()
                        if permissionsManager.cameraAuthorized {
                            await setupCamera()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
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
            HStack(spacing: 8) {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)
                Text("Recording...")
                    .font(.headline)
                    .foregroundStyle(.red)
            }

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

    // MARK: - Analysis Progress

    private var analysisProgressView: some View {
        VStack(spacing: 8) {
            ProgressView(value: analysisProgress) {
                Text(analysisPhaseLabel)
                    .font(.caption)
                    .foregroundStyle(.white)
            }
            .tint(.blue)

            Text("\(Int(analysisProgress * 100))%")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .monospacedDigit()
        }
        .padding(16)
        .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 40)
    }

    // MARK: - Recording Info

    private func recordingInfo(frameCount: Int) -> some View {
        Text("\(frameCount) frames captured")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white.opacity(0.8))
            .padding(8)
            .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        HStack(spacing: 40) {
            if !calibrationManager.isCalibrated {
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

            // Record button
            Button {
                Task { await toggleRecording() }
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
                        selectedClub = club
                    }
                }
            } label: {
                VStack {
                    Image(systemName: "figure.golf")
                        .font(.title)
                    Text(selectedClub.displayName)
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

    // MARK: - Camera Setup

    private func setupCamera() async {
        permissionsManager.checkPermissions()
        guard permissionsManager.cameraAuthorized else { return }

        do {
            try await cameraManager.configure()

            // Create preview layer BEFORE starting session — this is fast
            // Starting the session is what takes time, so do that in background
            let layer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
            layer.videoGravity = .resizeAspectFill
            previewLayer = layer
            cameraConfigured = true
            swingState = .idle

            // Start session on background thread so it doesn't block UI
            Task.detached {
                await cameraManager.startSession()
            }

            // Start monitoring camera stability
            cameraMovementDetector.startMonitoring()

            // Initialise capture coordinator for auto-capture mode
            let coordinator = SwingCaptureCoordinator(
                cameraManager: cameraManager,
                audioFeedback: audioFeedback
            )
            coordinator.configure(calibration: calibrationManager.calibrationData)
            captureCoordinator = coordinator
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Recording

    private func toggleRecording() async {
        if swingState == .swingInProgress {
            // Stop recording
            do {
                let url = try await cameraManager.stopRecording()
                let timestamps = await cameraManager.capturedFrameTimestamps
                lastRecordingURL = url
                lastFrameCount = timestamps.count
                audioFeedback.swingCaptured()

                // Run automated analysis if calibrated, otherwise show manual frame viewer
                if calibrationManager.isCalibrated {
                    swingState = .processing
                    await runAutomatedAnalysis(videoURL: url)
                } else {
                    swingState = .result
                    showFrameAnalysis = true
                }
            } catch {
                errorMessage = error.localizedDescription
                swingState = .idle
            }
        } else {
            // Start recording
            do {
                errorMessage = nil
                lastSpeedMph = nil
                lastFrameCount = nil
                _ = try await cameraManager.startRecording()
                swingState = .swingInProgress
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Automated Analysis

    private func runAutomatedAnalysis(videoURL: URL) async {
        guard let calibration = calibrationManager.calibrationData else {
            swingState = .result
            showFrameAnalysis = true
            return
        }

        let engine = PostCaptureAnalysisEngine()
        await engine.setProgressCallback { phase, progress in
            Task { @MainActor in
                analysisPhaseLabel = phase.rawValue
                analysisProgress = progress
            }
        }

        do {
            let result = try await engine.analyse(
                videoURL: videoURL,
                calibration: calibration,
                audioImpactTimestamp: nil,
                isRightHanded: true
            )

            lastSpeedMph = result.impactSpeedMph
            swingState = .result

            if let speed = result.impactSpeedMph {
                audioFeedback.speedResult(mph: speed)
            }

            // Save the swing record with analysis results
            saveSwingRecord(
                speed: result.impactSpeedMph,
                profile: result.speedProfile
            )
        } catch {
            errorMessage = "Analysis failed: \(error.localizedDescription)"
            swingState = .result
            // Fall back to manual frame analysis
            showFrameAnalysis = true
        }
    }
    // MARK: - Save Swing Record

    private func saveSwingRecord(speed: Double?, profile: SpeedProfile?) {
        let record = SwingRecord(
            impactSpeedMph: speed,
            confidenceScore: profile?.dataPoints.isEmpty == false ? 0.8 : 0.3,
            clubType: selectedClub,
            sessionId: sessionId,
            videoURL: lastRecordingURL
        )
        record.speedProfile = profile
        record.calibrationSnapshot = calibrationManager.calibrationData

        modelContext.insert(record)
    }
}

#Preview {
    CaptureView()
        .modelContainer(for: SwingRecord.self, inMemory: true)
}
