# Golf Apps & Simulator Platforms: Comprehensive Competitor Research

**Date:** March 22, 2026
**Purpose:** Competitive landscape analysis for camera-based golf swing speed measurement app

---

## Table of Contents

1. [CRITICAL REFERENCE: SwingVision (Tennis) -- Camera-Only Speed Tracking](#1-critical-reference-swingvision-tennis)
2. [Camera-Only Golf Speed Measurement Apps](#2-camera-only-golf-speed-measurement-apps)
3. [Smartphone Camera Golf Swing Analysis Apps](#3-smartphone-camera-golf-swing-analysis-apps)
4. [AI-Powered Golf Swing Analysis (New Wave)](#4-ai-powered-golf-swing-analysis-new-wave)
5. [Simulator Software & Platforms](#5-simulator-software--platforms)
6. [GPS & Shot Tracking Systems](#6-gps--shot-tracking-systems)
7. [Wearable Sensor-Based Trackers](#7-wearable-sensor-based-trackers)
8. [Key Technology Comparison Table](#8-key-technology-comparison-table)
9. [Key Takeaways for Our Project](#9-key-takeaways-for-our-project)

---

## 1. CRITICAL REFERENCE: SwingVision (Tennis)

> **This is the single most relevant competitor/reference for our project.** SwingVision proves that camera-only speed tracking from a smartphone is commercially viable.

### Overview

| Field | Details |
|-------|---------|
| **Full Name** | SwingVision: AI Stats for Tennis & Pickleball |
| **Company** | SwingVision Inc. (founded by Swupnil Sahai & Richard Hsu) |
| **Category** | AI-powered sports analytics (tennis/pickleball) |
| **Price** | Free tier + Premium subscription (~$14.99/month or $99.99/year) |
| **Platforms** | iOS (iPhone, iPad), Apple Watch |
| **Hardware Required** | iPhone or iPad mounted on fence/tripod; no external sensors |

### Founding Team & Background

- **Swupnil Sahai (CEO):** Former Senior Computer Vision Engineer at Tesla Autopilot. Worked directly with Elon Musk on 3D object tracking for autonomous driving. UC Berkeley graduate (Economics, Applied Math, Statistics). Two-time WWDC scholar.
- **Richard Hsu (Co-Founder):** Sahai's college roommate from UC Berkeley.
- **Team Background:** AI experts from Tesla and Apple. Venture-backed by Tennis Australia, Sony, and Techstars.
- **Key Insight:** Sahai realized the same 3D object tracking techniques used for self-driving cars could track balls on a tennis court.

### Technology Deep Dive

| Aspect | Details |
|--------|---------|
| **Core Technology** | On-device computer vision + machine learning using Apple's Neural Engine via CoreML |
| **Camera Requirements** | Standard iPhone/iPad rear camera at 60 fps minimum |
| **Processing** | Entirely on-device -- no internet connection required for real-time analysis |
| **Neural Engine Dependency** | App is "basically not possible without Neural Engine" (direct quote from Apple Developer story) |
| **Video Processing** | ~2 million pixels processed 60 times per second in real-time |
| **ML Models** | Proprietary models trained on thousands of hours of tennis footage; optimized to be as "lean as possible" |
| **Ball Tracking** | Tracks ball trajectory across full flight path |
| **Player Tracking** | Tracks player movement and positioning |

### Speed Measurement Method

- **How it works:** Calculates ball speed by averaging velocity over the entire flight path from the video frames.
- **Key difference from radar:** Readings are approximately 20% lower than TV radar because radar measures peak speed at impact, while SwingVision calculates average speed across the complete trajectory.
- **Implication for golf:** A similar approach for golf would need to account for this -- either measure average speed and communicate clearly, or develop trajectory-based extrapolation to estimate impact speed.

### Accuracy & Validation

| Metric | Accuracy |
|--------|----------|
| **Ball Speed** | Within ~10% of radar reference |
| **Ball Placement** | Within ~5% accuracy |
| **Speed ICC** | 0.76--0.80 (good validity, peer-reviewed) |
| **Placement ICC** | 0.83--0.87 (good to very good validity) |
| **Scientific Source** | MDPI Applied Sciences 13(10):6195, peer-reviewed study |

### Known Limitations

- Ball tracking challenged by small ball size and high speed
- Bounce zone affected by occlusion (players blocking view)
- Requires 60 fps minimum -- lower rates miss ball bounces entirely
- Accuracy varies with camera setup quality and positioning
- Speed accuracy decreases with suboptimal angles

### Why This Matters for Our Project

1. **Proves camera-only speed measurement works** on a standard iPhone with no external hardware
2. **Demonstrates on-device ML** is fast enough for real-time object tracking at 60 fps
3. **CoreML + Neural Engine** is the proven tech stack for this type of application
4. **10% speed accuracy** is a realistic baseline expectation for camera-only approaches
5. **Tennis balls travel 50-160 mph** -- golf clubheads move 60-130 mph, a comparable speed range
6. **However:** Tennis balls are visible across a long flight path (many frames); a golf clubhead at impact is only visible for a few frames, making the tracking challenge different and arguably harder

### Sources
- [SwingVision Official Site](https://swing.vision/)
- [Apple Developer: Behind the Design](https://developer.apple.com/news/?id=0pg4dthn)
- [Apple Newsroom: SwingVision Feature](https://www.apple.com/newsroom/2022/05/swupnil-sahai-and-his-co-founder-serve-an-ace-with-ai-powered-swingvision/)
- [MDPI Validation Study](https://www.mdpi.com/2076-3417/13/10/6195)
- [Tennis.com: SwingVision Review](https://www.tennis.com/baseline/articles/swingvision-delivers-pro-level-insights-for-recreational-players)
- [Pocket-lint: How SwingVision Works](https://www.pocket-lint.com/apps/news/apple/161241-what-is-the-swingvision-ai-app-how-does-it-work-how-can-it-improve-your-tennis/)

---

## 2. Camera-Only Golf Speed Measurement Apps

### 2a. ShotVision (Launch Monitor App)

> **The closest existing competitor to our concept in golf.** Uses only the iPhone camera to act as a launch monitor.

| Field | Details |
|-------|---------|
| **Full Name** | ShotVision Launch Monitor |
| **Company** | ShotVision |
| **Category** | Camera-based golf launch monitor |
| **Price** | Free (limited) / Pro: ~$9.99/month or $69.99/year |
| **Platforms** | iOS only |
| **Hardware Required** | iPhone rear camera only -- no external sensors |

#### Technology

- Uses **computer vision** through the iPhone's rear camera to detect and track the golf ball and club
- **Directly measures:** Ball speed, horizontal & vertical launch angle, club path
- **Algorithmically calculates:** Club face angle, spin, spin axis, carry distance, total distance
- Requires phone positioned parallel to the hitting direction using an alignment tool

#### Accuracy Assessment

- **Good conditions:** "Pretty accurate overall and certainly accurate enough to get a clear understanding of your swing" (MyGolfSpy)
- **Poor conditions:** Metrics can be off by 30-50% vs. Foresight GC Quad in bad lighting
- **Device dependency:** Accuracy scales directly with iPhone model -- newer phones are more accurate
- **Detection reliability:** Not all shots register; some well-struck shots fail to be detected
- **Critical factor:** Lighting is "make or break" for performance

#### Known Limitations

- Highly sensitive to lighting conditions
- Older iPhones produce significantly less accurate results
- Camera positioning must be precise (parallel to shot line)
- Shot detection is not 100% reliable
- Outdoor use in bright sunlight or low-light conditions is problematic

#### Sources
- [ShotVision Official Site](https://www.shotvisionapp.com/)
- [MyGolfSpy Review](https://mygolfspy.com/we-tried-it/we-tried-it-shot-vision-app/)
- [Golflink Review](https://www.golflink.com/equipment/shotvision-launch-monitor-app-review)
- [App Store](https://apps.apple.com/us/app/shotvision-launch-monitor/id1352247118)

---

## 3. Smartphone Camera Golf Swing Analysis Apps

These apps use the phone camera for **visual analysis** but do NOT attempt to measure speed from the camera alone.

### 3a. Swing Profile

| Field | Details |
|-------|---------|
| **Full Name** | Swing Profile Golf Analyzer |
| **Company** | Swing Profile |
| **Category** | AI-powered swing analysis |
| **Price** | Free (basic) / Premium subscription for advanced features |
| **Platforms** | iOS, Android |
| **Hardware Required** | iPhone/iPad camera (rear camera for 240fps mode) |

#### Technology

- **Patent-pending AI swing detection:** Automatically detects and records swings hands-free
- Records at up to **240 fps** on supported iPhones (rear camera only)
- Patented algorithm trims video to the 2-second swing motion only
- Auto-detects key swing positions and creates swing sequence
- Draws reference lines automatically (club line, neck-to-ball line)
- **Does NOT measure speed** -- purely visual/positional analysis

#### Innovative Approach

- Hands-free, automatic recording and trimming is a strong UX innovation
- AI-based swing detection eliminates manual video clipping
- Instant slow-motion replay without user interaction

#### Sources
- [Swing Profile Official](https://www.swingprofile.com/)
- [App Store](https://apps.apple.com/us/app/swing-profile-golf-analyzer/id1039981052)

### 3b. V1 Golf / V1 Sports

| Field | Details |
|-------|---------|
| **Full Name** | V1 Golf: Golf Swing Analyzer |
| **Company** | V1 Sports |
| **Category** | Video swing analysis + coaching platform |
| **Price** | Free (3 videos) / Premium: $59.99/year / Coaching from $14.99/month |
| **Platforms** | iOS, Android |
| **Hardware Required** | Phone/tablet camera |

#### Technology

- **Ball Tracing:** Visualizes ball flight path directly from video (no radar needed) -- uses CV to track the ball in recorded video
- **Skeletal Tracking:** AI-powered body pose estimation that overlays skeleton on swing video, revealing body movements hidden by clothing
- **Ground pressure sensor integration** for foot pressure analysis
- Cloud-based session storage and sync
- Largest model swing library (PGA, LIV, LPGA professionals)

#### Relevance

- Ball Tracing proves that **CV-based ball detection from phone video** is achievable in golf
- Skeletal Tracking demonstrates **pose estimation** can run on phone-captured golf video
- However, analysis appears to be **post-processed**, not real-time

#### Sources
- [V1 Sports Official](https://v1sports.com/)
- [App Store](https://apps.apple.com/us/app/v1-golf-golf-swing-analyzer/id349715369)

### 3c. Hudl Technique Golf (formerly Ubersense)

| Field | Details |
|-------|---------|
| **Full Name** | Hudl Technique Golf (formerly Ubersense Golf) |
| **Company** | Hudl (acquired Ubersense) -- now branded as OnForm |
| **Category** | Video analysis |
| **Price** | Free |
| **Platforms** | iOS |
| **Hardware Required** | iPhone/iPad camera |

#### Technology

- Records in HD up to **240 fps** on supported devices
- Frame-by-frame analysis with swing plane drawings
- Side-by-side comparison with 90+ PGA professional swings
- Voice-over annotations
- Import video from external cameras
- **No speed measurement** -- purely visual analysis

#### Status

- Over 10 million swings analyzed worldwide
- Now rebranded under OnForm

#### Sources
- [App Store](https://apps.apple.com/app/video-coach-ubersense/id581759921)

### 3d. Coach's Eye

| Field | Details |
|-------|---------|
| **Full Name** | Coach's Eye |
| **Company** | TechSmith |
| **Category** | Video analysis (multi-sport) |
| **Price** | Was subscription-based |
| **Platforms** | Was iOS, Android |
| **Status** | **DISCONTINUED** -- shut down September 15, 2022 |

#### Technology (Historical)

- Slow-motion playback and frame-by-frame analysis
- Drawing tools (lines, arrows) for annotation
- Side-by-side comparison
- No speed measurement capability

#### Sources
- [SeamsUp: Coach's Eye Alternative](https://seamsup.com/blog/the-best-coach-s-eye-alternative-for-video-analysis-seams-up)

### 3e. GolfShot

| Field | Details |
|-------|---------|
| **Full Name** | Golfshot Golf GPS |
| **Company** | Shotzoom Software |
| **Category** | GPS rangefinder + scoring + AR |
| **Price** | Free / Pro: $79.99/year or $17.99/month |
| **Platforms** | iOS, Android, Apple Watch, Wear OS |
| **Users** | 5 million+ |

#### Technology

- GPS rangefinder with 45,000+ courses
- **Golfscape AR:** Augmented reality feature using device camera for 360-degree course visualization
- Auto Shot Tracking via Apple Watch
- Auto Strokes Gained analysis
- Dynamic 3D flyover preview of holes
- Club recommendations based on performance data
- **No swing analysis or speed measurement** -- GPS/scoring focused

#### Sources
- [Golfshot Official](https://golfshot.com/)

### 3f. SwingU

| Field | Details |
|-------|---------|
| **Full Name** | SwingU Golf GPS |
| **Company** | SwingU |
| **Category** | GPS rangefinder + scoring + instruction |
| **Price** | Free / Plus: $49.99/year / Pro: $99.99/year |
| **Platforms** | iOS, Android, Apple Watch |

#### Technology

- GPS with AI-powered yardages (wind, slope adjustment)
- StrackaLine-powered green reading
- Club tracking and recommendation engine
- Weather-adjusted distance calculations
- **No camera-based swing or speed analysis** -- GPS/data focused

#### Sources
- [SwingU Official](https://swingu.com/)

---

## 4. AI-Powered Golf Swing Analysis (New Wave)

### 4a. GolfFix AI

| Field | Details |
|-------|---------|
| **Full Name** | GolfFix: AI Swing Analyzer |
| **Company** | MOAIS (now MWM) |
| **Category** | AI-powered swing analysis + coaching |
| **Price** | Free (basic) / Premium subscription |
| **Platforms** | iOS, Android |

#### Technology

- **AI vision technology** for automatic swing detection (address to finish)
- Detects **45+ swing issues** automatically (slice, hook, etc.)
- Rhythm and tempo analysis (breaks swing into 4 phases)
- Pose comparison with professional golfers
- Personalized AI coaching with tailored drills
- Supports 60 fps video
- **Does NOT measure club speed** -- focuses on swing form/mechanics

#### Sources
- [App Store](https://apps.apple.com/us/app/golffix-ai-golf-swing-analyzer/id1586120680)

### 4b. Sportsbox AI

| Field | Details |
|-------|---------|
| **Full Name** | Sportsbox 3D Golf |
| **Company** | Sportsbox AI (founded 2020) |
| **Category** | 3D motion analysis |
| **Price** | Free (limited) / Player: $110/year / Studio system: from $5,000 |
| **Platforms** | iOS, Android |

#### Technology

- **Patent-pending 3D Motion Analysis** from a single phone camera video
- Tracks **30+ key points** on body, club, and ball
- Creates full 3D animation viewable from 6 angles (face-on, DTL, behind, from target, above, below)
- Measures in **inches and degrees** -- angular and linear measurements (turn, bend, side bend, flexion, sway, lift)
- No sensors, vests, or calibration required
- **Kinematic AI technology** for motion analysis

#### Relevance

- Demonstrates that **3D body pose reconstruction from 2D video** is commercially viable on mobile
- 30+ point tracking from a single camera is impressive
- However, focuses on body/swing mechanics, **not speed measurement**

#### Sources
- [Sportsbox AI Official](https://www.sportsbox.ai/)
- [App Store](https://apps.apple.com/us/app/sportsbox-3d-golf/id1578921026)

---

## 5. Simulator Software & Platforms

### 5a. E6 Connect

| Field | Details |
|-------|---------|
| **Full Name** | E6 Connect |
| **Company** | TruGolf |
| **Category** | Premium golf simulation software |
| **Price** | $400--800/year (tiered subscriptions) |
| **Platforms** | PC, iOS |
| **Hardware Required** | Launch monitor (Uneekor, Flightscope, Garmin, NVISAGE, TruGolf) |

#### Technology & Features

- 4K resolution graphics; 100+ courses (18 in Golf Digest top 100)
- Post-shot swing analyzer: distance, carry, spin, launch angle, clubhead speed, ball speed, smash factor, face angle, club path
- Online multiplayer and tournament system
- Commercial "Clubhouse" management software for facilities
- **Does not do any tracking itself** -- relies entirely on connected launch monitors

#### Sources
- [TruGolf E6 Connect](https://trugolf.com/pages/e6-connect)
- [E6 Connect Cost Breakdown](https://golfersauthority.com/e6-connect-cost/)

### 5b. GSPro

| Field | Details |
|-------|---------|
| **Full Name** | GSPro (Golfmechanix Simulator Professional) |
| **Company** | GSPro Golf |
| **Category** | Golf simulation software |
| **Price** | $250/year |
| **Platforms** | Windows PC only |
| **Hardware Required** | Launch monitor (Uneekor, Foresight, FlightScope, MLM2PRO) + GTX 1070/RX 580 GPU minimum |

#### Technology & Features

- Built on **Unity gaming engine** with 4K graphics
- 1,000+ community-created courses (LIDAR-based recreations)
- Realistic ball physics
- Up to 8 players (local or online)
- Multiple game modes (stroke, scramble, stableford, match play, etc.)
- Community course creation tools (OPCD, GreenKeeper)
- **Does not do any tracking itself**

#### Sources
- [GSPro Official](https://gsprogolf.com/)
- [Carl's Place GSPro Review](https://www.carlofet.com/blog/gspro-software-review)

### 5c. Full Swing Golf

| Field | Details |
|-------|---------|
| **Full Name** | Full Swing KIT Launch Monitor + Simulator |
| **Company** | Full Swing Golf |
| **Category** | Premium launch monitor + simulation |
| **Price** | KIT Launch Monitor: $4,999; Pro simulators: $30,000+ |
| **Platforms** | PC, iOS (via E6 Connect, GSPro) |

#### Technology

- **Dual-mode 24 GHz Doppler radar** + machine-learning image processing
- 4K camera with 1080p output for integrated swing capture
- **16 data points:** Carry, total distance, spin rate, spin axis, face angle, face to path, attack angle, launch angle, ball speed, club speed, smash factor, club path, horizontal angle, apex height, side carry, side total
- Built-in lithium-ion battery (5 hours)
- 5.3" Full HD OLED display
- Endorsed by Tiger Woods and top PGA Tour players

#### Sources
- [Full Swing Official](https://www.fullswinggolf.com/)
- [PlayBetter KIT Review](https://www.playbetter.com/blogs/golf-simulator-reviews/full-swing-kit-review)

### 5d. Golfzon

| Field | Details |
|-------|---------|
| **Full Name** | Golfzon / Golfzon WAVE |
| **Company** | Golfzon Co., Ltd. (South Korea) |
| **Category** | Commercial + home golf simulation |
| **Price** | WAVE: ~$4,000; Two Vision: up to $70,000 |
| **Platforms** | Proprietary + mobile app |

#### Technology

- **WAVE: Dual technology** -- Doppler radar (full shots) + infrared sensor putting mat
- 34 data parameters via WAVE Skills mobile app
- Vision software with 100+ courses (3D renditions)
- Portable for outdoor use as a launch monitor
- Online multiplayer competition across locations
- Commercial systems include moving floor plates and ball tee-up mechanisms

#### Sources
- [Golfzon WAVE](https://www.golfzonwave.com/)
- [Golfzon Commercial](https://www.golfzongolf.com/)

### 5e. OptiShot Golf

| Field | Details |
|-------|---------|
| **Full Name** | OptiShot 2 |
| **Company** | OptiShot Golf (DancingDogg) |
| **Category** | Budget infrared golf simulator |
| **Price** | ~$299-$500 |
| **Platforms** | PC, Mac |
| **Hardware Required** | OptiShot infrared sensor pad |

#### Technology

- **16 infrared sensors** firing at 48 MHz (10,000 pulses/second)
- Sensors bounce IR off the **sole of the club** as it passes over the mat
- Measures: Clubhead speed, face angle, swing path
- **Does NOT track the ball** -- estimates ball flight from club data only
- Advertised accuracy: +/-2 mph clubhead speed, +/-1.5 degrees face angle, +/-1.9 degrees swing path

#### Known Limitations

- Only measures the club (not the ball)
- "Ballpark" simulation -- accuracy diminishes at higher swing speeds
- Mat-based only (can't use with real balls outdoors)
- No spin data

#### Relevance to Our Project

- Demonstrates that **club-only tracking** (without ball tracking) can produce usable simulation data
- IR approach at 10,000 Hz is far faster than any phone camera, but the principle of "measure the club, estimate the ball" is relevant

#### Sources
- [Practical-Golf OptiShot 2 Review](https://practical-golf.com/optishot-2-review)
- [OptiShot Specifications](https://www.par2pro.com/Optishot/SystemDetails2.html)

### 5f. ProTee Golf

| Field | Details |
|-------|---------|
| **Full Name** | ProTee VX |
| **Company** | ProTee Group |
| **Category** | Overhead camera launch monitor + simulator |
| **Price** | ~$3,000-5,000 (no subscriptions -- lifetime software included) |
| **Platforms** | PC (Windows) |

#### Technology

- **Machine vision + AI-powered** ceiling-mounted dual high-speed cameras
- Shot analysis in <0.3 seconds
- ProTee Labs software with driving range, bag mapping, dispersion, wedge matrix
- Compatible with GSPro and other simulation software
- ProTee Play: Cloud-based gaming platform (mini-games, zombie mode, etc.)

#### Sources
- [ProTee Group](https://proteegroup.com/)
- [PlayBetter ProTee VX Review](https://www.playbetter.com/blogs/golf-simulator-reviews/protee-vx-review)

### 5g. Creative Golf 3D

| Field | Details |
|-------|---------|
| **Full Name** | Creative Golf 3D |
| **Company** | Creative Golf |
| **Category** | Golf simulation software |
| **Price** | Subscription-based (various tiers) |
| **Platforms** | PC |

#### Technology

- LIDAR-measured, hand-crafted course recreations
- "Floating Grid" green reading feature
- Multiple game modes: course play, driving range, mini-golf, tournaments
- Creative Golf Editor for community course creation
- Major 2025 graphics overhaul (Advanced version)
- Compatible with various launch monitors

#### Sources
- [Creative Golf Official](https://creativegolf.com)
- [Golf Simulator Forum 2025 Review](https://golfsimulatorforum.com/forum/golf-simulator-brands-and-types/creative-golf-3d/415861-creative-golf-3d-2025-review-new-graphics-setup-features-more)

### 5h. Awesome Golf

| Field | Details |
|-------|---------|
| **Full Name** | Awesome Golf |
| **Company** | Awesome Golf |
| **Category** | Casual golf simulation software |
| **Price** | $14.99/month, $159.99/year, or **$349.99 lifetime** |
| **Platforms** | PC, iOS, Android |

#### Technology

- Ball flight tracing with club and ball statistics
- Fun game modes and basic coaching tools
- Community app for stat recording
- Compatible with FlightScope, Garmin, Rapsodo, Bushnell, Foresight
- Designed for casual players and families

#### Sources
- [Awesome Golf Official](https://www.awesome-golf.com/)

---

## 6. GPS & Shot Tracking Systems

### 6a. Arccos Golf

| Field | Details |
|-------|---------|
| **Full Name** | Arccos Smart Sensors |
| **Company** | Arccos Golf |
| **Category** | Automatic shot tracking + AI caddie |
| **Price** | Sensors: ~$179 + $149.99/year subscription |
| **Platforms** | iOS, Android, Apple Watch |
| **Technology Type** | Impact sensors (screw into grip end) + phone GPS/microphone |

#### How It Works

1. Sensors in each club grip detect impact via vibration
2. Signal sent to phone via Bluetooth ("I'm a 7-iron, I just hit a shot")
3. Phone GPS records exact shot location
4. Additional shot detection via phone motion sensors + microphone
5. AI analyzes 25 million rounds / 1.5 billion shots / 3.9 trillion data points

#### Metrics

- Shot distances per club, shot patterns, fairways hit, GIR, scrambling, putting stats
- AI-powered GPS rangefinder (adjusted for wind, elevation, temperature, humidity, altitude)
- Strokes gained analysis
- **Does NOT measure swing speed** -- only shot location and club used

#### Sources
- [Arccos Golf](https://www.arccosgolf.com/)

### 6b. Shot Scope

| Field | Details |
|-------|---------|
| **Full Name** | Shot Scope V5 / X5 / CONNEX |
| **Company** | Shot Scope |
| **Category** | GPS watch + shot tracking |
| **Price** | CONNEX tags: $100 / V5 Watch: $249.99 / X5: $299.99 (NO subscription) |
| **Platforms** | iOS, Android, proprietary watches |
| **Technology Type** | 16 lightweight club tags + GPS watch/handheld |

#### Key Differentiator

- **No subscription fees** -- lifetime access to 100+ Tour-level stats
- 36,000+ preloaded courses
- Strokes Gained and Handicap Benchmarking included
- **Does NOT measure swing speed**

#### Sources
- [Shot Scope Official](https://shotscope.com/us/)

### 6c. 18Birdies

| Field | Details |
|-------|---------|
| **Full Name** | 18Birdies: Golf GPS Tracker |
| **Company** | 18Birdies |
| **Category** | GPS + scoring + AI swing analyzer |
| **Price** | Free / Premium: $99.99/year |
| **Platforms** | iOS, Android, Apple Watch, Wear OS |

#### Technology

- GPS rangefinder with 43,000+ courses
- Satellite imagery with movable cursor for yardages
- Factors slope, wind, rain, temperature, altitude into club selection
- Premium includes "AI Swing Analyzer" and 3D green maps
- **AI Swing Analyzer** uses video analysis for swing feedback

#### Sources
- [18Birdies Official](https://18birdies.com/)

### 6d. Golf Pad

| Field | Details |
|-------|---------|
| **Full Name** | Golf Pad GPS |
| **Company** | Contorra (Golf Pad) |
| **Category** | GPS rangefinder + shot tracking |
| **Price** | Free (basic) / Premium subscription / Tags: ~$80-100 |
| **Platforms** | iOS, Android, Apple Watch, Wear OS |

#### Technology

- NFC-based "Tags" -- tap tag to phone before each shot to auto-track
- GPS shot distance and club tracking
- "Plays Like" distances (elevation, altitude, weather adjusted)
- Shot dispersion patterns and statistics
- **No swing analysis or speed measurement**

#### Sources
- [Golf Pad Official](https://golfpadgps.com/)

### 6e. Game Golf

| Field | Details |
|-------|---------|
| **Full Name** | Game Golf |
| **Company** | Game Golf / ActiveMind Technology |
| **Category** | Automatic shot tracking |
| **Price** | Device: ~$100-250 |
| **Platforms** | iOS, Android |
| **Technology Type** | Club-mounted sensors + GPS |

#### Technology

- Pioneer of automatic shot tracking category
- Sensors attach to club grips to detect impacts
- GPS records shot locations
- Stats: fairways hit, GIR, scrambling, putting metrics, club distances
- **No swing speed measurement**

#### Sources
- [Amazon: Game Golf](https://www.amazon.com/Game-Golf-Digital-Tracking-System/dp/B00JDZWQZK)

---

## 7. Wearable Sensor-Based Trackers

### 7a. Zepp Golf

| Field | Details |
|-------|---------|
| **Full Name** | Zepp Golf 2 Swing Analyzer |
| **Company** | Zepp Labs |
| **Category** | Wearable swing sensor |
| **Price** | ~$99-150 (device) |
| **Platforms** | iOS, Android |
| **Hardware** | Small sensor clipped to golf glove |

#### Technology

- **Dual accelerometers + dual 3-axis gyroscopes**
- Measures: Club speed, swing plane, hip rotation, tempo, backswing position
- Connects via Bluetooth to phone app
- 3D swing reconstruction

#### Accuracy (Peer-Reviewed)

- Compared to TrackMan 4 (gold standard):
  - Wedges: 4.6 +/- 14.3 km/h error
  - 7-iron: 0.9 +/- 13.8 km/h error
  - Woods: -2.7 +/- 16.0 km/h error
- "Quite accurate but with a lack of precision" -- **~12% random error**
- Accuracy degrades with higher clubhead speeds
- Source: MDPI Proceedings 2(6):246 (peer-reviewed)

#### Relevance

- Shows that **IMU-based speed measurement** has ~12% random error
- Our camera-based approach should aim to match or beat this accuracy
- Zepp's weakness (imprecision at high speeds) is a potential opportunity

#### Sources
- [Zepp Labs](https://www.zepplabs.com/en-us/golf/)
- [MDPI Validation Study](https://www.mdpi.com/2504-3900/2/6/246)

### 7b. Phigolf

| Field | Details |
|-------|---------|
| **Full Name** | Phigolf 2 |
| **Company** | PhiNetworks Co., Ltd. |
| **Category** | Motion sensor simulator |
| **Price** | ~$250 (hardware) + $1.99/month for WGT courses; Phigolf app is free |
| **Platforms** | iOS, Android |
| **Hardware** | 9-axis motion sensor + swing stick |

#### Technology

- **9-axis sensor** (accelerometer + gyroscope + magnetometer)
- Measures: Club head speed, tempo, club path, face angle, attack angle, total distance
- Swing analyzer algorithm projects trajectory from swing data
- Compatible with WGT, E6 Connect, and Phigolf apps
- 3D swing analysis and putting detail graphics
- Can be used with swing stick (no real ball) or attached to club

#### Sources
- [Phigolf Store](https://phigolfstore.com/)
- [Golf Insider UK Review](https://golfinsideruk.com/phigolf-review/)

### 7c. HomeCourse / SkyTrak

| Field | Details |
|-------|---------|
| **Full Name** | SkyTrak+ / HomeCourse |
| **Company** | SkyTrak Golf |
| **Category** | Photometric launch monitor + retractable screen simulator |
| **Price** | SkyTrak+: ~$2,995 / HomeCourse package: $5,000+ |
| **Platforms** | iOS, Android, PC, Mac |

#### Technology

- **Dual Doppler Radar** + **proprietary machine-learning software**
- Tracks: Launch angle, ball speed, backspin, sidespin, club speed, shot dispersion
- Wi-Fi pairing with iPads, PCs, and other devices
- Course Play software with premium course library
- HomeCourse Pro 180: Retractable ballistic-grade screen, 16:9 projection
- **This is a dedicated hardware device, not a phone app**

#### Sources
- [SkyTrak Official](https://www.skytrakgolf.com/)

---

## 8. Key Technology Comparison Table

### Camera/CV-Based Speed Measurement Approaches

| App | Sport | Measures Speed? | Method | Frame Rate | Accuracy | Price |
|-----|-------|----------------|--------|------------|----------|-------|
| **SwingVision** | Tennis | Yes (ball) | CV + CoreML, flight path averaging | 60 fps | ~10% vs radar | $99/yr |
| **ShotVision** | Golf | Yes (club + ball) | CV from iPhone camera | 60-240 fps | 30-50% off in bad light; decent in good light | $70/yr |
| **V1 Golf** | Golf | No (ball tracing only) | Post-process CV for trajectory | Standard | N/A | $60/yr |
| **Sportsbox AI** | Golf | No | 3D pose estimation from 2D video | Standard | N/A | $110/yr |
| **GolfFix** | Golf | No | AI vision for form analysis | 60 fps | N/A | Sub |
| **Swing Profile** | Golf | No | AI swing detection + lines | Up to 240 fps | N/A | Free/Sub |

### Hardware-Based Speed Measurement Approaches

| Device | Technology | Speed Accuracy | Price |
|--------|-----------|----------------|-------|
| **TrackMan** | Doppler radar | Gold standard (+/-1%) | $18,000-25,000 |
| **Full Swing KIT** | Dual 24GHz radar + ML | ~1-2% | $4,999 |
| **SkyTrak+** | Dual Doppler + ML | ~1-2% | $2,995 |
| **Golfzon WAVE** | Doppler radar | ~2-3% | $4,000 |
| **OptiShot 2** | Infrared (16 sensors, 10kHz) | +/-2 mph (club only) | $299 |
| **Zepp Golf 2** | IMU (glove-mounted) | ~12% random error | $99-150 |
| **Phigolf 2** | 9-axis IMU | Estimated ~10-15% | $250 |

---

## 9. Key Takeaways for Our Project

### The Opportunity Gap

1. **No golf app successfully measures clubhead speed from a phone camera alone with high accuracy.** ShotVision attempts this but struggles with reliability and accuracy in non-ideal conditions.

2. **SwingVision proves the core concept works** in tennis -- camera-only speed measurement from an iPhone, using CoreML and the Neural Engine, at ~10% accuracy relative to radar.

3. **The accuracy bar to beat is ~12%** (Zepp Golf's IMU-based random error). If we can get within 10% of radar-measured clubhead speed using only the phone camera, we would be competitive with dedicated wearable sensors.

### Technical Lessons from Competitors

| Lesson | Source | Implication |
|--------|--------|-------------|
| CoreML + Neural Engine is essential | SwingVision | Build on Apple's on-device ML stack |
| 60 fps minimum for tracking fast objects | SwingVision | iPhone 240 fps slo-mo mode could be a major advantage |
| Average speed != peak speed | SwingVision (20% gap vs radar) | Need calibration model to convert observed motion to impact speed |
| Lighting is critical | ShotVision (30-50% accuracy loss) | Must handle variable lighting or require controlled conditions |
| Camera positioning matters enormously | ShotVision | Need robust setup guidance and alignment tools |
| Shot detection reliability is hard | ShotVision (missed shots) | Invest heavily in detection reliability |
| Post-processing can supplement real-time | V1 Golf (ball tracing) | Can do real-time estimate + refined post-process calculation |
| 3D pose from 2D video is mature | Sportsbox AI (30+ points) | Can add body/swing analysis as supplementary feature |

### Critical Technical Differences: Tennis Ball vs. Golf Club

| Factor | Tennis Ball (SwingVision) | Golf Clubhead (Our App) |
|--------|--------------------------|------------------------|
| **Object size** | ~6.7 cm diameter | ~10 cm face width, thin profile |
| **Speed range** | 50-160 mph (ball) | 60-130 mph (clubhead) |
| **Frames visible** | Many (full flight path across court) | Very few (only near impact zone) |
| **Background** | Court surface (predictable) | Grass/mat (variable) |
| **Occlusion** | Occasional (player body) | Frequent (hands, arms, body) |
| **Measurement zone** | Full trajectory | Need to capture small arc near impact |
| **Color contrast** | Yellow ball on green/blue court | Dark club on variable background |

### Recommended Technical Approach (Informed by Research)

1. **Use 240 fps slow-motion mode** -- this gives 4x more frames than SwingVision's 60 fps requirement, which is critical because we have fewer frames of the club visible
2. **Target CoreML + Neural Engine** for on-device processing (proven by SwingVision)
3. **Build calibration model** to convert observed frame-to-frame club motion into estimated impact speed
4. **Handle the "average vs peak" problem** identified by SwingVision's 20% gap
5. **Invest in robust lighting detection** -- ShotVision's biggest weakness
6. **Consider club-only tracking** (like OptiShot) -- measuring the club and estimating ball data may be more feasible than tracking both
7. **Aim for <10% accuracy** to beat IMU-based sensors (Zepp's 12%)
8. **Provide clear accuracy communication** -- SwingVision succeeds despite lower accuracy than radar by being transparent about methodology

### Market Positioning

| Segment | Key Players | Our Differentiator |
|---------|-------------|-------------------|
| Camera-only speed measurement (golf) | ShotVision (unreliable) | Better accuracy, better UX, better lighting handling |
| Wearable speed sensors | Zepp (~12% error) | No hardware purchase needed; phone-only |
| Budget launch monitors | OptiShot ($299) | Free/cheap; no hardware |
| Premium launch monitors | SkyTrak ($3K), KIT ($5K) | 100x cheaper; accessible to all golfers |
| Video swing analysis | V1 Golf, GolfFix, Sportsbox | We ADD speed data to swing analysis |

---

## Appendix: Sources Index

### SwingVision (Critical Reference)
- https://swing.vision/
- https://developer.apple.com/news/?id=0pg4dthn
- https://www.apple.com/newsroom/2022/05/swupnil-sahai-and-his-co-founder-serve-an-ace-with-ai-powered-swingvision/
- https://www.mdpi.com/2076-3417/13/10/6195
- https://brian-whitney.medium.com/questions-with-swupnil-sahai-co-founder-and-ceo-of-swingvision-former-tesla-computer-vision-5303a8e85353

### Golf Camera Apps
- https://www.shotvisionapp.com/
- https://mygolfspy.com/we-tried-it/we-tried-it-shot-vision-app/
- https://www.swingprofile.com/
- https://v1sports.com/
- https://www.sportsbox.ai/

### Golf Simulators
- https://trugolf.com/pages/e6-connect
- https://gsprogolf.com/
- https://www.fullswinggolf.com/
- https://www.golfzongolf.com/
- https://proteegroup.com/
- https://creativegolf.com
- https://www.awesome-golf.com/

### GPS & Shot Tracking
- https://www.arccosgolf.com/
- https://shotscope.com/us/
- https://18birdies.com/
- https://golfpadgps.com/
- https://golfshot.com/
- https://swingu.com/

### Wearable Sensors
- https://www.zepplabs.com/en-us/golf/
- https://phigolfstore.com/
- https://www.skytrakgolf.com/

### Scientific Validation Studies
- SwingVision validation: https://www.mdpi.com/2076-3417/13/10/6195
- Zepp Golf 2 validation: https://www.mdpi.com/2504-3900/2/6/246
- Golf simulator camera technology: https://www.edmundoptics.com/knowledge-center/application-notes/imaging/machine-vision-for-golf-simulators/
