import AVFoundation
import UIKit

actor CameraManager {
    private let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureVideoDataOutput?
    private var movieOutput: AVCaptureMovieFileOutput?
    private var videoDevice: AVCaptureDevice?

    private(set) var isConfigured = false
    private(set) var isRecording = false
    private(set) var actualFPS: Double = 0

    // Frame buffer for post-capture analysis
    private(set) var capturedFrameTimestamps: [TimeInterval] = []
    private var recordingURL: URL?
    private var recordingDelegate: MovieRecordingDelegate?

    var previewLayer: AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspect
        return layer
    }

    // MARK: - Configuration

    func configure() throws {
        guard !isConfigured else { return }

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            throw CameraError.deviceNotFound
        }

        videoDevice = device
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .inputPriority

        // Add video input
        let input = try AVCaptureDeviceInput(device: device)
        guard captureSession.canAddInput(input) else {
            throw CameraError.cannotAddInput
        }
        captureSession.addInput(input)

        // Configure for highest available FPS at 1080p
        try configureHighFPS(device: device)

        // Add video data output for frame-level access
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        guard captureSession.canAddOutput(dataOutput) else {
            throw CameraError.cannotAddOutput
        }
        captureSession.addOutput(dataOutput)
        videoOutput = dataOutput

        // Add movie file output for recording
        let movieOut = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(movieOut) else {
            throw CameraError.cannotAddOutput
        }
        captureSession.addOutput(movieOut)
        movieOutput = movieOut

        captureSession.commitConfiguration()
        isConfigured = true
    }

    private func configureHighFPS(device: AVCaptureDevice) throws {
        // Find the best format: 1080p at highest FPS available
        var bestFormat: AVCaptureDevice.Format?
        var bestFPS: Float64 = 0

        for format in device.formats {
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            guard dimensions.width == Int32(AppConstants.Camera.captureWidth),
                  dimensions.height == Int32(AppConstants.Camera.captureHeight) else {
                continue
            }

            for range in format.videoSupportedFrameRateRanges {
                if range.maxFrameRate > bestFPS {
                    bestFPS = range.maxFrameRate
                    bestFormat = format
                }
            }
        }

        guard let format = bestFormat else {
            throw CameraError.highFPSNotSupported
        }

        try device.lockForConfiguration()
        device.activeFormat = format
        device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(bestFPS))
        device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: CMTimeScale(bestFPS))
        device.unlockForConfiguration()

        actualFPS = bestFPS
    }

    // MARK: - Session Control

    func startSession() {
        guard isConfigured, !captureSession.isRunning else { return }
        captureSession.startRunning()
    }

    func stopSession() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }

    // MARK: - Recording

    func startRecording() throws -> URL {
        guard let movieOutput, !isRecording else {
            throw CameraError.alreadyRecording
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "swing_\(UUID().uuidString).mov"
        let url = tempDir.appendingPathComponent(fileName)

        capturedFrameTimestamps = []
        recordingURL = url

        let delegate = MovieRecordingDelegate()
        recordingDelegate = delegate
        movieOutput.startRecording(to: url, recordingDelegate: delegate)
        isRecording = true

        return url
    }

    func stopRecording() async throws -> URL {
        guard let movieOutput, isRecording, let url = recordingURL else {
            throw CameraError.notRecording
        }

        movieOutput.stopRecording()
        isRecording = false

        // Wait for recording to finish
        if let delegate = recordingDelegate {
            try await delegate.waitForCompletion()
        }

        return url
    }

    // MARK: - Frame Timestamp Tracking

    func recordFrameTimestamp(_ timestamp: TimeInterval) {
        capturedFrameTimestamps.append(timestamp)
    }

    // MARK: - Permission

    static func requestPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }

    static var isAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
}

// MARK: - Errors

enum CameraError: LocalizedError {
    case deviceNotFound
    case cannotAddInput
    case cannotAddOutput
    case highFPSNotSupported
    case alreadyRecording
    case notRecording
    case recordingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .deviceNotFound: return "No camera found"
        case .cannotAddInput: return "Cannot configure camera input"
        case .cannotAddOutput: return "Cannot configure camera output"
        case .highFPSNotSupported: return "240fps not supported on this device"
        case .alreadyRecording: return "Already recording"
        case .notRecording: return "Not currently recording"
        case .recordingFailed(let error): return "Recording failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Recording Delegate

final class MovieRecordingDelegate: NSObject, AVCaptureFileOutputRecordingDelegate, Sendable {
    private let continuation = UnsafeContinuation<Void, Error>.self
    private var completionHandler: CheckedContinuation<Void, Error>?

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        if let error {
            completionHandler?.resume(throwing: CameraError.recordingFailed(error))
        } else {
            completionHandler?.resume()
        }
    }

    func waitForCompletion() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.completionHandler = continuation
        }
    }
}
