[Prev](./page-7-reading-history.md) | [Next](./page-9-shared-components.md)

# Sensor Calibration

This document describes the Sensor Calibration screen, which allows farmers to remotely trigger calibration mode on the Raspberry Pi's pH and EC sensors.

## 1. Overview
Physical sensors drift over time and require periodic calibration using reference solutions. The Calibration screen exposes a toggle per sensor that signals the Raspberry Pi to enter or exit calibration mode — without requiring physical access to the device.

## 2. Data Model (`lib/models/calibration_model.dart`)

### `SensorCalibration`
| Field | Type | Description |
|---|---|---|
| `id` | `int` | Unique sensor record ID |
| `sensorName` | `String` | Raw sensor identifier (e.g. `ph_sensor`, `ec_sensor`) |
| `isCalibrating` | `bool` | `true` = sensor is currently in calibration mode |
| `updatedAt` | `DateTime` | UTC timestamp of the last state change |

**`copyWith()`**: Used by the provider to apply optimistic UI updates before the API response returns.

## 3. User Interface (`lib/ui/calibration_screen.dart`)

### A. Calibration Card (`_buildCalibrationCard`)
Each sensor is shown as a card with three areas:

- **Left icon**: Science beaker (pH, blue) or bolt/lightning (EC, purple), shown in a circular container.
- **Middle info**:
  - Sensor name — formatted by `_formatSensorName()`, which converts `ph_sensor` → `pH Sensor`, `ec_sensor` → `EC Sensor`.
  - Status badge — **IDLE** (green) or **CALIBRATING** (orange).
  - Last updated timestamp — displayed in local time (`YYYY-MM-DD HH:MM:SS`).
- **Right switch**: A `Switch` widget that toggles calibration mode.
  - Active (calibrating): orange thumb + orange track.
  - Inactive (idle): grey.

### B. Card Border
Cards get an orange border (`Colors.orange` at 50% opacity) when `isCalibrating` is `true`, providing an additional visual cue that the sensor is active.

### C. Error Snackbar
If `CalibrationProvider.toggleCalibration()` returns `false`, a red `SnackBar` displays the error message from the provider.

## 4. Provider (`lib/providers/calibration_provider.dart`)
- **`fetchCalibrations()`**: Loads all sensor records from the server on screen open and on manual refresh.
- **`toggleCalibration(id, value)`**: Sends a PATCH request to update `is_calibrating`. Returns `bool` indicating success.

## 5. API Endpoints
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/iot/calibration/` | Fetch all sensor calibration records |
| `PATCH` | `/api/v1/iot/calibration/{id}/` | Update `is_calibrating` for a sensor |

## 6. Data Flow
```
CalibrationScreen.initState()
  └─ CalibrationProvider.fetchCalibrations()
       └─ GET /api/v1/iot/calibration/
            └─ List<SensorCalibration> rendered as cards

User toggles Switch
  └─ CalibrationProvider.toggleCalibration(id, newValue)
       └─ PATCH /api/v1/iot/calibration/{id}/
            └─ success → list refreshed
            └─ failure → SnackBar shown
```

## 7. State Handling
| State | UI |
|---|---|
| Loading (first load) | `CircularProgressIndicator` |
| Error (first load) | Error icon + message + Retry button |
| Empty | "No calibration data found." |
| Loaded | Scrollable list of sensor cards |
| Pull-to-refresh | Calls `fetchCalibrations()` again |
