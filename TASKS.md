# TASKS.md — Golf Swing Speed App Development Plan

> **Last Updated:** March 2026
> **Status Key:** `[ ]` Not started · `[~]` In progress · `[x]` Complete

---

## Phase 0 — Research & Planning
- [x] Create project repository and README
- [x] Write RESEARCH_PLAN.md
- [x] Conduct comprehensive competitive & technology research
- [x] Complete RESEARCH.md with findings
- [x] Create CLAUDE.md project guide
- [x] Create TASKS.md development plan

---

## Phase 1 — Prototype (Basic Capture & Manual Measurement)

### 1.1 Project Setup
- [ ] Create Xcode project (SwiftUI, iOS 17.0+)
- [ ] Set up project structure (Features/, Models/, ML/, Utilities/)
- [ ] Configure Info.plist for camera, microphone, and LiDAR permissions
- [ ] Set up SwiftData schema for swing records
- [ ] Add basic navigation (tab bar or sidebar)

### 1.2 High-FPS Camera Capture
- [ ] Implement AVCaptureSession for 240fps @ 1080p
- [ ] Build camera preview view (SwiftUI wrapper for AVCaptureVideoPreviewLayer)
- [ ] Implement CMSampleBuffer capture and storage
- [ ] Add recording start/stop controls
- [ ] Test frame timing accuracy (verify consistent 240fps delivery)
- [ ] Implement video clip saving to disk
- [ ] Handle camera permission request flow

### 1.3 Manual Calibration (Tap-to-Set)
- [ ] Build calibration UI — user taps two reference points on screen
- [ ] User enters known distance between points (e.g., ball to feet)
- [ ] Calculate pixels-per-metre scale factor from input
- [ ] User taps to set impact zone position
- [ ] Store calibration data with session
- [ ] Allow recalibration without restarting

### 1.4 Basic Motion Detection
- [ ] Implement frame differencing to detect motion onset
- [ ] Set motion threshold for swing start detection
- [ ] Detect motion cessation for swing end
- [ ] Visualize motion regions on preview (debug overlay)
- [ ] Test with real golf swings to tune thresholds

### 1.5 Manual Frame Analysis (Prototype Speed Calc)
- [ ] Build frame-by-frame viewer for captured video
- [ ] Allow user to tap club head position in each frame
- [ ] Calculate pixel displacement between marked frames
- [ ] Convert to real-world speed using calibration
- [ ] Display speed result
- [ ] **Milestone:** First speed measurement from manually marked frames

---

## Phase 2 — Core Feature Build (Automated Tracking)

### 2.1 Scene & Equipment Calibration
#### Phase 1: Scene Setup
- [ ] Implement ARKit session for scene scanning
- [ ] Detect ground plane via ARKit plane detection
- [ ] Implement raycasting — user taps to set calibration points in 3D space
- [ ] Calculate real-world distance between calibration points using ARKit
- [ ] Derive pixels-per-metre scale factor from LiDAR measurements
- [ ] Build calibration UI with visual feedback (AR overlay showing detected surfaces)
- [ ] Handle LiDAR unavailability gracefully (fallback to manual calibration)
- [ ] Test accuracy at various distances (1.5m, 2m, 2.5m, 3m)

#### Phase 2: Address Position Analysis (player stands at address with club)
- [ ] Implement `VNDetectHumanBodyPose3DRequest` for 3D body skeleton (17 joints in metres)
- [ ] Extract lead arm landmarks: shoulder, elbow, wrist in 3D world coordinates
- [ ] Detect club head at address via CV model (static = no blur, easier detection)
- [ ] Get club head 3D position from LiDAR depth at detected location
- [ ] Detect ball position via CV (white sphere detection) + LiDAR depth confirmation
- [ ] Calculate **club length**: 3D distance from wrist to club head
- [ ] Calculate **lie angle**: angle between shaft vector (wrist→club head) and ground plane
- [ ] Validate lie angle against expected range (56–64°) — flag if wildly off as detection error
- [ ] Calculate **shaft plane at address**: plane through spine, hands, club head → predicted swing plane
- [ ] Calculate **arm length**: shoulder→wrist 3D distance (constrains max swing arc radius)
- [ ] Calculate **ball-to-hands geometry**: 3D vectors defining expected impact zone
- [ ] Store all derived measurements as calibration constraints for tracking pipeline
- [ ] Display calibration results to user: club length, lie angle, ball position confirmed
- [ ] Allow user to select club type (driver, iron, wedge) for context

#### Phase 3: Lock & Capture Mode
- [ ] Lock calibration data when user confirms
- [ ] Pass constraints to Kalman filter: club_length radius, swing_plane, max_speed bounds
- [ ] Camera must remain stationary — detect movement and warn user
- [ ] **Milestone:** Full calibration pipeline — scene + body + equipment measured and locked

### 2.2 Club Head Detection (ML Model)
- [ ] Obtain/prepare training data (AICaddy dataset + additional collection)
- [ ] Include motion-blurred club head images in training set
- [ ] Train YOLOv8 or similar model for club head detection
- [ ] Export to Core ML format (.mlmodel)
- [ ] Integrate Core ML model into app
- [ ] Benchmark inference speed on target devices (iPhone 14 Pro, 15 Pro, 16 Pro)
- [ ] Test detection accuracy across lighting conditions
- [ ] Implement confidence thresholding — skip low-confidence detections

### 2.3 Club Head Tracking Pipeline
- [ ] Implement YOLO detection for initial club head location (slow frames)
- [ ] Implement optical flow (Lucas-Kanade) for frame-to-frame tracking
- [ ] Implement Kalman filter for motion prediction and smoothing
- [ ] Build hybrid pipeline: YOLO detection → optical flow tracking → Kalman prediction
- [ ] Handle detection failures (club lost due to blur/occlusion) with Kalman prediction
- [ ] Re-acquire club head after occlusion using YOLO
- [ ] Output: array of (x, y, timestamp, confidence) per frame

### 2.4 Speed Calculation Pipeline
- [ ] Convert tracked positions to real-world coordinates using calibration
- [ ] Calculate frame-to-frame speed at each tracked point
- [ ] Apply Kalman smoothing to speed curve
- [ ] Identify impact position from calibrated zone
- [ ] Extract speed at impact frame(s)
- [ ] Handle perspective correction — adjust scale factor based on estimated depth
- [ ] Build speed curve data structure (SpeedProfile model)
- [ ] **Milestone:** First automated club head speed measurement

### 2.5 Auto Swing Detection (Motion-Based)
- [ ] Implement swing state machine (IDLE → SETUP → READY → SWING → COMPLETE → RESULT)
- [ ] Use background subtraction (MOG2) for motion detection
- [ ] Implement stillness detection for READY state (low frame difference for N frames)
- [ ] Implement motion onset detection for SWING state
- [ ] Implement swing completion detection (velocity drop + follow-through)
- [ ] Distinguish real swings from practice waggles (duration + speed thresholds)
- [ ] Auto-start capture on swing detection
- [ ] Auto-stop capture on swing completion

### 2.6 Audio Feedback System (Beeps + Voice)
- [ ] Design audio feedback sound set (distinct tones for each state)
- [ ] Create/source short beep tones: ready beep, success beep, error beep, warning pulse
- [ ] Implement `AVAudioPlayer` for low-latency beep playback (<50ms)
- [ ] Implement `UINotificationFeedbackGenerator` haptic feedback paired with beeps
- [ ] Implement `AVSpeechSynthesizer` for voice mode alerts ("Ready", "Swing captured — X mph")
- [ ] Build feedback manager that dispatches correct sound for each state transition:
  - Player detected → single low tone / "Player detected"
  - Ready (start pose identified) → double ascending beep / "Ready"
  - Swing captured → confirmation tone / "Swing captured"
  - Speed result → triple ascending beep + speech / "[X] miles per hour"
  - Error: swing not detected → descending error tone / "Swing not detected, try again"
  - Error: tracking lost → rapid triple warning beep / "Tracking lost, please retry"
  - Struggling to detect position → slow repeating pulse / "Adjust position"
  - Calibration complete → rising chime / "Calibration complete"
- [ ] Add user setting: Beep Mode vs Voice Mode toggle
- [ ] Configure `AVAudioSession` for AirPods/Bluetooth headphone routing (`.playback` category, `.allowBluetooth`)
- [ ] Set audio session to duck other audio (`.duckOthers` + `.interruptSpokenAudioAndMixWithOthers`)
- [ ] Allow user to configure speed readout units (mph / km/h / m/s)
- [ ] Implement `Core Haptics` (`CHHapticEngine`) for custom haptic patterns synced with audio
- [ ] Test audio feedback latency with AirPods vs speaker
- [ ] **Milestone:** Full audio feedback loop working — golfer hears "Ready" → swings → hears speed

---

## Phase 3 — Accuracy & Audio Enhancement

### 3.1 Motion Blur Analysis
- [ ] Research and implement blur streak length estimation
- [ ] Calculate speed from blur length (speed = blur_length / exposure_time)
- [ ] Use blur direction to validate tracking direction
- [ ] Combine blur-based speed with frame-to-frame speed for weighted estimate
- [ ] Test accuracy improvement vs frame-to-frame only

### 3.2 Audio Swing Detection
- [ ] Implement AVAudioEngine for real-time audio monitoring
- [ ] Build audio onset detector (energy thresholding + spectral analysis)
- [ ] Characterize golf swing whoosh sound signature (frequency range, amplitude pattern)
- [ ] Detect swing onset from audio — trigger 240fps capture
- [ ] Detect impact sound (sharp transient) for precise impact timing
- [ ] Detect swing completion — audio returns to ambient baseline
- [ ] Implement noise filtering to distinguish wind from whoosh
- [ ] Test in various environments (range, backyard, indoor)
- [ ] Measure power savings vs continuous video monitoring
- [ ] **Milestone:** Audio-triggered capture working reliably

### 3.3 Sensor Fusion
- [ ] Combine camera tracking + audio timing + LiDAR calibration
- [ ] Use IMU (accelerometer) to detect/compensate for camera movement
- [ ] Weight speed estimates by confidence (high confidence tracking > blur estimate)
- [ ] Implement confidence scoring for final speed measurement
- [ ] A/B test accuracy: camera-only vs fused approach

### 3.4 Lag Angle / Wrist Release Detection
- [ ] Implement MediaPipe Pose (or Apple Vision `VNDetectHumanBodyPoseRequest`) for body landmark tracking
- [ ] Extract lead arm landmarks: shoulder, elbow, wrist positions per frame
- [ ] Combine wrist landmark with club head position from tracking pipeline to derive shaft vector
- [ ] Calculate lag angle per frame: `angle_between(elbow→wrist vector, wrist→club_head vector)`
- [ ] Build lag angle curve across entire swing (angle over time/arc position)
- [ ] Identify key measurement points:
  - Lag angle at top of backswing
  - Lag angle at lead arm parallel (downswing)
  - Lag angle at shaft horizontal
  - Shaft lean at impact (hands ahead or behind club head)
- [ ] Calculate **Lag Retention Index (LRI):** ratio of lag at lead-arm-parallel to lag at top
- [ ] Calculate **Release Point:** degrees of arm rotation before impact where lag begins decreasing rapidly
- [ ] Detect casting / early release: flag when LRI < 0.4 or release point > 90° before impact
- [ ] Detect maintained lag: flag when LRI > 0.5 and release point < 50° before impact
- [ ] Estimate speed loss from early release (compare actual speed to potential based on lag curve)
- [ ] Build swing replay overlay:
  - Draw lead arm and club shaft lines on video frames
  - Color-code by lag quality (green = good retention, yellow = moderate, red = casting)
  - Show lag angle number in real-time on replay
  - Mark release point on the swing arc
- [ ] Display lag metrics in swing detail view:
  - Lag Angle at key positions (top, arm parallel, impact)
  - Lag Retention Index (0–1 scale)
  - Release Point (degrees before impact)
  - Shaft Lean at Impact (degrees, positive = forward lean)
  - Casting/Lag verdict with explanation
- [ ] Add comparative view: show lag metrics side-by-side between two swings
- [ ] Store lag data in SwiftData alongside speed data per swing
- [ ] **Milestone:** Swing replay shows arm/shaft overlay with lag angle and casting detection

### 3.5 Accuracy Validation
- [ ] Test against known-speed reference device (borrow/rent Garmin R10 or similar)
- [ ] Record 100+ swings at various speeds
- [ ] Calculate mean absolute error, standard deviation
- [ ] Identify systematic biases and correct
- [ ] Establish accuracy claims with evidence
- [ ] Document accuracy vs speed range (slow swings more accurate than fast)

---

## Phase 4 — Data, History & UI Polish

### 4.1 Swing History
- [ ] Implement SwiftData persistence for swing records
- [ ] Store: timestamp, impact speed, full speed curve, calibration data, video clip (optional)
- [ ] Build history list view (date, speed, club type)
- [ ] Build swing detail view (speed curve chart, video playback)
- [ ] Implement session grouping (swings from same practice session)
- [ ] Add basic statistics (average speed, max speed, trend over time)

### 4.2 Speed Curve Visualization
- [ ] Build speed-over-time chart (Swift Charts)
- [ ] Mark impact point on chart
- [ ] Show speed at backswing, transition, downswing, impact, follow-through
- [ ] Overlay speed data on video playback (optional)

### 4.3 Settings
- [ ] Speed units preference (mph / km/h / m/s)
- [ ] Voice readout toggle and voice selection
- [ ] Auto-capture vs manual trigger mode
- [ ] Camera resolution preference (240fps vs 120fps fallback)
- [ ] Data retention settings
- [ ] Club type selection (driver, iron, wedge — for organization)

### 4.4 UI Polish
- [ ] Design app icon
- [ ] Build onboarding flow (camera permission, LiDAR explanation, first calibration)
- [ ] Add haptic feedback for state transitions
- [ ] Build loading/processing state UI
- [ ] Handle edge cases (no LiDAR, low light warning, thermal warning)
- [ ] Accessibility support (VoiceOver, Dynamic Type)
- [ ] Dark mode support

---

## Phase 5 — Testing & Release

### 5.1 Testing
- [ ] Unit tests for speed calculation math
- [ ] Unit tests for Kalman filter implementation
- [ ] Integration tests for capture → tracking → speed pipeline
- [ ] UI tests for critical user flows
- [ ] Performance testing — memory usage during 240fps capture
- [ ] Thermal testing — sustained capture duration before throttle
- [ ] Device testing across iPhone models (12 Pro through 17 Pro)

### 5.2 Beta Testing
- [ ] TestFlight internal testing
- [ ] Recruit 10-20 beta testers (speed training golfers, golf coaches)
- [ ] Collect accuracy feedback against reference devices
- [ ] Collect usability feedback
- [ ] Iterate based on feedback

### 5.3 App Store Release
- [ ] App Store screenshots and preview video
- [ ] App Store description and keywords
- [ ] Privacy policy
- [ ] App Review submission
- [ ] Launch

---

## Future / Backlog (Post v1)

- [ ] Slow-motion swing replay with speed overlay
- [ ] Speed comparison between swings / sessions
- [ ] Club-by-club speed profiles
- [ ] Training mode with target speeds and audio alerts
- [ ] Export data to CSV / share
- [ ] Side-on camera mode (second angle)
- [ ] Dual camera capture (wide + telephoto simultaneously)
- [ ] Reflective marker detection mode for enhanced accuracy
- [ ] Frame interpolation (RIFE) for synthetic FPS increase
- [ ] Apple Watch integration for wrist speed supplement
- [ ] Social features / leaderboards
- [ ] iPad support

---

*This task list will be updated as development progresses. Each task should be broken down further when work begins on that phase.*
