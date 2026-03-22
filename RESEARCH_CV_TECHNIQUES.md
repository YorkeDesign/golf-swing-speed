# Computer Vision Techniques for Golf Swing Speed Measurement
## Comprehensive Research Report

**Date:** 2026-03-22
**Scope:** Academic papers, CV techniques, speed calculation mathematics, and swing detection automation

---

## Table of Contents

1. [Academic Papers](#1-academic-papers)
2. [Computer Vision Techniques Deep Dive](#2-computer-vision-techniques-deep-dive)
3. [Speed Calculation Math Deep Dive](#3-speed-calculation-math-deep-dive)
4. [Swing Detection Automation](#4-swing-detection-automation)
5. [References](#5-references)

---

## 1. Academic Papers

### 1.1 Golf Swing Analysis Using Computer Vision

#### Paper: GolfDB: A Video Database for Golf Swing Sequencing
- **Authors:** William McNally, Kanav Vats, et al.
- **Year:** 2019
- **Publication:** IEEE CVPR Workshops (CVSports)
- **Key Contributions:** First substantial benchmark database (1400 golf swing videos, 390k+ frames) dedicated to CV applications in golf. Introduced SwingNet, a lightweight deep neural network baseline.
- **Methods:** SwingNet uses a hybrid deep convolutional (MobileNetV2) and bidirectional LSTM architecture. Maps RGB image sequences to event probability sequences. 5.38M parameters, 10.92B FLOPs.
- **Results:** Detected eight golf swing events (Address, Toe-up, Mid-backswing, Top, Mid-downswing, Impact, Mid-follow-through, Finish) at 76.1% average accuracy. Six of eight events detected at 91.8%.
- **Relevance:** Establishes the canonical swing phase segmentation framework. Essential for automating swing detection and phase identification.
- **Link:** [arXiv:1903.06528](https://arxiv.org/abs/1903.06528)

#### Paper: Golf Swing Sequencing Using Computer Vision
- **Authors:** McNally et al.
- **Year:** 2022
- **Publication:** Springer - Pattern Recognition and Image Analysis (IbPRIA 2022)
- **Key Contributions:** Extended GolfDB work with improved sequencing methods using pose estimation.
- **Link:** [Springer](https://link.springer.com/chapter/10.1007/978-3-031-04881-4_28)

#### Paper: Dynamic Golf Swing Analysis Framework Based on Efficient Similarity Assessment (DMSM)
- **Authors:** Seung-Su Lee, Jun-Hyuk Choi, Jeongeun Byun, Kwang-Il Hwang
- **Year:** 2025
- **Publication:** Sensors (MDPI), Vol. 25, No. 22
- **Key Contributions:** Proposed a Dynamic Motion Similarity Measurement framework that segments swings into seven canonical phases and evaluates dynamic trajectories of joint keypoints within each phase. Unlike traditional DTW- or frame-based methods, integrates continuous motion trajectories and normalizes joint coordinates to account for player body scale differences.
- **Methods:** Motion data are interpolated to improve temporal resolution. Numerical integration quantifies path differences, capturing motion flow rather than isolated postures. Side-view swing datasets used.
- **Results:** Phase-averaged separation of 0.092 vs. 0.090 for DTW+cosine baseline. Spine-angle trajectory distinction of 38.68 degrees. Computational overhead of ~169ms. Statistical significance confirmed (p < 0.05).
- **Relevance:** Demonstrates practical real-time swing analysis with biomechanically interpretable feedback. Based on articles retrieved from PubMed.
- **DOI:** [10.3390/s25227073](https://doi.org/10.3390/s25227073)

#### Paper: Biomechanical Golf Swing Analysis using Markerless Three-Dimensional Skeletal Tracking through Truncation-Robust Heatmaps
- **Authors:** B.F. Taylor
- **Year:** 2025
- **Publication:** MIT SM/SDM Thesis (DSpace@MIT)
- **Key Contributions:** Implemented markerless temporal skeletal tracking using the MeTRAbs computer vision framework. Focused on the kinematic sequence (coordinated segmental rotation of pelvis, torso, arms, and club). Demonstrated feasibility of extracting golf swing signatures and angular velocity profiles without expensive motion capture equipment.
- **Methods:** MeTRAbs-based pose estimation with truncation-robust heatmaps for 3D skeletal tracking from standard video.
- **Relevance:** Directly applicable to consumer-grade camera-based golf analysis. Open-source approach.
- **Link:** [MIT DSpace](https://dspace.mit.edu/handle/1721.1/162530)

#### Paper: GolfMate: Enhanced Golf Swing Analysis Tool through Pose Refinement Network
- **Authors:** (Multiple)
- **Year:** 2023
- **Publication:** Applied Sciences (MDPI), Vol. 13, No. 20
- **Key Contributions:** Pose refinement network with explainable golf swing embedding for self-training applications.
- **Link:** [MDPI](https://www.mdpi.com/2076-3417/13/20/11227)

#### Paper: Prototype Design of Speed Detection Mobile Application for Golfer's Swing Movement Using Computer Vision Compared to Portable Radar and Accelerometer Systems
- **Authors:** (SGU researchers)
- **Year:** 2021
- **Publication:** Academia / SGU Repository
- **Key Contributions:** Developed a Golf Swing Speed Detection Mobile Application (GSSDMA/Swing Vision) using computer vision. Compared CV-based speed measurement against RADAR and accelerometer references.
- **Methods:** Frame detection method identifying frames from start of downswing to ball impact. Total frames counted and used for speed calculation via Python. Measurements compared against portable Doppler radar and accelerometer data.
- **Results:** Demonstrated that phone camera-based CV is simpler and effective compared to RADAR and accelerometer systems, though with accuracy trade-offs.
- **Relevance:** Directly addresses the core challenge of measuring swing speed from a phone camera. The most relevant paper for this project's goals.
- **Link:** [SGU Repository](https://sgu.ac.id/wp-content/uploads/2021/09/Article-12.pdf)

### 1.2 Club Head and Sports Implement Tracking

#### Paper: CSE 190a - Golf Club Head Tracking
- **Authors:** Ravi Chugh
- **Year:** ~2010
- **Publication:** UCSD Course Project Report
- **Key Contributions:** Modeled club head trajectory through polar and polynomial approximations. Found that a typical upswing can be accurately modeled by a 4th-degree polar curve and a typical downswing by a 6th-degree curve.
- **Methods:** Robust curve fitting to estimate clubhead speed over time. Image processing techniques for club head localization.
- **Relevance:** Foundational work on trajectory modeling specific to golf clubs.
- **Link:** [UCSD Report](https://people.cs.uchicago.edu/~rchugh/static/misc/golf/golfReport.pdf)

#### Paper: Golf Swing Motion Tracking Using Inertial Sensors and a Stereo Camera
- **Authors:** (Multiple)
- **Year:** 2013
- **Publication:** IEEE Xplore
- **Key Contributions:** Hybrid tracking system combining inertial sensor unit on the golf club with a stereo camera capturing infrared LEDs.
- **Results:** Average position accuracy ~3.6 cm, maximum error ~13.2 cm.
- **Relevance:** Demonstrates the accuracy achievable with multi-sensor approaches and sets a benchmark for pure CV solutions.
- **DOI:** [IEEE Xplore](https://ieeexplore.ieee.org/document/6642108)

### 1.3 High-Speed Object Tracking

#### Paper: Tracking a Golf Ball With High-Speed Stereo Vision System
- **Authors:** (Multiple)
- **Year:** 2018
- **Publication:** IEEE Transactions
- **Key Contributions:** Demonstrated tracking of golf ball motion at speeds up to 360 km/h (224 mph) under normal indoor lighting using binocular cameras at 810 fps with 35-microsecond exposure time.
- **Methods:** Circle detection (circular Hough transform, OFF-cell filter, Hausdorff distance). No additional strobe lights required.
- **Relevance:** Proves high-speed tracking is feasible with proper camera setup. Sets the bar for what specialized hardware can achieve.
- **Link:** [IEEE Xplore](https://ieeexplore.ieee.org/document/8474387/)

#### Paper: Efficient Golf Ball Detection and Tracking Based on CNNs and Kalman Filter
- **Authors:** (Multiple)
- **Year:** 2020
- **Publication:** arXiv:2012.09393
- **Key Contributions:** Two-stage detection scheme employing Kalman filters to predict estimated ball location. After detection on a cropped image patch, the Kalman filter predicts the coordinate for the next frame, which is used to crop the next image for the object detector.
- **Methods:** CNN-based detection + Kalman filter prediction. Dynamic ROI for tracking. High-speed stereo vision system using circle detection.
- **Relevance:** Demonstrates the Kalman filter + CNN pipeline that could be adapted for club head tracking.
- **Link:** [arXiv:2012.09393](https://arxiv.org/abs/2012.09393)

#### Paper: An Analysis of Kalman Filter based Object Tracking Methods for Fast-Moving Tiny Objects
- **Authors:** (Multiple)
- **Year:** 2025
- **Publication:** arXiv:2509.18451
- **Key Contributions:** Comprehensive analysis of Kalman filter variants for tracking fast-moving tiny objects (e.g., table tennis balls). Addresses the challenge where small size and rapid motion make detection and tracking arduous.
- **Link:** [arXiv:2509.18451](https://arxiv.org/html/2509.18451v1)

### 1.4 Optical Flow Applied to Sports

#### Paper: RAFT: Recurrent All-Pairs Field Transforms for Optical Flow
- **Authors:** Zachary Teed, Jia Deng
- **Year:** 2020
- **Publication:** ECCV 2020 (Best Paper Award)
- **Key Contributions:** New deep network architecture for optical flow. Extracts per-pixel features, builds multi-scale 4D correlation volumes for all pairs of pixels, and iteratively updates a flow field through a recurrent unit.
- **Results:** On KITTI: F1-all error of 5.10% (16% reduction from prior best). On Sintel: EPE of 2.855 pixels (30% reduction). Strong cross-dataset generalization with high efficiency.
- **Relevance:** State-of-the-art dense optical flow that could provide sub-pixel motion estimation for club head displacement.
- **Link:** [arXiv:2003.12039](https://arxiv.org/abs/2003.12039) | [GitHub](https://github.com/princeton-vl/RAFT)

#### Paper: Player Tracking in Sports Video Using Optical Flow Analysis
- **Authors:** Kagalagomb, Dixit
- **Year:** 2016
- **Publication:** Springer
- **Key Contributions:** Survey of optical flow techniques for player tracking across various sports.
- **Link:** [Springer](https://link.springer.com/chapter/10.1007/978-981-10-1675-2_72)

### 1.5 LiDAR/Depth Camera Use in Sports

#### System: GEARS 3D Motion Capture
- **Type:** Commercial optical motion capture
- **Key Features:** Eight 1.7-megapixel cameras at 360 fps. Research-grade accuracy (< 0.2mm). Tracks both golfer and club.
- **Relevance:** Gold-standard benchmark for golf motion capture accuracy.
- **Link:** [Gears Sports](https://www.gearssports.com/golf-swing-biomechanics/)

#### Paper: Smart Motion Reconstruction System for Golf Swing (SMRG)
- **Authors:** (Multiple)
- **Year:** 2015
- **Publication:** Multimedia Tools and Applications (Springer)
- **Key Contributions:** Dynamic Bayesian Network model using Microsoft Kinect as the capturing device. Achieved comparable reconstruction accuracy to commercial optical motion capture systems at a fraction of the cost.
- **Methods:** Kinect depth sensor + Dynamic Bayesian Network for motion reconstruction.
- **Relevance:** Demonstrates depth-camera-based golf analysis as a viable low-cost alternative.
- **Link:** [Springer](https://link.springer.com/article/10.1007/s11042-015-3102-7)

#### System: Sportsbox AI
- **Type:** Commercial AI-powered 3D motion analysis
- **Key Features:** Patent-pending 3D Motion Analysis from standard smartphone video. Real-time corrective feedback. No markers or sensors needed.
- **Relevance:** Demonstrates that commercial solutions are achieving 3D analysis from 2D phone video.
- **Link:** [Sportsbox AI](https://www.sportsbox.ai/)

### 1.6 Pose Estimation Applied to Golf

#### Paper: Commercial Vision Sensors and AI-Based Pose Estimation Frameworks for Markerless Motion Analysis in Sports
- **Authors:** Edriss, Romagnoli, Caprioli, Bonaiuto, Padua, Annino
- **Year:** 2025
- **Publication:** Frontiers in Physiology, Vol. 16
- **Key Contributions:** Comprehensive review of markerless motion analysis systems. Examined OpenPose, MediaPipe, AlphaPose, DensePose, Microsoft Kinect, StereoLabs ZED, and Intel RealSense. Found 2D systems offer economic solutions but face limitations in capturing out-of-plane movements.
- **Relevance:** Directly evaluates the frameworks most applicable to phone-based golf analysis. Based on articles retrieved from PubMed.
- **DOI:** [10.3389/fphys.2025.1649330](https://doi.org/10.3389/fphys.2025.1649330)

#### Paper: A Comprehensive Analysis of ML Pose Estimation Models in Human Movement
- **Authors:** Roggio, Trovato, Sortino, Musumeci
- **Year:** 2024
- **Publication:** Heliyon, Vol. 10, No. 21
- **Key Contributions:** Evaluated OpenPose, PoseNet, AlphaPose, DeepLabCut, HRNet, MediaPipe Pose, BlazePose, EfficientPose, and MoveNet. Highlighted potential for non-invasive, cost-effective assessments in sports and clinical settings.
- **Relevance:** Provides comparative analysis of all major pose estimation frameworks relevant to golf swing analysis. Based on articles retrieved from PubMed.
- **DOI:** [10.1016/j.heliyon.2024.e39977](https://doi.org/10.1016/j.heliyon.2024.e39977)

#### Paper: Gait Analysis Comparison Between Manual Marking, 2D Pose Estimation, and 3D Marker-Based System
- **Authors:** Menychtas, Petrou, Kansizoglou, et al.
- **Year:** 2023
- **Publication:** Frontiers in Rehabilitation Sciences, Vol. 4
- **Key Contributions:** Compared OpenPose and MediaPipe against Vicon 3D motion capture (gold standard). Found pose estimation achieves comparable tracking for large joints but struggles with joints exhibiting small but crucial motion (e.g., ankle).
- **Relevance:** Quantifies the accuracy gap between pose estimation and professional motion capture. Based on articles retrieved from PubMed.
- **DOI:** [10.3389/fresc.2023.1238134](https://doi.org/10.3389/fresc.2023.1238134)

### 1.7 Frame Interpolation and Super Slow-Motion

#### Paper: RIFE: Real-Time Intermediate Flow Estimation for Video Frame Interpolation
- **Authors:** Huang et al.
- **Year:** 2022
- **Publication:** ECCV 2022
- **Key Contributions:** Intermediate Flow Estimation network achieving real-time inference without pre-trained optical flow models. Supports arbitrary-timestep frame interpolation with temporal encoding input. 4-27x faster than SuperSlomo and DAIN with better quality.
- **Methods:** IFNet for direct intermediate flow estimation. Does not rely on pre-trained optical flow backbones. Temporal encoding for arbitrary timestep.
- **Relevance:** Could synthetically increase frame rate of phone video (30fps to 240+ fps equivalent) to improve temporal resolution for speed calculation.
- **Link:** [ECCV 2022 Paper](https://www.ecva.net/papers/eccv_2022/papers_ECCV/papers/136740608.pdf) | [GitHub](https://github.com/hzwer/ECCV2022-RIFE)

#### Paper: FILM: Frame Interpolation for Large Motion
- **Authors:** (Google Research)
- **Year:** 2022
- **Publication:** ECCV 2022
- **Key Contributions:** Frame interpolation specifically designed for large motion scenarios. Multi-scale feature extraction and flow estimation.
- **Relevance:** Golf club head moves very fast between frames, making large-motion interpolation critical.
- **Link:** [Springer](https://link.springer.com/chapter/10.1007/978-3-031-20071-7_15)

#### Paper: Slow-Motion Video Synthesis for Basketball Using Frame Interpolation
- **Authors:** (Multiple)
- **Year:** 2024
- **Publication:** arXiv:2511.11644
- **Key Contributions:** Applied RIFE with domain-specific fine-tuning for sports slow-motion generation. Demonstrated that fine-tuned RIFE surpasses baselines while maintaining real-time throughput.
- **Relevance:** Direct precedent for using frame interpolation in sports analysis.
- **Link:** [arXiv:2511.11644](https://arxiv.org/html/2511.11644)

### 1.8 Sports Analytics Computer Vision (Broader)

#### Paper: Football Sports Video Tracking Based on YOLOv5 and DeepSORT
- **Authors:** (Multiple)
- **Year:** 2025
- **Publication:** Discover Applied Sciences (Springer)
- **Key Contributions:** Combines YOLOv5 with DeepSORT for player tracking and speed estimation using optical flow for camera motion compensation.
- **Link:** [Springer](https://link.springer.com/article/10.1007/s42452-025-07116-9)

#### Paper: CaddieSet: A Golf Swing Dataset with Human Joint Features and Ball Information
- **Authors:** (Multiple)
- **Year:** 2025
- **Publication:** arXiv:2508.20491
- **Key Contributions:** Extracts joint information from golf swing videos with ball trajectory data, segmenting swings into eight phases using CV.
- **Link:** [arXiv:2508.20491](https://arxiv.org/html/2508.20491v1)

---

## 2. Computer Vision Techniques Deep Dive

### 2.1 Optical Flow

Optical flow estimates the apparent motion of objects between consecutive frames by analyzing pixel intensity changes. For golf club head tracking at 100+ mph, this is a primary technique for measuring displacement.

#### 2.1.1 Lucas-Kanade (Sparse Optical Flow)
- **Type:** Sparse (tracks selected feature points only)
- **How it works:** Assumes constant flow within a small window (~15x15 pixels) around each tracked point. Solves the optical flow equation using least squares on the spatial intensity gradient. Uses iterative refinement and image pyramids (typically 3 levels) to handle larger displacements.
- **Strengths for golf:** Computationally lightweight (real-time capable on mobile). Good for tracking specific points like the club head tip if it can be reliably detected. Pyramid approach handles moderate displacements.
- **Limitations for golf:** Assumes small inter-frame motion -- at 30fps, a club head at 100mph moves ~60+ pixels per frame, which exceeds the small-motion assumption. Requires good feature points to track, and the club head may not have sufficient texture. Fails with motion blur.
- **OpenCV Function:** `cv2.calcOpticalFlowPyrLK()`
- **Verdict for this project:** Marginal. Requires higher frame rates (120+ fps) or frame interpolation to bring displacement into range. Could work for tracking body landmarks (wrist, shoulder) which move slower.

#### 2.1.2 Farneback (Dense Optical Flow)
- **Type:** Dense (computes flow for every pixel)
- **How it works:** Approximates the neighborhood of each pixel with a polynomial expansion (quadratic function). Estimates displacement fields by analyzing how these polynomial representations change between frames.
- **Strengths for golf:** Provides motion field for entire frame, useful for identifying regions of high motion (the club). No need for explicit feature detection. Good for detecting where the club is moving fastest.
- **Limitations for golf:** Computationally expensive (not real-time on mobile at full resolution). Same large-displacement problems as Lucas-Kanade. Sensitive to motion blur.
- **OpenCV Function:** `cv2.calcOpticalFlowFarneback()`
- **Verdict for this project:** Useful for swing phase detection (identifying when fast motion begins/ends) rather than precise speed measurement. Could identify the club region via maximum flow magnitude.

#### 2.1.3 RAFT (Deep Learning Dense Optical Flow)
- **Type:** Dense, deep learning-based
- **How it works:** Three-stage architecture: (1) Feature Encoder extracts per-pixel features from both frames, (2) Correlation Volume builds multi-scale 4D correlation volumes for all pixel pairs, (3) Recurrent Update iteratively refines flow estimates using GRU units and correlation lookups.
- **Strengths for golf:** Handles large displacements far better than classical methods (30% better accuracy on benchmarks). Sub-pixel accuracy. Strong generalization across domains.
- **Limitations for golf:** Requires GPU for real-time inference. Pre-trained models may not generalize perfectly to motion-blurred club heads. Processing time of ~100ms per frame pair.
- **Results:** F1-all error of 5.10% on KITTI, EPE of 2.855 pixels on Sintel.
- **Verdict for this project:** Best accuracy option if GPU inference is available. Could be run offline on captured video. The large-motion capability makes it the most suitable optical flow method for 100+ mph club head tracking.

### 2.2 Background Subtraction

Background subtraction separates moving foreground objects from the static (or slowly changing) background. For golf, this isolates the golfer and club from the driving range/course.

#### 2.2.1 MOG2 (Mixture of Gaussians 2)
- **How it works:** Models each pixel's background as a mixture of K Gaussian distributions. Updates the model over time. Pixels whose current value has low probability under the background model are classified as foreground.
- **Parameters:** `history` (number of frames affecting the model), `varThreshold` (threshold for background classification), `detectShadows` (shadow detection capability).
- **Strengths for golf:** Fast (suitable for real-time processing). Adapts to gradual lighting changes. Shadow detection available. Good for isolating the moving golfer/club from a static background.
- **Limitations for golf:** Requires several frames to build a stable background model. Performance degrades with moving camera. The "history" parameter needs tuning -- smaller values for fast movement, larger for detecting subtle motion. Does not distinguish between different moving objects.
- **OpenCV:** `cv2.createBackgroundSubtractorMOG2()`
- **Verdict for this project:** Good for the "is there motion?" question (swing onset detection). Effective for isolating the club swing region when the camera is stationary (tripod-mounted phone). Not suitable for precise club head localization.

#### 2.2.2 KNN (K-Nearest Neighbors)
- **How it works:** Non-parametric approach that classifies each pixel based on its k-nearest neighbors in a sample history.
- **Strengths for golf:** Better with rapidly changing backgrounds (e.g., trees blowing, other golfers). Higher similarity to human segmentation in tests.
- **Limitations for golf:** Slower than MOG2. Same general limitations as above.
- **OpenCV:** `cv2.createBackgroundSubtractorKNN()`
- **Verdict for this project:** Preferred over MOG2 when the background is dynamic (outdoor range with wind, people walking). Otherwise, MOG2 is preferred for speed.

### 2.3 Template Matching

Template matching searches for a small template image (the object of interest) within a larger image by sliding the template across the image and computing a similarity score at each position.

- **How it works:** Given a template patch of the club head, slide it across each frame and compute normalized cross-correlation (NCC) or sum of squared differences (SSD). The peak in the similarity map indicates the club head location.
- **OpenCV Function:** `cv2.matchTemplate()` with methods like `cv2.TM_CCOEFF_NORMED`
- **Strengths for golf:** Simple to implement. Works well if the club head appearance is consistent and distinct.
- **Limitations for golf:** Extremely sensitive to scale changes (club head appears larger/smaller as it moves closer/farther from camera). Cannot handle rotation (the club rotates significantly during the swing). Fails completely with motion blur (the template becomes unrecognizable). Not robust to lighting changes. Slow for large search areas.
- **Enhancement:** Can be combined with pyramid Lucas-Kanade: use template matching for initial detection, then track with pyrLK.
- **Verdict for this project:** Largely unsuitable as a primary tracking method for the fast-moving club head. Could be used for initial club head detection in the address position (before the swing starts) when the club is stationary and well-defined.

### 2.4 Contour Detection and Tracking

Contour detection identifies the boundaries of objects in an image by finding curves that follow edges.

- **Pipeline:** (1) Convert to grayscale, (2) Apply Gaussian blur, (3) Edge detection (Canny) or binary thresholding, (4) `cv2.findContours()`, (5) Filter by area/shape, (6) Track across frames.
- **Canny Edge Detection:** Uses gradient magnitude and non-maximum suppression with hysteresis thresholding to find edge pixels. Good for finding the club shaft outline.
- **Strengths for golf:** Works with background subtraction output (find contours of foreground blobs). Can estimate club head position as the endpoint of the detected club shaft contour. Morphological operations (dilation, erosion) can clean up noisy detections.
- **Limitations for golf:** Club head at speed creates severe motion blur, making edge detection unreliable. Contours merge when objects overlap. Matching contours across frames is unreliable for fast, erratic motion. The thin club shaft may not produce robust contours.
- **Verdict for this project:** Useful as a secondary technique. After background subtraction isolates the swing region, contour analysis could help estimate club orientation and endpoint. Not reliable as the primary tracking method at impact speeds.

### 2.5 Blob Detection

Blob detection finds regions in an image that differ in brightness or color compared to surrounding regions.

- **OpenCV SimpleBlobDetector:** (1) Thresholds the image at multiple levels (minThreshold to maxThreshold, stepped by thresholdStep), (2) Finds connected white pixel groups in each binary image, (3) Computes centers and merges blobs closer than minDistBetweenBlobs, (4) Filters by area, circularity, convexity, inertia, color.
- **Strengths for golf:** If the club head has a distinctive color or reflective marker, blob detection can locate it efficiently. Simple configuration through filter parameters.
- **Limitations for golf:** Requires the club head to form a distinct blob (difficult with motion blur at high speed). The club head is small and may not meet minimum area thresholds. Background clutter creates false positives. For single-blob scenarios, `findContours` is faster.
- **Verdict for this project:** Could work if a colored marker/sticker is placed on the club head. Without a marker, the natural club head appearance is unlikely to form a reliable blob at high speeds. Better suited for detecting the stationary ball or a brightly-colored club grip.

### 2.6 Kalman Filtering for Motion Prediction

The Kalman filter is a recursive state estimator that predicts the next state of a system (position, velocity) and then corrects the prediction using a new measurement.

- **Two-step process:**
  1. **Predict:** Estimate the current state (position, velocity, acceleration) from the previous state using a motion model (constant velocity or constant acceleration).
  2. **Update:** Combine the prediction with the new measurement (detected position), weighting each by their uncertainty (covariance).
- **State vector for club head:** `[x, y, vx, vy, ax, ay]` (position, velocity, acceleration in pixel space)
- **Strengths for golf:**
  - Handles missed detections: If the club head is not detected in a frame (motion blur, occlusion), the Kalman filter provides a predicted position.
  - Smooths noisy detections: Averages out jitter in frame-by-frame position estimates.
  - Predicts future positions: Narrows the search region for the next frame's detection (dynamic ROI).
  - Computationally trivial: Runs in microseconds.
- **Limitations for golf:**
  - Assumes linear motion model (constant velocity or acceleration). The golf swing is highly nonlinear (acceleration changes dramatically during downswing).
  - Extended Kalman Filter (EKF) or Unscented Kalman Filter (UKF) needed for nonlinear dynamics.
  - Requires a detection method to provide measurements; does not detect objects itself.
- **Verdict for this project:** Essential companion to any detection method. Should be paired with whatever detector is chosen (YOLO, blob, contour) to handle dropped frames and provide smooth trajectory estimation. The combination of CNN detection + Kalman prediction has been proven effective for golf ball tracking (arXiv:2012.09393) and applies equally to club head tracking.

### 2.7 Deep Learning Object Detection (YOLO, SSD)

#### 2.7.1 YOLO (You Only Look Once)
- **How it works:** Single-pass detection. Divides the image into a grid, predicts bounding boxes and class probabilities for each cell simultaneously. Current versions (YOLOv8, YOLOv11) use CSPDarknet backbone, PANet neck, and decoupled head.
- **Speed:** 155+ FPS on GPU. YOLOv8-nano can run on mobile devices at 30+ FPS.
- **Strengths for golf:**
  - Can be trained to detect "golf club head" as a custom class.
  - Real-time inference enables live tracking.
  - Bounding box output gives position for speed calculation.
  - Transfer learning from COCO dataset ("sports ball" class exists) accelerates training.
- **Limitations for golf:**
  - The club head is extremely small in the frame (~10-30 pixels).
  - Motion blur at high speeds makes the club head look like a streak, not a distinct object.
  - Requires labeled training data (bounding boxes on club heads across many frames).
  - Detection accuracy drops sharply for very small objects.
  - May need tiling or crop-and-detect strategies.
- **Recommended approach:** Train YOLOv8-small on cropped ROI patches centered on the expected swing arc. Use Kalman filter to predict ROI for next frame.

#### 2.7.2 SSD (Single Shot MultiBox Detector)
- **How it works:** Similar single-pass approach to YOLO but uses multi-scale feature maps from different layers of the backbone CNN to detect objects at various sizes.
- **Strengths:** Good at detecting objects at multiple scales. Faster than two-stage detectors.
- **Limitations:** Generally less accurate than modern YOLO variants for small objects. Less community support/tooling than YOLO ecosystem.
- **Verdict:** YOLO is preferred over SSD for this application due to better small-object detection in recent versions and superior tooling (Ultralytics).

### 2.8 Point Tracking (TAPIR, CoTracker)

Modern learned point trackers track arbitrary pixels across video frames, handling occlusions and appearance changes.

#### 2.8.1 TAPIR (Tracking Any Point with per-frame Initialization and temporal Refinement)
- **Developer:** Google DeepMind
- **How it works:** Initializes trajectory from TAP-Net, then refines using a PIPs-inspired architecture. Per-frame initialization enables robustness.
- **Performance:** ~20% absolute improvement in Average Jaccard on DAVIS benchmark over prior methods. Tracks 256 points at 40 FPS on 256x256 video.
- **Strengths for golf:** Can track a user-specified point on the club head across the entire swing. Handles occlusion (club behind body). Does not need training data specific to golf.
- **Limitations:** Requires GPU. May lose the point during extreme motion blur. 256x256 resolution is low for precise measurements.
- **Link:** [TAPIR](https://deepmind-tapir.github.io/) | [GitHub](https://github.com/google-deepmind/tapnet)

#### 2.8.2 CoTracker / CoTracker3
- **Developer:** Meta AI (FAIR)
- **How it works:** Transformer-based model that tracks dense points jointly (not independently), accounting for their correlations. CoTracker3 (2024) uses pseudo-labeling with 1000x less training data.
- **Strengths for golf:** Joint tracking of multiple points (club head, shaft, hands) improves robustness. Can track occluded points and points outside the camera view. State-of-the-art accuracy.
- **Publication:** ECCV 2024
- **Link:** [CoTracker](https://co-tracker.github.io/) | [GitHub](https://github.com/facebookresearch/co-tracker)

#### Verdict for this project:
Point trackers are the **most promising approach** for club head speed measurement from phone video. The workflow would be:
1. User marks the club head in the first frame (or auto-detect at address position)
2. TAPIR/CoTracker tracks that point through the entire swing
3. Pixel displacement between frames gives speed data
4. Kalman filter smooths the trajectory

The key concern is whether these trackers can follow through extreme motion blur at impact. Testing with real golf swing video is needed.

### 2.9 Frame Interpolation (FILM, RIFE)

Frame interpolation synthesizes intermediate frames between existing ones, effectively increasing the video frame rate.

#### 2.9.1 RIFE (Real-Time Intermediate Flow Estimation)
- **How it works:** IFNet directly estimates intermediate optical flow without pre-trained flow models. Supports arbitrary timestep interpolation via temporal encoding. Architecture enables real-time inference.
- **Speed:** 4-27x faster than SuperSlomo and DAIN.
- **Interpolation factor:** Can generate 2x, 4x, 8x, or arbitrary intermediate frames.
- **Strengths for golf:** Converting 30fps to 240fps (8x) brings inter-frame displacement into manageable range. At 30fps, a 100mph club head moves ~67 pixels/frame. At 240fps synthesized, this drops to ~8 pixels/frame -- well within optical flow and tracker capabilities.
- **Limitations:** Interpolated frames are synthetic estimates, not real observations. The interpolation itself relies on motion estimation, creating circular dependency. Very fast motion with blur may produce artifacts. Interpolation quality degrades with larger motion between source frames.
- **Link:** [GitHub](https://github.com/hzwer/ECCV2022-RIFE)

#### 2.9.2 FILM (Frame Interpolation for Large Motion)
- **How it works:** Multi-scale feature extraction with flow estimation specifically designed for large displacements between frames.
- **Strengths for golf:** Explicitly handles the large-motion scenario present in golf swings. Better suited than RIFE for extreme inter-frame displacement.
- **Link:** [Springer](https://link.springer.com/chapter/10.1007/978-3-031-20071-7_15)

#### Verdict for this project:
Frame interpolation is a **critical preprocessing step** if working with standard phone video (30-60fps). The recommended pipeline is:
1. Capture video at the phone's maximum frame rate (ideally 120-240fps if available, 60fps minimum)
2. Apply RIFE or FILM to interpolate to higher effective frame rate
3. Run point tracking or optical flow on the interpolated video
4. Be aware that speed measurements from interpolated frames carry additional uncertainty

**Important caveat:** The interpolated positions are estimated, not measured. Speed calculations from interpolated frames should be treated as approximations and validated against known-speed test cases.

---

## 3. Speed Calculation Math Deep Dive

### 3.1 Fundamental Formula

The core formula for speed from video:

```
speed = distance_real / time_between_frames
```

Where:
- `distance_real` = real-world distance (meters) the club head traveled between frames
- `time_between_frames` = 1 / FPS (seconds)

The challenge is converting pixel displacement to real-world distance.

### 3.2 Pixel Displacement to Real-World Distance

#### Step 1: Measure Pixel Displacement
```
displacement_pixels = sqrt((x2 - x1)^2 + (y2 - y1)^2)
```
Where (x1, y1) and (x2, y2) are the club head positions in consecutive frames (in pixels).

#### Step 2: Establish Scale Factor (pixels per meter)

**Method A: Known Reference Object**
Place an object of known size in the frame at the same depth plane as the club head during impact.

```
scale_factor = known_distance_pixels / known_distance_meters
```

Example: A golf club is ~45 inches (1.143m) long. At address position, measure the club length in pixels:
```
scale = club_length_pixels / 1.143  # pixels per meter
```

**Method B: Camera Intrinsic Calibration**
Using the pinhole camera model:
```
distance_real = (displacement_pixels * Z) / f
```
Where:
- `Z` = distance from camera to the club head (meters)
- `f` = focal length (pixels) = focal_length_mm * (image_width_pixels / sensor_width_mm)

For a typical smartphone:
- Sensor width: ~6mm
- Focal length: ~4.5mm
- Image width: 1920 pixels
- f = 4.5 * (1920 / 6) = 1440 pixels

If club head is 3 meters from camera:
```
distance_real = (displacement_pixels * 3.0) / 1440
```

#### Step 3: Calculate Speed
```
speed_m_per_s = distance_real / (1 / FPS)
speed_mph = speed_m_per_s * 2.237
```

### 3.3 Complete Example Calculation

**Setup:**
- Camera: iPhone at 240fps, 1080p
- Distance to golfer: 3 meters (measured)
- Club head displacement between frames: 15 pixels
- Focal length: 1440 pixels (estimated)

```
distance_real = (15 * 3.0) / 1440 = 0.03125 meters per frame
time_per_frame = 1/240 = 0.00417 seconds
speed = 0.03125 / 0.00417 = 7.5 m/s = 16.8 mph
```

Wait -- that is far too slow. For a 100 mph swing at 240fps:
```
100 mph = 44.7 m/s
distance_per_frame = 44.7 * (1/240) = 0.186 meters
pixels_per_frame = 0.186 * 1440 / 3.0 = 89.3 pixels
```

So at 240fps, the club head moves ~89 pixels per frame at 100 mph. At 30fps, that would be ~715 pixels -- likely exceeding the frame entirely and creating extreme blur.

**Key insight:** 240fps is the **minimum viable frame rate** for tracking a 100+ mph club head. At 120fps, displacement is ~179 pixels/frame -- possible but challenging. At 30fps, the club head traverses most of the frame in a single frame, making tracking nearly impossible without interpolation.

### 3.4 Perspective Correction and Homography

#### The Problem
A camera views the swing from a fixed angle. The club head moves in 3D space, but the camera captures a 2D projection. Movement toward/away from the camera is compressed (foreshortened), and movement at angles is distorted.

#### Homography Matrix
A homography `H` is a 3x3 matrix that maps points in one plane to corresponding points in another plane:

```
[x']     [h11 h12 h13] [x]
[y'] = H [h21 h22 h23] [y]
[w']     [h31 h32 h33] [1]
```

Where `(x'/w', y'/w')` are the corrected coordinates.

Requires 4+ point correspondences between known real-world positions and their pixel positions to solve for H.

#### Practical Calibration for Golf
1. Place markers at known positions on the ground in the swing plane
2. Compute the homography from these correspondences
3. Apply the homography to transform pixel coordinates to real-world coordinates in the swing plane

**OpenCV implementation:**
```python
H, status = cv2.findHomography(src_points, dst_points)
real_coords = cv2.perspectiveTransform(pixel_coords, H)
```

### 3.5 Camera Angle Considerations

#### Front-On View (Face-On)
- Camera faces the golfer from the front (target line).
- Club head moves primarily left-to-right and up-to-down in the frame.
- Depth movement (toward/away from camera) is compressed.
- **Correction:** Swing plane is roughly 45-60 degrees from vertical. True 3D displacement is approximately:
  ```
  distance_3D = distance_2D / cos(angle_out_of_plane)
  ```
  For a typical swing plane of 45 degrees from the camera plane:
  ```
  distance_3D = distance_2D / cos(45) = distance_2D * 1.414
  ```

#### Down-the-Line View (DTL)
- Camera positioned behind the golfer along the target line.
- Sees the swing plane nearly edge-on.
- Club head motion is mostly in the plane of the camera.
- **Better for speed measurement** because less out-of-plane correction is needed.
- **Correction factor:** Much smaller, ~1.0-1.1 depending on exact camera angle.

#### Recommendation for This App
**Down-the-line view is preferred** for speed measurement accuracy. The swing plane is more aligned with the camera image plane, reducing perspective errors. If front-on is used, apply a correction factor of ~1.3-1.5 depending on the golfer's swing plane angle.

### 3.6 Error Sources and Mitigation

| Error Source | Magnitude | Mitigation |
|---|---|---|
| **Frame rate too low** | Dominant error. At 30fps, club position is unknown between frames | Use highest available FPS (240 preferred). Frame interpolation as fallback. |
| **Motion blur** | Club head becomes an elongated streak, centroid is ambiguous | Short exposure time. Use streak endpoints. Image deblurring preprocessing. |
| **Incorrect scale factor** | Directly proportional error (10% scale error = 10% speed error) | Multiple reference measurements. Use club length at address. |
| **Camera distance uncertainty** | Proportional error through pinhole model | Measure camera distance. Use LiDAR sensor on newer phones for distance. |
| **Perspective/angle error** | 10-40% depending on view angle | Use DTL view. Apply perspective correction. Calibrate with known markers. |
| **Rolling shutter** | Phone CMOS sensors scan top-to-bottom, fast objects appear skewed | Use phones with global shutter or fast rolling shutter. Correct in post. |
| **Lens distortion** | 1-5% at frame edges | Apply camera calibration (checkerboard pattern) to undistort. |
| **Pixel quantization** | +-0.5 pixel per measurement = small for large displacements | Sub-pixel estimation via optical flow or template matching. |
| **Interpolation artifacts** | Unknown -- depends on motion and algorithm | Validate against known speeds. Use interpolation only as enhancement, not primary measurement. |

### 3.7 Recommended Accuracy Targets

Based on the literature:
- GEARS commercial system: < 0.2mm position accuracy
- Stereo camera + inertial sensor: ~3.6cm average accuracy
- Phone-based CV (this project): Target +-5-10 mph accuracy initially, refine to +-3 mph with calibration

For reference, a 100 mph driver swing speed corresponds to approximately:
- Ball speed: ~150 mph (1.5 smash factor)
- Carry distance: ~230 yards
- Each 1 mph change in club speed ~ 2.3 yards of distance

---

## 4. Swing Detection Automation

### 4.1 Detecting Swing Readiness (Pre-Swing)

The system needs to automatically detect when a golfer is ready to swing, start recording/analysis, and identify the swing phases.

#### 4.1.1 Stillness Detection
- **Method:** Compute frame differencing or optical flow magnitude over a region of interest.
- **Threshold:** When average pixel change drops below a threshold for N consecutive frames, the golfer is "still" (address position).
- **Implementation:**
  ```
  diff = abs(frame_current - frame_previous)
  motion_score = mean(diff[roi])
  if motion_score < threshold for N frames: still = True
  ```

#### 4.1.2 Pose-Based Readiness
- **Method:** Use MediaPipe Pose to detect the golfer's body landmarks (33 keypoints).
- **Criteria for "address" position:**
  - Both hands are together (wrist keypoints close together) -- grip detected
  - Arms extended downward (elbow angle > 150 degrees)
  - Torso slightly bent forward (hip-shoulder-knee angle)
  - Feet shoulder-width apart (ankle keypoint separation)
  - Head looking down (nose keypoint below shoulder keypoints)
- **Implementation:**
  ```python
  import mediapipe as mp
  pose = mp.solutions.pose.Pose()
  results = pose.process(frame_rgb)
  wrist_dist = distance(results.pose_landmarks[15], results.pose_landmarks[16])
  if wrist_dist < grip_threshold: grip_detected = True
  ```

#### 4.1.3 Combined Approach (Recommended)
1. Detect a person in the frame (YOLO or MediaPipe)
2. Verify pose matches "golfer at address" (pose estimation)
3. Confirm stillness for 1-2 seconds (frame differencing)
4. Arm the swing detector

### 4.2 Detecting Swing Onset (Backswing Start)

#### 4.2.1 Frame Differencing for Motion Onset
- **Method:** Compute absolute difference between consecutive frames. When the motion score exceeds a threshold after a period of stillness, the swing has begun.
- **Implementation:**
  ```
  motion = sum(abs(frame[t] - frame[t-1])) / num_pixels
  if was_still and motion > onset_threshold: swing_started = True
  ```
- **Refinement:** Use a moving average to avoid false triggers from noise:
  ```
  smoothed_motion = moving_average(motion_scores, window=5)
  ```

#### 4.2.2 Wrist Velocity Detection
- **Method:** Track wrist keypoints via MediaPipe. Compute velocity (pixel displacement per frame). Backswing onset = when wrist velocity first exceeds a threshold after stillness.
- **Advantage:** More specific than whole-frame differencing. Ignores irrelevant motion (wind, other people).

### 4.3 Detecting Swing Phases

Based on SwingNet (GolfDB), the canonical eight phases are:

1. **Address** -- Stillness, golfer at setup
2. **Toe-up** -- Club shaft parallel to ground (backswing)
3. **Mid-backswing** -- Club approximately 45 degrees past toe-up
4. **Top** -- Maximum backswing position (minimum wrist velocity, direction reversal)
5. **Mid-downswing** -- Club shaft parallel to ground (downswing)
6. **Impact** -- Club contacts ball (maximum velocity point)
7. **Mid-follow-through** -- Club shaft parallel to ground (follow-through)
8. **Finish** -- Swing complete, golfer in finish position

#### Detection Methods:
- **Velocity extrema:** Top of backswing = local minimum in wrist/hand velocity. Impact = local maximum.
- **Direction reversal:** Track the x-component of hand movement. Backswing moves one direction, downswing reverses.
- **Shoulder rotation:** Track shoulder keypoints. Maximum rotation difference between shoulders and hips indicates top of backswing.

### 4.4 Detecting Swing Completion

#### 4.4.1 Velocity Drop
- After impact, the club decelerates through the follow-through.
- **Detection:** When hand/wrist velocity drops below a threshold after having exceeded impact velocity, the swing is complete.
- **Implementation:**
  ```
  if velocity > impact_threshold: impact_detected = True
  if impact_detected and velocity < completion_threshold: swing_complete = True
  ```

#### 4.4.2 Pose-Based Finish Detection
- MediaPipe detects the "finish" pose:
  - Hands high (wrist keypoints above shoulder)
  - Weight on front foot (front ankle keypoint lower/more weighted)
  - Torso rotated fully toward target
  - Hips facing target line

#### 4.4.3 Return to Stillness
- After follow-through, the golfer returns to a stationary position.
- Same stillness detection as pre-swing, but applied after impact detection.

### 4.5 Background Modeling for Dynamic Scenes

#### 4.5.1 Adaptive Background Model
For outdoor driving ranges with wind, other golfers, and changing light:

```python
bg_subtractor = cv2.createBackgroundSubtractorMOG2(
    history=500,       # frames for background model
    varThreshold=50,   # sensitivity (lower = more sensitive)
    detectShadows=True
)

# For each frame:
fg_mask = bg_subtractor.apply(frame)
# Apply morphological operations to clean up:
fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, kernel)  # remove noise
fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, kernel)  # fill gaps
```

#### 4.5.2 ROI-Based Processing
Rather than processing the entire frame:
1. Detect the golfer's bounding box (YOLO or pose estimation)
2. Define a "swing zone" ROI around the golfer
3. Apply background subtraction and motion analysis only within this ROI
4. Reduces computation and false positives from background activity

### 4.6 Recommended Swing Detection Pipeline

```
1. CONTINUOUS MONITORING PHASE
   - Run MediaPipe Pose at reduced resolution (320x240) for efficiency
   - Detect person in frame
   - Check for "golfer at address" pose

2. READY DETECTION
   - Pose matches address position
   - Stillness confirmed (< 2 seconds of no motion)
   - Begin high-resolution capture / buffer last N seconds

3. SWING ONSET
   - Frame differencing exceeds threshold after stillness
   - OR wrist velocity exceeds threshold
   - Begin tracking club head position

4. SWING TRACKING
   - Track club head through backswing, downswing, impact, follow-through
   - Record position at each frame
   - Identify impact frame (maximum velocity)

5. SWING COMPLETION
   - Velocity drops below threshold after impact
   - OR finish pose detected
   - OR return to stillness

6. SPEED CALCULATION
   - Compute displacement between frames surrounding impact
   - Apply scale factor and perspective correction
   - Report speed in mph
```

---

## 5. References

### Academic Papers
1. McNally, W. et al. "GolfDB: A Video Database for Golf Swing Sequencing." CVPR Workshops, 2019. [arXiv:1903.06528](https://arxiv.org/abs/1903.06528)
2. Lee, S.-S. et al. "Dynamic Golf Swing Analysis Framework Based on Efficient Similarity Assessment." Sensors, 2025. [DOI:10.3390/s25227073](https://doi.org/10.3390/s25227073)
3. Taylor, B.F. "Biomechanical Golf Swing Analysis using Markerless Three-Dimensional Skeletal Tracking." MIT Thesis, 2025. [MIT DSpace](https://dspace.mit.edu/handle/1721.1/162530)
4. Teed, Z. and Deng, J. "RAFT: Recurrent All-Pairs Field Transforms for Optical Flow." ECCV 2020. [arXiv:2003.12039](https://arxiv.org/abs/2003.12039)
5. Huang, Z. et al. "Real-Time Intermediate Flow Estimation for Video Frame Interpolation." ECCV 2022. [GitHub](https://github.com/hzwer/ECCV2022-RIFE)
6. Reda, F. et al. "FILM: Frame Interpolation for Large Motion." ECCV 2022. [Springer](https://link.springer.com/chapter/10.1007/978-3-031-20071-7_15)
7. Doersch, C. et al. "TAPIR: Tracking Any Point with per-frame Initialization and temporal Refinement." [Project Page](https://deepmind-tapir.github.io/)
8. Karaev, N. et al. "CoTracker: It Is Better to Track Together." ECCV 2024. [Springer](https://link.springer.com/chapter/10.1007/978-3-031-73033-7_2)
9. "Efficient Golf Ball Detection and Tracking Based on CNNs and Kalman Filter." arXiv:2012.09393. [arXiv](https://arxiv.org/abs/2012.09393)
10. "Tracking a Golf Ball With High-Speed Stereo Vision System." IEEE, 2018. [IEEE Xplore](https://ieeexplore.ieee.org/document/8474387/)
11. Chugh, R. "Golf Club Head Tracking." UCSD CSE 190a. [Report](https://people.cs.uchicago.edu/~rchugh/static/misc/golf/golfReport.pdf)
12. "Golf Swing Motion Tracking Using Inertial Sensors and a Stereo Camera." IEEE, 2013. [IEEE Xplore](https://ieeexplore.ieee.org/document/6642108)
13. "Prototype Design of Speed Detection Mobile Application for Golfer's Swing Movement." [SGU](https://sgu.ac.id/wp-content/uploads/2021/09/Article-12.pdf)
14. Edriss, S. et al. "Commercial Vision Sensors and AI-Based Pose Estimation Frameworks for Markerless Motion Analysis." Frontiers in Physiology, 2025. [DOI:10.3389/fphys.2025.1649330](https://doi.org/10.3389/fphys.2025.1649330)
15. Roggio, F. et al. "A Comprehensive Analysis of ML Pose Estimation Models in Human Movement." Heliyon, 2024. [DOI:10.1016/j.heliyon.2024.e39977](https://doi.org/10.1016/j.heliyon.2024.e39977)
16. Menychtas, D. et al. "Gait Analysis Comparison Between Manual Marking, 2D Pose Estimation, and 3D Marker-Based System." Frontiers in Rehabilitation Sciences, 2023. [DOI:10.3389/fresc.2023.1238134](https://doi.org/10.3389/fresc.2023.1238134)
17. "Smart Motion Reconstruction System for Golf Swing." Multimedia Tools and Applications, Springer, 2015. [Springer](https://link.springer.com/article/10.1007/s11042-015-3102-7)
18. "An Analysis of Kalman Filter based Object Tracking Methods for Fast-Moving Tiny Objects." arXiv:2509.18451, 2025. [arXiv](https://arxiv.org/html/2509.18451v1)
19. "CaddieSet: A Golf Swing Dataset with Human Joint Features and Ball Information." arXiv:2508.20491, 2025. [arXiv](https://arxiv.org/html/2508.20491v1)

### Technical Resources
20. OpenCV Optical Flow Tutorial: [OpenCV Docs](https://docs.opencv.org/3.4/d4/dee/tutorial_optical_flow.html)
21. OpenCV Background Subtraction: [OpenCV Docs](https://docs.opencv.org/4.x/de/de1/group__video__motion.html)
22. Ultralytics YOLOv8 Documentation: [Ultralytics](https://docs.ultralytics.com/modes/track/)
23. MediaPipe Pose: [Google](https://ai.google.dev/edge/mediapipe/solutions/vision/pose_landmarker)
24. Camera Calibration Using Homography: [Galliot](https://galliot.us/blog/camera-calibration-using-homography-estimation/)
25. OpenCV Homography Tutorial: [OpenCV Docs](https://docs.opencv.org/4.x/d9/dab/tutorial_homography.html)
26. Zhang, Z. "A Flexible New Technique for Camera Calibration." Microsoft Research, 1998. [PDF](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/tr98-71.pdf)
27. Camera Calibration in Sports: [Roboflow](https://blog.roboflow.com/camera-calibration-sports-computer-vision/)
28. "Vehicle Speed Estimation Using Computer Vision." [OpenReview](https://openreview.net/pdf?id=Pl7uHR-Oe6l)
29. Ball Tracking with OpenCV: [PyImageSearch](https://pyimagesearch.com/2015/09/14/ball-tracking-with-opencv/)
30. Contour Detection using OpenCV: [LearnOpenCV](https://learnopencv.com/contour-detection-using-opencv-python-c/)

### Commercial Systems Referenced
31. GEARS 3D Motion Capture: [Gears Sports](https://www.gearssports.com/golf-swing-biomechanics/)
32. Sportsbox AI: [Sportsbox](https://www.sportsbox.ai/)
33. GOLFTEC OptiMotion: [GOLFTEC](https://www.golftec.com/optimotion)
34. Qualisys Golf Analysis: [Qualisys](https://www.qualisys.com/analysis/golf/)
35. PiTrac DIY Golf Launch Monitor: [Hackaday](https://hackaday.io/project/195042-pitrac-the-diy-golf-launch-monitor)

---

## Summary of Recommendations for This Project

### Most Promising Technical Approach (Ranked)

1. **Point Tracking (TAPIR/CoTracker) + Kalman Filter** -- Best accuracy potential for tracking a specific point on the club head through the swing. Handles occlusion. Requires GPU for inference (offline processing acceptable).

2. **Pose Estimation (MediaPipe) + Wrist Velocity Proxy** -- Track hand/wrist position as a proxy for club head speed (wrist speed ~ 0.4-0.5x club head speed due to lever effect). Works real-time on mobile. Less accurate but immediately deployable.

3. **Frame Interpolation (RIFE) + Optical Flow (RAFT)** -- Interpolate 30/60fps video to 240fps effective, then use RAFT dense optical flow to measure displacement. Good accuracy but requires significant computation.

4. **YOLO Custom Detection + Kalman Filter** -- Train a small YOLO model to detect the club head, use Kalman filter for prediction between frames. Requires labeled training data.

5. **Background Subtraction + Contour Analysis** -- Simplest approach. Isolate the moving club via MOG2, find the fastest-moving contour endpoint. Least accurate but works without ML models.

### Critical Frame Rate Requirements
| FPS | Club Head Pixels/Frame (100mph, 3m dist) | Viability |
|-----|------------------------------------------|-----------|
| 30  | ~715 pixels | Not viable without interpolation |
| 60  | ~358 pixels | Marginal, requires interpolation |
| 120 | ~179 pixels | Workable with advanced trackers |
| 240 | ~89 pixels | Good for most tracking methods |
| 480 | ~45 pixels | Excellent, even simple methods work |

### Recommended Minimum Viable Product Pipeline
```
Phone Camera (120-240fps)
  -> MediaPipe Pose (swing detection + body tracking)
  -> RIFE Frame Interpolation (if < 240fps)
  -> TAPIR/CoTracker Point Tracking (club head)
  -> Kalman Filter (trajectory smoothing)
  -> Homography Correction (perspective)
  -> Speed Calculation (distance/time)
  -> Display Result
```
