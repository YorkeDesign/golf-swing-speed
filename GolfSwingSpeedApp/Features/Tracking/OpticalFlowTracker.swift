import Foundation
import Vision
import CoreImage

/// Tracks objects between consecutive frames using Apple's VNGenerateOpticalFlowRequest.
///
/// Optical flow provides per-pixel motion vectors between two frames. This tracker
/// uses these vectors to follow a region of interest (the club head) without needing
/// a trained ML model.
///
/// Usage:
/// 1. Initialise with a known position (from calibration or previous detection)
/// 2. For each new frame, call `track(in:)` to get the updated position
/// 3. The tracker uses the optical flow field to move the ROI
actor OpticalFlowTracker {

    // MARK: - Configuration

    struct Config {
        /// Size of the region of interest to track (in pixels)
        var roiSize: CGFloat = 40

        /// Minimum flow magnitude to consider as valid motion (pixels)
        var minFlowMagnitude: Float = 1.0

        /// Maximum flow magnitude (reject outliers)
        var maxFlowMagnitude: Float = 200.0

        /// Computational level for optical flow (higher = more accurate, slower)
        var computationAccuracy: VNGenerateOpticalFlowRequest.ComputationAccuracy = .medium

        /// Number of frames without valid flow before declaring track lost
        var maxFramesWithoutFlow: Int = 5
    }

    private var config: Config
    private var currentPosition: CGPoint?
    private var previousPixelBuffer: CVPixelBuffer?
    private var framesWithoutFlow: Int = 0

    init(config: Config = Config()) {
        self.config = config
    }

    // MARK: - Initialise Tracking

    /// Set the initial position to track from (e.g., calibrated club head position).
    func setInitialPosition(_ position: CGPoint) {
        currentPosition = position
        framesWithoutFlow = 0
    }

    // MARK: - Track

    /// Track the object in the new frame. Returns the updated position or nil if lost.
    ///
    /// - Parameters:
    ///   - pixelBuffer: Current frame's pixel buffer
    ///   - roiCenter: Optional override for the region of interest center
    /// - Returns: Updated position based on optical flow, or nil if tracking lost
    func track(in pixelBuffer: CVPixelBuffer, roiCenter: CGPoint? = nil) async -> CGPoint? {
        let trackPoint = roiCenter ?? currentPosition
        guard let center = trackPoint else { return nil }

        defer {
            previousPixelBuffer = pixelBuffer
        }

        guard let prevBuffer = previousPixelBuffer else {
            // First frame — store and return current position
            currentPosition = center
            return center
        }

        // Generate optical flow between previous and current frame
        let flowResult = await computeOpticalFlow(from: prevBuffer, to: pixelBuffer)

        guard let flowBuffer = flowResult else {
            framesWithoutFlow += 1
            if framesWithoutFlow > config.maxFramesWithoutFlow {
                return nil // Track lost
            }
            return currentPosition // Return last known position
        }

        // Sample the flow field at the region of interest
        let displacement = sampleFlowField(
            flowBuffer: flowBuffer,
            at: center,
            roiSize: config.roiSize,
            imageWidth: CVPixelBufferGetWidth(pixelBuffer),
            imageHeight: CVPixelBufferGetHeight(pixelBuffer)
        )

        guard let displacement, isValidDisplacement(displacement) else {
            framesWithoutFlow += 1
            if framesWithoutFlow > config.maxFramesWithoutFlow {
                return nil
            }
            return currentPosition
        }

        // Update position
        let newPosition = CGPoint(
            x: center.x + CGFloat(displacement.x),
            y: center.y + CGFloat(displacement.y)
        )

        currentPosition = newPosition
        framesWithoutFlow = 0
        return newPosition
    }

    /// Whether the tracker still has a valid track.
    var isTrackingActive: Bool {
        currentPosition != nil && framesWithoutFlow <= config.maxFramesWithoutFlow
    }

    /// Reset the tracker state.
    func reset() {
        currentPosition = nil
        previousPixelBuffer = nil
        framesWithoutFlow = 0
    }

    // MARK: - Optical Flow Computation

    /// Compute optical flow between two frames using Vision framework.
    private func computeOpticalFlow(
        from previousBuffer: CVPixelBuffer,
        to currentBuffer: CVPixelBuffer
    ) async -> CVPixelBuffer? {
        let request = VNGenerateOpticalFlowRequest(targetedCVPixelBuffer: currentBuffer)
        request.computationAccuracy = config.computationAccuracy

        let handler = VNImageRequestHandler(cvPixelBuffer: previousBuffer, options: [:])

        do {
            try handler.perform([request])
        } catch {
            return nil
        }

        guard let observation = request.results?.first as? VNPixelBufferObservation else {
            return nil
        }

        return observation.pixelBuffer
    }

    // MARK: - Flow Field Sampling

    /// Sample the optical flow field in a region around the given center point.
    /// Returns the median flow vector in the ROI (robust to outliers).
    private func sampleFlowField(
        flowBuffer: CVPixelBuffer,
        at center: CGPoint,
        roiSize: CGFloat,
        imageWidth: Int,
        imageHeight: Int
    ) -> SIMD2<Float>? {
        CVPixelBufferLockBaseAddress(flowBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(flowBuffer, .readOnly) }

        let flowWidth = CVPixelBufferGetWidth(flowBuffer)
        let flowHeight = CVPixelBufferGetHeight(flowBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(flowBuffer)

        guard let baseAddress = CVPixelBufferGetBaseAddress(flowBuffer) else { return nil }

        // Scale the center point to flow field coordinates
        // Flow field may be different resolution from source image
        let scaleX = Float(flowWidth) / Float(imageWidth)
        let scaleY = Float(flowHeight) / Float(imageHeight)
        let flowCenterX = Int(Float(center.x) * scaleX)
        let flowCenterY = Int(Float(center.y) * scaleY)
        let flowRoiHalf = Int(Float(roiSize) * scaleX / 2)

        // Sample flow vectors in the ROI
        var flowVectors: [SIMD2<Float>] = []

        let minX = max(0, flowCenterX - flowRoiHalf)
        let maxX = min(flowWidth - 1, flowCenterX + flowRoiHalf)
        let minY = max(0, flowCenterY - flowRoiHalf)
        let maxY = min(flowHeight - 1, flowCenterY + flowRoiHalf)

        // Optical flow output is typically 2-channel float (dx, dy)
        let pixelFormat = CVPixelBufferGetPixelFormatType(flowBuffer)

        for y in stride(from: minY, through: maxY, by: 2) { // Sample every other pixel for speed
            let rowPtr = baseAddress.advanced(by: y * bytesPerRow)
            for x in stride(from: minX, through: maxX, by: 2) {
                if pixelFormat == kCVPixelFormatType_TwoComponent32Float {
                    // 2 × Float32 per pixel
                    let offset = x * 8
                    let dx = rowPtr.load(fromByteOffset: offset, as: Float.self)
                    let dy = rowPtr.load(fromByteOffset: offset + 4, as: Float.self)

                    // Scale flow back to image coordinates
                    let scaledDx = dx / scaleX
                    let scaledDy = dy / scaleY
                    flowVectors.append(SIMD2<Float>(scaledDx, scaledDy))
                } else if pixelFormat == kCVPixelFormatType_TwoComponent16Half {
                    // 2 × Float16 per pixel
                    let offset = x * 4
                    let rawDx = rowPtr.load(fromByteOffset: offset, as: UInt16.self)
                    let rawDy = rowPtr.load(fromByteOffset: offset + 2, as: UInt16.self)
                    let dx = float16ToFloat32(rawDx)
                    let dy = float16ToFloat32(rawDy)

                    let scaledDx = dx / scaleX
                    let scaledDy = dy / scaleY
                    flowVectors.append(SIMD2<Float>(scaledDx, scaledDy))
                }
            }
        }

        guard !flowVectors.isEmpty else { return nil }

        // Use median flow to be robust against outliers
        return medianFlow(flowVectors)
    }

    /// Calculate median of flow vectors (component-wise median).
    private func medianFlow(_ vectors: [SIMD2<Float>]) -> SIMD2<Float> {
        let sortedX = vectors.map(\.x).sorted()
        let sortedY = vectors.map(\.y).sorted()
        let mid = vectors.count / 2
        return SIMD2<Float>(sortedX[mid], sortedY[mid])
    }

    /// Check if the displacement is within valid bounds.
    private func isValidDisplacement(_ displacement: SIMD2<Float>) -> Bool {
        let magnitude = simd_length(displacement)
        return magnitude >= config.minFlowMagnitude && magnitude <= config.maxFlowMagnitude
    }

    /// Convert Float16 (stored as UInt16) to Float32.
    private func float16ToFloat32(_ value: UInt16) -> Float {
        var float16 = value
        var float32: Float = 0
        // Use vImage or manual conversion
        withUnsafePointer(to: &float16) { src in
            withUnsafeMutablePointer(to: &float32) { dst in
                // IEEE 754 half-precision to single-precision
                let sign = (src.pointee & 0x8000) >> 15
                let exponent = (src.pointee & 0x7C00) >> 10
                let mantissa = src.pointee & 0x03FF

                if exponent == 0 {
                    // Subnormal or zero
                    if mantissa == 0 {
                        dst.pointee = sign == 1 ? -0.0 : 0.0
                    } else {
                        var m = Float(mantissa) / 1024.0
                        m *= pow(2.0, -14.0)
                        dst.pointee = sign == 1 ? -m : m
                    }
                } else if exponent == 31 {
                    // Inf or NaN
                    dst.pointee = mantissa == 0 ? (sign == 1 ? -.infinity : .infinity) : .nan
                } else {
                    let e = Float(Int(exponent) - 15)
                    let m = 1.0 + Float(mantissa) / 1024.0
                    dst.pointee = (sign == 1 ? -1.0 : 1.0) * m * pow(2.0, e)
                }
            }
        }
        return float32
    }
}
