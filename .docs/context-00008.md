[Main](/context/context-00000.md) | [Previous](/context/context-00007.md)

# API Integration & Flutter Widget Architecture

This section details the transition from static mock data to dynamic API integration in `lib/dashboard_screen.dart`, while exploring the fundamental concepts of Flutter's widget system.

## 1. Understanding Widgets
In Flutter, "everything is a widget." A **Widget** is a basic building block of the user interface. It is an immutable description of a part of the UI, specifying how that part should look given its current configuration and state.

*   **Composition:** Complex UIs are built by nesting widgets within each other (the Widget Tree).
*   **Declarative UI:** You don't "change" a widget; you describe what the UI should look like based on data, and Flutter handles updating the pixels on the screen.

## 2. Stateless vs. Stateful Widgets
The transition in `lib/dashboard_screen.dart` highlights the two main types of widgets in Flutter:

### StatelessWidget
*   **Concept:** A widget that doesn't require mutable state. It is "dumb" and only depends on the information passed to it through its constructor.
*   **Behavior:** It only builds once and doesn't change during its lifetime unless its parent rebuilds it with new data.
*   **Use Case:** Icons, static text, or the previous version of our Dashboard when it used hardcoded data.

### StatefulWidget
*   **Concept:** A widget that can change its appearance over time in response to events (user interaction, data arrival).
*   **Behavior:** It consists of two classes: the Widget itself (immutable) and a **State** object (mutable). The State object persists while the widget rebuilds.
*   **The `setState()` Method:** This is the key. Calling `setState(() { ... })` tells Flutter that some data has changed and the framework should rebuild that specific part of the UI.
*   **Use Case:** Form inputs, animations, or our current Dashboard that needs to wait for an API response.

## 3. State Management Update
*   **The Change:** `DashboardScreen` was converted from a `StatelessWidget` to a `StatefulWidget` to handle the lifecycle of asynchronous data fetching.
*   **State Variables:**
    *   `Map<String, dynamic>? data`: Stores the fetched JSON data.
    *   `bool isLoading`: Tracks whether the network request is in progress.
    *   `String? errorMessage`: Stores error details if the request fails.

## 4. HTTP Implementation
*   **Package:** Imported `package:http/http.dart` to perform network requests.
    *   Command: `flutter pub add http`
*   **Endpoint:** The app now fetches data from `http://127.0.0.1:8000/api/v1/readings/latest`.
*   **Logic:**
    *   `initState()`: A lifecycle method in `StatefulWidget` that runs exactly once when the widget is inserted into the tree. We use it to trigger `fetchData()`.
    *   `fetchData()`: Performs a GET request asynchronously.
    *   `setState()`: Updates the UI upon success or failure by changing `isLoading`, `data`, or `errorMessage`.

## 5. UI Updates
*   **Conditional Rendering:** The `build` method now checks `isLoading` and `errorMessage` before rendering the main dashboard content.
*   **Null Safety:** Access to `data` fields now uses the null assertion operator (`!`) since `data` is nullable but guaranteed to be present when `isLoading` is false and `errorMessage` is null.

[Next](/context/context-00009.md)