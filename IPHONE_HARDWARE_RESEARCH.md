# iPhone Hardware Capabilities for Golf Swing Speed Measurement

## Technical Research Report

**Date:** 2026-03-22
**Purpose:** Deep technical analysis of iPhone LiDAR, high-FPS camera, and processing capabilities for building a golf swing speed measurement application.

---

## Table of Contents

1. [iPhone LiDAR Deep Dive](#1-iphone-lidar-deep-dive)
2. [High-FPS Camera on iPhone](#2-high-fps-camera-on-iphone)
3. [iPhone Processing Power](#3-iphone-processing-power)
4. [Golf Swing App: Architectural Implications](#4-golf-swing-app-architectural-implications)

---

## 1. iPhone LiDAR Deep Dive

### 1.1 How iPhone LiDAR Works

The iPhone LiDAR scanner uses **direct Time-of-Flight (dToF)** technology, which is fundamentally different from the structured-light approach used by the front-facing TrueDepth camera.

#### Hardware Components

**VCSEL Array (Vertical-Cavity Surface-Emitting Laser):**
- iPhone 12 Pro through iPhone 14 Pro: The emitter consists of 16 stacks of 4 VCSEL cells (64 total), multiplied by a 3x3 diffractive optical element (DOE) to produce **576 laser pulses** operating at **940nm wavelength** (near-infrared, eye-safe).
- iPhone 15 Pro and later: Redesigned bottom-emitting VCSEL directly bumped to the driver ASIC, generating an **8x14 point pattern** using over 100 independently controlled mesas. This eliminates the DOE, reducing active die area by over one-third and cutting manufacturing cost.

**SPAD Detector (Single-Photon Avalanche Diode):**
- The 576 (or equivalent) reflected laser pulses are captured by a **940nm-enhanced SPAD image sensor**.
- Each SPAD pixel can detect individual photons, enabling precise time measurement.
- On-board distance calculation logic computes the time-of-flight for each point.

**dToF Measurement Principle:**
- The system emits short laser pulses and measures the round-trip time for each pulse to reflect off a surface and return.
- Distance = (speed of light x time) / 2.
- The raw 576 depth points are **interpolated with RGB camera data** to produce the final depth map.

### 1.2 Range, Resolution, and Accuracy at 1-5 Metres

#### Maximum Range
- **Operational range: 0.3m to 5.0m** (optimal performance).
- Minimum reliable distance: ~30cm for acceptable signal-to-noise ratio.
- Performance degrades significantly beyond 5m.

#### Depth Map Resolution
- **256 x 192 pixels** (~49,152 depth points per frame) via ARKit's sceneDepth API.
- **768 x 576 pixels** via AVFoundation's LiDAR Depth Camera (available since iOS 15.4), more than 2x the ARKit resolution.

#### Accuracy at Golf-Relevant Distances (1-5m)

| Distance | Absolute Accuracy | Precision (Repeatability) | Notes |
|----------|-------------------|---------------------------|-------|
| 0.3-1.0m | +/- 1 cm | +/- 1 cm | Optimal range, best SNR |
| 1.0-2.0m | +/- 1-2 cm | +/- 1-2 cm | Still excellent for calibration |
| 2.0-3.0m | +/- 2-3 cm | +/- 2 cm | Good for zone setup |
| 3.0-5.0m | +/- 3-5 cm | +/- 3 cm | Usable but degrading |

**Key research findings:**
- Static acquisition yields **+/- 1-2 cm accuracy** regardless of scanned feature length, even for features 4m or longer (RMS accuracy of 2.84 cm).
- 92% of point cloud points fall within 5 cm of reference for small-area scans.
- Peer-reviewed studies confirm centimetre-level accuracy for objects larger than 10 cm at distances under 4m.

#### Implications for Golf Swing Measurement
At a typical phone-to-golfer distance of 2-3 metres, LiDAR provides **+/- 2-3 cm** depth accuracy. This is sufficient for:
- Establishing a calibrated measurement zone.
- Determining the golfer's distance from the camera.
- Computing a pixels-to-metres scale factor.
- It is **not** sufficient for directly tracking the club head position at speed via LiDAR alone (club head is ~10 cm and moving at 100+ mph).

### 1.3 Refresh Rate and Point Cloud Density

| Parameter | Value |
|-----------|-------|
| Depth map frame rate | **60 Hz** (matching ARFrame rate) |
| Raw hardware scan points | 576 per pulse cycle |
| Interpolated depth pixels | 256 x 192 (ARKit) or 768 x 576 (AVFoundation) |
| Point cloud generation | Real-time at 60 fps |

**Critical limitation for golf:** At 60 Hz, the LiDAR captures one depth frame every ~16.7 ms. A golf club head moving at 100 mph (44.7 m/s) travels **74.5 cm between LiDAR frames**. This means LiDAR alone cannot track the club head during the swing -- it would miss most of the motion arc. LiDAR's role must be **calibration and setup**, not real-time tracking during the swing.

### 1.4 ARKit APIs for Depth Sensing

#### ARWorldTrackingConfiguration with Scene Depth

```swift
let configuration = ARWorldTrackingConfiguration()
configuration.frameSemantics = [.sceneDepth, .smoothedSceneDepth]
configuration.sceneReconstruction = .mesh // Triangle mesh of environment
configuration.planeDetection = [.horizontal, .vertical]
arSession.run(configuration)
```

#### Key APIs

| API | Purpose | Resolution | Rate |
|-----|---------|------------|------|
| `ARFrame.sceneDepth` | Raw LiDAR depth map | 256x192 | 60 Hz |
| `ARFrame.smoothedSceneDepth` | Temporally smoothed depth | 256x192 | 60 Hz |
| `ARFrame.estimatedDepthData` | ML-enhanced depth (non-LiDAR devices) | 256x192 | 60 Hz |
| `ARDepthData.depthMap` | CVPixelBuffer of Float32 depth in metres | 256x192 | 60 Hz |
| `ARDepthData.confidenceMap` | Per-pixel confidence (low/medium/high) | 256x192 | 60 Hz |

#### Scene Understanding

```swift
// Plane detection -- instant with LiDAR
configuration.planeDetection = [.horizontal]

// Scene reconstruction -- mesh of environment
configuration.sceneReconstruction = .meshWithClassification
// Classifications: floor, wall, ceiling, table, seat, window, door

// Raycasting with LiDAR-enhanced accuracy
let query = arView.makeRaycastQuery(
    from: screenPoint,
    allowing: .estimatedPlane, // LiDAR data feeds this
    alignment: .any
)
```

#### Raycasting
LiDAR-enhanced raycasting provides results that match the surrounding environment with high fidelity. By setting `allowing: .estimatedPlane`, ARKit uses LiDAR data to detect planes almost instantly, even on featureless surfaces like white walls.

### 1.5 RealityKit Integration

RealityKit leverages LiDAR through ARKit's scene understanding:

```swift
import RealityKit

let arView = ARView(frame: .zero)

// Scene reconstruction meshes via ARMeshAnchor
arView.environment.sceneUnderstanding.options = [
    .occlusion,      // Virtual objects hidden behind real surfaces
    .receivesLighting,
    .physics         // Virtual objects interact with real geometry
]

// Access mesh anchors
func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for anchor in anchors {
        if let meshAnchor = anchor as? ARMeshAnchor {
            // meshAnchor.geometry contains vertices, normals, faces
            // meshAnchor.transform gives world-space position
        }
    }
}
```

**For golf app use:** RealityKit can render a visual calibration zone overlay in AR, showing the golfer exactly where to stand and swing. The mesh data confirms the ground plane and provides occlusion for any visual guides.

### 1.6 Using LiDAR for Real-World Measurement and Calibration

#### Setting Up a Calibrated Zone

The approach for establishing a golf measurement zone:

1. **Detect the ground plane** using `planeDetection: .horizontal` -- with LiDAR this is nearly instantaneous.
2. **Measure distance to golfer** by reading the depth map at the golfer's position: each pixel in `ARDepthData.depthMap` is a `Float32` value in metres.
3. **Establish the swing plane** by placing virtual anchor points at known positions relative to the golfer.
4. **Compute the pixels-to-metres scale factor** (see Section 1.8).

```swift
// Reading depth at a specific point
func depthAtPixel(depthMap: CVPixelBuffer, x: Int, y: Int) -> Float {
    CVPixelBufferLockBaseAddress(depthMap, .readOnly)
    let width = CVPixelBufferGetWidth(depthMap)
    let baseAddress = CVPixelBufferGetBaseAddress(depthMap)!
    let buffer = baseAddress.assumingMemoryBound(to: Float32.self)
    let depth = buffer[y * width + x] // depth in metres
    CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
    return depth
}
```

### 1.7 Accuracy Limitations at Relevant Distances

| Limitation | Impact on Golf App |
|-----------|-------------------|
| 60 Hz refresh rate | Cannot track club head during swing (too slow) |
| +/- 2-3 cm at 2-3m | Fine for zone setup, not for precise club position |
| Interpolation artefacts | Depth edges may be inaccurate near object boundaries |
| Sunlight interference | 940nm NIR can be swamped by strong direct sunlight; outdoor use affected |
| Reflective surfaces | Club shafts (metallic) may produce unreliable depth readings |
| Moving objects | LiDAR assumes relatively static scenes; fast-moving club will produce motion artefacts |
| Field of view | LiDAR FOV matches the wide-angle camera (~120 degrees diagonal) but depth accuracy degrades at edges |

### 1.8 LiDAR Availability Per iPhone Model

| Model | Year | LiDAR | Chip | Notes |
|-------|------|-------|------|-------|
| iPhone 12 Pro / Pro Max | 2020 | Yes | A14 | First iPhone with LiDAR |
| iPhone 13 Pro / Pro Max | 2021 | Yes | A15 | Same LiDAR hardware |
| iPhone 14 Pro / Pro Max | 2022 | Yes | A16 | Same LiDAR hardware |
| iPhone 15 Pro / Pro Max | 2023 | Yes | A17 Pro | Redesigned LiDAR module (smaller, no DOE) |
| iPhone 16 Pro / Pro Max | 2024 | Yes | A18 Pro | Same redesigned LiDAR |
| All non-Pro models | -- | No | -- | No LiDAR on standard/Plus/mini models |
| iPad Pro (2020+) | 2020+ | Yes | Various | First Apple device with LiDAR |

**Important:** LiDAR is exclusively a Pro/Pro Max feature. The app must have a graceful fallback for non-LiDAR devices (see Section 1.10 for TrueDepth comparison).

### 1.9 Establishing a Pixels-to-Metres Scale Factor Using LiDAR

This is critical for converting 2D club head tracking (from high-FPS camera) into real-world speed measurements.

#### Method 1: Direct Depth Map Reading

```swift
// The depth map gives metres directly per pixel.
// Combined with camera intrinsics, you can compute world coordinates.

func pixelsToMetresScale(at depthMetres: Float,
                         focalLengthPixels: Float) -> Float {
    // At a known depth, each pixel subtends:
    // metresPerPixel = depth / focalLength
    return depthMetres / focalLengthPixels
}

// Camera intrinsics from ARFrame
let intrinsics = frame.camera.intrinsics
let fx = intrinsics[0][0] // focal length in pixels (x)
let fy = intrinsics[1][1] // focal length in pixels (y)
```

#### Method 2: Two-Point Calibration

1. Place the phone at a known distance from the golfer.
2. Use LiDAR to measure the actual distance (in metres).
3. Detect a known-size reference object (e.g., the golfer's shoulder width, a golf club length of ~1.15m).
4. Compute: `scale = knownRealSize / measuredPixelSize`.

#### Method 3: ARKit World Coordinates

```swift
// ARKit provides world-space coordinates directly via raycasting
let results = arSession.raycast(from: pixelCoordinate,
                                 allowing: .estimatedPlane,
                                 alignment: .any)
if let result = results.first {
    let worldPosition = result.worldTransform.columns.3
    // worldPosition.x, .y, .z are in metres
}
```

**The depth map and camera image are already aligned** -- Apple handles the LiDAR-to-RGB calibration internally. The intrinsics of the LiDAR are only scaled relative to the colour camera.

### 1.10 Comparison: LiDAR vs. TrueDepth (Front-Facing Structured Light)

| Feature | Rear LiDAR (dToF) | Front TrueDepth (Structured Light) |
|---------|-------------------|-----------------------------------|
| Technology | Direct time-of-flight | Infrared dot pattern projection |
| Dot pattern | 24x24 regular grid (576 points) | Dense IR dot grid (~30,000 dots) |
| Working range | 0.3m - 5.0m | 0.25m - 0.4m (effective) |
| Accuracy at range | +/- 1-3 cm at 1-5m | Degrades rapidly beyond 30cm |
| Resolution | 256x192 (ARKit), 768x576 (AVF) | 640x480 |
| Refresh rate | 60 Hz | 30 Hz (typical) |
| Outdoor performance | Moderate (NIR interference from sunlight) | Poor (IR pattern washed out by sunlight) |
| Primary purpose | AR, 3D scanning, measurement | Face ID, Animoji, selfie depth |
| Available on | Pro models (rear) | All models with Face ID (front) |

**For golf swing measurement:** TrueDepth is unusable -- it faces the wrong direction (front camera) and has a working range of only ~40cm. The rear LiDAR is the only viable depth sensor.

---

## 2. High-FPS Camera on iPhone

### 2.1 Maximum FPS Capabilities Per Model

| iPhone Model | Chip | Max Normal Video | Slow-Mo Options | Max FPS Achievable |
|-------------|------|-------------------|-----------------|-------------------|
| iPhone 8 / X | A11 | 4K @ 60fps | 1080p @ 120fps, 1080p @ 240fps | 240 fps @ 1080p |
| iPhone XS / XR | A12 | 4K @ 60fps | 1080p @ 120fps, 1080p @ 240fps | 240 fps @ 1080p |
| iPhone 11 / 11 Pro | A13 | 4K @ 60fps | 1080p @ 120fps, 1080p @ 240fps | 240 fps @ 1080p |
| iPhone 12 / 12 Pro | A14 | 4K @ 60fps, Dolby Vision @ 30fps | 1080p @ 120fps, 1080p @ 240fps | 240 fps @ 1080p |
| iPhone 13 / 13 Pro | A15 | 4K @ 60fps, Cinematic @ 30fps | 1080p @ 120fps, 1080p @ 240fps | 240 fps @ 1080p |
| iPhone 14 / 14 Pro | A16 | 4K @ 60fps, Cinematic @ 30fps | 1080p @ 120fps, 1080p @ 240fps | 240 fps @ 1080p |
| iPhone 15 Pro | A17 Pro | 4K @ 60fps | 1080p @ 120fps, 1080p @ 240fps | 240 fps @ 1080p |
| **iPhone 16 Pro / Pro Max** | **A18 Pro** | **4K @ 120fps** (Dolby Vision) | 1080p @ 120fps, 1080p @ 240fps | **240 fps @ 1080p** (slo-mo), **120 fps @ 4K** (normal video) |

**Key takeaway for golf app:** The maximum usable frame rate is **240 fps at 1080p resolution** across all recent iPhones. The iPhone 16 Pro adds **4K @ 120 fps** as a new capability, which provides higher resolution at a still-useful frame rate.

### 2.2 Does Any iPhone Support 960fps? (Samsung Comparison)

**No. No iPhone has ever supported 960fps capture.**

#### Samsung 960fps Analysis

Samsung's "Super Slow-Mo" 960fps has a complex history:

- **Galaxy S9 / Note 9 (2018):** Used sensors with embedded DRAM (Samsung ISOCELL Fast 2L3, Sony IMX345) capable of **genuine hardware 960fps** capture at 720p. However, it captures only ~0.2 seconds of footage per burst.
- **Galaxy S21 and later:** Samsung **dropped hardware 960fps**. Instead, these devices capture at 240fps and use **AI frame interpolation** to generate the intermediate frames, producing a 960fps output. This is not true 960fps -- approximately half or more of the frames are software-generated duplicates or interpolations.
- **Galaxy S24 and later:** Samsung removed the Super Slow-Mo feature entirely from newer flagships.

**Why this matters for a golf app:**
- Samsung's real 960fps was limited to 720p, captured only 0.2 seconds, and required extremely bright lighting.
- Interpolated 960fps introduces artefacts that would corrupt accurate speed measurements.
- iPhone's genuine 240fps at 1080p is **more reliable for measurement** than Samsung's interpolated 960fps, as every frame is a real sensor capture.

**At 240fps, frame interval = 4.17ms.** A club head at 100 mph (44.7 m/s) moves **18.6 cm between frames**. This is trackable with computer vision, though sub-frame interpolation may be needed for maximum precision.

### 2.3 AVFoundation APIs for High-FPS Capture

#### Core Setup

```swift
import AVFoundation

let captureSession = AVCaptureSession()
let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                           for: .video,
                                           position: .back)!

// Find the 240fps format
let targetFormat = videoDevice.formats.first { format in
    let dimensions = CMVideoFormatDescriptionGetDimensions(
        format.formatDescription
    )
    let ranges = format.videoSupportedFrameRateRanges
    return dimensions.width == 1920
        && dimensions.height == 1080
        && ranges.contains(where: { $0.maxFrameRate >= 240 })
}

// Configure the device
try videoDevice.lockForConfiguration()
videoDevice.activeFormat = targetFormat!
videoDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 240)
videoDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 240)
videoDevice.unlockForConfiguration()

// Add input/output
let input = try AVCaptureDeviceInput(device: videoDevice)
captureSession.addInput(input)

let videoOutput = AVCaptureVideoDataOutput()
videoOutput.videoSettings = [
    kCVPixelBufferPixelFormatTypeKey as String:
        kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
]
videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
videoOutput.alwaysDiscardsLateVideoFrames = true
captureSession.addOutput(videoOutput)

captureSession.startRunning()
```

#### Key API Classes

| Class | Role |
|-------|------|
| `AVCaptureSession` | Manages the capture pipeline |
| `AVCaptureDevice` | Represents the physical camera hardware |
| `AVCaptureDeviceFormat` | Describes resolution, FPS range, FOV, depth support |
| `AVCaptureVideoDataOutput` | Delivers raw video frames to a delegate |
| `AVCaptureDepthDataOutput` | Delivers depth data (LiDAR or TrueDepth) |
| `AVCaptureMultiCamSession` | Enables simultaneous multi-camera capture |
| `AVCaptureDeviceInput` | Connects a device to the session |

#### Frame Rate Configuration

```swift
// Query available frame rates for a format
for range in format.videoSupportedFrameRateRanges {
    print("Min: \(range.minFrameRate), Max: \(range.maxFrameRate)")
}

// Set exact frame rate
device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFPS))
device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFPS))
```

**Practical note:** Developer reports indicate that when requesting 240fps through AVFoundation, the actual delivered frame rate can sometimes be lower (~120fps effective) depending on processing load and lighting conditions. Always verify actual frame timestamps in the delegate callback.

### 2.4 Resolution vs. Frame Rate Trade-offs

| Frame Rate | Max Resolution | Pixel Count | Use Case |
|-----------|---------------|-------------|----------|
| 24/25/30 fps | 4K (3840x2160) | 8.3M | Standard video |
| 60 fps | 4K (3840x2160) | 8.3M | Smooth standard video |
| 120 fps | 4K (3840x2160) | 8.3M | **iPhone 16 Pro only** |
| 120 fps | 1080p (1920x1080) | 2.1M | Slow-mo (all recent models) |
| 240 fps | 1080p (1920x1080) | 2.1M | Max slow-mo |

**For golf app recommendation:**
- **Primary mode: 240fps @ 1080p** -- maximum temporal resolution for tracking.
- **Alternative: 120fps @ 4K (iPhone 16 Pro)** -- 2x the spatial resolution at half the temporal resolution. Better for detecting small club heads at distance.
- The choice depends on whether temporal or spatial resolution is the bottleneck for your tracking algorithm.

### 2.5 Buffer Handling for Real-Time Processing

```swift
// Delegate callback -- called for every frame
func captureOutput(_ output: AVCaptureOutput,
                   didOutput sampleBuffer: CMSampleBuffer,
                   from connection: AVCaptureConnection) {

    // At 240fps, you have ~4.17ms per frame
    // At 120fps, you have ~8.33ms per frame

    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
        return
    }

    // Get precise timestamp for speed calculation
    let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

    // Process on GPU to avoid blocking the capture pipeline
    processFrameOnGPU(pixelBuffer, timestamp: timestamp)
}

// Dropped frame notification
func captureOutput(_ output: AVCaptureOutput,
                   didDrop sampleBuffer: CMSampleBuffer,
                   from connection: AVCaptureConnection) {
    // Frame was dropped -- log for diagnostics
    let reason = CMGetAttachment(
        sampleBuffer,
        key: kCMSampleBufferAttachmentKey_DroppedFrameReason,
        attachmentModeOut: nil
    )
    print("Frame dropped: \(reason ?? "unknown" as CFTypeRef)")
}
```

**Critical settings:**
- `alwaysDiscardsLateVideoFrames = true` -- essential at high FPS to prevent buffer backup.
- Use a dedicated serial `DispatchQueue` for the delegate to avoid contention.
- Process frames asynchronously; do not block the delegate callback.

### 2.6 CMSampleBuffer Processing Pipeline

```
Camera Sensor
    |
    v
CMSampleBuffer (contains CMBlockBuffer or CVImageBuffer + metadata)
    |
    v
CMSampleBufferGetImageBuffer() --> CVPixelBuffer
    |
    v
CVPixelBufferLockBaseAddress(.readOnly)
    |
    +---> CPU path: Direct pixel access via base address pointer
    |         (suitable for lightweight operations)
    |
    +---> GPU path: Create CIImage or MTLTexture from CVPixelBuffer
    |         (preferred for CV operations)
    |
    +---> ML path: Create VNImageRequestHandler with CVPixelBuffer
    |         (for Vision framework / Core ML inference)
    |
    v
CVPixelBufferUnlockBaseAddress()
```

**Performance rules at 240fps (4.17ms budget per frame):**
1. Never copy pixel data between CPU and GPU unnecessarily.
2. Keep pixel data on the GPU path from capture through processing.
3. Reuse buffers -- do not allocate/deallocate per frame.
4. Use `kCVPixelFormatType_420YpCbCr8BiPlanarFullRange` (NV12) for minimum memory bandwidth.
5. Prefer Metal textures created directly from CVPixelBuffer via `CVMetalTextureCache`.

### 2.7 Simultaneous LiDAR + Camera Capture

#### Option A: ARKit Session (Recommended for Golf App)

ARKit naturally provides both RGB frames and LiDAR depth in a single session:

```swift
let config = ARWorldTrackingConfiguration()
config.frameSemantics = [.sceneDepth]
// ARKit provides synchronized RGB + depth at 60fps
// But: RGB is limited to 60fps in ARKit sessions
```

**Limitation:** ARKit locks the camera to 60fps. You cannot get 240fps video through an ARKit session.

#### Option B: AVCaptureMultiCamSession

```swift
let multiCamSession = AVCaptureMultiCamSession()

// Add wide-angle camera for high-FPS video
let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                          for: .video, position: .back)
let wideInput = try AVCaptureDeviceInput(device: wideCamera!)
multiCamSession.addInput(wideInput)

// Add LiDAR depth camera
let lidarCamera = AVCaptureDevice.default(.builtInLiDARDepthCamera,
                                           for: .video, position: .back)
let lidarInput = try AVCaptureDeviceInput(device: lidarCamera!)
multiCamSession.addInput(lidarInput)
```

**Key constraint:** The LiDAR depth camera in AVFoundation (`.builtInLiDARDepthCamera`) uses the same wide-angle camera for its RGB stream. Running both simultaneously may require careful format negotiation to avoid conflicts.

#### Option C: Sequential Approach (Recommended)

1. **Calibration phase:** Run ARKit session with LiDAR to establish the measurement zone, distances, and scale factors. Store these calibration parameters.
2. **Capture phase:** Switch to a pure AVFoundation session at 240fps for the actual swing capture.
3. **Analysis phase:** Apply the stored calibration data to convert pixel measurements to real-world speeds.

This avoids the 60fps limitation of ARKit and the complexity of multi-cam sessions.

### 2.8 Thermal Throttling During Sustained High-FPS Capture

Thermal throttling is a significant concern for sustained 240fps capture:

| Scenario | Expected Duration Before Throttling | Mitigation |
|----------|-------------------------------------|------------|
| 240fps capture only | 3-5 minutes in warm conditions | Short burst recording |
| 240fps + ML inference | 1-3 minutes | Offload processing to post-capture |
| 240fps + LiDAR (if possible) | 1-2 minutes | Sequential approach |
| 120fps @ 4K | 2-4 minutes | Moderate thermal load |

**Throttling behaviour:**
- iOS reduces CPU/GPU clock speeds automatically when temperature thresholds are reached.
- Camera may silently drop to a lower frame rate without notification.
- The device may display an overheating warning and force the camera to stop.
- iPhone 16 Pro / Pro Max have an internal vapour chamber for improved heat dissipation.
- iPhone 15 Pro and earlier (and non-Pro Max models) lack vapour chambers and throttle sooner.

**Golf app strategy:**
- Design for **short burst capture** (5-10 seconds per swing) rather than continuous recording.
- Include a cool-down indicator if multiple swings are recorded consecutively.
- Monitor `ProcessInfo.processInfo.thermalState` and warn the user at `.serious` or `.critical`.

```swift
NotificationCenter.default.addObserver(
    forName: ProcessInfo.thermalStateDidChangeNotification,
    object: nil, queue: .main
) { _ in
    let state = ProcessInfo.processInfo.thermalState
    switch state {
    case .nominal: break // All good
    case .fair: break // Starting to warm up
    case .serious: // Warn user, consider reducing FPS
        showThermalWarning()
    case .critical: // Stop capture immediately
        stopCapture()
    @unknown default: break
    }
}
```

### 2.9 Metal/GPU Acceleration for Real-Time Frame Processing

#### CVPixelBuffer to Metal Texture (Zero-Copy)

```swift
var textureCache: CVMetalTextureCache?
CVMetalTextureCacheCreate(nil, nil, metalDevice, nil, &textureCache)

func metalTexture(from pixelBuffer: CVPixelBuffer) -> MTLTexture? {
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)

    var cvTexture: CVMetalTexture?
    CVMetalTextureCacheCreateTextureFromImage(
        nil, textureCache!, pixelBuffer, nil,
        .bgra8Unorm, width, height, 0, &cvTexture
    )
    return CVMetalTextureGetTexture(cvTexture!)
}
```

#### Metal Compute Kernel for Club Head Detection

```swift
// Example: threshold + edge detection in a Metal compute shader
// Processes 1080p frame in <1ms on A15+ GPU

kernel void detectClubHead(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    float4 color = input.read(gid);
    float luminance = dot(color.rgb, float3(0.299, 0.587, 0.114));
    // Threshold and edge detection logic
    output.write(float4(luminance), gid);
}
```

**Performance benchmarks for Metal compute on recent iPhones:**

| Operation | Resolution | A15 GPU | A17 Pro GPU | A18 Pro GPU |
|-----------|-----------|---------|-------------|-------------|
| Colour threshold | 1080p | <0.5ms | <0.3ms | <0.3ms |
| Gaussian blur 5x5 | 1080p | <0.8ms | <0.5ms | <0.5ms |
| Sobel edge detection | 1080p | <0.7ms | <0.4ms | <0.4ms |
| Full CV pipeline | 1080p | ~2-3ms | ~1.5-2ms | ~1-1.5ms |

These times are well within the 4.17ms budget at 240fps, leaving room for additional processing.

### 2.10 Core Video Pixel Buffer Access Patterns

```swift
// Direct CPU access (use only for lightweight operations)
CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)!
let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
let width = CVPixelBufferGetWidth(pixelBuffer)
let height = CVPixelBufferGetHeight(pixelBuffer)

// For NV12 (YCbCr biplanar) format:
let yPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)!
let uvPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1)!

CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)

// GPU access via CIImage (preferred for processing chains)
let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

// GPU access via Metal (preferred for custom compute)
let mtlTexture = metalTexture(from: pixelBuffer) // zero-copy
```

**Memory considerations at 240fps:**
- Each 1080p NV12 frame: ~3.1 MB
- At 240fps: ~744 MB/s throughput
- iOS manages a circular buffer pool automatically
- Setting `alwaysDiscardsLateVideoFrames = true` prevents memory accumulation

---

## 3. iPhone Processing Power

### 3.1 Neural Engine Capabilities Per Chip

| Chip | iPhone Models | Neural Engine Cores | TOPS | Key ML Features |
|------|--------------|-------------------|------|-----------------|
| A14 Bionic | 12, 12 Pro | 16 cores | 11 TOPS | Basic Core ML acceleration |
| A15 Bionic | 13, 13 Pro, 14, 14 Plus | 16 cores | 15.8 TOPS | Improved ML performance |
| A16 Bionic | 14 Pro, 15, 15 Plus | 16 cores | 17 TOPS | Better power efficiency |
| A17 Pro | 15 Pro, 15 Pro Max | 16 cores | 35 TOPS | 2x ML vs A16; first 3nm chip |
| A18 | 16, 16 Plus | 16 cores | 35 TOPS | Matches A17 Pro ML |
| A18 Pro | 16 Pro, 16 Pro Max | 16 cores | 35 TOPS | Up to 15% faster ML vs A17 Pro |

**TOPS context:** 35 TOPS is sufficient for running multiple real-time inference tasks simultaneously. For reference, this exceeds the ML performance of many dedicated edge AI accelerators.

### 3.2 Core ML Inference Speed for Object Detection

| Model | Task | Size | A15 Latency | A17 Pro Latency | A18 Pro Latency |
|-------|------|------|-------------|-----------------|-----------------|
| YOLOv8n | Object detection | ~6 MB | ~8-12ms | ~5-7ms | ~4-6ms |
| YOLOv8s | Object detection | ~22 MB | ~15-20ms | ~10-12ms | ~8-10ms |
| YOLO11n (CoreML) | Object detection | ~5 MB | ~6-10ms | ~4-6ms | ~3-5ms |
| SSDLite MobileNetV3 | Object detection | ~10 MB | ~12-16ms | ~8-10ms | ~6-8ms |
| MoveNet Lightning | Pose estimation | ~4 MB | ~8-12ms | ~5-7ms | ~4-6ms |
| Custom club detector | Object detection | ~3-5 MB | ~5-8ms | ~3-5ms | ~2-4ms |

**Key benchmark:** YOLO11 exported to CoreML achieved **85 FPS** (11.8ms per frame) on Neural Engine, compared to 21 FPS via PyTorch on-device. CoreML + Neural Engine is the clear path for real-time inference.

**For golf app at 240fps (4.17ms budget):**
- A lightweight custom model (YOLOv8n or smaller) can run inference within budget on A17 Pro+.
- On A15/A16, you may need to process every 2nd or 3rd frame (effectively 120fps or 80fps for ML, with interpolation).

### 3.3 Vision Framework Capabilities

| Request | Purpose | Performance | Golf App Use |
|---------|---------|-------------|-------------|
| `VNDetectHumanBodyPoseRequest` | 19-point body skeleton | Real-time at 30fps+ | Detect golfer's stance, arm positions |
| `VNDetectHumanBodyPose3DRequest` | 3D body pose (iOS 17+) | ~30fps | 3D swing plane analysis |
| `VNTrackObjectRequest` | Track a bounding box across frames | Very fast (<2ms) | Track club head after initial detection |
| `VNDetectRectanglesRequest` | Detect rectangles | Fast | Detect club face angle |
| `VNDetectContoursRequest` | Detect contours/edges | Moderate | Club shaft line detection |
| `VNGenerateOpticalFlowRequest` | Dense optical flow between frames | ~15-30ms | Motion vector field for speed estimation |
| `VNTrackRectangleRequest` | Track a rectangle across frames | Fast (<3ms) | Track detected regions |
| `VNDetectTrajectoriesRequest` | Detect object trajectories (iOS 14+) | Moderate | Ball flight path detection |

#### Body Pose Detection for Golfer

```swift
let poseRequest = VNDetectHumanBodyPoseRequest { request, error in
    guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }

    for observation in observations {
        // Key joints for golf swing analysis:
        let rightWrist = try? observation.recognizedPoint(.rightWrist)
        let leftWrist = try? observation.recognizedPoint(.leftWrist)
        let rightElbow = try? observation.recognizedPoint(.rightElbow)
        let rightShoulder = try? observation.recognizedPoint(.rightShoulder)

        // Use wrist positions to estimate club head region
        // The club extends beyond the wrists in the swing direction
    }
}

let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
try handler.perform([poseRequest])
```

#### Object Tracking Pipeline

```swift
// Step 1: Detect club head in first frame (ML model or Vision)
// Step 2: Initialize tracker
let trackRequest = VNTrackObjectRequest(detectedObjectObservation: initialObservation)
trackRequest.trackingLevel = .fast // .fast for speed, .accurate for precision

// Step 3: Track across subsequent frames
let sequenceHandler = VNSequenceRequestHandler()
for frame in subsequentFrames {
    try sequenceHandler.perform([trackRequest], on: frame)
    let trackedObject = trackRequest.results?.first as? VNDetectedObjectObservation
    // trackedObject.boundingBox gives the updated position
}
```

#### Optical Flow for Speed Estimation

```swift
let flowRequest = VNGenerateOpticalFlowRequest(
    targetedCVPixelBuffer: currentFrame,
    options: [:]
)
let handler = VNImageRequestHandler(cvPixelBuffer: previousFrame)
try handler.perform([flowRequest])

if let flowObservation = flowRequest.results?.first as? VNPixelBufferObservation {
    let flowBuffer = flowObservation.pixelBuffer
    // Each pixel contains (dx, dy) motion vectors
    // Convert pixel displacement to metres using LiDAR-derived scale
    // Speed = displacement_metres / time_between_frames
}
```

### 3.4 Real-Time vs. Post-Capture Processing Trade-offs

| Approach | Pros | Cons | Recommended For |
|----------|------|------|----------------|
| **Full real-time** (process every frame during capture) | Instant feedback, no storage needed | May drop frames at 240fps, thermal issues, limited to lightweight models | Simple tracking, live preview |
| **Lightweight real-time + post-capture** | Live tracking preview + detailed analysis after | Requires buffer storage, two-pass | **Best for golf app** |
| **Full post-capture** | Maximum accuracy, no time pressure, can use heavy models | No live feedback, requires storing all frames (~750 MB/s at 240fps 1080p) | Research/prototype phase |

**Recommended hybrid pipeline for golf app:**

1. **During capture (real-time):** Run lightweight object tracker (VNTrackObjectRequest) at 240fps to confirm club is visible and provide live feedback.
2. **After capture (post-process):** Run full ML inference + optical flow on the buffered frames for precise speed calculation. With no real-time constraint, you can use heavier models and multi-pass analysis.

### 3.5 Metal Performance Shaders for CV Operations

MPS provides GPU-accelerated primitives that are highly relevant:

| MPS Kernel | Use in Golf App |
|-----------|-----------------|
| `MPSImageGaussianBlur` | Noise reduction on each frame |
| `MPSImageSobel` | Edge detection for club shaft/head |
| `MPSImageThresholdBinary` | Isolate bright/dark club head |
| `MPSImageConvolution` | Custom filter kernels |
| `MPSImageHistogramEqualization` | Contrast enhancement in varying light |
| `MPSImageScale` | Resize frames for ML input |
| `MPSImageDilate` / `MPSImageErode` | Morphological operations to clean detections |
| `MPSTemporaryImage` | Efficient intermediate buffer management |
| `MPSNNGraph` | Run neural network layers on GPU |

```swift
// Example: Efficient MPS pipeline for pre-processing
let blur = MPSImageGaussianBlur(device: metalDevice, sigma: 1.0)
let sobel = MPSImageSobel(device: metalDevice)

// Chain operations using MPSTemporaryImage for zero-copy intermediates
let descriptor = MPSImageDescriptor(
    channelFormat: .float16, width: 1920, height: 1080, featureChannels: 1
)
let temp = MPSTemporaryImage(commandBuffer: commandBuffer, imageDescriptor: descriptor)

blur.encode(commandBuffer: commandBuffer, sourceTexture: inputTexture,
            destinationTexture: temp.texture)
sobel.encode(commandBuffer: commandBuffer, sourceTexture: temp.texture,
             destinationTexture: outputTexture)

commandBuffer.commit()
```

**Performance advantage:** MPS kernels are fine-tuned per Apple GPU family, typically 5-10x faster than equivalent CPU implementations and 2-3x faster than naive Metal compute shaders.

---

## 4. Golf Swing App: Architectural Implications

### 4.1 Recommended Architecture

```
Phase 1: CALIBRATION (ARKit + LiDAR, 60fps)
    |
    +--> Detect ground plane
    +--> Measure distance to golfer (depth map)
    +--> Compute pixels-to-metres scale factor
    +--> Establish swing measurement zone
    +--> Store calibration parameters
    |
Phase 2: CAPTURE (AVFoundation, 240fps @ 1080p)
    |
    +--> High-FPS video capture
    +--> Lightweight real-time tracking (VNTrackObjectRequest)
    +--> Buffer frames to memory (ring buffer, ~5-10 seconds)
    +--> Detect swing start/end events
    |
Phase 3: ANALYSIS (Post-capture, no time pressure)
    |
    +--> Run ML club head detection on buffered frames
    +--> Compute optical flow between consecutive frames
    +--> Apply calibration scale to convert pixels to metres
    +--> Calculate speed: distance / time between frames
    +--> Generate swing arc visualization
    +--> Report peak speed, average speed, acceleration profile
```

### 4.2 Key Technical Constraints Summary

| Constraint | Value | Impact |
|-----------|-------|--------|
| LiDAR refresh rate | 60 Hz | Cannot track club during swing; use for calibration only |
| Max camera FPS | 240 fps @ 1080p | 4.17ms between frames; club moves ~18.6cm per frame at 100mph |
| LiDAR accuracy at 2-3m | +/- 2-3 cm | Adequate for scale calibration (+/- 1-2% at 2m) |
| Neural Engine (A17 Pro+) | 35 TOPS | Can run lightweight detection at 240fps |
| Per-frame ML budget | 4.17ms at 240fps | Requires small models or every-other-frame processing |
| Thermal throttling | 2-5 min sustained | Design for short burst capture |
| LiDAR availability | Pro models only | Must have non-LiDAR fallback |

### 4.3 Minimum Device Requirements

| Feature | Minimum Device | Optimal Device |
|---------|---------------|----------------|
| 240fps capture | iPhone 8+ (any recent iPhone) | iPhone 15 Pro+ |
| LiDAR calibration | iPhone 12 Pro | iPhone 16 Pro |
| 4K @ 120fps | iPhone 16 Pro only | iPhone 16 Pro Max |
| Neural Engine 35 TOPS | iPhone 15 Pro | iPhone 16 Pro |
| Real-time ML at 240fps | iPhone 15 Pro (A17 Pro) | iPhone 16 Pro (A18 Pro) |

### 4.4 Non-LiDAR Fallback Strategy

For devices without LiDAR (all non-Pro iPhones):
1. **Manual calibration:** Ask user to place phone at a known distance, or use a reference object of known size (e.g., golf club length = 1.15m for a driver).
2. **ARKit depth estimation:** `estimatedDepthData` provides ML-estimated depth on non-LiDAR devices, but with significantly lower accuracy (+/- 10-20cm).
3. **Pose-based estimation:** Use `VNDetectHumanBodyPoseRequest` to estimate golfer's body dimensions and derive scale from anthropometric averages.

---

## Sources

- [Apple LiDAR Demystified: SPAD, VCSEL, and Fusion (4sense / Medium)](https://4sense.medium.com/apple-lidar-demystified-spad-vcsel-and-fusion-aa9c3519d4cb)
- [Evaluation of iPhone 12 Pro LiDAR for Geosciences (Nature Scientific Reports)](https://www.nature.com/articles/s41598-021-01763-9)
- [Characterization of iPhone LiDAR for Vibration Measurement (MDPI Sensors)](https://www.mdpi.com/1424-8220/23/18/7832)
- [LiDAR on iPhone: How Accurate Is It? (Scan Manifold)](https://www.scanmanifold.com/blog-posts/lidar-on-iphone-how-accurate-is-it-plus-the-biggest-errors-that-manifold-corrects)
- [ARDepthData (Apple Developer Documentation)](https://developer.apple.com/documentation/arkit/ardepthdata)
- [Displaying a Point Cloud Using Scene Depth (Apple Developer)](https://developer.apple.com/documentation/ARKit/displaying-a-point-cloud-using-scene-depth)
- [Capturing Depth Using the LiDAR Camera (Apple Developer)](https://developer.apple.com/documentation/AVFoundation/capturing-depth-using-the-lidar-camera)
- [Explore ARKit 4 -- WWDC20 (Apple Developer)](https://developer.apple.com/videos/play/wwdc2020/10611/)
- [Advanced Scene Understanding in AR (Apple Developer Tech Talks)](https://developer.apple.com/videos/play/tech-talks/609/)
- [Discover Advancements in iOS Camera Capture -- WWDC22 (Apple Developer)](https://developer.apple.com/videos/play/wwdc2022/110429/)
- [iPhone 16 Pro 4K 120fps (MacRumors)](https://www.macrumors.com/how-to/iphone-16-pro-shoot-4k-video-120-fps-slow-mo/)
- [Who Actually Has Real 960fps? (Android Authority)](https://www.androidauthority.com/real-960fps-super-slow-motion-999639/)
- [Samsung Super Slow Mo vs Slow Motion (Samsung)](https://www.samsung.com/sg/support/mobile-devices/what-is-super-slow-mo-and-how-is-it-different-from-slow-motion-video/)
- [Which iPhones Have LiDAR? (Know Your Mobile)](https://www.knowyourmobile.com/phones/which-iphones-have-lidar/)
- [TrueDepth vs LiDAR vs Structure Sensor (Structure.io)](https://structure.io/blog/which-scanner-is-best-truedepth-vs-lidar-vs-structure-sensor-3-/)
- [iPhone Face ID: LiDAR vs TrueDepth (LiDAR News)](https://lidarnews.com/phone-face-id-lidar-truedepth/)
- [VNDetectHumanBodyPoseRequest (Apple Developer)](https://developer.apple.com/documentation/vision/vndetecthumanbodyposerequest)
- [Detect Body and Hand Pose with Vision -- WWDC20 (Apple Developer)](https://developer.apple.com/videos/play/wwdc2020/10653/)
- [Metal Performance Shaders (Apple Developer)](https://developer.apple.com/documentation/metalperformanceshaders)
- [Neural Engine (Apple Wiki)](https://apple.fandom.com/wiki/Neural_Engine)
- [A18 Pro Neural Engine Performance (Macworld)](https://www.macworld.com/article/2304792/a18-pro-preview-performance-neural-engine-cpu-gpu-iphone-16-pro.html)
- [A17 Pro Neural Engine iOS 18 Benchmark (PhoneArena)](https://www.phonearena.com/news/ios-18-shows-big-improvement-in-core-ml-neural-engine-benchmark_id159647)
- [Best iOS Object Detection Models (Roboflow)](https://blog.roboflow.com/best-ios-object-detection-models/)
- [CoreML Export for YOLO Models (Ultralytics)](https://docs.ultralytics.com/integrations/coreml/)
- [RealityKit Scene Understanding (Apple Developer)](https://developer.apple.com/documentation/realitykit/realitykit-scene-understanding)
- [iOS 16: ARKit and RealityKit Measure Objects (Medium / Slalom Build)](https://medium.com/slalom-build/ios-16-how-arkit-and-realitykit-help-measure-objects-accurately-9128f4ca57a0)
- [Accuracy Assessment of iPhone LiDAR (MDPI Sensors)](https://www.mdpi.com/1424-8220/25/19/6141)
