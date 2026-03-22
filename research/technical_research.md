# Technical Research: iPhone LiDAR, High-FPS Camera & Golf Swing Analysis

---

## 1. iPhone LiDAR Sensor

### 1.1 How iPhone LiDAR Works (dToF, VCSEL, SPAD)

The iPhone LiDAR is a **direct Time-of-Flight (dToF)** system with three core components:

**VCSEL Emitter (Vertical-Cavity Surface-Emitting Laser):**
- Bottom-emitting VCSEL light source operating at **940nm** (near-infrared)
- iPhone 12/13 Pro: 16 stacks of 4 VCSEL cells = 64 total, multiplied by a 3x3 diffraction optical element (DOE) to produce **576 laser pulses**
- iPhone 15 Pro: Redesigned module that reduces active die area by over a third and eliminates diffractive optics
- VCSELs are ideal for mobile: small dimensions, good power efficiency, narrow wavelength bandwidth

**SPAD Receiver (Single-Photon Avalanche Diode):**
- 940nm-enhanced SPAD image sensor with onboard distance calculation logic
- Capable of detecting **single-photon signals** with resolution of tens of picoseconds
- Each reflected pulse's time-of-flight is measured individually

**dToF Principle:**
- System projects a structured pattern across the scene
- Measures the round-trip time of each laser pulse
- Calculates depth = (speed of light x time) / 2

Sources:
- [Apple LIDAR Demystified: SPAD, VCSEL, and Fusion (Medium)](https://4sense.medium.com/apple-lidar-demystified-spad-vcsel-and-fusion-aa9c3519d4cb)
- [iPhone LiDAR Characterization (MDPI Sensors)](https://www.mdpi.com/1424-8220/23/18/7832)
- [VCSELs Put LiDAR into Apple iPhones (DigiKey)](https://www.digikey.com/en/blog/vcsels-put-lidar-into-apple-iphones-what-can-you-do)
- [iPhone 12 Pro LiDAR Evaluation (Nature Scientific Reports)](https://www.nature.com/articles/s41598-021-01763-9)
- [Yole Group iPhone 15 Pro LiDAR Module Report](https://www.yolegroup.com/product/report/iphone-15-pro-lidar-module/)

### 1.2 Accuracy, Refresh Rate, Point Cloud Density

| Specification | Value |
|---|---|
| **Maximum Range** | 5 metres |
| **Depth Map Resolution** | 256 x 192 pixels (~49,000 depth points/frame) |
| **Refresh Rate** | Up to 60 Hz |
| **Absolute Accuracy** | +/- 1 cm for objects >10 cm side length |
| **Point Density at 25 cm** | ~7,225 points/m^2 |
| **Point Density at 250 cm** | ~150 points/m^2 |
| **Minimum Detectable Object** | ~5 cm side length |
| **Wavelength** | 940 nm (near-infrared) |

**Key accuracy notes:**
- Accuracy and precision increase with object size in all directions
- Precision decreases when scanning surfaces under 10 cm side length
- Errors accumulate with distance; accuracy degrades beyond ~2-3 metres
- Under real-world conditions with scanning best practices, measurements are within 1-2% accuracy
- Drift accumulates over time during sustained scanning sessions

Sources:
- [iPhone 12 Pro LiDAR Geosciences Evaluation (Nature)](https://www.nature.com/articles/s41598-021-01763-9)
- [iPhone LiDAR Accuracy for Streambeds (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12526706/)
- [Apple Developer Forums: LiDAR Specifications](https://developer.apple.com/forums/thread/812600)
- [LiDAR on iPhone Accuracy (Scan Manifold)](https://www.scanmanifold.com/blog-posts/lidar-on-iphone-how-accurate-is-it-plus-the-biggest-errors-that-manifold-corrects)

### 1.3 ARKit Depth Sensing APIs

**Core APIs:**

1. **Scene Depth (`ARFrame.sceneDepth`):**
   - Every `ARFrame` includes an `ARDepthData` object with two buffers:
     - **Depth map** (each pixel = depth in metres from camera)
     - **Confidence map** (per-pixel confidence: low/medium/high)
   - Enable via: `ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth)`

2. **Scene Reconstruction (Mesh):**
   - Triangle mesh representing topological mapping of the environment
   - Built by fusing LiDAR depth data with on-device ML
   - Optional semantic classification (floor, wall, ceiling, table, seat, window, door)
   - Access via `ARMeshAnchor` objects in the session

3. **Raycasting:**
   - `ARSession.raycast()` — cast rays into the real world
   - LiDAR improves raycasting with `estimatedPlane` targets
   - Highly optimized for object placement
   - Works without visible feature points (unlike camera-only AR)

4. **Point Cloud:**
   - Direct access to 3D point cloud via `ARFrame.rawFeaturePoints`
   - LiDAR-enhanced point clouds are denser and more accurate

Sources:
- [Apple: Visualizing and Interacting with a Reconstructed Scene](https://developer.apple.com/documentation/arkit/visualizing-and-interacting-with-a-reconstructed-scene)
- [Apple: Displaying a Point Cloud Using Scene Depth](https://developer.apple.com/documentation/ARKit/displaying-a-point-cloud-using-scene-depth)
- [Explore ARKit 4 (WWDC20)](https://developer.apple.com/videos/play/wwdc2020/10611/)
- [Advanced Scene Understanding in AR (Apple Tech Talk)](https://developer.apple.com/videos/play/tech-talks/609/)

### 1.4 LiDAR for Real-World Measurement Calibration

**Built-in calibration:**
- RGB-to-LiDAR calibration is handled internally by the scanning application
- Fuses depth and image data in real time using built-in algorithms
- Intrinsic and extrinsic camera parameters accessible via `ARCamera`

**Measurement accuracy by use case:**
- Static linear readings: 1-2 cm off
- Area measurements: ~1 m^2 accuracy
- With best practices: within 1-2% verified against tape measure

**Key limitations for calibration:**
- Drift accumulates over time (biggest source of error)
- Each subsequent scan multiplies the error
- Horizontal surfaces less accurate than vertical
- Reflective/transparent surfaces cause errors
- Sufficient for architectural planning but not mm-level engineering

Sources:
- [Canvas FAQ: Accuracy Expectations](https://support.canvas.io/article/5-what-kind-of-accuracy-can-i-expect-from-canvas)
- [iPhone 13 Pro LiDAR for Engineering (Conference Paper)](https://conferences.lib.unb.ca/index.php/tcrc/article/view/645)

### 1.5 LiDAR + Camera Simultaneous Capture

**Synchronized RGB-D capture:**
- ARKit automatically provides synchronized RGB and depth data per frame
- RGB frame: **1920 x 1440** resolution
- Depth map: **192 x 256** resolution (co-registered with RGB)
- Both captured at **60 Hz** sampling frequency
- IMU data also synchronized in each `ARFrame`

**Implementation:**
- Use `ARWorldTrackingConfiguration` with `.sceneDepth` frame semantics
- Each `ARFrame` contains: RGB image + depth map + confidence map + camera transform + IMU data
- No manual synchronization needed; ARKit handles temporal alignment

**Data streaming:**
- RGB-D + IMU data can be streamed via WebSocket for external processing
- Projects like ARKit-Scanner demonstrate saving synchronized color, depth, and IMU data

Sources:
- [iPhone 12 Pro LiDAR Data Guide (it-jim)](https://www.it-jim.com/blog/iphones-12-pro-lidar-how-to-get-and-interpret-data/)
- [ARKit-Scanner (GitHub)](https://github.com/xiongyiheng/ARKit-Scanner)
- [WebSocket LiDAR Streaming (DEV Community)](https://dev.to/jaskirat1616/i-built-a-websocket-server-to-stream-iphone-lidar-and-imu-data-20lp)

### 1.6 iPhone Models with LiDAR

| Model | Year | LiDAR |
|---|---|---|
| iPhone 12 Pro / Pro Max | 2020 | Yes |
| iPhone 13 Pro / Pro Max | 2021 | Yes |
| iPhone 14 Pro / Pro Max | 2022 | Yes |
| iPhone 15 Pro / Pro Max | 2023 | Yes (redesigned sensor) |
| iPhone 16 Pro / Pro Max | 2024 | Yes |
| iPhone 17 Pro / Pro Max | 2025 | Yes |

**Note:** Standard iPhone models (non-Pro), Plus models, and the iPhone 16e do NOT have LiDAR. It remains a **Pro-exclusive feature**.

iPad models with LiDAR: iPad Pro 11" (2nd gen+), iPad Pro 12.9" (4th gen+).

Source: [Which iPhones Have LiDAR (KnowYourMobile)](https://www.knowyourmobile.com/phones/which-iphones-have-lidar/)

---

## 2. iPhone High-FPS Camera

### 2.1 240fps Capture Capabilities by Model

| Model | Max Slow-Mo | Resolution at 240fps |
|---|---|---|
| iPhone 6 / 6 Plus | 240 fps | 720p |
| iPhone 6s / 6s Plus / 7 / 7 Plus | 240 fps | 720p |
| iPhone 8 / 8 Plus / X | 240 fps | **1080p** |
| iPhone XS / XR / 11 series | 240 fps | 1080p |
| iPhone 12 series | 240 fps | 1080p |
| iPhone 13 series | 240 fps | 1080p |
| iPhone 14 series | 240 fps | 1080p |
| iPhone 15 series | 240 fps | 1080p |
| iPhone 16 series | 240 fps | 1080p |

**Key notes:**
- 1080p @ 240fps available from iPhone 8 onwards
- 120fps available at 1080p on all modern iPhones
- 4K recording maxes out at 60fps (no 4K slow-mo)
- 240fps requires HEVC codec for recording
- Cinematic mode (with depth) limited to lower frame rates

Sources:
- [Apple Support: Video Recording Settings](https://support.apple.com/guide/iphone/change-video-recording-settings-iphc1827d32f/ios)
- [Apple Developer: Camera Compatibility](https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Cameras/Cameras.html)
- [iOS Tutorial: Developing with 240 FPS](http://taylorfranklin.me/2015/01/20/ios-tutorial-developing-240-fps/)

### 2.2 AVFoundation APIs for High-FPS Capture

**Core pipeline:**

```
AVCaptureSession
  ├── AVCaptureDeviceInput (camera)
  └── AVCaptureVideoDataOutput (frame delegate)
        └── AVCaptureVideoDataOutputSampleBufferDelegate
              └── captureOutput(_:didOutput:from:)  → CMSampleBuffer
```

**Key steps for 240fps capture:**
1. Find an `AVCaptureDeviceFormat` whose `videoSupportedFrameRateRanges` includes 240 FPS
2. Lock device for configuration
3. Set `activeFormat` to the matching format
4. Set `activeVideoMinFrameDuration = CMTimeMake(1, 240)`
5. Set `activeVideoMaxFrameDuration = CMTimeMake(1, 240)`
6. Disable smooth auto-focus if supported

**Real-time frame processing:**
- Implement `AVCaptureVideoDataOutputSampleBufferDelegate`
- Frames delivered as `CMSampleBuffer` on a dedicated serial dispatch queue
- Convert to `CVPixelBuffer` for Core ML / Vision processing
- Must process fast enough to avoid dropped frames

**iOS 17-18 enhancements:**
- `CaptureService` actor manages `AVCaptureSession` asynchronously
- Zero Shutter Lag, Deferred Photo Processing
- Responsive Capture APIs for reduced latency

Sources:
- [Apple TN2409: Camera Features for iPhone 6](https://developer.apple.com/library/archive/technotes/tn2409/_index.html)
- [Apple: Still and Video Media Capture](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/04_MediaCapture.html)
- [Create a More Responsive Camera Experience (WWDC23)](https://developer.apple.com/videos/play/wwdc2023/10105/)
- [Capturing Video on iOS (objc.io)](https://www.objc.io/issues/23-video/capturing-video/)

### 2.3 Resolution vs Frame Rate Trade-offs

| Resolution | Max FPS | Codec | Storage/min | Notes |
|---|---|---|---|---|
| 4K (3840x2160) | 60 fps | HEVC | ~400 MB | Best quality, most storage |
| 4K (3840x2160) | 30 fps | H.264 | ~350 MB | Compatible codec |
| 1080p (1920x1080) | 240 fps | HEVC | ~200 MB | Slow motion |
| 1080p (1920x1080) | 120 fps | HEVC | ~150 MB | Slow motion |
| 1080p (1920x1080) | 60 fps | H.264/HEVC | ~175 MB | Standard |
| 720p (1280x720) | 240 fps | H.264 | ~100 MB | Legacy slow-mo |

**Key trade-offs:**
- Higher FPS = more light needed (shorter exposure per frame)
- 240fps produces noticeably lower image quality than 30/60fps
- At 240fps, motion blur is minimal (good for tracking fast objects)
- HEVC required for highest data rate formats (1080p240)
- No 4K at >60fps on any current iPhone

Sources:
- [Best iPhone Video Settings (VideoProc)](https://www.videoproc.com/iphone-video-processing/best-iphone-video-quality-settings.htm)
- [Resolution and Frame Rate (Freefly)](https://freeflysystems.com/knowledge-base/resolution-and-frame-rate-fps)

### 2.4 Real-Time Frame Processing Pipeline

**Architecture for real-time ML inference on camera frames:**

```
Camera (240fps) → AVCaptureVideoDataOutput
    → CMSampleBuffer → CVPixelBuffer
        → VNImageRequestHandler (Vision framework)
            → VNCoreMLRequest (Core ML model)
                → Process results
```

**Key considerations:**
- At 240fps, each frame must be processed in < 4.17ms to avoid drops
- Typically process every Nth frame (e.g., every 4th = effective 60fps inference)
- Use `alwaysDiscardsLateVideoFrames = true` to prevent queue backlog
- Process on a dedicated serial dispatch queue (not main thread)
- Use `CVPixelBuffer` directly to avoid copies
- Vision framework handles image preprocessing (resize, normalize) for Core ML

**Optimization strategies:**
- Run ML model on Neural Engine (fastest for most models)
- Use quantized models (Int8) for faster inference
- Pipeline: capture on one queue, ML on another, UI updates on main thread
- Consider `VNTrackObjectRequest` for built-in object tracking

### 2.5 Thermal Throttling During Sustained Capture

**General behaviour:**
- iPhones throttle CPU/GPU when internal temperature exceeds thresholds
- Sustained 240fps recording generates significant heat
- Recording may stop automatically if overheating is detected

**By generation:**
- **iPhone 12-14 Pro:** Thermal throttling noticeable during sustained 4K60 recording; 240fps generates less heat (lower resolution) but still throttles after several minutes
- **iPhone 15 Pro:** Improved thermal management but still throttles under sustained load
- **iPhone 16 Pro:** Better thermal architecture
- **iPhone 17 Pro:** Apple-designed laser-welded vapor chamber; GPU and CPU deliver up to **40% better sustained performance**

**Mitigation strategies:**
- Remove phone case during capture
- Avoid direct sunlight
- Keep capture sessions short (< 5 minutes for 240fps)
- Monitor `ProcessInfo.thermalState` in code (.nominal / .fair / .serious / .critical)
- Gracefully reduce frame rate or stop capture when thermal state degrades

Sources:
- [iPhone 17 Pro Thermal Design (Apple)](https://www.apple.com/iphone-17-pro/)
- [Thermal Throttling in Smartphones (XDA)](https://www.xda-developers.com/silent-killer-of-your-phones-performance-thermal-throttling/)

### 2.6 Neural Engine / Core ML for Real-Time Inference

**Neural Engine specs by chip:**

| Chip | Device | Neural Engine Cores | TOPS |
|---|---|---|---|
| A14 Bionic | iPhone 12 | 16 | 11 |
| A15 Bionic | iPhone 13 | 16 | 15.8 |
| A16 Bionic | iPhone 14 Pro | 16 | 17 |
| A17 Pro | iPhone 15 Pro | 16 | 35 |
| A18 / A18 Pro | iPhone 16 | 16 | 35+ |
| A19 Pro | iPhone 17 Pro | 16 | ~38+ |

**Real-time object detection performance:**
- **YOLO11** on Neural Engine: 60+ FPS for live video, 53.4% mAP on COCO
- **RF-DETR**: First real-time model to exceed 60 mAP on domain adaptation benchmarks
- **YOLOv3 Tiny**: Up to 358 FPS (golf ball detection benchmark)
- A17 Pro: increased throughput for Int8-Int8 compute on Neural Engine

**Core ML optimization tips:**
- Use `MLComputeUnits.all` to let Core ML auto-select CPU/GPU/Neural Engine
- Quantize models to Int8 for significant Neural Engine speedups
- Use `MLModelConfiguration` to specify compute preference
- Neural Engine is 4.3x faster than GPU for certain hybrid models (Parakeet v3 benchmark)

Sources:
- [Core ML Overview (Apple Developer)](https://developer.apple.com/machine-learning/core-ml/)
- [iPhone 17 On-Device Inference Benchmarks (Argmax)](https://www.argmaxinc.com/blog/iphone-17-on-device-inference-benchmarks)
- [Best iOS Object Detection Models (Roboflow)](https://blog.roboflow.com/best-ios-object-detection-models/)
- [Core ML Performance Benchmark 2023 (Photoroom)](https://www.photoroom.com/inside-photoroom/core-ml-performance-benchmark-2023-edition)

---

## 3. Open Source Projects

### 3.1 Golf Swing Analysis

| Project | Description | Tech Stack | Link |
|---|---|---|---|
| **GolfDB / SwingNet** | Video database for golf swing sequencing; detects 8 swing events. Baseline CNN model (SwingNet) trained on 1400+ pro swing videos. | PyTorch, CNN | [github.com/wmcnally/golfdb](https://github.com/wmcnally/golfdb) |
| **AICaddy** | YOLOv8 model trained on 6000+ images of golf club heads (drivers) for swing tracing | YOLOv8, Python | [github.com/oswinkil-git/AICaddy-A-Golf-Club-Tracer](https://github.com/oswinkil-git/AICaddy-A-Golf-Club-Tracer) |
| **Golf Swing Analysis (MediaPipe)** | Swing analysis using MediaPipe Pose + OpenCV for motion tracking and posture evaluation | MediaPipe, OpenCV, Python | [github.com/HeleenaRobert/golf-swing-analysis](https://github.com/HeleenaRobert/golf-swing-analysis) |
| **Pose Estimation for Swing Improvement** | Advanced pose estimation for swing analysis using MediaPipe (33 keypoints) | MediaPipe, Python | [github.com/Strojove-uceni/23206-final-pose-estimation-for-swing-improvement](https://github.com/Strojove-uceni/23206-final-pose-estimation-for-swing-improvement) |
| **analyze.golf** | Browser-based swing analyzer; fully client-side video playback | React, Redux, Tailwind, Konva.js | [github.com/tlouth19/analyze.golf](https://github.com/tlouth19/analyze.golf) |
| **GolfTracker** | Mobile-style golf pro tracker for swing visualization | Python | [github.com/rlarcher/GolfTracker](https://github.com/rlarcher/GolfTracker) |
| **Golf Ball Tracking & Speed Detection** | Tracks golf ball and calculates putt speed | Python, OpenCV | [github.com/natterman12/Golf-Ball-Tracking-and-Speed-Detection](https://github.com/natterman12/Golf-Ball-Tracking-and-Speed-Detection) |
| **Simple Golf Simulator** | Calculates club swing, launch speed, and ball flight trajectory | Physics simulation | [github.com/markccchiang/Simple-Golf-Simulator](https://github.com/markccchiang/Simple-Golf-Simulator) |

### 3.2 PiTrac - DIY Golf Launch Monitor (Key Project)

**The most relevant open-source golf launch monitor project.**

- **What:** World's first free open-source golf launch monitor
- **How:** Uses Raspberry Pi computers with high-speed IR strobe-based image capture
- **Measures:** Ball launch speed, angles, and spin in 3 axes
- **Hardware cost:** ~$250 (two Pi computers + cameras + custom PCB)
- **Simulator support:** GSPro and E6/TruGolf
- **Status:** Active development, community-driven

GitHub: [github.com/PiTracLM/PiTrac](https://github.com/PiTracLM/PiTrac)
Website: [pitraclm.github.io/PiTrac](https://pitraclm.github.io/PiTrac/)
Hackaday: [hackaday.io/project/195042-pitrac-the-diy-golf-launch-monitor](https://hackaday.io/project/195042-pitrac-the-diy-golf-launch-monitor)

### 3.3 Sports Object Tracking

| Project | Description | Tech Stack | Link |
|---|---|---|---|
| **Roboflow Sports** | Open-source tools for sports analytics; ball tracking, player detection | YOLO, Python | [github.com/roboflow/sports](https://github.com/roboflow/sports) |
| **TrackNet** | Deep learning network for tracking high-speed tiny objects in sports. VGG16 encoder + DeconvNet decoder. 99.7% precision on tennis balls. | PyTorch | [github.com/yastrebksv/TrackNet](https://github.com/yastrebksv/TrackNet) |
| **Tennis Tracking (HawkEye)** | Monocular HawkEye system for tennis using TrackNet | Python, OpenCV | [github.com/ArtLabss/tennis-tracking](https://github.com/ArtLabss/tennis-tracking) |
| **FootAndBall** | Deep NN detector for ball and players in soccer videos | PyTorch | [github.com/jac99/FootAndBall](https://github.com/jac99/FootAndBall) |
| **Sports Object Detection** | Object detection and tracking in sports videos using TrackNet II | Python | [github.com/MichlF/sports_object_detection](https://github.com/MichlF/sports_object_detection) |
| **Ball Tracking (Generic)** | Tracks balls in flight using color filtering + k-means clustering | Python, OpenCV | [github.com/NattyBumppo/Ball-Tracking](https://github.com/NattyBumppo/Ball-Tracking) |
| **Golf Ball Detection (rucv)** | Golf ball detection using CNNs and Kalman filters | Python, Deep Learning | [github.com/rucv/golf_ball](https://github.com/rucv/golf_ball) |

**TrackNet architecture detail** (highly relevant for tracking fast objects):
- Input: Multiple consecutive frames (640x360)
- Architecture: VGG16 feature extraction + DeconvNet spatial localization
- Output: Gaussian heatmap centered on object position
- Learns both object appearance AND trajectory patterns
- Can detect occluded objects by predicting from trajectory
- Performance: 99.7% precision, 97.3% recall, 98.5% F1

Paper: [TrackNet (arXiv:1907.03698)](https://arxiv.org/abs/1907.03698)

### 3.4 Camera-Based Speed Measurement

| Project | Description | Tech Stack | Link |
|---|---|---|---|
| **pageauc/speed-camera** | Object speed camera using OpenCV motion tracking; calibration-based pixel-to-real-world conversion | Python, OpenCV, Raspberry Pi | [github.com/pageauc/speed-camera](https://github.com/pageauc/speed-camera) |
| **Speed-Camera (Optical Flow)** | Measures speed of moving objects using Optical Flow | Python, OpenCV | [github.com/Souvikray/Speed-Camera](https://github.com/Souvikray/Speed-Camera) |
| **Vehicle Speed Estimation** | Uses projective geometry and evolutionary camera calibration | Python, OpenCV, SciPy | [github.com/hector6298/EVOCamCal-vehicleSpeedEstimation](https://github.com/hector6298/EVOCamCal-vehicleSpeedEstimation) |
| **ITS2017 Vehicle Speed** | Vehicle detection and speed estimation from side-view camera | Python, OpenCV, scikit-learn | [github.com/Lab-Work/ITS2017_Validation](https://github.com/Lab-Work/ITS2017_Validation) |
| **Speed Object Detection Camera** | RTSP stream speed measurement with object recognition | Python | [github.com/julbov/Speed-object-detection-camera](https://github.com/julbov/Speed-object-detection-camera) |

**Common approaches:**
- YOLOv4/v8 for detection + DeepSORT for tracking
- OpenCV `getPerspectiveTransform` for perspective correction
- Calibration procedure to convert pixel displacement to real-world distance
- Speed = (real-world distance between frames) / (time between frames)

Source: [How to Estimate Speed with Computer Vision (Roboflow)](https://blog.roboflow.com/estimate-speed-computer-vision/)

### 3.5 ARKit / LiDAR Measurement Projects

| Project | Description | Link |
|---|---|---|
| **SwiftUI-LiDAR** | SwiftUI app for 3D scanning with LiDAR; exports .OBJ files | [github.com/cedanmisquith/SwiftUI-LiDAR](https://github.com/cedanmisquith/SwiftUI-LiDAR) |
| **ExampleOfiOSLiDAR** | Comprehensive LiDAR examples: depth map, confidence, collision detection, .obj export | [github.com/TokyoYoshida/ExampleOfiOSLiDAR](https://github.com/TokyoYoshida/ExampleOfiOSLiDAR) |
| **ARKit-Scanner** | RGB-D scanner using LiDAR; saves color, depth, IMU to disk; uploads to PC | [github.com/xiongyiheng/ARKit-Scanner](https://github.com/xiongyiheng/ARKit-Scanner) |
| **LiDARKit** | Swift library for capturing, processing, visualizing LiDAR point clouds | [github.com/tyang-gauntlet/LiDARKit](https://github.com/tyang-gauntlet/LiDARKit) |
| **ios-depth-point-cloud** | Save depth data and export point clouds; based on WWDC20 sample code | [github.com/Waley-Z/ios-depth-point-cloud](https://github.com/Waley-Z/ios-depth-point-cloud) |
| **iPadLIDARScanExport** | Export OBJ files from ARKit 3.5 LiDAR scans | [github.com/zeitraumdev/iPadLIDARScanExport](https://github.com/zeitraumdev/iPadLIDARScanExport) |
| **MeasureARKitPusher** | AR measurement app that sends measurements in realtime via Pusher | [github.com/eh3rrera/MeasureARKitPusher](https://github.com/eh3rrera/MeasureARKitPusher) |
| **iOS LiDAR Mesh** | Generates and displays LiDAR mesh data | [github.com/ximhear/ios-lidar-mesh](https://github.com/ximhear/ios-lidar-mesh) |

### 3.6 Golf Club Head Detection Datasets

| Resource | Description | Link |
|---|---|---|
| **Roboflow: golf-club-tracking** | Annotated dataset (TXT + YAML) for golf club head detection, compatible with YOLOv5/v7/v8/v9/v11 | [universe.roboflow.com/club-head-tracking/golf-club-tracking](https://universe.roboflow.com/club-head-tracking/golf-club-tracking/dataset/2) |
| **AICaddy dataset** | 6000+ annotated images of golf club heads (drivers) used for YOLOv8 training | [github.com/oswinkil-git/AICaddy-A-Golf-Club-Tracer](https://github.com/oswinkil-git/AICaddy-A-Golf-Club-Tracer) |
| **GolfDB** | 1400+ annotated golf swing videos with 8-event labels | [github.com/wmcnally/golfdb](https://github.com/wmcnally/golfdb) |

**Key challenge noted across projects:** Golf club heads move extremely fast and are heavily motion-blurred in most frames, making detection significantly harder than ball tracking.

### 3.7 Hardware-Based Golf Tracking

| Project | Description | Link |
|---|---|---|
| **ClubMaster** | Arduino Nano + LSM6DSOX IMU for measuring swing speed, angle, acceleration; data sent to Arduino IoT Cloud | [github.com/Concept-Bytes/ClubMaster](https://github.com/Concept-Bytes/ClubMaster) |
| **SwingMonitorApp** | Apple Watch app to detect golf swings and record accelerometer/gyroscope data | [github.com/robandrews/SwingMonitorApp](https://github.com/robandrews/SwingMonitorApp) |
| **ronheywood/opencv** | Experiments using OpenCV/Python for a golf launch monitor similar to SkyTrak/GC2/GCQuad | [github.com/ronheywood/opencv](https://github.com/ronheywood/opencv) |

---

## 4. Key Takeaways for Golf Swing Speed App

### LiDAR Feasibility
- **Range:** 5m max is adequate for a golfer standing 2-3m away
- **Refresh rate:** 60 Hz is far too slow for direct club head tracking (need 240+ Hz)
- **Best use:** Calibrate known distances in the scene (e.g., tee position, ball position) to create a reference frame for camera-based speed calculations
- **Depth map + RGB alignment** is automatic through ARKit

### Camera Strategy
- **240fps at 1080p** on iPhone 8+ gives the best temporal resolution for tracking fast-moving club heads
- At 240fps, a club head moving at 100 mph (~44.7 m/s) moves **~18.6 cm between frames** -- still very fast but potentially trackable
- Real-time ML inference at 240fps requires processing every Nth frame or using very lightweight models
- YOLOv3 Tiny achieved 358 FPS for golf ball detection, suggesting feasibility for club detection

### Recommended Approach
1. Use **LiDAR** for scene calibration (distance to ball, ground plane, scale reference)
2. Use **240fps camera** for actual swing capture and club head tracking
3. Use **Core ML** with quantized YOLO variant for club head detection
4. Calculate speed from pixel displacement + LiDAR-calibrated real-world scale
5. Consider **TrackNet** architecture for tracking through motion blur

### Most Relevant Open Source References
1. **PiTrac** -- full launch monitor architecture and speed calculation logic
2. **AICaddy** -- 6000+ club head images, YOLOv8 trained model
3. **TrackNet** -- state-of-the-art for tracking fast/tiny sports objects
4. **Roboflow golf-club-tracking** -- ready-to-use annotated dataset
5. **ARKit-Scanner** -- demonstrates synchronized RGB-D capture pipeline
