[Main](/context/context-00000.md) | [Previous](/context/context-00006.md)

# Dashboard Screen Code Walkthrough

This document provides a detailed breakdown of the `lib/dashboard_screen.dart` file, which serves as the primary interface for the LeafCloud application.

## 1. File Overview
The `DashboardScreen` is a `StatelessWidget` that displays real-time monitoring data for a hydroponic plant setup. It presents visual information including an image of the plant, sensor readings, nutrient status, and actionable recommendations.

## 2. Data Structure
The screen currently uses a hardcoded `data` map to simulate the response structure expected from the backend API.

```dart
final Map<String, dynamic> data = {
  "timestamp": "2025-11-16T10:30:01Z",
  "plant_id": "bucket_1_lettuce",
  "lettuce_image_url": "...",
  "sensors": { ... },
  "predictions": { ... },
  "status": { ... },
  "recommendation": "..."
};
```
*   **Purpose:** Allows UI development and testing without a live backend connection.
*   **Future Integration:** This map will eventually be replaced by a `FutureBuilder` or a state management solution (like Provider or Riverpod) fetching data from an HTTP API.

## 3. UI Components (Widget Breakdown)

The `build` method scaffolds the page using a `SingleChildScrollView` to ensure the content is scrollable on smaller screens. The layout is composed of several modular helper methods:

### 3.1. `_buildHeader()`
*   **Content:** Displays the `plant_id`, the last updated `timestamp`, and a large image of the lettuce.
*   **Image Handling:** Uses `Image.network` with:
    *   `loadingBuilder`: Shows a circular spinner while the image downloads.
    *   `errorBuilder`: Shows a fallback error icon if the image fails to load.

### 3.2. `_buildRecommendationCard()`
*   **Visuals:** A card with a light blue background (`Colors.blue[50]`) to highlight its importance.
*   **Content:** Displays the actionable advice (e.g., "Nitrogen is low. Consider adding...") directly from the `data['recommendation']` field.

### 3.3. `_buildStatusGrid()`
*   **Layout:** A 3-column `GridView` displaying the status of Nitrogen (N), Phosphorus (P), and Potassium (K).
*   **Data Source:** Uses the `data['status']` map.
*   **Note:** Currently displays raw text. This could be enhanced with color-coded badges (Red for 'Low', Green for 'OK') in future updates.

### 3.4. `_buildSensorReadings()`
*   **Purpose:** Shows raw data from hardware sensors.
*   **Content:** Electrical Conductivity (EC), pH Level, and Temperature.
*   **Helper:** Uses `_buildInfoCard` and `_buildInfoRow` for consistent styling.

### 3.5. `_buildNutrientPredictions()`
*   **Purpose:** Displays the machine learning model's estimated nutrient levels in parts per million (ppm).
*   **Content:** Specific N, P, and K values.

## 4. Helper Methods

To keep the `build` method clean, reusable UI logic is separated:

*   **`_buildInfoCard(...)`**: Creates a titled section with an icon and a list of children rows.
*   **`_buildInfoRow(...)`**: Creates a standard row with a label on the left and a value on the right (SpaceBetween).

## 5. Navigation

*   **History Button:** Located in the `AppBar` actions.
    ```dart
    IconButton(
      icon: const Icon(Icons.history, color: Colors.white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryScreen()),
        );
      },
    ),
    ```
    This pushes the `HistoryScreen` onto the navigation stack, allowing users to view past data trends.

[Next](/context/context-00008.md)
