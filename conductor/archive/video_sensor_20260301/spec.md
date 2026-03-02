# Track Specification: Video Feed & Sensor Data Integration (video_sensor_20260301)

## 1. Overview
The goal of this track is to integrate a live MJPEG video feed and real-time sensor metrics (temperature, EC, pH) into the Flutter dashboard. This will provide users with immediate visual feedback and data-driven insights from their cloud infrastructure resources.

## 2. Technical Requirements
- **Endpoint:** http://localhost:8000/video_feed (MJPEG Stream)
- **Data Endpoint:** POST /iot/sensor_data/ (for reading existing data)
- **Frontend Framework:** Flutter (Dart)
- **State Management:** Provider (or similar) for real-time updates.
- **MJPEG Rendering:** `mjpeg_view` package.
- **Data Visualization:** `fl_chart` (already in `pubspec.yaml`).

## 3. Key Features
- **Live Video Widget:** A widget that consumes and displays the MJPEG stream.
- **Real-time Metric Cards:** Dynamic display of temperature, EC, pH, and system status.
- **Interactive Dashboard:** Seamless integration of video and sensor data on the main dashboard screen.

## 4. Success Criteria
- [ ] Video feed displays correctly in the app without stuttering.
- [ ] Sensor metrics update in real-time as data changes.
- [ ] Automated tests for `ApiService` and `SensorData` model passing.
- [ ] >80% code coverage for the new features.