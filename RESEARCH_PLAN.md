# Golf Swing Speed App App — Research Plan

> **Purpose:** This document outlines the research brief for a comprehensive study of all existing golf swing tracking apps, software, hardware systems, academic papers, and open-source projects that use cameras (and related sensor technologies) to measure golf club head speed and swing metrics. It serves as the specification for conducting and writing `RESEARCH.md`.

---

## Research Goals

The primary goal is to inform the design and development of a new iPhone app that uses the device's built-in LiDAR sensor and high-FPS camera to measure golf club head speed — without any external hardware. This research should:

1. Map the entire competitive and academic landscape for camera-based golf swing analysis
2. Identify the best available techniques for club head detection and speed calculation using only a smartphone camera
3. Understand how LiDAR and depth sensors have been used (or could be used) for calibration in swing tracking
4. Understand the mathematical and algorithmic foundations for converting pixel movement to real-world speed
5. Identify gaps, limitations, and opportunities that our app can address
6. Catalogue innovative approaches that could be adapted or improved upon

---

## What We Are Building (Context for Research)

**App concept:** An iPhone app that:
- Uses the iPhone's built-in LiDAR scanner for initial setup calibration — identifying golf ball position and player's feet to define the swing capture zone
- Allows manual zone setup as an alternative (user taps on screen to define zone corners/boundaries)
- Activates the camera at its maximum FPS setting
- Is positioned **front-on to the player** to capture the full arc of the golf swing
- Uses computer vision to automatically detect when the player is ready to swing (setup detection) and when the swing is complete (follow-through detection)
- Tracks the club head throughout the entire swing arc
- Calculates club head speed at every point in the swing
- Identifies the **impact position** (where the ball would be) and reads out the club head speed at that point via text-to-speech
- Saves each swing with its full speed profile and data

**Out of scope for v1:**
- Ball tracking
- Club face angle
- Angle of attack
- Smash factor
- Launch angle
- Spin rate
- Any metrics beyond club head speed

---

## Research Scope

### 1. Commercial Products & Apps

Research every commercial product that uses cameras, radar, photometric sensors, or computer vision for golf swing or club head tracking. For each product, document:

#### Required Information Per Product
- **Full name** and **company/manufacturer**
- **Category** (launch monitor, swing analysis app, simulator, wearable, etc.)
- **Price / pricing model** (one-time, subscription, hardware cost)
- **Platform availability** (iOS, Android, Windows, Mac, web, proprietary hardware)
- **Hardware required** (external sensors, specific camera rigs, radar units, etc.)
- **Technology type** (radar Doppler, photometric camera, optical IR, accelerometer, etc.)
- **Camera specifications** (if camera-based: resolution, FPS used, setup distance, lighting requirements)
- **Metrics measured** (full list of what the product outputs)
- **Club head tracking method** (how they find and follow the club head)
- **Calibration approach** (how the system is set up before use)
- **Algorithms & mathematical approaches** (as much technical detail as publicly known)
- **Computer vision techniques** (optical flow, background subtraction, contour detection, ML-based detection, etc.)
- **Machine learning / AI** (what models or approaches are used, if any)
- **Accuracy claims** (what the manufacturer claims, and any third-party validation)
- **Known limitations** (documented or community-reported)
- **Innovative or unique approaches** (anything that sets this product apart technically)
- **Known patents or IP** (patent numbers or descriptions if discoverable)
- **Sources / links** (URLs, papers, reviews)

#### Products to Research (minimum — expand if more are found)

**Professional / High-End Launch Monitors**
- Trackman 4 (radar + camera)
- FlightScope X3, Xi, Mevo, Mevo+
- Foresight Sports GCQuad, GC3, GCHawk
- Bushnell Launch Pro (based on Foresight GCQuad)
- Uneekor EYE XO, EYE XO2, QED, EYELINE
- Swing Catalyst (force plate + high-speed camera)

**Consumer Launch Monitors**
- SkyTrak / SkyTrak+
- Garmin Approach R10
- Rapsodo MLM / MLM2PRO
- Voice Caddie SC4 / SC300i / SC300
- Ernest Sports ES14, ES16, ES Tour Plus
- Full Swing KIT
- Flightscope Mevo (original)

**Simulator Software & Platforms**
- E6 Connect
- GSPro
- Creative IT / about:Golf
- Full Swing Golf
- ProTee Golf
- Golfzon
- OptiShot Golf (infrared optical)
- Awesome Golf

**iPhone / Smartphone Camera Apps**
- Swing Profile (iPhone camera-based swing analysis)
- Hudl Technique (formerly Ubersense) — video analysis
- V1 Sports / V1 Golf — video analysis
- Coach's Eye — video analysis
- Swing Vision (tennis, but camera-based speed tracking)
- Callaway Swing Easy
- GolfShot
- SwingU

**GPS & Shot Tracking (for comparison)**
- Arccos Golf (sensor + AI)
- Zepp Golf (wrist sensor)
- Shot Scope (wearable GPS + shot tracking)
- Game Golf
- Golf Pad
- 18Birdies

**Motion Controller / Casual**
- Phigolf
- WGT Golf
- Homecourse (now SkyTrak)

---

### 2. Academic Research & Computer Vision Papers

Research and catalogue academic work on:

- Golf swing analysis using computer vision
- Club head / sports implement tracking from video
- High-speed object tracking algorithms
- Optical flow applied to sports analysis
- LiDAR / depth camera use in sports or motion capture
- Pose estimation applied to golf (MediaPipe, OpenPose, etc.)
- Frame interpolation and super slow-motion techniques
- Edge detection and contour tracking for fast-moving objects
- Background subtraction for dynamic scenes
- Sports analytics computer vision broadly (techniques transferable to golf)

For each paper:
- Title, authors, year, publication/conference
- Key contributions
- Methods and algorithms used
- Results / accuracy
- Relevance to our project
- Link / DOI

---

### 3. Open Source Projects

Search GitHub, Papers with Code, and academic repositories for:
- Open source golf swing analysis tools
- General sports tracking tools that could apply
- Camera-based speed measurement tools
- Club/racket/bat tracking implementations
- Any relevant datasets (labeled golf swing video datasets)

For each:
- Project name and link
- Stars / activity level
- Tech stack
- What it does
- Relevance to our project

---

### 4. Core Technology Deep Dives

Regardless of specific products, research and explain the following foundational technologies in depth:

#### 4a. Computer Vision Techniques for Fast Object Tracking
- Optical flow (Lucas-Kanade, Farneback, RAFT, etc.)
- Background subtraction (MOG2, KNN, etc.)
- Template matching
- Contour detection and tracking
- Blob detection
- Kalman filtering for motion prediction
- Deep learning object detection (YOLO, SSD, etc.) applied to fast-moving objects
- Point tracking (TAPIR, CoTracker, etc.)

#### 4b. LiDAR & Depth Sensing for Calibration
- How iPhone LiDAR works (ToF, range, resolution)
- Using ARKit for real-world measurement
- Setting up a calibrated zone using depth data
- Accuracy and limitations of iPhone LiDAR at relevant distances (1-5 metres)

#### 4c. High-FPS Camera Capture on iPhone
- Maximum FPS capabilities per iPhone model (120fps, 240fps, 960fps slow-mo)
- AVFoundation APIs for high-FPS capture
- Trade-offs (resolution vs frame rate)
- Buffer handling for real-time processing

#### 4d. Speed Calculation Math
- Converting pixel displacement to real-world distance
- Perspective correction and homography
- Using known reference distances (ball position, feet) for calibration
- Formula: speed = (real-world distance) / (time between frames)
- Accounting for camera angle / front-on perspective
- Error sources and how to minimise them

#### 4e. Swing Detection (Start/End Automation)
- Approaches to detecting swing readiness (stillness detection, pose, grip detection)
- Approaches to detecting swing completion (velocity drop, follow-through arc completion)
- Frame differencing for motion onset detection
- Background modelling with a golfer standing still

---

### 5. Key Challenges to Identify

Document the known hard problems in camera-only club head tracking:

- Motion blur at high club speeds (100+ mph)
- Maintaining tracking through impact (club/ball contact zone)
- Variable lighting conditions (outdoor, indoor simulator, etc.)
- Club head occlusion (behind body at certain swing positions)
- Perspective distortion from a front-on camera angle
- Distinguishing club head from body/clothing at similar colours
- Latency between capture and result display
- Battery and thermal management during high-FPS capture
- Accuracy vs professional radar-based systems

---

## Research Output Format

The output should be saved as `RESEARCH.md` in the root of this repository.

Structure of `RESEARCH.md`:

```
# Golf Swing Speed App — Competitive & Technology Research

## Executive Summary
## 1. Commercial Products
   ### 1.1 Professional Launch Monitors
   ### 1.2 Consumer Launch Monitors
   ### 1.3 Simulator Platforms
   ### 1.4 Smartphone Camera Apps
   ### 1.5 GPS & Shot Tracking (Comparison Only)
## 2. Academic Research & Papers
## 3. Open Source Projects
## 4. Technology Deep Dives
   ### 4.1 Computer Vision Techniques
   ### 4.2 LiDAR & Depth Sensing
   ### 4.3 High-FPS Camera on iPhone
   ### 4.4 Speed Calculation Math
   ### 4.5 Swing Detection Automation
## 5. Key Challenges
## 6. Opportunities & Gaps
## 7. Recommendations for Our App
## 8. Comparison Table
```

### Comparison Table Columns
| Product | Category | Price | Tech Type | Camera-Based? | FPS Used | Club Speed | Full Metrics | Hardware Needed | Accuracy | Platform |

---

## Research Quality Standards

- Be comprehensive — err on the side of too much detail
- Cite sources with URLs where possible
- Clearly distinguish between: manufacturer claims, third-party reviews, academic findings, and reasoned inference
- Flag anything that is unknown or unverifiable
- For academic content: include DOIs and publication venues
- For open source: include GitHub links and star counts
- Prioritise depth over breadth — a thorough analysis of 20 products is better than a shallow mention of 50

---

## Timeline & Execution

This research document should be completed before any app architecture or code is written. It will directly inform:

- Which computer vision approach to use for club head detection
- How to implement the LiDAR calibration
- What FPS target to optimise for
- How to structure the speed calculation pipeline
- What accuracy benchmarks to aim for
- Which features are genuinely novel vs already solved

---

*This research plan was created as part of the Golf Swing Speed App iPhone App project. See `README.md` for full project overview.*