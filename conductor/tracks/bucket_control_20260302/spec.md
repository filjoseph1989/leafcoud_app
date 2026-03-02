# Specification: Bucket Control Interface and Status Overlay

## Overview
This track implements a bucket control interface on the Dashboard screen and enhances the video feed with a status overlay. Users can select active buckets (NPK, Micro, Mix, Water) or stop current activity, with real-time feedback overlaid on the video stream.

## Functional Requirements
- **Dashboard Control Panel:**
  - Implement a `GridView` or `Wrap` on the `DashboardScreen`.
  - Include five `ElevatedButton` widgets: 'NPK', 'Micro', 'Mix', 'Water', and 'Stop'.
  - On press, each button sends a POST request to `http://192.168.1.2:8000/control/active-bucket` with the button's label as the payload.
- **Real-time Status Overlay:**
  - Update `VideoFeedWidget` to include a semi-transparent overlay.
  - Overlay displays "Active Bucket: [Name]" based on the current system status.
- **Backend Communication:**
  - Poll the backend status endpoint (to be inferred or added to `ApiService`) every 2 seconds.
  - Implement a dedicated `BucketControlNotifier` using the `provider` package to manage state and polling logic.
- **Error Handling:**
  - Silently retry failed status fetches or control requests without interrupting the user experience.

## Non-Functional Requirements
- **Consistency:** Use existing `ApiService` patterns and `provider` for state.
- **Performance:** Polling should be efficient and not block the UI thread.
- **UI/UX:** Overlay should be legible and semi-transparent to minimize obscuring the video feed.

## Acceptance Criteria
- [ ] Control buttons are visible and functional on the Dashboard screen.
- [ ] Pressing a button triggers the correct POST request to the backend.
- [ ] Video feed displays a real-time overlay of the active bucket.
- [ ] Status updates automatically every 2 seconds.
- [ ] Application remains stable even if the backend is temporarily unreachable (silent retry).

## Out of Scope
- Modifying the video stream source itself.
- User authentication for control actions.
