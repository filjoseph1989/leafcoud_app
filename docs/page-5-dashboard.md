[Prev](./page-4-system-config.md) | [Next](./page-6-alert-notifications.md)

# Real-Time Monitoring Dashboard

This document describes the implementation of the AI-powered monitoring dashboard for LeafCloud, including the latest Multi-Task AI integration.

## 1. Overview
The Dashboard is the main screen shown to farmers after login. It integrates raw sensor data (pH, EC, Temp), a live plant image feed, Multi-Task AI nutrient classifications and regressions, and actionable alerts based on the active reservoir configuration.

## 2. Implementation Layers

### A. Data Models (`lib/models/dashboard_model.dart`)
- **`DashboardData`**: Root model containing reservoir info, image URL, health status, and sub-models.
    - **`isAnomaly`**: Boolean flag indicating a discrepancy between sensor data and AI visual analysis.
- **`TelemetryData`**: Raw readings for pH, EC, and Water Temperature.
- **`NutrientEstimation`**: AI calculations for:
    - **Macro Nutrients**: Nitrogen (N), Phosphorus (P), and Potassium (K) in Parts Per Million (PPM).
- **`AdvisoryInsight`**: AI-generated summary, explanation, and recommended farmer action. Includes specialized logic for "AI Sensor Anomaly Detected".
- **`ActionableAlert`**: Triggered when nutrient levels drop below 70%; includes top-up amounts in mL.

### B. User Interface (`lib/ui/dashboard_screen.dart`)
- **Profile Banner**: A prominent status bar showing the AI-detected solution profile (e.g., `Balanced`, `Macro-Leaning Blend`).
- **Health Status Badge**: Dynamically colored based on `healthStatus`:
    - **Green** (`HEALTHY`)
    - **Orange/Red** (`NUTRIENT DEFICIENT`)
- **Anomaly Warning UI**: Displays a ⚠️ warning icon and red border on pH/EC sensor cards if an anomaly is detected, alerting the farmer to potential sensor drift or clogs.
- **Image Feed**: Displays the latest plant photo captured by the Raspberry Pi.
- **Telemetry Grid**: Quick-glance cards for pH, EC, and Temperature.
- **Advisory Card**: AI-generated recommendation shown below the image.
- **Nutrient Breakdown**: Detailed row-based breakdown for Macro (NPK) and Total Concentration (PPM).

## 3. Multi-Task AI Integration
The mobile app leverages the backend's dual-head AI model (Classification + Regression):

1.  **Confidence via Classification**: The `profile_detected` field (Classification head) is displayed in the top banner to confirm that the AI recognizes the current nutrient mix.
2.  **Accuracy via Sanity Checks**: If the AI's classification (e.g., "Water") conflicts with the sensor's regression (e.g., "High EC"), the backend sets `is_anomaly: true`. The mobile app responds by visually flagging the sensor cards.
3.  **Detailed Breakdown**: The regression head now provides specific nutrient concentrations in PPM (`n_ppm`, `p_ppm`, `k_ppm`), showing a breakdown for each element alongside the total estimated PPM.

## 4. API Contract
The dashboard is driven by a single endpoint:
```
GET /api/v1/iot/dashboard/{tank_id}
```
Key response fields:
| Field | Description |
|---|---|
| `image_url` | Full `http://` URL to the latest plant image |
| `health_status` | `HEALTHY` or `NUTRIENT DEFICIENT` |
| `profile_detected` | `Balanced`, `Macro-Leaning Blend`, `Micro-Leaning Blend`, or `Water` |
| `predicted_class` | Raw AI prediction class (e.g. `Mix`, `NPK`, `Water`, etc.) |
| `is_anomaly` | `true` if AI and sensors disagree |
| `telemetry` | `{ ph, ec, water_temp, status }` |
| `estimated_nutrients` | `{ n_ppm, p_ppm, k_ppm, total_estimated_ppm, unit }` |
| `advisory` | `{ summary, explanation, farmer_action }` |
| `alert` | `null` or `{ level, message, topup_macro_ml, topup_micro_ml }` |

## 5. Platform Configuration for HTTP Image Loading
The server serves images over plain HTTP. Both Android and iOS block cleartext HTTP traffic by default.

### Android (`android/app/src/main/AndroidManifest.xml`)
Added `android:usesCleartextTraffic="true"` to the `<application>` tag.

### iOS (`ios/Runner/Info.plist`)
Added `NSAppTransportSecurity` to allow arbitrary loads.

## 6. Dynamic Integration
The dashboard is tightly coupled with **System Configuration**:
1. Identifies the **Active Reservoir** via `ConfigProvider`.
2. Requests dashboard data for that `tank_id`.
3. If no active reservoir is configured, prompts the user to set one up.
