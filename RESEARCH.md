# Golf Swing Speed App — Competitive & Technology Research

> **Status:** Complete — March 2026
> **Purpose:** Comprehensive research to inform the design and development of an iPhone app that uses the device's built-in LiDAR sensor and high-FPS camera to measure golf club head speed without external hardware.

---

## Executive Summary

This research maps the full landscape of golf swing speed measurement technology — from professional radar/photometric launch monitors costing $20,000+ to free smartphone apps. The key findings are:

1. **One competitor (ShotVision) attempts camera-only speed measurement on iPhone** — but with significant reliability issues (accuracy drops 30-50% in poor lighting, not all shots detected). This validates the concept but leaves a major quality gap to exploit.

2. **Camera-only speed tracking is proven possible** — SwingVision (tennis) demonstrates real-time ball and racket speed measurement using only an iPhone camera and on-device ML. This validates the core concept.

3. **240fps at 1080p is the practical ceiling** on current iPhones. At 100mph club head speed (~44 m/s), the club head moves ~18cm per frame — trackable but challenging with motion blur.

4. **Motion blur is both the biggest challenge and a potential signal.** Blur streak length is proportional to speed and can supplement frame-to-frame tracking for velocity estimation.

5. **LiDAR calibration is viable** at 1–5m range with ±1cm accuracy for establishing pixel-to-real-world scale, though its 15Hz refresh rate means it's useful for setup calibration only, not real-time tracking.

6. **Audio-based swing detection** could significantly reduce processing overhead by triggering high-FPS capture only during actual swings, rather than continuous video monitoring.

7. **Realistic accuracy target: ±3-5 mph** for v1, with potential to reach ±2 mph through sensor fusion (camera + LiDAR + audio + IMU).

---

## 1. Commercial Products

### 1.1 Professional Launch Monitors

#### Trackman 4
- **Company:** Trackman (Denmark)
- **Category:** Professional dual-radar launch monitor
- **Price:** ~$20,000–$25,000
- **Technology:** Patented dual Doppler radar + optically enhanced radar tracking (OERT). One radar measures launch conditions at impact; the second tracks ball through entire flight (~6 seconds). High-speed camera at up to 4,600 fps for club and ball tracking.
- **Metrics:** 40+ data points including club speed, ball speed, face angle, club path, spin rate, spin axis, launch angle, carry, total distance, attack angle, dynamic loft, smash factor
- **Accuracy:** Industry gold standard. Used on PGA Tour. Club head speed claimed ±0.5 mph
- **Calibration:** Patented alignment camera for automatic target alignment
- **Key Insight:** Dual Doppler radar captures data for entire ball flight — this is fundamentally different from camera-only approaches which capture fractions of a second
- **Limitations:** Size, cost, requires space behind golfer
- **Patents:** Multiple patents on dual radar and OERT technology

#### Foresight Sports GCQuad
- **Company:** Foresight Sports (USA)
- **Category:** Professional photometric launch monitor
- **Price:** ~$12,000–$14,000
- **Technology:** Quadrascopic imaging — 4 high-speed cameras with infrared object tracking. Captures club and ball at impact using IR illumination and high-speed photography
- **Metrics:** Club head speed, ball speed, launch angle, spin rate, spin axis, carry distance, face angle, attack angle, club path, impact location
- **Accuracy:** Tour-level. Within ±0.5 mph on club speed. Used by major tour fitters
- **Calibration:** Internal accelerometer eliminates manual calibration; onboard barometer adjusts for atmosphere
- **Camera Speed:** Captures at ~10,000fps with IR flash illumination. Reflective stickers on clubface tracked frame-to-frame. Uses patented "Spherical Correlation" algorithm matching ball dimple patterns between frames for spin
- **Key Insight:** Photometric (camera-based) approach proves high-speed cameras can measure club speed accurately — but requires IR illumination, purpose-built optics, and 10,000fps (vs our 240fps)
- **Limitations:** Captures data only at impact zone (fraction of a second vs Trackman's full flight tracking). Requires ball to be within specific hitting zone

#### Foresight Sports GC3
- **Company:** Foresight Sports (USA)
- **Category:** Portable photometric launch monitor
- **Price:** ~$5,000–$7,000
- **Technology:** Same photometric technology as GCQuad but with 3 cameras instead of 4
- **Metrics:** Similar to GCQuad but slightly fewer club data points
- **Key Insight:** Demonstrates that 3-camera photometric system is sufficient for accurate speed measurement

#### Bushnell Launch Pro
- **Company:** Bushnell (partnership with Foresight Sports)
- **Price:** ~$3,000 (hardware) + subscription for full features
- **Technology:** Based on Foresight GC3 platform — 3-camera photometric system
- **Key Insight:** Same core technology as GC3 at lower price point through different business model

#### FlightScope X3
- **Company:** FlightScope (South Africa)
- **Category:** Professional radar launch monitor
- **Price:** ~$10,000–$15,000
- **Technology:** 3D Doppler radar (phased array). Tracks club and ball continuously
- **Metrics:** Comprehensive — club speed, ball speed, spin, launch, carry, etc.
- **Accuracy:** Professional-grade. Competes directly with Trackman

#### Uneekor EYE XO2
- **Company:** Uneekor (South Korea)
- **Category:** Overhead-mounted photometric launch monitor
- **Price:** ~$5,000–$7,000
- **Technology:** 3 high-speed infrared cameras mounted overhead, looking down at impact zone. Patented "EYE XO engine"
- **Metrics:** Club head speed (±0.5 mph accuracy), ball speed, launch angle, spin rate, face angle, attack angle, impact location, club path, dynamic loft
- **Hitting Zone:** 28" wide × 21" deep (300% larger than predecessor)
- **Calibration:** No marked balls required for ball tracking. Reflective club stickers needed for full club data
- **Key Insight:** Overhead camera angle avoids many occlusion problems. Slow-motion video replay of impact included
- **Limitations:** Indoor-only due to mounting requirements

#### Uneekor QED
- **Company:** Uneekor
- **Price:** ~$3,000–$4,000
- **Technology:** 2 high-speed cameras (vs 3 in EYE XO2), overhead mount
- **Key Insight:** Lower camera count still provides accurate speed measurement

#### Swing Catalyst
- **Company:** Swing Catalyst (Norway)
- **Category:** Force plate + high-speed camera system
- **Price:** ~$10,000–$20,000+ (full system)
- **Technology:** Combination of force/pressure plates (2,000+ sensors) and high-speed cameras up to 500fps (Lynx GigE camera up to 320fps). Includes markerless motion capture
- **Metrics:** Ground reaction forces, pressure distribution, center of pressure, body kinematics, swing video analysis
- **Key Insight:** Demonstrates multi-sensor fusion approach (force + camera + markerless mocap). No markers, wires, or calibration required for their latest system
- **Limitations:** Primarily a biomechanics tool rather than launch monitor. Requires installation

---

### 1.2 Consumer Launch Monitors

#### FlightScope Mevo+
- **Company:** FlightScope
- **Price:** ~$2,000
- **Technology:** Patented "Fusion Tracking" — 3D Doppler radar + synchronized high-speed image processing camera
- **Metrics:** 20+ parameters including club head speed, ball speed, spin rate, launch angle, carry distance
- **Accuracy:** Very good for price point. Radar measured, algorithms calculated for some metrics
- **Setup:** 6.5–8.5 feet behind the ball
- **Key Insight:** Fusion of radar + camera demonstrates that combining sensor modalities improves accuracy over either alone
- **Limitations:** Requires significant space behind golfer. Underreports rollout/total distance. Fluorescent lighting can affect performance

#### SkyTrak+
- **Company:** SkyTrak (USA)
- **Price:** ~$2,500
- **Technology:** Dual Doppler radar + photometric camera system (upgrade from original SkyTrak which was photometric only)
- **Metrics:** Club head speed, ball speed, smash factor, club path, face angle, face-to-path, backspin, sidespin, launch angle, carry/total distance, shot shape
- **Accuracy:** Robot-tested at Golf Laboratories. Within ~5% of premium monitors ($20K units) on ball speed, launch angle, spin rates
- **Key Insight:** Adding radar to photometric system improved outdoor performance significantly. Demonstrates value of multi-sensor approach

#### Garmin Approach R10
- **Company:** Garmin
- **Price:** ~$600
- **Technology:** Single Doppler radar
- **Metrics:** 14 data points — 4-5 directly measured by radar (ball speed, club head speed, launch angle, launch direction), remaining calculated by algorithm
- **Accuracy:** Carry distance within ~5 yards. More accurate outdoors where full ball flight observable. Indoors, uses ML model for spin estimation
- **Setup:** Behind the ball, aimed down target line
- **Key Insight:** Machine learning supplements radar data to estimate parameters not directly measured. Titleist RCT balls improve spin accuracy 30x
- **Limitations:** Algorithm-calculated metrics less reliable than directly measured. Indoor accuracy lower

#### Rapsodo MLM2PRO
- **Company:** Rapsodo
- **Price:** ~$700
- **Technology:** Dual optical camera (one 240fps high-speed, one standard) + Doppler radar
- **Metrics:** 15 parameters including club path, angle of attack, spin rate, spin axis
- **Accuracy:** Claims within 1% of high-end monitors when using RPT balls (Callaway Chrome Soft X with embedded tracking markers)
- **Key Insight:** 240fps high-speed camera provides "Impact Vision" showing club path and contact point. Demonstrates what's achievable at 240fps. Requires special marked balls for full spin accuracy
- **Setup:** 6.5–8.5 feet behind ball

#### Voice Caddie SC300i
- **Company:** Voice Caddie
- **Price:** ~$400–$500
- **Technology:** Doppler radar + atmospheric pressure sensors
- **Metrics:** Club speed, ball speed, carry distance, smash factor, launch angle, apex height
- **Accuracy:** ±2% ball speed, ±3% carry distance
- **Setup:** 40–60" behind ball
- **Key Insight:** Simple radar-only approach still achieves ±2% accuracy on speed metrics

#### Ernest Sports ES16
- **Company:** Ernest Sports
- **Price:** ~$3,500–$4,000
- **Technology:** Quad Doppler radar + dual photometric cameras
- **Metrics:** Club head speed, ball speed, smash factor, face angle, club path, angle of attack, spin rate, spin axis, launch angle, carry/total distance
- **Key Insight:** Explicitly combines radar for speed accuracy with cameras for directional/spin accuracy — acknowledging each technology's strengths

---

### 1.3 Simulator Platforms

#### OptiShot 2
- **Technology:** 16 infrared sensors (48MHz) firing 10,000 pulses/second, mounted in a mat. Two rows of IR sensors detect club sole as it passes over
- **Price:** ~$300
- **Metrics:** Club head speed, face angle, swing path, distance, face contact, swing tempo
- **Accuracy:** Claims ±2 mph club speed, ±1.5° face angle, ±1.9° swing path. Real-world accuracy decreases at higher speeds
- **Key Insight:** Demonstrates that speed can be measured from brief sensor readings near impact zone. However, accuracy is "ballpark" — doesn't account for gear effect on off-center hits
- **Limitations:** Indoor only. No ball tracking. Accuracy diminishes with speed

#### E6 Connect / GSPro / Awesome Golf
- Software platforms that connect to various launch monitors. Not measurement devices themselves
- GSPro notable for being community-driven with wide device compatibility
- E6 Connect is the most polished with photorealistic courses

#### Golfzon
- **Technology:** Proprietary overhead camera + floor sensor system
- **Category:** Commercial simulator (primarily installed in golf lounges)
- Full swing analysis with auto-tee system

---

### 1.4 Smartphone Camera Apps

#### SwingVision (Tennis/Pickleball) — HIGHLY RELEVANT
- **Company:** SwingVision (founded by Swupnil Sahai, former Tesla Autopilot CV engineer)
- **Platform:** iOS (iPhone, iPad, Apple Watch)
- **Price:** Subscription-based (~$15/month)
- **Technology:** CoreML + Apple Neural Engine for on-device computer vision. Processes 2M pixels/frame in real-time. No internet required
- **How It Works:** iPhone/iPad mounted to fence or tripod. Proprietary AI processes video at ~60fps to detect ball trajectories, measure speed (average velocity over flight path — reads ~20% lower than peak/impact radar), and classify shot types. Apple Watch uses accelerometer + gyroscope for swing speed
- **Accuracy:** Peer-reviewed validation: ICC 0.76-0.80 for speed. ~10% accuracy vs radar at 60fps
- **Key Quote (company):** Speed measurement is "not possible without Neural Engine"
- **Key Insight:** **Validates camera-only speed measurement on iPhone.** Our 240fps gives a 4× advantage over SwingVision's 60fps baseline. However, a golf club head is visible in far fewer frames than a tennis ball in flight — the tracking challenge is harder
- **Accuracy Benchmark:** Zepp Golf 2 wearable IMU sensor achieves ~12% random error (peer-reviewed). If our camera-only app achieves <10% accuracy, it beats dedicated wearable hardware

#### V1 Golf / V1 Sports
- **Technology:** Video analysis with manual annotation. Drawing tools, side-by-side comparison, slow-motion playback
- **No speed measurement** — purely visual analysis
- **Key Insight:** Market leader in video swing analysis. No automated tracking or measurement

#### Hudl Technique (formerly Ubersense)
- **Technology:** Slow-motion video capture and analysis
- **No speed measurement** — video overlay and annotation tools

#### Coach's Eye
- **Technology:** Similar to V1 — video capture with drawing tools and comparison
- **No speed measurement**

#### Swing Profile
- **Technology:** iPhone camera-based swing analysis with some automated pose detection
- **No speed measurement**

#### GolfShot / SwingU / 18Birdies
- **Category:** GPS/rangefinder apps with basic swing tracking
- **No club head speed measurement** — focused on course management, scoring, GPS distances

**Key Finding:** One golf app (ShotVision) attempts camera-only speed measurement but with significant reliability issues — accuracy drops 30-50% in poor lighting and not all shots are detected. This validates the concept while leaving a quality gap to fill.

#### ShotVision (Golf) — DIRECT COMPETITOR
- **Platform:** iOS
- **Technology:** Computer vision from iPhone camera. Uses CV to directly measure ball speed, launch angle, club path; algorithmically derives club speed, spin, distance
- **Accuracy:** Significant reliability issues — accuracy drops 30-50% in poor lighting. Not all shots are detected
- **Key Insight:** Demonstrates the camera-only concept in golf but with major quality issues. Lighting handling is the #1 differentiator for camera-based approaches. Our LiDAR calibration + audio detection + 240fps capture at higher quality could significantly outperform

---

### 1.5 GPS & Shot Tracking (Comparison)

| Product | Technology | Speed Measurement | Notes |
|---|---|---|---|
| Arccos Golf | Club sensors + AI | No direct speed | Shot tracking via impact detection |
| Zepp Golf | Wrist/grip sensor | Estimates swing speed from accelerometer | Not club head speed — wrist speed |
| Shot Scope | Wearable GPS + club tags | No | Distance-based tracking |
| Game Golf | Club tags + GPS | No | Shot tracking only |
| Phigolf | Motion sensor stick | Simulated speed from motion data | Not real club measurement |

---

## 2. Academic Research & Papers

### 2.1 Golf-Specific Computer Vision

**"Visual Golf Club Tracking for Enhanced Swing Analysis"**
- Uses a global motion model to retrieve 2D spatio-temporal trajectory of golf club head from ordinary video sequences
- Extracts club orientation, local speed, and acceleration
- Demonstrates that club head tracking from standard video is feasible but challenging
- Source: ResearchGate

**"Efficient Golf Ball Detection and Tracking Based on Convolutional Neural Networks" (Zhang et al., 2020)**
- ArXiv: 2012.09393
- Uses CNN for real-time golf ball detection combined with discrete Kalman filter for tracking
- Addresses motion blur, small object size, and high-speed movement challenges
- Reports optical flow compensation for motion blur + YOLOv3/v4 for detection + unscented Kalman filter for robust tracking through occlusion

**"Golf Video Tracking Based on Recognition with HOG and Spatial-Temporal Vector" (Li et al., 2017)**
- Uses HOG features with spatial-temporal analysis for golf tracking
- Published in International Journal of Advanced Robotic Systems

**GolfDB — Golf Swing Sequencing Database (McNally et al.)**
- GitHub: wmcnally/golfdb
- Video database for detecting 8 golf swing events in trimmed videos
- Baseline model "SwingNet" for swing phase classification
- Relevant for swing detection and phase segmentation

**"Advanced Golf Swing Analysis Using MediaPipe and Machine Learning" (2025)**
- Uses MediaPipe Pose Estimation to extract 33 body landmarks
- ML models (Decision Tree, Random Forest, LSTM, GRU, 1D CNN) for swing phase classification
- Segments swing into: address, top backswing, contact, follow-through
- Published in Springer proceedings

### 2.2 High-Speed Object Tracking

**RAFT: Recurrent All-Pairs Field Transforms for Optical Flow (2020)**
- State-of-the-art optical flow. Per-pixel features → 4D correlation volumes → iterative flow refinement
- F1-all error: 5.10% on KITTI, EPE: 2.855 pixels on Sintel
- Relevant for dense motion estimation between frames

**CoTracker3 (Meta/Facebook Research, 2024)**
- Transformer-based model for tracking any point (pixel) on a video
- Tracks points jointly across frames (not independently) → higher accuracy
- 1000x less training data than predecessors
- State-of-the-art on TAP-Vid benchmarks
- GitHub: facebookresearch/co-tracker
- **Highly relevant** — could track club head as a point through swing video

**TAPIR (DeepMind)**
- Feed-forward point tracker combining matching and refinement stages
- Struggles with occluded points — relevant limitation for golf (club behind body)

**"An Analysis of Kalman Filter based Object Tracking Methods for Fast-Moving Tiny Objects" (2025)**
- ArXiv: 2509.18451
- Directly relevant — analyzes tracking of small, fast objects
- SORT algorithm uses Kalman Filter + Hungarian algorithm, runs at 260 Hz
- Unscented Kalman Filter (UKF) handles non-linear motion better than standard KF

### 2.3 Motion Blur and Velocity Estimation

**"Vehicle Speed Estimation Based On Image Motion Blur Using RADON Transform"**
- Uses motion blur streak analysis for speed estimation
- Process: estimate motion direction → simplify to 1D → detect blur length via edge analysis → calculate speed from imaging geometry
- Accuracy: <1% error at speeds up to 40km/h, ~3% at 70km/h

**"Velocity Estimation From a Single Linear Motion Blurred Image Using DCT"**
- Estimates speed from a single blurred frame using Discrete Cosine Transform
- **Key insight for our app:** Motion blur length = speed × exposure time. If exposure time is known (from camera settings), blur length directly gives speed

**"A Novel Method for Measuring Velocity Through Synthetic Motion Blur Images" (2024)**
- Uses FFT → binarization → Radon transform to extract blur length
- Correlates motion blur with axial velocity
- Demonstrates motion blur as a viable speed measurement signal

### 2.4 Frame Interpolation

**RIFE: Real-Time Intermediate Flow Estimation (ECCV 2022)**
- GitHub: hzwer/ECCV2022-RIFE
- Neural network (IFNet) estimates intermediate optical flows
- Runs at 30+ FPS for 2× 720p interpolation on 2080Ti GPU
- 4–27× faster than SuperSlomo and DAIN with better results
- Supports arbitrary timestep interpolation
- **Application:** Could interpolate 240fps → effective 480fps or higher for improved tracking resolution

**FILM (Frame Interpolation for Large Motion)**
- Google Research method for large-motion frame interpolation
- Complementary to RIFE for different motion magnitudes

### 2.5 Pose Estimation for Golf

**MediaPipe Pose**
- Google's real-time pose estimation: 33 body landmarks
- Successfully applied to golf swing analysis in multiple projects
- Can track ear, hip, wrist positions for swing phase detection
- Runs on-device on iPhone via Core ML or directly via MediaPipe iOS SDK

**OpenPose**
- Multi-person pose estimation (Carnegie Mellon)
- Used in golf analysis for detailed body kinematics
- Heavier than MediaPipe — less suitable for real-time mobile use

---

## 3. Open Source Projects

### 3.1 Golf-Specific

| Project | Link | Stars | Tech | Relevance |
|---|---|---|---|---|
| **GolfDB** | github.com/wmcnally/golfdb | ~200+ | Python, PyTorch | Swing event detection from video. 8-event classification |
| **AICaddy** | github.com/oswinkil-git/AICaddy-A-Golf-Club-Tracer | ~50 | Python, YOLOv8 | **Club head detection model trained on 6,000+ images of golf club heads (drivers)** |
| **golf-swing-analysis** | github.com/HeleenaRobert/golf-swing-analysis | ~30 | Python, MediaPipe, OpenCV | Pose-based swing analysis, angle calculation, motion tracking |
| **GolfTracker** | github.com/rlarcher/GolfTracker | ~20 | Mobile | Ball trajectory tracing, launch angle, swing speed estimation |
| **analyze.golf** | github.com/tlouth19/analyze.golf | ~40 | React, Redux, Konva.js | Browser-based swing analyzer with drawing tools |
| **GolfSwing** | github.com/personableduck/GolfSwing | ~15 | Python | Golf swing analysis model |
| **Pose Estimation for Swing** | github.com/Strojove-uceni/23206-final-pose-estimation | ~10 | Python | ViTPose model for swing phase segmentation |

### 3.2 DIY Launch Monitors

| Project | Link | Tech | Relevance |
|---|---|---|---|
| **PiTrac** | hackaday.io/project/195042 | Raspberry Pi, IR strobe cameras | **Full DIY launch monitor** — ball speed, launch angles, 3-axis spin. Uses high-speed IR strobe-based capture to avoid needing expensive high-speed cameras. Demonstrates that speed measurement is possible with creative hardware approaches |

### 3.3 Key Reference Implementations (iOS)

| Project | Link | Relevance |
|---|---|---|
| **SlowMotionVideoRecorder** | github.com/shu223/SlowMotionVideoRecorder | iOS 240fps camera capture reference implementation with clean wrapper class. Directly reusable for our capture pipeline |
| **ObjectDetection-CoreML** | github.com/tucan9389/ObjectDetection-CoreML | Complete reference for running YOLOv8/v5 on iPhone via CoreML with live camera feed. Shows how to wire detection model to AVFoundation |

### 3.4 Sports Object Tracking (Cross-Sport)

| Project | Source | Relevance |
|---|---|---|
| **TrackNet** | arxiv.org/abs/1907.03698 | Deep learning architecture purpose-built for tracking tiny high-speed objects in sports video. 99.7% precision on tennis ball tracking. Multiple PyTorch implementations available. **Highly relevant** — could be adapted for golf club head tracking |

### 3.5 Datasets

| Dataset | Source | Content |
|---|---|---|
| **golf-club-tracking** | Roboflow Universe | 6,750 images with Darknet annotations for YOLO training. Exportable in CoreML/YOLO format. Ready for custom model training |
| **GolfDB** | GitHub | 1,400 annotated golf swing videos with 8-event annotations. Critical for swing phase detection and identifying impact frame |

### 3.6 General CV Tools (Applicable)

| Project | Link | Relevance |
|---|---|---|
| **CoTracker** | github.com/facebookresearch/co-tracker | State-of-the-art point tracking. Could track club head through swing |
| **Practical-RIFE** | github.com/hzwer/Practical-RIFE | Frame interpolation for increasing effective FPS |
| **Ultralytics YOLOv8/YOLO11** | github.com/ultralytics/ultralytics | Object detection including golf ball tracking examples |

---

## 4. Technology Deep Dives

### 4.1 Computer Vision Techniques for Club Head Tracking

#### Optical Flow
- **Lucas-Kanade:** Sparse optical flow — tracks specific points between frames. Fast, suitable for tracking a few key points (like club head centroid). Assumes constant flow in local neighborhood
- **Farneback:** Dense optical flow — computes motion for every pixel. Computationally expensive but gives full motion field. Useful for swing detection (detecting overall motion onset)
- **RAFT:** Deep learning optical flow. State-of-the-art accuracy. Could be too slow for real-time on iPhone but useful for post-capture analysis
- **Relevance:** Optical flow between consecutive 240fps frames can estimate club head displacement. At 100mph, displacement is ~18cm/frame — detectable but requires robust feature tracking through motion blur

#### Background Subtraction
- **MOG2 (Mixture of Gaussians 2):** Models each pixel as mixture of Gaussians. Handles lighting variations and shadows. Faster than KNN — better for real-time. Good for detecting swing onset (golfer begins moving)
- **KNN (K-Nearest Neighbors):** More robust edge detection, works in low light, but more computationally intensive
- **Application:** Use background subtraction to detect when the golfer transitions from still (address) to moving (swing start). Also useful for isolating the moving club from static background

#### Template Matching
- Match a template image of the club head across frames
- Fast but brittle — fails with rotation, scale changes, and motion blur
- Could work for initial detection in early backswing frames where club moves slowly
- Not suitable for high-speed downswing frames

#### Contour Detection and Blob Detection
- Detect club head as a distinct blob/contour against background
- Works best with high contrast between club and background
- Challenging when club head is similar color to grass/sky
- Could be enhanced with HSV color space filtering

#### Kalman Filter
- Predicts next position based on current state (position + velocity)
- SORT algorithm: Kalman + Hungarian algorithm, runs at 260Hz
- **Critical for our app:** When club head is temporarily lost (motion blur, occlusion), Kalman filter predicts expected position for next frame. Unscented Kalman Filter (UKF) handles the non-linear acceleration through the swing arc
- Prediction step maintains track even through 2-3 frames of detection failure

#### Deep Learning Detection (YOLO, SSD)
- **YOLOv8/YOLO11:** Real-time object detection. AICaddy project demonstrates YOLOv8 trained on 6,000+ golf club head images
- **Challenge:** Standard YOLO operates on single frames — motion-blurred club heads look very different from clean training images
- **Solution:** Train on augmented dataset including motion-blurred club heads. Or use YOLO for detection in slow frames (backswing) and switch to optical flow/Kalman for fast frames (downswing)
- **On-device inference:** Core ML can run lightweight YOLO models on iPhone Neural Engine at 3-6ms per inference on A17 Pro+ (35 TOPS Neural Engine). This fits within the 4.17ms per-frame budget at 240fps — real-time detection may be feasible

#### Apple Vision Framework (Built-in iOS APIs)
- **VNTrackObjectRequest:** Fast object tracking — give it initial bounding box, it tracks across frames. Hardware-accelerated. Directly usable for club head tracking after initial YOLO detection
- **VNGenerateOpticalFlowRequest:** Built-in optical flow generation between frames. Returns motion vectors. No need for custom optical flow implementation
- **VNDetectHumanBodyPoseRequest:** 19-point body pose detection. Could supplement swing phase detection
- **Key advantage:** These are Apple-optimized, hardware-accelerated, and require no custom model deployment

#### Point Tracking (CoTracker, TAPIR)
- **CoTracker3:** Track any point through video. User specifies initial point on club head → model tracks it through entire swing
- **Advantage:** Handles appearance changes better than template matching
- **Challenge:** Computationally expensive. May need post-capture processing rather than real-time
- **Application:** Process swing video after capture to extract precise club head trajectory

### 4.2 LiDAR & Depth Sensing on iPhone

#### How iPhone LiDAR Works
- **Sensor Type:** direct Time-of-Flight (dToF) — measures actual round-trip time of IR light pulses
- **Emitter:** VCSEL (Vertical-Cavity Surface-Emitting Laser) array — emits grid of IR dots
- **Detector:** SPAD (Single-Photon Avalanche Diode) array — detects individual returning photons
- **Process:** Emits IR light → measures time for each pulse to return → calculates distance per point

#### Specifications
- **Range:** 0.26m (minimum) to ~6.4m (maximum) for rear sensor via ARKit
- **Optimal Range:** 0.3m to 2.0m for best accuracy
- **Accuracy:** ±1cm for objects >10cm at optimal range; ±10cm at larger scales/distances
- **Sampling Rate:** 60Hz via AVFoundation depth data output (some earlier sources reported 15Hz — this appears to be for ARKit scene reconstruction mesh updates, not raw depth map delivery)
- **Resolution:** 256×192 (ARKit) or 768×576 (AVFoundation) depth map. Interpolated from sparse point cloud
- **Lighting:** Accuracy decreases in low light (Apple fuses RGB + depth internally)

#### Available iPhone Models with LiDAR
| Model | Chip | LiDAR | Max Slow-Mo FPS |
|---|---|---|---|
| iPhone 12 Pro/Max | A14 | Yes | 240fps @ 1080p |
| iPhone 13 Pro/Max | A15 | Yes | 240fps @ 1080p |
| iPhone 14 Pro/Max | A16 | Yes | 240fps @ 1080p |
| iPhone 15 Pro/Max | A17 Pro | Yes | 240fps @ 1080p |
| iPhone 16 Pro/Max | A18 Pro | Yes | 240fps @ 1080p |
| iPhone 17 Pro/Max | A19 Pro | Yes | 240fps @ 1080p |

#### ARKit Capabilities for Calibration
- **Scene Reconstruction:** ARKit builds 3D mesh of environment
- **Raycasting:** Tap screen → ARKit returns 3D world coordinate. Can identify ground plane, object positions
- **Plane Detection:** Automatically detects horizontal/vertical surfaces
- **World Tracking:** 6DoF camera pose tracking in real-time
- **Measurement API:** ARKit can measure real-world distances between points

#### Calibration Approach for Our App
1. User positions iPhone front-on to swing area (1.5–3m distance)
2. LiDAR scans scene → ARKit identifies ground plane
3. User places ball (or marks impact zone) → LiDAR measures distance and position
4. ARKit provides camera intrinsic parameters + depth-to-camera transform
5. Establishes pixels-per-metre scale factor at the swing plane
6. Scale factor accounts for perspective (objects further from camera appear smaller)
7. Lock calibration during capture — camera must remain stationary

#### Limitations
- LiDAR at 15Hz is too slow for real-time club tracking during swing
- Depth accuracy degrades beyond 2m — may affect calibration at larger setup distances
- Cannot provide real-time depth during 240fps capture (different camera modes)
- Calibration is only as good as the assumption that the swing happens in a consistent plane

### 4.3 High-FPS Camera on iPhone

#### Capabilities
- **All Pro models (12 Pro+):** 240fps at 1080p (1920×1080)
- **4K options:** Up to 120fps on recent Pro models
- **No iPhone supports 960fps** (Samsung offered this briefly via frame interpolation, not true 960fps capture)

#### AVFoundation API
```swift
// Key classes for high-FPS capture
AVCaptureSession / AVCaptureMultiCamSession
AVCaptureDevice — configure frame rate, resolution
AVCaptureVideoDataOutput — receive CMSampleBuffer per frame
AVCaptureMovieFileOutput — record to file

// Setting 240fps:
device.activeFormat = format  // Find format supporting 240fps
device.activeVideoMinFrameDuration = CMTime(1, 240)
device.activeVideoMaxFrameDuration = CMTime(1, 240)
```

#### Resolution vs Frame Rate Trade-offs
| FPS | Resolution | Pixel Count | Processing Load |
|---|---|---|---|
| 30 | 4K (3840×2160) | 8.3M | Low |
| 60 | 4K (3840×2160) | 8.3M | Medium |
| 120 | 4K (3840×2160) | 8.3M | High |
| 240 | 1080p (1920×1080) | 2.1M | Very High |

#### Multi-Camera Session
- `AVCaptureMultiCamSession` (iOS 13+) allows simultaneous capture from multiple cameras
- Could capture wide (for full swing arc) + telephoto (for impact zone detail) simultaneously
- **Trade-off:** Multi-cam sessions may not support 240fps on both streams simultaneously
- Needs testing to confirm whether wide@240fps + telephoto@lower-fps is possible

#### Real-Time Processing Pipeline
1. `AVCaptureVideoDataOutput` delivers `CMSampleBuffer` per frame
2. Extract `CVPixelBuffer` from sample buffer
3. Convert to `CIImage` or `vImage` for processing
4. Run through Vision framework or Core ML model
5. Metal/GPU acceleration available via `MTLTexture`

#### Thermal Management
- Sustained 240fps capture generates significant heat
- iPhone thermal management will throttle camera after prolonged capture
- **Mitigation:** Capture only during actual swings (not continuous). Audio-triggered capture could reduce thermal load by 90%+

### 4.4 Speed Calculation Math

#### Basic Formula
```
speed (m/s) = real_world_distance (m) / time_between_frames (s)
speed (mph) = speed (m/s) × 2.23694
time_between_frames at 240fps = 1/240 = 0.00417 seconds
```

#### Pixel to Real-World Distance
```
Given: calibration establishes pixels_per_metre at the swing plane
pixel_displacement = √((x2-x1)² + (y2-y1)²)  // between frames
real_distance = pixel_displacement / pixels_per_metre
```

#### Perspective Correction (Homography)
- Front-on camera introduces perspective distortion
- Club head at top of backswing is further from camera than at impact zone
- **Solution 1:** Use LiDAR depth map to establish a 3D model of the swing plane. Adjust pixels_per_metre based on estimated depth at each swing position
- **Solution 2:** Homography matrix transforms image coordinates to ground-plane coordinates. Requires 4+ known reference points (feet positions, ball position from LiDAR)
- **Solution 3:** Assume swing arc lies approximately in a single plane. Calibrate scale at multiple known depths during setup

#### Error Sources
| Source | Impact | Mitigation |
|---|---|---|
| Motion blur (centroid uncertainty) | ±2-5 cm per frame | Motion blur analysis, sub-pixel estimation |
| LiDAR calibration accuracy | ±1-2% scale error | Multiple calibration points, averaging |
| Perspective distortion | ±3-10% at extremes | Homography correction, depth-adjusted scale |
| Frame timing jitter | **SIGNIFICANT** — iPhone 14 Pro reports 162-200fps actual when set to 240fps | **MUST read actual timestamps from CMSampleBuffer metadata, never assume consistent 240fps** |
| Club head detection error | ±1-3 pixels | Kalman smoothing, confidence weighting |
| Camera shake | Variable | Require tripod/stable mount, OIS compensation |

#### Speed Profile Construction
1. Track club head position in each frame: (x_i, y_i, t_i)
2. Calculate instantaneous speed between consecutive frames
3. Apply Kalman smoothing to reduce noise in speed curve
4. Identify impact zone from calibrated position
5. Extract speed at impact frame(s)
6. Apply correction factors from calibration

#### Accuracy Estimation
At 240fps with 100mph club head speed:
- Club head moves ~18cm per frame
- At 1080p with typical framing, this is ~20-40 pixels per frame
- With ±2 pixel detection accuracy: speed uncertainty = ±2/30 × 100 = ~±7%
- With sub-pixel accuracy (±0.5 pixel): uncertainty = ~±2%
- With motion blur analysis supplementing: potentially ±1-2%

### 4.5 Swing Detection Automation

#### State Machine
```
IDLE → SETUP_DETECTED → READY → SWING_IN_PROGRESS → SWING_COMPLETE → PROCESSING → RESULT
```

#### Setup Detection (IDLE → SETUP_DETECTED)
- **Pose estimation:** MediaPipe detects golfer in address position (specific body landmark configuration)
- **Background subtraction:** Person enters frame and becomes stationary
- **Detection:** Golfer body detected + golf club detected (vertical orientation)

#### Ready Detection (SETUP_DETECTED → READY)
- **Stillness detection:** Frame-to-frame motion drops below threshold for N frames
- **Metrics:** Average pixel displacement < threshold for 0.5–1.0 seconds
- **Alternative:** Audio monitoring — ambient sound baseline (no whoosh)

#### Swing Start (READY → SWING_IN_PROGRESS)
- **Motion onset:** Frame differencing exceeds threshold
- **Audio trigger:** Whoosh sound onset detection
- **Speed:** Must trigger within 1-2 frames (~4-8ms) to not miss the start

#### Swing Complete (SWING_IN_PROGRESS → SWING_COMPLETE)
- **Velocity drop:** Tracked motion speed drops below threshold (follow-through decelerating)
- **Audio:** Whoosh sound fades
- **Duration:** Typical full swing is 0.8–1.5 seconds. If >2 seconds, likely a waggle or interrupted swing
- **Impact detection:** Sharp spike in audio or maximum speed point in tracking

### 4.6 Lag Angle / Wrist Release Analysis

#### Industry Terminology
The angle between the lead arm and club shaft during the downswing is referred to by several terms:
- **Lag Angle** — the most common term. The angle between the lead forearm and the club shaft
- **Wrist Cock Angle** / **Wrist Set Angle** — the angle created by the wrist hinge (radial deviation)
- **Release Angle** — the lag angle at the point where the wrist begins to unhinge
- **Lever Angle** — biomechanics term for the same measurement
- GEARS 3D system calls it **"lead wrist set angle"**

#### How It's Measured
- **Definition:** The angle formed between the lead forearm line (elbow to wrist) and the club shaft line (wrist to club head)
- **Key measurement points:**
  - **Top of backswing:** Typically 80–100° for tour pros, ≥90° for amateurs
  - **Lead arm parallel (downswing):** The critical measurement point. 45° shaft angle is ideal and achievable for average golfers
  - **Shaft horizontal (downswing):** Tour pros maintain 100–120°. Below 110° virtually ensures no "flip"
  - **Impact:** Ideally the hands are ahead of the club head (forward shaft lean). Shaft lean angle of 5–15° at impact indicates maintained lag
- **Camera angle matters:** Must measure perpendicular to the angle plane. Front-on view can distort — club laid off appears to have less lag than actual. Down-the-line view is more accurate for this measurement

#### Benchmark Numbers
| Player Type | Lag at Top | Lag at Lead Arm Parallel | Lag at Shaft Horizontal |
|---|---|---|---|
| Tour Pro (average) | 80–100° | ~45° shaft to ground | 100–120° |
| Tour Pro (extreme, e.g., Sergio Garcia) | <80° | ~30° shaft to ground | 70–100° |
| Good amateur (5-10 hdcp) | 90–100° | 50–60° | 90–110° |
| High handicapper (20+) | 90–100° (similar setup) | 70–90° (early release) | 60–80° (severe casting) |

#### Casting vs Lag Retention
- **Casting / Early Release:** Loss of lag angle early in the downswing. The wrist unhinge begins at or shortly after the transition, causing the club head to overtake the hands before impact
- **Maintained Lag:** Wrist angle preserved deep into the downswing. Release occurs in the last 30–50° of arm rotation before impact
- **Speed Impact (quantified):** Chu et al. (2010, Golf Science Journal, study of 308 golfers) found that a decrease in wrist cock angle of **10° at late downswing = ~5 mph increase in club head speed**. An amateur who casts 30° early could be losing **10–15 mph**. At ~2.5 yards carry per 1 mph, that's **25–37 yards** lost
- **Citation:** Chu et al., "How Amateur Golfers Deliver Energy to the Driver" — golfsciencejournal.org/article/12640
- **Visual indicator:** If the club shaft passes vertical before the hands reach hip height, the golfer is casting

#### HackMotion Wrist Measurement Standard (Industry Reference)
HackMotion — the leading wrist measurement sensor — tracks three axes:
1. **Flexion / Extension** — up-down bending of wrist. Flexion = "bowed" (flat/strong at impact). Extension = "cupped" (weak at impact)
2. **Radial / Ulnar Deviation** — side-to-side hinge. Radial = "cocked" (creating lag). Ulnar = "uncocked" (releasing lag)
3. **Rotation (Pronation / Supination)** — forearm rotation

**Key data from HackMotion:**
- Tour pros add 15–20° of radial deviation at the top, then release back to starting angle by impact
- Amateurs show rapid loss of radial deviation (uncocking) early in downswing — the biomechanical signature of casting
- At impact: great players have slightly flexed (bowed) lead wrist; poor players have extended (cupped) wrist

#### Measuring from 2D Video (Our App's Approach)
- **MediaPipe Pose provides:** Shoulder, elbow, and wrist landmarks (33 body keypoints total)
- **Club shaft detection:** Needed from our YOLO/tracking model — gives club head position
- **Lag angle calculation from landmarks:**
  ```
  forearm_vector = wrist_position - elbow_position
  shaft_vector = club_head_position - wrist_position
  lag_angle = angle_between(forearm_vector, shaft_vector)
  ```
- **2D limitation — CRITICAL:** Sportsbox AI warns that a golfer can appear to have **31° in 2D front-on view but actually 72° in 3D**. The swing plane is not perpendicular to the camera, so 2D projections severely distort the true angle
- **Accuracy expectation:** ±5–10° absolute accuracy from 2D front-on video, but 2D values will systematically differ from true 3D values. **Must present as relative comparison metric between swings, NOT absolute degrees**
- **Recommendation:** Report a "Lag Score" (relative metric for comparing swings) rather than claiming accurate absolute degree measurements

#### Metric We Should Report
- **"Lag Retention Index" (LRI)** — a custom metric: the ratio of lag angle at lead-arm-parallel to lag angle at top of backswing. Higher = more lag retained
  - Tour pro typical LRI: 0.5–0.7 (retains 50–70% of set angle)
  - Casting amateur typical LRI: 0.2–0.4 (loses 60–80% early)
- **"Release Point"** — the position in the downswing arc (in degrees of arm rotation before impact) where the lag angle begins decreasing rapidly
  - Tour pro: 30–50° before impact
  - Casting amateur: 90–120° before impact (very early)
- **"Shaft Lean at Impact"** — the angle between the shaft and vertical at the moment of impact
  - Positive = hands ahead (forward lean, good)
  - Negative = club head ahead (scooping/flipping, bad)
  - Tour pro with irons: +10° to +20°

### 4.7 Audio Feedback System Design

#### Status Feedback Modes
Two modes selectable by user:
1. **Beep Mode** — distinct tonal beeps for each state (low latency, works in noisy environments)
2. **Voice Mode** — spoken words via AVSpeechSynthesizer (clearer but slightly higher latency)

#### Feedback Events and Sounds
| Event | Beep Mode | Voice Mode |
|---|---|---|
| Player detected in frame | Single low tone | "Player detected" |
| Starting pose identified / Ready | Double ascending beep | "Ready" |
| Swing captured successfully | Single bright confirmation tone | "Swing captured — [X] mph" |
| Processing complete with speed | Triple ascending beep + speed via speech | "[X] miles per hour" |
| Error: swing not detected | Descending two-tone (error pattern) | "Swing not detected, try again" |
| Error: tracking lost mid-swing | Rapid triple beep (warning) | "Tracking lost, please retry" |
| Struggling to detect start position | Slow repeating pulse tone | "Adjust position — stand in frame" |
| Calibration complete | Rising three-note chime | "Calibration complete" |

#### iOS Implementation
- **Beep tones:** Custom `.wav` or `.aif` files (short, <100ms) played via `AVAudioPlayer` or `AudioServicesPlaySystemSound` for minimum latency
- **Voice alerts:** `AVSpeechSynthesizer` with `AVSpeechUtterance` — configurable rate, pitch, voice
- **Haptic feedback:** `UINotificationFeedbackGenerator` paired with audio for tactile confirmation (success/error/warning patterns)
- **Core Haptics:** `CHHapticEngine` for custom haptic patterns synchronized with audio
- **AirPods/Bluetooth:** Audio routes automatically to connected headphones via `AVAudioSession` with `.playback` category. Set `.allowBluetooth` option. Voice mode especially valuable with AirPods — golfer hears feedback without phone screen
- **Audio session config:** Category `.playback`, mode `.voicePrompt`, options `.duckOthers` + `.interruptSpokenAudioAndMixWithOthers` — ensures feedback audio plays over any background music and ducks appropriately
- **Latency:** System sounds via AudioToolbox: <10ms. AVAudioPlayer: ~20-50ms. AVSpeechSynthesizer: ~100-200ms. All acceptable for post-event feedback

---

## 5. Key Challenges

### 5.1 Motion Blur
- At 100mph (44.7 m/s) and 240fps: club head moves **18.6cm per frame**
- At 1/240s exposure: significant motion blur streak
- The club head may appear as an elongated streak rather than a discrete object
- **Mitigation strategies:**
  - Use blur streak length and direction as speed/direction data
  - Shorter exposure time (1/1000s or faster) reduces blur but requires good lighting
  - Train detection model on motion-blurred club head images
  - Use Kalman prediction to maintain track through blurred frames

### 5.2 Impact Zone Tracking
- Maximum speed occurs at or just before impact — hardest frame to track
- Club and ball may overlap at impact
- Maximum motion blur at maximum speed
- **Mitigation:** Kalman filter predicts impact position from pre-impact trajectory. Speed curve interpolation to estimate impact speed from surrounding frames

### 5.3 Variable Lighting
- Outdoor: direct sun causes harsh shadows, backlight situations
- Indoor: artificial lighting, potentially low light
- Dusk/dawn: rapidly changing conditions
- **Mitigation:** Auto-exposure management, adaptive thresholds, model trained on varied lighting conditions

### 5.4 Club Head Occlusion
- Club goes behind body during backswing and follow-through
- Lost from view for several frames
- **Mitigation:** Kalman prediction maintains estimated position. Detect re-emergence and reconnect track. Ignore occluded frames in speed calculation

### 5.5 Perspective Distortion
- Front-on view means club head distance from camera varies throughout swing
- Top of backswing is further than impact zone
- **Mitigation:** LiDAR depth-calibrated scale adjustment. Homography correction

### 5.6 Small, Low-Contrast Target
- Club head is small (~4" wide) relative to full swing frame
- May be similar color to grass, sky, or clothing
- **Mitigation:** Reflective sticker option for practice. ML model trained specifically on club heads. Combination of motion + appearance cues

### 5.7 Battery and Thermal Management
- 240fps capture is power-intensive
- Processing each frame in real-time compounds power draw
- iPhone will thermal throttle after sustained use
- **Mitigation:** Audio-triggered capture (not continuous). Process only during swings. Allow phone cooling between sessions. Consider lower FPS (120fps) as fallback mode

### 5.8 Accuracy vs Professional Systems
- Radar systems (Trackman): ±0.5 mph accuracy
- Photometric systems (GCQuad): ±0.5 mph accuracy
- Our camera-only approach: **realistically ±3-5 mph for v1**
- **Acceptable because:** Target users are speed training golfers who need relative consistency (is this swing faster than the last?) more than absolute accuracy

---

## 6. Opportunities & Gaps

### 6.1 The Gap This App Fills
- **ShotVision attempts camera-only golf speed measurement but with poor reliability** (30-50% accuracy drop in bad lighting, missed shots). A well-engineered solution with LiDAR calibration, 240fps capture, and audio-assisted detection could significantly outperform
- Speed training golfers need a quick, free tool for repetitive swing measurement
- No external hardware to charge, connect, calibrate, or carry
- Our key differentiators vs ShotVision: LiDAR calibration for real-world scale, 240fps (not standard camera), audio swing detection for reliability, and focus on club head speed for speed training (not trying to be a full launch monitor)

### 6.2 Unique Advantages
1. **Zero additional hardware cost** — works with existing iPhone
2. **LiDAR calibration** — no other phone app uses LiDAR for measurement calibration
3. **Full speed curve** — not just impact speed, but speed throughout the entire swing arc
4. **Instant voice readout** — audio feedback without looking at screen
5. **Audio-triggered capture** — innovative approach to reduce processing load

### 6.3 Competitive Moat
- SwingVision (tennis) is the closest comparable. First-mover in golf camera-only speed tracking would be significant
- ML model trained on golf club heads is a compounding advantage over time
- LiDAR calibration is iPhone-exclusive — Android can't easily replicate

---

## 7. Recommendations for Our App

### 7.1 Core Architecture
1. **Detection approach:** Hybrid — YOLO-based club head detection for slow frames (address, backswing) + optical flow/Kalman filter for fast frames (downswing, impact)
2. **Calibration:** LiDAR-first with manual fallback. Use ARKit raycasting to establish ground plane, ball position, feet positions → compute pixels-per-metre
3. **Capture:** 240fps at 1080p via AVFoundation. Audio-triggered to minimize battery/thermal impact
4. **Speed calculation:** Frame-to-frame pixel displacement → calibrated real-world distance → speed. Kalman smoothing. Motion blur analysis as supplementary signal
5. **Impact detection:** Audio spike + maximum speed in tracked trajectory + calibrated impact zone position

### 7.2 Accuracy Strategy
- **v1 target: ±5-8 mph** with basic frame-to-frame tracking (naive approach)
- **v1.1 target: ±2-4 mph** with sub-pixel tracking + motion blur velocity estimation + Kalman smoothing
- **v2 target: ±1-3 mph** with trained ML model + sensor fusion + optional reflective marker
- **Key insight:** 1-pixel position error ≈ 0.6 mph speed error. Sub-pixel accuracy is critical
- **Key insight:** Consistency (low variance) matters more than absolute accuracy for speed training
- **WARNING:** Do NOT use AI frame interpolation (RIFE/FILM) for measurement — interpolated frames contain no new temporal information and introduce systematic bias
- **WARNING:** Do NOT rely on LiDAR for direct club tracking — 60fps at 256×192 is insufficient

### 7.3 ML Model Plan
1. Start with AICaddy's YOLOv8 club head dataset (6,000+ images) as base
2. Collect additional data: motion-blurred club heads at various speeds and lighting
3. Train custom Core ML model optimized for iPhone Neural Engine
4. Model outputs: club head bounding box + confidence score
5. Supplement with optical flow for frame-to-frame tracking

### 7.4 Audio-Based Swing Detection (NEW — from user clarification)
**Purpose:** Reduce processing power by using audio to detect swing phases instead of continuous video monitoring

**Approach:**
1. **Idle state:** Monitor audio only (very low power). Camera at standby
2. **Swing onset detection:** Detect the characteristic "whoosh" sound of downswing using audio onset detection (spectral analysis, energy thresholding)
3. **Trigger capture:** On audio swing detection → activate 240fps camera capture
4. **Phase segmentation from audio:**
   - Backswing: quiet or faint sound
   - Transition: brief pause in sound
   - Downswing: increasing whoosh (frequency and amplitude rise)
   - Impact: sharp transient spike (if hitting a ball)
   - Follow-through: declining whoosh
5. **Swing completion:** Audio energy returns to ambient baseline → stop capture
6. **Power savings:** Only capture video during actual swings (~1-2 seconds) vs continuous monitoring. Could reduce camera-on time by 90%+

**Feasibility Assessment: HIGHLY FEASIBLE — commercially proven**
- Swing Catalyst already ships a microphone-based capture trigger for golf video recording
- Cricket's Snickometer has used acoustic impact detection in professional broadcasting for 20+ years
- Impact detection: **95%+ confidence** — sharp transient at 2-5kHz, trivial onset detection
- Downswing onset: **85-90% confidence** — rising broadband whoosh gives 200-500ms warning before impact
- Follow-through completion: **70-80% confidence** — energy decay below threshold
- **Backswing detection: NOT feasible via audio** — too quiet. Needs IMU or vision for backswing start
- **iOS toolkit:** AVAudioEngine + SoundAnalysis framework + CoreML — complete pipeline, no third-party dependencies
- **Recommended detector:** Two-stage — RMS energy threshold first, spectral/ML confirmation second
- **Challenge:** Outdoor wind noise. **Mitigation:** High-pass filtering, spectral discrimination, lightweight CoreML classifier trained on golf sounds via CreateML

**Impact Timing Precision:**
- Audio impact detection provides ~1ms timing precision vs 4.17ms per video frame at 240fps
- This makes audio the best sensor for identifying the exact impact moment
- Combining audio impact timing with video tracking gives more accurate impact speed extraction

**Microphone Considerations:**
- iPhone mic: 48kHz sample rate, 24-bit depth, usable to 20kHz — adequate for all swing sounds
- **Risk:** Golf ball impact peak SPL can reach ~127 dB — may clip iPhone microphone. Need to manage gain levels or use measurement mode
- Round-trip audio latency: ~5-10ms in measurement mode

**Patent Note:** US Patent 10,391,358 B2 claims calculating swing speed from microphone-detected sound — potential IP consideration. Our approach uses audio for swing *detection* and *timing*, not speed *calculation*, which may differ sufficiently.

**Power/Processing Comparison:**
| Mode | CPU Load | Battery Impact |
|---|---|---|
| Continuous 240fps video + processing | Very High | ~2-3 hours max |
| Audio monitoring only | Very Low (~100-300mW) | ~12+ hours |
| Audio-triggered 240fps capture | Low → High during swing (~100-300mW idle, 2-4W active) | ~6-8 hours estimated |

### 7.5 Phased Development
1. **Phase 1 (Prototype):** Basic 240fps capture + manual frame selection + manual calibration (tap reference points)
2. **Phase 2 (Core):** YOLO club head detection + Kalman tracking + LiDAR calibration + auto swing detection (motion-based)
3. **Phase 3 (Accuracy):** Motion blur analysis + sensor fusion + trained ML model + audio swing detection
4. **Phase 4 (Polish):** Voice readout + swing history + speed comparison + confidence scoring

---

## 8. Comparison Table

| Product | Category | Price | Tech Type | Camera-Based? | FPS Used | Club Speed? | Full Metrics | Hardware Needed | Accuracy | Platform |
|---|---|---|---|---|---|---|---|---|---|---|
| Trackman 4 | Pro Launch Monitor | $20,000+ | Dual Doppler Radar + Camera | Partial (camera + radar) | 4,600fps | Yes | 40+ metrics | Dedicated unit | ±0.5 mph | Proprietary |
| GCQuad | Pro Launch Monitor | $12,000+ | 4-Camera Photometric + IR | Yes | High-speed (proprietary) | Yes | Full | Dedicated unit | ±0.5 mph | Proprietary |
| GC3 | Pro Launch Monitor | $5,000+ | 3-Camera Photometric + IR | Yes | High-speed (proprietary) | Yes | Full | Dedicated unit | ±0.5 mph | Proprietary |
| FlightScope X3 | Pro Launch Monitor | $10,000+ | 3D Doppler Radar | No | N/A | Yes | Full | Dedicated unit | ±0.5 mph | Proprietary |
| Uneekor EYE XO2 | Pro Launch Monitor | $5,000+ | 3 IR Cameras (overhead) | Yes | High-speed (proprietary) | Yes | Full | Overhead mount | ±0.5 mph | Indoor only |
| Swing Catalyst | Biomechanics | $10,000+ | Force plates + 500fps cameras | Yes | 320-500fps | Indirect | Body kinematics | Force plates + cameras | N/A | Indoor |
| Mevo+ | Consumer Monitor | $2,000 | Doppler Radar + Camera | Partial | N/A | Yes | 20+ | Dedicated unit | Good | iOS/Android |
| SkyTrak+ | Consumer Monitor | $2,500 | Dual Radar + Photometric | Partial | N/A | Yes | 15+ | Dedicated unit | ±5% of premium | iOS/Android |
| Garmin R10 | Consumer Monitor | $600 | Doppler Radar | No | N/A | Yes | 14 (5 measured) | Dedicated unit | ±5 yards carry | iOS/Android |
| Rapsodo MLM2PRO | Consumer Monitor | $700 | Dual Camera + Radar | Yes | 240fps | Yes | 15 | Dedicated unit | Good | iOS/Android |
| Voice Caddie SC300i | Consumer Monitor | $400 | Doppler Radar | No | N/A | Yes | 6 | Dedicated unit | ±2% ball speed | iOS/Android |
| Ernest Sports ES16 | Consumer Monitor | $3,500 | Quad Radar + Dual Camera | Partial | N/A | Yes | 15+ | Dedicated unit | Good | iOS/Android |
| OptiShot 2 | Simulator | $300 | 16 IR Sensors | No | N/A | Yes | Basic | Sensor mat | ±2 mph (claimed) | Windows |
| SwingVision | Tennis App | $15/mo | iPhone Camera + ML | Yes | Standard | Yes (ball) | Shot stats | None (iPhone only) | Good | iOS |
| V1 Golf | Golf App | $10/mo | Video Analysis | Video only | Standard | No | None | None | N/A | iOS/Android |
| **Our App** | **Golf App** | **Free** | **iPhone Camera + LiDAR + Audio** | **Yes** | **240fps** | **Yes** | **Speed curve** | **None (iPhone only)** | **±3-5 mph (target)** | **iOS** |

---

## 9. Additional Technology Exploration

### 9.1 Sensor Fusion (Camera + LiDAR + IMU + Audio)
- **Camera:** Primary speed measurement via club head tracking
- **LiDAR:** Scene calibration and pixel-to-real-world mapping
- **IMU (accelerometer/gyroscope):** Detect if phone is moving during capture; compensate for any camera motion
- **Audio:** Swing detection, phase segmentation, impact moment identification
- Combining all four sensors could provide more robust measurement than any single sensor

### 9.2 Reflective Markers (Optional Enhancement)
- Small reflective sticker on club head (legal for practice, not competition)
- Dramatically improves detection reliability — high contrast against any background
- Uneekor EYE XO2 uses similar approach (reflective club stickers for full data)
- Could be offered as optional "accuracy boost" accessory

### 9.3 Dual Camera Capture
- `AVCaptureMultiCamSession` enables simultaneous wide + telephoto capture
- Wide camera: full swing arc tracking
- Telephoto camera: detailed impact zone view
- Potential for improved accuracy at impact where it matters most
- **Risk:** May not support 240fps on both cameras simultaneously — needs testing

### 9.4 Edge-Device ML Inference
- iPhone Neural Engine: 15.8 TOPS (A16), 35 TOPS (A17 Pro)
- Core ML can run YOLO models at 30-60fps
- For 240fps processing, may need lighter model or process every Nth frame
- **Recommended:** Run detection at 60fps (every 4th frame at 240fps capture), interpolate positions between detected frames using Kalman filter

---

*Research completed March 2026. Sources include manufacturer websites, academic papers (ArXiv, ResearchGate, Springer, MDPI), GitHub repositories, Apple Developer documentation, and golf technology review sites.*

*See also: `OPEN_SOURCE_RESEARCH.md` for an expanded catalogue of 50+ open source projects, datasets, and reference implementations.*

*See also: `RESEARCH_AUDIO_ANALYSIS.md` for detailed audio/acoustic analysis including Strouhal relationship, impact acoustics research (Shannon & Axe 2002, Roberts et al. 2005-2006), and iPhone microphone specifications.*

*See also: `IPHONE_HARDWARE_RESEARCH.md` for detailed iPhone LiDAR sensor specs (VCSEL/SPAD), camera pipeline architecture, Neural Engine benchmarks, Vision framework APIs, and thermal management analysis.*

*See also: `ADVANCED_CV_RESEARCH.md` for deep dive on motion blur as speed signal, sub-pixel tracking (1/10 pixel accuracy), frame interpolation (RIFE synthetic 960fps), reflective markers, sensor fusion via Extended Kalman Filter, and detailed accuracy tier analysis.*

*See also: `research/consumer_launch_monitor_report.md` for expanded consumer launch monitor analysis with measured vs calculated metric distinctions, detailed technology comparison table, and sensor fusion approaches.*

*See also: `COMPETITOR_RESEARCH.md` for detailed smartphone app competitor analysis including ShotVision (direct competitor), SwingVision technical details (Tesla Autopilot CV founder, ICC validation data), simulator platforms, and GPS/wearable comparison.*

*See also: `RESEARCH_CV_TECHNIQUES.md` for 19 academic papers cited, 9 CV techniques analyzed for club head tracking, worked speed calculation examples (89 pixels/frame at 240fps vs 715 at 30fps), swing detection automation pipeline, and SGU phone-camera vs radar comparison study.*

*See also: `LAUNCH_MONITOR_RESEARCH.md` for expanded pro launch monitor analysis (15+ products, 7 families) with specific patent numbers, academic validation studies with PMIDs, FlightScope vs TrackMan patent dispute, Foresight Spherical Correlation technology, and full patent landscape.*

*See also: `ACCURACY_RESEARCH.md` for refined accuracy tiers, motion blur velocity estimation (BlurBall 2025 paper), sub-pixel tracking techniques, warnings against frame interpolation for measurement, and the 1-pixel = 0.6 mph error relationship.*
