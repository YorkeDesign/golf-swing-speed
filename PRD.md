# Golf Swing Speed App — Product Requirements Document

> **Version:** 1.0
> **Date:** March 2026
> **Status:** Approved for development
> **Platform:** iOS 17.0+ (iPhone 12 Pro and later)

---

## 1. Executive Summary

Golf Swing Speed App is a free iPhone app that measures golf club head speed and analyses wrist lag/release using only the device's built-in LiDAR scanner, 240fps camera, and microphone — no external hardware required.

The app targets speed training golfers who currently must spend $300–$25,000 on dedicated launch monitors to get swing speed data. One competitor (ShotVision) attempts camera-only speed measurement but with poor reliability (30–50% accuracy loss in bad lighting). Our approach combines LiDAR-calibrated 3D measurement, Apple's built-in 3D body pose estimation, audio-triggered capture, and adaptive post-capture analysis to deliver accurate speed measurement and lag angle analysis from a single iPhone.

**Core value proposition:** Accurate club head speed + casting/lag analysis, instantly, for free, from the iPhone already in your pocket.

---

## 2. Product Vision & Strategy

### 2.1 Why This Exists
Speed training is one of the fastest-growing areas in golf instruction. Programs like SuperSpeed Golf, The Stack, and overspeed training protocols require golfers to measure and track club head speed across hundreds of swings per session. Current options:

| Option | Cost | Portability | Speed Data |
|---|---|---|---|
| Trackman / GCQuad | $12,000–$25,000 | Low | Excellent |
| Garmin R10 / Rapsodo | $400–$700 | Medium | Good |
| ShotVision (app) | Free/subscription | Excellent | Unreliable |
| **Our app** | **Free / Freemium** | **Excellent** | **Good (±3-5 mph target)** |

### 2.2 Competitive Positioning
- **vs Launch monitors:** We're not trying to replace a $20K Trackman. We're the tool you grab when you're in the backyard with a speed stick doing 50 swings and just want to know your numbers
- **vs ShotVision:** Same concept, but we use LiDAR calibration (they don't), 3D body pose (they don't), audio-triggered capture (they don't), and 240fps analysis (they use standard camera rates). Our reliability should be significantly higher
- **vs SwingVision (tennis):** Proves the concept works. Their founder (ex-Tesla Autopilot) validated camera-only speed tracking on iPhone. Golf is harder (smaller, faster object) but our 240fps gives 4x their temporal resolution
- **Unique differentiators:** LiDAR calibration, 3D lag angle analysis, audio-triggered capture, address-position equipment measurement, adaptive frame sampling

### 2.3 Moat
- ML model trained on golf club heads improves with every swing analysed
- LiDAR calibration is iPhone-exclusive (Android can't replicate)
- Address-position equipment calibration (club length, lie angle, swing plane) constrains tracking in ways competitors can't match
- Future learned inference model ("Coach's Eye") becomes a compounding data advantage

---

## 3. Target Users

### 3.1 Primary: Speed Training Golfers
- **Who:** Amateur golfers (5-25 handicap) doing dedicated speed training with protocols like SuperSpeed Golf, The Stack, or overspeed training
- **Need:** Quick, repeated speed measurement across 30-100+ swings per session. Currently using no measurement or borrowing a friend's launch monitor
- **Use case:** Backyard, range, or indoor hitting bay. Phone on a tripod, train for 15-30 minutes, review speed trends after

### 3.2 Secondary: Golf Coaches
- **Who:** Teaching pros, golf coaches, junior coaches
- **Need:** Lightweight speed measurement tool for lessons without hauling a launch monitor to every session
- **Use case:** Quick speed check during a lesson. Show a student their casting pattern via lag analysis

### 3.3 Tertiary: Curious Recreational Golfers
- **Who:** Casual golfers who've never measured their swing speed
- **Need:** "How fast do I actually swing?" — one-time curiosity or occasional check-in
- **Use case:** At the range, set up phone, hit a few shots, see numbers

---

## 4. Monetisation — Freemium Model

### 4.1 Free Tier
- Club head speed measurement (impact speed)
- Speed readout via voice/beep
- Basic swing history (last 50 swings)
- Manual calibration (tap-to-set)
- Audio feedback (beep mode only)

### 4.2 Premium Tier (subscription or one-time unlock — pricing TBD)
- LiDAR auto-calibration with address position equipment analysis
- Lag angle analysis (LRI, release point, shaft lean, casting detection)
- Swing replay with arm/shaft overlay and color-coded lag visualization
- Full speed curve visualization
- Unlimited swing history with session grouping
- Swing comparison (side-by-side)
- Voice mode audio feedback (AVSpeechSynthesizer)
- Export data to CSV
- Detailed statistics and trend tracking
- Priority processing (adaptive sampling optimisations)

### 4.3 Rationale
Core speed measurement is the hook — free and frictionless. The lag analysis and detailed visualization are the premium differentiator that coaches and serious speed trainers will pay for, as this data typically requires $3,000+ HackMotion sensors or $30K+ GEARS systems.

---

## 5. Feature Requirements (v1)

### F1: Camera Capture System

**Priority:** Critical — foundation of all measurement

| Requirement | Specification |
|---|---|
| Frame rate | 240fps @ 1080p (maximum available) |
| Codec | HEVC (H.265) for efficient storage |
| Frame timestamps | Read from `CMSampleBuffer.presentationTimeStamp` — NEVER assume consistent intervals |
| Recording duration | Capture only during detected swings (~1-2 seconds per swing) |
| Storage | Temp directory during capture, moved to persistent storage on save |
| Preview | Live camera feed displayed during idle/ready states |
| Orientation | Landscape, rear camera |

**Critical constraint:** iPhone 240fps is NOT guaranteed. Reports show actual rates of 162-200fps. All speed calculations must use actual measured timestamps per frame.

**Thermal management:**
- Audio-triggered capture means camera runs at 240fps only during actual swings (~1-2 seconds)
- Between swings, camera can drop to 30fps preview or standby
- Display thermal warning if device temperature exceeds threshold
- Estimated active capture time per session: 2-5 minutes total across a 30-minute training session

### F2: Calibration System

**Priority:** Critical — accuracy depends on calibration quality

#### F2.1: Manual Calibration (Free Tier)
- User taps two points on camera preview
- User enters known distance between those points (e.g., club length, stance width)
- App calculates pixels-per-metre scale factor
- User taps to mark impact zone position
- Calibration stored and reusable until camera moves

#### F2.2: LiDAR Auto-Calibration (Premium)
Three-phase calibration:

**Phase 1 — Scene Setup:**
- ARKit session scans scene, identifies ground plane
- Establishes 3D world coordinate system
- Measures camera height and angle relative to ground

**Phase 2 — Address Position Analysis:**
While golfer stands at address (static), the app captures simultaneously:
- `VNDetectHumanBodyPose3DRequest` → 17-joint 3D skeleton (shoulder, elbow, wrist positions in metres)
- Club head detection via CV model → LiDAR provides depth for 3D club head position
- Ball detection (if present) → white sphere CV detection + LiDAR depth

Derived measurements:
| Measurement | Calculation | Use |
|---|---|---|
| Club length | 3D distance: wrist → club head | Constrains Kalman filter tracking radius |
| Lie angle | Shaft vector vs ground plane angle | Self-validation (expect 56-64°) |
| Shaft plane | Plane through spine, hands, club head | Predicted swing plane for tracking |
| Arm length | Shoulder → wrist 3D distance | Max swing arc radius constraint |
| Ball-to-hands geometry | 3D vectors | Impact zone prediction |

**Phase 3 — Lock:**
- Calibration data locked
- Camera must remain stationary (IMU detects movement, warns user)
- All derived measurements passed as constraints to tracking pipeline

#### F2.3: Depth Layout (Face-On Camera at ~2-3m)
The club head/ball are 0.5-1.0m closer to the camera than the golfer's body (club extends forward at lie angle to reach the ground ahead of feet). LiDAR accuracy is ±2-3cm at these distances. All measurements are taken directly — no flat-plane assumptions.

### F3: Club Head Detection & Tracking

**Priority:** Critical — core measurement capability

#### F3.1: Detection Model
- Custom YOLOv8 model trained on golf club head images
- Base dataset: AICaddy (6,000+ images) + Roboflow golf-club-tracking (6,750 images)
- Augmented with motion-blurred club head images at various speeds/lighting
- Exported to Core ML format for iPhone Neural Engine
- Inference target: <6ms per frame on A17 Pro+

#### F3.2: Tracking Pipeline (Post-Capture)
Hybrid approach per swing phase:
1. **YOLO detection** — locate club head in slow frames (backswing, follow-through)
2. **Apple Vision VNTrackObjectRequest** — fast hardware-accelerated tracking between detections
3. **Optical flow (VNGenerateOpticalFlowRequest)** — frame-to-frame motion vectors
4. **Kalman filter** — predict position through blur/occlusion, smooth trajectory
5. **Calibration constraints** — club head within `club_length` of wrist, approximately in `swing_plane`

#### F3.3: 3D Body Pose (Post-Capture)
- `VNDetectHumanBodyPose3DRequest` on every analysed frame
- Provides 3D wrist position at up to 240fps (post-capture, no real-time constraint)
- Wrist position constrains club head search to `club_length` radius sphere
- 17 joints: head, shoulders, elbows, wrists, spine, hips, knees, ankles

### F4: Speed Calculation Pipeline

**Priority:** Critical

#### F4.1: Core Calculation
```
For each consecutive pair of tracked frames (i, i+1):
  displacement_3d = distance(position_3d[i], position_3d[i+1])
  time_delta = timestamp[i+1] - timestamp[i]  // ACTUAL timestamps, not 1/240
  instantaneous_speed = displacement_3d / time_delta
  speed_mph = instantaneous_speed * 2.23694
```

#### F4.2: Speed Curve
- Array of (timestamp, speed_mph, confidence) for every tracked frame
- Kalman-smoothed to reduce noise
- Impact speed = speed at the frame closest to calibrated impact zone position

#### F4.3: Supplementary: Motion Blur Velocity
- Blur streak length encodes velocity: `speed = blur_length × distance / (exposure_time × focal_length)`
- Used to supplement frame-to-frame speed, especially at impact where tracking is hardest
- Weight: frame-to-frame tracking (primary) + blur estimate (supplementary, 0.2-0.3 weight)

#### F4.4: Confidence Scoring
Each speed measurement gets a confidence score (0-1) based on:
- Club head detection confidence from YOLO
- Tracking consistency (sudden jumps = low confidence)
- Blur-based vs tracking-based agreement
- Number of consecutive successfully tracked frames

Display to user: speed + confidence indicator (green/yellow/red)

### F5: Swing Detection

**Priority:** High

#### F5.1: State Machine
```
IDLE → PLAYER_DETECTED → READY → SWING_IN_PROGRESS → SWING_COMPLETE → PROCESSING → RESULT → IDLE
```

#### F5.2: Detection Methods

| Transition | Method | Trigger |
|---|---|---|
| IDLE → PLAYER_DETECTED | Vision body pose detection | Human body detected in frame |
| PLAYER_DETECTED → READY | Stillness detection | Frame difference below threshold for 0.5-1s |
| READY → SWING_IN_PROGRESS | Motion onset + audio whoosh | Frame difference spike AND/OR audio energy rise |
| SWING_IN_PROGRESS → SWING_COMPLETE | Audio + motion | Audio energy decay + motion velocity drop |
| SWING_COMPLETE → PROCESSING | Automatic | Immediate transition |
| PROCESSING → RESULT | Pipeline complete | Analysis finished |
| RESULT → IDLE | Timeout or user tap | Auto-reset after result displayed for 3-5s |

#### F5.3: Audio-Triggered Capture (Phase 3 Enhancement)
- Idle: audio monitoring only (100-300mW) with camera at 30fps preview
- Whoosh detected → switch to 240fps capture
- Impact transient → mark impact frame (±1ms precision vs ±4ms from video alone)
- Energy decay → stop capture
- Power saving: 10-20x reduction vs continuous 240fps

### F6: Audio Feedback System

**Priority:** High — essential for hands-free operation during speed training

#### F6.1: Modes
- **Beep Mode** (Free Tier): distinct tonal beeps, <50ms latency via AVAudioPlayer
- **Voice Mode** (Premium): spoken alerts via AVSpeechSynthesizer, ~100-200ms latency

#### F6.2: Event → Sound Mapping

| Event | Beep Mode | Voice Mode |
|---|---|---|
| Player detected | Single low tone (200Hz, 100ms) | "Player detected" |
| Ready (address identified) | Double ascending beep (400Hz→600Hz) | "Ready" |
| Swing captured | Single bright confirmation (800Hz, 150ms) | "Swing captured" |
| Speed result | Triple ascending + speech | "[X] miles per hour" |
| Error: swing missed | Descending two-tone (600Hz→300Hz) | "Swing not detected, try again" |
| Error: tracking lost | Rapid triple beep (500Hz×3) | "Tracking lost, please retry" |
| Position adjustment needed | Slow repeating pulse (400Hz, 500ms interval) | "Adjust position — stand in frame" |
| Calibration complete | Rising three-note chime (C-E-G) | "Calibration complete" |

#### F6.3: Audio Routing
- `AVAudioSession` category: `.playback`
- Mode: `.voicePrompt`
- Options: `.duckOthers`, `.interruptSpokenAudioAndMixWithOthers`, `.allowBluetooth`
- Automatically routes to AirPods/Bluetooth headphones when connected
- Haptic feedback paired via `UINotificationFeedbackGenerator` + `CHHapticEngine`

### F7: Lag Angle Analysis (Premium)

**Priority:** High — key premium differentiator

#### F7.1: Measurement Approach
- 3D body pose (`VNDetectHumanBodyPose3DRequest`) provides shoulder, elbow, wrist in 3D metres
- Club head position from tracking pipeline
- Lag angle calculated in true 3D: `angle_between(elbow→wrist vector, wrist→club_head vector)`
- Post-capture processing at full 240fps → release point detection to ±4ms / ±1-2° precision

#### F7.2: Metrics Reported

| Metric | Definition | Good Value | Casting Value |
|---|---|---|---|
| **Lag Angle at Top** | Arm-shaft angle at top of backswing | 80-100° | Same (set is similar) |
| **Lag Angle at Arm Parallel** | Angle when lead arm is parallel to ground in downswing | 80-100° (maintained) | 50-70° (released early) |
| **Lag Retention Index (LRI)** | Ratio: lag at arm-parallel / lag at top | 0.5-0.7 | 0.2-0.4 |
| **Release Point** | Degrees of arm rotation before impact where lag begins decreasing rapidly | 30-50° before impact | 90-120° before impact |
| **Shaft Lean at Impact** | Angle between shaft and vertical at impact | +10° to +20° (forward) | 0° or negative (flipping) |

#### F7.3: Casting Detection Logic
- **Casting flagged** when: LRI < 0.4 OR release point > 90° before impact
- **Good lag flagged** when: LRI > 0.5 AND release point < 50° before impact
- **Speed loss estimate:** `(ideal_LRI - actual_LRI) × calibration_factor × base_speed`

#### F7.4: 2D Parallax Limitation
Sportsbox AI research shows 2D front-on measurement can show 31° when actual 3D is 72°. Our use of Apple's 3D pose estimation avoids this for body joints. The club head position still has some depth uncertainty, but combined with the wrist constraint (club_length radius), the 3D angle calculation is far more accurate than pure 2D.

### F8: Swing Replay (Premium)

**Priority:** Medium

#### F8.1: Video Playback
- Slow-motion playback of captured swing video
- Playback speed control (0.25x, 0.5x, 1x)
- Frame-by-frame scrubbing

#### F8.2: Overlays
- **Arm/shaft lines:** Lead arm (shoulder→elbow→wrist) and shaft (wrist→club head) drawn on video
- **Color coding:** Green (good lag) / Yellow (moderate) / Red (casting/early release)
- **Lag angle number:** Displayed in real-time on replay, updating each frame
- **Speed number:** Club head speed displayed per frame
- **Release point marker:** Visual indicator on the swing arc where release begins
- **Impact marker:** Highlight the impact frame

### F9: Swing History & Data

**Priority:** Medium

#### F9.1: Data Storage (SwiftData)
- All data stored locally on device (no cloud in v1)
- **SwingRecord:** id, timestamp, impactSpeed, confidenceScore, clubType, sessionId, videoURL, isBookmarked
- **SpeedProfile:** array of (frameTimestamp, speedMph, confidence) per swing
- **LagMetrics:** lagAngleTop, lagAngleArmParallel, lagRetentionIndex, releasePointDegrees, shaftLeanAtImpact, castingDetected
- **CalibrationData:** calibrationMethod, pixelsPerMetre, impactZonePosition, clubLength, lieAngle, swingPlane, armLength
- **Session:** id, startTime, endTime, swingCount, averageSpeed, maxSpeed, clubType

#### F9.2: History View
- List of swings grouped by session
- Each row: date/time, impact speed, club type, confidence indicator
- Filter by club type, date range
- Free tier: last 50 swings. Premium: unlimited

#### F9.3: Swing Detail View
- Impact speed (large, prominent)
- Speed curve chart (Swift Charts)
- Lag metrics summary (Premium)
- Video replay with overlays (Premium)
- Comparison button (Premium)

#### F9.4: Statistics
- Average speed (overall, per club, per session)
- Max speed (overall, per club)
- Speed trend over time (chart)
- Session summary (swing count, average, max, best lag score)

### F10: Settings

**Priority:** Low (but needed for v1)

| Setting | Options | Default |
|---|---|---|
| Speed units | mph / km/h / m/s | mph |
| Audio feedback mode | Beep / Voice / Off | Beep |
| Auto-capture | On / Off | On |
| Club type default | Driver / 3-Wood / Hybrid / 5i-PW / Wedge | Driver |
| Show confidence score | On / Off | On |
| Save video clips | Always / Never / Ask | Ask |
| Haptic feedback | On / Off | On |

### F11: Onboarding

**Priority:** Medium

#### Flow:
1. **Welcome screen** — app name, one-sentence value prop, "Get Started" button
2. **Camera permission** — explain why needed, request access
3. **Microphone permission** — explain audio detection, request access
4. **LiDAR explanation** — "Your iPhone has a LiDAR sensor that helps us measure distances accurately" (show on Pro models only)
5. **First calibration** — guided walkthrough of manual calibration (or LiDAR if Premium)
6. **First swing** — "Set up your phone on a tripod, stand in frame, and take a swing"
7. **Done** — show results, explain what the numbers mean

---

## 6. Technical Architecture

### 6.1 Technology Stack

| Component | Technology | Notes |
|---|---|---|
| Language | Swift 5.9+ | iOS 17.0+ minimum |
| UI | SwiftUI | UIKit only for camera/AR views |
| Camera | AVFoundation | AVCaptureSession, 240fps config |
| LiDAR/Depth | ARKit / RealityKit | Scene understanding, raycasting |
| CV - Detection | Core ML (custom YOLO) | Club head detection model |
| CV - Tracking | Vision framework | VNTrackObjectRequest, VNGenerateOpticalFlowRequest |
| CV - Body Pose | Vision framework | VNDetectHumanBodyPose3DRequest (17 joints, 3D) |
| Audio Detection | AVAudioEngine | Real-time audio monitoring, onset detection |
| Audio Feedback | AVAudioPlayer + Core Haptics | Beeps, tones, haptic patterns |
| Speech | AVSpeechSynthesizer | Voice alerts and speed readout |
| Data | SwiftData | Local persistence, @Model |
| Charts | Swift Charts | Speed curves, statistics |
| Concurrency | Swift Concurrency | async/await, actors for thread safety |

### 6.2 Processing Pipeline

```
┌─────────────────────────────────────────────────────┐
│                    IDLE STATE                        │
│  Audio monitoring (low power) + 30fps preview        │
└───────────────┬─────────────────────────────────────┘
                │ Player detected + address stillness
                ▼
┌─────────────────────────────────────────────────────┐
│                  READY STATE                         │
│  "Ready" beep/voice. Waiting for swing onset         │
└───────────────┬─────────────────────────────────────┘
                │ Motion onset / audio whoosh detected
                ▼
┌─────────────────────────────────────────────────────┐
│              CAPTURE (240fps)                        │
│  Recording video + audio. Minimal real-time work     │
└───────────────┬─────────────────────────────────────┘
                │ Swing complete (audio decay + motion stop)
                ▼
┌─────────────────────────────────────────────────────┐
│          POST-CAPTURE ANALYSIS                       │
│                                                      │
│  Pass 1: Phase detection (~30fps)                    │
│  ├── Identify: backswing, top, downswing, impact,   │
│  │   follow-through from motion + audio              │
│  │                                                   │
│  Pass 2: Targeted analysis (variable FPS)            │
│  ├── 3D Body Pose (all analysed frames)             │
│  ├── YOLO club head detection                        │
│  ├── Optical flow + Kalman tracking                  │
│  ├── 3D position calculation (calibration)           │
│  ├── Speed curve computation                         │
│  ├── Lag angle calculation (3D)                      │
│  └── Release point + casting detection               │
│                                                      │
│  Adaptive FPS per phase:                             │
│  ├── Backswing:           60fps                      │
│  ├── Top/Transition:      120fps                     │
│  ├── Downswing→Impact:    240fps (every frame)       │
│  ├── Post-impact:         120fps                     │
│  └── Follow-through:      60fps                      │
│                                                      │
│  Total: ~140-160 frames vs ~288 full 240fps          │
│  Processing time: ~3-8 seconds                       │
└───────────────┬─────────────────────────────────────┘
                │ Analysis complete
                ▼
┌─────────────────────────────────────────────────────┐
│                   RESULT                             │
│  Speed readout (voice/beep) + save to history        │
│  Auto-reset to IDLE after 3-5 seconds                │
└─────────────────────────────────────────────────────┘
```

### 6.3 Data Flow

```
Camera (240fps) ──→ Video file (temp)
                         │
Microphone ──→ Audio buffer ──→ Swing detection timing
                         │
LiDAR (calibration) ──→ CalibrationData
                         │
                    ┌────┴────┐
                    │ Post-   │
                    │ Capture │
                    │ Engine  │
                    └────┬────┘
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
         SpeedProfile  LagMetrics  SwingRecord
              │          │          │
              └──────────┼──────────┘
                         ▼
                    SwiftData
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
         HistoryView  DetailView  StatsView
```

---

## 7. Data Models

### 7.1 SwingRecord
```swift
@Model
class SwingRecord {
    var id: UUID
    var timestamp: Date
    var impactSpeedMph: Double?
    var confidenceScore: Double  // 0.0 - 1.0
    var clubType: ClubType
    var sessionId: UUID?
    var videoURL: URL?
    var isBookmarked: Bool
    var speedProfile: SpeedProfile?
    var lagMetrics: LagMetrics?
    var calibrationSnapshot: CalibrationSnapshot?
}
```

### 7.2 SpeedProfile
```swift
struct SpeedProfile: Codable {
    var dataPoints: [SpeedDataPoint]
    var peakSpeedMph: Double
    var peakSpeedTimestamp: TimeInterval
    var impactSpeedMph: Double
    var impactTimestamp: TimeInterval
    var swingDurationSeconds: Double
}

struct SpeedDataPoint: Codable {
    var frameTimestamp: TimeInterval
    var speedMph: Double
    var confidence: Double
    var swingPhase: SwingPhase
}
```

### 7.3 LagMetrics
```swift
struct LagMetrics: Codable {
    var lagAngleAtTop: Double          // degrees
    var lagAngleAtArmParallel: Double  // degrees
    var lagRetentionIndex: Double      // 0.0 - 1.0
    var releasePointDegrees: Double    // degrees before impact
    var shaftLeanAtImpact: Double      // degrees, positive = forward lean
    var castingDetected: Bool
    var estimatedSpeedLossMph: Double?
    var lagCurve: [LagDataPoint]       // lag angle over time
}

struct LagDataPoint: Codable {
    var frameTimestamp: TimeInterval
    var lagAngleDegrees: Double
    var swingPhase: SwingPhase
}
```

### 7.4 CalibrationData
```swift
struct CalibrationSnapshot: Codable {
    var method: CalibrationMethod       // .manual or .lidar
    var pixelsPerMetre: Double
    var impactZonePosition: CGPoint     // in image coordinates
    var cameraToSubjectDistance: Double? // metres (LiDAR only)
    var clubLength: Double?             // metres (LiDAR only)
    var lieAngle: Double?               // degrees (LiDAR only)
    var armLength: Double?              // metres (LiDAR only)
    var swingPlaneNormal: SIMD3<Float>? // 3D vector (LiDAR only)
    var groundPlaneY: Float?            // ground height in world coords
}
```

### 7.5 Enums
```swift
enum SwingPhase: String, Codable {
    case address, backswing, top, earlyDownswing, lateDownswing
    case impact, postImpact, followThrough
}

enum ClubType: String, Codable, CaseIterable {
    case driver, threeWood, hybrid
    case fiveIron, sixIron, sevenIron, eightIron, nineIron
    case pitchingWedge, gapWedge, sandWedge, lobWedge
    case speedStick, other
}

enum CalibrationMethod: String, Codable {
    case manual, lidar
}

enum SwingState {
    case idle, playerDetected, ready, swingInProgress
    case swingComplete, processing, result
}

enum AudioFeedbackMode: String, Codable {
    case beep, voice, off
}

enum SpeedUnit: String, Codable {
    case mph, kmh, ms
}
```

---

## 8. User Flows

### 8.1 First Launch
```
App Launch → Welcome Screen → Camera Permission → Mic Permission
→ [LiDAR detected?] → LiDAR Explanation → Calibration Tutorial
→ First Calibration (manual) → First Swing → Results → Main App
```

### 8.2 Normal Session (Returning User)
```
App Launch → Capture Tab (camera preview, IDLE state)
→ [Calibration valid?]
  → Yes: Skip to Ready detection
  → No: Prompt recalibration
→ Player stands in frame → PLAYER_DETECTED (beep)
→ Player takes address → READY (beep)
→ Player swings → CAPTURE (240fps recording)
→ Swing complete → PROCESSING (progress indicator)
→ Results displayed + voice/beep readout
→ Auto-reset to IDLE (ready for next swing)
→ [Repeat for each swing in session]
→ User taps History tab → Review session
```

### 8.3 Calibration Flow (Manual)
```
Tap "Calibrate" → Camera preview with overlay
→ "Tap first reference point" → User taps
→ "Tap second reference point" → User taps
→ "Enter distance between points" → Number input (metres or feet)
→ "Tap the impact zone" → User taps ball/tee position
→ "Calibration complete" (chime)
→ Return to capture
```

### 8.4 Calibration Flow (LiDAR / Premium)
```
Tap "Auto Calibrate" → AR view activates
→ "Scanning environment..." → Ground plane detected
→ "Take your address position with your club"
→ [Player stands at address]
→ "Measuring..." → 3D pose + club + ball detected
→ "Club length: 112cm, Lie angle: 60°, Ball detected" (confirmation)
→ "Calibration complete" (chime)
→ Return to capture
```

---

## 9. Performance Requirements

| Metric | Target | Notes |
|---|---|---|
| Post-capture processing time | <8 seconds | For full adaptive analysis of ~1.2s swing |
| Processing with adaptive sampling | <4 seconds | Target after optimisation |
| Camera switch to 240fps | <200ms | From audio trigger to first 240fps frame |
| Audio feedback latency (beep) | <50ms | From event to sound |
| Audio feedback latency (voice) | <200ms | From event to speech start |
| Memory usage during capture | <200MB | 240fps buffer management |
| Video file size per swing | ~15-30MB | 1-2 seconds at 240fps 1080p HEVC |
| App launch to ready | <3 seconds | With cached calibration |
| Battery drain per hour (active training) | <15% | Audio-triggered capture, not continuous |

---

## 10. Accuracy Targets

| Version | Speed Accuracy | Lag Angle Accuracy | Approach |
|---|---|---|---|
| v1.0 | ±5-8 mph | ±5-10° | Basic frame-to-frame tracking, manual calibration |
| v1.1 | ±2-4 mph | ±3-5° | + Sub-pixel tracking, motion blur analysis, Kalman smoothing, LiDAR calibration |
| v2.0 | ±1-3 mph | ±2-3° | + Trained ML model, full sensor fusion, optional reflective marker |

**Key relationships:**
- 1 pixel position error ≈ 0.6 mph speed error
- 10° additional retained lag ≈ 5 mph more club head speed (Chu et al., 2010)
- Consistency (low variance between measurements of same swing) matters more than absolute accuracy for training

**Validation methodology:**
- Compare against Garmin R10 (±1 mph club speed, ±3 mph claimed) for speed
- Compare against HackMotion for lag angles (if available)
- Record 100+ swings at various speeds with reference device
- Report: mean absolute error, standard deviation, correlation coefficient

---

## 11. Device Compatibility

| Model | LiDAR | 240fps | 3D Pose | Neural Engine | Support Level |
|---|---|---|---|---|---|
| iPhone 12 Pro/Max | Yes | Yes | Yes (iOS 17+) | 11 TOPS | Full |
| iPhone 13 Pro/Max | Yes | Yes | Yes | 15.8 TOPS | Full |
| iPhone 14 Pro/Max | Yes | Yes | Yes | 17 TOPS | Full |
| iPhone 15 Pro/Max | Yes | Yes | Yes | 35 TOPS | Full (recommended) |
| iPhone 16 Pro/Max | Yes | Yes | Yes | 35 TOPS | Full (recommended) |
| iPhone 17 Pro/Max | Yes | Yes | Yes | TBD | Full (recommended) |
| Non-Pro iPhones | No | Yes* | Limited | Varies | Free tier only (manual calibration, no 3D pose lag analysis) |

*240fps available on iPhone 8+ but without LiDAR for calibration

**Graceful degradation:**
- No LiDAR → manual calibration only (free tier)
- No 3D pose → 2D lag angle estimation (relative only, clearly labelled)
- Older chip → longer processing time (show progress bar)

---

## 12. Privacy & Data

- **All data stored locally** on device. No cloud upload in v1
- **No account required** to use free tier
- **Camera access:** Used only for swing capture. No photos taken. Video stored locally, user controls deletion
- **Microphone access:** Used for swing detection and audio analysis. No audio recording saved
- **LiDAR access:** Used for calibration measurement only. No environment mapping saved
- **Analytics:** Anonymous usage statistics only (swing count, app sessions) if user opts in. No swing data or video leaves the device
- **Future (with consent):** Anonymised swing metrics could be collected to train the learned inference model. Requires explicit opt-in. No video or personally identifiable data

---

## 13. Accessibility

- **VoiceOver:** All UI elements labelled. Speed results announced automatically
- **Dynamic Type:** All text scales with system font size settings
- **Audio feedback:** The core feedback loop (beep/voice) is inherently accessible to visually impaired users — the app works without looking at the screen
- **High contrast:** Support system high contrast mode
- **Reduce Motion:** Respect system reduce motion preference for animations
- **Colour coding:** Lag visualisation uses colour + shape/pattern (not colour alone) for colour-blind users

---

## 14. Success Metrics

| Metric | Target | Measurement |
|---|---|---|
| Speed accuracy (v1.0) | ±5 mph or better vs Garmin R10 | 100-swing validation test |
| Speed consistency | <3 mph standard deviation on repeated same-speed swings | Controlled test with metronome swing |
| Processing time | <8 seconds per swing | Measured on iPhone 14 Pro |
| Swing detection rate | >90% of real swings detected | Field testing with 10+ golfers |
| False detection rate | <5% false positives (waggles, non-swings) | Field testing |
| Calibration success rate | >95% LiDAR calibration completes without error | Field testing |
| Session battery drain | <15% per hour of active training | 30-minute session test |
| User retention (7-day) | >40% | Analytics after launch |
| Premium conversion | >5% of active users | Analytics after launch |

---

## 15. Out of Scope (v1)

Explicitly excluded from v1:
- Ball tracking / ball flight analysis
- Club face angle measurement
- Angle of attack
- Smash factor / ball speed
- Launch angle / spin rate
- Carry distance prediction
- Cloud sync / multi-device
- Social features / leaderboards
- Apple Watch integration
- iPad support
- Android version
- Video sharing / social export
- AI coaching suggestions
- Dual camera capture
- Reflective marker detection mode

---

## 16. Future Roadmap

### v1.1 — Accuracy & Performance
- Sub-pixel tracking + motion blur velocity estimation
- Sensor fusion (camera + LiDAR + audio + IMU)
- Optimised adaptive frame sampling
- Improved YOLO model with expanded training data

### v2.0 — Intelligence
- Learned inference model ("Coach's Eye") for near-instant results
- Audio-only speed estimation exploration
- Non-LiDAR iPhone support via learned physics model
- Advanced statistics and AI-generated insights
- Cloud backup (optional, encrypted)

### v2.x — Platform Expansion
- iPad support (larger screen for coaching)
- Apple Watch companion (wrist speed supplement)
- Side-on camera mode
- Dual camera capture (wide + telephoto)
- Social features and sharing
- Export to CSV/PDF reports

---

## 17. Dependencies & Risks

| Risk | Impact | Mitigation |
|---|---|---|
| iPhone 240fps unreliability (162-200fps actual) | Speed calculation errors | Use actual frame timestamps, never assume intervals |
| YOLO model insufficient for blurred club heads | Tracking fails at high speeds | Motion blur as signal + Kalman prediction through failures |
| LiDAR accuracy at 2-3m (±2-3cm) | Calibration error compounds into speed error | Multiple calibration points, self-validation via lie angle check |
| Thermal throttling during sessions | Camera drops from 240fps | Audio-triggered burst capture, not continuous. Warn user |
| ShotVision improves significantly | Competitive threat | Our LiDAR + 3D pose + audio approach is architecturally superior |
| Apple deprecates VNDetectHumanBodyPose3DRequest | 3D pose unavailable | Fallback to 2D pose with relative metrics |
| App Store rejection (camera/mic permissions) | Launch delay | Clear privacy descriptions, minimal data collection |

---

*This PRD is the authoritative specification for v1 development. All feature decisions, technical approaches, and scope boundaries are defined here. See RESEARCH.md for supporting evidence and TASKS.md for implementation breakdown.*
