# Computer Vision Research: Golf Club Head Speed Tracking from iPhone Camera

> **Compiled**: March 2026
> **Application**: Tracking a golf club head at 100+ mph from an iPhone camera (240 fps slo-mo)

---

## Table of Contents

1. [Golf Swing Computer Vision Tracking](#1-golf-swing-computer-vision-tracking)
2. [High-Speed Object Tracking with Deep Learning](#2-high-speed-object-tracking-with-deep-learning)
3. [Optical Flow Algorithms for Sports](#3-optical-flow-algorithms-for-sports)
4. [YOLO/SSD for Fast-Moving Small Objects](#4-yolossd-for-fast-moving-small-objects)
5. [Point Tracking Methods (TAPIR, CoTracker, PIPs)](#5-point-tracking-methods-tapir-cotracker-pips)
6. [Motion Blur Speed Estimation](#6-motion-blur-speed-estimation)
7. [Frame Interpolation for Temporal Super-Resolution](#7-frame-interpolation-for-temporal-super-resolution)
8. [Kalman Filtering for Sports Object Tracking](#8-kalman-filtering-for-sports-object-tracking)
9. [Camera-Based Speed Measurement](#9-camera-based-speed-measurement)
10. [Pose Estimation for Golf](#10-pose-estimation-for-golf)
11. [Perspective Correction and Homography](#11-perspective-correction-and-homography)
12. [Background Subtraction for Motion Detection](#12-background-subtraction-for-motion-detection)
13. [Deblurring Algorithms for Motion Blur Recovery](#13-deblurring-algorithms-for-motion-blur-recovery)
14. [Math: Pixel Displacement to Real-World Speed](#14-math-pixel-displacement-to-real-world-speed)
15. [iPhone-Specific Constraints](#15-iphone-specific-constraints)
16. [Recommended Architecture for This App](#16-recommended-architecture-for-this-app)

---

## 1. Golf Swing Computer Vision Tracking

### Key Papers

- **CNN and bi-LSTM based 3D Golf Swing Analysis** -- Uses frontal swing sequence images with CNN feature extraction and bi-LSTM temporal modeling. [Semantic Scholar](https://www.semanticscholar.org/paper/CNN-and-bi-LSTM-based-3D-golf-swing-analysis-by-Ko-Pan/4d5c8f1a92169e23f77ab3544575abe775ab9463)

- **Dynamic Golf Swing Analysis Framework (2025)** -- Image-based pose estimation segments swings into 7 canonical phases (address, takeaway, half, top, impact, release, finish) and evaluates joint keypoint trajectories within each phase. Vision-based approaches are noted as cost-effective, portable, and easy to deploy. [MDPI Sensors](https://www.mdpi.com/1424-8220/25/22/7073)

- **CaddieSet Golf Swing Dataset (2025)** -- Includes joint information and ball information, extracting features from swing videos segmented into 8 phases. Predicts ball speed, spin axis, and direction angle. [arXiv](https://arxiv.org/html/2508.20491v1)

- **AI-Integrated Mobile Golf System (2024)** -- Extracts kinematic data from golf swing videos on standard smartphones and integrates GPT-4 for coaching feedback. [PDF](https://aircconline.com/csit/papers/vol15/csit152206.pdf)

- **GolfPose (ICPR 2024)** -- Transforms regular posture into golf swing posture for pose estimation. [PDF](https://minghanlee.github.io/papers/ICPR_2024_GolfPose.pdf)

- **Visual Golf Club Tracking for Enhanced Swing Analysis** -- Early work specifically on club tracking using visual methods. [ResearchGate](https://www.researchgate.net/publication/240399424_Visual_Golf_Club_Tracking_for_Enhanced_Swing_Analysis)

- **Biomechanical Golf Swing Analysis using Markerless Methods (MIT, 2025)** -- Thesis on markerless motion capture for golf biomechanics. [MIT DSpace](https://dspace.mit.edu/bitstream/handle/1721.1/162530/taylor-bftaylor-sm-sdm-2025-thesis.pdf)

- **Golf Club Head Tracking (UCSD CSE 190a)** -- Early project report specifically addressing club head tracking with computer vision. [PDF](https://people.cs.uchicago.edu/~rchugh/static/misc/golf/golfReport.pdf)

### Key Insight for Our App
Most golf CV research focuses on **pose estimation** (body keypoints) rather than **club head tracking**. The club head is extremely small (a few pixels), moves at 100+ mph, and is heavily motion-blurred. This is a harder sub-problem that requires specialized techniques beyond standard pose estimation.

---

## 2. High-Speed Object Tracking with Deep Learning

### TrackNet Family (Most Relevant)

**TrackNet** is the most directly applicable architecture for our problem. It was designed specifically for tracking high-speed, tiny objects in sports.

- **TrackNet v1** -- Heatmap-based deep learning network that takes multiple consecutive frames as input, learning both ball features and trajectory patterns. Uses VGG-16 backbone. Achieved 99.7% precision, 97.3% recall on tennis ball tracking. [arXiv](https://arxiv.org/abs/1907.03698)

- **TrackNetV2** -- Efficient shuttlecock tracking with improved architecture. [IEEE Xplore](https://ieeexplore.ieee.org/document/9302757/)

- **TrackNetV4 (2024)** -- Enhances fast sports object tracking with Motion Attention Maps, explicitly incorporating motion information to handle partial occlusion and low visibility. [arXiv](https://arxiv.org/abs/2409.14543)

### Hybrid Tracking Approaches

- Combining correlation filter-based tracking, deep learning detection, and background subtraction achieves a balance of speed and accuracy.
- A 500 fps tracking pipeline uses deep-learning detection + K-means color clustering + HFR color-filter tracking. [Viso.ai](https://viso.ai/deep-learning/object-tracking/)

### Small Object Detection Challenges

- Average Precision for tiny objects remains 20-40% in the visible spectrum.
- Key techniques: multi-scale feature extraction, super-resolution, attention mechanisms, transformer architectures.
- Lightweight neural networks and knowledge distillation enable edge/mobile deployment. [ScienceDirect survey](https://www.sciencedirect.com/science/article/pii/S2590005625002425)

### YOLO-MoNet (2024)
Motion-Aware Tiny Object Detection -- improved YOLOv8 focused on motion-specific tiny objects. [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S1877050925016886)

---

## 3. Optical Flow Algorithms for Sports

### Lucas-Kanade (Classical)

- Differential method assuming constant flow in a local pixel neighborhood, solved by least squares.
- **Pyramid-LK** handles large motions by starting at the lowest-resolution level and refining.
- Fast but limited: struggles with large displacements, noise, illumination changes.
- Has been used for vehicle speed estimation. [IEEE](https://ieeexplore.ieee.org/document/10165227/)
- [OpenCV Tutorial](https://docs.opencv.org/4.x/d4/dee/tutorial_optical_flow.html)

### RAFT (Recurrent All-Pairs Field Transforms)

- Iteratively refines flow estimates using a grid of all-pairs correlation volumes.
- Handles large motions and occlusions well.
- Computationally intensive but state-of-the-art accuracy.
- Better suited for offline processing than real-time mobile.

### FlowNet / FlowNet2

- Early CNN-based optical flow; FlowNet2 significantly improved accuracy.
- Faster than RAFT but less accurate on challenging cases.

### Comparison for Golf Club Tracking

| Method | Speed | Large Motion | Accuracy | Mobile-Friendly |
|--------|-------|-------------|----------|----------------|
| Lucas-Kanade (Pyramid) | Very Fast | Moderate | Low | Yes |
| FlowNet2 | Fast | Good | Medium | Possible |
| RAFT | Slow | Excellent | High | No (offline) |

**Recommendation**: Pyramid-LK for real-time on-device; RAFT for offline post-processing.

[Comparison Article](https://eureka.patsnap.com/article/optical-flow-methods-lucas-kanade-vs-deep-learning-raft-flownet)

---

## 4. YOLO/SSD for Fast-Moving Small Objects

### Challenges

- YOLO's grid-based detection lacks resolution for very small objects.
- Fast-moving objects are motion-blurred, reducing feature quality.
- Standard YOLO struggles with objects smaller than 32x32 pixels. [Ultralytics Issue #7109](https://github.com/ultralytics/ultralytics/issues/7109)

### Solutions

- **Motion Augmentation**: Simulating trajectories during training to account for motion blur. A modified YOLOv3 achieved real-time ball detection with specific architecture adjustments for small objects. [MDPI Sensors](https://www.mdpi.com/1424-8220/21/9/3214)

- **YOLO-MoNet**: Improved YOLOv8 variant for motion-specific tiny object detection. [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S1877050925016886)

- **Multi-Object Tracking with YOLO**: Ultralytics supports built-in tracking modes (BoTSORT, ByteTrack). [Ultralytics Docs](https://docs.ultralytics.com/modes/track/)

### Key Takeaway
Standard YOLO is insufficient for a golf club head (~10-20 pixels). A custom-trained model with motion augmentation and specialized anchor boxes would be needed. TrackNet's heatmap approach is likely more suitable.

---

## 5. Point Tracking Methods (TAPIR, CoTracker, PIPs)

### PIPs (Persistent Independent Particles)
- Revisited the Particle Video method with deep learning.
- Extracts correlation maps between frames and refines track estimates.
- Tracks points independently.

### TAPIR (Google DeepMind)
- Feed-forward tracker combining TAP-Net initialization with PIPs refinement.
- **Matching stage**: Independently locates candidate point matches on every frame.
- **Refinement stage**: Updates trajectory and query features based on local correlations.
- ~20% absolute improvement in Average Jaccard on TAP-Vid/DAVIS benchmark.
- [Project Page](https://deepmind-tapir.github.io/) | [GitHub](https://github.com/google-deepmind/tapnet)

### CoTracker (Meta/Facebook Research)
- Transformer-based model tracking dense points **jointly** across video.
- Joint tracking yields significantly higher accuracy than independent tracking.
- [Project Page](https://co-tracker.github.io/) | [GitHub](https://github.com/facebookresearch/co-tracker)

### CoTracker3 (2024)
- Semi-supervised training with pseudo-labels from real videos.
- Bridges the synthetic-to-real domain gap.
- [Project Page](https://cotracker3.github.io/) | [arXiv](https://arxiv.org/html/2410.11831v1)

### TrackIME (NeurIPS 2024)
- Enhanced Video Point Tracking via Instance Motion Estimation.
- [NeurIPS Paper](https://proceedings.neurips.cc/paper_files/paper/2024/file/7bf421a1370d5d3fae9ddbcbaf746143-Paper-Conference.pdf)

### Applicability to Golf Club Tracking
Point trackers are promising for tracking a user-selected point on the club head. However:
- They assume the point remains **visible** -- motion blur may cause the point to vanish.
- CoTracker's joint tracking could leverage the club shaft + head relationship.
- These models are too heavy for real-time mobile inference; best for offline analysis.

---

## 6. Motion Blur Speed Estimation

### Core Principle
When there is relative motion between camera and object during exposure, the blur length is **directly proportional** to the object's displacement during the exposure interval. If blur parameters and camera geometry are known, speed can be estimated.

### Key Approaches

- **Blur Parameter Estimation**: Segment the target region, estimate blur length and angle from the motion-blurred subimage, deblur, then calculate speed from imaging geometry + blur extent. Vehicle speed estimates achieved within 5% of actual speeds. [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0263224110001326)

- **CNN-Based Blur Estimation**: Deep learning estimates blur length and angle, combined with particle filter for tracking. [IET Image Processing](https://ietresearch.onlinelibrary.wiley.com/doi/full/10.1049/ipr2.12189)

- **Tracking by Deblatting (IJCV 2021)**: Simultaneously recovers trajectory, shape, and appearance of fast-moving objects from their motion blur streaks. The blur kernel is constrained to lie on a 1D curve representing the intra-frame trajectory. Achieves higher temporal resolution than conventional trackers. [Springer IJCV](https://link.springer.com/article/10.1007/s11263-021-01480-w)

### Speed from Blur Formula

```
v = blur_length_pixels * pixel_size_meters / exposure_time
```

Where:
- `blur_length_pixels` = length of the motion blur streak in pixels
- `pixel_size_meters` = real-world size corresponding to one pixel at the object's depth
- `exposure_time` = camera shutter speed (e.g., 1/240s for 240fps)

### Relevance to Golf
At 100 mph, a golf club head moves ~1.85 inches per frame at 240 fps. At typical filming distances, this produces a significant blur streak that **encodes speed information**. The Deblatting approach is particularly relevant since it can recover sub-frame trajectories.

---

## 7. Frame Interpolation for Temporal Super-Resolution

### RIFE (Real-Time Intermediate Flow Estimation)

- Neural network (IFNet) estimates intermediate flows end-to-end.
- 30+ FPS for 2x interpolation at 720p on a 2080Ti GPU.
- Supports arbitrary-timestep interpolation.
- 4-27x faster than SuperSlomo and DAIN with better results.
- [GitHub](https://github.com/hzwer/ECCV2022-RIFE) | [arXiv](https://arxiv.org/abs/2011.06294)

### FILM (Frame Interpolation for Large Motion)

- Google's model specifically designed for large motion interpolation.
- Uses a multi-scale feature extractor with shared weights.

### Sports-Specific Applications

- Domain-specific fine-tuning of RIFE for basketball achieved superior fidelity and real-time speed for slow-motion synthesis. [arXiv](https://arxiv.org/html/2511.11644)
- Two-stage pipelines combine spatial upscaling (Real-ESRGAN) with temporal interpolation (RIFE).

### Application to Golf Club Tracking

Temporal super-resolution is critical:
- iPhone at 240 fps captures a frame every 4.17 ms.
- At 100 mph, the club head moves ~18.5 cm (7.3 inches) between frames.
- Interpolating 240 fps to 960 fps or 1920 fps reduces inter-frame displacement to 4.6 cm or 2.3 cm respectively.
- **Caution**: Interpolated frames are synthesized, not measured. Speed estimates from interpolated frames have additional uncertainty.

---

## 8. Kalman Filtering for Sports Object Tracking

### How Kalman Filters Work

Two-step recursive algorithm:
1. **Predict**: Estimate current state from previous state + elapsed time.
2. **Update**: Combine prediction with noisy measurement to produce refined estimate.

### Benefits for Sports Tracking

- Predicts object location when detection fails (occlusion, blur).
- Reduces noise from inaccurate detections.
- Facilitates multi-object track association.
- [MATLAB Tutorial](https://www.mathworks.com/help/vision/ug/using-kalman-filter-for-object-tracking.html)

### Extended Kalman Filter (EKF) for Ball Trajectories

- EKF handles non-linear motion models (e.g., projectile trajectories with drag).
- Binocular vision + EKF achieved maximum position error of 0.0165 cm for ball tracking. [Springer](https://link.springer.com/chapter/10.1007/978-3-031-57037-7_8)

### Application to Golf Club Tracking

The club head follows a roughly circular arc during the downswing. A Kalman filter with a **constant angular velocity model** (rather than constant linear velocity) would be appropriate:

```
State: [theta, omega, r]  (angle, angular velocity, radius)
Measurement: [x, y]       (pixel coordinates of detected club head)
```

When detection fails due to blur, the Kalman filter predicts the next position along the arc, maintaining tracking continuity.

[Ultralytics Blog: Ball Trajectory Prediction](https://www.ultralytics.com/blog/enhancing-ball-trajectory-prediction-using-vision-ai)

---

## 9. Camera-Based Speed Measurement

### General Pipeline

1. **Camera calibration** -- Estimate intrinsic (focal length, principal point, distortion) and extrinsic (rotation, translation) parameters.
2. **Object detection and tracking** -- Locate the object across frames.
3. **Pixel-to-world mapping** -- Convert pixel displacement to real-world distance.
4. **Speed computation** -- Distance / time between frames.

### State of the Art

- Best methods achieve median vehicle speed estimation error of 0.58 km/h. [arXiv](https://arxiv.org/html/2505.01203v1)
- Semi-automatic calibration using vanishing point detection + known metric distances in the scene.
- RANSAC-based lane detection + geometric camera-road relationships. [ACM](https://dl.acm.org/doi/10.1145/3282286.3282288)

### Camera Calibration for Speed

- [Ultralytics Guide (2025)](https://www.ultralytics.com/blog/a-guide-to-camera-calibration-for-computer-vision-in-2025)
- [Roboflow Sports Calibration](https://blog.roboflow.com/camera-calibration-sports-computer-vision/)
- [OpenCV Camera Calibration](https://docs.opencv.org/4.5.2/d4/d94/tutorial_camera_calibration.html)

---

## 10. Pose Estimation for Golf

### MediaPipe Pose

- Developed by Google; tracks 33 body keypoints in real-time.
- Widely used for golf: tracks ear, hip, wrist landmarks.
- More precise and detailed pose data than YOLO-based detection.
- Runs on mobile devices.
- [GitHub Project](https://github.com/HeleenaRobert/golf-swing-analysis)

### Advanced Golf Swing Analysis Using MediaPipe and ML

- Analyzes 8 swing phases: Address, Toe-Up, Mid-Backswing, Top, Mid-Downswing, Impact, Mid-Follow-Through, Finish.
- Uses Decision Trees, Random Forests, LSTM, and 1D CNN for phase classification.
- [ResearchGate](https://www.researchgate.net/publication/394742786_Advanced_Golf_Swing_Analysis_Using_MediaPipe_and_Machine_Learning)

### GolfMate

- Enhanced golf swing analysis with Pose Refinement Network and Explainable Golf Swing Embedding.
- [MDPI Applied Sciences](https://www.mdpi.com/2076-3417/13/20/11227)

### OpenPose Limitations

- Bottom-up coordinate detection model.
- **Experiences non-detection issues with golf swing motion data** -- likely due to self-occlusion and fast motion.
- MediaPipe is preferred for golf applications.

### Relevance to Club Speed

Pose estimation provides the **wrist position** across frames. Since the club is a rigid extension of the wrists, wrist velocity combined with estimated club length gives an approximation of club head speed:

```
v_clubhead = v_wrist + omega_wrist * L_club
```

Where `L_club` is the club length and `omega_wrist` is the angular velocity of the wrist.

---

## 11. Perspective Correction and Homography

### Homography

A 3x3 projective transformation matrix mapping points from one plane to another. Requires minimum 4 point correspondences.

```
[x']     [h11 h12 h13] [x]
[y'] = H [h21 h22 h23] [y]
[w']     [h31 h32 h33] [1]
```

Where (x'/w', y'/w') are the transformed coordinates.

### Homography vs. Full Camera Calibration

- **Homography**: Maps between two planes (e.g., image plane to ground plane). Simpler, fewer parameters, but limited to planar scenes.
- **Full calibration**: Recovers intrinsic + extrinsic parameters. More accurate, handles 3D scenes, but requires checkerboard or similar calibration target.

[CMU Lecture Notes](http://16720.courses.cs.cmu.edu/lec/transformations.pdf) | [MIT Vision Book](https://visionbook.mit.edu/homography.html)

### Application to Golf Speed Measurement

The golf swing plane is roughly planar. A homography from the image plane to the swing plane allows converting pixel displacements to real-world distances **within that plane**. This avoids full 3D reconstruction.

**Calibration approach**:
1. Place markers at known distances in the swing plane.
2. Compute homography from image coords to swing plane coords.
3. Track club head in image coordinates.
4. Transform tracked positions through homography.
5. Compute speed from transformed positions + frame timing.

[Roboflow Sports Calibration](https://blog.roboflow.com/camera-calibration-sports-computer-vision/)

---

## 12. Background Subtraction for Motion Detection

### Core Concept

Subtract a background model from current frame to obtain a foreground (moving object) mask. Works with static cameras.

### Key Methods

- **Frame Differencing**: Simplest approach; subtract previous frame from current.
- **Gaussian Mixture Model (GMM)**: Handles multimodal backgrounds (e.g., waving grass). Very fast, low memory. [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S2665917423002349)
- **MOG2** (OpenCV): Adaptive GMM that automatically selects the number of Gaussian components.
- **KNN Background Subtractor** (OpenCV): Non-parametric, handles complex backgrounds.

### Advantages for Small Object Detection

Background subtraction can detect **very small objects** -- even smaller than what deep detectors like YOLO can find. This makes it particularly useful as a first-pass detector for the club head.

### Coarse-to-Fine Approach

1. Estimate rough motion regions.
2. Refine to precise moving object boundaries.
[ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0030402620300292)

### Application to Golf

With a tripod-mounted iPhone:
1. Background subtract to detect all moving regions (golfer + club).
2. The club head will be the fastest-moving foreground region.
3. Use the foreground mask to focus expensive tracking algorithms on a small ROI.

---

## 13. Deblurring Algorithms for Motion Blur Recovery

### Deep Learning Approaches (2024 Survey)

Comprehensive comparison of 30 blind motion deblurring methods:
- 12 CNN-based
- 5 RNN-based
- 6 GAN-based
- 7 Transformer-based

Transformer-based methods achieve competitive performance across most datasets due to self-attention capturing remote dependencies. [Springer](https://link.springer.com/article/10.1007/s00371-024-03632-8) | [arXiv](https://arxiv.org/html/2401.05055v2)

### Recent Innovations

- **Diffusion-based deblurring (2025)**: One-step diffusion model for motion deblurring. [arXiv](https://arxiv.org/html/2503.06537v1)
- **Event-camera-based deblurring (CVPR 2024)**: Frequency-aware approach using event cameras for real-world blur. [CVPR 2024](https://openaccess.thecvf.com/content/CVPR2024/papers/Kim_Frequency-aware_Event-based_Video_Deblurring_for_Real-World_Motion_Blur_CVPR_2024_paper.pdf)
- **RAW domain blur synthesis**: More realistic blur simulation for training.

### Tracking by Deblatting (Key Paper)

Rather than deblurring first and tracking second, this approach jointly solves blind deblurring and image matting. It recovers the **intra-frame trajectory** of fast objects from their blur streaks, achieving higher temporal resolution than conventional trackers. [IJCV 2021](https://link.springer.com/article/10.1007/s11263-021-01480-w)

### Application to Golf

Two strategies:
1. **Deblur then track**: Apply deep deblurring to recover sharp club head, then detect/track. Risk: deblurring artifacts may mislead detection.
2. **Track from blur (Deblatting)**: Use blur streak directly as speed information. More robust but requires custom implementation.

---

## 14. Math: Pixel Displacement to Real-World Speed

### Fundamental Camera Model

The pinhole camera model relates 3D world points to 2D image points:

```
[u]     [fx  0  cx] [R | t] [X]
[v] = K [0  fy  cy]         [Y]
[1]     [0   0   1]         [Z]
                             [1]
```

Where:
- `(u, v)` = pixel coordinates
- `K` = intrinsic matrix (focal length fx, fy in pixels; principal point cx, cy)
- `[R | t]` = extrinsic matrix (rotation and translation from world to camera)
- `(X, Y, Z)` = 3D world coordinates

### Step 1: Pixel Displacement Measurement

Given two consecutive frames at times t1 and t2:
```
delta_u = u2 - u1  (horizontal pixel displacement)
delta_v = v2 - v1  (vertical pixel displacement)
delta_pixels = sqrt(delta_u^2 + delta_v^2)
```

### Step 2: Pixel-to-Meters Conversion (Planar Case)

**Method A: Known-Distance Calibration (Simplest)**

Place two markers at known distance `D_known` meters apart, visible in the frame at the same depth as the club head. Measure their pixel separation `P_known`.

```
scale = D_known / P_known  (meters per pixel at that depth)
displacement_meters = delta_pixels * scale
speed_mps = displacement_meters / delta_t
speed_mph = speed_mps * 2.237
```

**Where**:
- `delta_t` = 1 / frame_rate (e.g., 1/240 = 0.00417 seconds)

**Method B: Focal Length + Known Depth**

If camera intrinsics are calibrated and object depth Z is known:

```
displacement_meters = delta_pixels * Z / f_pixels
```

Where:
- `Z` = distance from camera to the object (meters)
- `f_pixels` = focal length in pixels (from calibration)

The focal length in pixels is:
```
f_pixels = f_mm * image_width_pixels / sensor_width_mm
```

For iPhone 15 Pro main camera:
- f_mm ~ 6.86 mm (24mm equivalent / crop factor)
- sensor_width ~ 9.8 mm (1/1.28" sensor)
- At 1080p: f_pixels ~ 6.86 * 1920 / 9.8 ~ 1343 pixels

**Method C: Homography (Planar Scene)**

If the swing occurs in a known plane, compute a homography H from image coordinates to real-world plane coordinates:

```
[X_world]       [u]
[Y_world] = H * [v]
[  1    ]       [1]
```

Then:
```
displacement = sqrt((X2-X1)^2 + (Y2-Y1)^2) in world units
speed = displacement / delta_t
```

### Step 3: Perspective Correction

Objects farther from the camera appear smaller. Without correction, the same physical speed produces different pixel displacements depending on depth.

**Correction formula**:
```
true_displacement = pixel_displacement * Z_object / f_pixels
```

If the object moves **toward or away** from the camera (depth change), the perspective scale changes between frames:
```
true_displacement = sqrt(
    (delta_u * Z_avg / f_pixels)^2 +
    (delta_v * Z_avg / f_pixels)^2 +
    delta_Z^2
)
```

For golf, since the swing plane is roughly perpendicular to the camera view axis when filming from face-on or down-the-line, depth changes during the fastest part of the swing (near impact) are relatively small.

### Step 4: Full Speed Calculation

```
speed_mph = (delta_pixels * scale_factor / delta_t) * 2.237

Where:
  delta_pixels = pixel displacement between frames
  scale_factor = meters_per_pixel at object depth
  delta_t = 1 / fps (seconds between frames)
  2.237 = m/s to mph conversion
```

### Worked Example

**Setup**: iPhone at 240 fps, 3 meters from golfer, filming face-on
- f_pixels ~ 1343 (calculated above)
- Z = 3.0 meters
- meters_per_pixel = Z / f_pixels = 3.0 / 1343 = 0.00223 m/pixel

**Measurement**: Club head moves 83 pixels between two consecutive frames
```
displacement = 83 * 0.00223 = 0.1854 meters
delta_t = 1/240 = 0.00417 seconds
speed = 0.1854 / 0.00417 = 44.5 m/s = 99.5 mph
```

### Error Sources

| Source | Typical Magnitude | Mitigation |
|--------|-------------------|------------|
| **Focal length uncertainty** | 1-3% | Calibrate with checkerboard |
| **Distance-to-subject error** | 2-5% | Use reference marker or LiDAR |
| **Pixel localization error** | +/- 1-2 pixels | Sub-pixel refinement, Kalman filtering |
| **Motion blur** | Can shift centroid 5-15 pixels | Deblatting or deblur first |
| **Frame timing jitter** | ~0.5% on iPhone | Average over multiple frames |
| **Lens distortion** | 1-3% at edges | Apply undistortion from calibration |
| **Swing plane angle** | 5-15% if not perpendicular | Use homography correction |
| **Rolling shutter** | Varies with direction | Use front camera or correct |
| **Depth variation** | 2-5% during downswing | Model as circular arc |

**Combined typical error**: 5-15% without calibration, 2-5% with careful calibration.

### Error Reduction Strategies

1. **Use a known reference object**: An alignment stick or club placed at a known distance provides a scale reference.
2. **Film from face-on or down-the-line**: Minimizes depth variation during the fastest part of the swing.
3. **Use iPhone LiDAR** (Pro models): Provides depth map for accurate Z estimation.
4. **Track multiple points**: Track both club head and a body keypoint (wrist); the relative motion reduces camera-motion error.
5. **Temporal averaging**: Fit a smooth curve to tracked positions, then differentiate analytically rather than using noisy frame-to-frame differences.

---

## 15. iPhone-Specific Constraints

### Frame Rate Reality

- iPhone advertises 240 fps slow-motion at 1080p.
- **Actual frame rates vary**: iPhone 14 Pro users report 162-200 fps instead of 240. Older models (iPhone 11) achieve true 240 fps more reliably. [Apple Community](https://discussions.apple.com/thread/254658403)
- **Implication**: Must read actual timestamps from video metadata, not assume constant 240 fps.

### At 240 fps, Club Head Displacement Per Frame

| Club Speed | Distance/Frame | Pixels at 3m |
|-----------|---------------|--------------|
| 80 mph | 14.9 cm | 67 px |
| 100 mph | 18.6 cm | 83 px |
| 120 mph | 22.3 cm | 100 px |
| 140 mph | 26.0 cm | 117 px |

The club head moves 67-117 pixels per frame at typical filming distances. This is large enough to track but causes significant motion blur.

### Exposure Time

At 240 fps, maximum exposure time is ~4.17 ms. In bright conditions, auto-exposure may use shorter exposure (1/1000s = 1 ms), significantly reducing blur.

### Resolution at 240fps

- 1080p (1920 x 1080) -- sufficient for tracking.
- Club head is approximately 10-20 pixels wide at 3m distance.

### Processing Capability

- iPhone Neural Engine: 15-17 TOPS (A16+).
- CoreML supports on-device inference for lightweight models.
- Real-time tracking at 240fps is extremely challenging; offline post-processing is more practical.

---

## 16. Recommended Architecture for This App

Based on this research, a multi-stage pipeline is recommended:

### Stage 1: Video Capture
- 240 fps slo-mo, 1080p, with tripod or stabilization.
- Bright lighting to minimize exposure time and blur.

### Stage 2: Calibration
- Use a known reference distance in the frame (alignment stick, club length at address).
- Optionally use LiDAR for depth measurement on Pro models.
- Compute meters-per-pixel scale factor.

### Stage 3: Coarse Detection (Per-Frame)
- **Background subtraction** (MOG2/KNN) to detect moving regions.
- **MediaPipe Pose** to locate wrist keypoints.
- Define ROI around expected club head location (below and ahead of wrist).

### Stage 4: Fine Tracking
- **Option A (Lightweight)**: Template matching or color-based tracking within ROI.
- **Option B (Accurate)**: TrackNet-style heatmap regression fine-tuned on golf club heads.
- **Option C (Point Tracking)**: CoTracker/TAPIR initialized on club head point.

### Stage 5: Speed Estimation
- Apply Kalman filter with circular-arc motion model to smooth trajectory.
- Convert pixel displacement to real-world distance using calibration.
- Compute instantaneous speed at each frame.
- Report peak speed near impact.

### Stage 6 (Optional): Temporal Super-Resolution
- Apply RIFE frame interpolation to increase effective frame rate.
- Re-track on interpolated frames for smoother trajectory.
- Use only for visualization; report speed from original frames.

### Most Promising Novel Approach: Motion Blur Analysis
- At impact, the club head produces a distinctive blur streak.
- Blur length directly encodes speed (no tracking needed across frames).
- Could provide single-frame speed estimation using Deblatting techniques.
- This is the most unique and potentially accurate approach for extreme speeds.

---

## Key Citations and Resources

### Papers
1. TrackNet (2019): [arXiv:1907.03698](https://arxiv.org/abs/1907.03698)
2. RAFT Optical Flow (2020): ECCV 2020
3. Tracking by Deblatting (2021): [IJCV](https://link.springer.com/article/10.1007/s11263-021-01480-w)
4. RIFE Frame Interpolation (2022): [arXiv:2011.06294](https://arxiv.org/abs/2011.06294)
5. CoTracker3 (2024): [arXiv:2410.11831](https://arxiv.org/html/2410.11831v1)
6. TrackNetV4 (2024): [arXiv:2409.14543](https://arxiv.org/abs/2409.14543)
7. TAPIR (2023): [Project Page](https://deepmind-tapir.github.io/)
8. CaddieSet (2025): [arXiv](https://arxiv.org/html/2508.20491v1)
9. Motion Blur Speed Estimation: [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0262885607000881)
10. Deep Deblurring Survey (2024): [arXiv:2401.05055](https://arxiv.org/html/2401.05055v2)

### Tools and Libraries
- [OpenCV Optical Flow](https://docs.opencv.org/4.x/d4/dee/tutorial_optical_flow.html)
- [Ultralytics YOLO Tracking](https://docs.ultralytics.com/modes/track/)
- [MediaPipe Pose](https://github.com/HeleenaRobert/golf-swing-analysis)
- [CoTracker GitHub](https://github.com/facebookresearch/co-tracker)
- [TAPIR / TAPNet GitHub](https://github.com/google-deepmind/tapnet)
- [RIFE GitHub](https://github.com/hzwer/ECCV2022-RIFE)
- [Awesome Deblurring](https://github.com/subeeshvasu/Awesome-Deblurring)
