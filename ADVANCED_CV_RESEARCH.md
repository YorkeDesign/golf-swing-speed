# Advanced Computer Vision Techniques for Golf Club Head Speed Measurement

## Research Report: Maximizing Accuracy from iPhone Camera

---

## Table of Contents

1. [Video Frame Interpolation (Temporal Upsampling)](#1-video-frame-interpolation)
2. [Super-Resolution & Deblurring](#2-super-resolution--deblurring)
3. [Motion Blur as a Speed Signal](#3-motion-blur-as-a-speed-signal)
4. [Event Cameras & Neuromorphic Vision](#4-event-cameras--neuromorphic-vision)
5. [Multi-Frame Fusion & Temporal Super-Resolution](#5-multi-frame-fusion--temporal-super-resolution)
6. [Neural Radiance Fields (NeRF)](#6-neural-radiance-fields-nerf)
7. [Sensor Fusion (Camera + LiDAR + IMU)](#7-sensor-fusion-camera--lidar--imu)
8. [Sub-Pixel Tracking Accuracy](#8-sub-pixel-tracking-accuracy)
9. [Confidence Scoring & Statistical Validation](#9-confidence-scoring--statistical-validation)
10. [How Professional Systems Achieve Accuracy](#10-how-professional-systems-achieve-accuracy)
11. [Physical Augmentation: Markers, Stickers & Lighting](#11-physical-augmentation)
12. [Dual/Multi-Camera Techniques](#12-dualmulti-camera-techniques)
13. [Novel & Unconventional Ideas](#13-novel--unconventional-ideas)
14. [Practical Architecture Recommendation](#14-practical-architecture-recommendation)
15. [Realistic Accuracy Expectations](#15-realistic-accuracy-expectations)

---

## 1. Video Frame Interpolation

### The Opportunity

At 240 fps, a club head moving at 100 mph (~44.7 m/s) travels approximately **18.6 cm between frames**. That is a huge gap for tracking. If we could synthetically interpolate to an effective 960 fps, the gap drops to **~4.7 cm** -- substantially more trackable.

### Key Algorithms

**RIFE (Real-Time Intermediate Flow Estimation)**
- Uses a neural network called IFNet to directly estimate intermediate optical flows between frames end-to-end.
- 4-27x faster than older methods (SuperSlomo, DAIN) with better quality.
- Can perform 2x, 4x, or 8x frame rate multiplication.
- Convolution-based, making it potentially suitable for mobile inference via CoreML.
- Source: ECCV 2022, available at [github.com/hzwer/ECCV2022-RIFE](https://github.com/hzwer/ECCV2022-RIFE).

**FILM (Frame Interpolation for Large Motion)**
- Google Research algorithm specifically designed for large motion interpolation.
- Uses a multi-scale feature extractor and a fusion network.
- Handles occlusions and large displacements better than flow-warping-only methods.
- Well suited to the large inter-frame motion of a golf club head.

**AMT (All-Pairs Multi-Field Transforms)**
- CVPR 2023 paper from Nankai University.
- Builds bidirectional correlation volumes for all pixel pairs.
- Derives multiple groups of fine-grained flow fields from coarse flows.
- Specifically designed for large motions and occluded areas.
- Competes with Transformer-based models while being more efficient.
- Source: [arxiv.org/abs/2304.09790](https://arxiv.org/abs/2304.09790).

### Applicability Assessment

| Factor | Rating | Notes |
|--------|--------|-------|
| Accuracy for fast motion | Medium | These models are trained on natural video; a club head at 100+ mph is an extreme case |
| Hallucination risk | High | Interpolated frames are *synthetic* -- the club head position is estimated, not measured |
| On-device feasibility | Low-Medium | RIFE is relatively lightweight; 4x interpolation of 240fps video is heavy but possible post-capture |
| Value for speed estimation | Medium | Better for visualization than measurement; interpolated positions carry uncertainty |

### Practical Strategy

**Use interpolation for trajectory refinement, not as ground truth.** Interpolated frames can help fit a smoother trajectory curve, but the speed estimate should be anchored by real measured frames. Treat interpolated positions as soft constraints with lower confidence weights in the trajectory fitting.

A realistic pipeline:
1. Capture at 240 fps (native)
2. Run RIFE/AMT 4x interpolation post-capture to get effective 960 fps
3. Track club head in all frames (real + synthetic)
4. Weight real-frame detections at 1.0, interpolated-frame detections at 0.3-0.5
5. Fit trajectory curve through weighted points
6. Derive speed from the fitted curve

---

## 2. Super-Resolution & Deblurring

### Why This Matters

At 240 fps on iPhone, the club head is typically:
- A small object: ~5-15 pixels across in the frame (depending on framing)
- Motion-blurred: even at 1/960s exposure, a 100 mph object moves ~4.7 cm during exposure
- Low contrast: metallic club face against variable backgrounds

### Deblurring Approaches

**Classical Blind Deconvolution**
- Estimate the blur kernel (Point Spread Function / PSF) from the image
- Deconvolve to recover a sharper image
- Works when blur is approximately linear (which it is for very short exposures)

**Neural Network Deblurring**
- Modern networks can recover sharp frames from severely blurred input
- Key architectures: DeblurGAN-v2, NAFNet, Stripformer
- The AIM 2025 Challenge on High FPS Motion Deblurring specifically targets this problem
- Event-enhanced approaches (Ev-DeblurVSR) combine event-camera-like data with frame deblurring for state-of-the-art results

**Joint Super-Resolution + Deblurring**
- Networks that simultaneously increase resolution and remove blur
- High-resolution optical flow combined with frame-recurrent networks can jointly solve both problems
- This is highly relevant: we need both more pixels on the club head AND sharper edges

### DynaMoDe-NeRF (CVPR 2025)

A cutting-edge approach that uses motion-aware deblurring within a Neural Radiance Field for dynamic scenes. While not directly applicable to real-time iPhone processing, the concepts of motion-aware deblurring are transferable.

### Practical Strategy

For our use case, a two-stage approach:
1. **Detection stage**: Use the blurred frame as-is for approximate localization (blur streaks actually help locate the club path)
2. **Refinement stage**: Apply a lightweight deblurring network to the ROI around the detected club head to sharpen edges for precise centroid estimation

A CoreML-optimized deblurring model running on the detected ROI (e.g., 64x64 crop) is feasible on modern iPhones.

---

## 3. Motion Blur as a Speed Signal

### The Core Insight

**Motion blur is not noise -- it is a direct encoding of velocity.**

The fundamental relationship:

```
blur_length_pixels = (object_speed x exposure_time x focal_length) / object_distance
```

Or more practically:

```
speed = (blur_length_pixels x object_distance) / (exposure_time x focal_length_pixels)
```

Where:
- `blur_length_pixels`: measured length of the motion blur streak in the image
- `exposure_time`: known from camera EXIF/metadata (iPhone reports this precisely)
- `focal_length_pixels`: known from camera calibration
- `object_distance`: estimated from LiDAR, ARKit, or known club length

### Research Backing

Published research demonstrates this approach achieves:
- Maximum error of 5.4% for UAV velocity estimation using blur analysis
- RMSE of 0.025 m/s in controlled environments
- The Discrete Cosine Transform (DCT) can extract the PSF from blurred images to measure blur extent and angle

### Blur Kernel Estimation Techniques

1. **Radon Transform**: Extract the dominant direction and length of blur streaks by analyzing the image in Radon space (projection along angles). Peak in Radon transform indicates blur angle; width of peak indicates blur length.

2. **Frequency Domain Analysis**: Motion blur creates characteristic notch patterns in the Fourier spectrum. The spacing of notches is inversely proportional to blur length. This is robust even with noise.

3. **Canny Edge + Hough Transform**: Detect blur streak edges, then use Hough transform to find dominant line segments. Streak length = velocity signal.

4. **Neural PSF Estimation**: Train a CNN to directly regress blur kernel parameters (length and angle) from image patches. Can be very fast at inference.

### Why This Is Extremely Promising for Golf

- At 100 mph with 1/960s exposure: blur streak ~4.7 cm in real space
- At typical framing, this is 20-50 pixels of blur -- easily measurable
- The blur direction directly encodes the swing path
- Works even when the club head is too blurred for centroid tracking
- iPhone provides precise exposure time metadata via AVCaptureDevice
- This technique actually gets MORE accurate at higher speeds (longer blur = more signal)

### Hybrid Approach (Recommended)

Combine blur-based speed estimation with point tracking:
1. In frames where the club is slow enough to track as a point: use centroid tracking
2. In frames near impact where blur is severe: switch to blur-length speed estimation
3. Fuse both estimates using a Kalman filter with appropriate uncertainty models

This is potentially the single most impactful technique for the impact zone, where traditional tracking fails but blur is maximal.

---

## 4. Event Cameras & Neuromorphic Vision

### What They Are

Event cameras (e.g., Prophesee, iniVation) report per-pixel brightness changes asynchronously with **microsecond temporal resolution** -- effectively millions of FPS equivalent. They output a stream of events: (x, y, timestamp, polarity) for every pixel that detects a change.

### Key Properties

- **Extreme temporal resolution**: microsecond-level event timing
- **Very high dynamic range**: >120 dB (vs ~60 dB for standard cameras)
- **No motion blur**: each event captures an instantaneous change
- **Low data rate for sparse scenes**: only changing pixels generate data

### Why They Are Relevant (Even Though iPhone Doesn't Have One)

1. **Algorithmic concepts transfer**: Event-based tracking algorithms that handle asynchronous, high-temporal-resolution data can inspire how we process 240fps data with interpolation.

2. **Event-Enhanced Video Super-Resolution**: Research like Ev-DeblurVSR shows that combining event data with frames dramatically improves deblurring and temporal super-resolution. We can simulate "pseudo-events" from inter-frame optical flow.

3. **Future hardware**: If Apple ever integrates neuromorphic sensing (possibly in LiDAR evolution), the software architecture should be ready.

4. **External accessory potential**: A USB-C event camera accessory is theoretically possible, though currently no consumer product exists for this.

### Transferable Concepts

- **Asynchronous processing**: Instead of processing whole frames, focus computational resources on the ROI where motion is detected
- **Change detection as primary signal**: Use frame differencing aggressively to isolate moving objects
- **Temporal binning**: Accumulate motion information across time windows for robust estimation

---

## 5. Multi-Frame Fusion & Temporal Super-Resolution

### Space-Time Video Super-Resolution (STVSR)

STVSR simultaneously increases both spatial resolution and frame rate. This is exactly what we need: more pixels on the club head AND more temporal samples.

### Key Techniques

**Deformable 3D Convolution**
- Combines deformable convolution with 3D convolution
- Adaptively performs motion compensation while exploiting space-time information
- Can align features from adjacent frames even with large motion

**Long-Term Mixture of Experts (LTMoE)**
- Encodes and integrates complementary information from long-term frame sequences
- Compensates spatial details and reduces blur in interpolated features
- Addresses the limitation of single-frame-pair interpolation

**Multi-Scale Feature Interpolation**
- Uses feature pyramids to handle motion at different scales
- Small club head motion captured at fine scales; overall swing arc at coarse scales
- Temporal feature fusion propagates information bidirectionally across frames

### Practical Multi-Frame Fusion Pipeline for Golf

```
Frame t-2  ---\
Frame t-1  ----\
Frame t    ------> Multi-Frame Fusion Network --> Enhanced Frame t
Frame t+1  ----/     (spatial + temporal)          (higher resolution,
Frame t+2  ---/                                     reduced blur,
                                                    sub-pixel precision)
```

Key insight: Even without neural network fusion, simple multi-frame techniques help:
1. **Background subtraction**: Average frames where the club is absent to get a clean background model; subtract from active frames to isolate club head
2. **Temporal median for noise reduction**: Reduce sensor noise by leveraging temporal redundancy in static regions
3. **Motion history images**: Accumulate motion across frames to visualize the full swing path

---

## 6. Neural Radiance Fields (NeRF)

### Concept

NeRF represents a 3D scene as a continuous volumetric function, mapping (x, y, z, viewing_direction) to (color, density). Trained on a set of 2D images with known camera poses, it can synthesize novel views.

### Relevance to Golf Speed Measurement

**Low relevance for real-time speed measurement**, but interesting for:

1. **Post-hoc 3D reconstruction**: After capture, reconstruct the full 3D swing path for analysis
2. **Camera pose estimation**: NeRF-adjacent techniques (like COLMAP or structure-from-motion) can precisely determine camera-to-golfer geometry
3. **DynaMoDe-NeRF**: This CVPR 2025 paper specifically handles motion blur in dynamic NeRFs, recovering velocity and trajectory information from blurred multi-view video

### Limitations

- Requires multiple viewpoints or a moving camera (single static iPhone is insufficient)
- Computationally expensive (minutes to hours of training per scene)
- Dynamic scene NeRFs are still research-grade
- Not suitable for real-time or near-real-time feedback

### 3D Gaussian Splatting (More Practical Alternative)

Gaussian Splatting achieves similar 3D reconstruction quality but trains in seconds-to-minutes and renders in real time. If future versions of the app support multi-angle capture (e.g., two iPhones), 4D Gaussian Splatting could provide full 3D swing reconstruction with motion blur handling.

---

## 7. Sensor Fusion (Camera + LiDAR + IMU)

### Available iPhone Sensors

| Sensor | Data | Rate | Precision |
|--------|------|------|-----------|
| Wide camera | 240fps video | 240 Hz | Sub-pixel with CV |
| Telephoto camera | 120fps video (on some models) | 120 Hz | Higher magnification |
| LiDAR (Pro models) | Depth map | 10-15 Hz | ~1 cm at 5m |
| Accelerometer | 3-axis acceleration | 100 Hz (CMMotionManager) | High |
| Gyroscope | 3-axis rotation rate | 100 Hz | High |
| Magnetometer | 3-axis magnetic field | 100 Hz | Medium |
| ARKit | 6DoF device pose | 60 Hz | ~1-3 cm position |

**Important**: CMBatchedSensorManager (Apple Watch Series 8+) supports up to 800 Hz accelerometer, but on iPhone the standard limit is 100 Hz via CMMotionManager.

### Kalman Filter Fusion Architecture

```
          Visual Tracking (240 Hz)
                |
                v
    +-------------------------+
    |   Extended Kalman Filter |
    |                          |
    |   State: [x, y, z,      |
    |           vx, vy, vz,   |
    |           ax, ay, az]    |
    +-------------------------+
          ^           ^
          |           |
    LiDAR Depth    IMU Data
     (15 Hz)      (100 Hz)
```

### How Each Sensor Contributes

**Camera (Primary)**
- Provides 2D position of club head at 240 Hz
- Highest temporal resolution for tracking
- Affected by motion blur, occlusion, and lighting

**LiDAR (Scale & Depth)**
- Provides absolute distance to the golfer/club
- Resolves scale ambiguity (critical: a 100-pixel motion could be 10 cm or 1 m depending on distance)
- At 15 Hz, it provides intermittent depth anchors
- iPhone LiDAR resolution: up to 768x576 depth pixels

**IMU (Device Stability)**
- The IMU data is from the *phone*, not the club
- Useful for: compensating for camera shake/movement during capture
- If the phone moves during the swing (handheld capture), IMU data can correct for this
- Enables ego-motion compensation in the tracking pipeline
- Also detects the moment of impact via acoustic/vibration signal (slight but detectable)

**ARKit (Geometry)**
- Provides 6DoF camera pose at 60 Hz
- Enables mapping from 2D image coordinates to 3D world coordinates
- Plane detection can identify the ground plane for geometric constraints
- Body tracking (ARKit 3+) can detect the golfer's pose, constraining where the club can be

### Fusion Strategy

1. **Predict** club head position using kinematic model (constant-acceleration during downswing)
2. **Update with camera**: 2D detection provides pixel coordinates, combined with LiDAR depth for 3D position
3. **Update with IMU**: Correct for camera ego-motion
4. **Constrain with ARKit**: Body pose provides arm/wrist position as a kinematic anchor

The Kalman filter naturally handles different sensor rates and uncertainties, producing a smooth, physically plausible trajectory estimate at the highest rate (240 Hz).

---

## 8. Sub-Pixel Tracking Accuracy

### Why Sub-Pixel Matters

If the club head spans 10 pixels and moves 20 pixels between frames, we need sub-pixel accuracy to distinguish 95 mph from 100 mph (~5% difference = ~1 pixel difference in displacement).

### Techniques for Sub-Pixel Precision

**Centroid Methods**
- Compute brightness-weighted centroid of the detected club head region
- Achieves ~1/10 pixel accuracy in favorable conditions
- Simple, fast, and well-understood
- Best when the club head is a bright, well-contrasted blob

**Gaussian Fitting**
- Fit a 2D Gaussian to the intensity profile of the detected region
- Peak of Gaussian gives sub-pixel position
- More robust than centroid when the object shape is known
- Achieves 1/10 to 1/100 pixel accuracy in controlled conditions

**Phase Correlation**
- Measure sub-pixel displacement between frames using phase correlation in frequency domain
- Very robust to noise and illumination changes
- Can achieve 1/20 pixel accuracy
- Natural extension to tracking: compute displacement directly without explicit detection

**Edge-Based Sub-Pixel Tracking**
- Fit mathematical models to edge profiles with sub-pixel precision
- A subpixel-precise rigid object tracker using edge information can determine position, scale, and rotation at ~80fps
- Well-suited to tracking the sharp edges of a club head

**Template Matching with Sub-Pixel Refinement**
- Match a template of the club head in the frame
- Refine match location to sub-pixel accuracy using parabolic or sinc interpolation of the correlation surface
- The correlation peak location can be estimated to 1/10 pixel or better

### Resolution Limits

Published research on resolution limits for sub-pixel tracking shows:
- **Theoretical limit**: ~1/100 pixel with perfect SNR
- **Practical limit**: 1/10 pixel is reliably achievable
- **With averaging**: multiple measurements can be combined to push beyond single-frame limits
- For a 10-pixel club head, 1/10 pixel accuracy means ~1% position accuracy per frame

### Impact on Speed Accuracy

With 240 fps and 1/10 pixel sub-pixel accuracy:
- Frame-to-frame displacement at 100 mph: ~20 pixels
- Position uncertainty: ~0.1 pixel per frame
- Displacement uncertainty: ~0.14 pixels (sqrt(2) x 0.1)
- Speed uncertainty from single pair: ~0.7%
- With trajectory fitting over 10+ frames: uncertainty drops to ~0.2-0.3%

This suggests **sub-pixel tracking alone could theoretically achieve ~0.3 mph accuracy at 100 mph** -- if detection is reliable.

---

## 9. Confidence Scoring & Statistical Validation

### Per-Frame Confidence Metrics

Each speed measurement from each frame pair should carry a confidence score based on:

1. **Detection confidence**: How certain is the neural network about the club head location?
   - Object detector confidence score (0-1)
   - IoU with expected region from kinematic prediction
   - Size and aspect ratio consistency with expected club head appearance

2. **Blur assessment**: How much motion blur affects the frame?
   - Blur metric (Laplacian variance of the ROI)
   - If blur is severe: lower confidence for centroid tracking, higher confidence for blur-length speed

3. **Geometric consistency**: Does this measurement fit the expected trajectory?
   - Residual from trajectory curve fit
   - Mahalanobis distance from Kalman filter prediction
   - Physical plausibility check (acceleration limits, jerk limits)

4. **Lighting/contrast**: Is the club head visible?
   - Local contrast ratio
   - Signal-to-noise ratio in the detection region
   - Histogram analysis of the ROI

### Trajectory Curve Fitting

Rather than computing speed from individual frame pairs, fit a smooth trajectory through all detections:

**Polynomial Fit**
- The downswing arc is well-approximated by a polynomial in time
- Fit a 3rd or 4th-order polynomial to the position data
- Speed = derivative of position polynomial
- Natural smoothing; outliers have reduced influence

**Spline Fit (Preferred)**
- Cubic or B-spline fit through weighted position measurements
- Allows for the natural curvature changes during the swing
- Smoothing parameter controls trade-off between fitting data and smoothness
- Speed and acceleration derived analytically from spline coefficients

**Physics-Informed Constraints**
- Maximum physically plausible acceleration: ~30g during downswing
- Angular velocity of the club follows specific biomechanical patterns
- Speed must be zero at the top of the backswing
- Speed should peak within ~10ms of impact
- These constraints can be incorporated as priors in the fitting

### Butterworth Low-Pass Filtering

Standard in sports biomechanics. A 4th-order Butterworth filter at an appropriate cutoff frequency:
- Removes high-frequency noise from tracking
- Preserves the actual speed dynamics
- Cutoff frequency selection based on residual analysis
- Research shows this is effective for GNSS-derived acceleration data in team sports

### Statistical Confidence Interval

Report speed as: **100 +/- 2 mph (95% confidence)**

Calculate using:
- Standard error from trajectory fit residuals
- Propagation of sub-pixel uncertainty through the speed calculation
- MDC95 (Minimum Detectable Change at 95%) = SEM x 1.96 x sqrt(2) for assessing whether two measurements are truly different

---

## 10. How Professional Systems Achieve Accuracy

### TrackMan (Radar-Based)

- Uses dual Doppler radar to track the ball throughout its entire flight
- Radar measures velocity directly via frequency shift (not position differentiation)
- OERT (Optically Enhanced Radar Tracking) adds a synchronized HD camera
- Ball speed accuracy: +/- 0.1 mph
- Club head speed: derived from ball speed and impact dynamics
- Cost: $20,000-$35,000

### Foresight GCQuad (Camera-Based)

- Four ultra-high-speed cameras capturing at ~10,000 fps
- Takes ~200 images within the first 30 cm of ball flight
- Uses **spherical correlation** of golf ball dimple patterns to track rotation
- Requires reflective markers on the club face for club data
- Direct measurement at impact, not reverse-engineered from flight
- Club face angle accuracy: within 1/10 of 1 degree
- Cost: $10,000-$15,000

### Key Differences from iPhone Approach

| Factor | Professional | iPhone |
|--------|-------------|--------|
| Frame rate | 10,000 fps | 240 fps |
| Resolution | Dedicated high-speed sensor | Consumer sensor |
| Lighting | Controlled flash/IR | Ambient |
| Markers | Required reflective dots | Optional |
| Processing | Custom DSP hardware | Mobile SoC |
| Distance | Fixed, known position | Variable |
| Calibration | Factory calibrated | User-performed |

### What This Means for Realistic Accuracy

Professional camera systems achieve +/- 0.5-1 mph for club head speed with 10,000 fps and controlled conditions. With 240 fps (42x fewer frames), the theoretical floor for a camera-only iPhone approach is roughly:

- **Best case (with markers, good lighting, known geometry)**: +/- 2-3 mph
- **Good case (natural club, good lighting, calibrated distance)**: +/- 3-5 mph
- **Average case (variable conditions)**: +/- 5-8 mph
- **With motion blur analysis as supplementary signal**: Could improve each tier by 1-2 mph

---

## 11. Physical Augmentation

### Reflective Markers / Stickers

This is the single easiest way to dramatically improve accuracy. Professional systems require them for a reason.

**How They Work**
- Small reflective dots (1/4 inch, ~6mm) placed on the club face
- Made with high-reflectivity glass bead film for superior light capture
- Provide a bright, high-contrast tracking target even in challenging lighting
- Weatherproof adhesive; will not affect club performance

**Impact on Tracking**

| Configuration | Data Captured | Accuracy Improvement |
|--------------|--------------|---------------------|
| 1 marker | Speed, smash factor, attack angle, club path | 2-3x improvement in detection reliability |
| 4 markers | All above + face angle, lie, loft, closure rate, impact location | Enables geometric pose estimation of club face |

**Marker Detection Algorithm**
1. Use the known high reflectivity to threshold-detect markers
2. Compute sub-pixel centroid of each marker blob
3. With 4+ markers: solve PnP (Perspective-n-Point) to get full 3D club face pose
4. Track marker constellation across frames for robust association

**Commercially Available**
- Foresight Sports Club Marker Pack: designed for GCQuad, works with any camera system
- Generic reflective dot stickers (e.g., RAWILL, LiteMark) for $5-15
- Compatible with TrackMan, GCQuad, SkyTrak, and any custom vision system

**Legal Status**: Reflective stickers are legal for practice and recreational play. They are NOT legal in competition (Rory Sabbatini was DQ'd for having a Foresight sticker on his club during a PGA Tour event).

### Structured Light Patterns

- Project a known pattern (dots, grid, stripes) onto the swing area
- The deformation of the pattern encodes 3D geometry
- iPhone's Face ID projector uses structured IR light but is not accessible to third-party apps
- A simple stick-on IR LED array could provide structured illumination
- Primarily useful for depth estimation, not speed

### LED or Retroreflective Tape

- Wrap the club head in retroreflective tape (legal in practice)
- Under iPhone's flash/LED illumination, the tape creates an extremely bright target
- Can be thresholded trivially from the background
- Even a small strip increases detection reliability substantially

---

## 12. Dual/Multi-Camera Techniques

### iPhone Multi-Camera Capture (AVCaptureMultiCamSession)

Since iOS 13, Apple supports simultaneous capture from multiple cameras. This enables:

**Wide + Telephoto Simultaneous Capture**
- Wide camera (26mm equivalent): captures full swing context
- Telephoto camera (77mm or 120mm equivalent): 3-5x closer view of the impact zone
- Synchronized capture provides two viewpoints at different magnifications

**Benefits**:
- Telephoto gives 3-5x more pixels on the club head
- Wide camera provides context and full body tracking
- Stereo geometry between the two cameras enables 3D estimation (baseline ~10mm)
- If one camera loses tracking (blur, occlusion), the other may still have data

**Limitations**:
- Telephoto cameras on iPhone typically max at 120 fps (not 240)
- Processing two video streams doubles computational load
- The baseline between cameras is small (~10mm), limiting depth accuracy

### Ultra-Wide Camera Applications

- 13mm equivalent, 120-degree field of view
- Useful for: ensuring the full swing stays in frame, capturing reference geometry
- Lower resolution per object pixel, so not ideal for precision tracking
- Could serve as a "geometric anchor" -- detecting the golfer's body position and ground plane

### Practical Multi-Camera Strategy

```
Wide Camera (240fps) --> Primary tracking: full swing arc, speed estimation
                          |
Telephoto Camera (120fps) --> Impact zone refinement: higher resolution
                               around impact for sub-pixel accuracy
                          |
LiDAR Scanner (15 Hz) --> Depth calibration: absolute distance for
                           scale, club-to-camera geometry
```

Sync all streams via AVCaptureMultiCamSession timestamps. Use the wide camera as the primary tracker and the telephoto as a refinement signal near impact.

---

## 13. Novel & Unconventional Ideas

### Flash/Strobe Timing

- Use the iPhone LED flash as a strobe during capture
- The flash can be synchronized with frame capture
- In low light, each flash creates a bright exposure of the club head frozen in motion
- iPhone's True Tone flash can output at ~30 Hz; insufficient for 240fps but could mark specific frames
- A third-party Bluetooth-synced strobe light could provide higher-rate illumination

### Acoustic Impact Detection

- The sound of club impact with the ball is a sharp acoustic event
- iPhone microphone records at 48 kHz (48,000 samples/second)
- Impact time can be localized to within ~0.02 ms from the audio waveform
- Knowing the exact impact frame enables precise speed-at-impact extraction
- Audio provides a ground-truth timestamp that visual tracking can anchor to

### Crowd-Sourced Calibration

- Users capture swings with known speeds (validated by radar devices)
- Aggregate data to train/calibrate the vision model
- Build a prior distribution of club head appearance vs. speed for different club types
- Over time, the model learns club-specific and condition-specific corrections

### Wearable IMU on Club

- A small IMU (accelerometer + gyroscope) attached to the club shaft
- Apple Watch on the wrist provides partial swing data via CMBatchedSensorManager at 800 Hz
- Direct speed measurement via integration of accelerometer data
- Fuse with camera data for combined estimate
- Products like Arccos, Garmin CT10 already do this but don't provide club head speed

### Shadow Analysis

- In bright sunlight, the club casts a shadow on the ground
- The shadow moves at the same angular rate as the club
- Shadow tracking can provide a secondary speed estimate
- Works best on light-colored ground surfaces
- Completely occlusion-free (shadow is always visible even when the club is blurred)

### Polarization Filtering

- The metallic club head has different polarization properties than the background
- A clip-on polarization filter on the iPhone camera could enhance club head contrast
- Particularly useful for chrome or polished club faces
- Could be implemented as a simple, cheap physical accessory

### Reference Object Scale Calibration

- Place a known-size object in the scene (e.g., a golf ball = 42.67mm diameter)
- Auto-detect the golf ball in frame to establish precise pixels-per-cm calibration
- The golf ball on the tee is always present and always a known size
- This removes the need for manual distance calibration

---

## 14. Practical Architecture Recommendation

### Tiered Accuracy System

**Tier 1: Basic (No accessories, minimal setup)**
- 240fps capture with automatic exposure optimization
- YOLOv8-nano or similar lightweight detector for club head
- Simple centroid tracking with sub-pixel refinement
- Trajectory polynomial fit over the downswing
- Golf ball as reference scale object
- Expected accuracy: +/- 5-8 mph

**Tier 2: Enhanced (With software augmentation)**
- Everything in Tier 1, plus:
- Motion blur analysis for impact-zone speed estimation
- RIFE 4x frame interpolation for trajectory refinement
- Kalman filter fusion of tracking + blur-speed estimates
- ARKit body pose for kinematic constraints
- LiDAR depth for absolute scale (Pro models)
- Expected accuracy: +/- 3-5 mph

**Tier 3: Maximum Accuracy (With physical augmentation)**
- Everything in Tier 2, plus:
- Reflective marker stickers on club face (1 or 4)
- Dedicated marker detection pipeline (threshold + centroid)
- Multi-camera capture (wide 240fps + telephoto 120fps)
- Acoustic impact detection for timing
- PnP pose estimation with 4 markers
- Physics-informed trajectory fitting with biomechanical priors
- Expected accuracy: +/- 2-3 mph

### Processing Pipeline

```
CAPTURE PHASE (Real-time)
  Camera 240fps --> Frame buffer
  LiDAR 15Hz   --> Depth buffer
  IMU 100Hz    --> Motion buffer
  Audio 48kHz  --> Audio buffer
  ARKit 60Hz   --> Pose buffer

DETECTION PHASE (Post-capture, ~2-5 seconds)
  1. Detect swing start/end from body pose
  2. Extract downswing frames (typically 0.2-0.3 seconds = 48-72 frames)
  3. Run club head detector on each frame
  4. Run marker detector (if markers present)
  5. Estimate motion blur parameters per frame

TRACKING PHASE
  6. Initialize Kalman filter with first detection
  7. Propagate state with kinematic model
  8. Update with detections (weighted by confidence)
  9. Update with blur-based speed estimates
  10. Incorporate LiDAR depth measurements
  11. Apply biomechanical constraints

INTERPOLATION PHASE (Optional)
  12. Run RIFE/AMT 4x interpolation on downswing frames
  13. Detect club head in interpolated frames
  14. Add as low-weight observations to trajectory fit

ESTIMATION PHASE
  15. Fit constrained spline through all observations
  16. Compute speed profile as derivative of spline
  17. Extract peak speed (typically 2-5 frames before impact)
  18. Detect impact time from audio
  19. Report speed at impact with confidence interval

OUTPUT
  Speed: 98.5 mph (+/- 2.3 mph, 95% CI)
  Confidence: HIGH / MEDIUM / LOW
  Quality metrics: detection rate, blur level, lighting score
```

---

## 15. Realistic Accuracy Expectations

### Comparison with Known Systems

| System | Technology | Club Head Speed Accuracy | Cost |
|--------|-----------|------------------------|------|
| TrackMan 4 | Dual Doppler radar + camera | +/- 0.5 mph | $25,000 |
| Foresight GCQuad | 4x high-speed cameras, 10K fps | +/- 0.5 mph | $12,000 |
| FlightScope Mevo+ | Radar | +/- 1 mph | $2,000 |
| Rapsodo MLM2 Pro | Camera + radar | +/- 1-2 mph | $700 |
| SkyTrak+ | Camera-based | +/- 1-2 mph | $700 |
| Garmin Approach R10 | Radar | +/- 2-3 mph | $600 |
| iPhone (this project, Tier 3) | 240fps camera + LiDAR + markers | +/- 2-3 mph (target) | $0* |
| iPhone (this project, Tier 2) | 240fps camera + software | +/- 3-5 mph (target) | $0* |
| iPhone (this project, Tier 1) | 240fps camera, basic | +/- 5-8 mph (target) | $0* |

*Assumes user already owns an iPhone

### Key Limiting Factors

1. **Frame rate**: 240fps vs 10,000fps is a 42x disadvantage. This is the single biggest limitation.
2. **Rolling shutter**: iPhone cameras use rolling shutter, causing geometric distortion of fast-moving objects. Partial mitigation is possible via computational correction.
3. **Exposure control**: At 240fps, the maximum shutter speed is 1/240s unless manually overridden. With manual control via AVCaptureDevice, can achieve ~1/2000s or faster, which is critical.
4. **Small object size**: The club head may be only 5-15 pixels depending on framing and camera selection.
5. **Ambient lighting**: Unlike professional systems with controlled flash, iPhone relies on ambient light.

### What Would Move the Needle Most

Ranked by expected accuracy improvement per effort:

1. **Motion blur speed estimation** -- High impact, software only, works best exactly when tracking fails
2. **Reflective markers** -- High impact, $5 accessory, dramatically improves detection
3. **Optimal camera settings** -- Medium-high impact, software only (fast shutter, low ISO, manual focus)
4. **LiDAR depth integration** -- Medium impact, no additional hardware on Pro models
5. **Sub-pixel tracking refinement** -- Medium impact, software only
6. **Acoustic impact timing** -- Medium impact, software only, anchors the critical moment
7. **Frame interpolation** -- Low-medium impact, computationally expensive, improvement is marginal
8. **Multi-camera capture** -- Low-medium impact, complex implementation, limited telephoto fps

---

## References & Key Resources

- RIFE Frame Interpolation: [github.com/hzwer/ECCV2022-RIFE](https://github.com/hzwer/ECCV2022-RIFE)
- AMT Frame Interpolation: [arxiv.org/abs/2304.09790](https://arxiv.org/abs/2304.09790)
- Motion Blur Velocity Estimation (UAV study): [Springer - Autonomous Intelligent Systems](https://link.springer.com/article/10.1007/s43684-024-00073-x)
- Vehicle Speed from Motion Blur: [ResearchGate](https://www.researchgate.net/publication/223042727_Vehicle_speed_detection_from_a_single_motion_blurred_image)
- Golf Club Head Tracking (UCSD): [people.cs.uchicago.edu](https://people.cs.uchicago.edu/~rchugh/static/misc/golf/golfReport.pdf)
- Machine Vision for Golf Simulators: [Edmund Optics](https://www.edmundoptics.com/knowledge-center/application-notes/imaging/machine-vision-for-golf-simulators/)
- Foresight GCQuad Technology: [foresightsports.eu](https://foresightsports.eu/launch-monitors/gcquad/)
- Event Camera Survey: [arxiv.org/html/2408.13627](https://arxiv.org/html/2408.13627v2)
- Sub-Pixel Tracking Limits: [Optica](https://opg.optica.org/ol/abstract.cfm?uri=ol-37-23-4877)
- DynaMoDe-NeRF (CVPR 2025): [openaccess.thecvf.com](https://openaccess.thecvf.com/content/CVPR2025/papers/Kumar_DynaMoDe-NeRF_Motion-aware_Deblurring_Neural_Radiance_Field_for_Dynamic_Scenes_CVPR_2025_paper.pdf)
- Reflective Markers for Golf: [Foresight Sports Help](https://help.foresightsports.com/hc/en-us/articles/4408197030035-How-to-Apply-and-Maintain-Club-Markers-for-Foresight-Sports-Devices)
- CMMotionManager: [Apple Developer Documentation](https://developer.apple.com/documentation/coremotion/cmmotionmanager)
- Multi-Camera Capture iOS: [Apple WWDC19](https://developer.apple.com/videos/play/wwdc2019/249/)
- Sports Biomechanics Smoothing: [MDPI Applied Sciences](https://www.mdpi.com/2076-3417/14/22/10573)
- Awesome Deblurring: [github.com/subeeshvasu/Awesome-Deblurring](https://github.com/subeeshvasu/Awesome-Deblurring)
