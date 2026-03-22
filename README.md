# Golf Swing Speed App — iPhone App

> **Status:** Pre-development — Research & Planning Phase
> **Working Title:** Golf Swing Speed App (name TBD)
> **Platform:** iOS (iPhone)
> **Repo:** [YorkeDesign/Golf-Swing-Speed-App](https://github.com/YorkeDesign/Golf-Swing-Speed-App)

---

## Overview

**Golf Swing Speed App** is an iPhone app that uses the device's built-in LiDAR scanner and high-FPS camera to measure golf club head speed throughout the full arc of a swing — with no external hardware required.

Existing solutions either cost thousands of dollars (professional launch monitors) or lack real-time speed measurement (swing analysis video apps). This app aims to fill the gap: accurate, instant club head speed measurement from a single iPhone, free from proprietary hardware.

---

## The Problem

Golfers wanting to track club head speed for speed training have limited options:

| Option | Cost | Accuracy | Portability |
|---|---|---|---|
| Professional launch monitor (Trackman, Foresight) | $10,000–$25,000+ | Excellent | Low |
| Consumer launch monitor (SkyTrak, Garmin R10) | $500–$2,500 | Good | Medium |
| Swing analysis apps (Hudl, V1 Golf) | Free–$10/mo | No speed data | High |
| This app | Free (on existing iPhone) | TBD | Excellent |

For speed training specifically — where a golfer is swinging repeatedly without hitting a ball, focusing purely on generating and measuring speed — there is no lightweight, accurate, zero-cost option. That's the gap this app targets.

---

## Core Concept

The app is positioned **front-on to the player**, capturing the full arc of the golf swing — from address through backswing, downswing, impact zone, and follow-through.

### How It Works

1. **Setup / Calibration**
   - iPhone's LiDAR scanner scans the scene and identifies:
     - The golf ball position (or tee/impact zone)
     - The player's feet (to define stance width and baseline)
   - This establishes a real-world coordinate system, mapping pixels to physical distances
   - Alternative: user taps on screen to manually define the impact zone if LiDAR setup is not preferred

2. **Swing Detection**
   - The app monitors the live camera feed
   - When the player takes their address position and becomes still, the app enters "ready" state
   - Capture begins automatically when swing motion is detected

3. **High-FPS Capture**
   - Camera runs at maximum available FPS (240fps on supported iPhones)
   - Full swing arc is captured — backswing, downswing, impact, follow-through

4. **Club Head Tracking**
   - Computer vision algorithms track the club head through each frame
   - Positional data (x, y coordinates) is recorded per frame

5. **Speed Calculation**
   - Using the calibrated real-world scale, pixel displacement between frames is converted to metres
   - Speed at each frame = distance / time between frames
   - A speed curve is built across the entire swing arc

6. **Impact Detection & Readout**
   - The app identifies the impact position (where the ball was or would be) from the calibrated zone
   - Club head speed at that specific position is extracted
   - Speed is read aloud via text-to-speech immediately after the swing

7. **Data Storage**
   - Each swing is saved with:
     - Timestamp
     - Full speed curve (speed at every tracked frame)
     - Impact speed (primary metric)
     - Swing duration
     - Raw video clip (optional)

---

## Goals

### v1 — Core Feature Set

- [x] LiDAR-based calibration setup
- [x] Manual tap-to-set zone as alternative
- [x] Automatic swing start/end detection
- [x] High-FPS camera capture (front-on)
- [x] Club head tracking throughout swing arc
- [x] Speed curve calculation
- [x] Impact speed identification
- [x] Voice readout of impact speed
- [x] Audio feedback system (beep + voice modes for system status, AirPods support)
- [x] Swing history and data storage
- [x] Lag angle / wrist release analysis (detect casting vs maintained lag)
- [x] Swing replay with arm/shaft overlay and lag angle visualization

### v1 — Explicitly Out of Scope

The following are deliberately excluded from v1 to keep focus on club head speed and swing efficiency:

- ❌ Ball tracking / ball flight analysis
- ❌ Club face angle
- ❌ Angle of attack
- ❌ Smash factor
- ❌ Launch angle
- ❌ Spin rate
- ❌ Ball speed
- ❌ Carry distance prediction

### Future Versions (Potential)

- Slow-motion swing replay with speed overlay
- Speed comparison between swings / sessions
- Club-by-club speed profiles
- Training mode with target speeds
- Export data to CSV / share
- Side-on camera mode
- Additional launch monitor metrics (if viable from camera alone)

---

## Technical Approach

### Stack

| Component | Technology |
|---|---|
| Language | Swift |
| UI Framework | SwiftUI |
| Camera Capture | AVFoundation |
| LiDAR / Depth | ARKit / RealityKit |
| Computer Vision | Vision framework, Core ML |
| Speech Output | AVSpeechSynthesizer |
| Data Storage | SwiftData / Core Data |

### Key Technical Challenges

1. **Motion Blur** — A golf club head at 100mph moves ~44m/s. At 240fps, it travels ~18cm per frame. At full resolution this is manageable, but motion blur remains a real challenge for accurate centroid tracking.

2. **Perspective & Scale** — Front-on view introduces perspective distortion. The club head at the far end of the follow-through is further from the camera than at address. LiDAR calibration helps establish a depth model to compensate.

3. **Club Head Detection** — The club head is small, fast, and often similar in colour/tone to the background (grass, sky). Reliable detection requires robust feature extraction or a trained model.

4. **Impact Zone** — The moment of impact is the highest speed point, but also the hardest to track due to maximum motion blur and potential occlusion.

5. **Automatic Swing Detection** — Distinguishing a practice waggle from a real swing, and detecting swing completion vs an interrupted follow-through, requires careful motion analysis.

6. **iPhone Thermal Management** — Sustained 240fps capture generates significant heat. The app must handle thermal throttling gracefully.

### LiDAR Calibration Detail

iPhone models with LiDAR (iPhone 12 Pro and later):
- Time-of-Flight (ToF) sensor with ~15cm depth accuracy at 1–5 metre range
- ARKit provides a 3D mesh of the scene
- The app uses ARKit raycasting to identify the ground plane and ball/foot positions
- This establishes a pixels-per-metre scale factor, accounting for camera height and angle
- The scale factor updates if the camera moves; a lock is applied during active capture

### Speed Calculation

```
real_world_distance = pixel_distance × (known_real_distance / known_pixel_distance)
time_between_frames = 1 / FPS
speed_ms = real_world_distance / time_between_frames
speed_mph = speed_ms × 2.23694
```

Where `known_real_distance` is derived from the LiDAR calibration (e.g. the measured distance between the ball position markers set during calibration).

### Swing Detection State Machine

```
IDLE → SETUP_DETECTED → READY → SWING_IN_PROGRESS → SWING_COMPLETE → PROCESSING → RESULT
         ↑ player at       ↑ stillness       ↑ motion           ↑ motion stops
           address          detected           detected             + follow-through
```

---

## Project Structure

```
Golf-Swing-Speed-App/
├── README.md                    ← This file
├── RESEARCH_PLAN.md             ← Research brief and methodology
├── RESEARCH.md                  ← Completed research (populated separately)
├── GolfSwingSpeed/              ← Xcode project (to be created)
│   ├── App/
│   ├── Features/
│   │   ├── Calibration/         ← LiDAR + manual setup
│   │   ├── Capture/             ← AVFoundation high-FPS camera
│   │   ├── Tracking/            ← Computer vision / club head detection
│   │   ├── SpeedCalc/           ← Speed calculation pipeline
│   │   ├── History/             ← Swing data storage & display
│   │   └── Settings/
│   ├── Models/
│   └── Utilities/
├── docs/                        ← Additional documentation
└── research/                    ← Raw research notes and sources
```

---

## Research

Before any code is written, comprehensive research is being conducted on:

- All existing commercial products that measure golf club/swing speed
- Academic computer vision research on sports implement tracking
- Open source tools and datasets
- iPhone LiDAR and high-FPS camera capabilities
- Mathematical approaches to speed calculation from video

See **[RESEARCH_PLAN.md](./RESEARCH_PLAN.md)** for the full research brief and methodology.

See **[RESEARCH.md](./RESEARCH.md)** for the completed research (in progress).

---

## Target Users

- Golfers doing speed training (e.g. SuperSpeed Golf protocol, Overspeed training)
- Golf coaches wanting a lightweight tool for students
- Recreational golfers curious about their club speed without buying a launch monitor
- Golf fitness trainers tracking progress

---

## Requirements

- iPhone 12 Pro or later (LiDAR required for calibration)
- iPhone 13 or later recommended (for 240fps video)
- iOS 17.0+
- Rear camera access

### Supported iPhone Models
| Model | LiDAR | Max FPS | Notes |
|---|---|---|---|
| iPhone 12 Pro / Pro Max | ✅ | 240fps | Minimum supported |
| iPhone 13 Pro / Pro Max | ✅ | 240fps | |
| iPhone 14 Pro / Pro Max | ✅ | 240fps | Better stabilisation |
| iPhone 15 Pro / Pro Max | ✅ | 240fps | Best processing power |
| iPhone 16 Pro / Pro Max | ✅ | 240fps | Recommended |

---

## Development Approach

### Phase 1 — Research (Current)
- Comprehensive competitive and technical research
- Identify optimal computer vision approach
- Establish accuracy expectations

### Phase 2 — Prototype
- Basic AVFoundation high-FPS capture
- Simple motion detection (frame differencing)
- Manual calibration (tap to set scale reference)
- Hardcoded impact zone test

### Phase 3 — Core Feature Build
- LiDAR calibration integration
- Club head tracking algorithm
- Speed calculation pipeline
- Auto swing detection

### Phase 4 — Polish & Accuracy
- Accuracy testing vs known-speed devices
- Edge case handling (poor lighting, occlusion)
- UI refinement
- Voice readout

### Phase 5 — Release
- App Store submission
- Beta testing with real golfers

---

## Contributing

This is currently a solo development project. The research phase is open — if you have expertise in computer vision, golf biomechanics, or iPhone sensor APIs and want to contribute ideas, open an issue.

---

## License

TBD — likely MIT for any open-sourced components.

---

## Acknowledgements

Research draws on the work of the teams behind Trackman, FlightScope, Foresight Sports, and the broader computer vision research community. This project is not affiliated with any commercial golf technology company.

---

*Last updated: March 2026*
