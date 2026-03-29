# Phase 2 Architecture — Automated Speed Measurement Pipeline

> **Date:** March 2026
> **Status:** Implementation in progress
> **Goal:** Replace manual frame-by-frame analysis with fully automated club head tracking and speed calculation

---

## Overview

Phase 2 transforms the app from a manual measurement prototype into an automated speed measurement system. The pipeline:

1. **Calibration** (once per session): LiDAR scene scan + address position analysis → pixels-per-metre, club length, swing plane
2. **Detection** (idle): Audio monitoring triggers 240fps recording on swing onset
3. **Capture** (0.5-3s): 240fps video recording of full swing
4. **Analysis** (post-capture, 3-15s): Frame-by-frame tracking → speed calculation → results

---

## Component Architecture

### 2.1 LiDAR Scene Calibration (`LiDARCalibrationManager`)

**Purpose:** Establish real-world scale and 3D coordinate system using ARKit + LiDAR.

**Implementation:**
- `ARWorldTrackingConfiguration` with scene reconstruction enabled
- Detect ground plane via `ARPlaneAnchor` classification
- User taps screen → raycast to get 3D world coordinate
- Calculate pixels-per-metre from known 3D distances
- Camera intrinsics from `ARFrame.camera.intrinsics` for perspective correction

**Key Constraint:** ARKit session and AVCaptureSession cannot run simultaneously on iOS. LiDAR calibration must complete BEFORE switching to 240fps capture mode.

**Fallback:** If LiDAR unavailable (non-Pro iPhone), fall back to manual calibration (already implemented).

### 2.2 Address Position Analysis (`AddressAnalyser`)

**Purpose:** While golfer stands at address (static), measure club dimensions and define swing plane.

**Implementation:**
- `VNDetectHumanBodyPose3DRequest` → 3D skeleton (17 joints in metres)
- Extract lead arm: shoulder → elbow → wrist in world coordinates
- Club head detection at address (static frame = no blur, easier detection)
- Club head 3D position from LiDAR depth map at detected pixel location
- Calculate:
  - **Club length:** 3D distance from wrist to club head
  - **Lie angle:** angle between shaft vector and ground plane
  - **Arm length:** shoulder → wrist 3D distance
  - **Swing plane:** plane through spine, hands, club head → predicted arc
  - **Ball position:** detect white sphere + LiDAR depth confirmation

### 2.3 Club Head Detection (`ClubHeadDetector`)

**Purpose:** Detect club head in individual video frames.

**Strategy (no trained ML model yet):**

Phase 2a — Vision framework approach (ship now):
1. **At address:** Use calibrated club head position from address analysis as initial detection
2. **During swing:** VNTrackObjectRequest tracks from known position
3. **Motion-based fallback:** Frame differencing in the expected club head region (constrained by club length from wrist)
4. **Optical flow:** VNGenerateOpticalFlowRequest between consecutive frames

Phase 2b — Trained ML model (future):
1. Collect training data from app users (with consent)
2. Train YOLO-style detector via Create ML
3. Replace optical flow tracking with ML detection

### 2.4 Tracking Pipeline (enhanced `TrackingPipeline`)

**Existing:** YOLO → Vision tracking → Kalman filter (architecture built, needs ML model)

**Enhancement for Phase 2:**
- Start tracking from calibrated address position (known club head location)
- Use VNGenerateOpticalFlowRequest as primary tracking between frames
- Kalman filter constrains predictions using:
  - Club length radius from wrist
  - Swing plane constraint (club head stays approximately in plane)
  - Maximum acceleration limits (physics-based)
- Periodic re-detection via Vision VNTrackObjectRequest
- Confidence scoring combining: detection source, constraint satisfaction, trajectory smoothness

### 2.5 Speed Calculation (enhanced `SpeedCalculator`)

**Existing:** 2D pixel distance × calibration scale ÷ time delta

**Enhancement for Phase 2:**
- **3D swing plane projection:** Convert 2D tracked positions to 3D arc positions using swing plane model
- **Perspective correction:** Adjust pixels-per-metre based on estimated depth at each point in the arc
- **Multi-frame regression:** Fit speed curve using 5+ frames near impact, not just 2-frame differencing
- **Motion blur fusion:** Use blur streak length as supplementary speed signal
- **Impact detection:** Combine audio impact timestamp with tracking data for precise impact frame

**3D Speed Correction Factor:**
The club swings through a tilted plane. A front-on camera sees only the component of motion perpendicular to the camera axis. The correction factor depends on:
- Swing plane tilt angle (from address calibration)
- Position in the arc (impact zone is approximately perpendicular to camera = most accurate)
- Camera-to-golfer distance

For a typical front-on view with 45° swing plane:
- At impact (club moving roughly perpendicular to camera): correction ≈ 1.0-1.05×
- At top of swing (club moving roughly parallel to camera): correction ≈ 1.5-2.0×
- **Most critical measurement (impact speed) is also the most accurate**

### 2.6 Auto Swing Detection (wiring `SwingAudioDetector` + `SwingStateMachine`)

**Existing:** Both components built independently. Need to be wired together.

**Flow:**
1. App starts in IDLE state with audio monitoring active (low power)
2. Audio detects swing onset (whoosh) → trigger state machine → start 240fps recording
3. Audio detects impact → record timestamp for analysis
4. Audio detects swing complete → stop recording
5. PostCaptureAnalysisEngine processes the recorded video
6. Results displayed, swing saved

---

## File Plan

### New Files
| File | Purpose |
|---|---|
| `Features/Calibration/LiDARCalibrationManager.swift` | ARKit + LiDAR scene calibration |
| `Features/Calibration/AddressAnalyser.swift` | Address position analysis (3D pose + club measurement) |
| `Features/Capture/SwingCaptureCoordinator.swift` | Orchestrates the full capture flow (audio → record → analyse) |
| `Features/SpeedCalc/SwingPlaneCorrector.swift` | 3D swing plane projection + perspective correction |
| `Features/Tracking/OpticalFlowTracker.swift` | VNGenerateOpticalFlowRequest wrapper for frame-to-frame tracking |
| `GolfSwingSpeedAppTests/LiDARCalibrationTests.swift` | Unit tests for calibration maths |
| `GolfSwingSpeedAppTests/SwingPlaneCorrectionTests.swift` | Unit tests for 3D correction |
| `GolfSwingSpeedAppTests/TrackingPipelineTests.swift` | Unit tests for tracking pipeline |
| `GolfSwingSpeedAppTests/SwingCaptureCoordinatorTests.swift` | Unit tests for capture flow |

### Modified Files
| File | Changes |
|---|---|
| `TrackingPipeline.swift` | Add optical flow tracking, swing plane constraint |
| `SpeedCalculator.swift` | Add 3D correction, multi-frame regression, blur fusion |
| `PostCaptureAnalysisEngine.swift` | Wire up new tracking, use auto-detected impact |
| `CaptureView.swift` | Wire auto-detection, show processing progress |
| `CalibrationManager.swift` | Support LiDAR calibration mode |
| `CameraManager.swift` | Support switching between ARKit and AVCapture modes |
| `SwingStateMachine.swift` | Wire to audio detector for auto-triggering |

---

## Testing Strategy

Each component gets:
1. **Unit tests with mock data** — verify maths and logic
2. **Integration test** — verify components work together
3. **Code review** — architectural review before commit

Key test scenarios:
- Speed calculation accuracy with known inputs (100 mph = specific pixel displacement at specific calibration)
- Kalman filter convergence with simulated swing trajectory
- Swing plane correction factors match expected physics
- Perspective correction at different camera distances
- Audio detection state machine transitions
- Full pipeline: mock frames → tracked positions → speed result

---

## Accuracy Targets

| Measurement | Phase 1 (Manual) | Phase 2 (Automated) | Notes |
|---|---|---|---|
| Impact speed | ±5-8 mph | ±3-5 mph | 3D correction + multi-frame fit |
| Consistency | Variable | ±2 mph run-to-run | Same swing should give same result |
| Lag angle | N/A | ±5° | 3D pose at 240fps |
| Release point | N/A | ±10° arm rotation | ±4ms temporal precision |

---

*This document will be updated as implementation progresses.*
