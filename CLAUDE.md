# CLAUDE.md — Golf Swing Speed App

## Project Overview

Golf Swing Speed App is an iPhone app that measures golf club head speed using the device's built-in LiDAR scanner and 240fps camera — with no external hardware required. It targets speed training golfers who want instant, free swing speed feedback.

**Status:** Pre-development — Research complete, entering prototype phase
**Platform:** iOS (iPhone 12 Pro and later — LiDAR required)
**Language:** Swift
**UI Framework:** SwiftUI

## Architecture

### Stack
| Component | Technology |
|---|---|
| Language | Swift |
| UI | SwiftUI |
| Camera | AVFoundation (240fps capture) |
| LiDAR/Depth | ARKit / RealityKit |
| Computer Vision | Vision framework, Core ML (custom YOLO model) |
| ML Training | Create ML / PyTorch → Core ML export |
| Audio Detection | AVAudioEngine / Accelerate framework |
| Audio Feedback | AVAudioPlayer (beeps), Core Haptics (CHHapticEngine) |
| Speech Output | AVSpeechSynthesizer (voice alerts + speed readout) |
| Body Pose | Vision (VNDetectHumanBodyPoseRequest) or MediaPipe Pose |
| Data Storage | SwiftData |

### Core Pipeline
1. **Audio monitoring** (idle) → detect swing onset via whoosh sound
2. **240fps capture** triggered by audio → record full swing arc (minimal real-time processing)
3. **Post-capture analysis** on every frame (~240-360 frames, ~4-15 seconds processing):
   - 3D body pose (`VNDetectHumanBodyPose3DRequest`) on all frames at full 240fps
   - Club head detection (YOLO) + tracking (optical flow + Kalman) on all frames
   - Speed calculation using LiDAR-calibrated 3D positions
   - Lag angle calculation in true 3D at full temporal resolution
   - Release point detection to ±4ms / ±1-2° precision
4. **Impact speed extraction** from calibrated impact zone position
5. **Audio feedback** of speed + lag analysis results

### Key Directories (planned)
```
GolfSwingSpeedApp/
├── App/                    — App entry point, navigation
├── Features/
│   ├── Calibration/        — LiDAR + manual setup
│   ├── Capture/            — AVFoundation 240fps camera
│   ├── Tracking/           — CV / club head detection / ML model
│   ├── SpeedCalc/          — Speed calculation pipeline
│   ├── AudioDetection/     — Swing detection via microphone
│   ├── History/            — Swing data storage & display
│   └── Settings/
├── Models/                 — Data models, SwiftData schemas
├── ML/                     — Core ML models, training scripts
└── Utilities/              — Shared helpers
```

## Coding Conventions

- Swift 5.9+, iOS 17.0+ minimum deployment target
- SwiftUI for all UI, no UIKit unless required for camera/AR views
- Use async/await for all asynchronous operations
- Use Swift concurrency (actors) for thread-safe sensor data
- Prefer value types (structs) over classes where possible
- All measurements in SI units (metres, seconds) internally; convert to mph/kmh for display only
- Camera pipeline uses CMSampleBuffer → CVPixelBuffer → CIImage flow
- Core ML models stored in ML/ directory with .mlmodel extension
- Use #Preview macros for SwiftUI previews

## Key Technical Decisions

- **240fps at 1080p** is the capture target (max available on iPhone)
- **Hybrid tracking:** YOLO detection for slow frames + optical flow + Kalman filter for fast frames
- **Audio-triggered capture** to reduce battery/thermal impact vs continuous recording
- **LiDAR for calibration only** (60Hz too slow for 240fps tracking) — establishes pixel-to-metre scale
- **Address position calibration** — while golfer is static at address, combine Apple 3D body pose + LiDAR + CV to measure: club length, lie angle, shaft plane, arm length, ball position. These become Kalman filter constraints during tracking (club head must be within club_length of wrist, approximately in swing plane)
- **Post-capture processing at full 240fps** — all heavy analysis (3D pose, YOLO detection, speed calc, lag angle) runs on every frame AFTER swing completes. No real-time processing constraints. ~4-15 seconds total for full analysis. This enables 3D body pose on all 240 frames where real-time would only manage ~60fps
- **v1 scope: club head speed + lag angle analysis** — no ball tracking, face angle, spin, or other launch monitor metrics
- **Lag angle detection** via MediaPipe/Vision body pose + club shaft tracking. Reports: Lag Retention Index, Release Point, Shaft Lean at Impact, casting detection
- **Audio feedback system** with two modes: Beep Mode (low-latency tones) and Voice Mode (AVSpeechSynthesizer). Routes to AirPods/Bluetooth automatically

## Research References

- `RESEARCH.md` — Full competitive and technology research
- `RESEARCH_PLAN.md` — Research methodology and scope
- `README.md` — Project overview and goals

## Accuracy Targets

| Version | Target Accuracy | Approach |
|---|---|---|
| v1.0 | ±5-8 mph | Basic frame-to-frame tracking |
| v1.1 | ±2-4 mph | + Sub-pixel tracking + motion blur velocity estimation + Kalman smoothing |
| v2.0 | ±1-3 mph | + Trained ML model + sensor fusion + optional reflective marker |

**Key:** 1-pixel position error ≈ 0.6 mph speed error. Consistency matters more than absolute accuracy for training use.

**Do NOT use:** AI frame interpolation (RIFE/FILM) for measurement — no new temporal information. LiDAR for direct tracking — 60fps/256×192 insufficient.

## Critical: Frame Timing

**iPhone 240fps is NOT guaranteed.** Reports show iPhone 14 Pro delivers 162-200fps actual when set to 240fps. Speed calculations MUST use actual frame timestamps from `CMSampleBuffer.presentationTimeStamp`, never assume consistent 1/240s intervals.

## Known Hard Problems

1. Motion blur at 100+ mph makes club head detection unreliable at impact
2. Club head is small, fast, and often low-contrast against background
3. Occlusion when club passes behind golfer's body
4. Perspective distortion from front-on camera angle
5. Thermal throttling during sustained 240fps capture
6. Outdoor wind noise interfering with audio swing detection

## Version Control & Git Workflow

### Commit & Push Policy
- **Always commit and push to GitHub** after: research completion, major document updates, or feature updates — keep the remote repo in sync at all times
- Commit messages should be descriptive and reference the version number where applicable

### Versioning — V0.00.00 Bump Workflow
The project uses a three-tier semantic version format: **V`MAJOR`.`MINOR`.`PATCH`**

| Bump | Format | When | Approval Required? |
|---|---|---|---|
| Patch | `0.00.XX` | Minor code changes, bug fixes, small tweaks | No — apply freely |
| Minor | `0.XX.00` | Larger feature updates, significant refactors, new capabilities | **Yes — requires user approval before bumping** |
| Major | `X.00.00` | Significant large builds, major milestones, breaking changes | **Yes — requires user approval before bumping** |

- Current version: **V0.00.00** (pre-development)
- Version is tracked in the project and updated with each relevant commit
- Patch resets to 00 on minor bump; patch and minor reset to 00 on major bump
- When in doubt about bump level, ask before committing

## Build & Run

*Not yet applicable — no Xcode project created yet. See TASKS.md for development plan.*
