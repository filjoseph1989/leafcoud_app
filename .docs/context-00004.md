[Main](/context/context-00000.md) | [Previous](/context/context-00003.md)

# App Walkthrough & Code Structure

This guide is designed for developers who are new to the LeafCloud Flutter application. It explains the codebase from the entry point through the main user flows.

## 1. Entry Point: `lib/main.dart`

Every Flutter application starts here.

*   **File:** `lib/main.dart`
*   **Key Function:** `main()` calls `runApp(const MyApp())`.
*   **Key Widget:** `MyApp` sets up the `MaterialApp`, defines the green theme, and sets the `home` property to `DashboardScreen()`.

**Start here to:**
*   Change the app name (`title`).
*   Modify the global theme or color scheme (`ThemeData`).
*   Change the default startup screen (`home`).

## 2. Main Dashboard: `lib/dashboard_screen.dart`

This is the first screen the user sees. It serves as the central hub for the application.

*   **File:** `lib/dashboard_screen.dart`
*   **Key Widget:** `DashboardScreen`
*   **State:** Currently `StatelessWidget`, using hardcoded `data` map to simulate API responses.
*   **More Discussion:** See [Dashboard Screen Code Walkthrough](/context/context-00007.md).

**Key Components within this file:**
*   **`_buildHeader()`**: Displays the plant ID, timestamp, and the lettuce image.
*   **`_buildRecommendationCard()`**: Shows actionable advice based on sensor analysis.
*   **`_buildStatusGrid()`**: A grid showing simple status flags (e.g., "Low", "OK") for N, P, and K.
*   **`_buildSensorReadings()`**: Lists raw sensor data like EC, pH, and Temperature.
*   **`_buildNutrientPredictions()`**: Lists the specific PPM values for Nitrogen, Phosphorus, and Potassium.
*   **Navigation:** The `AppBar` contains an "History" icon button that pushes the `HistoryScreen` onto the navigation stack.

**Explore this file to:**
*   Understand how the main UI is laid out (`SingleChildScrollView`, `Column`).
*   See how data is mapped from a JSON-like structure to UI widgets.
*   Modify the layout of the dashboard cards.

## 3. History View: `lib/history_screen.dart`

This screen shows historical data trends.

*   **File:** `lib/history_screen.dart`
*   **Key Widget:** `HistoryScreen`
*   **Navigation:** Accessed by tapping the clock/history icon in the top-right of the Dashboard.

**Key Features:**
*   **List View:** Uses a `ListView.builder` to efficiently render a list of `Card` widgets.
*   **Data:** Contains a `historyData` list which mimics the response from the `/api/v1/readings/history` endpoint.

**Explore this file to:**
*   See how lists of data are rendered in Flutter.
*   Understand how the app handles navigation to secondary screens.

## Summary of Flow

1.  **Launch:** App opens `lib/main.dart` -> `MyApp`.
2.  **Home:** `MyApp` loads `lib/dashboard_screen.dart`.
3.  **Interaction:** User sees current stats.
4.  **Navigation:** User taps "History" icon -> App navigates to `lib/history_screen.dart`.

[Next](/context/context-00005.md)