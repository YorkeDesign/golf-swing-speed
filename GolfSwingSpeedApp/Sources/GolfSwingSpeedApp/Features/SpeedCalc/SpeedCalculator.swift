import Foundation

// MARK: - Phase 2: Speed Calculation Pipeline
// This file will contain:
// - 3D position tracking → calibrated real-world distance
// - Frame-to-frame speed calculation using ACTUAL timestamps
// - Kalman smoothing of speed curve
// - Impact speed extraction from calibrated zone
// - Motion blur velocity supplementary estimation
// - Confidence scoring per measurement
//
// See PRD.md section F4 for full specification.

struct SpeedCalculator {

    /// Calculate speed between two tracked positions using actual frame timestamps.
    /// CRITICAL: Never assume consistent frame intervals — use actual timestamps.
    static func instantaneousSpeed(
        from p1: TrackedPosition,
        to p2: TrackedPosition,
        calibration: CalibrationSnapshot
    ) -> Double? {
        let timeDelta = p2.frameTimestamp - p1.frameTimestamp
        guard timeDelta > 0 else { return nil }

        // Use 3D positions if available (LiDAR calibration)
        if let pos3d1 = p1.position3D, let pos3d2 = p2.position3D {
            let distance = pos3d1.distance(to: pos3d2)
            let speedMs = Double(distance) / timeDelta
            return speedMs * AppConstants.Speed.metersPerSecondToMph
        }

        // Fallback to 2D with calibration scale
        let pixelDistance = p1.position2D.distance(to: p2.position2D)
        let realDistance = Double(pixelDistance) / calibration.pixelsPerMetre
        let speedMs = realDistance / timeDelta
        return speedMs * AppConstants.Speed.metersPerSecondToMph
    }
}
