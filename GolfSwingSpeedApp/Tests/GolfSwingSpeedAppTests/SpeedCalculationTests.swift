import Testing
import Foundation
@testable import GolfSwingSpeedApp

@Suite("Speed Calculation Tests")
struct SpeedCalculationTests {

    @Test("Convert m/s to mph correctly")
    func metersPerSecondToMph() {
        let mps = 44.704 // 100 mph in m/s
        let mph = mps * AppConstants.Speed.metersPerSecondToMph
        #expect(abs(mph - 100.0) < 0.1)
    }

    @Test("Speed unit conversion - mph to km/h")
    func mphToKmh() {
        let result = SpeedUnit.kmh.convert(fromMph: 100.0)
        #expect(abs(result - 160.934) < 0.1)
    }

    @Test("Speed unit conversion - mph to m/s")
    func mphToMs() {
        let result = SpeedUnit.ms.convert(fromMph: 100.0)
        #expect(abs(result - 44.704) < 0.1)
    }

    @Test("Pixel-to-metre conversion with calibration")
    func pixelToMetreConversion() {
        let calibration = CalibrationSnapshot(
            method: .manual,
            pixelsPerMetre: 500.0, // 500 pixels per metre
            impactZoneX: 960,
            impactZoneY: 540
        )

        // 100 pixels should be 0.2 metres
        let distance = Double(100) / calibration.pixelsPerMetre
        #expect(abs(distance - 0.2) < 0.001)
    }

    @Test("Instantaneous speed calculation uses actual timestamps")
    func instantaneousSpeedUsesActualTimestamps() {
        let calibration = CalibrationSnapshot(
            method: .manual,
            pixelsPerMetre: 500.0,
            impactZoneX: 960,
            impactZoneY: 540
        )

        // Simulate two frames: 40 pixels apart, 0.005s apart (200fps actual)
        let p1 = TrackedPosition(
            frameTimestamp: 1.000,
            position2D: CGPoint(x: 100, y: 100),
            position3D: nil,
            confidence: 0.9,
            source: .yoloDetection
        )

        let p2 = TrackedPosition(
            frameTimestamp: 1.005, // 5ms later (actual timestamp, NOT assumed 1/240)
            position2D: CGPoint(x: 140, y: 100),
            position3D: nil,
            confidence: 0.9,
            source: .opticalFlow
        )

        let speed = SpeedCalculator.instantaneousSpeed(from: p1, to: p2, calibration: calibration)

        // 40px / 500ppm = 0.08m; 0.08m / 0.005s = 16 m/s = 35.8 mph
        #expect(speed != nil)
        if let speed {
            #expect(abs(speed - 35.8) < 0.5)
        }
    }

    @Test("CGPoint distance calculation")
    func pointDistance() {
        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 3, y: 4)
        #expect(abs(p1.distance(to: p2) - 5.0) < 0.001)
    }

    @Test("Lag Retention Index thresholds")
    func lagRetentionThresholds() {
        // Good lag: LRI > 0.5
        #expect(0.6 > AppConstants.LagAnalysis.goodLagLRIThreshold)

        // Casting: LRI < 0.4
        #expect(0.3 < AppConstants.LagAnalysis.castingLRIThreshold)
    }

    @Test("Speed loss per 10 degrees lag")
    func speedLossFromLag() {
        // Chu et al.: 10° retained lag ≈ 5 mph
        let degreesLost = 20.0
        let estimatedLoss = (degreesLost / 10.0) * AppConstants.LagAnalysis.speedLossPerTenDegreesLag
        #expect(abs(estimatedLoss - 10.0) < 0.001)
    }
}
