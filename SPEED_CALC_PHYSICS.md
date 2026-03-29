# Speed Calculation Physics & Mathematics

> **Purpose:** Technical reference for calculating golf club head speed from 2D camera tracking data, with 3D swing plane correction and perspective distortion compensation.
>
> **Audience:** Implementation guide for `SpeedCalculator.swift` and `CalibrationManager.swift`
>
> **Last Updated:** March 2026

---

## Table of Contents

1. [The 2D-to-3D Speed Problem](#1-the-2d-to-3d-speed-problem)
2. [Swing Plane Geometry](#2-swing-plane-geometry)
3. [Perspective Correction](#3-perspective-correction)
4. [Speed Calculation Formulas](#4-speed-calculation-formulas)
5. [Accuracy Analysis](#5-accuracy-analysis)
6. [Key Formulas Summary](#6-key-formulas-summary)
7. [Recommended Implementation](#7-recommended-implementation)

---

## 1. The 2D-to-3D Speed Problem

### 1.1 Why 2D Tracking Underestimates Speed

A front-on camera captures the club head's projection onto the image plane. The actual club head moves through a 3D arc on a tilted swing plane. The camera only sees the component of motion that is perpendicular to the camera's optical axis -- the depth component (toward/away from the camera) is invisible.

**The fundamental relationship:**

```
v_apparent_2D = v_actual_3D * cos(alpha)
```

Where `alpha` is the angle between the club head's instantaneous velocity vector and the image plane. At any point in the swing arc, a fraction of the true velocity is directed along the camera's depth axis and is invisible to 2D tracking.

### 1.2 Quantifying the 2D Speed Error

Consider a golf swing as circular motion on a tilted plane. The swing plane is tilted at angle `theta` from vertical (where the camera faces). The club head traces a circle on this tilted plane.

**Parametric position on the swing arc** (angle `phi` measured from top of backswing, increasing through downswing):

For a front-on camera (camera looks along the X axis, with Y vertical and Z horizontal in the image plane):

```
World coordinates of club head on swing arc:
  X(phi) = R * sin(theta) * sin(phi)       // depth: toward/away from camera
  Y(phi) = R * cos(phi)                     // vertical (visible)
  Z(phi) = R * cos(theta) * sin(phi)        // horizontal (visible)
```

Where:
- `R` = swing radius (arm + club length, typically 1.5-1.8m)
- `theta` = swing plane tilt from vertical (complement of plane angle from ground)
- `phi` = angular position in swing arc

**The 3D velocity magnitude:**
```
v_3D = R * omega
```
Where `omega` = angular velocity (rad/s).

**The apparent 2D velocity (what the camera sees):**
```
v_2D = R * omega * sqrt(cos^2(phi) + cos^2(theta) * sin^2(phi))
```

**The speed ratio (2D/3D):**
```
ratio = v_2D / v_3D = sqrt(cos^2(phi) + cos^2(theta) * sin^2(phi))
```

This ratio is always <= 1, meaning 2D always underestimates true speed.

### 1.3 Error by Swing Phase

The error varies dramatically through the swing arc:

| Swing Position | phi (deg) | 2D/3D Ratio (driver, theta=42) | Speed Error |
|---|---|---|---|
| Top of backswing | 0 | 1.00 | 0% |
| Early downswing | 45 | 0.87 | -13% |
| Mid downswing | 90 | 0.74 | -26% |
| Late downswing | 135 | 0.87 | -13% |
| Impact (approx) | ~160-170 | 0.97-0.99 | -1% to -3% |
| Low point | 180 | 1.00 | 0% |

**Key insight:** At impact, the club head is near the bottom of the arc (phi near 180 degrees), where most motion is in the visible plane (horizontal). The depth component is minimal. This means **2D measurement is most accurate precisely where it matters most -- at impact.**

The worst accuracy is at phi = 90 degrees (club shaft horizontal during downswing), where the depth component is maximum. For a driver swing plane (48 degrees from ground = 42 degrees from vertical), a naive 2D measurement at this point underestimates speed by about 26%.

### 1.4 Why This Works in Our Favour

For impact speed measurement specifically:
- At impact, the club is moving approximately horizontally (parallel to the ground)
- A front-on camera captures this horizontal motion well
- The depth error at impact is proportional to `sin^2(theta) * cos^2(phi_impact)`
- For phi_impact near 170 degrees: error is only 1-3%

**However:** For full swing speed profiles (graphing speed throughout the swing), the 3D correction is essential to avoid a distorted speed curve.

---

## 2. Swing Plane Geometry

### 2.1 Defining the Swing Plane

The swing plane is the tilted disc that the club head approximately traces during the downswing. It can be defined by:

1. **Normal vector** `n` = unit vector perpendicular to the plane
2. **Tilt angle** `theta_ground` = angle between the plane and the ground
3. **Centre point** = approximate spine/shoulder position

**From address position calibration data:**

```
Given:
  - spine_pos: 3D position of spine (base of neck)
  - hand_pos:  3D position of hands at address
  - club_head_pos: 3D position of club head at address

The swing plane contains the spine-to-hand vector and the hand-to-club vector.

plane_normal = normalize(cross(hand_pos - spine_pos, club_head_pos - hand_pos))
```

If we only have 2D data plus LiDAR calibration:

```
Given:
  - lie_angle: angle of club shaft to ground (from manual input or LiDAR)
  - club_length: length of club (from calibration)
  - camera_to_subject_distance: from LiDAR

The swing plane tilt from vertical:
  theta_from_vertical = 90 - lie_angle  (approximate)

For more precision, the swing plane angle differs from the lie angle by a few degrees
because the swing plane is defined by the club head path, not the shaft angle.
TrackMan data shows swing plane is typically 3-5 degrees flatter than shaft plane.
```

### 2.2 Typical Swing Plane Angles

Based on TrackMan aggregated data:

| Club | Swing Plane (from ground) | Tilt from Vertical | Typical Lie Angle |
|---|---|---|---|
| Driver | 45-50 deg | 40-45 deg | 56-60 deg |
| 3-Wood | 50-53 deg | 37-40 deg | 58-60 deg |
| 5-Iron | 55-58 deg | 32-35 deg | 60-62 deg |
| 7-Iron | 58-62 deg | 28-32 deg | 62-64 deg |
| 9-Iron | 60-63 deg | 27-30 deg | 64-65 deg |
| PW/SW | 62-65 deg | 25-28 deg | 64-65 deg |

**Scratch male golfer averages** (TrackMan):
- Driver: 48.1 degrees from ground
- 6-iron: approximately 59 degrees from ground

### 2.3 Swing Plane Normal Vector

For a front-on camera where:
- X = depth (toward camera is positive)
- Y = vertical (up is positive)
- Z = horizontal/target line (right is positive for right-handed golfer)

The swing plane normal for a right-handed golfer is approximately:

```
n = (-sin(theta_from_vertical), 0, cos(theta_from_vertical))
```

This assumes the plane contains the vertical axis. In reality it is slightly rotated, but this is a good first approximation.

More precisely, for a swing plane tilted at angle `alpha` from vertical and rotated `beta` around the vertical axis:

```
n_x = -sin(alpha) * cos(beta)
n_y = cos(alpha)                    // small for steep planes
n_z = sin(alpha) * sin(beta)
```

Where `beta` accounts for the fact that the swing plane may not be perfectly aligned with the camera axis.

### 2.4 How Plane Angle Affects the Correction Factor

The 3D speed correction factor at any point in the swing arc is:

```
correction = 1.0 / sqrt(cos^2(phi) + cos^2(theta) * sin^2(phi))
```

Where `theta` is the tilt from vertical.

At the critical impact zone (phi near 170 degrees):

| Plane Angle (from ground) | theta (from vertical) | Correction at Impact |
|---|---|---|
| 45 deg (driver) | 45 deg | 1.01 - 1.03 |
| 55 deg (mid iron) | 35 deg | 1.005 - 1.02 |
| 63 deg (wedge) | 27 deg | 1.003 - 1.01 |

**Key finding:** The correction at impact is small (1-3%) because impact occurs near the bottom of the arc. Steeper (more upright) swings need less correction. The correction is most significant for flatter swings (driver) during the mid-downswing.

---

## 3. Perspective Correction

### 3.1 The Perspective Scale Problem

A camera uses perspective projection: objects further away appear smaller. The pixels-per-metre scale factor changes with depth. If calibration is done at one depth (e.g., the ball position) but the club head moves to a different depth during the swing, the scale factor is wrong.

**Pinhole camera model:**

```
u = f * X / Z + u0
v = f * Y / Z + v0
```

Where:
- (u, v) = pixel coordinates
- (X, Y, Z) = 3D coordinates in camera frame
- f = focal length in pixels
- (u0, v0) = principal point

The scale factor (pixels per metre) at depth Z is:

```
pixels_per_metre(Z) = f / Z
```

### 3.2 Depth Variation During Swing

For a front-on camera at distance `D` from the golfer, the club head's depth varies as it swings toward and away from the camera:

```
depth_offset(phi) = R * sin(theta) * sin(phi)
Z(phi) = D + R * sin(theta) * sin(phi)
```

Where:
- D = camera-to-golfer distance (2-3m, measured at the ball/stance)
- R = swing radius (~1.5-1.8m)
- theta = swing plane tilt from vertical
- phi = position in swing arc

**Maximum depth excursion:**
```
max_depth_change = R * sin(theta)
```

For a driver: `1.7m * sin(45 deg) = 1.2m`

This means the club head can be up to 1.2m closer or further from the camera compared to the calibration plane.

### 3.3 Perspective Scale Correction

The pixel displacement between two frames measures apparent motion. To get true displacement, correct for depth:

```
true_displacement = pixel_displacement * Z_actual / Z_calibration
```

Or equivalently:

```
true_displacement = pixel_displacement / pixels_per_metre_calibration * (Z_actual / Z_calibration)
```

The correction factor is:

```
perspective_correction = Z_actual / Z_calibration = (D + depth_offset) / D
```

### 3.4 Magnitude of Perspective Error

| Camera Distance D | Max Depth Change | Max Perspective Error |
|---|---|---|
| 2.0 m | 1.2 m (driver) | +60% / -37% |
| 2.5 m | 1.2 m (driver) | +48% / -32% |
| 3.0 m | 1.2 m (driver) | +40% / -29% |
| 2.0 m | 0.8 m (7-iron) | +40% / -29% |
| 3.0 m | 0.8 m (7-iron) | +27% / -21% |

**These are worst-case numbers** at the extremes of the swing arc (top of backswing, end of follow-through). At impact, the depth offset is small:

```
At impact (phi ~ 170 deg):
  depth_offset = R * sin(theta) * sin(170 deg) = R * sin(theta) * 0.17
  For driver: 1.7 * 0.71 * 0.17 = 0.21m
  Perspective error at D=2.5m: 0.21/2.5 = 8.4%
```

**With correction applied, residual error depends on how well we know the depth.** If we model the swing as a circular arc on a known plane, the depth is deterministic and can be corrected exactly. The remaining error comes from:
- Uncertainty in the swing plane angle (typically +/- 3 degrees)
- Uncertainty in the swing radius (typically +/- 5cm)
- Deviation from a perfect circular arc (the real swing path is not a perfect circle)

### 3.5 Full Perspective Correction Formula

Given a pixel displacement `dp` between two frames at estimated depths `Z1` and `Z2`:

```
real_displacement = dp / ppm_calibration * (Z1 + Z2) / (2 * Z_calibration)
```

Where `ppm_calibration` is the pixels-per-metre measured at `Z_calibration`.

For the speed calculation:

```
speed = real_displacement / dt
```

Where `dt` is the actual time between frames (from CMSampleBuffer timestamps).

---

## 4. Speed Calculation Formulas

### 4.1 Level 0: Naive 2D (Current Implementation)

```
pixel_distance = sqrt((x2-x1)^2 + (y2-y1)^2)
real_distance = pixel_distance / pixels_per_metre
speed_ms = real_distance / dt
speed_mph = speed_ms * 2.23694
```

**Expected error: +/- 10-30% depending on swing phase**
At impact: +/- 2-8% (because depth component is small)

### 4.2 Level 1: 2D + Perspective Correction

```
// Estimate depth at each tracked point using swing plane model
Z1 = D + R * sin(theta) * sin(phi1)
Z2 = D + R * sin(theta) * sin(phi2)

// Correct pixel distance for perspective
corrected_distance = pixel_distance / ppm * (Z1 + Z2) / (2 * D)
speed_ms = corrected_distance / dt
```

To estimate `phi` (angular position) from 2D tracked position:
```
// The vertical component is preserved by front-on camera
// phi can be estimated from the Y coordinate relative to shoulder
cos(phi) = (Y_shoulder - Y_clubhead) / R_apparent
phi = acos(...)
```

**Expected improvement: reduces perspective error from 8% to ~2% at impact**

### 4.3 Level 2: Full 3D Arc Speed from 2D Tracking

Given a 2D tracked position (u, v) in pixels and a known swing plane, reconstruct the 3D position on the arc:

**Step 1: Construct a ray from the camera through the pixel**
```
ray_direction = normalize((u - u0) / f, (v - v0) / f, 1.0)
```

**Step 2: Intersect the ray with the swing plane**

The swing plane passes through the pivot point (shoulder) with normal `n`:
```
Plane equation: dot(n, P - shoulder) = 0
Ray equation: P = camera_origin + t * ray_direction

t = dot(n, shoulder - camera_origin) / dot(n, ray_direction)
P_3D = camera_origin + t * ray_direction
```

This gives the 3D position of the club head on the swing plane.

**Step 3: Calculate 3D speed**
```
distance_3D = length(P_3D_frame2 - P_3D_frame1)
speed_3D = distance_3D / dt
```

**Expected error: +/- 3-8% total (dominated by tracking noise, not geometry)**

### 4.4 Level 3: Impact Speed Extraction

Impact speed is the most important single number. Extract it from frames surrounding the impact event:

```
1. Identify impact frame (audio spike, sudden deceleration, or ball appearance change)
2. Use frames impact-2, impact-1, impact, impact+1, impact+2 (5 frames = 20ms window at 240fps)
3. Calculate speed for each consecutive frame pair
4. Weight by proximity to impact and tracking confidence:

impact_speed = sum(w_i * speed_i) / sum(w_i)

where w_i = confidence_i * gaussian(t_i - t_impact, sigma=0.004)
```

Using more frames reduces noise; the Gaussian weighting (sigma = 4ms, roughly 1 frame at 240fps) ensures the impact moment is most influential.

**Alternative: Fit a polynomial to the speed curve near impact and evaluate at t_impact**
```
Fit quadratic: speed(t) = a*t^2 + b*t + c to the 5-7 points around impact
impact_speed = speed(t_impact)
```

This is more robust to individual noisy frames.

### 4.5 Motion Blur Velocity Estimation

When the club head is moving fast, it creates a motion blur streak. The streak length encodes velocity information:

```
blur_length_metres = streak_length_pixels / pixels_per_metre(Z)
speed_from_blur = blur_length_metres / exposure_time
```

Where `exposure_time` is from the frame's metadata (CMSampleBuffer exposure duration).

**At 100 mph (44.7 m/s) with 1/1000s exposure:**
```
blur = 44.7 * 0.001 = 0.0447m = 4.47cm
At 2.5m distance with typical phone camera (f ~ 4000 pixels for 1080p):
blur_pixels = 0.0447 * 4000 / 2.5 = 71.5 pixels
```

This is very measurable and provides a useful independent speed estimate.

**At 1/2000s exposure (achievable in good light):**
```
blur = 44.7 * 0.0005 = 2.24cm = ~36 pixels
```

Still measurable, but lower signal.

### 4.6 Fused Speed Estimate

Combine frame-to-frame tracking speed with motion blur speed:

```
// Adaptive weighting based on confidence
alpha = tracking_confidence  // 0.0 to 1.0
beta = blur_confidence       // 0.0 to 1.0

// Normalize weights
w_track = alpha / (alpha + beta)
w_blur = beta / (alpha + beta)

fused_speed = w_track * tracking_speed + w_blur * blur_speed
```

**Blur confidence** should be high when:
- The blur streak is clearly directional (not just noise)
- The streak length is consistent with the tracking speed (within 30%)
- Exposure time is accurately known

**Tracking confidence** should be high when:
- YOLO detection confidence is high
- Kalman filter innovation (prediction error) is small
- Consecutive tracked frames exist (smooth trajectory)

### 4.7 Confidence Scoring

```
confidence = base_tracking_confidence
           * trajectory_smoothness_factor
           * blur_agreement_factor
           * constraint_satisfaction_factor

where:
  base_tracking_confidence: from YOLO/Vision detection (0-1)

  trajectory_smoothness_factor: 1.0 if the tracked positions follow a smooth arc,
    drops toward 0.5 for erratic jumps. Computed as:
    1.0 - clamp(jerk / max_expected_jerk, 0, 0.5)

  blur_agreement_factor: 1.0 if tracking and blur speeds agree within 10%,
    0.8 if within 20%, drops linearly to 0.5 at 50% disagreement.
    = 1.0 - 0.5 * clamp(|speed_track - speed_blur| / speed_track / 0.5, 0, 1)

  constraint_satisfaction_factor: 1.0 if club head is within club_length of wrist,
    drops as the constraint is violated.
    = 1.0 - clamp((distance_to_wrist - club_length) / club_length, 0, 0.5)
```

---

## 5. Accuracy Analysis

### 5.1 Error Budget

| Error Source | Magnitude (at impact) | Mitigation |
|---|---|---|
| 2D depth projection | 1-3% | Swing plane correction |
| Perspective scale | 2-8% | Depth-corrected scale factor |
| Pixel tracking noise | +/- 1-3 pixels = 3-9% | Kalman filter, multi-frame averaging |
| Frame timing jitter | 0.1-0.5% | Use actual timestamps |
| Calibration scale error | 2-5% | LiDAR calibration |
| Swing plane angle uncertainty | 1-3% | Address position calibration |
| Non-circular arc | 0.5-1% | Small -- swing arc is nearly circular near impact |

### 5.2 Pixel Error to Speed Error Conversion

At 240fps, a 100 mph club head moves approximately:

```
100 mph = 44.7 m/s
Distance per frame = 44.7 / 240 = 0.186m = 18.6cm
At 2.5m camera distance, with iPhone 13 Pro (f ~ 26mm, sensor 5.7mm wide):
  pixels_per_metre at 2.5m = (1920 / sensor_width_m) * (f / D)
  For iPhone 13 Pro main camera: approximately 770 pixels/metre at 2.5m distance
  18.6cm = 143 pixels per frame
```

**1 pixel error in position = 2 pixel error in displacement (worst case) = 2/143 = 1.4% speed error**

More precisely:
```
speed_error_mph = (pixel_error / pixels_per_frame_displacement) * actual_speed

For 1-pixel error at 100mph:
  speed_error = (1/143) * 100 = 0.7 mph per pixel of position error
  With 2 positions (start/end): ~1.4 mph per pixel of position error
```

At different speeds:
| Speed (mph) | Pixels/Frame at 240fps | 1-pixel error (mph) |
|---|---|---|
| 50 | 72 | 0.7 |
| 80 | 115 | 0.7 |
| 100 | 143 | 0.7 |
| 120 | 172 | 0.7 |

The error in mph is approximately constant at 0.7 mph per pixel of position error (at 2.5m camera distance, 1920px width). This is because both displacement and speed scale linearly.

### 5.3 Frame Rate Impact on Accuracy

```
displacement_per_frame = speed / fps
pixel_displacement = displacement_per_frame * pixels_per_metre

Higher fps = smaller displacement per frame = pixel errors are a larger fraction
```

Paradoxically, higher frame rate can reduce per-frame accuracy. But multi-frame averaging recovers this:

| fps | Pixels/Frame (100mph) | 1px Error | Using 3-Frame Average |
|---|---|---|---|
| 120 | 287 | 0.35% | 0.20% |
| 240 | 143 | 0.70% | 0.40% |

**However,** 240fps gives more data points near impact and better temporal resolution for identifying the exact impact moment. The net effect is positive.

### 5.4 Expected Accuracy by Correction Level

| Level | Method | Impact Speed Error (mph) |
|---|---|---|
| 0 | Naive 2D, manual calibration | +/- 8-15 mph |
| 1 | 2D + perspective correction | +/- 4-8 mph |
| 2 | 3D swing plane reconstruction | +/- 3-5 mph |
| 3 | Level 2 + LiDAR calibration | +/- 2-4 mph |
| 4 | Level 3 + blur fusion + Kalman | +/- 1-3 mph |
| 5 | Level 4 + ML correction model | +/- 1-2 mph |

### 5.5 Comparison to Commercial Devices

| Device | Technology | Club Head Speed Accuracy |
|---|---|---|
| TrackMan 4 | Dual radar, 20kHz | +/- 0.5 mph |
| Foresight GCQuad | 4x stereo cameras | +/- 1 mph |
| Rapsodo MLM2 Pro | Dual camera + radar | +/- 1-2% (~1-2 mph) |
| Garmin R10 | Radar | +/- 2% (~2-3 mph) |
| PRGR Speed Monitor | Radar | +/- 2 mph |
| **Our app (target v1)** | **Single 240fps camera** | **+/- 5-8 mph** |
| **Our app (target v2)** | **+ LiDAR + ML** | **+/- 2-4 mph** |

The v1 target of +/- 5-8 mph is achievable with basic 2D tracking + perspective correction + LiDAR calibration. This is useful for speed training (tracking relative improvement) even if absolute accuracy is lower than dedicated devices.

---

## 6. Key Formulas Summary

### 6.1 Swing Plane Normal from Calibration Data

```
// Given lie angle and camera-to-subject setup
let theta = (90.0 - lieAngleDegrees) * .pi / 180.0  // tilt from vertical in radians
let planeNormal = SIMD3<Float>(
    -sin(Float(theta)),  // X: depth component
    0,                   // Y: vertical (plane contains vertical axis, approximately)
    cos(Float(theta))    // Z: horizontal component
)
```

### 6.2 Depth at Any Point on the Swing Arc

```
// phi: angular position on swing arc (0 = top, pi = bottom/impact)
// R: swing radius in metres
// theta: swing plane tilt from vertical
// D: camera-to-golfer distance in metres
func depthAtArcPosition(phi: Double, R: Double, theta: Double, D: Double) -> Double {
    return D + R * sin(theta) * sin(phi)
}
```

### 6.3 Perspective-Corrected Speed

```
func correctedSpeed(
    pixelDisplacement: Double,
    ppmAtCalibrationDepth: Double,
    calibrationDepth: Double,
    depth1: Double,
    depth2: Double,
    dt: Double
) -> Double {
    let avgDepth = (depth1 + depth2) / 2.0
    let correctedDisplacementMetres = (pixelDisplacement / ppmAtCalibrationDepth) * (avgDepth / calibrationDepth)
    return correctedDisplacementMetres / dt
}
```

### 6.4 3D Position from 2D Pixel + Swing Plane Intersection

```
func reconstruct3DPosition(
    pixelU: Double, pixelV: Double,
    focalLengthPixels: Double,
    principalPoint: (Double, Double),
    cameraPosition: SIMD3<Float>,
    planeNormal: SIMD3<Float>,
    planePoint: SIMD3<Float>  // shoulder/pivot position
) -> SIMD3<Float>? {
    // Ray from camera through pixel
    let rayDir = normalize(SIMD3<Float>(
        Float((pixelU - principalPoint.0) / focalLengthPixels),
        Float((pixelV - principalPoint.1) / focalLengthPixels),
        1.0
    ))

    // Intersect ray with swing plane
    let denom = dot(planeNormal, rayDir)
    guard abs(denom) > 1e-6 else { return nil }  // ray parallel to plane

    let t = dot(planeNormal, planePoint - cameraPosition) / denom
    guard t > 0 else { return nil }  // intersection behind camera

    return cameraPosition + t * rayDir
}
```

### 6.5 Angular Position Estimation from 2D Tracking

```
func estimateArcAngle(
    clubHeadY: Double,     // vertical pixel position of club head
    shoulderY: Double,     // vertical pixel position of shoulder/pivot
    swingRadiusPixels: Double
) -> Double {
    // cos(phi) = (shoulderY - clubHeadY) / R_pixels
    // Note: pixel Y increases downward, so club below shoulder = positive cos(phi)
    let cosPhiRaw = (shoulderY - clubHeadY) / swingRadiusPixels
    let cosPhi = max(-1.0, min(1.0, cosPhiRaw))
    return acos(cosPhi)
}
```

### 6.6 Motion Blur Speed

```
func speedFromBlur(
    streakLengthPixels: Double,
    exposureTimeSeconds: Double,
    pixelsPerMetre: Double,
    depthCorrectionFactor: Double  // Z_actual / Z_calibration
) -> Double {
    let streakMetres = (streakLengthPixels / pixelsPerMetre) * depthCorrectionFactor
    return streakMetres / exposureTimeSeconds  // m/s
}
```

### 6.7 Fused Impact Speed

```
func fusedImpactSpeed(
    trackingSpeeds: [(speed: Double, confidence: Double, timestamp: Double)],
    blurSpeeds: [(speed: Double, confidence: Double, timestamp: Double)],
    impactTimestamp: Double,
    sigma: Double = 0.004  // 4ms Gaussian width
) -> (speed: Double, confidence: Double) {
    var weightedSum = 0.0
    var totalWeight = 0.0

    for s in trackingSpeeds {
        let timeWeight = exp(-pow(s.timestamp - impactTimestamp, 2) / (2 * sigma * sigma))
        let w = s.confidence * timeWeight
        weightedSum += w * s.speed
        totalWeight += w
    }

    for s in blurSpeeds {
        let timeWeight = exp(-pow(s.timestamp - impactTimestamp, 2) / (2 * sigma * sigma))
        let w = s.confidence * timeWeight * 0.5  // blur gets lower base weight
        weightedSum += w * s.speed
        totalWeight += w
    }

    guard totalWeight > 0 else { return (0, 0) }
    return (weightedSum / totalWeight, min(1.0, totalWeight / 3.0))
}
```

---

## 7. Recommended Implementation

### 7.1 Phase 1 (v1.0): Basic 2D + Perspective Correction

1. Keep the existing `SpeedCalculator.instantaneousSpeed()` as the fallback
2. Add swing plane angle as a calibration parameter (default by club type)
3. Add depth estimation per frame using the swing arc model
4. Apply perspective correction to pixel displacements
5. Use polynomial fitting for impact speed extraction

**Expected accuracy improvement: from +/- 10-15 mph to +/- 5-8 mph**

### 7.2 Phase 2 (v1.1): 3D Reconstruction

1. Implement ray-plane intersection for full 3D position reconstruction
2. Use Apple's 3D body pose for shoulder/wrist positions as pivot points
3. Calculate 3D distances between consecutive positions
4. Add motion blur speed estimation as supplementary signal
5. Implement confidence-weighted fusion

**Expected accuracy improvement: from +/- 5-8 mph to +/- 3-5 mph**

### 7.3 Phase 3 (v2.0): LiDAR + ML

1. Use LiDAR at address for precise swing plane and scale calibration
2. Train ML model on accumulated data to predict correction factors
3. Add sub-pixel tracking refinement
4. Cross-validate against blur estimates for quality assurance

**Expected accuracy improvement: from +/- 3-5 mph to +/- 2-4 mph**

### 7.4 Implementation Priority

The highest-impact changes for the least implementation effort:

1. **Swing plane angle per club type** (1 hour) -- add a lookup table, apply correction factor
2. **Perspective depth correction** (2 hours) -- estimate depth from arc position, correct scale
3. **Impact speed polynomial fitting** (1 hour) -- reduce noise by fitting curve near impact
4. **Motion blur speed estimation** (3 hours) -- requires blur streak detection algorithm
5. **Ray-plane 3D reconstruction** (4 hours) -- requires camera intrinsics + plane estimation
6. **Confidence-weighted fusion** (2 hours) -- combine all signals with quality weights

---

## Appendix A: iPhone Camera Intrinsics

Approximate values for iPhone 13 Pro main camera (used for 240fps capture):

| Parameter | Value |
|---|---|
| Sensor width | 5.7mm |
| Focal length | 5.7mm (26mm equivalent) |
| Image size (240fps) | 1920 x 1080 |
| Focal length in pixels (fx) | ~1920 (at 1920px width) |
| Principal point (u0, v0) | ~(960, 540) |
| Horizontal FOV | ~67 degrees |

Note: Exact values can be obtained from `AVCaptureDevice.activeFormat` intrinsic matrix at runtime. Always prefer runtime values over these approximations.

```swift
// Getting camera intrinsics at runtime
if let intrinsicMatrix = captureDevice.activeFormat.videoFieldOfView {
    // Or via CMSampleBuffer:
    // let intrinsics = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, ...)
}
```

## Appendix B: Useful Constants

```swift
// Swing plane angles (from ground, in degrees)
static let swingPlaneAngles: [ClubType: Double] = [
    .driver: 48.0,
    .threeWood: 51.0,
    .hybrid: 55.0,
    .fiveIron: 57.0,
    .sixIron: 59.0,
    .sevenIron: 60.0,
    .eightIron: 61.0,
    .nineIron: 62.0,
    .pitchingWedge: 63.0,
    .gapWedge: 63.5,
    .sandWedge: 64.0,
    .lobWedge: 64.5,
    .speedStick: 48.0,  // similar to driver
    .other: 55.0,
]

// Average swing radii (arm + club length, in metres)
static let typicalSwingRadius: [ClubType: Double] = [
    .driver: 1.75,
    .threeWood: 1.70,
    .hybrid: 1.60,
    .fiveIron: 1.55,
    .sixIron: 1.50,
    .sevenIron: 1.45,
    .eightIron: 1.40,
    .nineIron: 1.35,
    .pitchingWedge: 1.30,
    .gapWedge: 1.28,
    .sandWedge: 1.25,
    .lobWedge: 1.22,
    .speedStick: 1.70,
    .other: 1.50,
]
```

---

## Sources

- [TrackMan: What is Swing Plane in Golf?](https://www.trackman.com/blog/golf/what-is-swing-plane)
- [A Three Dimensional Kinematic and Kinetic Study of the Golf Swing (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC3899667/)
- [Jacobs 3D: Swing Angles](https://jacobs3d.com/playbook/swing-angles)
- [Measuring the Timing of the Golf Swing from Video (MyTPI)](https://www.mytpi.com/articles/biomechanics/measuring-the-timing-of-the-golf-swing-from-video)
- [CSE 190a: Golf Club Head Tracking (UC San Diego)](https://people.cs.uchicago.edu/~rchugh/static/misc/golf/golfReport.pdf)
- [ScienceInsights: How to Measure Club Head Speed](https://scienceinsights.org/how-to-measure-club-head-speed-with-or-without-a-monitor/)
- [A Real-Time Vision-Based System for Badminton Smash Speed (arXiv)](https://arxiv.org/html/2509.05334v1)
- [Where Is The Ball: 3D Ball Trajectory from 2D Monocular Tracking (arXiv)](https://arxiv.org/html/2506.05763v1)
- [Vehicle Speed Estimation Using Computer Vision (OpenReview)](https://openreview.net/pdf?id=Pl7uHR-Oe6l)
- [Tracking by Deblatting (Springer)](https://link.springer.com/article/10.1007/s11263-021-01480-w)
- [Perspective Distortion Correction for Planar Imaging (MDPI)](https://www.mdpi.com/1424-8220/25/6/1891)
- [Dissecting the Camera Matrix: The Intrinsic Matrix](https://ksimek.github.io/2013/08/13/intrinsic/)
- [Pinhole Camera Model (MIT)](https://vnav.mit.edu/material/11-ImageFormation-notes.pdf)
- [Golf Biomechanics and Swing Plane (GolfWRX)](https://www.golfwrx.com/181715/biomechanics-and-how-they-affect-swing-plane/)
- [Rapsodo MLM2PRO vs Garmin R10 Comparison (PlayBetter)](https://www.playbetter.com/blogs/golf-simulator-comparisons/rapsodo-mlm2pro-vs-garmin-approach-r10-comparison-review)
- [Garmin R10 vs Rapsodo MLM2PRO (Rain or Shine Golf)](https://rainorshinegolf.com/blogs/product-comparisons-reviews/garmin-r10-vs-rapsodo-mlm2pro)
