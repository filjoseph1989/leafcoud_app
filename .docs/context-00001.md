[Previous](/context/context-00000.md)

# API Endpoints & Data Model

This document outlines the classic IoT-to-App workflow for the LeafCloud application, where the Raspberry Pi acts as the **Data Collector** and the Flutter App as the **Data Viewer**.

The app consumes `GET` endpoints to fetch data from the server.

---

### 1. Endpoint: Get Latest Readings (Dashboard)

This endpoint retrieves the single most recent data entry to display on the main dashboard for an "at-a-glance" view.

* **Method:** `GET`
* **Endpoint:** `/api/v1/readings/latest`
* **Purpose:** To retrieve the last record created by the Raspberry Pi and CNN.

#### JSON Response Structure (Success):

```json
{
  "timestamp": "2025-11-16T10:30:01Z",
  "plant_id": "bucket_1_lettuce",
  "lettuce_image_url": "https://www.gardeningknowhow.com/wp-content/uploads/2021/05/lettuce-with-brown-edges.jpg",
  "sensors": {
    "ec": 790.5,
    "ph": 6.4,
    "temp_c": 25.1
  },
  "predictions": {
    "n_ppm": 139.4,
    "p_ppm": 46.5,
    "k_ppm": 185.8
  },
  "status": {
    "n_status": "low",
    "p_status": "ok",
    "k_status": "ok",
    "overall_status": "warning"
  },
  "recommendation": "Nitrogen is low. Consider adding 10ml of 'Grow' solution."
}
```

**Field Explanations:**

* `timestamp`: The exact time the reading was taken (ISO 8601).
* `lettuce_image_url`: The URL to the photo taken by the Raspberry Pi.
* `sensors`: Raw sensor data (EC, pH, Temperature).
* `predictions`: Final NPK values from the CNN model.
* `status`: Simple string codes for color-coding the UI (e.g., `low`, `ok`, `warning`).
* `recommendation`: Actionable advice for the user.

---

### 2. Endpoint: Get Historical Data (History Charts)

This endpoint retrieves an array of data from a specific time range to populate the line graphs on the "History" screen.

* **Method:** `GET`
* **Endpoint:** `/api/v1/readings/history?range=7d`
* **Query Parameters:** `range=24h`, `range=7d`, or `range=30d`.

#### JSON Response Structure (Success):

```json
[
  {
    "timestamp": "2025-11-15T10:00:00Z",
    "n_ppm": 120.0,
    "p_ppm": 40.0,
    "k_ppm": 160.0,
    "ec": 750.0,
    "ph": 6.2,
    "temp_c": 24.5
  },
  {
    "timestamp": "2025-11-15T12:00:00Z",
    "n_ppm": 125.0,
    "p_ppm": 42.0,
    "k_ppm": 165.0,
    "ec": 760.0,
    "ph": 6.3,
    "temp_c": 24.8
  }
]
```

---

### Flutter Application Logic

1.  **Dashboard Screen:**
    * Fetch `/api/v1/readings/latest`.
    * Update UI widgets with NPK, EC, pH, and recommendations.
    * Use `status` fields for conditional styling.

2.  **History Screen:**
    * Fetch `/api/v1/readings/history?range=7d`.
    * Feed the data into list or chart widgets to display historical trends.

[Next](/context/context-00002.md)