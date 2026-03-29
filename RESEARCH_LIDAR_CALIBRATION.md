# LiDAR-Based Scene Calibration — Technical Research Report

**Date:** 2026-03-29
**Scope:** ARKit scene scanning, 3D body pose, club measurement, pixels-per-metre calibration
**Target Device:** iPhone 13 Pro+ (LiDAR required), iOS 17+

---

## 1. ARKit Scene Scanning for Calibration

### 1.1 ARWorldTrackingConfiguration with LiDAR Scene Reconstruction

ARKit uses the LiDAR scanner to create a polygonal mesh of the physical environment. The scanner retrieves depth information from a wide area without requiring the user to move. ARKit converts this into a series of vertices forming a mesh, partitioned across multiple `ARMeshAnchor` instances.

**Configuration setup:**

```swift
import ARKit
import RealityKit

class CalibrationARSessionManager: NSObject, ObservableObject, ARSessionDelegate {
    let arView = ARView(frame: .zero)

    func startSession() {
        let configuration = ARWorldTrackingConfiguration()

        // Enable LiDAR scene reconstruction with classification
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            configuration.sceneReconstruction = .meshWithClassification
        }

        // Enable plane detection (ground plane)
        configuration.planeDetection = [.horizontal, .vertical]

        // Enable scene depth from LiDAR
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.smoothedSceneDepth) {
            configuration.frameSemantics.insert(.smoothedSceneDepth)
        }

        // Enable person segmentation (useful for isolating golfer)
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }

        arView.session.delegate = self
        arView.session.run(configuration)
    }

    func pauseSession() {
        arView.session.pause()
    }
}
```

**Key options for `sceneReconstruction`:**
- `.mesh` — basic mesh without classification
- `.meshWithClassification` — mesh with floor/wall/ceiling/table/seat/window/door labels
- Use `.meshWithClassification` for golf calibration to reliably identify the ground plane

**Mesh classification types (`ARMeshClassification`):**
- `.floor` — the ground surface (critical for calibration)
- `.wall`, `.ceiling`, `.table`, `.seat`, `.window`, `.door`, `.none`

### 1.2 Ground Plane Detection via ARKit Plane Detection

ARKit detects planes as `ARPlaneAnchor` objects. For golf calibration, the ground plane is the primary target.

```swift
// ARSessionDelegate method — called when a new plane is detected
func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for anchor in anchors {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            if planeAnchor.alignment == .horizontal {
                // This is a horizontal plane (likely the ground)
                let center = planeAnchor.center        // simd_float3 in anchor's local space
                let extent = planeAnchor.extent        // simd_float3 (width, 0, length) in metres
                let transform = planeAnchor.transform  // simd_float4x4 world transform

                // Ground plane Y coordinate in world space
                let groundY = transform.columns.3.y

                print("Ground plane at Y=\(groundY)m, extent: \(extent.x)m x \(extent.z)m")
            }
        }
    }
}

// Called when ARKit refines a previously detected plane
func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    for anchor in anchors {
        if let planeAnchor = anchor as? ARPlaneAnchor,
           planeAnchor.alignment == .horizontal {
            // Plane refined — update ground plane reference
            // As user moves, ARKit improves plane detection accuracy
        }
    }
}
```

**Ground plane normal vector extraction:**

```swift
func groundPlaneNormal(from planeAnchor: ARPlaneAnchor) -> simd_float3 {
    // The plane's local Y-axis in world space is its normal
    let localUp = simd_float4(0, 1, 0, 0)
    let worldNormal = planeAnchor.transform * localUp
    return simd_normalize(simd_float3(worldNormal.x, worldNormal.y, worldNormal.z))
}
```

### 1.3 Raycasting — User Taps to Get 3D World Coordinates

Raycasting fires a ray from a 2D screen point through the AR scene to find the intersection with real-world surfaces. This replaces the deprecated `hitTest` API.

**Using ARView (RealityKit):**

```swift
import UIKit
import ARKit
import RealityKit

class CalibrationViewController: UIViewController {
    var arView: ARView!
    var tappedPoints: [simd_float3] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)

        startARSession()
    }

    func startARSession() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.smoothedSceneDepth) {
            config.frameSemantics.insert(.smoothedSceneDepth)
        }
        arView.session.run(config)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)

        // Create raycast query from tap point
        guard let query = arView.makeRaycastQuery(
            from: tapLocation,
            allowing: .estimatedPlane,  // or .existingPlaneGeometry for detected planes only
            alignment: .any
        ) else { return }

        // Perform the raycast
        guard let result = arView.session.raycast(query).first else {
            print("No surface found at tap location")
            return
        }

        // Extract 3D world position from the result
        let worldTransform = result.worldTransform
        let position = simd_float3(
            worldTransform.columns.3.x,
            worldTransform.columns.3.y,
            worldTransform.columns.3.z
        )

        tappedPoints.append(position)
        print("Tapped point at world position: \(position) metres")

        // Place a visual marker at the tapped location
        let marker = ModelEntity(
            mesh: .generateSphere(radius: 0.01),
            materials: [SimpleMaterial(color: .red, isMetallic: false)]
        )
        let anchor = AnchorEntity(world: worldTransform)
        anchor.addChild(marker)
        arView.scene.addAnchor(anchor)
    }
}
```

**Raycast target options:**
| Target | Description | Use Case |
|--------|-------------|----------|
| `.existingPlaneGeometry` | Only detected plane surfaces | When plane detection is running and you want precise plane hits |
| `.existingPlaneInfinite` | Extends detected planes infinitely | Tap beyond detected plane boundary |
| `.estimatedPlane` | ARKit estimates planes even without detection | Works without plane detection enabled |

**Alignment options:**
| Alignment | Description |
|-----------|-------------|
| `.horizontal` | Ground, tables |
| `.vertical` | Walls |
| `.any` | Both |

### 1.4 Calculating Real-World Distance Between Two 3D Points

Since ARKit operates in metres, distance calculation is straightforward Euclidean distance:

```swift
func distanceBetween(_ a: simd_float3, _ b: simd_float3) -> Float {
    return simd_distance(a, b)  // Returns distance in metres
}

// Example: After user taps two points
let pointA = tappedPoints[0]  // e.g. club head position
let pointB = tappedPoints[1]  // e.g. grip position
let clubLength = distanceBetween(pointA, pointB)
print("Club length: \(clubLength) metres (\(clubLength * 100) cm)")
```

**3D vector between points (for angle calculations):**

```swift
func vectorBetween(_ from: simd_float3, _ to: simd_float3) -> simd_float3 {
    return to - from
}

func angleBetweenVectors(_ a: simd_float3, _ b: simd_float3) -> Float {
    let dotProduct = simd_dot(simd_normalize(a), simd_normalize(b))
    return acos(simd_clamp(dotProduct, -1.0, 1.0))  // Returns radians
}
```

### 1.5 Deriving Pixels-Per-Metre Scale Factor

The pixels-per-metre scale factor varies with distance from the camera. It is derived from the camera's intrinsic matrix.

**Camera intrinsics approach:**

```swift
func pixelsPerMetre(at distanceMetres: Float, from frame: ARFrame) -> Float {
    // Camera intrinsics: 3x3 matrix
    // [fx  0  cx]
    // [0  fy  cy]
    // [0   0   1]
    // fx, fy = focal length in pixels
    // cx, cy = principal point (image center) in pixels

    let intrinsics = frame.camera.intrinsics
    let focalLengthPixels = intrinsics[0][0]  // fx (horizontal focal length)

    // Pinhole camera model: pixels_per_metre = focal_length_px / distance_m
    return focalLengthPixels / distanceMetres
}

// Example usage during calibration:
func calculateScaleFactor(frame: ARFrame, groundDistance: Float) {
    let ppm = pixelsPerMetre(at: groundDistance, from: frame)
    print("At \(groundDistance)m: \(ppm) pixels per metre")
    print("1 pixel = \(1.0 / ppm * 100) cm")

    // For 240fps tracking, this tells us position error per pixel
    // At 2.5m distance with ~1900px focal length:
    // ppm ≈ 760 px/m → 1 pixel ≈ 1.3mm
}
```

**Using LiDAR depth + raycasting for precise distance:**

```swift
func calibrateScaleFactor(arView: ARView, frame: ARFrame) {
    // Raycast from screen center to ground plane
    let screenCenter = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)

    guard let query = arView.makeRaycastQuery(
        from: screenCenter,
        allowing: .existingPlaneGeometry,
        alignment: .horizontal
    ) else { return }

    guard let result = arView.session.raycast(query).first else { return }

    // Distance from camera to ground
    let cameraPosition = frame.camera.transform.columns.3
    let groundPosition = result.worldTransform.columns.3
    let distance = simd_distance(
        simd_float3(cameraPosition.x, cameraPosition.y, cameraPosition.z),
        simd_float3(groundPosition.x, groundPosition.y, groundPosition.z)
    )

    let ppm = pixelsPerMetre(at: distance, from: frame)

    // Camera image resolution
    let imageWidth = CVPixelBufferGetWidth(frame.capturedImage)
    let imageHeight = CVPixelBufferGetHeight(frame.capturedImage)

    print("Camera resolution: \(imageWidth)x\(imageHeight)")
    print("Distance to ground: \(distance)m")
    print("Scale: \(ppm) px/m at ground level")
}
```

**IMPORTANT:** The pixels-per-metre scale is NOT constant across the image — it varies with depth. Objects closer to the camera appear larger. For the golf swing use case, the scale factor should be calculated at the **swing plane distance** (roughly where the club head will travel), typically 2-3 metres from the camera.

---

## 2. 3D Body Pose for Address Position Analysis

### 2.1 VNDetectHumanBodyPose3DRequest — Joint Names and Coordinate Space

Introduced in iOS 17 (WWDC23). Returns a 3D skeleton with **17 joints** in metres relative to the root joint.

**Complete list of 17 joints (`VNHumanBodyPose3DObservation.JointName`):**

| # | Joint Name | Body Group |
|---|-----------|------------|
| 1 | `.topHead` | Head |
| 2 | `.centerHead` | Head |
| 3 | `.centerShoulder` | Torso |
| 4 | `.leftShoulder` | Torso / Left Arm |
| 5 | `.rightShoulder` | Torso / Right Arm |
| 6 | `.spine` | Torso |
| 7 | `.root` | Torso (hip center) |
| 8 | `.leftHip` | Torso / Left Leg |
| 9 | `.rightHip` | Torso / Right Leg |
| 10 | `.leftElbow` | Left Arm |
| 11 | `.leftWrist` | Left Arm |
| 12 | `.rightElbow` | Right Arm |
| 13 | `.rightWrist` | Right Arm |
| 14 | `.leftKnee` | Left Leg |
| 15 | `.leftAnkle` | Left Leg |
| 16 | `.rightKnee` | Right Leg |
| 17 | `.rightAnkle` | Right Leg |

**Joint group names (`JointsGroupName`):**
- `.head` — topHead, centerHead
- `.torso` — centerShoulder, leftShoulder, rightShoulder, spine, root, leftHip, rightHip
- `.leftArm` — leftShoulder, leftElbow, leftWrist
- `.rightArm` — rightShoulder, rightElbow, rightWrist
- `.leftLeg` — leftHip, leftKnee, leftAnkle
- `.rightLeg` — rightHip, rightKnee, rightAnkle
- `.all` — all 17 joints

**Coordinate space:**
- Positions are in **metres**, relative to the **root joint** (hip center) as origin
- Left/right are relative to the **person** (not the camera/image)
- The `cameraOriginMatrix` on the observation provides the camera's position relative to the person, useful for transforming joint positions to camera/world space
- With LiDAR: true metric positions. Without LiDAR: assumes 1.8m reference height

### 2.2 Extracting Shoulder, Elbow, Wrist Positions

```swift
import Vision

func analyzeBodyPose(from image: CGImage) async throws -> BodyPoseData? {
    let request = VNDetectHumanBodyPose3DRequest()
    let handler = VNImageRequestHandler(cgImage: image, orientation: .up)

    try handler.perform([request])

    guard let observation = request.results?.first else {
        print("No body detected")
        return nil
    }

    // Body height (true metric with LiDAR, else 1.8m reference)
    let bodyHeight = observation.bodyHeight
    let heightTechnique = observation.heightEstimation
    print("Body height: \(bodyHeight)m (technique: \(heightTechnique))")

    // Extract key joints for golf address position
    let rightShoulder = try observation.recognizedPoint(.rightShoulder)
    let rightElbow = try observation.recognizedPoint(.rightElbow)
    let rightWrist = try observation.recognizedPoint(.rightWrist)
    let leftShoulder = try observation.recognizedPoint(.leftShoulder)
    let leftElbow = try observation.recognizedPoint(.leftElbow)
    let leftWrist = try observation.recognizedPoint(.leftWrist)
    let spine = try observation.recognizedPoint(.spine)
    let root = try observation.recognizedPoint(.root)
    let centerShoulder = try observation.recognizedPoint(.centerShoulder)

    // Joint positions are simd_float4x4 transforms relative to root
    // Extract position from the transform's translation column
    let rightWristPos = simd_float3(
        rightWrist.position.columns.3.x,
        rightWrist.position.columns.3.y,
        rightWrist.position.columns.3.z
    )

    let leftWristPos = simd_float3(
        leftWrist.position.columns.3.x,
        leftWrist.position.columns.3.y,
        leftWrist.position.columns.3.z
    )

    print("Right wrist position (relative to root): \(rightWristPos) metres")
    print("Left wrist position (relative to root): \(leftWristPos) metres")

    // Local position — relative to parent joint (elbow is parent of wrist)
    let rightWristLocal = rightWrist.localPosition
    print("Right wrist (relative to elbow): \(rightWristLocal)")

    // Camera origin matrix — camera position relative to person
    let cameraMatrix = observation.cameraOriginMatrix
    print("Camera position: \(cameraMatrix.columns.3)")

    return BodyPoseData(
        rightWrist: rightWristPos,
        leftWrist: leftWristPos,
        spine: extractPosition(spine),
        root: simd_float3(0, 0, 0),  // root is the origin
        bodyHeight: bodyHeight
    )
}

private func extractPosition(_ point: VNHumanBodyRecognizedPoint3D) -> simd_float3 {
    return simd_float3(
        point.position.columns.3.x,
        point.position.columns.3.y,
        point.position.columns.3.z
    )
}
```

**Projecting 3D joints back to 2D image coordinates:**

```swift
func project3DJointTo2D(
    observation: VNHumanBodyPose3DObservation,
    jointName: VNHumanBodyPose3DObservation.JointName
) throws -> CGPoint {
    // The observation can project back to 2D normalised coordinates
    let point2D = try observation.pointInImage(jointName)
    // Returns VNRecognizedPoint with x,y in Vision normalised coords (0..1, bottom-left origin)
    return VNImagePointForNormalizedPoint(
        CGPoint(x: point2D.x, y: point2D.y),
        Int(imageWidth),
        Int(imageHeight)
    )
}
```

### 2.3 Combining Body Pose with LiDAR Depth Data

The body pose positions from VNDetectHumanBodyPose3DRequest are already in metric space when LiDAR is available. However, you can cross-reference with LiDAR depth for additional precision:

```swift
func getDepthAtJoint(
    frame: ARFrame,
    jointScreenPosition: CGPoint,
    imageSize: CGSize
) -> Float? {
    guard let sceneDepth = frame.smoothedSceneDepth ?? frame.sceneDepth else {
        return nil
    }

    let depthMap = sceneDepth.depthMap
    let depthWidth = CVPixelBufferGetWidth(depthMap)   // 256
    let depthHeight = CVPixelBufferGetHeight(depthMap)  // 192

    // Scale from camera image coordinates to depth map coordinates
    let scaleX = Float(depthWidth) / Float(imageSize.width)
    let scaleY = Float(depthHeight) / Float(imageSize.height)

    let depthX = Int(Float(jointScreenPosition.x) * scaleX)
    let depthY = Int(Float(jointScreenPosition.y) * scaleY)

    guard depthX >= 0, depthX < depthWidth,
          depthY >= 0, depthY < depthHeight else {
        return nil
    }

    CVPixelBufferLockBaseAddress(depthMap, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }

    let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
    guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap)?
        .assumingMemoryBound(to: Float32.self) else {
        return nil
    }

    let index = depthY * bytesPerRow / MemoryLayout<Float32>.stride + depthX
    return baseAddress[index]  // Distance in metres
}
```

**Confidence map for filtering unreliable readings:**

```swift
func getDepthConfidence(
    frame: ARFrame,
    depthX: Int,
    depthY: Int
) -> ARConfidenceLevel? {
    guard let confidenceMap = frame.smoothedSceneDepth?.confidenceMap ??
                              frame.sceneDepth?.confidenceMap else {
        return nil
    }

    CVPixelBufferLockBaseAddress(confidenceMap, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(confidenceMap, .readOnly) }

    let bytesPerRow = CVPixelBufferGetBytesPerRow(confidenceMap)
    guard let baseAddress = CVPixelBufferGetBaseAddress(confidenceMap)?
        .assumingMemoryBound(to: UInt8.self) else {
        return nil
    }

    let index = depthY * bytesPerRow + depthX
    let value = baseAddress[index]

    // 0 = low, 1 = medium, 2 = high
    return ARConfidenceLevel(rawValue: Int(value))
}
```

### 2.4 Accuracy and Limitations of 3D Body Pose at 2-3m

**With LiDAR (iPhone 13 Pro):**
- Joint positions are in true metric scale (metres)
- `bodyHeight` reflects measured height, not the 1.8m fallback
- Positional accuracy: approximately 2-5cm for major joints at 2-3m distance
- Wrist detection is critical for golf — it is the most distal joint tracked (no hands/fingers)

**Without LiDAR:**
- Falls back to 1.8m reference height assumption
- All metric values are scaled based on this assumption
- If golfer is 1.7m or 1.9m tall, all measurements have proportional error

**Known limitations:**
- **Single person only** — detects only the closest/most prominent person
- **No hand or finger joints** — wrist is the last tracked point on each arm
- **No club detection** — body pose does not track held objects
- **Occlusion sensitivity** — joints behind the body may be estimated with lower accuracy
- **17 joints only** — no spine subdivisions, no foot orientation
- **Processing cost** — 3D pose is more expensive than 2D; suitable for static calibration, not 240fps
- **Distance range** — optimal at 1.5-4m; beyond 4m accuracy degrades

---

## 3. Club Measurement from Address Position

### 3.1 Detecting the Club Head at Address (Static)

At the address position, the club head is stationary and resting on the ground. This is the ideal time for detection — no motion blur.

**Strategy: Custom Core ML Model (recommended)**

For production, train a YOLO model on golf club head images using Create ML:

```swift
import Vision
import CoreML

func detectClubHead(in image: CGImage) async throws -> CGRect? {
    // Load custom-trained club head detection model
    guard let model = try? VNCoreMLModel(
        for: GolfClubHeadDetector(configuration: .init()).model
    ) else {
        print("Failed to load club head model")
        return nil
    }

    let request = VNCoreMLRequest(model: model)
    request.imageCropAndScaleOption = .scaleFill

    let handler = VNImageRequestHandler(cgImage: image, orientation: .up)
    try handler.perform([request])

    guard let results = request.results as? [VNRecognizedObjectObservation],
          let bestResult = results.first else {
        return nil
    }

    // Returns bounding box in Vision normalised coordinates (0..1, bottom-left origin)
    print("Club head detected with confidence: \(bestResult.confidence)")
    return bestResult.boundingBox
}
```

**Strategy: Contour Detection (fallback/prototype)**

For early prototyping before the ML model is trained:

```swift
import Vision

func detectClubHeadViaContours(in image: CGImage) throws -> CGPoint? {
    let contourRequest = VNDetectContoursRequest()
    contourRequest.contrastAdjustment = 2.0
    contourRequest.detectsDarkOnLight = true

    let handler = VNImageRequestHandler(cgImage: image, orientation: .up)
    try handler.perform([contourRequest])

    guard let contours = contourRequest.results?.first else {
        return nil
    }

    // Filter contours by area and position (club head is near bottom of frame)
    // This requires heuristics based on expected club head size and position
    // Not recommended for production — use ML model instead

    return nil // Placeholder — requires significant heuristic tuning
}
```

**Strategy: User-Guided Tap (simplest, current implementation)**

The current `ManualCalibrationView.swift` uses manual tapping — user taps the club head on screen. This is the simplest and most reliable approach for calibration:

```swift
// User taps club head location on camera preview
// Convert tap to 3D via raycasting (see Section 1.3)
// This is already partially implemented in ManualCalibrationView
```

### 3.2 Getting Club Head 3D Position from LiDAR Depth

Once the club head is located in 2D (either via ML detection or user tap), retrieve its 3D position:

```swift
func getClubHead3DPosition(
    screenPosition: CGPoint,
    arView: ARView,
    frame: ARFrame
) -> simd_float3? {

    // Method 1: Raycast from screen position to ground plane
    // Best when club head is resting on the ground at address
    if let query = arView.makeRaycastQuery(
        from: screenPosition,
        allowing: .existingPlaneGeometry,
        alignment: .horizontal
    ) {
        if let result = arView.session.raycast(query).first {
            let pos = result.worldTransform.columns.3
            return simd_float3(pos.x, pos.y, pos.z)
        }
    }

    // Method 2: Use LiDAR depth map directly
    // Better when club head is elevated (e.g. during waggle)
    let imageSize = CGSize(
        width: CVPixelBufferGetWidth(frame.capturedImage),
        height: CVPixelBufferGetHeight(frame.capturedImage)
    )

    guard let depthMetres = getDepthAtJoint(
        frame: frame,
        jointScreenPosition: screenPosition,
        imageSize: imageSize
    ) else {
        return nil
    }

    // Unproject 2D + depth to 3D using camera intrinsics
    let intrinsics = frame.camera.intrinsics
    let fx = intrinsics[0][0]
    let fy = intrinsics[1][1]
    let cx = intrinsics[2][0]
    let cy = intrinsics[2][1]

    // Convert screen position to camera image coordinates
    // (accounting for any preview scaling)
    let imgX = Float(screenPosition.x)  // adjust for preview-to-image mapping
    let imgY = Float(screenPosition.y)

    // Unproject using pinhole model
    let x = (imgX - cx) * depthMetres / fx
    let y = (imgY - cy) * depthMetres / fy
    let z = depthMetres

    // This is in camera-local coordinates
    // Transform to world coordinates using camera transform
    let cameraTransform = frame.camera.transform
    let cameraPoint = simd_float4(x, y, z, 1.0)
    let worldPoint = cameraTransform * cameraPoint

    return simd_float3(worldPoint.x, worldPoint.y, worldPoint.z)
}
```

### 3.3 Calculating Club Length (Wrist-to-Clubhead 3D Distance)

```swift
struct ClubCalibrationData {
    let clubHeadPosition: simd_float3   // From LiDAR/raycast
    let leadWristPosition: simd_float3  // From body pose (left wrist for right-handed)
    let trailWristPosition: simd_float3 // From body pose (right wrist for right-handed)
    let groundPlaneY: Float             // From plane detection

    /// Club length from lead wrist to club head (metres)
    var clubLength: Float {
        simd_distance(leadWristPosition, clubHeadPosition)
    }

    /// Shaft vector from grip to club head
    var shaftVector: simd_float3 {
        simd_normalize(clubHeadPosition - leadWristPosition)
    }

    /// Grip midpoint (between lead and trail wrists)
    var gripCenter: simd_float3 {
        (leadWristPosition + trailWristPosition) / 2.0
    }
}

func measureClub(
    bodyPose: BodyPoseData,
    clubHeadWorldPos: simd_float3,
    groundY: Float,
    isRightHanded: Bool
) -> ClubCalibrationData {
    // For a right-handed golfer:
    // Lead hand (lower on grip) = left hand
    // Trail hand (upper on grip) = right hand
    let leadWrist = isRightHanded ? bodyPose.leftWrist : bodyPose.rightWrist
    let trailWrist = isRightHanded ? bodyPose.rightWrist : bodyPose.leftWrist

    // NOTE: Body pose positions are relative to root (hip center)
    // Must transform to world coordinates using cameraOriginMatrix
    // if comparing with ARKit world-space club head position

    return ClubCalibrationData(
        clubHeadPosition: clubHeadWorldPos,
        leadWristPosition: leadWrist,
        trailWristPosition: trailWrist,
        groundPlaneY: groundY
    )
}
```

### 3.4 Calculating Lie Angle (Shaft vs Ground Plane)

The lie angle is the angle between the club shaft and the ground plane. For a standard iron, this is typically 60-65 degrees.

```swift
func calculateLieAngle(calibration: ClubCalibrationData) -> Float {
    // Shaft vector from wrist down to club head
    let shaft = calibration.shaftVector

    // Ground plane normal (pointing up)
    let groundNormal = simd_float3(0, 1, 0)

    // Ground plane tangent (project shaft onto ground plane)
    // The shaft direction projected onto the horizontal plane
    let shaftHorizontal = simd_float3(shaft.x, 0, shaft.z)

    // Lie angle = angle between shaft and its horizontal projection
    // = 90 - angle between shaft and ground normal
    let angleToVertical = acos(simd_dot(simd_normalize(shaft), groundNormal))
    let lieAngle = Float.pi / 2.0 - angleToVertical

    let lieAngleDegrees = lieAngle * 180.0 / Float.pi
    print("Lie angle: \(lieAngleDegrees) degrees")

    return lieAngleDegrees
}
```

### 3.5 Estimating Swing Plane from Address Position

The swing plane is defined by three points: spine angle, hand position, and club head position.

```swift
func estimateSwingPlane(
    bodyPose: BodyPoseData,
    clubHeadPosition: simd_float3
) -> (normal: simd_float3, angle: Float) {
    // Three points define the swing plane:
    // 1. Spine/shoulder center
    // 2. Hand position (wrist midpoint)
    // 3. Club head position

    let shoulder = bodyPose.spine  // or centerShoulder
    let hands = (bodyPose.leftWrist + bodyPose.rightWrist) / 2.0
    let clubHead = clubHeadPosition

    // Two vectors in the plane
    let v1 = hands - shoulder
    let v2 = clubHead - shoulder

    // Plane normal = cross product of the two vectors
    let planeNormal = simd_normalize(simd_cross(v1, v2))

    // Swing plane angle relative to ground
    // = angle between plane normal and horizontal
    let groundNormal = simd_float3(0, 1, 0)
    let angleToGround = acos(abs(simd_dot(planeNormal, groundNormal)))
    let swingPlaneAngle = Float.pi / 2.0 - angleToGround

    let angleDegrees = swingPlaneAngle * 180.0 / Float.pi
    print("Estimated swing plane angle: \(angleDegrees) degrees from horizontal")

    return (normal: planeNormal, angle: angleDegrees)
}
```

**These calibration values become Kalman filter constraints during tracking:**
- Club head must be within `clubLength` of the detected wrist
- Club head should remain approximately in the swing plane (with some deviation)
- At impact, club head should be near the ground plane Y

---

## 4. Key Constraints and Limitations

### 4.1 LiDAR Hardware Specs

| Property | Value |
|----------|-------|
| Frame rate | 60 Hz (vs 240fps camera) |
| Resolution | 256 x 192 pixels |
| Range | 0.2 - 5.0 metres |
| Technology | dToF (direct Time of Flight) |

**Why LiDAR cannot track the swing:**
- At 60Hz, a 100mph club head moves ~0.75 metres between LiDAR frames
- 256x192 resolution is too coarse for sub-centimetre club head tracking
- LiDAR is only suitable for **static calibration** at the address position

### 4.2 LiDAR During Static Calibration Only

The calibration workflow should be:
1. **Start ARKit session** with LiDAR + plane detection
2. **Golfer stands at address** — static position, club on ground
3. **Detect ground plane** via ARKit plane detection
4. **Run 3D body pose** on the current frame
5. **Detect/tap club head** position
6. **Calculate calibration values:** club length, lie angle, swing plane, pixels-per-metre
7. **Pause ARKit session**
8. **Switch to AVCaptureSession** for 240fps capture

### 4.3 iPhone 13 Pro Specific Considerations

- Has LiDAR scanner (same hardware as 12 Pro)
- Supports ARWorldTrackingConfiguration with sceneReconstruction
- Supports `.smoothedSceneDepth` frame semantics
- Camera: 1920x1440 at up to 240fps (actual fps may vary — 162-200fps reported)
- A15 Bionic chip — adequate for post-capture processing but thermal throttling under sustained load
- `VNDetectHumanBodyPose3DRequest` requires iOS 17+ (available on iPhone 13 Pro)

### 4.4 ARKit Session and AVCaptureSession Coexistence

**They CANNOT run simultaneously.** This is a fundamental iOS limitation.

When you start an AVCaptureSession, any running ARSession stops. When you start an ARSession, any running AVCaptureSession stops.

**Recommended workflow for the golf app:**

```
┌─────────────────────────────────────────┐
│  Phase 1: CALIBRATION (ARKit)           │
│  - ARWorldTrackingConfiguration         │
│  - LiDAR scene depth                    │
│  - Plane detection                      │
│  - 3D body pose analysis                │
│  - Club measurement                     │
│  - Store calibration data               │
│  - Pause ARSession                      │
└────────────────┬────────────────────────┘
                 │ ~0.3-0.5s switch time
┌────────────────▼────────────────────────┐
│  Phase 2: CAPTURE (AVFoundation)        │
│  - AVCaptureSession at 240fps           │
│  - Audio detection for swing trigger    │
│  - High-speed video capture             │
│  - Use stored calibration values        │
│  - No LiDAR/ARKit available             │
└─────────────────────────────────────────┘
```

**Switching timing (measured by community):**
- ARKit → AVCaptureSession: ~0.3 seconds (using AVCaptureVideoDataOutput)
- Need to drop first ~5 frames from AVCaptureSession (they are dark)
- Total transition: ~0.5 seconds visible screen freeze
- 0.05 radians (~3 degrees) orientation drift during switch

**Saving and restoring ARKit state:**

```swift
// Before switching to AVCaptureSession
func saveARState(session: ARSession, completion: @escaping (ARWorldMap?) -> Void) {
    session.getCurrentWorldMap { worldMap, error in
        if let map = worldMap {
            // Store for potential later re-calibration
            completion(map)
        } else {
            completion(nil)
        }
        session.pause()
    }
}

// Later, if you need to re-enter ARKit
func restoreARState(arView: ARView, worldMap: ARWorldMap) {
    let config = ARWorldTrackingConfiguration()
    config.initialWorldMap = worldMap
    config.planeDetection = [.horizontal]
    arView.session.run(config, options: [])
}
```

---

## 5. Complete Calibration Flow — Swift Code

### 5.1 Full ARKit Calibration Session Setup

```swift
import ARKit
import RealityKit
import Vision
import Combine

@Observable
class LiDARCalibrationManager: NSObject, ARSessionDelegate {

    // MARK: - Published State
    var isCalibrating = false
    var groundPlaneDetected = false
    var bodyPoseDetected = false
    var calibrationComplete = false
    var statusMessage = "Initialising..."

    // MARK: - Calibration Results
    var groundPlaneY: Float = 0
    var groundPlaneNormal: simd_float3 = simd_float3(0, 1, 0)
    var clubLength: Float = 0          // metres
    var lieAngle: Float = 0            // degrees
    var swingPlaneAngle: Float = 0     // degrees
    var pixelsPerMetreAtSwingPlane: Float = 0
    var distanceToGolfer: Float = 0    // metres

    // MARK: - Internal
    private var arView: ARView?
    private var detectedGroundAnchor: ARPlaneAnchor?
    private var latestFrame: ARFrame?

    // MARK: - Setup

    func configureARView(_ arView: ARView) {
        self.arView = arView
        arView.session.delegate = self
    }

    func startCalibration() {
        guard let arView else { return }

        let config = ARWorldTrackingConfiguration()

        // Ground plane detection
        config.planeDetection = [.horizontal]

        // LiDAR scene depth
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.smoothedSceneDepth) {
            config.frameSemantics.insert(.smoothedSceneDepth)
        }

        // Scene reconstruction (for mesh classification)
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            config.sceneReconstruction = .meshWithClassification
        }

        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        isCalibrating = true
        statusMessage = "Scanning ground plane..."
    }

    func stopCalibration() {
        arView?.session.pause()
        isCalibrating = false
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let plane = anchor as? ARPlaneAnchor,
               plane.alignment == .horizontal {
                detectedGroundAnchor = plane
                groundPlaneY = plane.transform.columns.3.y
                groundPlaneDetected = true
                statusMessage = "Ground detected. Position golfer at address."
            }
        }
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        latestFrame = frame
    }

    // MARK: - Depth Reading

    func depthAtScreenPoint(_ point: CGPoint) -> Float? {
        guard let frame = latestFrame,
              let sceneDepth = frame.smoothedSceneDepth ?? frame.sceneDepth else {
            return nil
        }

        let depthMap = sceneDepth.depthMap
        let depthW = CVPixelBufferGetWidth(depthMap)
        let depthH = CVPixelBufferGetHeight(depthMap)

        let imgW = CVPixelBufferGetWidth(frame.capturedImage)
        let imgH = CVPixelBufferGetHeight(frame.capturedImage)

        // Scale from image coordinates to depth map coordinates
        let dx = Int(Float(point.x) / Float(imgW) * Float(depthW))
        let dy = Int(Float(point.y) / Float(imgH) * Float(depthH))

        guard dx >= 0, dx < depthW, dy >= 0, dy < depthH else { return nil }

        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }

        let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
        guard let base = CVPixelBufferGetBaseAddress(depthMap)?
            .assumingMemoryBound(to: Float32.self) else { return nil }

        let index = dy * bytesPerRow / MemoryLayout<Float32>.stride + dx
        return base[index]
    }

    // MARK: - Raycast from Screen Tap

    func worldPosition(fromScreenPoint point: CGPoint) -> simd_float3? {
        guard let arView else { return nil }

        guard let query = arView.makeRaycastQuery(
            from: point,
            allowing: .existingPlaneGeometry,
            alignment: .horizontal
        ) else { return nil }

        guard let result = arView.session.raycast(query).first else { return nil }

        let col3 = result.worldTransform.columns.3
        return simd_float3(col3.x, col3.y, col3.z)
    }

    // MARK: - 3D Body Pose

    func analyzeBodyPose() async -> BodyPoseResult? {
        guard let frame = latestFrame else { return nil }

        let pixelBuffer = frame.capturedImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        let request = VNDetectHumanBodyPose3DRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .right)

        do {
            try handler.perform([request])
        } catch {
            print("Body pose failed: \(error)")
            return nil
        }

        guard let obs = request.results?.first else {
            statusMessage = "No person detected. Stand at address."
            return nil
        }

        bodyPoseDetected = true

        // Extract wrist positions
        let lw = try? obs.recognizedPoint(.leftWrist)
        let rw = try? obs.recognizedPoint(.rightWrist)
        let sp = try? obs.recognizedPoint(.spine)
        let cs = try? obs.recognizedPoint(.centerShoulder)

        func pos(_ p: VNHumanBodyRecognizedPoint3D?) -> simd_float3? {
            guard let p else { return nil }
            return simd_float3(
                p.position.columns.3.x,
                p.position.columns.3.y,
                p.position.columns.3.z
            )
        }

        return BodyPoseResult(
            leftWrist: pos(lw),
            rightWrist: pos(rw),
            spine: pos(sp),
            centerShoulder: pos(cs),
            bodyHeight: obs.bodyHeight,
            cameraOriginMatrix: obs.cameraOriginMatrix
        )
    }

    // MARK: - Pixels Per Metre

    func calculatePixelsPerMetre(atDistance distance: Float) -> Float {
        guard let frame = latestFrame else { return 0 }
        let fx = frame.camera.intrinsics[0][0]
        return fx / distance
    }

    // MARK: - Complete Calibration

    func performFullCalibration(
        clubHeadScreenPoint: CGPoint,
        isRightHanded: Bool
    ) async -> Bool {

        // 1. Get club head 3D position via raycast
        guard let clubHead3D = worldPosition(fromScreenPoint: clubHeadScreenPoint) else {
            statusMessage = "Could not locate club head in 3D"
            return false
        }

        // 2. Analyze body pose
        guard let pose = await analyzeBodyPose() else {
            statusMessage = "Could not detect body pose"
            return false
        }

        // 3. Determine lead/trail wrist
        guard let leadWrist = isRightHanded ? pose.leftWrist : pose.rightWrist,
              let trailWrist = isRightHanded ? pose.rightWrist : pose.leftWrist,
              let spine = pose.spine else {
            statusMessage = "Missing joint data"
            return false
        }

        // NOTE: Body pose positions are relative to root joint.
        // Club head position is in ARKit world space.
        // Must transform body pose to world space using cameraOriginMatrix
        // before comparing. This is a simplification — in production,
        // use the full transform chain.

        // 4. Calculate club length
        clubLength = simd_distance(leadWrist, clubHead3D)

        // 5. Calculate lie angle
        let shaftVec = simd_normalize(clubHead3D - leadWrist)
        let angleToVert = acos(simd_dot(shaftVec, simd_float3(0, 1, 0)))
        lieAngle = (Float.pi / 2.0 - angleToVert) * 180.0 / Float.pi

        // 6. Estimate swing plane
        let hands = (leadWrist + trailWrist) / 2.0
        let v1 = hands - spine
        let v2 = clubHead3D - spine
        let planeNorm = simd_normalize(simd_cross(v1, v2))
        let groundAngle = acos(abs(simd_dot(planeNorm, simd_float3(0, 1, 0))))
        swingPlaneAngle = (Float.pi / 2.0 - groundAngle) * 180.0 / Float.pi

        // 7. Calculate pixels-per-metre at swing plane distance
        guard let frame = latestFrame else { return false }
        let camPos = frame.camera.transform.columns.3
        distanceToGolfer = simd_distance(
            simd_float3(camPos.x, camPos.y, camPos.z),
            hands
        )
        pixelsPerMetreAtSwingPlane = calculatePixelsPerMetre(atDistance: distanceToGolfer)

        statusMessage = "Calibration complete"
        calibrationComplete = true

        print("""
        === Calibration Results ===
        Club length: \(clubLength * 100) cm
        Lie angle: \(lieAngle)°
        Swing plane: \(swingPlaneAngle)° from horizontal
        Distance to golfer: \(distanceToGolfer) m
        Scale: \(pixelsPerMetreAtSwingPlane) px/m
        1 pixel ≈ \(1.0 / pixelsPerMetreAtSwingPlane * 1000) mm
        """)

        return true
    }
}

// MARK: - Data Types

struct BodyPoseResult {
    let leftWrist: simd_float3?
    let rightWrist: simd_float3?
    let spine: simd_float3?
    let centerShoulder: simd_float3?
    let bodyHeight: Float
    let cameraOriginMatrix: simd_float4x4
}
```

### 5.2 SwiftUI Integration for ARView

```swift
import SwiftUI
import ARKit
import RealityKit

struct ARCalibrationView: UIViewRepresentable {
    let calibrationManager: LiDARCalibrationManager

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        calibrationManager.configureARView(arView)

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(manager: calibrationManager)
    }

    class Coordinator: NSObject {
        let manager: LiDARCalibrationManager

        init(manager: LiDARCalibrationManager) {
            self.manager = manager
        }

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return }
            let point = sender.location(in: arView)

            // User taps club head position
            Task {
                await manager.performFullCalibration(
                    clubHeadScreenPoint: point,
                    isRightHanded: true
                )
            }
        }
    }
}
```

---

## 6. Coordinate Space Summary

| Data Source | Coordinate Space | Units | Origin |
|-------------|-----------------|-------|--------|
| ARKit world tracking | World space | Metres | Session start position |
| ARPlaneAnchor | World space (via transform) | Metres | Anchor center |
| ARKit raycast result | World space (worldTransform) | Metres | Intersection point |
| ARFrame.sceneDepth | Depth map (256x192) | Metres (Float32) | Per-pixel distance from camera |
| ARCamera.intrinsics | Pixel space | Pixels (focal length) | Camera sensor |
| VNDetectHumanBodyPose3DRequest | Skeleton-local | Metres | Root joint (hip center) |
| VNHumanBodyRecognizedPoint3D.position | Skeleton-local | Metres | Root joint |
| VNHumanBodyRecognizedPoint3D.localPosition | Parent-joint-local | Metres | Parent joint |
| cameraOriginMatrix | Camera-to-skeleton | Metres | Camera position relative to person |

**Critical: Coordinate transform chain for comparing body pose with ARKit positions:**
```
Body pose (root-relative) → cameraOriginMatrix → Camera space → ARFrame.camera.transform → World space
```

---

## 7. References

- [ARWorldTrackingConfiguration — Apple Developer](https://developer.apple.com/documentation/arkit/arworldtrackingconfiguration)
- [Visualizing and Interacting with a Reconstructed Scene — Apple Developer](https://developer.apple.com/documentation/ARKit/visualizing-and-interacting-with-a-reconstructed-scene)
- [sceneReconstruction Property — Apple Developer](https://developer.apple.com/documentation/arkit/arworldtrackingconfiguration/scenereconstruction)
- [VNDetectHumanBodyPose3DRequest — Apple Developer](https://developer.apple.com/documentation/vision/vndetecthumanbodypose3drequest)
- [VNHumanBodyPose3DObservation.JointName — Apple Developer](https://developer.apple.com/documentation/vision/vnhumanbodypose3dobservation/jointname)
- [Detecting Human Body Poses in 3D with Vision — Apple Developer](https://developer.apple.com/documentation/Vision/detecting-human-body-poses-in-3d-with-vision)
- [Explore 3D Body Pose and Person Segmentation in Vision — WWDC23](https://developer.apple.com/videos/play/wwdc2023/111241/)
- [Placing Objects and Handling 3D Interaction — Apple Developer](https://developer.apple.com/documentation/arkit/world_tracking/placing_objects_and_handling_3d_interaction)
- [ARDepthData — Apple Developer](https://developer.apple.com/documentation/arkit/ardepthdata)
- [ARCamera — Apple Developer](https://developer.apple.com/documentation/arkit/arcamera)
- [Tracking and Visualizing Planes — Apple Developer](https://developer.apple.com/documentation/arkit/arkit_in_ios/content_anchors/tracking_and_visualizing_planes)
- [ARKit and AVFoundation Switching Timing — Medium](https://rockyshikoku.medium.com/how-many-seconds-does-it-take-to-switch-between-arkit-and-avfoundation-5b8eebcadf2c)
- [LiDAR Depth Reading — Medium](https://rockyshikoku.medium.com/obtain-the-distance-in-meters-from-scenedepth-ardepthdata-which-measures-the-distance-between-f900f10d4161)
- [WWDC23 3D Body Pose Analysis — Medium](https://medium.com/@frentebw/wwdc2023-apples-new-vision-framework-with-3d-detection-9335051d7acd)
- [ARKit 911 Scene Reconstruction — Medium](https://medium.com/macoclock/arkit-911-scene-reconstruction-with-a-lidar-scanner-57ff0a8b247e)
- [ARKit LiDAR Point Clouds — Medium](https://medium.com/@ivkuznetsov/arkit-lidar-building-point-clouds-in-swift-2c9b7eb88b03)
- [ARKit in a SwiftUI App — gfrigerio.com](https://www.gfrigerio.com/arkit-in-a-swiftui-app/)
- [Apple Developer Forums — ARKit + AVCaptureSession](https://developer.apple.com/forums/thread/677731)
