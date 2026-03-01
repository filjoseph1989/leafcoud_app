[Main](/context/context-00000.md) | [Previous](/context/context-00008.md)

# Phase 2: Live Video Integration & Connectivity Refinement

This section details the implementation of the live MJPEG video feed and the critical network configuration updates required for physical device testing.

## 1. Live Video Integration
*   **VideoFeedWidget:** Created a dedicated widget in `lib/widgets/video_feed_widget.dart` that uses the `mjpeg_view` package.
*   **MJPEG Proxy:** The widget connects to the `/video_feed` endpoint, which acts as a proxy for the live MJPEG stream from the Raspberry Pi.
*   **Dashboard Integration:** Replaced the static header image in `lib/dashboard_screen.dart` with the `VideoFeedWidget`.

## 2. Robust JSON Handling
*   **Null Safety:** Transitioned from null assertions (`!`) to safe navigation (`?.`) and null-coalescing (`??`) operators. This prevents application crashes when certain sensor readings or status fields are missing from the API response.
*   **Structure Flexibility:** Updated the mapping logic to support both "predictions" (NPK) and legacy "npk_levels" keys, as well as handling both string-based and map-based status fields.

## 3. Connectivity & Environment Updates
*   **Local IP Configuration:** For physical Android device testing, all API URLs were updated to use the host Mac's local network IP (e.g., `192.168.1.7`) instead of `127.0.0.1`.
*   **Emulator Addressing:** Documented the use of `10.0.2.2` for Android Emulators to communicate with the host machine's backend.
*   **Security & Network:** Verified that both the computer and the physical device must be on the same Wi-Fi network and that the backend must bind to `0.0.0.0` or the specific local IP.
