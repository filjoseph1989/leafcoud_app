[Prev](./page-6-alert-notifications.md) | [Next](./page-8-sensor-calibration.md)

# Reading History

This document describes the implementation of the Reading History screen, which lets farmers review past sensor readings, plant photos, and AI-generated nutrient trend data.

## 1. Overview
The History screen gives farmers a time-based view of their reservoir data. It is split into two tabs — **Photos** (per-reading cards) and **Trends** (line charts) — and supports filtering by 7, 30, or 90 days.

## 2. Data Model (`lib/models/history_model.dart`)

### `HistoryReading`
A single snapshot from the Raspberry Pi upload.

| Field | Type | Description |
|---|---|---|
| `readingId` | `int` | Unique reading ID |
| `timestamp` | `DateTime` | UTC timestamp of the upload |
| `imageUrl` | `String` | Normalized image URL via `ApiConstants.normalizeImageUrl()` |
| `ph` | `double` | pH sensor reading |
| `ec` | `double` | EC sensor reading (mS/cm) |
| `waterTemp` | `double` | Water temperature (°C) |
| `predictedN/P/K` | `double?` | AI-predicted nutrient grams (nullable — pending AI) |
| `macroScale` | `double?` | Macro nutrient level as 0.0–1.0 scale |
| `microScale` | `double?` | Micro nutrient level as 0.0–1.0 scale |

**`hasAiData`**: Computed boolean — `true` when `predictedN` is not null. Controls whether AI-dependent widgets render.

### `HistoryData`
Root response object from the API.
- `tankId`, `tankName`, `days`, `total` — metadata about the query.
- `readings` — list of `HistoryReading`, newest-first from the server.

## 3. User Interface (`lib/ui/history_screen.dart`)

### A. Day Range Selector
A `ChoiceChip` row at the top of the screen with options: **7 days**, **30 days**, **90 days**.
- Selecting a chip immediately triggers `IotProvider.fetchHistory()` with the new range.
- Active chip uses the app's green (`0xFF4E7A43`) with white text.

### B. Photos Tab (`_PhotosTab` / `_ReadingCard`)
A scrollable list of per-reading cards. Each card contains:
1. **Plant image** — tappable, opens a full-screen `InteractiveViewer` with pinch-to-zoom.
2. **Timestamp** — formatted as `YYYY-MM-DD HH:MM`.
3. **"AI Pending" badge** — shown in amber when `hasAiData` is `false` (AI has not yet processed the reading).
4. **Sensor chips** — color-coded pill badges for pH (blue), EC (orange), and Temperature (red).
5. **Scale bars** — horizontal progress bars for Macro and Micro nutrient levels, only rendered when `hasAiData` is `true`. Bars turn orange below the 70% threshold.

### C. Trends Tab (`_TrendsTab`)
Line charts built with the `fl_chart` package. Data is **reversed** from the server's newest-first order to display chronologically (oldest → newest) on the x-axis.

| Chart | Color | Data source |
|---|---|---|
| pH | Blue | `reading.ph` |
| EC (mS/cm) | Orange | `reading.ec` |
| Water Temp (°C) | Red | `reading.waterTemp` |
| Nutrient Scale (AI) | Green + Purple | `macroScale` / `microScale` |

**`_ScaleChartCard`**: A special dual-line chart showing both Macro (green) and Micro (purple) scales on a 0–100% y-axis. A dashed red horizontal line marks the **70% threshold** — readings below this indicate a potential nutrient alert.

Dots on data points are only shown when there are **10 or fewer readings** to avoid clutter.

## 4. Data Flow
```
HistoryScreen.initState()
  └─ IotProvider.fetchHistory(tankId, days: 7)   ← default 7 days
       └─ GET /api/v1/iot/history/{tank_id}?days=7
            └─ returns HistoryData
                 └─ TabBarView renders _PhotosTab / _TrendsTab
```

## 5. State Handling
| State | UI |
|---|---|
| No active config | "No active reservoir. Please configure one first." |
| Loading | `CircularProgressIndicator` |
| Error | Centered error message |
| Empty | "No readings found for this period." |
| Loaded | TabBarView with Photos + Trends |
