# Golf Launch Monitors, Apps, Simulators & Tracking Technology Research

## Table of Contents
1. [Consumer Launch Monitors](#consumer-launch-monitors)
2. [Smartphone Golf/Swing Apps](#smartphone-golf-swing-apps)
3. [SwingVision Deep Dive (Camera-Only Speed Tracking)](#swingvision-deep-dive)
4. [Simulator Software](#simulator-software)
5. [GPS / Shot Tracking Systems](#gps--shot-tracking-systems)
6. [Technology Comparison Summary](#technology-comparison-summary)

---

## Consumer Launch Monitors

### SkyTrak+ (ST+)
- **Price:** ~$1,795 (sale) / $1,995 (MSRP)
- **Technology:** Dual-technology hybrid -- Dual Doppler Radar + Advanced Photometric Camera System
- **How It Works:** Doppler radar captures club data (club head speed, smash factor, club path, face angle). High-speed photometric cameras capture ball data (launch angle, spin rate, carry distance). Machine-learning algorithms are applied to the radar data for enhanced precision.
- **Metrics:** 20+ data points including ball speed, launch angle, spin rate, spin axis, carry distance, total distance, club head speed, smash factor, club path, face angle
- **Accuracy:** Robot-tested at Golf Laboratories; results described as "virtually indistinguishable" from leading commercial launch monitors (Trackman/GCQuad tier) across the 5 most important parameters
- **Connectivity:** WiFi, compatible with E6 Connect, GSPro (via API), and native Course Play platform (61 courses from Trackman and Foresight libraries including Pebble Beach)
- **Use:** Indoor and outdoor

### Garmin Approach R10
- **Price:** ~$400-$575
- **Technology:** Doppler Radar (3-receiver radar system)
- **How It Works:** Three radar receivers analyze club and ball motion to extract metrics. Radar-based, so it sits behind the golfer and tracks through the swing. More accurate outdoors than indoors because it can track ball flight longer.
- **Metrics:** 14 data points -- club head speed, ball speed, smash factor, launch angle, launch direction, spin rate, spin axis, carry distance, total distance, club path, face angle, face to path, angle of attack, max height
- **Accuracy:**
  - Ball speed: +/-1 MPH
  - Launch angle: +/-1 degree
  - Club speed: +/-3 MPH
  - Club path: +/-4 degrees
  - Face angle: +/-2 degrees
  - Distance: off by a few yards at most outdoors; less accurate indoors
- **Physical:** 3.5" x 2.8" x 1", 5.22 oz, IPX7 water resistant, 10-hour battery
- **Connectivity:** Bluetooth to Garmin Golf app; compatible with E6 Connect, Awesome Golf, Home Tee Hero (42,000+ virtual courses for $99.99/yr)
- **Use:** Indoor and outdoor (better outdoors)

### Rapsodo MLM2PRO
- **Price:** $699 device + $199.99/yr premium membership (or $599.99 lifetime)
- **Technology:** Triple-sensor hybrid -- Doppler Radar + Dual Camera System (Impact Vision Camera + Shot Vision Camera)
- **How It Works:**
  1. **Doppler Radar:** Measures ball speed, launch angle, and distance
  2. **Impact Vision Camera (240fps):** Reads RPT (Rapsodo Precision Technology) printed patterns on special Callaway Chrome Soft X balls to measure spin rate and spin axis with high precision
  3. **Shot Vision Camera (wide-angle):** Records the swing from behind and shows the ball's flight path overlaid on video, similar to TV broadcast shot tracers
- **Metrics:** 13 data points -- 7 measured directly, 6 calculated. Ball speed, launch angle, launch direction, carry distance, total distance, spin rate (with RPT balls), spin axis (with RPT balls), club head speed, smash factor, max height
- **Accuracy:**
  - With RPT balls: spin readings within 1-2% of Trackman
  - Carry distance: <2 yards vs Trackman (wedge/7-iron), ~5 yards (driver)
  - Without RPT balls: spin rate is estimated/less accurate
- **Connectivity:** WiFi/Bluetooth; compatible with E6 Connect, GSPro (via connector), Awesome Golf
- **Use:** Indoor and outdoor

### Voice Caddie / Swing Caddie SC4 Pro & SC300i

#### SC4 Pro (2025)
- **Price:** ~$599
- **Technology:** Doppler Radar with ProMetrics engine
- **How It Works:** Doppler radar positioned behind the golfer measures ball speed and club speed, then calculates derived metrics. "ProMetrics engine" is their proprietary algorithm layer.
- **Metrics:** 12 data points -- carry distance, total distance, ball speed, swing speed, smash factor, apex height, launch angle, side spin, back spin, spin axis, dispersion/deviation
- **Accuracy:** Measuring range 15-370 yards; accuracy specs not published precisely but considered competitive in the sub-$600 category
- **Extras:** Built-in LCD display, voice output of distance, remote control, rechargeable Li-Ion battery; connects to VOICECADDIE S app for 3D driving range; comes with 5 free E6 Connect courses
- **Use:** Indoor and outdoor

#### SC300i
- **Price:** ~$250-$300
- **Technology:** Doppler Radar + atmospheric pressure sensors
- **Metrics:** Carry distance, total distance, swing speed, ball speed, smash factor, launch height (apex), spin rate (via app)
- **Accuracy:** +/-2% ball speed; +/-3 yards carry (target mode); +/-3% carry (practice mode)
- **Use:** Primarily a practice/range tool; outdoor focused

### Ernest Sports ES16
- **Price:** ~$3,500-$4,000
- **Technology:** Hybrid -- Quad Doppler Radar + Dual Photometric cameras
- **How It Works:** The quad radar handles speed measurements (most accurate technology for speed), while dual photometric cameras excel at spin and directional measurements. Combining both provides comprehensive coverage.
- **Metrics (extensive):**
  - **Ball data:** Carry distance, total distance, roll distance, ball speed, launch angle, launch direction angle, spin rate, spin axis, max height, hang time, shot dispersion, landing angle
  - **Club data:** Club head speed, smash factor, angle of attack, spin loft, face angle, club path, dynamic loft
- **Accuracy:** Professional-grade; positioned between consumer and commercial tiers
- **Connectivity:** Free companion app; compatible with The Golf Club simulation software and other simulation platforms
- **Use:** Indoor and outdoor

---

## Smartphone Golf/Swing Apps

### V1 Golf
- **Type:** Video swing analysis app
- **Price:** Free basic; coaching memberships for premium features
- **Platform:** iOS and Android
- **Technology:**
  - **Ball Tracing:** Visualizes golf ball flight path from video WITHOUT radar -- uses computer vision to detect ball trajectory from camera footage
  - **Skeletal Tracking:** AI-based body pose detection identifies body movements and shifts through clothing
  - **Ground Pressure Integration:** Connects to compatible ground pressure sensors for weight transfer analysis
- **Key Features:** Side-by-side comparison with PGA/LIV/LPGA model swings library, HD capture, frame-by-frame playback, drawing tools (lines, circles, boxes in 6 colors), video overlay, live video coaching sessions with real coaches
- **Relevance to Speed Tracking:** Ball Tracing demonstrates feasibility of camera-only ball flight detection, though it provides trajectory rather than precise speed measurements

### Hudl Technique (formerly Ubersense)
- **Type:** Video analysis app (multi-sport, includes golf-specific version)
- **Price:** Free with in-app purchases
- **Platform:** iOS
- **Technology:** High-speed camera capture (up to 240 FPS on supported devices) with slow-motion playback
- **Key Features:** Record at 240fps, slow-motion analysis with swing plane drawings, comparison against 90+ PGA golfer swings, zoom/pan, drawing tools, side-by-side/stacked video comparison, synchronized comparison videos
- **Scale:** Over 10 million swings analyzed worldwide
- **Note:** More of a manual analysis tool -- no automatic metrics extraction

### Coach's Eye
- **Status: DISCONTINUED as of September 2022** (by parent company TechSmith)
- **What It Was:** Video analysis app with instant playback, slow motion, annotation tools (lines/arrows drawn on video), file management, sharing via text/email/social media
- **Alternatives:** Coachly, Onform, VisualEyes, SeamsUp

### Swing Profile
- **Type:** AI-powered golf swing analysis app
- **Price:** Free basic; premium plans available
- **Platform:** iOS and Android
- **Technology:** Patent-pending AI for swing detection -- 5 automations:
  1. **Auto Capture:** AI detects and records swing motion automatically, hands-free
  2. **Auto Trim:** Removes redundant footage, keeps only the swing
  3. **Auto Sequence:** Generates Golf Digest-style swing sequence images
  4. **Auto Line:** Draws swing plane and measures club angle automatically
  5. **Auto Sync:** Synchronizes two different swings regardless of speed difference
- **How It Works:** Point camera at golfer, AI detects swing start/end, records, plays back instantly ("Auto Replay"). Detects front-on vs down-the-line view automatically. Can simulate 2-camera setups.
- **Key Features:** Automatic reference line drawing (club line + neck-to-ball line), dual camera support, hands-free operation
- **Relevance:** Demonstrates sophisticated on-device AI for motion detection and analysis without any sensors

### GolfShot
- **Type:** GPS rangefinder + shot tracking + swing analysis
- **Price:** Free basic; GolfShot Pro for premium features
- **Platform:** iOS (with Apple Watch), Android
- **Technology:**
  - **Auto Shot Tracking (AST):** Uses Apple Watch accelerometer/gyroscope to detect shots automatically -- first app to offer this
  - **Auto-Strokes Gained Analysis:** Calculates strokes gained automatically on Apple Watch
  - **Golfscape AR:** Augmented reality view of the course using phone camera
- **Key Features:** GPS distances, green maps with heatmaps for break reading, 3D flyovers, shot tracking, scoring, statistics
- **Relevance:** Apple Watch motion detection for automatic shot recognition is a notable sensor-free approach

### SwingU
- **Type:** Golf GPS + shot tracking + coaching platform
- **Price:** Free basic; Plus ($49.99/yr) for wind/elevation/club recs/green maps; Pro ($99.99/yr) for full strokes gained analysis + personalized drills
- **Platform:** iOS (with Apple Watch), Android
- **Technology:** GPS-based distance measurement, shot tracking via manual input and Apple Watch detection
- **Key Features:** Strokes Gained analysis, Improvement Priority identification, personalized practice plans from Top-100 instructors, green-reading maps for 14,000+ courses, wind speed, elevation, club recommendations
- **Relevance:** Demonstrates how shot data + AI coaching can provide value without hardware sensors

---

## SwingVision Deep Dive
**(Camera-Only Ball/Racket Speed Tracking on iPhone -- Highly Relevant)**

### Overview
SwingVision is a tennis/pickleball app that achieves **real-time ball speed tracking, shot placement, and line calling using ONLY the iPhone/iPad camera** -- no radar, no external sensors. This is the closest existing analog to camera-based golf swing speed tracking.

### Founding Team
- **Swupnil Sahai** (CEO): Ex-Tesla Autopilot engineer, UC Berkeley data science professor
- **Richard Hsu** (Co-founder): Sahai's UC Berkeley roommate
- Built by AI experts from Tesla and Apple backgrounds

### Technical Architecture

#### Core Technology Stack
1. **Apple Core ML:** On-device machine learning framework for real-time video analysis
2. **Apple Neural Engine:** Hardware-accelerated ML inference -- Sahai states the app is "basically not possible without Neural Engine"
3. **On-Device Processing:** All video processing happens locally on the device -- NO internet connection required
4. **Foundation Models Integration:** Structured output from Core ML feeds into language models for natural-language coaching feedback

#### Video Processing Pipeline
- **Input:** 1080p video at 60fps from iPhone/iPad camera
- **Processing Load:** ~2 million pixels processed 60 times per second
- **Optimization:** Team had to innovate extensively to make ML models "as lean as possible" to run in real-time on mobile hardware
- **Output:** Real-time structured data about ball position, speed, trajectory, shot type, and player movement

#### How Ball Speed is Measured
- **Method:** Computer vision tracks the ball across multiple video frames
- **Speed Calculation:** Ball speed is calculated by averaging velocity over the entire flight path
- **Key Difference from Radar:** Radar guns measure peak speed immediately after impact; SwingVision provides average speed across the complete trajectory
- **Result:** Readings are approximately **20% lower** than radar-measured speeds because of the average-vs-peak difference

### Accuracy
- **Ball Speed:** Claimed within 10% accuracy (though the definition of this claim is ambiguous -- may mean 10% variability around actual value, or 10% of shots are outliers)
- **Ball Placement:** Claimed within 5% accuracy
- **Line Calling:** More accurate than human eyes for shots within 10cm of a line
- **Academic Validation:** A peer-reviewed study found SwingVision speed data showed moderate correlation with criterion radar data, with different mean values (SwingVision: ~59.6-59.9 mph vs radar criterion: ~55.1 mph), suggesting reliable relative measurements but systematic offset from radar
- **Camera Setup Requirement:** 60FPS minimum, proper camera positioning is critical for accuracy

### Pricing
- **Free tier:** 2 hours/month of video analysis and shot tracking
- **Pro:** $179.99/year ($14.99/month)
- **Max:** Family plan, up to 5 members

### Key Metrics Tracked (Camera Only)
- Ball speed (averaged over flight)
- Shot placement and distribution
- Shot type classification (forehand/backhand/volley/serve)
- Rally length
- Court positioning
- Points played
- Line calling (in/out)
- Spin detection (visual)

### Implications for Golf Swing Speed App
1. **Proof of Concept:** SwingVision proves that camera-only speed measurement is viable on consumer iPhone hardware using Core ML + Neural Engine
2. **Speed Accuracy Limitation:** The ~20% lower reading vs radar and ~10% accuracy band suggests camera-only speed measurement is useful for relative comparison and trend tracking, but not yet radar-accurate for absolute measurements
3. **On-Device is Essential:** Real-time processing requires Neural Engine; cloud processing would introduce unacceptable latency
4. **Model Optimization is Critical:** The biggest engineering challenge is making ML models lean enough for real-time mobile inference
5. **Object Detection in Motion:** Tennis ball tracking at 60fps across a court is technically similar to tracking a golf club head or ball in a swing (both involve small, fast-moving objects)
6. **Average vs Peak Speed:** Any camera-based system will inherently measure differently than radar -- this needs to be clearly communicated to users

---

## Simulator Software

### E6 Connect (by TruGolf)
- **Price:** Varies by license tier; typically $300-$500/yr for consumer
- **Technology:** 4K-capable graphics engine refined over 30+ years; LiDAR-mapped course recreations accurate within centimeters of real-world counterparts; advanced physics engine
- **Course Library:** 100+ courses including premium real-world recreations
- **Compatibility:** Truly cross-platform (PC and iOS); compatible with virtually every leading launch monitor -- TruGolf, FlightScope, Garmin R10/R50, Rapsodo, Foresight, and many more
- **Game Modes:** Stroke, Scramble, Best Ball, Stableford, Match Play, plus mini-games (Closest to Pin, Demolition Driving Range, Long Drive, 301)
- **Commercial Features:** CLUBHOUSE Module for running leagues and simulator businesses

### GSPro
- **Price:** $250/year subscription
- **Technology:** Built on Unity gaming engine; 4K graphics; independent ball flight physics engine
- **Course Library:** 1,000+ user-created courses via open-platform model (courses built with Unity + Open Platform Course Designer using LiDAR data)
- **Compatibility:**
  - **Official:** ProTee VX, Uneekor, Foresight (GC3/GCQuad/GCHawk), Bushnell, FlightScope, Full Swing KIT, Garmin
  - **Via Open API:** SkyTrak, Garmin R10, and others through third-party connectors
  - Note: Foresight Launch Pro requires $499/yr Gold Subscription
- **Requirements:** Windows PC (Win 10/11), GTX 1070 or RX 580 GPU minimum, 4GB free storage
- **Community:** Very active modding/course-creation community; considered best value in sim software

### OptiShot (OptiShot 2)
- **Price:** $299 (OptiShot 2); $5,995 (OptiShot BallFlight with all courses)
- **Technology:** Infrared optical sensor pad -- NOT a launch monitor; does NOT track the ball
- **How It Works:** 16 precisely-tuned high-speed 48MHz infrared sensors fire ~10,000 pulses per second. Sensors bounce IR light off the sole of the club slightly before and after impact to measure club head speed, face angle, and swing path. Software then extrapolates ball flight from these club-only variables.
- **Metrics:** Club head speed, face angle, swing path, distance (calculated), face contact, swing tempo, shot shape (all derived from club data only)
- **Limitations:** Indoor only; no actual ball tracking; accuracy is approximate since all ball data is extrapolated from club data
- **Courses:** Pre-loaded with 15 courses
- **Use Case:** Budget entry point for golf simulation

### Golfzon
- **Price:** Commercial/premium tier ($15,000-$50,000+ for full systems)
- **Technology:** High-speed stereoscopic camera system -- NOT radar-based
- **How It Works:**
  - **TwoVision System:** Two high-speed cameras (ceiling-mounted + tee-side) capture at up to 2,000fps
  - **Dimple Tracking:** Cameras focus on tracking golf ball dimples for precise spin measurement
  - **T2 Sensors:** Floor-mounted stereoscope cameras detect ball speed, direction, trajectory, spin rate, launch angle, spin axis, fade/draw from dimple rotation analysis
- **Unique Hardware:**
  - **24-way directional moving swing plate:** Recreates true stance and lie conditions (uphill/downhill/sidehill)
  - **Auto-tee feature**
  - **5-surface hitting mat**
- **Graphics:** TwoVisionNX uses Unreal Engine 5
- **Scale:** 400+ patents; world's largest indoor golf simulator company
- **Course Library:** Extensive library of accurately mapped real-world courses

### Awesome Golf
- **Price:** Subscription-based (varies by platform)
- **Technology:** Cross-platform golf simulation engine
- **Compatibility:**
  - **Platforms:** Windows 10+, iOS/iPadOS, macOS (Apple Silicon), Android 8+, ChromeOS
  - **Launch Monitors:** Bushnell Launch Pro/LPi, FlightScope Mevo Gen2/Mevo+, Foresight GC3/GC3S/GCQuad/QuadMAX/GCHawk/Falcon, Garmin R10/R50, Rapsodo MLM2PRO, Square Golf
- **Key Features:** Unique courses, mini-games (shark-infested pools, nearest pin, long drive), challenges/shootouts/leaderboards, offline mode (limited), community stats tracking
- **System Requirements:** Modest -- runs on 2017+ devices; designed for accessibility

---

## GPS / Shot Tracking Systems

### Arccos Caddie Smart Sensors
- **Price:** ~$179.99 for sensor set (14 sensors); subscription for AI features
- **Technology:** Impact detection sensors (motion + sound) + smartphone GPS + AI
- **How It Works:**
  1. **Sensors:** Screw-in sensors at the butt-end of each club grip; light and sound-activated
  2. **Shot Detection:** Combination of sensor impact detection AND phone microphone sound analysis
  3. **Location Recording:** When sensor detects impact, it signals phone via Bluetooth ("I'm a 7-iron and I just hit a shot"), phone logs GPS coordinates
  4. **AI Caddie:** After several rounds of data, AI provides adjusted yardages factoring in temperature, wind, elevation, course conditions, and personal shot patterns
- **Sensors are deactivated** when club is upside down (in bag)
- **Key Features:** GPS distances to greens/hazards, AI-powered club recommendations, strokes gained analysis, automatic shot tracking
- **Relevance:** Demonstrates sensor + phone as a distributed tracking system

### Zepp Golf
- **Price:** ~$99-$150 for sensor
- **Technology:** Wearable sensor with 3-axis gyroscope + dual accelerometers + Bluetooth
- **How It Works:** Small sensor clips to the back of the golf glove (not the club shaft). Tracks hand/wrist motion through the entire swing. If phone is in back pocket, also captures hip rotation data.
- **Metrics:** Club speed, swing plane, hip rotation, tempo, backswing position, overall swing score
- **Key Features:**
  - 3D swing replay from any angle (360-degree)
  - Spin around club plane and hand path
  - Compare backswing shape to downswing shape
  - Instant swing scoring with category breakdowns
- **Advantage:** Attaches to glove not club, so no need to switch between clubs
- **Limitation:** Measures hand/wrist motion as proxy for club motion; no ball data

### Shot Scope
- **Price:** Varies by device (~$149-$299 for watches; tags included)
- **Technology:** RFID tracking tags + GPS + Power-Sense AI
- **How It Works:**
  1. **16 RFID Club Tags:** 2nd-generation plug-n-play tags screw into butt-end of each club; embedded with smart GPS chips
  2. **Shot Detection:** Tags communicate with Shot Scope watch/device via RFID; identify which club was hit and GPS location
  3. **Power-Sense AI Strap:** Enables instant syncing and club recognition with no pairing, phone, or tagging required
  4. **Manual Mode:** Alternatively, tap club tag against device
- **Devices:** GPS watches (V5, X5), handhelds (H4), laser rangefinders, mobile tags
- **Statistics:** 100+ performance stats including club distances, approaches, short game, putting, strokes gained, handicap benchmarking
- **Dashboard:** Free mobile app + web dashboard for analysis

---

## Technology Comparison Summary

### Sensing Technologies Used

| Technology | How It Works | Speed Accuracy | Products Using It |
|---|---|---|---|
| **Doppler Radar** | Measures frequency shift of reflected microwave signal from moving object | Best for speed (+/-1-3 mph) | Garmin R10, SC300i/SC4, component in SkyTrak+, MLM2PRO, ES16 |
| **Photometric Camera** | High-speed cameras capture ball/club at impact; measure position change between frames | Good for spin, direction | Component in SkyTrak+, MLM2PRO, ES16, Golfzon |
| **Infrared Sensors** | IR pulses reflect off club sole; measure club position changes | Moderate (club only) | OptiShot |
| **Stereoscopic Camera** | Dual cameras create 3D model; track dimple patterns for spin | Excellent for spin | Golfzon TwoVision (2000fps) |
| **Computer Vision/ML (Camera-only)** | ML models process standard video frames to detect and track objects | ~10-20% variance | SwingVision, V1 Golf (ball trace), Swing Profile |
| **IMU Sensors (Accelerometer/Gyro)** | Measure acceleration and rotation of attached object | Good for swing metrics | Zepp Golf, Arccos (impact detect) |
| **RFID + GPS** | RFID identifies club; GPS logs location | N/A (location, not speed) | Arccos, Shot Scope |

### Price vs. Accuracy Tiers

| Tier | Price Range | Speed Accuracy | Example Products |
|---|---|---|---|
| **Professional** | $15,000+ | +/-0.1 mph | Trackman, Foresight GCQuad, Golfzon |
| **Prosumer** | $2,000-$5,000 | +/-0.5-1 mph | SkyTrak+, Ernest Sports ES16 |
| **Mid-Range** | $500-$1,000 | +/-1-2 mph | Rapsodo MLM2PRO, SC4 Pro |
| **Budget Hardware** | $300-$500 | +/-1-3 mph | Garmin R10, SC300i |
| **Camera-Only (App)** | $0-$180/yr | +/-10-20% | SwingVision (tennis), V1 Golf (trajectory only) |
| **Entry Simulator** | $299 | Estimated only | OptiShot 2 |

### Key Technical Takeaways for Camera-Based Speed Tracking

1. **SwingVision proves it works:** Camera-only speed tracking on iPhone is commercially viable and used by millions of tennis players
2. **Neural Engine is required:** Real-time processing of 1080p@60fps needs hardware ML acceleration
3. **Core ML is the framework:** Apple's on-device ML framework handles the video analysis pipeline
4. **Accuracy gap exists:** ~10-20% variance from radar is the current state-of-the-art for camera-only
5. **Average vs Peak:** Camera measures average speed over trajectory; radar measures peak at impact -- fundamentally different measurements
6. **Model optimization is the hard part:** Making ML models lean enough for real-time inference on mobile is the primary engineering challenge
7. **No one does this for golf yet:** There is no golf app doing real-time camera-only club head speed measurement -- this is a market gap
8. **Closest golf analog:** V1 Golf's Ball Tracing does camera-based ball flight path detection, and Swing Profile does AI swing detection, but neither measures speed from camera
