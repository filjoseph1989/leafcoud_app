[Prev](./page-5-dashboard.md) | [Next](./page-7-reading-history.md)

# Alert Polling & Notifications

This document describes the implementation of the background alert polling and local notification system.

## 1. Overview
LeafCloud ensures that farmers are notified immediately when nutrient levels drop below a critical threshold without requiring the app to be actively open in the foreground (within the limits of background execution).

## 2. Technical Architecture

### A. Alert Model (`lib/models/alert_model.dart`)
A lightweight data model that maps to the server's `/api/v1/iot/alert/{tank_id}` endpoint. It focuses on the `has_alert` status and human-readable messages.

### B. Notification Service (`lib/services/notification_service.dart`)
A singleton service that abstracts the `flutter_local_notifications` plugin.
- **Initialization**: Configures Android (using the app icon) and iOS (requesting alert, badge, and sound permissions).
- **V21.0.0 Compatibility**: Uses the latest named parameter API for `initialize()` and `show()`.
- **Channel Configuration**: Defines a "Nutrient Alerts" channel for Android with high importance.

### C. Alert Provider (`lib/providers/alert_provider.dart`)
The core polling engine.
- **Polling Interval**: Set to **5 minutes** as per the server's recommendation.
- **Dependency**: Uses `ChangeNotifierProxyProvider` to depend on `ConfigProvider` so it always knows which reservoir is currently **Active**.
- **Logic**: 
    1. Every 5 minutes, it checks if an active reservoir exists.
    2. It calls `getAlertStatus()` from the repository.
    3. If `has_alert` is true, it triggers a local notification via the `NotificationService`.

## 3. Platform Configuration

### Android (`AndroidManifest.xml`)
Added `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` to support Android 13+ permission requirements.

### iOS (`Info.plist`)
Maintains `NSAppTransportSecurity` arbitrary loads to ensure it can reach the local server discovery IP during background polls.

### D. Nutrient Alerts Screen (`lib/ui/alerts_screen.dart`)
A dedicated screen that provides a comprehensive view of all reservoirs and their nutrient statuses.
- **Visual Feedback**: Uses color-coded icons (Green for Normal, Orange for Warning, Red for Critical).
- **Expansion Detail**: Each reservoir card can be expanded to show detailed top-up instructions for both Macro and Micro fertilizers.
- **Manual Refresh**: Includes a refresh button to sync alert statuses across all reservoirs on demand.

## 4. Polling Flow
1. **App Launch**: `NotificationService.init()` is called in `main.dart`.
2. **Provider Registration**: `AlertProvider` is registered in `MultiProvider` with `lazy: false`.
3. **Multi-Reservoir Check**: The provider loops through **all** configured reservoirs and fetches their specific alert status.
4. **User Action**: 
    - Tapping the "Nutrient Alerts" item in the drawer opens the `AlertsScreen`.
    - Tapping a notification opens the app to the last viewed screen (can be extended to route directly to alerts).

## 5. Alert Thresholds
As defined by the server:
- **70% - 100%**: Normal (no notification).
- **50% - 69%**: `WARNING` level notification.
- **< 50%**: `CRITICAL` level notification.
