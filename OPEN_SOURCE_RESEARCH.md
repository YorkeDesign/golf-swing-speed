# Open Source Projects Research: Golf Swing Speed App

**Date:** 2026-03-22
**Scope:** Golf swing analysis, sports tracking, camera-based speed measurement, object tracking, iPhone/LiDAR projects, datasets, and pre-trained models.

---

## Table of Contents

1. [Golf Swing Analysis Tools](#1-golf-swing-analysis-tools)
2. [Golf Launch Monitors & Simulators](#2-golf-launch-monitors--simulators)
3. [Golf Swing Datasets & Pre-trained Models](#3-golf-swing-datasets--pre-trained-models)
4. [General Sports Tracking & Analytics](#4-general-sports-tracking--analytics)
5. [High-Speed Object Tracking (TrackNet & Similar)](#5-high-speed-object-tracking-tracknet--similar)
6. [Multi-Object Tracking Frameworks (DeepSORT, ByteTrack)](#6-multi-object-tracking-frameworks-deepsort-bytetrack)
7. [Pose Estimation Frameworks](#7-pose-estimation-frameworks)
8. [Racket/Bat/Club Tracking in Other Sports](#8-racketbatclub-tracking-in-other-sports)
9. [Speed & Velocity Estimation via Computer Vision](#9-speed--velocity-estimation-via-computer-vision)
10. [iPhone Camera / High-FPS Capture for iOS](#10-iphone-camera--high-fps-capture-for-ios)
11. [ARKit / LiDAR / Body Tracking on iOS](#11-arkit--lidar--body-tracking-on-ios)
12. [CoreML / Apple Vision Framework Projects](#12-coreml--apple-vision-framework-projects)
13. [Computer Vision Toolkits (Roboflow, Supervision)](#13-computer-vision-toolkits-roboflow-supervision)
14. [Academic Papers & Research](#14-academic-papers--research)
15. [Relevance Summary & Recommendations](#15-relevance-summary--recommendations)

---

## 1. Golf Swing Analysis Tools

### GolfDB / SwingNet
- **Repo:** [wmcnally/golfdb](https://github.com/wmcnally/golfdb)
- **Tech Stack:** Python, PyTorch
- **Last Updated:** Maintained; CVPR Workshop 2019 paper
- **What It Does:** Video database for golf swing sequencing -- detects 8 swing events (address, toe-up, mid-backswing, top, mid-downswing, impact, mid-follow-through, finish) in trimmed golf swing videos. SwingNet is the baseline model.
- **Key Algorithms:** MobileNetV2 feature extraction + Bidirectional LSTM for temporal sequencing. Achieves ~76% PCE with augmentation.
- **Dataset:** 1400 video clips from 580 YouTube videos with frame-level annotations for 8 events. Mixed slow-motion/regular, male/female, multiple club types.
- **Relevance:** HIGH -- Directly applicable for detecting swing phases. The event detection model can identify the impact frame, which is critical for calculating club head speed from video.

### AICaddy - Golf Club Tracer
- **Repo:** [oswinkil-git/AICaddy-A-Golf-Club-Tracer](https://github.com/oswinkil-git/AICaddy-A-Golf-Club-Tracer)
- **Tech Stack:** Python, YOLOv8
- **What It Does:** Uses a custom YOLOv8 model trained on 6000+ images of golf club heads to trace the club path during a swing.
- **Key Algorithms:** YOLOv8 object detection fine-tuned for golf club head detection.
- **Dataset:** 6000+ annotated golf club head images.
- **Relevance:** VERY HIGH -- Directly detects and tracks golf club heads in video. The detection model could feed into a speed calculation pipeline by tracking club head position across frames.

### Golf Swing Analysis (MediaPipe)
- **Repo:** [HeleenaRobert/golf-swing-analysis](https://github.com/HeleenaRobert/golf-swing-analysis)
- **Tech Stack:** Python, MediaPipe Pose, OpenCV
- **What It Does:** Analyzes golf swings using body landmark tracking (ear, hip, wrist), calculates swing angles, overlays reference axes, and produces annotated video.
- **Key Algorithms:** MediaPipe Pose for 33 body landmarks, angle computation between joints.
- **Relevance:** HIGH -- Demonstrates a lightweight approach to swing analysis that could run on mobile. Body pose can supplement club tracking for holistic analysis.

### Pose Estimation for Swing Improvement
- **Repo:** [Strojove-uceni/23206-final-pose-estimation-for-swing-improvement](https://github.com/Strojove-uceni/23206-final-pose-estimation-for-swing-improvement)
- **Tech Stack:** Python, pose estimation models
- **What It Does:** Uses pose estimation to analyze and provide feedback on golf swing form.
- **Key Algorithms:** Pose estimation with comparison to reference swings.
- **Relevance:** MODERATE -- Focuses on form rather than speed, but the body tracking approach is relevant.

### analyze.golf
- **Repo:** [tlouth19/analyze.golf](https://github.com/tlouth19/analyze.golf)
- **Tech Stack:** React, Redux, Tailwind, Konva.js
- **What It Does:** Browser-based golf swing analyzer with manual annotation and drawing tools.
- **Relevance:** LOW for algorithms, but useful UX reference for a swing analysis app.

### GolfSwing (personableduck)
- **Repo:** [personableduck/GolfSwing](https://github.com/personableduck/GolfSwing)
- **Tech Stack:** Python
- **What It Does:** Golf swing analysis model using machine learning.
- **Relevance:** MODERATE -- Another ML-based swing analysis approach.

### GolfTracker
- **Repo:** [rlarcher/GolfTracker](https://github.com/rlarcher/GolfTracker)
- **Tech Stack:** Python, OpenCV
- **What It Does:** Produces a mobile version of the golf pro tracker overlay seen on PGA broadcasts, with swing analysis features.
- **Relevance:** MODERATE -- The broadcast-style tracking overlay is a useful visualization reference.

### Golf Ball Tracking (YOLOv5)
- **Repo:** [onkar-99/Golf-Ball-Tracking](https://github.com/onkar-99/Golf-Ball-Tracking)
- **Tech Stack:** Python, YOLOv5
- **What It Does:** Tracks a golf ball and draws the swing curve trajectory.
- **Key Algorithms:** YOLOv5 custom-trained for golf ball detection.
- **Relevance:** MODERATE -- Ball tracking complements club head tracking for a full launch monitor solution.

---

## 2. Golf Launch Monitors & Simulators

### PiTrac - DIY Golf Launch Monitor
- **Repo:** [PiTracLM/PiTrac](https://github.com/PiTracLM/PiTrac)
- **Website:** [pitraclm.github.io/PiTrac](https://pitraclm.github.io/PiTrac/)
- **Hackaday:** [hackaday.io/project/195042](https://hackaday.io/project/195042-pitrac-the-diy-golf-launch-monitor)
- **Tech Stack:** C++, Python, Raspberry Pi, Pi Global Shutter Camera
- **What It Does:** World's first free, open-source golf launch monitor. Determines ball speed, launch angles (horizontal and vertical), and spin in 3 axes using high-speed infrared strobe-based image capture.
- **Key Algorithms:** IR strobe illumination for high-speed capture, image processing for ball position/spin detection, physics-based speed calculation.
- **Hardware:** ~$250 total (2x Raspberry Pi + cameras). Uses Pi Global Shutter camera (~$50).
- **Interfaces:** GSPro, E6/TruGolf simulators, standalone web app.
- **Relevance:** VERY HIGH -- The most directly relevant project. Demonstrates actual speed measurement from camera images. The algorithms for calculating ball speed from frame-to-frame displacement are directly transferable. The IR strobe approach is clever but not needed for a phone app -- however, the math and calibration logic are gold.

### Seneca Golf - Open Source Golf Simulator
- **Repo:** [csites/Seneca-Golf](https://github.com/csites/Seneca-Golf)
- **Tech Stack:** Various
- **What It Does:** Open source golf simulator framework for DIY enthusiasts to build launch monitors and golf courses.
- **Relevance:** LOW -- More focused on simulation than measurement.

### OpenShotGolf
- **Repo:** [jhauck2/OpenShotGolf](https://github.com/jhauck2/OpenShotGolf)
- **Tech Stack:** Godot Engine
- **What It Does:** Golf simulator built with Godot.
- **Relevance:** LOW -- Game/simulation focus.

### ronheywood/opencv (Golf Launch Monitor Experiments)
- **Repo:** [ronheywood/opencv](https://github.com/ronheywood/opencv)
- **Tech Stack:** Python, OpenCV
- **What It Does:** Experiments using machine vision with OpenCV for driving golf launch monitor software (similar to SkyTrak, GC2, GCQuad).
- **Relevance:** HIGH -- Direct experimentation with the same problem space.

---

## 3. Golf Swing Datasets & Pre-trained Models

### Roboflow Universe - Golf Club Tracking Dataset
- **URL:** [universe.roboflow.com/club-head-tracking/golf-club-tracking](https://universe.roboflow.com/club-head-tracking/golf-club-tracking/dataset/2)
- **Size:** 6,750 annotated golf images
- **Formats:** YOLO (v5/v7/v8/v11), COCO JSON, CreateML JSON, TFRecord, PaliGemma JSONL
- **Relevance:** VERY HIGH -- Ready-to-use dataset for training a golf club head detection model. Supports direct export to CoreML via CreateML format.

### Roboflow - Golf Swing Position Dataset
- **URL:** [universe.roboflow.com/lvs-rd/golf-swing](https://universe.roboflow.com/lvs-rd/golf-swing)
- **Size:** 2,398 images + pre-trained model
- **Relevance:** HIGH -- Includes a pre-trained model and API for golf swing position detection.

### Roboflow - Golf Swing 2 (Pose)
- **URL:** [universe.roboflow.com/pose-2n8xx/golf-swing-2](https://universe.roboflow.com/pose-2n8xx/golf-swing-2/dataset/1)
- **Size:** 6,805 annotated images
- **Relevance:** HIGH -- Large annotated dataset for golf swing pose detection.

### Roboflow - Golf Swing Analyzer
- **URL:** [universe.roboflow.com/bosharluke/golf-swing-analyzer](https://universe.roboflow.com/bosharluke/golf-swing-analyzer)
- **Size:** 5,583 images
- **Relevance:** MODERATE -- Another annotated golf swing dataset.

### Roboflow - Golf Driver Tracker
- **URL:** [universe.roboflow.com/salo-levy-nlqrn/golf-driver-tracker](https://universe.roboflow.com/salo-levy-nlqrn/golf-driver-tracker)
- **Relevance:** HIGH -- Specifically focused on tracking the driver club head.

### Roboflow - Detect Golfclub
- **URL:** [universe.roboflow.com/suranaree-university-of-tecnology/detect-golfclub](https://universe.roboflow.com/suranaree-university-of-tecnology/detect-golfclub/dataset/2)
- **Size:** 45 images (small but annotated)
- **Relevance:** LOW -- Too small for production training but useful for quick prototyping.

### Roboflow - Golf Swing Keypoint Detection
- **URL:** [universe.roboflow.com/photofunction/golf-swing-b21yo](https://universe.roboflow.com/photofunction/golf-swing-b21yo)
- **Relevance:** HIGH -- Keypoint detection model for golf swing pose analysis.

### GolfDB Dataset (Academic)
- **Source:** [CVPR 2019 Workshop Paper](https://openaccess.thecvf.com/content_CVPRW_2019/papers/CVSports/McNally_GolfDB_A_Video_Database_for_Golf_Swing_Sequencing_CVPRW_2019_paper.pdf)
- **Size:** 1,400 video clips from 580 YouTube videos
- **Annotations:** 8 swing events per clip, frame-level
- **Relevance:** HIGH -- The standard academic golf swing video dataset.

### CaddieSet Dataset (2025)
- **Paper:** [arxiv.org/html/2508.20491v1](https://arxiv.org/html/2508.20491v1)
- **What It Does:** Connects golfers' joint information with ball trajectory data per shot. Demonstrates interpretable ML for personalized golf swing corrections.
- **Relevance:** HIGH -- Novel dataset linking body mechanics to ball outcomes.

---

## 4. General Sports Tracking & Analytics

### Roboflow Sports
- **Repo:** [roboflow/sports](https://github.com/roboflow/sports)
- **Tech Stack:** Python
- **What It Does:** Computer vision tools specifically for sports analytics. Tackles ball tracking, jersey number reading, player tracking with consistent IDs. Uses it as a testing ground for object detection, segmentation, and keypoint detection.
- **Relevance:** MODERATE -- General sports CV toolkit with reusable patterns for tracking.

### SportsVision-YOLO
- **Repo:** [forzasys-students/SportsVision-YOLO](https://github.com/forzasys-students/SportsVision-YOLO)
- **Tech Stack:** Python, YOLOv8
- **What It Does:** Fine-tuned YOLOv8 for soccer and ice hockey (players, balls, logos).
- **Relevance:** LOW -- Different sport but demonstrates fine-tuning workflow.

### Tennis Tracking (HawkEye Clone)
- **Repo:** [ArtLabss/tennis-tracking](https://github.com/ArtLabss/tennis-tracking)
- **Tech Stack:** Python, TrackNet, ResNet50
- **What It Does:** Open-source monocular HawkEye for tennis. Uses TrackNet for ball tracking and ResNet50 for player detection. Calculates ball speed.
- **Key Algorithms:** TrackNet deep learning network, player detection, speed calculation from trajectory.
- **Relevance:** HIGH -- Ball speed calculation from video is directly analogous to club head speed calculation. The pixel-to-real-world calibration approach is transferable.

### Cricket Computer Vision
- **Repo:** [siddharthksah/cricket_computer_vision_sports](https://github.com/siddharthksah/cricket_computer_vision_sports)
- **Tech Stack:** Python, YOLOv8, DeepSORT
- **What It Does:** Detects and classifies objects in cricket matches, tracks the ball using YOLOv8 + DeepSORT.
- **Relevance:** LOW-MODERATE -- Demonstrates ball tracking pipeline.

### RacketDB - Badminton Racket Dataset
- **Repo:** [muhabdulhaq/racketdb](https://github.com/muhabdulhaq/racketdb)
- **What It Does:** Specialized dataset for badminton racket detection with annotations for racket detection, orientation estimation, and equipment-player interaction.
- **Relevance:** MODERATE -- Racket detection is analogous to club detection.

---

## 5. High-Speed Object Tracking (TrackNet & Similar)

### TrackNet (Official)
- **Paper:** [arxiv.org/abs/1907.03698](https://arxiv.org/abs/1907.03698)
- **Website:** [nol.cs.nctu.edu.tw](https://nol.cs.nctu.edu.tw/ndo3je6av9/)
- **Tech Stack:** Python, deep learning (VGG16 + DeconvNet)
- **What It Does:** Deep learning network specifically designed for tracking high-speed and tiny objects in sports. Takes multiple consecutive frames as input and outputs a Gaussian heatmap centered on the ball position. Achieves 99.7% precision, 97.3% recall on tennis ball tracking.
- **Key Algorithms:** FCN model with VGG16 encoder + DeconvNet decoder, multi-frame input for temporal learning, Gaussian heatmap output.
- **Relevance:** VERY HIGH -- The core architecture is designed for exactly the problem of tracking small, fast-moving objects (like a club head) in video. The multi-frame approach helps with motion blur, which is a key challenge for high-speed golf swings.

### TrackNet (PyTorch Unofficial)
- **Repo:** [yastrebksv/TrackNet](https://github.com/yastrebksv/TrackNet)
- **Tech Stack:** Python, PyTorch
- **What It Does:** Unofficial PyTorch implementation of TrackNet.
- **Relevance:** HIGH -- More modern framework implementation for easier integration.

### TrackNet - Badminton Tracking (TensorFlow2)
- **Repo:** [Chang-Chia-Chi/TrackNet-Badminton-Tracking-tensorflow2](https://github.com/Chang-Chia-Chi/TrackNet-Badminton-Tracking-tensorflow2)
- **Tech Stack:** Python, TensorFlow 2
- **Relevance:** MODERATE -- Alternative framework implementation.

### TrackNet V4
- **Website:** [tracknetv4.github.io](https://tracknetv4.github.io/)
- **What It Does:** Latest evolution of TrackNet with improved performance.
- **Relevance:** HIGH -- Most recent version with best accuracy.

### Weekend Deep Learning TrackNet
- **Repo:** [weekenddeeplearning/TrackNet](https://github.com/weekenddeeplearning/TrackNet)
- **Tech Stack:** Python
- **What It Does:** Heatmap-based high-speed tiny sport object tracking implementation.
- **Relevance:** HIGH -- Clean implementation focused on sports tracking.

---

## 6. Multi-Object Tracking Frameworks (DeepSORT, ByteTrack)

### ByteTrack
- **Repo:** [FoundationVision/ByteTrack](https://github.com/FoundationVision/ByteTrack)
- **Tech Stack:** Python, PyTorch
- **What It Does:** ECCV 2022 paper. Associates every detection box (including low-confidence ones) for robust multi-object tracking. Simple, fast, and strong.
- **Relevance:** MODERATE -- Useful if tracking multiple objects (ball + club head simultaneously).

### DeepSORT (Original)
- **Repo:** [nwojke/deep_sort](https://github.com/nwojke/deep_sort)
- **Tech Stack:** Python
- **What It Does:** Simple Online Realtime Tracking with a Deep Association Metric.
- **Relevance:** MODERATE -- Standard tracking framework for maintaining object identity across frames.

### DeepSORT Realtime
- **Repo:** [levan92/deep_sort_realtime](https://github.com/levan92/deep_sort_realtime)
- **Tech Stack:** Python
- **What It Does:** Real-time optimized adaptation of DeepSORT. Supports in-built appearance feature embedder.
- **Relevance:** MODERATE -- Better suited for real-time applications.

### YOLOv8 + DeepSORT Tracking
- **Repo:** [MuhammadMoinFaisal/YOLOv8-DeepSORT-Object-Tracking](https://github.com/MuhammadMoinFaisal/YOLOv8-DeepSORT-Object-Tracking)
- **Tech Stack:** Python, PyTorch, OpenCV
- **What It Does:** Complete pipeline combining YOLOv8 detection with DeepSORT tracking.
- **Relevance:** MODERATE -- Reference implementation of detection + tracking pipeline.

---

## 7. Pose Estimation Frameworks

### MMPose (OpenMMLab)
- **Repo:** [open-mmlab/mmpose](https://github.com/open-mmlab/mmpose)
- **Tech Stack:** Python, PyTorch
- **Stars:** 5,000+
- **Last Updated:** Actively maintained (v1.3.0 released Jan 2024)
- **What It Does:** Comprehensive pose estimation toolbox: 2D/3D human pose, hand pose, face landmarks, 133-keypoint whole-body, animal pose. Includes RTMPose for real-time multi-person pose estimation with high accuracy and speed.
- **Key Models:** ViTPose, RTMPose (real-time), HRNet, SimpleBaseline
- **Relevance:** HIGH -- RTMPose is fast enough for real-time mobile applications. Body pose from the golfer helps calculate body rotation speed and sequencing, which correlates with club head speed.

### MediaPipe Pose (Google)
- **Repo:** [google-ai-edge/mediapipe](https://github.com/google-ai-edge/mediapipe)
- **Tech Stack:** Python, C++, Swift (iOS), Kotlin (Android)
- **What It Does:** 33 3D body landmarks from RGB video, optimized for mobile. Two-stage pipeline: person detection + keypoint localization. Background segmentation included.
- **Key Algorithms:** BlazePose (optimized for mobile), single-person tracking.
- **Relevance:** VERY HIGH -- Runs natively on iOS, lightweight, real-time. Can track wrist/arm movement as a proxy for club head speed. Already used in multiple golf analysis projects.

### PyBodyTrack
- **Source:** [ScienceDirect paper](https://www.sciencedirect.com/science/article/pii/S2352711025002390)
- **Tech Stack:** Python
- **What It Does:** Multi-algorithm motion quantification library that integrates MediaPipe, YOLO, and OpenPose. Simplifies video management for motion analysis.
- **Relevance:** MODERATE -- Abstraction layer over multiple pose estimators.

### Athlete AI MMPose
- **Repo:** [agencyenterprise/athlete-ai-mmpose](https://github.com/agencyenterprise/athlete-ai-mmpose)
- **Tech Stack:** Python, PyTorch (MMPose fork)
- **What It Does:** MMPose fork specifically tuned for athletic/sports applications.
- **Relevance:** MODERATE -- Sports-specific pose estimation tuning.

---

## 8. Racket/Bat/Club Tracking in Other Sports

### RacketVision (Tennis Analysis)
- **Repo:** [skisurfer13/RacketVision](https://github.com/skisurfer13/RacketVision)
- **Tech Stack:** Python, TrackNet, YOLOv8, CNN, CatBoost
- **What It Does:** Advanced sports analytics using multiple CV architectures for player detection, ball tracking, and speed estimation in tennis.
- **Key Algorithms:** TrackNet for ball, YOLOv8 for players, CatBoost Regressor for speed estimation.
- **Relevance:** HIGH -- Speed estimation from video is directly applicable. The multi-model pipeline pattern is a good architecture reference.

### RacketVision Benchmark (Academic)
- **Paper:** [arxiv.org/html/2511.17045v1](https://arxiv.org/html/2511.17045v1)
- **What It Does:** Large-scale benchmark for racket sports covering table tennis, tennis, and badminton. Provides annotations for racket pose alongside ball positions for trajectory forecasting.
- **Relevance:** MODERATE -- Racket pose estimation techniques transfer to club pose estimation.

### Tennis Ball Tracker (YOLO)
- **Repo:** [nikhilgrad/Tennis-Ball-Tracker](https://github.com/nikhilgrad/Tennis-Ball-Tracker)
- **Tech Stack:** Python, YOLO
- **What It Does:** Tracks tennis balls with interpolation for handling tracking failures.
- **Key Algorithms:** YOLO detection + interpolation for missing frames.
- **Relevance:** MODERATE -- Interpolation technique useful for handling frames where club head is motion-blurred.

---

## 9. Speed & Velocity Estimation via Computer Vision

### Car Velocity Estimation (Optical Flow + DL)
- **Repo:** [Rishikesh-Jadhav/Car-Velocity-Estimation-using-OpticalFlow-DL](https://github.com/Rishikesh-Jadhav/Car-Velocity-Estimation-using-OpticalFlow-DL)
- **Tech Stack:** Python, OpenCV, PyTorch (RAFT)
- **What It Does:** Combines Lucas-Kanade, Farneback optical flow, and RAFT deep learning for velocity estimation from video.
- **Key Algorithms:** Lucas-Kanade optical flow, Farneback dense optical flow, RAFT (Recurrent All-Pairs Field Transforms).
- **Relevance:** HIGH -- The optical flow approach for measuring object velocity from video is directly transferable to measuring club head speed. RAFT is state-of-the-art for dense optical flow.

### Object Tracking with Speed Estimation
- **Repo:** [be5s1l/Object-Tracking-in-Videos](https://github.com/be5s1l/Object-Tracking-in-Videos)
- **Tech Stack:** Python, YOLO, OpenCV
- **What It Does:** Real-time multi-object tracking with speed estimation and trajectory visualization.
- **Key Algorithms:** YOLO detection + optical flow for speed.
- **Relevance:** MODERATE -- Combined detection + speed estimation pipeline.

### FastFlowNet
- **Repo:** [ltkong218/FastFlowNet](https://github.com/ltkong218/FastFlowNet)
- **Tech Stack:** Python, PyTorch
- **What It Does:** Lightweight network for fast optical flow estimation (ICRA 2021). Designed for resource-constrained deployment.
- **Relevance:** MODERATE -- Could enable optical flow on mobile for real-time speed measurement.

---

## 10. iPhone Camera / High-FPS Capture for iOS

### SlowMotionVideoRecorder
- **Repo:** [shu223/SlowMotionVideoRecorder](https://github.com/shu223/SlowMotionVideoRecorder)
- **Tech Stack:** Swift/Objective-C, AVFoundation
- **What It Does:** iOS sample app for recording 120/240 FPS slow-motion video. Includes `TTMCaptureManager` wrapper class for easy integration.
- **Relevance:** VERY HIGH -- Direct reference for capturing high-FPS video on iPhone, which is essential for measuring fast club head movement. At 240 FPS, a 100mph club head moves ~0.7 inches per frame, making tracking feasible.

### PBJVision
- **Repo:** [piemonte/PBJVision](https://github.com/piemonte/PBJVision)
- **Tech Stack:** Objective-C, AVFoundation
- **What It Does:** iOS media capture engine with touch-to-record, slow motion, and photography features.
- **Relevance:** HIGH -- Mature camera capture library with slow-motion support.

### SCRecorder
- **Repo:** [rFlex/SCRecorder](https://github.com/rFlex/SCRecorder)
- **Tech Stack:** Objective-C, AVFoundation
- **What It Does:** iOS camera engine with slow motion video capture and segments editing.
- **Relevance:** MODERATE -- Older but well-tested slow-motion capture.

### Key Technical Notes for iOS High-FPS Capture
- iPhone 15 Pro / 16 Pro support 240 FPS at 1080p
- AVFoundation's `AVCaptureDevice.Format` allows querying supported frame rate ranges
- Configure via `activeVideoMinFrameDuration` / `activeVideoMaxFrameDuration`
- At 240 FPS, each frame has ~4.17ms exposure -- sufficient for club head blur reduction
- CMSampleBuffer provides precise timestamps for frame-to-frame time delta calculation

---

## 11. ARKit / LiDAR / Body Tracking on iOS

### BodyTracking Swift Package
- **Repo:** [Reality-Dev/BodyTracking](https://github.com/Reality-Dev/BodyTracking)
- **Tech Stack:** Swift, ARKit, RealityKit
- **What It Does:** Swift package making body tracking easy in ARKit/RealityKit. Provides 3D skeleton with joint positions.
- **Relevance:** HIGH -- Could track golfer body movement in 3D for biomechanics analysis. Joint velocities from skeleton tracking could estimate arm/wrist speed.

### Body-Tracking-AR
- **Repo:** [huntercodes/Body-Tracking-AR](https://github.com/huntercodes/Body-Tracking-AR)
- **Tech Stack:** Swift, ARKit, RealityKit (iOS 15+)
- **What It Does:** Body tracking with skeleton visualization.
- **Relevance:** MODERATE -- Simple example of ARKit body tracking.

### ARBodyTracking
- **Repo:** [fncischen/ARBodyTracking](https://github.com/fncischen/ARBodyTracking)
- **Tech Stack:** Swift, ARKit, Unity
- **What It Does:** AR body tracking experiments with VFX capabilities.
- **Relevance:** LOW-MODERATE -- More AR-focused than measurement-focused.

### ExampleOfiOSLiDAR
- **Repo:** [TokyoYoshida/ExampleOfiOSLiDAR](https://github.com/TokyoYoshida/ExampleOfiOSLiDAR)
- **Tech Stack:** Swift, ARKit
- **What It Does:** Example of iOS ARKit LiDAR usage with point cloud capture.
- **Relevance:** MODERATE -- LiDAR could provide depth information for 3D club head positioning, but LiDAR frame rate (typically 10-30 Hz) is too slow for direct club head tracking during the swing.

### LiDARKit
- **Repo:** [tyang-gauntlet/LiDARKit](https://github.com/tyang-gauntlet/LiDARKit)
- **Tech Stack:** Swift, ARKit, SceneKit
- **What It Does:** Real-time LiDAR point cloud capture, depth map processing, position/transform tracking, SceneKit rendering.
- **Relevance:** MODERATE -- Useful for environment calibration (knowing the distance to the golfer) but not fast enough for direct club tracking.

### SwiftUI-LiDAR
- **Repo:** [cedanmisquith/SwiftUI-LiDAR](https://github.com/cedanmisquith/SwiftUI-LiDAR)
- **Tech Stack:** SwiftUI, ARKit
- **What It Does:** 3D environment scanning and mesh export.
- **Relevance:** LOW -- Environment scanning, not motion tracking.

### ARKit-Scanner
- **Repo:** [xiongyiheng/ARKit-Scanner](https://github.com/xiongyiheng/ARKit-Scanner)
- **Tech Stack:** Swift, ARKit
- **What It Does:** RGB-D scanning with iPhone LiDAR, stores color + depth + IMU data.
- **Relevance:** MODERATE -- The IMU data capture alongside video is interesting for sensor fusion approaches to speed measurement.

---

## 12. CoreML / Apple Vision Framework Projects

### ObjectDetection-CoreML
- **Repo:** [tucan9389/ObjectDetection-CoreML](https://github.com/tucan9389/ObjectDetection-CoreML)
- **Tech Stack:** Swift, CoreML, Vision
- **What It Does:** Running object detection (YOLOv8, YOLOv5, YOLOv3, MobileNetV2+SSDLite) on iOS using CoreML.
- **Relevance:** VERY HIGH -- Direct reference for running YOLO-based club head detection on iPhone. Shows the full pipeline from camera frame to CoreML inference to bounding box overlay.

### Vision-Object-Tracking
- **Repo:** [VikramParimi/Vision-Object-Tracking](https://github.com/VikramParimi/Vision-Object-Tracking)
- **Tech Stack:** Swift, Vision framework
- **What It Does:** Object tracking using Apple's Vision framework with VNTrackObjectRequest.
- **Relevance:** HIGH -- Apple Vision's built-in object tracking could be used for frame-to-frame club head tracking after initial detection, potentially faster than running YOLO every frame.

### ObjectDetection_CoreML-Swift
- **Repo:** [Dr-Groot/ObjectDetection_CoreML-Swift](https://github.com/Dr-Groot/ObjectDetection_CoreML-Swift)
- **Tech Stack:** Swift, CoreML, Vision, ARKit
- **What It Does:** Real-time camera object detection with CoreML, combining Vision and ARKit.
- **Relevance:** HIGH -- Demonstrates CoreML + ARKit integration for real-time detection.

### VisionExamples
- **Repo:** [GauravGupta0216/VisionExamples](https://github.com/GauravGupta0216/VisionExamples)
- **Tech Stack:** SwiftUI, Vision, CoreML
- **What It Does:** Multiple Vision Framework examples including YOLOv3 object detection.
- **Relevance:** MODERATE -- Good reference for Vision framework usage patterns.

### Key Technical Notes for CoreML
- YOLOv8 nano exports to CoreML and achieves 60+ FPS on iPhone Neural Engine
- YOLO11 (Oct 2024) achieves 53.4% mAP on COCO with 200+ FPS on GPU
- RF-DETR achieves 54.7% mAP with excellent on-device performance
- Roboflow Swift SDK handles CoreML model loading and caching automatically
- VNCoreMLRequest + VNImageRequestHandler pipeline for per-frame inference
- Apple's pre-trained models available at [developer.apple.com/machine-learning/models](https://developer.apple.com/machine-learning/models/)

---

## 13. Computer Vision Toolkits (Roboflow, Supervision)

### Roboflow Supervision
- **Repo:** [roboflow/supervision](https://github.com/roboflow/supervision)
- **Tech Stack:** Python
- **Stars:** 20,000+
- **License:** MIT
- **What It Does:** Reusable computer vision toolkit for loading datasets, drawing detections, counting objects in zones, tracking, and annotation. Works with any detection model.
- **Relevance:** HIGH -- Excellent for rapid prototyping of detection + tracking pipelines during development.

### Ultralytics YOLOv8/YOLO11
- **Repo:** [ultralytics/ultralytics](https://github.com/ultralytics/ultralytics)
- **Tech Stack:** Python, PyTorch
- **Stars:** 30,000+
- **What It Does:** State-of-the-art object detection, segmentation, pose estimation, and tracking. Supports export to CoreML, ONNX, TensorRT.
- **Key Feature:** Direct CoreML export for iOS deployment with `model.export(format='coreml')`.
- **Relevance:** VERY HIGH -- The likely backbone for club head detection. Train a custom YOLOv8 model on golf club head data, export to CoreML, deploy on iPhone.

---

## 14. Academic Papers & Research

### GolfPose (ICPR 2024)
- **Paper:** [IEEE Xplore](https://ieeexplore.ieee.org/document/9859415/)
- **What It Does:** Lightweight temporal-based 2D human pose estimation optimized for golf swing analysis. Uses temporal information to improve accuracy for fast-moving and self-occluded keypoints. Designed for real-time mobile inference.
- **Relevance:** VERY HIGH -- Purpose-built for the golf swing analysis problem on mobile devices.

### GolfPoseNet: Golf-Specific 3D Human Pose Estimation
- **Paper:** [ResearchGate](https://www.researchgate.net/publication/389114267_GolfPoseNet_Golf-Specific_3D_Human_Pose_Estimation_Network)
- **What It Does:** 3D pose estimation network specifically designed for golf applications.
- **Relevance:** HIGH -- 3D joint positions enable more accurate biomechanics analysis.

### GolfMate: Enhanced Golf Swing Analysis Tool
- **Paper:** [MDPI](https://www.mdpi.com/2076-3417/13/20/11227)
- **What It Does:** Pose refinement network + explainable golf swing embedding for self-training. Compares learner swings to professional swings.
- **Relevance:** HIGH -- Provides the "coaching" angle that can complement speed measurement.

### CaddieSet (2025)
- **Paper:** [arxiv.org/html/2508.20491v1](https://arxiv.org/html/2508.20491v1)
- **What It Does:** Links joint information to ball trajectory outcomes with interpretable ML for personalized corrections.
- **Relevance:** HIGH -- Demonstrates the end-to-end pipeline from pose to ball outcome.

### Efficient Golf Ball Detection and Tracking (2020)
- **Paper:** [arxiv.org/abs/2012.09393](https://arxiv.org/abs/2012.09393)
- **What It Does:** CNN-based golf ball detection combined with Kalman filter for tracking.
- **Key Algorithms:** CNN detection + Kalman filter prediction.
- **Relevance:** HIGH -- Kalman filter for smoothing noisy detections is highly relevant for club head tracking.

### Dynamic Golf Swing Analysis Framework (2025)
- **Paper:** [MDPI Sensors](https://www.mdpi.com/1424-8220/25/22/7073)
- **What It Does:** Segments swing into 7 canonical phases and evaluates dynamic trajectories of joint keypoints per phase.
- **Relevance:** MODERATE -- Phase segmentation useful for contextualizing speed measurements.

### Stanford CS231N - Golf Swing Sequencing (2025)
- **Paper:** [cs231n.stanford.edu](https://cs231n.stanford.edu/2025/papers/cs231n_final_report__Revised%20-%20Yanming%20Zhu.pdf)
- **What It Does:** Video understanding sequence model applied to golf swing event detection.
- **Relevance:** MODERATE -- Academic exploration of sequence models for swing analysis.

### TrackNet Paper (2019)
- **Paper:** [arxiv.org/abs/1907.03698](https://arxiv.org/abs/1907.03698)
- **What It Does:** Deep learning network for tracking high-speed tiny objects in sports. 99.7% precision on tennis ball tracking.
- **Relevance:** VERY HIGH -- The foundational approach for tracking small fast objects in sports video.

---

## 15. Relevance Summary & Recommendations

### Tier 1: Directly Applicable (Build On These)

| Project | Why |
|---------|-----|
| **PiTrac** | Open source launch monitor with actual speed measurement algorithms |
| **AICaddy (YOLOv8 Club Tracker)** | Pre-trained club head detection model with 6000+ training images |
| **Roboflow Golf Club Tracking Dataset** | 6,750 annotated images ready for custom model training |
| **TrackNet** | Purpose-built architecture for high-speed small object tracking in sports |
| **GolfDB / SwingNet** | Swing phase detection to identify the impact frame |
| **SlowMotionVideoRecorder** | iOS 240 FPS capture reference implementation |
| **ObjectDetection-CoreML** | YOLOv8 on iPhone via CoreML reference |
| **MediaPipe Pose** | Real-time body tracking on iOS for supplementary analysis |
| **Ultralytics YOLOv8** | Train custom model + export to CoreML for iOS |

### Tier 2: Valuable Reference (Learn From These)

| Project | Why |
|---------|-----|
| **Tennis Tracking (HawkEye)** | Speed calculation from video, pixel-to-real calibration |
| **RacketVision** | Multi-model pipeline: detection + tracking + speed estimation |
| **Vision-Object-Tracking** | Apple Vision framework for efficient frame-to-frame tracking |
| **BodyTracking Swift Package** | ARKit body tracking for biomechanics |
| **Optical Flow Velocity Estimation** | Alternative approach using RAFT/Lucas-Kanade for speed |
| **Roboflow Supervision** | Rapid prototyping toolkit for CV pipelines |
| **GolfPose (paper)** | Mobile-optimized golf pose estimation |
| **RTMPose (MMPose)** | Real-time pose estimation for sports |

### Tier 3: Supplementary (Useful But Indirect)

| Project | Why |
|---------|-----|
| **ByteTrack / DeepSORT** | Robust tracking if multi-object needed |
| **LiDARKit / ARKit examples** | Depth/calibration data, not fast enough for direct tracking |
| **FastFlowNet** | Mobile optical flow for speed estimation |
| **CaddieSet / GolfMate papers** | Academic approaches to golf analytics |
| **PBJVision / SCRecorder** | Alternative iOS camera capture libraries |

### Recommended Architecture Based on Research

```
iPhone 240 FPS Camera Capture (AVFoundation)
        |
        v
Frame Buffer (CMSampleBuffer with timestamps)
        |
        +---> CoreML YOLOv8 Nano (club head detection)
        |           |
        |           v
        |     Bounding box + confidence
        |           |
        +---> Apple Vision VNTrackObjectRequest (frame-to-frame tracking)
        |           |
        |           v
        |     Club head position per frame
        |           |
        +---> Speed Calculation Engine
        |     - Pixel displacement between frames
        |     - Camera calibration (pixels -> real world distance)
        |     - Frame timestamp delta (1/240s = 4.17ms)
        |     - Speed = distance / time
        |           |
        |           v
        |     Club Head Speed (mph)
        |
        +---> MediaPipe Pose (optional, body analysis)
                    |
                    v
              Swing phase, body mechanics
```

### Key Training Data Strategy

1. Start with the **Roboflow Golf Club Tracking Dataset** (6,750 images)
2. Supplement with **AICaddy's 6,000+ images** if compatible format
3. Fine-tune **YOLOv8 Nano** for small model size on iPhone
4. Export to **CoreML** via Ultralytics
5. Use **GolfDB** for swing phase detection (identify the frames around impact)
6. Apply **Kalman filter** (from the golf ball detection paper) for smoothing noisy detections

### Physics for Speed Calculation

- Club head speed at impact: typically 80-120 mph (36-54 m/s)
- At 240 FPS, the club head moves 6-9 inches (15-23 cm) per frame near impact
- A YOLOv8 detection with 1080p input can localize to ~5-10 pixel accuracy
- With proper camera calibration (known distance to golfer), pixel displacement can be converted to real-world distance
- Speed = pixel_displacement * (real_world_scale / pixels_per_unit) / frame_time_delta
- Angular momentum: L = I * omega; club head speed = omega * club_length
