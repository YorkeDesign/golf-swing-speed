import Foundation

enum AppConstants {
    static let appName = "Golf Swing Speed App"
    static let appVersion = "0.02.01"

    enum Camera {
        static let targetFPS: Double = 240
        static let fallbackFPS: Double = 120
        static let captureWidth: Int = 1920
        static let captureHeight: Int = 1080
    }

    enum Calibration {
        static let minLieAngleDegrees: Double = 50
        static let maxLieAngleDegrees: Double = 70
        static let minClubLengthMetres: Double = 0.60
        static let maxClubLengthMetres: Double = 1.25
        static let recommendedCameraDistanceMetres: Double = 2.0
        static let maxCameraDistanceMetres: Double = 3.0
    }

    enum SwingDetection {
        static let stillnessThresholdSeconds: Double = 0.5
        static let minSwingDurationSeconds: Double = 0.5
        static let maxSwingDurationSeconds: Double = 3.0
        static let motionOnsetThreshold: Double = 15.0
    }

    enum Speed {
        static let metersPerSecondToMph: Double = 2.23694
        static let metersPerSecondToKmh: Double = 3.6
    }

    enum LagAnalysis {
        static let castingLRIThreshold: Double = 0.4
        static let goodLagLRIThreshold: Double = 0.5
        static let castingReleasePointThreshold: Double = 90.0
        static let goodReleasePointThreshold: Double = 50.0
        static let speedLossPerTenDegreesLag: Double = 5.0
    }

    enum History {
        static let freeSwingLimit: Int = 50
    }
}
