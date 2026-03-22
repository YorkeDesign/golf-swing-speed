import Foundation

// MARK: - Phase 2: Club Head Tracking Pipeline
// This file will contain:
// - YOLO-based club head detection via Core ML
// - Apple Vision VNTrackObjectRequest integration
// - Optical flow (VNGenerateOpticalFlowRequest) for frame-to-frame tracking
// - Kalman filter for motion prediction and smoothing
// - Calibration constraint integration (club_length radius from wrist)
//
// See PRD.md section F3 for full specification.

struct TrackedPosition {
    var frameTimestamp: TimeInterval
    var position2D: CGPoint
    var position3D: SIMD3<Float>?
    var confidence: Double
    var source: TrackingSource
}

enum TrackingSource: String {
    case yoloDetection
    case opticalFlow
    case kalmanPrediction
    case visionTracking
}
